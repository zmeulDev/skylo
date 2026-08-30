import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/uv_air_data_source.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/services/alert_evaluator.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/weather_providers.dart';

final uvAirDataSourceProvider = Provider<UvAirDataSource>((ref) {
  return UvAirDataSource(apiKey: ref.watch(openWeatherApiKeyProvider));
});

/// Threshold alerts for one saved place, evaluated from the weather the
/// app already fetched plus optional UV/air-quality enrichment. Never
/// throws — enrichment failures just yield fewer alerts.
final placeAlertsProvider =
    FutureProvider.autoDispose.family<List<WeatherAlert>, SavedPlace>((
  ref,
  place,
) async {
  // Wait for the weather this place's page already fetched, so the
  // banner never races the weather card.
  final weather = await ref.watch(placeWeatherProvider(place).future);
  final dataSource = ref.watch(uvAirDataSourceProvider);
  final lat = weather.lat;
  final lon = weather.lon;
  if (lat == null || lon == null) {
    // Coordinates unknown (legacy payloads): weather-only alerts.
    return AlertEvaluator.evaluate(weather, _Texts());
  }

  // Best-effort enrichment; failures just yield fewer alerts.
  final uv = await dataSource.uvIndex(lat, lon).catchError((_) => null);
  final aqi = await dataSource.airQualityIndex(lat, lon).catchError((_) => null);
  return AlertEvaluator.evaluate(weather, _Texts(), uvIndex: uv, aqi: aqi);
});

class _Texts implements AlertTexts {
  @override
  String headline(WeatherAlertKind kind) => kind.name;

  @override
  String whenPhrase(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:00';

  @override
  String tempPhrase(double celsius) => '${celsius.round()}°';

  @override
  String gustPhrase(double ms) => '${(ms * 3.6).round()} km/h';

  @override
  String uvPhrase(double uv) => 'UV ${uv.round()}';

  @override
  String aqiPhrase(int aqi) => 'AQI $aqi/5';
}
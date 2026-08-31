import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/uv_air_data_source.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/services/alert_evaluator.dart';
import 'package:skylo/l10n/app_localizations.dart';
import 'package:skylo/presentation/providers/locale_providers.dart';
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
  final texts = _texts(ref, weather);
  if (lat == null || lon == null) {
    // Coordinates unknown (legacy payloads): weather-only alerts.
    return AlertEvaluator.evaluate(weather, texts);
  }

  // Best-effort enrichment; failures just yield fewer alerts.
  final uv = await dataSource.uvIndex(lat, lon).catchError((_) => null);
  final aqi = await dataSource.airQualityIndex(lat, lon).catchError((_) => null);
  return AlertEvaluator.evaluate(weather, texts, uvIndex: uv, aqi: aqi);
});

AlertTexts _texts(Ref ref, WeatherEntity weather) {
  final Locale? override = ref.watch(localeProvider);
  final Locale locale = override ?? ref.watch(platformLocaleProvider);
  return _Texts(weather, locale);
}

class _Texts implements AlertTexts {
  _Texts(this.weather, this.locale);

  final WeatherEntity weather;
  final Locale locale;

  /// Localized "Tomorrow" — the delegate's lookup is synchronous for
  /// all supported locales.
  String get _tomorrowLabel =>
      lookupAppLocalizations(locale).tomorrow.toLowerCase();

  /// Whether [time] falls on a later calendar day than the place's
  /// local "today" — drives the "tomorrow" qualifier.
  bool _isTomorrow(DateTime time) {
    final now = weather.localNow();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return !time.isBefore(tomorrow);
  }

  @override
  String headline(WeatherAlertKind kind) => kind.name;

  @override
  String whenPhrase(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    if (_isTomorrow(time)) return '$_tomorrowLabel $hh:$mm';
    return '$hh:$mm';
  }

  @override
  String tempPhrase(double celsius) => '${celsius.round()}°';

  @override
  String gustPhrase(double ms) => '${(ms * 3.6).round()} km/h';

  @override
  String uvPhrase(double uv) => 'UV ${uv.round()}';

  @override
  String aqiPhrase(int aqi) => 'AQI $aqi/5';
}
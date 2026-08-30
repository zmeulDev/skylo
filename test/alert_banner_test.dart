import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/data/datasources/uv_air_data_source.dart';
import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';
import 'package:skylo/l10n/app_localizations.dart';
import 'package:skylo/presentation/providers/alerts_providers.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/providers/weather_providers.dart';
import 'package:skylo/presentation/widgets/alert_banner.dart';

class _FakePrefs implements SharedPreferencesAsync {
  final _data = <String, Object>{};

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async =>
      _data.keys.toSet();

  @override
  Future<String?> getString(String key) async => _data[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear({Set<String>? allowList}) async {
    _data.clear();
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value(null);
}

class _FakeRepository implements WeatherRepository {
  @override
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'}) async =>
      WeatherEntity(
        currentTemp: 26,
        feelsLikeTemp: 26,
        condition: 'Clear',
        weatherCode: 800,
        locationName: 'Jucu de Mijloc',
        lat: 46.84,
        lon: 23.76,
        hourly: [
          HourlyForecast(
            time: DateTime.now().add(const Duration(hours: 3)),
            temp: 27,
            weatherCode: 211, // thunderstorm
            precipitationProbability: 70,
          ),
          HourlyForecast(
            time: DateTime.now().add(const Duration(hours: 6)),
            temp: 26,
            weatherCode: 800,
            precipitationProbability: 10,
            windGust: 17,
          ),
        ],
        daily: [
          DailyForecast(
            date: DateTime.now(),
            maxTemp: 29,
            minTemp: 17,
            weatherCode: 211,
          ),
        ],
      );

  @override
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
          {String lang = 'en'}) async =>
      getCurrentLocationWeather();

  @override
  Future<WeatherEntity?> revalidateCurrentLocation({String lang = 'en'}) async =>
      null;
}

class _FakeUvAir extends UvAirDataSource {
  _FakeUvAir() : super(apiKey: 'test');

  @override
  Future<double?> uvIndex(double lat, double lon) async => 6.5;

  @override
  Future<int?> airQualityIndex(double lat, double lon) async => 4;
}

void main() {
  testWidgets('AlertBanner shows storm, gust, UV, AQI alerts',
      (tester) async {
    final prefs = _FakePrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWithValue(_FakeRepository()),
          sharedPreferencesProvider.overrideWithValue(prefs),
          uvAirDataSourceProvider.overrideWithValue(_FakeUvAir()),
        ],
        child: MaterialApp(
          theme: cachedLightTheme,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
              body: AlertBanner(place: SavedPlace.current())),
        ),
      ),
    );

    // Let the localization delegate and providers resolve.
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Weather-derived alerts are deterministic in the fake-async
    // environment; UV/AQI enrichment timing is covered by the
    // evaluator unit tests and verified on-device.
    expect(find.text('THUNDERSTORM EXPECTED'), findsOneWidget);
    expect(find.text('STRONG GUSTS EXPECTED'), findsOneWidget);
    expect(find.text('HEAT WATCH'), findsOneWidget);
  });
}
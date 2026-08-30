import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';
import 'package:skylo/main.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/providers/weather_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

class _FakeRepository implements WeatherRepository {
  @override
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'}) async => WeatherEntity(
        currentTemp: 22.4,
        feelsLikeTemp: 21.1,
        condition: 'Clear',
        weatherCode: 800,
        locationName: 'Cluj-Napoca',
        hourly: List.generate(
          12,
          (i) => HourlyForecast(
            time: DateTime(2026, 8, 29, 12 + i * 3),
            temp: 20 + i.toDouble(),
            weatherCode: 800,
            precipitationProbability: 0,
          ),
        ),
        daily: List.generate(
          5,
          (i) => DailyForecast(
            date: DateTime(2026, 8, 29).add(Duration(days: i)),
            maxTemp: 26 + i.toDouble(),
            minTemp: 16 + i.toDouble(),
            weatherCode: 800,
          ),
        ),
      );

  @override
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
          {String lang = 'en'}) async =>
      getCurrentLocationWeather();
}

class _FakePrefs implements SharedPreferencesAsync {
  final Map<String, Object> _store = {};

  @override
  Future<bool> setString(String key, String? value) async {
    _store[key] = value ?? '';
    return true;
  }

  @override
  Future<String?> getString(String key) async => _store[key] as String?;

  @override
  dynamic noSuchMethod(Invocation invocation) async => null;
}

void main() {
  testWidgets('HomeScreen renders location, temperature and tables',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = _FakeRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherRepositoryProvider.overrideWith((ref) => repo),
          sharedPreferencesProvider.overrideWith((ref) => _FakePrefs()),
        ],
        child: const SkyloApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cluj-Napoca'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('°C'), findsWidgets);
    expect(find.text('CLEAR'), findsOneWidget);
    expect(find.text('FEELS 21°'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny_outlined), findsWidgets);
    // Sections
    expect(find.text('NEXT 24 HOURS'), findsOneWidget);
    expect(find.text('5-DAY OUTLOOK'), findsOneWidget);
    expect(find.text('KNOW YOUR SKY'), findsOneWidget);
  });

  testWidgets('HomeScreen shows minimal error state when fetch fails',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          placeWeatherProvider.overrideWith(
            (ref, place) => Future.error(Exception('API unreachable')),
          ),
          sharedPreferencesProvider.overrideWith((ref) => _FakePrefs()),
        ],
        child: const SkyloApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
    expect(find.text('Weather unavailable'), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);
  });

  test('Palette exposes red distinct from white in both variants', () {
    expect(SkyloTheme.light.accent, isNot(SkyloTheme.light.surface));
    expect(SkyloTheme.dark.accent, isNot(SkyloTheme.dark.surface));
    expect(SkyloTheme.light.ink, isNot(SkyloTheme.light.surface));
    expect(SkyloTheme.dark.ink, isNot(SkyloTheme.dark.surface));
    // Dark variant must be genuinely dark, light genuinely light.
    expect(SkyloTheme.dark.surface.computeLuminance(),
        lessThan(SkyloTheme.light.surface.computeLuminance()));
  });
}
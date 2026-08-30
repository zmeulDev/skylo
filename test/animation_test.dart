import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';
import 'package:skylo/main.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/providers/weather_providers.dart';
import 'package:skylo/presentation/widgets/theme_toggle.dart';

class _AnimFakeRepo implements WeatherRepository {
  @override
  Future<WeatherEntity> getCurrentLocationWeather() async => WeatherEntity(
        currentTemp: 22.0,
        feelsLikeTemp: 21.0,
        condition: 'Clear',
        weatherCode: 800,
        locationName: 'Testville',
        hourly: List.generate(
          8,
          (i) => HourlyForecast(
            time: DateTime(2026, 8, 29, 12 + i * 3),
            temp: 20.0 + i,
            weatherCode: 800,
            precipitationProbability: 0,
          ),
        ),
        daily: List.generate(
          5,
          (i) => DailyForecast(
            date: DateTime(2026, 8, 29 + i),
            maxTemp: 26.0 + i,
            minTemp: 16.0 + i,
            weatherCode: 800,
          ),
        ),
      );

  @override
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon) async =>
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

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        weatherRepositoryProvider.overrideWith((ref) => _AnimFakeRepo()),
        sharedPreferencesProvider.overrideWith((ref) => _FakePrefs()),
      ],
      child: const SkyloApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byType(ThemeToggle));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Temperature count-up animates on unit switch',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    // Hero shows 22 (metric) once the initial count-up settles.
    expect(find.text('22'), findsOneWidget);

    await _openSettings(tester);
    expect(find.text('SETTINGS'), findsOneWidget);

    // Tap the Units row.
    await tester.tap(find.text('Units'));
    await tester.pump(); // frame of the tap
    await tester.pump(const Duration(milliseconds: 150));

    // Sheet closes instantly; count-up must still be running at 150ms.
    expect(find.text('72'), findsNothing,
        reason: 'count-up should still be running at 150ms');

    await tester.pumpAndSettle();
    expect(find.text('72'), findsOneWidget);
  });

  testWidgets('Theme switch from settings sheet runs behind the ink-reveal',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await _openSettings(tester);
    // The theme row is labeled 'Theme' with the current state as trailing.
    await tester.tap(find.text('Theme'));
    await tester.pump(const Duration(milliseconds: 100));

    // Mask expands first; theme must not have swapped yet (340ms).
    final midApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(midApp.themeMode, ThemeMode.system,
        reason: 'theme should swap at 340ms, not instantly');

    await tester.pumpAndSettle();
    final endApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final platformDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    expect(
        endApp.themeMode, platformDark ? ThemeMode.light : ThemeMode.dark);
  });

  testWidgets('Settings sheet shows theme state and units state',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    await _openSettings(tester);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    expect(find.text('°C'), findsWidgets);
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skylo/data/models/widget_snapshot.dart';
import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_entity.dart';

WeatherEntity _weather({
  List<HourlyForecast> hourly = const [],
  List<DailyForecast> daily = const [],
  int tzOffsetSeconds = 0,
  double currentTemp = 21.6,
}) =>
    WeatherEntity(
      currentTemp: currentTemp,
      feelsLikeTemp: 20.4,
      condition: 'Clear',
      conditionDescription: 'clear sky',
      weatherCode: 800,
      locationName: 'Cluj-Napoca',
      timeZoneOffsetSeconds: tzOffsetSeconds,
      hourly: hourly,
      daily: daily,
    );

double _celsius(double c) => c;
double _fahrenheit(double c) => c * 9 / 5 + 32;

void main() {
  setUpAll(() async {
    // The app relies on flutter_localizations to initialize intl's
    // locale data; pure tests must do it explicitly.
    await initializeDateFormatting();
  });

  // 2026-09-01 15:10 UTC; entity tz offset 0 → place-local 15:10.
  final now = DateTime.utc(2026, 9, 1, 15, 10);

  test('renders place, temp, condition with metric units', () {
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: _weather(),
      localeTag: 'en',
      todayLabel: 'Today',
      tomorrowLabel: 'Tomorrow',
      convert: _celsius,
      tempLabel: '°C',
      nowUtc: now,
    );

    expect(snapshot.values['temp'], '22');
    expect(snapshot.values['tempUnit'], '°C');
    expect(snapshot.values['feelsLike'], '20');
    expect(snapshot.values['condition'], 'clear sky');
    expect(snapshot.values['weatherCode'], '800');
    expect(snapshot.values['placeName'], 'Current location');
  });

  test('converts to imperial and rounds', () {
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: _weather(currentTemp: 21.6),
      localeTag: 'en',
      todayLabel: 'Today',
      tomorrowLabel: 'Tomorrow',
      convert: _fahrenheit,
      tempLabel: '°F',
      nowUtc: now,
    );

    expect(snapshot.values['temp'], '71'); // 21.6C -> 70.88F
    expect(snapshot.values['tempUnit'], '°F');
  });

  test('falls back to condition main when description empty', () {
    final weather = _weather();
    final weatherNoDesc = WeatherEntity(
      currentTemp: weather.currentTemp,
      feelsLikeTemp: weather.feelsLikeTemp,
      condition: 'Clouds',
      conditionDescription: '',
      weatherCode: 801,
      hourly: const [],
      daily: const [],
    );
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: weatherNoDesc,
      localeTag: 'en',
      todayLabel: 'Today',
      tomorrowLabel: 'Tomorrow',
      convert: _celsius,
      tempLabel: '°C',
      nowUtc: now,
    );

    expect(snapshot.values['condition'], 'Clouds');
  });

  test('hourly row keeps next 4 slots from place-local now, zero-padded',
      () {
    // Local now 15:10; slots 12,15,18,21,00 — the 12 drops.
    final hourly = [
      for (final h in [12, 15, 18, 21, 0])
        HourlyForecast(
          time: h == 0
              ? DateTime(2026, 9, 2, 0)
              : DateTime(2026, 9, 1, h),
          temp: 20.0 + h,
          weatherCode: 800,
          precipitationProbability: 0,
        ),
    ];
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: _weather(hourly: hourly),
      localeTag: 'en',
      todayLabel: 'Today',
      tomorrowLabel: 'Tomorrow',
      convert: _celsius,
      tempLabel: '°C',
      nowUtc: now,
    );

    expect(snapshot.values['h0_time'], '15');
    expect(snapshot.values['h1_time'], '18');
    expect(snapshot.values['h2_time'], '21');
    expect(snapshot.values['h3_time'], '00');
    expect(snapshot.values['h3_temp'], '20');
  });

  test('daily labels: Today, Tomorrow, then localized weekday', () {
    final daily = [
      for (var i = 0; i < 5; i++)
        DailyForecast(
          date: DateTime(2026, 9, 1).add(Duration(days: i)), // Tuesday
          maxTemp: 26 + i.toDouble(),
          minTemp: 16 + i.toDouble(),
          weatherCode: 800,
        ),
    ];
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: _weather(daily: daily),
      localeTag: 'en',
      todayLabel: 'Today',
      tomorrowLabel: 'Tomorrow',
      convert: _celsius,
      tempLabel: '°C',
      nowUtc: now,
    );

    expect(snapshot.values['d0_label'], 'Today');
    expect(snapshot.values['d1_label'], 'Tomorrow');
    expect(snapshot.values['d2_label'], 'Thu'); // Sep 3 2026
    expect(snapshot.values['d2_min'], '18');
    expect(snapshot.values['d2_max'], '28');
    expect(snapshot.values['d4_label'], 'Sat');
  });

  test('daily labels localize via intl (romanian)', () {
    final daily = [
      for (var i = 2; i < 5; i++)
        DailyForecast(
          date: DateTime(2026, 9, 1).add(Duration(days: i)),
          maxTemp: 26,
          minTemp: 16,
          weatherCode: 800,
        ),
    ];
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: _weather(daily: daily),
      localeTag: 'ro',
      todayLabel: 'Azi',
      tomorrowLabel: 'Mâine',
      convert: _celsius,
      tempLabel: '°C',
      nowUtc: now,
    );

    expect(snapshot.values['d0_label'], 'Joi'); // Thursday in Romanian
  });

  test('missing daily days render null, never stale placeholders', () {
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: _weather(daily: [
        DailyForecast(
          date: DateTime(2026, 9, 1),
          maxTemp: 26,
          minTemp: 16,
          weatherCode: 800,
        ),
      ]),
      localeTag: 'en',
      todayLabel: 'Today',
      tomorrowLabel: 'Tomorrow',
      convert: _celsius,
      tempLabel: '°C',
      nowUtc: now,
    );

    expect(snapshot.values['d0_label'], 'Today');
    expect(snapshot.values['d4_label'], isNull);
    expect(snapshot.values['d4_min'], isNull);
    expect(snapshot.values['d4_max'], isNull);
  });

  test('snapshot values cover exactly the native key namespace', () {
    final snapshot = renderWidgetSnapshot(
      place: SavedPlace.current(),
      weather: _weather(),
      localeTag: 'en',
      todayLabel: 'Today',
      tomorrowLabel: 'Tomorrow',
      convert: _celsius,
      tempLabel: '°C',
      nowUtc: now,
    );

    expect(
      snapshot.values.keys.toSet(),
      WidgetSnapshot.allKeys.toSet(),
    );
    // Every key is present (value may be null when data is absent).
    for (final key in WidgetSnapshot.allKeys) {
      expect(snapshot.values.containsKey(key), isTrue,
          reason: 'missing key: $key');
    }
  });
}
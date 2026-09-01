import 'package:flutter_test/flutter_test.dart';
import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/services/alert_evaluator.dart';

class _Texts implements AlertTexts {
  @override
  String headline(WeatherAlertKind kind) => kind.name;
  @override
  String whenPhrase(DateTime time) => '${time.hour}:00';
  @override
  String dayPhrase(DateTime time) => 'that day';
  @override
  String tempPhrase(double celsius) => '${celsius.round()}°';
  @override
  String gustPhrase(double ms) => '${ms.round()} m/s';
  @override
  String uvPhrase(double uv) => 'UV ${uv.round()}';
  @override
  String aqiPhrase(int aqi) => 'AQI $aqi';
}

WeatherEntity _weather({
  List<HourlyForecast> hourly = const [],
  List<DailyForecast> daily = const [],
  int timeZoneOffsetSeconds = 0,
}) {
  return WeatherEntity(
    currentTemp: 20,
    feelsLikeTemp: 20,
    condition: 'Clear',
    weatherCode: 800,
    timeZoneOffsetSeconds: timeZoneOffsetSeconds,
    hourly: hourly,
    daily: daily,
  );
}

void main() {
  final texts = _Texts();

  HourlyForecast h(int hourOffset,
      {int code = 800, double pop = 0, double? gust, double temp = 20}) {
    return HourlyForecast(
      time: DateTime.now().add(Duration(hours: hourOffset)),
      temp: temp,
      weatherCode: code,
      precipitationProbability: pop,
      windGust: gust,
    );
  }

  test('no alerts for calm weather', () {
    final weather = _weather(hourly: [h(1), h(2), h(3)]);
    expect(AlertEvaluator.evaluate(weather, texts), isEmpty);
  });

  test('thunderstorm in window is severe', () {
    final weather = _weather(hourly: [h(1, code: 211), h(2)]);
    final alerts = AlertEvaluator.evaluate(weather, texts);
    expect(alerts, hasLength(1));
    expect(alerts.first.kind, WeatherAlertKind.thunderstorm);
    expect(alerts.first.severe, isTrue);
  });

  test('rain with high pop produces rain alert', () {
    final weather = _weather(hourly: [
      h(1, code: 500, pop: 70),
      h(2, pop: 60),
    ]);
    final alerts = AlertEvaluator.evaluate(weather, texts);
    expect(alerts.map((a) => a.kind), contains(WeatherAlertKind.rain));
  });

  test('low-probability drizzle produces no rain alert', () {
    final weather = _weather(hourly: [h(1, code: 300, pop: 20)]);
    expect(AlertEvaluator.evaluate(weather, texts), isEmpty);
  });

  test('snow before rain reports snow', () {
    final weather = _weather(hourly: [
      h(1, code: 601, pop: 80),
      h(4, code: 500, pop: 80),
    ]);
    final alerts = AlertEvaluator.evaluate(weather, texts);
    expect(alerts.map((a) => a.kind), contains(WeatherAlertKind.snow));
    expect(alerts.map((a) => a.kind), isNot(contains(WeatherAlertKind.rain)));
  });

  test('fog in window produces fog alert', () {
    final weather = _weather(hourly: [h(2, code: 741)]);
    final alerts = AlertEvaluator.evaluate(weather, texts);
    expect(alerts.map((a) => a.kind), contains(WeatherAlertKind.fog));
  });

  test('heat watch at 28°+, severe at 32°+', () {
    final mild = _weather(hourly: [h(1, temp: 29)]);
    expect(AlertEvaluator.evaluate(mild, texts)
        .map((a) => a.kind), contains(WeatherAlertKind.heat));

    final brutal = _weather(hourly: [h(1, temp: 34)]);
    final alerts = AlertEvaluator.evaluate(brutal, texts);
    expect(alerts.first.severe, isTrue);
  });

  test('cold watch below -5°, severe below -10°', () {
    final chilly = _weather(hourly: [h(1, temp: -6)]);
    expect(AlertEvaluator.evaluate(chilly, texts)
        .map((a) => a.kind), contains(WeatherAlertKind.cold));

    final brutal = _weather(hourly: [h(1, temp: -12)]);
    expect(
        AlertEvaluator.evaluate(brutal, texts).first.severe, isTrue);
  });

  test('gusts above 14 m/s alert, above 20 severe', () {
    final breezy = _weather(hourly: [h(1, gust: 16)]);
    expect(AlertEvaluator.evaluate(breezy, texts)
        .map((a) => a.kind), contains(WeatherAlertKind.windGust));

    final stormy = _weather(hourly: [h(1, gust: 25)]);
    expect(
        AlertEvaluator.evaluate(stormy, texts).first.severe, isTrue);
  });

  test('high UV and poor air quality alerts', () {
    final weather = _weather(hourly: [h(1)]);
    final alerts = AlertEvaluator.evaluate(weather, texts,
        uvIndex: 7.5, aqi: 4);
    expect(alerts.map((a) => a.kind),
        containsAll([WeatherAlertKind.uv, WeatherAlertKind.airQuality]));
  });

  test('UV below threshold is silent', () {
    final weather = _weather(hourly: [h(1)]);
    final alerts = AlertEvaluator.evaluate(weather, texts, uvIndex: 4.6);
    expect(alerts, isEmpty);
  });

  test('entries outside the 24h window are ignored', () {
    final weather = _weather(hourly: [
      h(1),
      h(30, code: 211), // beyond window
    ]);
    expect(AlertEvaluator.evaluate(weather, texts), isEmpty);
  });

  test('hot day beyond the window does not raise a heat alert', () {
    // Reproduces the on-device report: 28° now, a 33° daily max four
    // days out — the old code alerted "now — 33°" from a day bucket
    // outside the 24h window.
    final hotFarDay = DailyForecast(
      date: DateTime.now().add(const Duration(days: 4)),
      maxTemp: 33,
      minTemp: 20,
      weatherCode: 800,
    );
    final weather = _weather(hourly: [h(1, temp: 27)], daily: [hotFarDay]);
    expect(AlertEvaluator.evaluate(weather, texts), isEmpty);
  });

  test('daily max within the window raises heat alert with hourly slot', () {
    final today = DailyForecast(
      date: DateTime.now(),
      maxTemp: 31,
      minTemp: 18,
      weatherCode: 800,
    );
    final weather = _weather(hourly: [h(1, temp: 27)], daily: [today]);
    final alerts = AlertEvaluator.evaluate(weather, texts);
    expect(alerts.map((a) => a.kind), contains(WeatherAlertKind.heat));
    // The detail quotes the peak hour actually in the window, never
    // "now": a same-day 31° bucket with a 27° hourly peak reads as
    // "14:00 — 27°" until an hourly sample tops it.
    final heat = alerts.firstWhere((a) => a.kind == WeatherAlertKind.heat);
    expect(heat.severe, isFalse); // 31 < 32 severe bar
    expect(heat.detail, contains('27°'));
  });

  test('hourly peak above daily max wins and carries its own time', () {
    final today = DailyForecast(
      date: DateTime.now(),
      maxTemp: 29,
      minTemp: 18,
      weatherCode: 800,
    );
    final weather = _weather(hourly: [h(2, temp: 34)], daily: [today]);
    final alerts = AlertEvaluator.evaluate(weather, texts);
    final heat = alerts.firstWhere((a) => a.kind == WeatherAlertKind.heat);
    expect(heat.severe, isTrue); // 34 >= 32
    expect(heat.detail, contains('34°'));
  });

  test('rain slot on tomorrow\'s calendar day gets a day-aware phrase', () {
    // Reproduces the 08:20-local user report: the first rain slot in
    // the 24h window belongs to tomorrow (e.g. 06:00), so callers must
    // be able to label it "tomorrow", not a bare time that reads as
    // a slot that already passed today. Entity times are wall-clock
    // in the place's zone, so give the entity the machine's offset to
    // keep wall clocks aligned in the test.
    final machineOffset =
        DateTime.now().timeZoneOffset.inSeconds;
    final now = DateTime.now();
    final tomorrowSixAm =
        DateTime(now.year, now.month, now.day, 6).add(const Duration(days: 1));
    // Between 00:00 and 06:00 local, tomorrow's 06:00 is more than 24h
    // out and legitimately outside the window.
    if (!tomorrowSixAm.difference(now).isNegative &&
        tomorrowSixAm.difference(now).inHours >= 24) {
      return;
    }
    final weather = _weather(
      timeZoneOffsetSeconds: machineOffset,
      hourly: [
        HourlyForecast(
          time: tomorrowSixAm,
          temp: 18,
          weatherCode: 500,
          precipitationProbability: 70,
        ),
      ],
    );

    DateTime? captured;
    final texts =
        _PhraseCapturingTexts(onWhen: (time) => captured = time);
    final alerts = AlertEvaluator.evaluate(weather, texts);

    expect(alerts.map((a) => a.kind), contains(WeatherAlertKind.rain));
    // The rain alert carries tomorrow's slot, and its calendar day is
    // not today — the caller can (and the app does) label it
    // "tomorrow".
    expect(captured, isNotNull);
    expect(captured!.hour, 6);
    // The slot is on a later calendar day than today (month-safe).
    final todayMidnight = DateTime(now.year, now.month, now.day);
    expect(captured!.difference(todayMidnight).inDays, greaterThanOrEqualTo(1));
  });
}

class _PhraseCapturingTexts implements AlertTexts {
  _PhraseCapturingTexts({required this.onWhen});
  final void Function(DateTime time) onWhen;

  @override
  String headline(WeatherAlertKind kind) => kind.name;

  @override
  String whenPhrase(DateTime time) {
    onWhen(time);
    return '${time.hour}:00';
  }
  @override
  String dayPhrase(DateTime time) => 'that day';

  @override
  String tempPhrase(double celsius) => '${celsius.round()}°';

  @override
  String gustPhrase(double ms) => '${ms.round()} m/s';

  @override
  String uvPhrase(double uv) => 'UV ${uv.round()}';

  @override
  String aqiPhrase(int aqi) => 'AQI $aqi';
}
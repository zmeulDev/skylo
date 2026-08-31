import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/entities/weather_alert.dart';

/// Texts the evaluator needs; supplied localized by the caller so the
/// evaluator stays a pure, UI-agnostic function.
abstract class AlertTexts {
  String headline(WeatherAlertKind kind);

  /// e.g. "at 15:00" or "tomorrow at 06:00" — the caller formats the
  /// time (and day, when the slot is not today) phrase.
  String whenPhrase(DateTime time);

  /// e.g. "up to 34°".
  String tempPhrase(double celsius);

  /// e.g. "gusts up to 72 km/h".
  String gustPhrase(double ms);

  /// e.g. "UV index 7".
  String uvPhrase(double uv);

  /// e.g. "air quality 4/5".
  String aqiPhrase(int aqi);
}

/// Evaluates threshold alerts from the data the app already fetches
/// (OWM 2.5 current + 5-day/3-hour forecast) plus optional UV and air
/// quality enrichment. Pure function of inputs; no I/O.
abstract final class AlertEvaluator {
  /// Alert window: the next 24h of forecast entries.
  static const _window = Duration(hours: 24);

  // Thresholds (metric, as delivered by the API).
  static const gustSevere = 20.0; // m/s — damaging gusts
  static const gustWatch = 14.0; // m/s — noteworthy
  static const heatSevere = 32.0; // °C
  static const heatWatch = 28.0; // °C
  static const coldSevere = -10.0; // °C
  static const coldWatch = -5.0; // °C
  static const popWatch = 50.0; // % precipitation probability
  static const uvHigh = 6.0; // WHO "high" begins
  static const uvVeryHigh = 8.0; // WHO "very high"
  static const aqiPoor = 4; // OWM aqi: 4 = poor, 5 = very poor

  static List<WeatherAlert> evaluate(
    WeatherEntity weather,
    AlertTexts texts, {
    double? uvIndex,
    int? aqi,
  }) {
    final alerts = <WeatherAlert>[];

    // Window: hourly entries between local now and +24h.
    final now = weather.localNow();
    final windowEnd = now.add(_window);
    final upcoming = weather.hourly
        .where((h) => !h.time.isBefore(now) && h.time.isBefore(windowEnd))
        .toList();

    // OWM condition id groups: 2xx thunderstorm, 5xx rain, 6xx snow,
    // 7xx atmosphere (fog/haze).
    HourlyForecast? first(int group) {
      for (final h in upcoming) {
        if (_inGroup(h.weatherCode, group)) return h;
      }
      return null;
    }

    final storm = first(2);
    if (storm != null) {
      alerts.add(WeatherAlert(
        kind: WeatherAlertKind.thunderstorm,
        headline: texts.headline(WeatherAlertKind.thunderstorm),
        detail: texts.whenPhrase(storm.time),
        severe: true,
      ));
    } else {
      final rain = first(5);
      final snow = first(6);
      // Whichever arrives first sets the tone; mixed days report snow.
      final snowFirst =
          snow != null && (rain == null || !snow.time.isAfter(rain.time));
      final precip = snowFirst ? snow : rain;
      if (precip != null && _maxPop(upcoming) >= popWatch) {
        final kind = snowFirst ? WeatherAlertKind.snow : WeatherAlertKind.rain;
        alerts.add(WeatherAlert(
          kind: kind,
          headline: texts.headline(kind),
          detail: texts.whenPhrase(precip.time),
        ));
      }
    }

    final fog = first(7);
    if (fog != null) {
      alerts.add(WeatherAlert(
        kind: WeatherAlertKind.fog,
        headline: texts.headline(WeatherAlertKind.fog),
        detail: texts.whenPhrase(fog.time),
      ));
    }

    // Gusts: max gust over the window (when the API reports them).
    var peakGust = -1.0;
    DateTime? peakGustTime;
    for (final h in upcoming) {
      final gust = h.windGust;
      if (gust != null && gust > peakGust) {
        peakGust = gust;
        peakGustTime = h.time;
      }
    }
    if (peakGust >= gustWatch) {
      alerts.add(WeatherAlert(
        kind: WeatherAlertKind.windGust,
        headline: texts.headline(WeatherAlertKind.windGust),
        detail:
            '${texts.whenPhrase(peakGustTime!)} — ${texts.gustPhrase(peakGust)}',
        severe: peakGust >= gustSevere,
      ));
    }

    // Temperature extremes over the window.
    if (upcoming.isNotEmpty) {
      var peak = upcoming.first.temp;
      var peakTime = upcoming.first.time;
      var trough = upcoming.first.temp;
      var troughTime = upcoming.first.time;
      for (final h in upcoming) {
        if (h.temp > peak) {
          peak = h.temp;
          peakTime = h.time;
        }
        if (h.temp < trough) {
          trough = h.temp;
          troughTime = h.time;
        }
      }
      final dayMax = _dailyMax(weather);
      final dayMin = _dailyMin(weather);
      if (peak >= heatWatch || dayMax >= heatWatch) {
        final top = peak >= dayMax ? peak : dayMax;
        alerts.add(WeatherAlert(
          kind: WeatherAlertKind.heat,
          headline: texts.headline(WeatherAlertKind.heat),
          detail:
              '${texts.whenPhrase(top == peak ? peakTime : now)} — ${texts.tempPhrase(top)}',
          severe: top >= heatSevere,
        ));
      } else if (trough <= coldWatch || dayMin <= coldWatch) {
        final bottom = trough <= dayMin ? trough : dayMin;
        alerts.add(WeatherAlert(
          kind: WeatherAlertKind.cold,
          headline: texts.headline(WeatherAlertKind.cold),
          detail:
              '${texts.whenPhrase(bottom == trough ? troughTime : now)} — ${texts.tempPhrase(bottom)}',
          severe: bottom <= coldSevere,
        ));
      }
    }

    if (uvIndex != null && uvIndex >= uvHigh) {
      alerts.add(WeatherAlert(
        kind: WeatherAlertKind.uv,
        headline: texts.headline(WeatherAlertKind.uv),
        detail: texts.uvPhrase(uvIndex),
        severe: uvIndex >= uvVeryHigh,
      ));
    }

    if (aqi != null && aqi >= aqiPoor) {
      alerts.add(WeatherAlert(
        kind: WeatherAlertKind.airQuality,
        headline: texts.headline(WeatherAlertKind.airQuality),
        detail: texts.aqiPhrase(aqi),
      ));
    }

    return alerts;
  }

  static bool _inGroup(int code, int group) =>
      code >= group * 100 && code < (group + 1) * 100;

  static double _maxPop(List<HourlyForecast> entries) {
    if (entries.isEmpty) return 0;
    return entries
        .map((e) => e.precipitationProbability)
        .reduce((a, b) => a >= b ? a : b);
  }

  static double _dailyMax(WeatherEntity weather) => weather.daily.isEmpty
      ? double.negativeInfinity
      : weather.daily.map((d) => d.maxTemp).reduce((a, b) => a >= b ? a : b);

  static double _dailyMin(WeatherEntity weather) => weather.daily.isEmpty
      ? double.infinity
      : weather.daily.map((d) => d.minTemp).reduce((a, b) => a <= b ? a : b);
}
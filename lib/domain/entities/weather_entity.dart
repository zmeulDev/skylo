import 'daily_forecast.dart';
import 'hourly_forecast.dart';

class WeatherEntity {
  final double currentTemp;
  final double feelsLikeTemp;
  final String condition;
  final String conditionDescription;
  final int weatherCode;
  final String locationName;
  final int timeZoneOffsetSeconds;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final double? lat;
  final double? lon;

  /// When this snapshot was fetched (UTC). Null for legacy/test payloads;
  /// treated as "just fetched" so such data never looks stale.
  final DateTime? observedAt;

  const WeatherEntity({
    required this.currentTemp,
    required this.feelsLikeTemp,
    required this.condition,
    this.conditionDescription = '',
    required this.weatherCode,
    this.locationName = '',
    this.timeZoneOffsetSeconds = 0,
    required this.hourly,
    required this.daily,
    this.lat,
    this.lon,
    this.observedAt,
  });

  /// Age of this snapshot. Data without a timestamp never counts as stale.
  bool olderThan(Duration maxAge) {
    final at = observedAt;
    if (at == null) return false;
    return DateTime.now().toUtc().difference(at) > maxAge;
  }

  double tempIn(WeatherUnits units) =>
      units.convertTemp(currentTemp);

  double feelsLikeIn(WeatherUnits units) =>
      units.convertTemp(feelsLikeTemp);

  /// Current wall-clock time at the place this weather belongs to.
  /// Plain wall-clock value (no offset identity) so `.day`/`.hour` read
  /// the place's local calendar fields.
  DateTime localNow() {
    final shifted =
        DateTime.now().toUtc().add(Duration(seconds: timeZoneOffsetSeconds));
    return DateTime(
        shifted.year, shifted.month, shifted.day, shifted.hour, shifted.minute);
  }
}

enum WeatherUnits { system, metric, imperial }

extension WeatherUnitsX on WeatherUnits {
  double convertTemp(double celsius) => switch (this) {
        WeatherUnits.metric => celsius,
        WeatherUnits.imperial => celsius * 9 / 5 + 32,
        WeatherUnits.system => celsius,
      };

  String get degreeLabel => switch (this) {
        WeatherUnits.metric => '°C',
        WeatherUnits.imperial => '°F',
        // Resolved by the caller against the locale before use.
        WeatherUnits.system => '°C',
      };

  String get name => switch (this) {
        WeatherUnits.metric => 'Metric (°C)',
        WeatherUnits.imperial => 'Imperial (°F)',
        WeatherUnits.system => 'System',
      };

  /// A single country code drives the default: the US uses °F,
  /// everyone else °C.
  static WeatherUnits fromCountryCode(String? code) =>
      code == 'US' || code == 'LR' || code == 'MM'
          ? WeatherUnits.imperial
          : WeatherUnits.metric;
}
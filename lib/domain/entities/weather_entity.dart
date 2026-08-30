import 'daily_forecast.dart';
import 'hourly_forecast.dart';

class WeatherEntity {
  final double currentTemp;
  final double feelsLikeTemp;
  final String condition;
  final int weatherCode;
  final String locationName;
  final int timeZoneOffsetSeconds;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherEntity({
    required this.currentTemp,
    required this.feelsLikeTemp,
    required this.condition,
    required this.weatherCode,
    this.locationName = '',
    this.timeZoneOffsetSeconds = 0,
    required this.hourly,
    required this.daily,
  });

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

enum WeatherUnits { metric, imperial }

extension WeatherUnitsX on WeatherUnits {
  double convertTemp(double celsius) => switch (this) {
        WeatherUnits.metric => celsius,
        WeatherUnits.imperial => celsius * 9 / 5 + 32,
      };

  String get degreeLabel => switch (this) {
        WeatherUnits.metric => '°C',
        WeatherUnits.imperial => '°F',
      };

  String get name => switch (this) {
        WeatherUnits.metric => 'Metric (°C)',
        WeatherUnits.imperial => 'Imperial (°F)',
      };
}
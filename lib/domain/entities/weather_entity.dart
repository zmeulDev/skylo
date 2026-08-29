import 'daily_forecast.dart';
import 'hourly_forecast.dart';

class WeatherEntity {
  final double currentTemp;
  final double feelsLikeTemp;
  final String condition;
  final int weatherCode;
  final String locationName;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const WeatherEntity({
    required this.currentTemp,
    required this.feelsLikeTemp,
    required this.condition,
    required this.weatherCode,
    this.locationName = '',
    required this.hourly,
    required this.daily,
  });
}
import 'dart:math' as math;

import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/weather_entity.dart';

/// DTO mapping OpenWeatherMap One Call API 3.0 payloads to [WeatherEntity].
class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.currentTemp,
    required super.feelsLikeTemp,
    required super.condition,
    required super.weatherCode,
    super.locationName,
    required super.hourly,
    required super.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as List<dynamic>? ?? const [];
    final dailyJson = json['daily'] as List<dynamic>? ?? const [];

    final hourly = hourlyJson
        .map((raw) => HourlyForecast(
              time: DateTime.fromMillisecondsSinceEpoch(
                ((raw['dt'] as num) * 1000).toInt(),
                isUtc: true,
              ).toLocal(),
              temp: (raw['temp'] as num).toDouble(),
              weatherCode: ((raw['weather'] as List<dynamic>).first['id'] as num).toInt(),
              precipitationProbability:
                  ((raw['pop'] as num?) ?? 0).toDouble() * 100,
            ))
        .toList();

    final daily = dailyJson.map((raw) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        ((raw['dt'] as num) * 1000).toInt(),
        isUtc: true,
      ).toLocal();
      final dayStart = DateTime(date.year, date.month, date.day);
      return DailyForecast(
        date: date,
        maxTemp: (raw['temp']['max'] as num).toDouble(),
        minTemp: (raw['temp']['min'] as num).toDouble(),
        weatherCode: ((raw['weather'] as List<dynamic>).first['id'] as num).toInt(),
        hours: hourly
            .where((h) =>
                !h.time.isBefore(dayStart) && h.time.isBefore(dayStart.add(const Duration(days: 1))))
            .toList(),
      );
    }).toList();

    return WeatherModel(
      currentTemp: (current['temp'] as num).toDouble(),
      feelsLikeTemp: (current['feels_like'] as num).toDouble(),
      condition: (current['weather'] as List<dynamic>).first['main'] as String,
      weatherCode: ((current['weather'] as List<dynamic>).first['id'] as num).toInt(),
      locationName: (json['timezone'] as String?) ?? '',
      hourly: hourly,
      daily: daily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': {
        'temp': currentTemp,
        'feels_like': feelsLikeTemp,
        'weather': [
          {'main': condition, 'id': weatherCode},
        ],
      },
      'hourly': hourly
          .map((h) => {
                'dt': h.time.millisecondsSinceEpoch ~/ 1000,
                'temp': h.temp,
                'pop': h.precipitationProbability / 100,
                'weather': [
                  {'id': h.weatherCode},
                ],
              })
          .toList(),
      'daily': daily
          .map((d) => {
                'dt': d.date.millisecondsSinceEpoch ~/ 1000,
                'temp': {'max': d.maxTemp, 'min': d.minTemp},
                'weather': [
                  {'id': d.weatherCode},
                ],
              })
          .toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModel &&
          runtimeType == other.runtimeType &&
          currentTemp == other.currentTemp &&
          feelsLikeTemp == other.feelsLikeTemp &&
          condition == other.condition &&
          weatherCode == other.weatherCode;

  @override
  int get hashCode => Object.hash(currentTemp, feelsLikeTemp, condition, weatherCode);
}

extension WeatherModelX on WeatherModel {
  List<double> get hourlyTemps => hourly.map((h) => h.temp).toList();
  double get maxTemp => daily.isNotEmpty
      ? daily.map((d) => d.maxTemp).reduce(math.max)
      : currentTemp;
  double get minTemp => daily.isNotEmpty
      ? daily.map((d) => d.minTemp).reduce(math.min)
      : currentTemp;
}
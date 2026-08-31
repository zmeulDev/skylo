import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skylo/data/models/weather_model.dart';

class WeatherApiException implements Exception {
  final int? statusCode;

  WeatherApiException(this.statusCode);

  @override
  String toString() {
    if (statusCode == 401) {
      return 'OpenWeatherMap rejected the API key (401). Check that the key is valid.';
    }
    if (statusCode == 429) {
      return 'OpenWeatherMap rate limit exceeded. Try again in a minute.';
    }
    return 'Could not reach OpenWeatherMap (status ${statusCode ?? 'unknown'}). Check your connection.';
  }
}

/// Free-tier data source using the 2.5 Current Weather and 5-day/3-hour
/// Forecast endpoints, merged into a One Call-shaped payload.
class OpenWeatherRemoteDataSource {
  static const _currentUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const _forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  final Dio _dio;
  final String apiKey;

  OpenWeatherRemoteDataSource({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));

  Future<WeatherModel> getWeather(double lat, double lon,
      {String lang = 'en'}) async {
    debugPrint('[Skylo] Fetching weather for $lat, $lon (lang: $lang)');
    final current = await _get(_currentUrl, lat, lon, lang);
    final forecast = await _get(_forecastUrl, lat, lon, lang);

    final merged = mergeToOnecallShape(current, forecast);
    // Stamp the fetch time so the app can tell how fresh the snapshot is.
    merged['observed_at'] = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    debugPrint('[Skylo] Weather fetched: ${merged['timezone'] ?? '?'}');
    return WeatherModel.fromJson(merged);
  }

  Future<Map<String, dynamic>> _get(
      String url, double lat, double lon, String lang) async {
    try {
      final response = await _dio.get<Object>(
        url,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
          'units': 'metric',
          'lang': lang,
        },
      );
      final data = response.data;
      return data is String
          ? Map<String, dynamic>.from(jsonDecode(data) as Map)
          : Map<String, dynamic>.from(data! as Map);
    } on DioException catch (e) {
      debugPrint('[Skylo] OWM request failed: ${e.type.name} '
          '${e.response?.statusCode ?? ''} ${e.message}');
      throw WeatherApiException(e.response?.statusCode);
    }
  }

  static Map<String, dynamic> mergeToOnecallShape(
    Map<String, dynamic> current,
    Map<String, dynamic> forecast,
  ) {
    return _merge(current, forecast);
  }

  static Map<String, dynamic> _merge(
    Map<String, dynamic> current,
    Map<String, dynamic> forecast,
  ) {
    final list = forecast['list'] as List<dynamic>? ?? const [];
    // The 2.5 forecast endpoint exposes the place's UTC offset only at
    // city.timezone; /weather exposes it top-level. Try both before
    // defaulting to 0 (UTC) — a wrong offset shifts every displayed
    // time to the wrong wall clock.
    final city = forecast['city'] as Map<String, dynamic>?;
    final tzOffset = ((city?['timezone'] as num?) ??
            (forecast['timezone'] as num?) ??
            (current['timezone'] as num?) ??
            0)
        .toInt();

    final hourly = list
        .map((entry) => {
              'dt': entry['dt'],
              'temp': (entry['main'] as Map<String, dynamic>)['temp'],
              'pop': entry['pop'] ?? 0,
              'weather': entry['weather'],
              'wind': entry['wind'],
            })
        .toList();

    // Group 3-hour entries into the place's own local days.
    // Wall-clock semantics: strip the UTC identity after shifting.
    DateTime placeTime(num dt) {
      final shifted =
          DateTime.fromMillisecondsSinceEpoch((dt * 1000).toInt(), isUtc: true)
              .add(Duration(seconds: tzOffset));
      return DateTime(
          shifted.year, shifted.month, shifted.day, shifted.hour);
    }

    final days = <DateTime, List<Map<String, dynamic>>>{};
    for (final entry in list) {
      final time = placeTime(entry['dt'] as num);
      final day = DateTime(time.year, time.month, time.day);
      days.putIfAbsent(day, () => []).add(entry as Map<String, dynamic>);
    }

    final daily = <Map<String, dynamic>>[];
    final sortedDays = days.keys.toList()..sort();
    for (final day in sortedDays) {
      final entries = days[day]!;
      double max = double.negativeInfinity;
      double min = double.infinity;
      Map<String, dynamic>? middayWeather;
      var middayDistance = double.infinity;
      for (final entry in entries) {
        final main = entry['main'] as Map<String, dynamic>;
        final tMax = (main['temp_max'] as num).toDouble();
        final tMin = (main['temp_min'] as num).toDouble();
        if (tMax > max) max = tMax;
        if (tMin < min) min = tMin;

        final time = placeTime(entry['dt'] as num);
        final distance = (time.hour - 12).abs().toDouble();
        if (distance < middayDistance) {
          middayDistance = distance;
          middayWeather =
              (entry['weather'] as List<dynamic>).first as Map<String, dynamic>;
        }
      }
      daily.add({
        'dt': (day.millisecondsSinceEpoch ~/ 1000) + 43200, // midday local
        'temp': {'max': max, 'min': min},
        'weather': [middayWeather],
      });
    }

    return {
      'timezone': current['name'],
      'timezone_offset': tzOffset,
      'lat': (current['coord'] as Map<String, dynamic>?)?['lat'],
      'lon': (current['coord'] as Map<String, dynamic>?)?['lon'],
      'current': {
        'dt': current['dt'],
        'temp': (current['main'] as Map<String, dynamic>)['temp'],
        'feels_like': (current['main'] as Map<String, dynamic>)['feels_like'],
        'weather': current['weather'],
      },
      'hourly': hourly,
      'daily': daily,
    };
  }
}
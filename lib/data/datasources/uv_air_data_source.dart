import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Free OWM enrichment endpoints: current UV index and air quality.
/// Both are best-effort — failures resolve to null so weather
/// rendering never depends on them.
class UvAirDataSource {
  static const _uvUrl = 'https://api.openweathermap.org/data/2.5/uvi';
  static const _airUrl =
      'https://api.openweathermap.org/data/2.5/air_pollution';

  final Dio _dio;
  final String apiKey;

  UvAirDataSource({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<double?> uvIndex(double lat, double lon) async {
    try {
      final response = await _dio.get<Object>(
        _uvUrl,
        queryParameters: {'lat': lat, 'lon': lon, 'appid': apiKey},
      );
      final data = _asMap(response.data);
      final value = (data['value'] as num?)?.toDouble();
      if (value == null || value < 0) return null;
      debugPrint('[Skylo] UV index: $value');
      return value;
    } catch (e) {
      debugPrint('[Skylo] UV fetch failed: $e');
      return null;
    }
  }

  Future<int?> airQualityIndex(double lat, double lon) async {
    try {
      final response = await _dio.get<Object>(
        _airUrl,
        queryParameters: {'lat': lat, 'lon': lon, 'appid': apiKey},
      );
      final data = _asMap(response.data);
      final list = data['list'] as List<dynamic>? ?? const [];
      if (list.isEmpty) return null;
      final aqi = ((list.first as Map)['main'] as Map)['aqi'];
      final index = aqi is num ? aqi.toInt() : null;
      if (index == null) return null;
      debugPrint('[Skylo] Air quality index: $index');
      return index;
    } catch (e) {
      debugPrint('[Skylo] Air quality fetch failed: $e');
      return null;
    }
  }

  Map<String, dynamic> _asMap(Object? data) => data is String
      ? Map<String, dynamic>.from(jsonDecode(data) as Map)
      : Map<String, dynamic>.from(data! as Map);
}
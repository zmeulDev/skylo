import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GeocodingResult {
  final String name;
  final String? state;
  final String? country;
  final double lat;
  final double lon;

  const GeocodingResult({
    required this.name,
    required this.state,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      name: json['name'] as String,
      state: json['state'] as String?,
      country: json['country'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  String get label => state == null || state == name
      ? '$name, ${country ?? ''}'
      : '$name, $state, ${country ?? ''}';
}

class GeocodingDataSource {
  static const _url = 'https://api.openweathermap.org/geo/1.0/direct';

  final Dio _dio;
  final String apiKey;

  GeocodingDataSource({required this.apiKey, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ));

  Future<List<GeocodingResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];
    try {
      final response = await _dio.get<Object>(
        _url,
        queryParameters: {
          'q': trimmed,
          'limit': 8,
          'appid': apiKey,
        },
      );
      final data = response.data;
      final list = data is String
          ? jsonDecode(data) as List
          : data! as List;
      return list
          .map((raw) =>
              GeocodingResult.fromJson(Map<String, dynamic>.from(raw as Map)))
          .toList();
    } on DioException catch (e) {
      debugPrint('[Skylo] Geocoding failed: ${e.type.name} '
          '${e.response?.statusCode ?? ''} ${e.message}');
      rethrow;
    }
  }
}
import 'package:flutter/foundation.dart';

import 'package:skylo/data/datasources/location_service.dart';
import 'package:skylo/data/datasources/open_weather_remote_data_source.dart';
import 'package:skylo/data/datasources/platform_geocoder.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final OpenWeatherRemoteDataSource _remoteDataSource;
  final LocationService _locationService;
  final PlatformGeocoder _geocoder;

  WeatherRepositoryImpl(
    this._remoteDataSource,
    this._locationService, [
    PlatformGeocoder? geocoder,
  ]) : _geocoder = geocoder ?? PlatformGeocoder();

  @override
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'}) async {
    final location = await _locationService.getCurrentLocation();
    return _weatherWithLocalName(
        location.latitude, location.longitude, lang: lang);
  }

  @override
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
      {String lang = 'en'}) {
    return _remoteDataSource.getWeather(lat, lon, lang: lang);
  }

  @override
  Future<WeatherEntity?> revalidateCurrentLocation(
      {String lang = 'en'}) async {
    final moved = await _locationService.revalidate();
    if (moved == null) return null;
    debugPrint('[Skylo] Device moved — refetching weather');
    return _weatherWithLocalName(moved.latitude, moved.longitude,
        lang: lang);
  }

  /// Fetches weather for coords, then resolves the display name via the
  /// platform geocoder when OWM's own city name snaps to a neighbor.
  /// OWM's city index is coarse (villages map to nearby towns — Jucu
  /// de Sus reads as "Apahida"), while the platform geocoder knows the
  /// same villages Google Maps does.
  Future<WeatherEntity> _weatherWithLocalName(double lat, double lon,
      {String lang = 'en'}) async {
    final weather =
        await _remoteDataSource.getWeather(lat, lon, lang: lang);

    final platformName = await _geocoder.locality(lat, lon, locale: lang);
    if (platformName == null) return weather;

    // Trust the platform when OWM's name is missing or clearly a
    // different place than the coords resolve to.
    if (platformName.toLowerCase() != weather.locationName.toLowerCase()) {
      debugPrint('[Skylo] Location name: OWM "${weather.locationName}" '
          '-> platform "$platformName"');
      return _withLocationName(weather, platformName);
    }
    return weather;
  }

  WeatherEntity _withLocationName(
      WeatherEntity weather, String name) {
    return WeatherEntity(
      currentTemp: weather.currentTemp,
      feelsLikeTemp: weather.feelsLikeTemp,
      condition: weather.condition,
      conditionDescription: weather.conditionDescription,
      weatherCode: weather.weatherCode,
      locationName: name,
      timeZoneOffsetSeconds: weather.timeZoneOffsetSeconds,
      hourly: weather.hourly,
      daily: weather.daily,
    );
  }
}
import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'});
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
      {String lang = 'en'});

  /// Returns fresh weather if the device has moved since the last
  /// current-location fetch (stale-while-revalidate), else null.
  Future<WeatherEntity?> revalidateCurrentLocation({String lang = 'en'});
}
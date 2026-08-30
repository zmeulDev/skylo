import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'});
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
      {String lang = 'en'});
}
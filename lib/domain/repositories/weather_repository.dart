import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getCurrentLocationWeather();
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon);
}
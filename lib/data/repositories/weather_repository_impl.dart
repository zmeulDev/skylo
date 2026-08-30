import 'package:skylo/data/datasources/location_service.dart';
import 'package:skylo/data/datasources/open_weather_remote_data_source.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final OpenWeatherRemoteDataSource _remoteDataSource;
  final LocationService _locationService;

  WeatherRepositoryImpl(this._remoteDataSource, this._locationService);

  @override
  Future<WeatherEntity> getCurrentLocationWeather({String lang = 'en'}) async {
    final location = await _locationService.getCurrentLocation();
    return _remoteDataSource.getWeather(location.latitude,
        location.longitude,
        lang: lang);
  }

  @override
  Future<WeatherEntity> getWeatherForLocation(double lat, double lon,
          {String lang = 'en'}) =>
      _remoteDataSource.getWeather(lat, lon, lang: lang);
}
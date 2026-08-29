import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/location_service.dart';
import 'package:skylo/data/datasources/open_weather_remote_data_source.dart';
import 'package:skylo/data/repositories/weather_repository_impl.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';

final openWeatherApiKeyProvider = Provider<String>(
  (ref) => const String.fromEnvironment('OPEN_WEATHER_MAP_API_KEY'),
);

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiKey = ref.watch(openWeatherApiKeyProvider);
  return WeatherRepositoryImpl(
    OpenWeatherRemoteDataSource(apiKey: apiKey),
    LocationService(),
  );
});

final weatherProvider = FutureProvider.autoDispose<WeatherEntity>((ref) async {
  return ref.watch(weatherRepositoryProvider).getCurrentLocationWeather();
});
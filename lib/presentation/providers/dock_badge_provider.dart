import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/dock_badge_service.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/units_providers.dart';

/// Keeps the macOS dock badge in sync with the CURRENT LOCATION's
/// temperature, honoring the active units. Clears on error/absence.
final dockBadgeProvider = Provider<void>((ref) {
  final places = ref.watch(savedPlacesProvider);
  final current =
      places.where((p) => p.isCurrentLocation).firstOrNull;
  if (current == null) return;

  final units = ref.watch(unitsProvider);
  final weatherAsync = ref.watch(placeWeatherProvider(current));

  weatherAsync.when(
    data: (WeatherEntity weather) {
      DockBadgeService.instance.setTemperature(
        weather.currentTemp,
        imperial: units == WeatherUnits.imperial,
      );
    },
    error: (_, _) => DockBadgeService.instance.clear(),
    loading: () {},
  );
  return;
});
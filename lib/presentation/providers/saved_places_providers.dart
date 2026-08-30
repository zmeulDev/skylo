import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/geocoding_data_source.dart';
import 'package:skylo/data/repositories/saved_places_repository.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_entity.dart';

import 'package:skylo/presentation/providers/locale_providers.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/providers/weather_providers.dart';

final geocodingDataSourceProvider = Provider<GeocodingDataSource>((ref) {
  return GeocodingDataSource(
      apiKey: ref.watch(openWeatherApiKeyProvider));
});

final savedPlacesRepositoryProvider = Provider<SavedPlacesRepository>((ref) {
  return SavedPlacesRepository(ref.watch(sharedPreferencesProvider));
});

class SavedPlacesNotifier extends StateNotifier<List<SavedPlace>> {
  final SavedPlacesRepository _repository;

  SavedPlacesNotifier(this._repository) : super([SavedPlace.current()]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.load();
  }

  Future<void> add(SavedPlace place) async {
    if (state.any((p) => p.id == place.id)) return;
    state = [...state, place];
    await _repository.save(state);
  }

  Future<void> remove(String id) async {
    if (id == 'current') return;
    state = state.where((p) => p.id != id).toList();
    await _repository.save(state);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex == 0) return; // current location stays first
    final list = [...state];
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (adjusted == 0) return;
    final place = list.removeAt(oldIndex);
    list.insert(adjusted, place);
    state = list;
    await _repository.save(list);
  }
}

final savedPlacesProvider =
    StateNotifierProvider<SavedPlacesNotifier, List<SavedPlace>>(
  (ref) => SavedPlacesNotifier(ref.watch(savedPlacesRepositoryProvider)),
);

/// The device's own locale, for when no app override is set.
final platformLocaleProvider = Provider<Locale>((ref) {
  return WidgetsBinding.instance.platformDispatcher.locale;
});

/// Weather for one saved place. The current-location place resolves
/// via geolocation; others by coordinates. The response language follows
/// the active app locale.
final placeWeatherProvider =
    FutureProvider.autoDispose.family<WeatherEntity, SavedPlace>(
        (ref, place) {
  final repository = ref.watch(weatherRepositoryProvider);
  final Locale? override = ref.watch(localeProvider);
  final Locale locale =
      override ?? ref.watch(platformLocaleProvider);
  final lang = locale.languageCode;
  if (place.isCurrentLocation) {
    return repository.getCurrentLocationWeather(lang: lang);
  }
  return repository.getWeatherForLocation(place.lat, place.lon, lang: lang);
});

/// City search for the add-place sheet.
final citySearchProvider =
    FutureProvider.autoDispose.family<List<GeocodingResult>, String>(
        (ref, query) {
  return ref.watch(geocodingDataSourceProvider).search(query);
});

/// Debug-friendly wrapper exposing search errors.
extension GeocodingResultListX on List<GeocodingResult> {
  void logResults() {
    for (final r in this) {
      debugPrint('[Skylo] ${r.label}');
    }
  }
}
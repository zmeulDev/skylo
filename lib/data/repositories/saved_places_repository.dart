import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/domain/entities/saved_place.dart';

class SavedPlacesRepository {
  static const _key = 'skylo.savedPlaces';

  final SharedPreferencesAsync _prefs;

  SavedPlacesRepository(this._prefs);

  Future<List<SavedPlace>> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [SavedPlace.current()];
    try {
      final list = jsonDecode(raw) as List;
      final places = list
          .map((e) => SavedPlace.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (places.isEmpty || !places.any((p) => p.isCurrentLocation)) {
        places.insert(0, SavedPlace.current());
      }
      return places;
    } catch (_) {
      return [SavedPlace.current()];
    }
  }

  Future<void> save(List<SavedPlace> places) async {
    final encoded =
        jsonEncode(places.where((p) => !p.isCurrentLocation).toList());
    await _prefs.setString(_key, encoded);
  }
}
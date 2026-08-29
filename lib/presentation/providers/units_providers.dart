import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/domain/entities/weather_entity.dart';

import 'theme_providers.dart';

const _kUnitsKey = 'skylo.units';

final unitsProvider =
    StateNotifierProvider<UnitsNotifier, WeatherUnits>(
  (ref) => UnitsNotifier(ref.watch(sharedPreferencesProvider))..load(),
);

class UnitsNotifier extends StateNotifier<WeatherUnits> {
  final SharedPreferencesAsync _prefs;

  UnitsNotifier(this._prefs) : super(WeatherUnits.metric);

  Future<void> load() async {
    final stored = await _prefs.getString(_kUnitsKey);
    if (stored == 'imperial') {
      state = WeatherUnits.imperial;
    }
  }

  Future<void> set(WeatherUnits units) async {
    state = units;
    await _prefs.setString(_kUnitsKey, units.name);
  }
}
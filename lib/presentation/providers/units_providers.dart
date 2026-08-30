import 'package:flutter/material.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/domain/entities/weather_entity.dart';

import 'theme_providers.dart';

const _kUnitsKey = 'skylo.units';

final unitsProvider =
    StateNotifierProvider<UnitsNotifier, WeatherUnits>(
  (ref) => UnitsNotifier(ref.watch(sharedPreferencesProvider))..load(),
);

/// Resolves [WeatherUnits.system] against the device locale (US-style
/// locales default to °F, everyone else °C). Explicit choices pass
/// through unchanged.
WeatherUnits resolveUnits(WeatherUnits units, Locale locale) {
  if (units != WeatherUnits.system) return units;
  return WeatherUnitsX.fromCountryCode(locale.countryCode);
}

class UnitsNotifier extends StateNotifier<WeatherUnits> {
  final SharedPreferencesAsync _prefs;

  UnitsNotifier(this._prefs) : super(WeatherUnits.system);

  Future<void> load() async {
    final stored = await _prefs.getString(_kUnitsKey);
    state = switch (stored) {
      'imperial' => WeatherUnits.imperial,
      'metric' => WeatherUnits.metric,
      _ => WeatherUnits.system,
    };
  }

  Future<void> set(WeatherUnits units) async {
    state = units;
    await _prefs.setString(_kUnitsKey, units.name);
  }

  Future<void> toggle(Locale locale) => set(switch (state) {
        WeatherUnits.system =>
          resolveUnits(state, locale) == WeatherUnits.metric
              ? WeatherUnits.imperial
              : WeatherUnits.metric,
        WeatherUnits.metric => WeatherUnits.imperial,
        WeatherUnits.imperial => WeatherUnits.metric,
      });
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_providers.dart';

const _kLocaleKey = 'skylo.locale';

/// null = follow the system language.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(ref.watch(sharedPreferencesProvider))..load(),
);

class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferencesAsync _prefs;

  LocaleNotifier(this._prefs) : super(null);

  Future<void> load() async {
    final stored = await _prefs.getString(_kLocaleKey);
    if (stored == 'en') {
      state = const Locale('en');
    } else if (stored == 'ro') {
      state = const Locale('ro');
    }
  }

  /// null clears the override (system language).
  Future<void> set(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(_kLocaleKey);
    } else {
      await _prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}
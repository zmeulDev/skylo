import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

const _kThemeModeKey = 'skylo.themeMode';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(sharedPreferencesProvider))..load(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferencesAsync _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.light);

  Future<void> load() async {
    final stored = await _prefs.getString(_kThemeModeKey);
    state = switch (stored) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> toggle() => set(switch (state) {
        ThemeMode.dark => ThemeMode.light,
        _ => ThemeMode.dark,
      });
}

extension SkyloThemeDataX on ThemeMode {
  ThemeData toThemeData() {
    final tokens = this == ThemeMode.dark ? SkyloTheme.dark : SkyloTheme.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: tokens.accent,
      surface: tokens.surface,
      brightness:
          this == ThemeMode.dark ? Brightness.dark : Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.surface,
      extensions: [tokens],
    );
  }
}
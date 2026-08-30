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

/// Built once and cached — rebuilding ThemeData on every widget rebuild
/// forces the whole tree to re-inherit the theme and janks animations.
final cachedLightTheme = _buildTheme(SkyloTheme.light, Brightness.light);
final cachedDarkTheme = _buildTheme(SkyloTheme.dark, Brightness.dark);

ThemeData _buildTheme(SkyloTheme tokens, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: tokens.accent,
    surface: tokens.surface,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.surface,
    extensions: [tokens],
  );
}
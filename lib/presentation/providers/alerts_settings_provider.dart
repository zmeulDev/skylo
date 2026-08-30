import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_providers.dart';

const _kAlertsEnabledKey = 'skylo.alertsEnabled';

/// Whether threshold alerts (storm, gusts, heat, UV...) are shown in
/// the app. An option the user turns on; default off.
final alertsEnabledProvider =
    StateNotifierProvider<AlertsEnabledNotifier, bool>(
  (ref) => AlertsEnabledNotifier(ref.watch(sharedPreferencesProvider))..load(),
);

class AlertsEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferencesAsync _prefs;

  AlertsEnabledNotifier(this._prefs) : super(false);

  Future<void> load() async {
    state = await _prefs.getBool(_kAlertsEnabledKey) ?? false;
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    await _prefs.setBool(_kAlertsEnabledKey, enabled);
  }

  Future<void> toggle() => set(!state);
}
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/data/background/background_alerts.dart';
import 'package:skylo/data/datasources/notification_service.dart';

import 'theme_providers.dart';

const _kAlertsEnabledKey = 'skylo.alertsEnabled';

/// Whether threshold alerts (storm, gusts, heat, UV...) are shown in
/// the app. An option the user turns on; default off.
///
/// Turning it ON also requests notification permission and schedules
/// the background check; denial keeps alerts in-app only.
final alertsEnabledProvider =
    StateNotifierProvider<AlertsEnabledNotifier, bool>(
  (ref) => AlertsEnabledNotifier(ref.watch(sharedPreferencesProvider))..load(),
);

class AlertsEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferencesAsync _prefs;

  AlertsEnabledNotifier(this._prefs) : super(false);

  Future<void> load() async {
    state = await _prefs.getBool(_kAlertsEnabledKey) ?? false;
    if (state) {
      _afterEnable();
    }
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    await _prefs.setBool(_kAlertsEnabledKey, enabled);
    if (enabled) _afterEnable();
  }

  Future<void> toggle() => set(!state);

  /// Enabled-path side effects: OS permission request (first enable
  /// per install; later calls are no-ops on Android, cheap on iOS)
  /// and the WorkManager schedule (idempotent by unique name).
  void _afterEnable() {
    NotificationService.instance.requestPermission().then((granted) {
      debugPrint('[Skylo] Notification permission granted: $granted');
    });
    scheduleBackgroundAlertCheck().catchError((e) {
      debugPrint('[Skylo] Background schedule failed: $e');
    });
  }
}
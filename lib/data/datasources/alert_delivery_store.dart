import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Remembers which alerts have already been delivered as notifications,
/// so the 15-minute refresh loop doesn't re-notify the same storm all
/// day. Dedup key: place + alert kind + place-local calendar day —
/// one notification per kind per place per day. Severity upgrades
/// (watch → severe) override: a storm strengthening past the severe
/// threshold re-earns a notification.
class AlertDeliveryStore {
  static const _key = 'skylo.alertDeliveries';

  final SharedPreferencesAsync _prefs;

  AlertDeliveryStore(this._prefs);

  /// Returns true when [alertKey] has not been delivered yet — and
  /// marks it delivered. [severe] upgrades are allowed through again.
  Future<bool> shouldDeliver(String alertKey, {required bool severe}) async {
    final entries = await _load();
    final existing = entries[alertKey];
    if (existing != null && existing >= (severe ? 2 : 1)) return false;
    entries[alertKey] = severe ? 2 : 1;
    await _save(entries);
    return true;
  }

  /// Drops delivered-markers whose local day has passed, so the store
  /// never grows without bound and a new day re-enables its alerts.
  Future<void> pruneExpired(Set<String> aliveKeys) async {
    final entries = await _load();
    final dead = entries.keys.where((k) => !aliveKeys.contains(k)).toList();
    if (dead.isEmpty) return;
    for (final k in dead) {
      entries.remove(k);
    }
    await _save(entries);
  }

  Future<Map<String, int>> _load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _save(Map<String, int> entries) async {
    await _prefs.setString(_key, jsonEncode(entries));
  }
}
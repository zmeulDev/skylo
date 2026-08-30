import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Shows the current temperature as a macOS dock badge (e.g. `29°`).
/// No-op on other platforms.
class DockBadgeService {
  static const _channel = MethodChannel('skylo/dockBadge');

  static final DockBadgeService instance = DockBadgeService._();

  DockBadgeService._();

  Future<void> setTemperature(double tempCelsius, {required bool imperial}) async {
    if (!_isMacOS) return;
    final value =
        imperial ? tempCelsius * 9 / 5 + 32 : tempCelsius;
    final label = '${value.round()}°';
    try {
      await _channel.invokeMethod('setBadge', {'label': label});
    } on PlatformException catch (e) {
      debugPrint('[Skylo] Dock badge failed: ${e.message}');
    } on MissingPluginException {
      // Not macOS or channel unavailable — ignore.
    }
  }

  Future<void> clear() async {
    if (!_isMacOS) return;
    try {
      await _channel.invokeMethod('clearBadge');
    } on PlatformException {
      // Ignore.
    } on MissingPluginException {
      // Ignore.
    }
  }

  bool get _isMacOS => defaultTargetPlatform == TargetPlatform.macOS;
}
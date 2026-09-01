import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skylo/domain/entities/weather_alert.dart';

/// Posts weather alerts as OS notifications. Two channels:
/// - SEVERE (storm, damaging gusts, extreme heat/cold): high priority,
///   sound + heads-up.
/// - WATCH (everything else): silent, default importance.
///
/// Follows the DockBadgeService pattern: singleton, swallows platform
/// errors so alert delivery never breaks the weather UI.
class NotificationService {
  static const _channelSevere = 'skylo_alerts_severe';
  static const _channelWatch = 'skylo_alerts_watch';

  static final NotificationService instance = NotificationService._();

  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// iOS/macOS only: set by main after runApp so taps route while the
  /// engine is headless. Kept as a static so the background isolate can
  /// not depend on it (taps are handled by the running app).
  static void Function(String placeId)? onNotificationTap;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onResponse,
    );
    _initialized = true;
  }

  void _onResponse(NotificationResponse response) {
    final placeId = response.payload;
    if (placeId == null) return;
    debugPrint('[Skylo] Notification tapped for place $placeId');
    final callback = onNotificationTap;
    if (callback != null) {
      callback(placeId);
    }
  }

  /// Requests notification permission (Android 13+ POST_NOTIFICATIONS,
  /// iOS UNUserNotificationCenter). Returns false on denial or non-mobile
  /// platforms — callers fall back to in-app alerts only.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    await initialize();
    try {
      if (Platform.isAndroid) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return granted ?? false;
      }
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    } catch (e) {
      debugPrint('[Skylo] Notification permission request failed: $e');
      return false;
    }
  }

  /// Shows one alert as a system notification. Returns false when the
  /// platform can't show it (permission denied, unsupported platform) —
  /// the alert still renders in the in-app banner.
  Future<bool> showAlert({
    required WeatherAlert alert,
    required String title,
    required String body,
    required String placeId,
    int id = 0,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return false;
    await initialize();
    try {
      final severe = alert.earnsAccent;
      final android = AndroidNotificationDetails(
        severe ? _channelSevere : _channelWatch,
        severe ? 'Severe weather' : 'Weather watches',
        channelDescription: severe
            ? 'Severe weather warnings (storm, damaging gusts, extreme temperatures)'
            : 'Weather watches (rain, fog, heat, UV, air quality)',
        importance:
            severe ? Importance.max : Importance.defaultImportance,
        priority: severe ? Priority.max : Priority.defaultPriority,
        playSound: severe,
        enableVibration: severe,
        color: const Color(0xFFE4002B),
        category: severe
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.recommendation,
        visibility: NotificationVisibility.public,
        styleInformation: const DefaultStyleInformation(false, false),
      );
      const darwin = DarwinNotificationDetails();
      final details = NotificationDetails(
        android: android,
        iOS: darwin,
        macOS: darwin,
      );
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: placeId,
      );
      return true;
    } catch (e) {
      debugPrint('[Skylo] Failed to show notification: $e');
      return false;
    }
  }

  /// Removes one delivered notification (e.g. its alert expired while
  /// the app was in the foreground).
  Future<void> cancel(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }

  /// Clears all delivered alert notifications.
  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
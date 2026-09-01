import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/data/datasources/alert_delivery_store.dart';
import 'package:skylo/data/datasources/location_service.dart';
import 'package:skylo/data/datasources/notification_service.dart';
import 'package:skylo/data/datasources/open_weather_remote_data_source.dart';
import 'package:skylo/data/datasources/uv_air_data_source.dart';
import 'package:skylo/data/repositories/saved_places_repository.dart';
import 'package:skylo/data/repositories/weather_repository_impl.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/services/alert_delivery.dart';
import 'package:workmanager/workmanager.dart';

/// Weather alert check that runs while the app is closed:
/// - Android: WorkManager periodic task (every ~6h, network required).
/// - iOS: BGAppRefreshTask — iOS decides when; expect a few runs per
///   day at best. Foreground resume checks remain the reliable path.
const _checkTask = 'skylo.alertCheck';
const _checkTaskUnique = 'skylo.alertCheck.unique';

/// Debug-only one-off run of the same pipeline, to prove the
/// background path (cold isolate, no Riverpod, no running app)
/// without waiting for the 6-hour WorkManager slot.
const _debugOneOffTask = 'skylo.alertCheck.debug';

/// Reads the alert switch the settings sheet persists, so the
/// background check respects the user's opt-in without Riverpod.
const _kAlertsEnabledKey = 'skylo.alertsEnabled';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case _checkTask:
      case _debugOneOffTask:
      case Workmanager.iOSBackgroundTask:
        final ok = await _runAlertCheck();
        if (taskName == _debugOneOffTask) {
          // Visible proof the cold isolate ran the whole pipeline.
          await _debugMarker(ok);
        }
        return ok;
      default:
        return true;
    }
  });
}

/// One alert-check round: every saved place, weather fetched fresh,
/// alerts evaluated, new ones notified. Returns true even on partial
/// failures so WorkManager doesn't back off — the next round retries.
Future<bool> _runAlertCheck() async {
  try {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final prefs = SharedPreferencesAsync();
    final enabled = await prefs.getBool(_kAlertsEnabledKey) ?? false;
    if (!enabled) return true;

    final apiKey = const String.fromEnvironment('OPEN_WEATHER_MAP_API_KEY');
    if (apiKey.isEmpty) return true;

    final locale = await _locale(prefs);
    final places = await SavedPlacesRepository(prefs).load();

    final repository = WeatherRepositoryImpl(
      OpenWeatherRemoteDataSource(apiKey: apiKey),
      LocationService(),
    );
    final delivery = AlertDelivery(
      repository: repository,
      store: AlertDeliveryStore(prefs),
      notifications: NotificationService.instance,
      enrichment: _UvAir(UvAirDataSource(apiKey: apiKey)),
    );

    // The current-location place needs a GPS fix; in the background
    // that may hang on a cold start, so it gets its own timeout
    // rather than starving the saved cities that follow.
    for (final place in places) {
      if (place.isCurrentLocation) {
        final done = delivery.deliverForPlace(place, locale)
            .timeout(const Duration(seconds: 60), onTimeout: () {});
        await done;
      } else {
        await delivery.deliverForPlace(place, locale);
      }
    }
    return true;
  } catch (e) {
    debugPrint('[Skylo] Background alert check failed: $e');
    return true;
  }
}

Future<Locale> _locale(SharedPreferencesAsync prefs) async {
  final code = await prefs.getString('skylo.locale');
  if (code != null && code.isNotEmpty) return Locale(code);
  final device = PlatformDispatcher.instance.locale;
  return device;
}

/// Posts a marker notification after a debug one-off run, so the
/// result is visible on the phone with the app closed.
Future<void> _debugMarker(bool ok) async {
  await NotificationService.instance.showAlert(
    alert: WeatherAlert(
      kind: WeatherAlertKind.thunderstorm,
      headline: 'DEBUG',
      detail: ok ? 'background check ran' : 'background check FAILED',
      severe: true,
    ),
    title: ok
        ? 'DEBUG: background check completed'
        : 'DEBUG: background check FAILED',
    body: 'Cold-isolate pipeline ran with the app closed '
        '(weather fetch → evaluate → notify).',
    placeId: 'current',
    id: 900010,
  );
}

/// Schedules the debug one-off background check (15s out). Only call
/// when SKYLO_DEBUG_NOTIFICATIONS is compiled in.
Future<void> scheduleDebugOneOffCheck() async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Workmanager().registerOneOffTask(
      _debugOneOffTask,
      _debugOneOffTask,
      initialDelay: const Duration(seconds: 15),
    );
  }
}

/// Adapts [UvAirDataSource] to the delivery seam.
class _UvAir implements UvAirEnrichment {
  final UvAirDataSource _source;

  _UvAir(this._source);

  @override
  Future<double?> uvIndex(double lat, double lon) =>
      _source.uvIndex(lat, lon);

  @override
  Future<int?> airQualityIndex(double lat, double lon) =>
      _source.airQualityIndex(lat, lon);
}

/// Schedules the background check. Called from the app when alerts
/// are enabled (and again on every launch — WorkManager dedups by
/// unique name, keeps the existing schedule).
Future<void> scheduleBackgroundAlertCheck() async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
  await Workmanager().initialize(callbackDispatcher);
  if (Platform.isAndroid) {
    await Workmanager().registerPeriodicTask(
      _checkTaskUnique,
      _checkTask,
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  } else {
    // iOS: BGAppRefreshTask — the system picks the cadence.
    await Workmanager().registerPeriodicTask(
      _checkTaskUnique,
      _checkTask,
      initialDelay: const Duration(minutes: 30),
    );
  }
}
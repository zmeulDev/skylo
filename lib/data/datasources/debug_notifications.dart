import 'package:flutter/foundation.dart';
import 'package:skylo/data/background/background_alerts.dart';
import 'package:skylo/data/datasources/notification_service.dart';
import 'package:skylo/domain/entities/weather_alert.dart';

/// Debug helpers for testing notifications on a real device without
/// waiting for weather. Enabled only when the app is built with
/// --dart-define=SKYLO_DEBUG_NOTIFICATIONS=true (see run.sh).
const kSkyloDebugNotifications =
    bool.fromEnvironment('SKYLO_DEBUG_NOTIFICATIONS');

/// Posts a fake severe + a fake watch notification immediately, then
/// one delayed, and schedules a one-off background run of the real
/// alert pipeline 15s later — background the app to see its marker.
Future<void> postDebugNotifications() async {
  if (!kSkyloDebugNotifications) return;
  debugPrint('[Skylo] Posting debug notifications');
  await scheduleDebugOneOffCheck();

  await NotificationService.instance.showAlert(
    alert: WeatherAlert(
      kind: WeatherAlertKind.thunderstorm,
      headline: 'DEBUG STORM',
      detail: 'tomorrow at 15:00 — debug severe channel test',
      severe: true,
    ),
    title: 'DEBUG: THUNDERSTORM EXPECTED · Severe channel',
    body: 'Tomorrow at 15:00 — heads-up banner, sound, red accent.',
    placeId: 'current',
    id: 900001,
  );

  await NotificationService.instance.showAlert(
    alert: WeatherAlert(
      kind: WeatherAlertKind.heat,
      headline: 'DEBUG HEAT',
      detail: 'tomorrow — up to 34° — debug watch channel test',
      severe: false,
    ),
    title: 'DEBUG: HEAT WATCH · Watch channel',
    body: 'Tomorrow — up to 34°. Silent, no heads-up.',
    placeId: 'current',
    id: 900002,
  );

  await Future<void>.delayed(const Duration(seconds: 20));
  await NotificationService.instance.showAlert(
    alert: WeatherAlert(
      kind: WeatherAlertKind.windGust,
      headline: 'DEBUG GUST (DELAYED)',
      detail: 'in 3 hours — gusts up to 72 km/h — posted while app runs',
      severe: true,
    ),
    title: 'DEBUG: STRONG GUSTS EXPECTED · Delayed',
    body: 'At 18:00 — gusts up to 72 km/h. Try backgrounding the app.',
    placeId: 'current',
    id: 900003,
  );
  debugPrint('[Skylo] Debug notifications posted');
}
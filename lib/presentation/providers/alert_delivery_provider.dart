import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/alert_delivery_store.dart';
import 'package:skylo/data/datasources/notification_service.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/services/alert_delivery.dart';
import 'package:skylo/presentation/providers/alerts_providers.dart';
import 'package:skylo/presentation/providers/alerts_settings_provider.dart';
import 'package:skylo/presentation/providers/locale_providers.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/theme_providers.dart'
    show sharedPreferencesProvider;
import 'package:skylo/presentation/providers/weather_providers.dart';

/// Dedup store for notification delivery, persisted across runs and
/// shared with the background task (same SharedPreferences key).
final alertDeliveryStoreProvider = Provider<AlertDeliveryStore>(
  (ref) => AlertDeliveryStore(ref.watch(sharedPreferencesProvider)),
);

/// Notification delivery engine, same shape the background task uses.
final alertDeliveryProvider = Provider<AlertDelivery>(
  (ref) => AlertDelivery(
    repository: ref.watch(weatherRepositoryProvider),
    store: ref.watch(alertDeliveryStoreProvider),
    notifications: NotificationService.instance,
  ),
);

/// Delivers notifications for alerts the app's places have already
/// evaluated. Reuses `placeAlertsProvider` — no extra fetches:
/// whenever a place's alerts change (weather refreshed), new alerts
/// pass the dedup store and go out as notifications. Off (and
/// subscriptions torn down) the moment the user disables alerts.
final alertDeliveryCoordinatorProvider = Provider<void>((ref) {
  if (!ref.watch(alertsEnabledProvider)) return;
  final places = ref.watch(savedPlacesProvider);
  final delivery = ref.watch(alertDeliveryProvider);

  final subs =
      <ProviderSubscription<List<WeatherAlert>?>>[];
  for (final place in places) {
    subs.add(ref.listen(
      placeAlertsProvider(place).select((async) => async.valueOrNull),
      (previous, next) {
        final alerts = next;
        if (alerts == null || alerts.isEmpty) return;
        _deliver(delivery, place, alerts, ref);
      },
    ));
  }
  ref.onDispose(() {
    for (final s in subs) {
      s.close();
    }
  });
  return;
});

Future<void> _deliver(
  AlertDelivery delivery,
  SavedPlace place,
  List<WeatherAlert> alerts,
  Ref ref,
) async {
  final Locale? override = ref.read(localeProvider);
  final locale = override ?? ref.read(platformLocaleProvider);
  // The fetched snapshot's local clock scopes the dedup key so the
  // "day" belongs to the place, not the viewer. Weather fetch errors
  // just skip this delivery round.
  final weather = await ref
      .read(placeWeatherProvider(place).future)
      .then<WeatherEntity?>((w) => w)
      .catchError((_) => null);
  if (weather == null) return;
  await delivery.deliverAlerts(alerts, place, weather, locale!);
}
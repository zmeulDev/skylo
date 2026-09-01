import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:skylo/data/datasources/alert_delivery_store.dart';
import 'package:skylo/data/datasources/notification_service.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/repositories/weather_repository.dart';
import 'package:skylo/domain/services/alert_texts.dart';
import 'package:skylo/domain/services/alert_evaluator.dart';

/// Turns weather into delivered notifications, one saved place at a
/// time. Shared by the foreground coordinator (app alive) and the
/// workmanager background task (app closed, Android) so dedup rules
/// apply identically wherever the check runs.
class AlertDelivery {
  AlertDelivery({
    required this.repository,
    required this.store,
    required this.notifications,
    this.enrichment,
  });

  final WeatherRepository repository;
  final AlertDeliveryStore store;
  final NotificationService notifications;
  final UvAirEnrichment? enrichment;

  /// Delivers already-evaluated [alerts] for [place], deduped against
  /// the store (one notification per place + kind + local day, severe
  /// upgrades re-deliver). Used by the foreground coordinator, which
  /// reuses the alerts each place page already evaluated.
  Future<void> deliverAlerts(
    List<WeatherAlert> alerts,
    SavedPlace place,
    WeatherEntity weather,
    Locale locale,
  ) async {
    try {
      await _deliver(alerts, place, weather, locale);
    } catch (e) {
      debugPrint('[Skylo] Alert delivery failed for ${place.id}: $e');
    }
  }

  /// Fetches weather for [place], evaluates alerts, and posts the ones
  /// not yet delivered today. Never throws — a background caller must
  /// return success so WorkManager doesn't back off exponentially.
  Future<void> deliverForPlace(SavedPlace place, Locale locale) async {
    try {
      final weather = await _fetchWeather(place, locale);
      if (weather == null) return;
      final alerts = await _evaluate(weather, locale);
      await _deliver(alerts, place, weather, locale);
    } catch (e) {
      debugPrint('[Skylo] Alert delivery failed for ${place.id}: $e');
    }
  }

  Future<WeatherEntity?> _fetchWeather(SavedPlace place, Locale locale) {
    final lang = locale.languageCode;
    if (place.isCurrentLocation) {
      // Background: the location service handles the last-known-fix
      // shortcut; a cold GPS fix is slow but still bounded.
      return repository.getCurrentLocationWeather(lang: lang);
    }
    return repository.getWeatherForLocation(place.lat, place.lon, lang: lang);
  }

  Future<List<WeatherAlert>> _evaluate(
    WeatherEntity weather,
    Locale locale,
  ) async {
    double? uv;
    int? aqi;
    final source = enrichment;
    if (source != null && weather.lat != null && weather.lon != null) {
      uv = await source.uvIndex(weather.lat!, weather.lon!);
      aqi = await source.airQualityIndex(weather.lat!, weather.lon!);
    }
    return AlertEvaluator.evaluate(
      weather,
      LocalizedAlertTexts(weather, locale),
      uvIndex: uv,
      aqi: aqi,
    );
  }

  Future<void> _deliver(
    List<WeatherAlert> alerts,
    SavedPlace place,
    WeatherEntity weather,
    Locale locale,
  ) async {
    if (alerts.isEmpty) return;
    // Place-local calendar day scopes the dedup keys.
    final localNow = weather.localNow();
    final aliveKeys = <String>{};
    for (final alert in alerts) {
      final key = _deliveryKey(place, alert, localNow);
      aliveKeys.add(key);
      final shouldDeliver =
          await store.shouldDeliver(key, severe: alert.severe);
      if (!shouldDeliver) continue;
      await postNotification(
        alert: alert,
        title: _title(alert, place, locale),
        body: alert.detail,
        placeId: place.id,
        id: _notificationId(place, alert),
      );
    }
    await store.pruneExpired(aliveKeys);
  }

  /// The actual OS notification post. Subclasses (tests) can intercept
  /// here; the production path is [NotificationService.showAlert].
  Future<bool> postNotification({
    required WeatherAlert alert,
    required String title,
    required String body,
    required String placeId,
    int id = 0,
  }) {
    return notifications.showAlert(
      alert: alert,
      title: title,
      body: body,
      placeId: placeId,
      id: id,
    );
  }

  /// Stable per place+kind id: re-notify of the same kind replaces the
  /// previous notification instead of stacking a second one.
  int _notificationId(SavedPlace place, WeatherAlert alert) {
    return place.id.hashCode ^ alert.kind.index;
  }

  String _deliveryKey(
    SavedPlace place,
    WeatherAlert alert,
    DateTime localNow,
  ) {
    final day = '${localNow.year}-${localNow.month}-${localNow.day}';
    return '${place.id}:${alert.kind.name}:$day';
  }

  String _title(WeatherAlert alert, SavedPlace place, Locale locale) {
    final headline = localizedAlertHeadline(alert.kind, locale);
    if (place.isCurrentLocation) return headline;
    return '$headline · ${place.label}';
  }
}

/// UV/AQI enrichment seam, so callers can inject the same best-effort
/// data source the UI uses (or none, in tests).
abstract class UvAirEnrichment {
  Future<double?> uvIndex(double lat, double lon);
  Future<int?> airQualityIndex(double lat, double lon);
}
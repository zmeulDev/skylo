import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/presentation/providers/locale_providers.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/weather_providers.dart';

/// How long a weather snapshot stays fresh. OWM free tier updates its
/// current-conditions roughly every 10 minutes; 15 keeps us within one
/// API update without hammering the network.
const _weatherTtl = Duration(minutes: 15);

/// Re-check cadence while the app is in the foreground, so a phone
/// sitting on the table still sees the temperature drift.
const _heartbeat = Duration(minutes: 15);

/// Watches app lifecycle and the clock: refetches weather when the
/// existing snapshot has gone stale. On resume (and shortly after
/// startup) it also runs the movement check for the current-location
/// place, which invalidates that place's weather if the device moved
/// since the last fix — stale-while-revalidate.
final locationRevalidationProvider = Provider<void>((ref) {
  final observer = _ResumeObserver(ref);
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
    observer.dispose();
  });

  // Post-launch check — lets the cached-weather paint first, then
  // corrects it if the device moved or the data went stale while the
  // app was closed.
  final startupTimer = Timer(const Duration(seconds: 3), () {
    observer.checkAndRevalidate();
  });
  ref.onDispose(startupTimer.cancel);

  // Cold start never fires a lifecycle transition: the app is already
  // in the resumed state, so start the foreground heartbeat now.
  observer.startHeartbeat();
  return;
});

class _ResumeObserver with WidgetsBindingObserver {
  final Ref _ref;
  Timer? _heartbeatTimer;

  _ResumeObserver(this._ref);

  void dispose() {
    _heartbeatTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startHeartbeat();
      checkAndRevalidate();
    } else {
      _heartbeatTimer?.cancel();
      _heartbeatTimer = null;
    }
  }

  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeat, (_) {
      _refreshStalePlaces();
    });
  }

  Future<void> checkAndRevalidate() async {
    // Movement check only makes sense for the current-location place.
    await _revalidateCurrentLocation();
    _refreshStalePlaces();
  }

  Future<void> _revalidateCurrentLocation() async {
    final places = _ref.read(savedPlacesProvider);
    final current = places.where((p) => p.isCurrentLocation).firstOrNull;
    if (current == null) return;

    final repository = _ref.read(weatherRepositoryProvider);
    final Locale? override = _ref.read(localeProvider);
    final Locale effective = override ?? _ref.read(platformLocaleProvider);
    final lang = effective.languageCode;

    // Stale-while-revalidate: silently check for movement; only
    // invalidate (and thus refetch) when the device actually moved.
    final moved = await repository.revalidateCurrentLocation(lang: lang);
    if (moved != null) {
      _ref.invalidate(placeWeatherProvider(current));
    }
  }

  /// Invalidates every place whose weather snapshot is older than the
  /// TTL. Providers whose data is fresh stay untouched, so this is
  /// cheap to call on every resume and every heartbeat tick.
  void _refreshStalePlaces() {
    final places = _ref.read(savedPlacesProvider);
    for (final place in places) {
      // Never spin up a provider that isn't alive — that would trigger
      // a network fetch the UI never asked for.
      if (!_ref.exists(placeWeatherProvider(place))) continue;
      final state = _ref.read(placeWeatherProvider(place));
      final weather = state.valueOrNull;
      if (weather != null && weather.olderThan(_weatherTtl)) {
        _ref.invalidate(placeWeatherProvider(place));
      }
    }
  }
}
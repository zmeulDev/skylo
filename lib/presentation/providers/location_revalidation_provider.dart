import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/presentation/providers/locale_providers.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/weather_providers.dart';

/// Watches app lifecycle: when the app returns to the foreground, runs the
/// stale-while-revalidate check. If the device has moved since the last
/// current-location fetch, invalidates that place's weather so the UI
/// refetches with fresh coords.
///
/// Also runs the check once shortly after startup: cold starts have no
/// lifecycle transition, and the OS's cached position may be hours old.
final locationRevalidationProvider = Provider<void>((ref) {
  final observer = _ResumeObserver(ref);
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));

  // Post-launch check — lets the cached-weather paint first, then
  // corrects it if the device has moved since the cache was written.
  // Cancelable so tests (and disposal) never leave a pending timer.
  final startupTimer = Timer(const Duration(seconds: 3), () {
    observer.checkAndRevalidate();
  });
  ref.onDispose(startupTimer.cancel);
  return;
});

class _ResumeObserver with WidgetsBindingObserver {
  final Ref _ref;

  _ResumeObserver(this._ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    checkAndRevalidate();
  }

  Future<void> checkAndRevalidate() async {
    final places = _ref.read(savedPlacesProvider);
    final current =
        places.where((p) => p.isCurrentLocation).firstOrNull;
    if (current == null) return;

    final repository = _ref.read(weatherRepositoryProvider);
    final Locale? override = _ref.read(localeProvider);
    final Locale effective =
        override ?? _ref.read(platformLocaleProvider);
    final lang = effective.languageCode;

    // Stale-while-revalidate: silently check for movement; only
    // invalidate (and thus refetch) when the device actually moved.
    final moved = await repository.revalidateCurrentLocation(lang: lang);
    if (moved != null) {
      _ref.invalidate(placeWeatherProvider(current));
    }
  }
}
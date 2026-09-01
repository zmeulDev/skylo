import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/widget_snapshot_store.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_entity.dart'
    show WeatherEntity, WeatherUnits, WeatherUnitsX;
import 'package:skylo/l10n/app_localizations.dart';
import 'package:skylo/presentation/providers/locale_providers.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/units_providers.dart';

/// The place whose page is currently on screen (last-viewed). The
/// home-screen widget mirrors this page. Updated by HomeScreen on
/// page changes; defaults to the first place.
final currentViewedPlaceProvider = StateProvider<SavedPlace?>((ref) => null);

/// The first saved place — the widget's default subject before the
/// user has swiped anywhere.
final _firstPlaceProvider = Provider<SavedPlace?>((ref) {
  final places = ref.watch(savedPlacesProvider);
  return places.isEmpty ? null : places.first;
});

/// Keeps the home-screen widgets in sync with the last-viewed place:
/// republishes the snapshot whenever its weather refreshes, or when
/// units/locale change (display strings are pre-rendered in Dart).
///
/// Mirrors the dock-badge pattern: rides existing providers, adds no
/// network fetches of its own.
final widgetSnapshotCoordinatorProvider = Provider<void>((ref) {
  final store = WidgetSnapshotStore.instance;
  store.initialize();

  final place = ref.watch(currentViewedPlaceProvider) ??
      ref.watch(_firstPlaceProvider);
  if (place == null) return;

  final locale = _effectiveLocale(ref);
  final units = resolveUnits(ref.watch(unitsProvider), locale);
  final weatherAsync = ref.watch(placeWeatherProvider(place));

  weatherAsync.when(
    data: (weather) => _publish(store, place, weather, units, locale),
    error: (_, _) => store.clear(),
    loading: () {},
  );
  return;
});

Locale _effectiveLocale(Ref ref) {
  final override = ref.watch(localeProvider);
  return override ?? ref.watch(platformLocaleProvider);
}

Future<void> _publish(
  WidgetSnapshotStore store,
  SavedPlace place,
  WeatherEntity weather,
  WeatherUnits units,
  Locale locale,
) async {
  // Localized Today/Tomorrow from the app's own l10n bundle — the
  // widget never localizes on its own.
  final l10n = lookupAppLocalizations(locale);
  await store.publish(
    place: place,
    weather: weather,
    localeTag: locale.toString(),
    todayLabel: l10n.today,
    tomorrowLabel: l10n.tomorrow,
    convert: units.convertTemp,
    tempLabel: units.degreeLabel,
  );
}
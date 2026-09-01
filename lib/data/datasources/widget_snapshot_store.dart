import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/data/models/widget_snapshot.dart';

/// The iOS App Group that shares the widget snapshot between the app
/// and the WidgetKit extension. Android needs no equivalent — the
/// plugin's SharedPreferences live in the app's own process, which is
/// exactly where the AppWidget code runs.
const _iOSAppGroupId = 'group.com.zmeul.skylo';

/// The WidgetKit "kind" the iOS extension registers. Must match the
/// `@main` widget in SkyloWidget.swift and the name Dart passes to
/// `HomeWidget.updateWidget`.
const _iOSWidgetKind = 'SkyloWidget';

/// Prefix every snapshot key shares, so a future widget can clear the
/// whole namespace without enumerating keys by hand.
const _prefix = 'skylo.widget.';

/// Renders the last-viewed place's weather into the home-screen
/// widgets (Android AppWidget + iOS WidgetKit) through the
/// home_widget plugin's shared store.
///
/// Everything is pre-rendered on the Dart side into display strings —
/// localized, unit-converted, rounded (see [renderWidgetSnapshot]) —
/// so the native widgets stay dumb view layers with zero business
/// logic. Numerals land as pre-formatted strings; the bundled Inter
/// (Android) and SF (iOS) render them tabular-stable.
class WidgetSnapshotStore {
  static final WidgetSnapshotStore instance = WidgetSnapshotStore._();

  WidgetSnapshotStore._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) return;
    if (!(defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS)) {
      return;
    }
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(_iOSAppGroupId);
      }
      _initialized = true;
    } catch (e) {
      debugPrint('[Skylo] Widget init failed: $e');
    }
  }

  /// Writes the [place]'s [weather] snapshot and pokes both platforms'
  /// widget renderers. Display strings localize via [todayLabel],
  /// [tomorrowLabel] and the intl [localeTag] weekday names; [convert]
  /// is the Celsius → display conversion and [tempLabel] its unit
  /// suffix. Call on every weather refresh of the last-viewed place,
  /// and after units/locale changes.
  Future<void> publish({
    required SavedPlace place,
    required WeatherEntity weather,
    required String localeTag,
    required String todayLabel,
    required String tomorrowLabel,
    required double Function(double celsius) convert,
    required String tempLabel,
  }) async {
    final snapshot = renderWidgetSnapshot(
      place: place,
      weather: weather,
      localeTag: localeTag,
      todayLabel: todayLabel,
      tomorrowLabel: tomorrowLabel,
      convert: convert,
      tempLabel: tempLabel,
    );
    await write(snapshot);
  }

  @visibleForTesting
  Future<void> write(WidgetSnapshot snapshot) async {
    if (!_initialized) return;
    try {
      await Future.wait([
        for (final entry in snapshot.values.entries)
          HomeWidget.saveWidgetData('$_prefix${entry.key}', entry.value),
      ]);
      await HomeWidget.updateWidget(
        androidName: 'SkyloWidgetProvider',
        iOSName: _iOSWidgetKind,
      );
    } catch (e) {
      debugPrint('[Skylo] Widget publish failed: $e');
    }
  }

  /// Clears the whole snapshot namespace (all widgets fall back to
  /// their "open the app" placeholder).
  Future<void> clear() async {
    if (!_initialized) return;
    try {
      await Future.wait([
        for (final key in WidgetSnapshot.allKeys)
          HomeWidget.saveWidgetData('$_prefix$key', null),
      ]);
      await HomeWidget.updateWidget(
        androidName: 'SkyloWidgetProvider',
        iOSName: _iOSWidgetKind,
      );
    } catch (e) {
      debugPrint('[Skylo] Widget clear failed: $e');
    }
  }
}
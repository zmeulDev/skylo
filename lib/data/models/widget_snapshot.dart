import 'package:intl/intl.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_entity.dart';

/// The display-ready snapshot the home-screen widgets render. Values
/// are final strings — localized, unit-converted, rounded — keyed by
/// the names both native widgets read (Android: SkyloWidgetProvider;
/// iOS: SkyloWidget.swift).
class WidgetSnapshot {
  final Map<String, String?> values;

  const WidgetSnapshot(this.values);

  /// Every key the native layouts bind, in write/clear order.
  static const allKeys = [
    'placeName',
    'temp',
    'tempUnit',
    'feelsLike',
    'condition',
    'weatherCode',
    'h0_time',
    'h0_temp',
    'h0_code',
    'h1_time',
    'h1_temp',
    'h1_code',
    'h2_time',
    'h2_temp',
    'h2_code',
    'h3_time',
    'h3_temp',
    'h3_code',
    'd0_label',
    'd0_min',
    'd0_max',
    'd0_code',
    'd1_label',
    'd1_min',
    'd1_max',
    'd1_code',
    'd2_label',
    'd2_min',
    'd2_max',
    'd2_code',
    'd3_label',
    'd3_min',
    'd3_max',
    'd3_code',
    'd4_label',
    'd4_min',
    'd4_max',
    'd4_code',
  ];
}

/// Renders a weather snapshot into display strings for the native
/// home-screen widgets. Pure — no platform calls — so it is fully
/// unit-testable and the store stays a thin I/O wrapper.
///
/// Local clock rule (same as the app): the hourly row and the
/// Today/Tomorrow labels follow the *place's* wall clock, not the
/// viewer's. [nowUtc] defaults to the real clock; tests inject one.
WidgetSnapshot renderWidgetSnapshot({
  required SavedPlace place,
  required WeatherEntity weather,
  required String localeTag,
  required String todayLabel,
  required String tomorrowLabel,
  required double Function(double celsius) convert,
  required String tempLabel,
  DateTime? nowUtc,
}) {
  final values = <String, String?>{
    'placeName': place.label,
    'temp': convert(weather.currentTemp).round().toString(),
    'tempUnit': tempLabel,
    'feelsLike': convert(weather.feelsLikeTemp).round().toString(),
    'condition': weather.conditionDescription.isEmpty
        ? weather.condition
        : weather.conditionDescription,
    'weatherCode': weather.weatherCode.toString(),
  };

  // Hourly row: next 4 slots (3-hour steps on free-tier OWM) from
  // the place's local clock.
  final localNow = _localNow(weather, nowUtc);
  final cutoff =
      DateTime(localNow.year, localNow.month, localNow.day, localNow.hour);
  final upcoming =
      weather.hourly.where((h) => !h.time.isBefore(cutoff)).take(4).toList();
  for (var i = 0; i < 4; i++) {
    final has = i < upcoming.length;
    values['h${i}_time'] =
        has ? upcoming[i].time.hour.toString().padLeft(2, '0') : null;
    values['h${i}_temp'] =
        has ? convert(upcoming[i].temp).round().toString() : null;
    values['h${i}_code'] = has ? upcoming[i].weatherCode.toString() : null;
  }

  // 5-day outlook: Today/Tomorrow for the first two, localized
  // weekday names after (intl CLDR data, same source as the app UI).
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final locale = localeTag.split('-').first;
  final weekdayFormat = DateFormat.E(locale);
  for (var i = 0; i < 5; i++) {
    final has = i < weather.daily.length;
    if (!has) {
      values['d${i}_label'] = null;
      values['d${i}_min'] = null;
      values['d${i}_max'] = null;
      values['d${i}_code'] = null;
      continue;
    }
    final day = weather.daily[i];
    final dayStart = DateTime(day.date.year, day.date.month, day.date.day);
    final diff = dayStart.difference(today).inDays;
    final label = diff == 0
        ? todayLabel
        : diff == 1
            ? tomorrowLabel
            : _capitalize(weekdayFormat.format(dayStart));
    values['d${i}_label'] = label;
    values['d${i}_min'] = convert(day.minTemp).round().toString();
    values['d${i}_max'] = convert(day.maxTemp).round().toString();
    values['d${i}_code'] = day.weatherCode.toString();
  }

  return WidgetSnapshot(values);
}

/// The place-local wall clock. Mirrors WeatherEntity.localNow(): a
/// plain shifted value whose calendar fields read the place's day.
DateTime _localNow(WeatherEntity weather, DateTime? nowUtc) {
  final shifted = (nowUtc ?? DateTime.now()).toUtc().add(
      Duration(seconds: weather.timeZoneOffsetSeconds));
  return DateTime(
      shifted.year, shifted.month, shifted.day, shifted.hour, shifted.minute);
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
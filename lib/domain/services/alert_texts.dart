import 'dart:ui';

import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/domain/services/alert_evaluator.dart';
import 'package:skylo/l10n/app_localizations.dart';

/// Localized [AlertTexts] for a place's weather snapshot. Shared by
/// the in-app banner provider and the notification delivery path so
/// both speak with one voice. The delegate lookup is synchronous for
/// all supported locales.
class LocalizedAlertTexts implements AlertTexts {
  LocalizedAlertTexts(this.weather, this.locale);

  final WeatherEntity weather;
  final Locale locale;

  AppLocalizations get _l10n => lookupAppLocalizations(locale);

  String get _tomorrowLabel => _l10n.tomorrow.toLowerCase();

  String get _todayLabel => _l10n.today.toLowerCase();

  /// Whether [time] falls on a later calendar day than the place's
  /// local "today" — drives the "tomorrow" qualifier.
  bool _isTomorrow(DateTime time) {
    final now = weather.localNow();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return !time.isBefore(tomorrow);
  }

  @override
  String headline(WeatherAlertKind kind) => switch (kind) {
        WeatherAlertKind.thunderstorm => _l10n.alertThunderstorm,
        WeatherAlertKind.snow => _l10n.alertSnow,
        WeatherAlertKind.rain => _l10n.alertRain,
        WeatherAlertKind.windGust => _l10n.alertWindGust,
        WeatherAlertKind.heat => _l10n.alertHeat,
        WeatherAlertKind.cold => _l10n.alertCold,
        WeatherAlertKind.fog => _l10n.alertFog,
        WeatherAlertKind.uv => _l10n.alertUv,
        WeatherAlertKind.airQuality => _l10n.alertAirQuality,
      };

  @override
  String whenPhrase(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    if (_isTomorrow(time)) return '$_tomorrowLabel $hh:$mm';
    return '$hh:$mm';
  }

  @override
  String dayPhrase(DateTime time) =>
      _isTomorrow(time) ? _tomorrowLabel : _todayLabel;

  @override
  String tempPhrase(double celsius) => '${celsius.round()}°';

  @override
  String gustPhrase(double ms) => '${(ms * 3.6).round()} km/h';

  @override
  String uvPhrase(double uv) => 'UV ${uv.round()}';

  @override
  String aqiPhrase(int aqi) => 'AQI $aqi/5';
}

/// Headline for an alert kind in [locale], for callers that only need
/// the title (notification title lines). The headline itself does not
/// depend on the weather snapshot, so a constant empty one is supplied.
String localizedAlertHeadline(WeatherAlertKind kind, Locale locale) {
  return LocalizedAlertTexts(const WeatherEntity(
    currentTemp: 0,
    feelsLikeTemp: 0,
    condition: '',
    weatherCode: 0,
    hourly: [],
    daily: [],
  ), locale).headline(kind);
}

/// Minimal place surface the notification title needs — implemented
/// by [SavedPlace] without coupling this file to it.
abstract class SavedPlaceLike {
  String get label;
}
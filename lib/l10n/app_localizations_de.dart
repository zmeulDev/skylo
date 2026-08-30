// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Skylo — Kenne deinen Himmel.';

  @override
  String get currentLocation => 'Aktueller Standort';

  @override
  String get today => 'Heute';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get next24Hours => 'Nächste 24 Stunden';

  @override
  String get fiveDayOutlook => '5-Tage-Vorhersage';

  @override
  String get noHourlyData => 'Keine Stundendaten';

  @override
  String get noDailyData => 'Keine Tagesdaten';

  @override
  String feelsLike(int temp) {
    return 'GEFÜHLT $temp°';
  }

  @override
  String get knowYourSky => 'KENNE DEINEN HIMMEL';

  @override
  String get addAPlace => 'ORT HINZUFÜGEN';

  @override
  String get searchCity => 'Stadt suchen';

  @override
  String get noPlacesFound => 'Keine Orte gefunden.';

  @override
  String get searchFailed => 'Suche fehlgeschlagen. Prüfe deine Verbindung.';

  @override
  String get settings => 'EINSTELLUNGEN';

  @override
  String get theme => 'Design';

  @override
  String get units => 'Einheiten';

  @override
  String get language => 'Sprache';

  @override
  String get systemLanguage => 'System';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'HELL';

  @override
  String get dark => 'DUNKEL';

  @override
  String get weatherUnavailable => 'Wetter nicht verfügbar';

  @override
  String get locationUnavailable => 'Standort nicht verfügbar';

  @override
  String get retry => 'WIEDERHOLEN';

  @override
  String get openSystemSettings => 'SYSTEMEINSTELLUNGEN ÖFFNEN';

  @override
  String get rain => 'REGEN';

  @override
  String get minLabel => 'MIN';

  @override
  String get maxLabel => 'MAX';

  @override
  String get threeHourSteps => '3-STUNDEN-SCHRITTE';

  @override
  String get noHourlyDetail => 'Keine Stundendetails für diesen Tag.';

  @override
  String get permissionDeniedMessage =>
      'Skylo benötigt die Standortberechtigung, um dein lokales Wetter anzuzeigen.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Der Standortzugriff für Skylo ist deaktiviert. Aktiviere ihn unter Systemeinstellungen → Datenschutz & Sicherheit → Standortdienste.';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap hat den API-Schlüssel abgelehnt (401). Prüfe, ob der Schlüssel gültig ist.';

  @override
  String get rateLimited =>
      'OpenWeatherMap-Limit überschritten. Versuche es in einer Minute erneut.';

  @override
  String get networkError =>
      'OpenWeatherMap konnte nicht erreicht werden. Prüfe deine Verbindung.';

  @override
  String get alertThunderstorm => 'GEWITTER ERWARTET';

  @override
  String get alertSnow => 'SCHNEE ERWARTET';

  @override
  String get alertRain => 'REGEN ERWARTET';

  @override
  String get alertWindGust => 'STARKE BÖEN';

  @override
  String get alertHeat => 'HITZEWARTE';

  @override
  String get alertCold => 'EXTREME KÄLTE';

  @override
  String get alertFog => 'NEBEL ERWARTET';

  @override
  String get alertUv => 'HOHER UV-INDEX';

  @override
  String get alertAirQuality => 'SCHLECHTE LUFTQUALITÄT';
}

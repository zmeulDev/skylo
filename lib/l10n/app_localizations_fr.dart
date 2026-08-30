// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Skylo — Connais ton ciel.';

  @override
  String get currentLocation => 'Position actuelle';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get next24Hours => 'Prochaines 24 heures';

  @override
  String get fiveDayOutlook => 'Prévisions sur 5 jours';

  @override
  String get noHourlyData => 'Aucune donnée horaire';

  @override
  String get noDailyData => 'Aucune donnée quotidienne';

  @override
  String feelsLike(int temp) {
    return 'RESSENTI $temp°';
  }

  @override
  String get knowYourSky => 'CONNAIS TON CIEL';

  @override
  String get addAPlace => 'AJOUTER UN LIEU';

  @override
  String get searchCity => 'Rechercher une ville';

  @override
  String get noPlacesFound => 'Aucun lieu trouvé.';

  @override
  String get searchFailed => 'Échec de la recherche. Vérifie ta connexion.';

  @override
  String get settings => 'RÉGLAGES';

  @override
  String get theme => 'Thème';

  @override
  String get units => 'Unités';

  @override
  String get language => 'Langue';

  @override
  String get systemLanguage => 'Système';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'CLAIR';

  @override
  String get dark => 'SOMBRE';

  @override
  String get weatherUnavailable => 'Météo indisponible';

  @override
  String get locationUnavailable => 'Position indisponible';

  @override
  String get retry => 'RÉESSAYER';

  @override
  String get openSystemSettings => 'OUVRIR LES RÉGLAGES SYSTÈME';

  @override
  String get rain => 'PLUIE';

  @override
  String get minLabel => 'MIN';

  @override
  String get maxLabel => 'MAX';

  @override
  String get threeHourSteps => 'INTERVALLES DE 3 HEURES';

  @override
  String get noHourlyDetail => 'Aucun détail horaire pour ce jour.';

  @override
  String get permissionDeniedMessage =>
      'Skylo a besoin de la permission de localisation pour afficher ta météo locale.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'L\'accès à la localisation est désactivé pour Skylo. Active-le dans Réglages système → Confidentialité et sécurité → Services de localisation.';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap a rejeté la clé API (401). Vérifie que la clé est valide.';

  @override
  String get rateLimited =>
      'Limite OpenWeatherMap dépassée. Réessaie dans une minute.';

  @override
  String get networkError =>
      'Impossible de contacter OpenWeatherMap. Vérifie ta connexion.';

  @override
  String get alertThunderstorm => 'ORAGE PRÉVU';

  @override
  String get alertSnow => 'NEIGE PRÉVUE';

  @override
  String get alertRain => 'PLUIE PRÉVUE';

  @override
  String get alertWindGust => 'RAFALES FORTES';

  @override
  String get alertHeat => 'VAGUE DE CHALEUR';

  @override
  String get alertCold => 'FROID EXTRÊME';

  @override
  String get alertFog => 'BROUILLARD PRÉVU';

  @override
  String get alertUv => 'INDICE UV ÉLEVÉ';

  @override
  String get alertAirQuality => 'QUALITÉ DE L\'AIR MÉDIOCRE';
}

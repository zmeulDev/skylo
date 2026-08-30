// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Skylo — Conosci il tuo cielo.';

  @override
  String get currentLocation => 'Posizione attuale';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get next24Hours => 'Prossime 24 ore';

  @override
  String get fiveDayOutlook => 'Previsioni a 5 giorni';

  @override
  String get noHourlyData => 'Nessun dato orario';

  @override
  String get noDailyData => 'Nessun dato giornaliero';

  @override
  String feelsLike(int temp) {
    return 'PERCEPITI $temp°';
  }

  @override
  String get knowYourSky => 'CONOSCI IL TUO CIELO';

  @override
  String get addAPlace => 'AGGIUNGI UN LUOGO';

  @override
  String get searchCity => 'Cerca città';

  @override
  String get noPlacesFound => 'Nessun luogo trovato.';

  @override
  String get searchFailed => 'Ricerca non riuscita. Controlla la connessione.';

  @override
  String get settings => 'IMPOSTAZIONI';

  @override
  String get theme => 'Tema';

  @override
  String get units => 'Unità';

  @override
  String get language => 'Lingua';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'CHIARO';

  @override
  String get dark => 'SCURO';

  @override
  String get weatherUnavailable => 'Meteo non disponibile';

  @override
  String get locationUnavailable => 'Posizione non disponibile';

  @override
  String get retry => 'RIPROVA';

  @override
  String get openSystemSettings => 'APRI IMPOSTAZIONI DI SISTEMA';

  @override
  String get rain => 'PIOGGIA';

  @override
  String get minLabel => 'MIN';

  @override
  String get maxLabel => 'MAX';

  @override
  String get threeHourSteps => 'INTERVALLI DI 3 ORE';

  @override
  String get noHourlyDetail => 'Nessun dettaglio orario per questo giorno.';

  @override
  String get permissionDeniedMessage =>
      'Skylo richiede l\'autorizzazione di localizzazione per mostrarti il meteo locale.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'L\'accesso alla posizione è disattivato per Skylo. Attivalo in Impostazioni sistema → Privacy e sicurezza → Servizi di localizzazione.';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap ha rifiutato la chiave API (401). Verifica che la chiave sia valida.';

  @override
  String get rateLimited =>
      'Limite OpenWeatherMap superato. Riprova tra un minuto.';

  @override
  String get networkError =>
      'Impossibile contattare OpenWeatherMap. Controlla la connessione.';

  @override
  String get alertThunderstorm => 'TEMPESTA ATTESA';

  @override
  String get alertSnow => 'NEVE ATTESA';

  @override
  String get alertRain => 'PIOGGIA ATTESA';

  @override
  String get alertWindGust => 'RAFFICHE FORTE';

  @override
  String get alertHeat => 'ONDATA DI CALORE';

  @override
  String get alertCold => 'FREDDO ESTREMO';

  @override
  String get alertFog => 'NEBBIA ATTESA';

  @override
  String get alertUv => 'INDICE UV ALTO';

  @override
  String get alertAirQuality => 'QUALITÀ DELL\'ARIA SCARSA';
}

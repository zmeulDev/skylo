// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Skylo — Cunoaște-ți cerul.';

  @override
  String get currentLocation => 'Locația curentă';

  @override
  String get today => 'Azi';

  @override
  String get tomorrow => 'Mâine';

  @override
  String get next24Hours => 'Următoarele 24 de ore';

  @override
  String get fiveDayOutlook => 'Prognoza pe 5 zile';

  @override
  String get noHourlyData => 'Date orare indisponibile';

  @override
  String get noDailyData => 'Date zilnice indisponibile';

  @override
  String feelsLike(int temp) {
    return 'SE SIMT $temp°';
  }

  @override
  String get knowYourSky => 'CUNOAȘTE-ȚI CERUL';

  @override
  String get addAPlace => 'ADAUGĂ UN LOC';

  @override
  String get searchCity => 'Caută un oraș';

  @override
  String get noPlacesFound => 'Niciun loc găsit.';

  @override
  String get searchFailed => 'Căutarea a eșuat. Verifică conexiunea.';

  @override
  String get settings => 'SETĂRI';

  @override
  String get theme => 'Temă';

  @override
  String get units => 'Unități';

  @override
  String get language => 'Limbă';

  @override
  String get systemLanguage => 'SISTEM';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'LUMINOS';

  @override
  String get dark => 'ÎNTUNECAT';

  @override
  String get weatherUnavailable => 'Vremea nu e disponibilă';

  @override
  String get locationUnavailable => 'Locația nu e disponibilă';

  @override
  String get retry => 'REÎNCEARCĂ';

  @override
  String get openSystemSettings => 'DESCHIDE SETĂRILE SISTEMULUI';

  @override
  String get rain => 'PLOAIE';

  @override
  String get minLabel => 'MIN';

  @override
  String get maxLabel => 'MAX';

  @override
  String get threeHourSteps => 'PAȘI DE 3 ORE';

  @override
  String get noHourlyDetail => 'Detalii orare indisponibile pentru această zi.';

  @override
  String get permissionDeniedMessage =>
      'Skylo are nevoie de permisiunea de locație pentru a-ți arăta vremea locală.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Accesul la locație este dezactivat pentru Skylo. Activează-l în Setări sistem → Confidențialitate și securitate → Servicii de locație.';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap a respins cheia API (401). Verifică dacă cheia este validă.';

  @override
  String get rateLimited =>
      'Limita de solicitări OpenWeatherMap a fost atinsă. Încearcă din nou într-un minut.';

  @override
  String get networkError =>
      'Nu s-a putut contacta OpenWeatherMap. Verifică conexiunea.';
}

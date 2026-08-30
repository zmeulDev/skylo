// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Skylo — Know your sky.';

  @override
  String get currentLocation => 'Current location';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get next24Hours => 'Next 24 hours';

  @override
  String get fiveDayOutlook => '5-day outlook';

  @override
  String get noHourlyData => 'No hourly data';

  @override
  String get noDailyData => 'No daily data';

  @override
  String feelsLike(int temp) {
    return 'FEELS $temp°';
  }

  @override
  String get knowYourSky => 'KNOW YOUR SKY';

  @override
  String get addAPlace => 'ADD A PLACE';

  @override
  String get searchCity => 'Search city';

  @override
  String get noPlacesFound => 'No places found.';

  @override
  String get searchFailed => 'Search failed. Check your connection.';

  @override
  String get settings => 'SETTINGS';

  @override
  String get theme => 'Theme';

  @override
  String get units => 'Units';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'SYSTEM';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'LIGHT';

  @override
  String get dark => 'DARK';

  @override
  String get weatherUnavailable => 'Weather unavailable';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get retry => 'RETRY';

  @override
  String get openSystemSettings => 'OPEN SYSTEM SETTINGS';

  @override
  String get rain => 'RAIN';

  @override
  String get minLabel => 'MIN';

  @override
  String get maxLabel => 'MAX';

  @override
  String get threeHourSteps => '3-HOUR STEPS';

  @override
  String get noHourlyDetail => 'No hourly detail for this day.';

  @override
  String get permissionDeniedMessage =>
      'Skylo needs location permission to show your local weather.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Location access is disabled for Skylo. Enable it in System Settings → Privacy & Security → Location Services.';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap rejected the API key (401). Check that the key is valid.';

  @override
  String get rateLimited =>
      'OpenWeatherMap rate limit exceeded. Try again in a minute.';

  @override
  String get networkError =>
      'Could not reach OpenWeatherMap. Check your connection.';
}

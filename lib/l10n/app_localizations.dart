import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Skylo — Know your sky.'**
  String get appTitle;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @next24Hours.
  ///
  /// In en, this message translates to:
  /// **'Next 24 hours'**
  String get next24Hours;

  /// No description provided for @fiveDayOutlook.
  ///
  /// In en, this message translates to:
  /// **'5-day outlook'**
  String get fiveDayOutlook;

  /// No description provided for @noHourlyData.
  ///
  /// In en, this message translates to:
  /// **'No hourly data'**
  String get noHourlyData;

  /// No description provided for @noDailyData.
  ///
  /// In en, this message translates to:
  /// **'No daily data'**
  String get noDailyData;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'FEELS {temp}°'**
  String feelsLike(int temp);

  /// No description provided for @knowYourSky.
  ///
  /// In en, this message translates to:
  /// **'KNOW YOUR SKY'**
  String get knowYourSky;

  /// No description provided for @addAPlace.
  ///
  /// In en, this message translates to:
  /// **'ADD A PLACE'**
  String get addAPlace;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get searchCity;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No places found.'**
  String get noPlacesFound;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Check your connection.'**
  String get searchFailed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM'**
  String get systemLanguage;

  /// No description provided for @celsiusUnit.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsiusUnit;

  /// No description provided for @fahrenheitUnit.
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get fahrenheitUnit;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'LIGHT'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'DARK'**
  String get dark;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherUnavailable;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'OPEN SYSTEM SETTINGS'**
  String get openSystemSettings;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'RAIN'**
  String get rain;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get minLabel;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get maxLabel;

  /// No description provided for @threeHourSteps.
  ///
  /// In en, this message translates to:
  /// **'3-HOUR STEPS'**
  String get threeHourSteps;

  /// No description provided for @noHourlyDetail.
  ///
  /// In en, this message translates to:
  /// **'No hourly detail for this day.'**
  String get noHourlyDetail;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Skylo needs location permission to show your local weather.'**
  String get permissionDeniedMessage;

  /// No description provided for @permissionPermanentlyDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Location access is disabled for Skylo. Enable it in System Settings → Privacy & Security → Location Services.'**
  String get permissionPermanentlyDeniedMessage;

  /// No description provided for @apiKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'OpenWeatherMap rejected the API key (401). Check that the key is valid.'**
  String get apiKeyInvalid;

  /// No description provided for @rateLimited.
  ///
  /// In en, this message translates to:
  /// **'OpenWeatherMap rate limit exceeded. Try again in a minute.'**
  String get rateLimited;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach OpenWeatherMap. Check your connection.'**
  String get networkError;

  /// No description provided for @alertThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'THUNDERSTORM EXPECTED'**
  String get alertThunderstorm;

  /// No description provided for @alertSnow.
  ///
  /// In en, this message translates to:
  /// **'SNOW EXPECTED'**
  String get alertSnow;

  /// No description provided for @alertRain.
  ///
  /// In en, this message translates to:
  /// **'RAIN EXPECTED'**
  String get alertRain;

  /// No description provided for @alertWindGust.
  ///
  /// In en, this message translates to:
  /// **'STRONG GUSTS EXPECTED'**
  String get alertWindGust;

  /// No description provided for @alertHeat.
  ///
  /// In en, this message translates to:
  /// **'HEAT WATCH'**
  String get alertHeat;

  /// No description provided for @alertCold.
  ///
  /// In en, this message translates to:
  /// **'COLD WATCH'**
  String get alertCold;

  /// No description provided for @alertFog.
  ///
  /// In en, this message translates to:
  /// **'FOG EXPECTED'**
  String get alertFog;

  /// No description provided for @alertUv.
  ///
  /// In en, this message translates to:
  /// **'HIGH UV TODAY'**
  String get alertUv;

  /// No description provided for @alertAirQuality.
  ///
  /// In en, this message translates to:
  /// **'POOR AIR QUALITY'**
  String get alertAirQuality;

  /// No description provided for @alertsSetting.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsSetting;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get off;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'pt',
    'ro',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

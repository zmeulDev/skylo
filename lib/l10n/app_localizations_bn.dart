// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Skylo — আপনার আকাশ জানুন।';

  @override
  String get currentLocation => 'বর্তমান অবস্থান';

  @override
  String get today => 'আজ';

  @override
  String get tomorrow => 'আগামীকাল';

  @override
  String get next24Hours => 'পরবর্তী ২৪ ঘণ্টা';

  @override
  String get fiveDayOutlook => '৫ দিনের পূর্বাভাস';

  @override
  String get noHourlyData => 'ঘণ্টাভিত্তিক ডেটা নেই';

  @override
  String get noDailyData => 'দৈনিক ডেটা নেই';

  @override
  String feelsLike(int temp) {
    return 'অনুভূত $temp°';
  }

  @override
  String get knowYourSky => 'আপনার আকাশ জানুন';

  @override
  String get addAPlace => 'স্থান যোগ করুন';

  @override
  String get searchCity => 'শহর খুঁজুন';

  @override
  String get noPlacesFound => 'কোনো স্থান পাওয়া যায়নি।';

  @override
  String get searchFailed => 'অনুসন্ধান ব্যর্থ। আপনার সংযোগ পরীক্ষা করুন।';

  @override
  String get settings => 'সেটিংস';

  @override
  String get theme => 'থিম';

  @override
  String get units => 'একক';

  @override
  String get language => 'ভাষা';

  @override
  String get systemLanguage => 'সিস্টেম';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'লাইট';

  @override
  String get dark => 'ডার্ক';

  @override
  String get weatherUnavailable => 'আবহাওয়া পাওয়া যাচ্ছে না';

  @override
  String get locationUnavailable => 'অবস্থান পাওয়া যাচ্ছে না';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get openSystemSettings => 'সিস্টেম সেটিংস খুলুন';

  @override
  String get rain => 'বৃষ্টি';

  @override
  String get minLabel => 'ন্যূন';

  @override
  String get maxLabel => 'সর্বোচ্চ';

  @override
  String get threeHourSteps => '৩ ঘণ্টার ব্যবধান';

  @override
  String get noHourlyDetail => 'এই দিনের জন্য ঘণ্টাভিত্তিক বিবরণ নেই।';

  @override
  String get permissionDeniedMessage =>
      'আপনার স্থানীয় আবহাওয়া দেখাতে Skylo-র লোকেশন অনুমতি প্রয়োজন।';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Skylo-র লোকেশন অ্যাক্সেস বন্ধ। সিস্টেম সেটিংস → গোপনীয়তা ও নিরাপত্তা → লোকেশন পরিষেবা-তে চালু করুন।';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap API কী প্রত্যাখ্যান করেছে (401)। কীটি বৈধ কিনা পরীক্ষা করুন।';

  @override
  String get rateLimited =>
      'OpenWeatherMap-এর সীমা ছাড়িয়ে গেছে। এক মিনিট পর আবার চেষ্টা করুন।';

  @override
  String get networkError =>
      'OpenWeatherMap-এ পৌঁছানো যায়নি। আপনার সংযোগ পরীক্ষা করুন।';
}

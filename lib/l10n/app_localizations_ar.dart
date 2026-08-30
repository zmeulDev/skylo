// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Skylo — اعرف سماءك.';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get next24Hours => 'الـ 24 ساعة القادمة';

  @override
  String get fiveDayOutlook => 'توقعات 5 أيام';

  @override
  String get noHourlyData => 'لا توجد بيانات ساعية';

  @override
  String get noDailyData => 'لا توجد بيانات يومية';

  @override
  String feelsLike(int temp) {
    return 'الإحساس $temp°';
  }

  @override
  String get knowYourSky => 'اعرف سماءك';

  @override
  String get addAPlace => 'إضافة مكان';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get noPlacesFound => 'لم يتم العثور على أماكن.';

  @override
  String get searchFailed => 'فشل البحث. تحقق من اتصالك.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get units => 'الوحدات';

  @override
  String get language => 'اللغة';

  @override
  String get systemLanguage => 'النظام';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get weatherUnavailable => 'الطقس غير متاح';

  @override
  String get locationUnavailable => 'الموقع غير متاح';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get openSystemSettings => 'افتح إعدادات النظام';

  @override
  String get rain => 'أمطار';

  @override
  String get minLabel => 'الأدنى';

  @override
  String get maxLabel => 'الأقصى';

  @override
  String get threeHourSteps => 'فترات كل 3 ساعات';

  @override
  String get noHourlyDetail => 'لا توجد تفاصيل ساعية لهذا اليوم.';

  @override
  String get permissionDeniedMessage =>
      'يحتاج Skylo إلى إذن الموقع لعرض طقسك المحلي.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'تم تعطيل الوصول إلى الموقع لـ Skylo. فعّله من إعدادات النظام → الخصوصية والأمان → خدمات الموقع.';

  @override
  String get apiKeyInvalid =>
      'رفض OpenWeatherMap مفتاح API (401). تحقق من صحة المفتاح.';

  @override
  String get rateLimited =>
      'تم تجاوز حد OpenWeatherMap. حاول مجددًا بعد دقيقة.';

  @override
  String get networkError => 'تعذر الوصول إلى OpenWeatherMap. تحقق من اتصالك.';
}

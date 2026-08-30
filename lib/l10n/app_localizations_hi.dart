// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Skylo — अपने आकाश को जानें।';

  @override
  String get currentLocation => 'वर्तमान स्थान';

  @override
  String get today => 'आज';

  @override
  String get tomorrow => 'कल';

  @override
  String get next24Hours => 'अगले 24 घंटे';

  @override
  String get fiveDayOutlook => '5 दिन का पूर्वानुमान';

  @override
  String get noHourlyData => 'प्रति घंटा डेटा नहीं';

  @override
  String get noDailyData => 'दैनिक डेटा नहीं';

  @override
  String feelsLike(int temp) {
    return 'महसूस $temp°';
  }

  @override
  String get knowYourSky => 'अपने आकाश को जानें';

  @override
  String get addAPlace => 'स्थान जोड़ें';

  @override
  String get searchCity => 'शहर खोजें';

  @override
  String get noPlacesFound => 'कोई स्थान नहीं मिला।';

  @override
  String get searchFailed => 'खोज असफल। अपना कनेक्शन जांचें।';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get theme => 'थीम';

  @override
  String get units => 'इकाइयाँ';

  @override
  String get language => 'भाषा';

  @override
  String get systemLanguage => 'सिस्टम';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'लाइट';

  @override
  String get dark => 'डार्क';

  @override
  String get weatherUnavailable => 'मौसम उपलब्ध नहीं';

  @override
  String get locationUnavailable => 'स्थान उपलब्ध नहीं';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get openSystemSettings => 'सिस्टम सेटिंग्स खोलें';

  @override
  String get rain => 'वर्षा';

  @override
  String get minLabel => 'न्यू';

  @override
  String get maxLabel => 'अधि';

  @override
  String get threeHourSteps => '3 घंटे के अंतराल';

  @override
  String get noHourlyDetail => 'इस दिन के लिए प्रति घंटा विवरण नहीं।';

  @override
  String get permissionDeniedMessage =>
      'अपना स्थानीय मौसम देखने के लिए Skylo को लोकेशन अनुमति चाहिए।';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Skylo के लिए लोकेशन एक्सेस बंद है। सिस्टम सेटिंग्स → प्राइवेसी और सुरक्षा → लोकेशन सेवाओं में सक्षम करें।';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap ने API कुंजी अस्वीकार कर दी (401)। कुंजी मान्य है या नहीं जांचें।';

  @override
  String get rateLimited =>
      'OpenWeatherMap की सीमा पार हो गई। एक मिनट में फिर कोशिश करें।';

  @override
  String get networkError =>
      'OpenWeatherMap से संपर्क नहीं हो सका। अपना कनेक्शन जांचें।';

  @override
  String get alertThunderstorm => 'आंधी-तूफ़ान संभव';

  @override
  String get alertSnow => 'बर्फ़बारी संभव';

  @override
  String get alertRain => 'बारिश संभव';

  @override
  String get alertWindGust => 'तेज़ हवाएँ';

  @override
  String get alertHeat => 'गर्मी का अलर्ट';

  @override
  String get alertCold => 'कड़ाके की ठंड';

  @override
  String get alertFog => 'कोहरा संभव';

  @override
  String get alertUv => 'यूवी सूचकांक अधिक';

  @override
  String get alertAirQuality => 'वायु गुणवत्ता खराब';

  @override
  String get alertsSetting => 'अलर्ट';

  @override
  String get on => 'चालू';

  @override
  String get off => 'बंद';
}

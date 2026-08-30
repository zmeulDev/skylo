// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Skylo — Познай своё небо.';

  @override
  String get currentLocation => 'Текущее местоположение';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get next24Hours => 'Следующие 24 часа';

  @override
  String get fiveDayOutlook => 'Прогноз на 5 дней';

  @override
  String get noHourlyData => 'Нет почасовых данных';

  @override
  String get noDailyData => 'Нет ежедневных данных';

  @override
  String feelsLike(int temp) {
    return 'ОЩУЩАЕТСЯ $temp°';
  }

  @override
  String get knowYourSky => 'ПОЗНАЙ СВОЁ НЕБО';

  @override
  String get addAPlace => 'ДОБАВИТЬ МЕСТО';

  @override
  String get searchCity => 'Найти город';

  @override
  String get noPlacesFound => 'Места не найдены.';

  @override
  String get searchFailed => 'Поиск не удался. Проверьте подключение.';

  @override
  String get settings => 'НАСТРОЙКИ';

  @override
  String get theme => 'Тема';

  @override
  String get units => 'Единицы';

  @override
  String get language => 'Язык';

  @override
  String get systemLanguage => 'Система';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'СВЕТЛАЯ';

  @override
  String get dark => 'ТЁМНАЯ';

  @override
  String get weatherUnavailable => 'Погода недоступна';

  @override
  String get locationUnavailable => 'Местоположение недоступно';

  @override
  String get retry => 'ПОВТОРИТЬ';

  @override
  String get openSystemSettings => 'ОТКРЫТЬ НАСТРОЙКИ СИСТЕМЫ';

  @override
  String get rain => 'ДОЖДЬ';

  @override
  String get minLabel => 'МИН';

  @override
  String get maxLabel => 'МАКС';

  @override
  String get threeHourSteps => 'ШАГИ ПО 3 ЧАСА';

  @override
  String get noHourlyDetail => 'Нет почасовых подробностей для этого дня.';

  @override
  String get permissionDeniedMessage =>
      'Skylo требуется разрешение на геолокацию, чтобы показать вашу местную погоду.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Доступ к геолокации отключён для Skylo. Включите его в Настройках системы → Конфиденциальность и безопасность → Службы геолокации.';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap отклонил ключ API (401). Проверьте, действителен ли ключ.';

  @override
  String get rateLimited =>
      'Превышен лимит OpenWeatherMap. Попробуйте через минуту.';

  @override
  String get networkError =>
      'Не удалось связаться с OpenWeatherMap. Проверьте подключение.';

  @override
  String get alertThunderstorm => 'ОЖИДАЕТСЯ ГРОЗА';

  @override
  String get alertSnow => 'ОЖИДАЕТСЯ СНЕГ';

  @override
  String get alertRain => 'ОЖИДАЕТСЯ ДОЖДЬ';

  @override
  String get alertWindGust => 'СИЛЬНЫЕ ПОРЫВЫ ВЕТРА';

  @override
  String get alertHeat => 'ЖАРА';

  @override
  String get alertCold => 'СИЛЬНЫЙ МОРОЗ';

  @override
  String get alertFog => 'ОЖИДАЕТСЯ ТУМАН';

  @override
  String get alertUv => 'ВЫСОКИЙ УФ-ИНДЕКС';

  @override
  String get alertAirQuality => 'ПЛОХОЕ КАЧЕСТВО ВОЗДУХА';

  @override
  String get alertsSetting => 'Оповещения';

  @override
  String get on => 'ВКЛ';

  @override
  String get off => 'ВЫКЛ';
}

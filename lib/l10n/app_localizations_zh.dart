// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Skylo — 了解你的天空。';

  @override
  String get currentLocation => '当前位置';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get next24Hours => '未来24小时';

  @override
  String get fiveDayOutlook => '5天预报';

  @override
  String get noHourlyData => '无逐小时数据';

  @override
  String get noDailyData => '无每日数据';

  @override
  String feelsLike(int temp) {
    return '体感 $temp°';
  }

  @override
  String get knowYourSky => '了解你的天空';

  @override
  String get addAPlace => '添加地点';

  @override
  String get searchCity => '搜索城市';

  @override
  String get noPlacesFound => '未找到地点。';

  @override
  String get searchFailed => '搜索失败。请检查网络连接。';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get units => '单位';

  @override
  String get language => '语言';

  @override
  String get systemLanguage => '系统';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get weatherUnavailable => '天气信息不可用';

  @override
  String get locationUnavailable => '位置信息不可用';

  @override
  String get retry => '重试';

  @override
  String get openSystemSettings => '打开系统设置';

  @override
  String get rain => '降雨';

  @override
  String get minLabel => '最低';

  @override
  String get maxLabel => '最高';

  @override
  String get threeHourSteps => '3小时间隔';

  @override
  String get noHourlyDetail => '当天无逐小时详情。';

  @override
  String get permissionDeniedMessage => 'Skylo 需要位置权限才能显示您当地的天气。';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Skylo 的位置访问已禁用。请在 系统设置 → 隐私与安全 → 定位服务 中启用。';

  @override
  String get apiKeyInvalid => 'OpenWeatherMap 拒绝了 API 密钥 (401)。请检查密钥是否有效。';

  @override
  String get rateLimited => '已超出 OpenWeatherMap 请求限制。请一分钟后重试。';

  @override
  String get networkError => '无法连接 OpenWeatherMap。请检查网络连接。';

  @override
  String get alertThunderstorm => '预计有雷暴';

  @override
  String get alertSnow => '预计有降雪';

  @override
  String get alertRain => '预计有降雨';

  @override
  String get alertWindGust => '强阵风';

  @override
  String get alertHeat => '高温预警';

  @override
  String get alertCold => '严寒预警';

  @override
  String get alertFog => '预计有雾';

  @override
  String get alertUv => '紫外线强';

  @override
  String get alertAirQuality => '空气质量差';

  @override
  String get alertsSetting => '天气预警';

  @override
  String get on => '开';

  @override
  String get off => '关';
}

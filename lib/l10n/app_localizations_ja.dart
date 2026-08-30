// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Skylo — あなたの空を知ろう。';

  @override
  String get currentLocation => '現在地';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get next24Hours => '今後24時間';

  @override
  String get fiveDayOutlook => '5日間の予報';

  @override
  String get noHourlyData => '時間ごとのデータなし';

  @override
  String get noDailyData => '日ごとのデータなし';

  @override
  String feelsLike(int temp) {
    return '体感 $temp°';
  }

  @override
  String get knowYourSky => 'あなたの空を知ろう';

  @override
  String get addAPlace => '場所を追加';

  @override
  String get searchCity => '都市を検索';

  @override
  String get noPlacesFound => '場所が見つかりません。';

  @override
  String get searchFailed => '検索に失敗しました。接続を確認してください。';

  @override
  String get settings => '設定';

  @override
  String get theme => 'テーマ';

  @override
  String get units => '単位';

  @override
  String get language => '言語';

  @override
  String get systemLanguage => 'システム';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get weatherUnavailable => '天気が取得できません';

  @override
  String get locationUnavailable => '現在地が取得できません';

  @override
  String get retry => '再試行';

  @override
  String get openSystemSettings => 'システム設定を開く';

  @override
  String get rain => '雨';

  @override
  String get minLabel => '最低';

  @override
  String get maxLabel => '最高';

  @override
  String get threeHourSteps => '3時間ごと';

  @override
  String get noHourlyDetail => 'この日の時間ごとの詳細はありません。';

  @override
  String get permissionDeniedMessage => '現地の天気を表示するには位置情報の許可が必要です。';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'Skylo の位置情報アクセスが無効です。システム設定 → プライバシーとセキュリティ → 位置情報サービス で有効にしてください。';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap が API キーを拒否しました (401)。キーが有効か確認してください。';

  @override
  String get rateLimited => 'OpenWeatherMap のリクエスト制限を超えました。1分後に再試行してください。';

  @override
  String get networkError => 'OpenWeatherMap に接続できません。接続を確認してください。';
}

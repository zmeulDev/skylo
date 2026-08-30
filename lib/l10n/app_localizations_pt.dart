// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Skylo — Conheça o seu céu.';

  @override
  String get currentLocation => 'Localização atual';

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get next24Hours => 'Próximas 24 horas';

  @override
  String get fiveDayOutlook => 'Previsão de 5 dias';

  @override
  String get noHourlyData => 'Sem dados por hora';

  @override
  String get noDailyData => 'Sem dados diários';

  @override
  String feelsLike(int temp) {
    return 'SENSAÇÃO $temp°';
  }

  @override
  String get knowYourSky => 'CONHEÇA O SEU CÉU';

  @override
  String get addAPlace => 'ADICIONAR LOCAL';

  @override
  String get searchCity => 'Pesquisar cidade';

  @override
  String get noPlacesFound => 'Nenhum local encontrado.';

  @override
  String get searchFailed => 'A pesquisa falhou. Verifique sua conexão.';

  @override
  String get settings => 'AJUSTES';

  @override
  String get theme => 'Tema';

  @override
  String get units => 'Unidades';

  @override
  String get language => 'Idioma';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get celsiusUnit => '°C';

  @override
  String get fahrenheitUnit => '°F';

  @override
  String get light => 'CLARO';

  @override
  String get dark => 'ESCURO';

  @override
  String get weatherUnavailable => 'Clima indisponível';

  @override
  String get locationUnavailable => 'Localização indisponível';

  @override
  String get retry => 'TENTAR NOVAMENTE';

  @override
  String get openSystemSettings => 'ABRIR AJUSTES DO SISTEMA';

  @override
  String get rain => 'CHUVA';

  @override
  String get minLabel => 'MÍN';

  @override
  String get maxLabel => 'MÁX';

  @override
  String get threeHourSteps => 'INTERVALOS DE 3 HORAS';

  @override
  String get noHourlyDetail => 'Sem detalhes por hora para este dia.';

  @override
  String get permissionDeniedMessage =>
      'A Skylo precisa de permissão de localização para mostrar o clima local.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'O acesso à localização está desativado para a Skylo. Ative-o em Ajustes do sistema → Privacidade e segurança → Serviços de localização.';

  @override
  String get apiKeyInvalid =>
      'A OpenWeatherMap rejeitou a chave da API (401). Verifique se a chave é válida.';

  @override
  String get rateLimited =>
      'Limite da OpenWeatherMap excedido. Tente novamente em um minuto.';

  @override
  String get networkError =>
      'Não foi possível contatar a OpenWeatherMap. Verifique sua conexão.';

  @override
  String get alertThunderstorm => 'TEMPESTADE PREVISTA';

  @override
  String get alertSnow => 'NEVE PREVISTA';

  @override
  String get alertRain => 'CHUVA PREVISTA';

  @override
  String get alertWindGust => 'RAJADAS FORTES';

  @override
  String get alertHeat => 'ONDA DE CALOR';

  @override
  String get alertCold => 'FRIO EXTREMO';

  @override
  String get alertFog => 'NEBLINA PREVISTA';

  @override
  String get alertUv => 'ÍNDICE UV ALTO';

  @override
  String get alertAirQuality => 'QUALIDADE DO AR BAIXA';
}

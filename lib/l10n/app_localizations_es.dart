// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Skylo — Conoce tu cielo.';

  @override
  String get currentLocation => 'Ubicación actual';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get next24Hours => 'Próximas 24 horas';

  @override
  String get fiveDayOutlook => 'Pronóstico de 5 días';

  @override
  String get noHourlyData => 'Sin datos por horas';

  @override
  String get noDailyData => 'Sin datos diarios';

  @override
  String feelsLike(int temp) {
    return 'SE SIENTE $temp°';
  }

  @override
  String get knowYourSky => 'CONOCE TU CIELO';

  @override
  String get addAPlace => 'AÑADIR UN LUGAR';

  @override
  String get searchCity => 'Buscar ciudad';

  @override
  String get noPlacesFound => 'No se encontraron lugares.';

  @override
  String get searchFailed => 'La búsqueda falló. Comprueba tu conexión.';

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
  String get dark => 'OSCURO';

  @override
  String get weatherUnavailable => 'Tiempo no disponible';

  @override
  String get locationUnavailable => 'Ubicación no disponible';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get openSystemSettings => 'ABRIR AJUSTES DEL SISTEMA';

  @override
  String get rain => 'LLUVIA';

  @override
  String get minLabel => 'MÍN';

  @override
  String get maxLabel => 'MÁX';

  @override
  String get threeHourSteps => 'INTERVALOS DE 3 HORAS';

  @override
  String get noHourlyDetail => 'Sin detalle por horas para este día.';

  @override
  String get permissionDeniedMessage =>
      'Skylo necesita permiso de ubicación para mostrarte el tiempo local.';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'El acceso a la ubicación está desactivado para Skylo. Actívalo en Ajustes del sistema → Privacidad y seguridad → Servicios de ubicación.';

  @override
  String get apiKeyInvalid =>
      'OpenWeatherMap rechazó la clave API (401). Comprueba que la clave sea válida.';

  @override
  String get rateLimited =>
      'Se superó el límite de OpenWeatherMap. Inténtalo de nuevo en un minuto.';

  @override
  String get networkError =>
      'No se pudo contactar con OpenWeatherMap. Comprueba tu conexión.';

  @override
  String get alertThunderstorm => 'TORMENTA PREVISTA';

  @override
  String get alertSnow => 'NIEVE PREVISTA';

  @override
  String get alertRain => 'LLUVIA PREVISTA';

  @override
  String get alertWindGust => 'RÁFAGAS FUERTES';

  @override
  String get alertHeat => 'OLEAJE DE CALOR';

  @override
  String get alertCold => 'FRÍO EXTREMO';

  @override
  String get alertFog => 'NIEBLA PREVISTA';

  @override
  String get alertUv => 'ÍNDICE UV ALTO';

  @override
  String get alertAirQuality => 'CALIDAD DEL AIRE BAJA';

  @override
  String get alertsSetting => 'Alertas';

  @override
  String get on => 'SÍ';

  @override
  String get off => 'NO';
}

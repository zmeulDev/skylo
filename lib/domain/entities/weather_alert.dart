/// A weather alert derived from forecast data by threshold rules.
enum WeatherAlertKind {
  thunderstorm,
  snow,
  rain,
  windGust,
  heat,
  cold,
  fog,
  uv,
  airQuality,
}

class WeatherAlert {
  final WeatherAlertKind kind;
  final String headline;
  final String detail;
  final bool severe;

  const WeatherAlert({
    required this.kind,
    required this.headline,
    required this.detail,
    this.severe = false,
  });

  /// Severe alerts earn the red accent; the rest stay ink/muted.
  bool get earnsAccent => severe;
}
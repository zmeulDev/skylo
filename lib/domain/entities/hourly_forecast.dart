class HourlyForecast {
  final DateTime time;
  final double temp;
  final int weatherCode;
  final double precipitationProbability;

  const HourlyForecast({
    required this.time,
    required this.temp,
    required this.weatherCode,
    required this.precipitationProbability,
  });
}
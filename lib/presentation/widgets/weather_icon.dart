import 'package:flutter/material.dart';

/// Maps OpenWeatherMap condition codes to Material icons.
class WeatherIcon extends StatelessWidget {
  final int weatherCode;
  final double size;

  const WeatherIcon({super.key, required this.weatherCode, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Icon(_icon, size: size, color: Colors.white);
  }

  IconData get _icon {
    if (weatherCode >= 200 && weatherCode < 300) return Icons.thunderstorm_rounded;
    if (weatherCode >= 300 && weatherCode < 600) return Icons.water_drop_rounded;
    if (weatherCode >= 600 && weatherCode < 700) return Icons.ac_unit_rounded;
    if (weatherCode >= 700 && weatherCode < 800) return Icons.blur_on_rounded;
    if (weatherCode == 800) return Icons.wb_sunny_rounded;
    if (weatherCode > 800) return Icons.cloud_rounded;
    return Icons.help_outline_rounded;
  }
}
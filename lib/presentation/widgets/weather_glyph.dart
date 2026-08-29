import 'package:flutter/material.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Monochrome OWM weather-code glyph. [accent] renders precip codes in red.
class WeatherGlyph extends StatelessWidget {
  final int weatherCode;
  final double size;
  final bool accent;

  const WeatherGlyph({
    super.key,
    required this.weatherCode,
    this.size = 22,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _icon,
      size: size,
      color: accent ? context.skylo.accent : context.skylo.ink,
    );
  }

  IconData get _icon {
    if (weatherCode >= 200 && weatherCode < 300) return Icons.thunderstorm_outlined;
    if (weatherCode >= 300 && weatherCode < 600) return Icons.water_drop_outlined;
    if (weatherCode >= 600 && weatherCode < 700) return Icons.ac_unit_outlined;
    if (weatherCode >= 700 && weatherCode < 800) return Icons.blur_on_outlined;
    if (weatherCode == 800) return Icons.wb_sunny_outlined;
    if (weatherCode > 800) return Icons.cloud_outlined;
    return Icons.circle_outlined;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/weather_entity.dart' show WeatherUnitsX;
import 'package:skylo/presentation/providers/units_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';
import 'package:skylo/presentation/widgets/anim/motion.dart';
import 'package:skylo/presentation/widgets/weather_glyph.dart';

/// Day detail sheet: opens from a tap on a 5-day outlook row.
/// Shows the day's 3-hour timeline with the same row language as
/// the hourly strip, plus min/max/rain stats.
Future<void> showDayDetailSheet(
    BuildContext context, DailyForecast day, String title) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.skylo.surface,
    barrierColor: context.skylo.ink.withValues(alpha: 0.4),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (_) => _DayDetailSheet(day: day, title: title),
  );
}

class _DayDetailSheet extends ConsumerWidget {
  final DailyForecast day;
  final String title;

  const _DayDetailSheet({required this.day, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);
    final hours = day.hours;
    final maxPop = hours.isEmpty
        ? 0.0
        : hours
            .map((h) => h.precipitationProbability)
            .reduce((a, b) => a > b ? a : b);
    final rainy = maxPop >= 30;

    return Padding(
      padding:
          EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom +
                MediaQuery.viewPaddingOf(context).bottom,
          ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppText.location(context)),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMMM').format(day.date),
                style: AppText.condition(context).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _Stat(
                    label: 'MIN',
                    value: '${units.convertTemp(day.minTemp).round()}°',
                  ),
                  _Stat(
                    label: 'MAX',
                    value: '${units.convertTemp(day.maxTemp).round()}°',
                  ),
                  _Stat(
                    label: 'RAIN',
                    value: '${maxPop.round()}%',
                    accent: rainy,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Container(
                      width: 3, height: 14, color: context.skylo.accent),
                  const SizedBox(width: 10),
                  Text('3-HOUR STEPS', style: AppText.label(context)),
                ],
              ),
              const SizedBox(height: 20),
              if (hours.isEmpty)
                Text('No hourly detail for this day.',
                    style: AppText.condition(context))
              else
                _DayTimeline(hours: hours, animateKey: day.date),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _Stat({required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.label(context)),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppText.tabular(context).copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: accent ? context.skylo.accent : context.skylo.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTimeline extends ConsumerWidget {
  final List<HourlyForecast> hours;
  final Object animateKey;

  const _DayTimeline({required this.hours, required this.animateKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);
    final temps = hours.map((h) => h.temp).toList();
    final minTemp = temps.reduce((a, b) => a < b ? a : b);
    final maxTemp = temps.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final h in hours)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    DateFormat('HH:mm').format(h.time),
                    style: AppText.tabular(context)
                        .copyWith(color: context.skylo.muted),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: PulsingGlyph(
                    enabled: h.precipitationProbability >= 30,
                    child: WeatherGlyph(
                      weatherCode: h.weatherCode,
                      size: 18,
                      accent: h.precipitationProbability >= 30,
                    ),
                  ),
                ),
                Expanded(
                  child: SweepingTempBar(
                    fraction: _fraction(h.temp, minTemp, maxTemp),
                    animateKey: animateKey,
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${units.convertTemp(h.temp).round()}°',
                    textAlign: TextAlign.right,
                    style: AppText.tabular(context),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    h.precipitationProbability >= 1
                        ? '${h.precipitationProbability.round()}%'
                        : '—',
                    textAlign: TextAlign.right,
                    style: AppText.tabular(context)
                        .copyWith(color: context.skylo.muted),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  double _fraction(double temp, double minTemp, double maxTemp) {
    final range = (maxTemp - minTemp).clamp(1.0, double.infinity);
    final fraction = ((temp - minTemp) / range).clamp(0.0, 1.0);
    return fraction == 0 ? 0.03 : fraction;
  }
}
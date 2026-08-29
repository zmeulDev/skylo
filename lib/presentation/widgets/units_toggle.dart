import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/presentation/providers/units_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// One-tap unit toggle: 40px hairline circle, °C / °F glyph.
/// Active unit in ink; flips metric <-> imperial instantly.
class UnitsToggle extends ConsumerWidget {
  const UnitsToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);
    final isImperial = units == WeatherUnits.imperial;

    return GestureDetector(
      onTap: () => ref.read(unitsProvider.notifier).set(
            isImperial ? WeatherUnits.metric : WeatherUnits.imperial,
          ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.skylo.hairline, width: 1),
        ),
        child: Center(
          child: Text(
            isImperial ? '°F' : '°C',
            style: AppText.tabular(context).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.skylo.ink,
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/providers/units_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Opens the settings sheet: theme + units, in the design language.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.skylo.surface,
    barrierColor: context.skylo.ink.withValues(alpha: 0.4),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isEffectiveDark(ref.watch(themeModeProvider));
    final isImperial =
        ref.watch(unitsProvider) == WeatherUnits.imperial;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                    width: 3, height: 14, color: context.skylo.accent),
                const SizedBox(width: 10),
                Text('SETTINGS', style: AppText.label(context)),
              ],
            ),
            const SizedBox(height: 28),
            _SettingsRow(
              icon: isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              title: 'Theme',
              trailing: Text(
                isDark ? 'DARK' : 'LIGHT',
                style: AppText.tabular(context).copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: context.skylo.muted,
                ),
              ),
              onTap: () {
                // Close first, then run the ink-reveal from this row's
                // origin — the overlay lives in the root and survives pop.
                Navigator.of(context).pop();
                ref
                    .read(themeModeProvider.notifier)
                    .toggleWithReveal(context);
              },
            ),
            const SizedBox(height: 12),
            _SettingsRow(
              icon: Icons.straighten_outlined,
              title: 'Units',
              trailing: Text(
                isImperial ? '°F' : '°C',
                style: AppText.tabular(context).copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: context.skylo.muted,
                ),
              ),
              onTap: () => ref.read(unitsProvider.notifier).set(
                    isImperial
                        ? WeatherUnits.metric
                        : WeatherUnits.imperial,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.skylo.ink),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: AppText.body(context)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
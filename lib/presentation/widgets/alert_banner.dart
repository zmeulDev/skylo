import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_alert.dart';
import 'package:skylo/l10n/app_localizations.dart';
import 'package:skylo/presentation/providers/alerts_providers.dart';
import 'package:skylo/presentation/providers/alerts_settings_provider.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Inline alert strip under the current-weather block. Severe alerts
/// earn the accent; watches stay ink with a hairline. Follows the
/// "accent is earned" rule from the design notes.
/// Off by default — the user turns alerts on in Settings.
class AlertBanner extends ConsumerWidget {
  final SavedPlace place;

  const AlertBanner({super.key, required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (!ref.watch(alertsEnabledProvider)) return const SizedBox.shrink();
    if (l10n == null) return const SizedBox.shrink();

    final alertsAsync = ref.watch(placeAlertsProvider(place));
    final alerts = alertsAsync.value ?? const <WeatherAlert>[];
    if (alerts.isEmpty) return const SizedBox.shrink();

    final theme = context.skylo;

    // Severe first, then by kind order.
    final sorted = [...alerts]..sort((a, b) {
        if (a.severe != b.severe) return a.severe ? -1 : 1;
        return a.kind.index.compareTo(b.kind.index);
      });

    return Column(
      children: [
        for (final alert in sorted.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AlertRow(alert: alert, theme: theme, l10n: l10n),
          ),
      ],
    );
  }
}

class _AlertRow extends StatelessWidget {
  final WeatherAlert alert;
  final SkyloTheme theme;
  final AppLocalizations l10n;

  const _AlertRow({
    required this.alert,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final color = alert.earnsAccent ? theme.accent : theme.ink;
    final label = _headline(l10n);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.body(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _detail(),
              style: AppText.label(context),
            ),
          ],
        ),
      ),
    );
  }

  String _headline(AppLocalizations l10n) => switch (alert.kind) {
        WeatherAlertKind.thunderstorm => l10n.alertThunderstorm,
        WeatherAlertKind.snow => l10n.alertSnow,
        WeatherAlertKind.rain => l10n.alertRain,
        WeatherAlertKind.windGust => l10n.alertWindGust,
        WeatherAlertKind.heat => l10n.alertHeat,
        WeatherAlertKind.cold => l10n.alertCold,
        WeatherAlertKind.fog => l10n.alertFog,
        WeatherAlertKind.uv => l10n.alertUv,
        WeatherAlertKind.airQuality => l10n.alertAirQuality,
      };

  String _detail() => alert.detail;
}
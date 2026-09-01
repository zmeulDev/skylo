import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/debug_notifications.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/l10n/app_localizations.dart';
import 'package:skylo/presentation/providers/alerts_settings_provider.dart';
import 'package:skylo/presentation/providers/locale_providers.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/providers/units_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Opens the settings sheet: theme + units + language, in the design
/// language.
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = isEffectiveDark(ref.watch(themeModeProvider));
    final localeOverride = ref.watch(localeProvider);
    final resolvedLocale = localeOverride ??
        Localizations.localeOf(context);
    final units = resolveUnits(ref.watch(unitsProvider), resolvedLocale);

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
                Text(l10n.settings, style: AppText.label(context)),
              ],
            ),
            const SizedBox(height: 28),
            _SettingsRow(
              icon: isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              title: l10n.theme,
              trailing: Text(
                isDark ? l10n.dark : l10n.light,
                style: _stateStyle(context),
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
              title: l10n.units,
              trailing: Text(
                units == WeatherUnits.metric
                    ? l10n.celsiusUnit
                    : l10n.fahrenheitUnit,
                style: _stateStyle(context),
              ),
              onTap: () {
                final locale = localeOverride ??
                    Localizations.localeOf(context);
                ref
                    .read(unitsProvider.notifier)
                    .toggle(locale);
              },
            ),
            const SizedBox(height: 12),
            _SettingsRow(
              icon: Icons.warning_amber_outlined,
              title: l10n.alertsSetting,
              trailing: Text(
                ref.watch(alertsEnabledProvider) ? l10n.on : l10n.off,
                style: _stateStyle(context),
              ),
              onTap: () {
                ref.read(alertsEnabledProvider.notifier).toggle();
              },
            ),
            const SizedBox(height: 12),
            _SettingsRow(
              icon: Icons.language_outlined,
              title: l10n.language,
              trailing: Text(
                _languageLabel(l10n, localeOverride),
                style: _stateStyle(context),
              ),
              onTap: () {
                Navigator.of(context).pop();
                showLanguageSheet(context);
              },
            ),
            if (kSkyloDebugNotifications) ...[
              const SizedBox(height: 12),
              _SettingsRow(
                icon: Icons.bolt_outlined,
                title: 'TEST NOTIFICATIONS',
                trailing: const SizedBox.shrink(),
                onTap: postDebugNotifications,
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _stateStyle(BuildContext context) =>
      AppText.tabular(context).copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: context.skylo.muted,
      );

  /// Native name of the language, ALL CAPS per the design language.
  String _languageLabel(AppLocalizations l10n, Locale? override) {
    if (override == null) return l10n.systemLanguage;
    return _nativeName(override.languageCode);
  }
}

/// Native language names — each shown in its own script, ALL CAPS where
/// the script supports it.
String _nativeName(String code) => switch (code) {
      'en' => 'ENGLISH',
      'ro' => 'ROMÂNĂ',
      'es' => 'ESPAÑOL',
      'fr' => 'FRANÇAIS',
      'de' => 'DEUTSCH',
      'it' => 'ITALIANO',
      'pt' => 'PORTUGUÊS',
      'ru' => 'РУССКИЙ',
      'zh' => '中文',
      'ja' => '日本語',
      'hi' => 'हिन्दी',
      'ar' => 'العربية',
      'bn' => 'বাংলা',
      _ => code.toUpperCase(),
    };

/// The ordered language list shown in the picker.
const kSupportedLanguageCodes = [
  null, // system
  'en', 'ro', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'zh', 'ja', 'hi', 'ar',
  'bn',
];

/// Language picker sheet: SYSTEM + every supported language, native names,
/// active in ink with the red tick per the accent rules.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.skylo.surface,
    barrierColor: context.skylo.ink.withValues(alpha: 0.4),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final active = ref.watch(localeProvider);

    return Padding(
      padding: EdgeInsets.only(
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
              Row(
                children: [
                  Container(
                      width: 3, height: 14, color: context.skylo.accent),
                  const SizedBox(width: 10),
                  Text(l10n.language.toUpperCase(),
                      style: AppText.label(context)),
                ],
              ),
              const SizedBox(height: 16),
              for (final code in kSupportedLanguageCodes)
                InkWell(
                  onTap: () {
                    ref.read(localeProvider.notifier).set(
                        code == null ? null : Locale(code));
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          color: _matches(active, code)
                              ? context.skylo.accent
                              : Colors.transparent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            code == null
                                ? l10n.systemLanguage
                                : _nativeName(code),
                            style: AppText.body(context).copyWith(
                              fontWeight: _matches(active, code)
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matches(Locale? active, String? code) {
    if (code == null) return active == null;
    return active?.languageCode == code;
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
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/data/datasources/notification_service.dart';
import 'package:skylo/l10n/app_localizations.dart';
import 'package:skylo/presentation/providers/alert_delivery_provider.dart';
import 'package:skylo/presentation/providers/dock_badge_provider.dart';
import 'package:skylo/presentation/providers/locale_providers.dart';
import 'package:skylo/presentation/providers/location_revalidation_provider.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/screens/home_screen.dart';
import 'package:skylo/presentation/providers/widget_snapshot_provider.dart';

void main() {
  runApp(const ProviderScope(child: SkyloApp()));
  NotificationService.instance.initialize();
  // Notification tap routing is registered by HomeScreen once its
  // PageController exists; the service holds the static hook.
}

class SkyloApp extends ConsumerWidget {
  const SkyloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final localeOverride = ref.watch(localeProvider);
    ref.watch(dockBadgeProvider);
    ref.watch(locationRevalidationProvider);
    ref.watch(alertDeliveryCoordinatorProvider);
    ref.watch(widgetSnapshotCoordinatorProvider);

    return MaterialApp(
      title: 'Skylo — Know your sky.',
      debugShowCheckedModeBanner: false,
      theme: cachedLightTheme,
      darkTheme: cachedDarkTheme,
      themeMode: mode,
      locale: localeOverride,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
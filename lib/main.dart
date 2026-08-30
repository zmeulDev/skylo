import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/presentation/providers/dock_badge_provider.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/screens/home_screen.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SkyloApp()));
}

class SkyloApp extends ConsumerWidget {
  const SkyloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    ref.watch(dockBadgeProvider);

    return MaterialApp(
      title: 'Skylo — Know your sky.',
      debugShowCheckedModeBanner: false,
      theme: ThemeMode.light.toThemeData(),
      darkTheme: ThemeMode.dark.toThemeData(),
      themeMode: mode,
      home: const AnimatedTheme(
        child: HomeScreen(),
      ),
    );
  }
}

/// Cross-fades surface color during theme changes.
class AnimatedTheme extends StatelessWidget {
  final Widget child;

  const AnimatedTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final skylo = context.skylo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      color: skylo.surface,
      child: child,
    );
  }
}
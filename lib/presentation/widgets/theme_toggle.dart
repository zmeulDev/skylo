import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/presentation/theme/app_theme.dart';
import 'package:skylo/presentation/widgets/settings_sheet.dart';

/// Settings entry point: 40px hairline circle with an outlined gear glyph.
/// Opens the settings sheet (theme + units).
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => showSettingsSheet(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.skylo.hairline, width: 1),
        ),
        child: Icon(
          Icons.settings_outlined,
          size: 18,
          color: context.skylo.ink,
        ),
      ),
    );
  }
}
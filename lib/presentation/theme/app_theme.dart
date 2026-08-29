import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand constants — identical in light and dark.
abstract final class AppColors {
  static const red = Color(0xFFE4002B);
  static const white = Color(0xFFFFFFFF);
}

/// Skylo design tokens. Light and dark share one structure:
/// flat surface, single ink, muted greys, hairline rules, red accent.
@immutable
class SkyloTheme extends ThemeExtension<SkyloTheme> {
  const SkyloTheme({
    required this.surface,
    required this.ink,
    required this.muted,
    required this.hairline,
    required this.accent,
  });

  /// Canvas.
  final Color surface;

  /// Primary text, glyphs, bar fills.
  final Color ink;

  /// Secondary text, timestamps, min temps.
  final Color muted;

  /// 2px separators and unfilled bar tracks.
  final Color hairline;

  /// The single accent. Reserved, never decorative.
  final Color accent;

  static const light = SkyloTheme(
    surface: Color(0xFFFAFAF8),
    ink: Color(0xFF0A0A0A),
    muted: Color(0xFF8A8A8A),
    hairline: Color(0xFFE8E8E8),
    accent: AppColors.red,
  );

  static const dark = SkyloTheme(
    surface: Color(0xFF0D0D0D),
    ink: Color(0xFFF2F2F0),
    muted: Color(0xFF9A9A9A),
    hairline: Color(0xFF262626),
    accent: Color(0xFFFF375F),
  );

  @override
  SkyloTheme copyWith({
    Color? surface,
    Color? ink,
    Color? muted,
    Color? hairline,
    Color? accent,
  }) {
    return SkyloTheme(
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      hairline: hairline ?? this.hairline,
      accent: accent ?? this.accent,
    );
  }

  @override
  SkyloTheme lerp(SkyloTheme other, double t) {
    return SkyloTheme(
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

extension SkyloThemeX on BuildContext {
  SkyloTheme get skylo => Theme.of(this).extension<SkyloTheme>()!;
}

/// Inter-based type scale. All colors resolve from the active [SkyloTheme].
abstract final class AppText {
  static TextStyle display(BuildContext context) => GoogleFonts.inter(
        fontSize: 120,
        fontWeight: FontWeight.w200,
        letterSpacing: -6,
        height: 1.0,
        color: context.skylo.ink,
      );

  static TextStyle location(BuildContext context) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: context.skylo.ink,
      );

  static TextStyle condition(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: context.skylo.muted,
      );

  static TextStyle label(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: context.skylo.muted,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: context.skylo.ink,
      );

  static TextStyle tabular(BuildContext context) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        fontFeatures: [const FontFeature.tabularFigures()],
        color: context.skylo.ink,
      );

  static TextStyle degrees(BuildContext context) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: context.skylo.accent,
      );

  static TextStyle wordmark(BuildContext context) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 4,
        color: context.skylo.ink,
      );

  static TextStyle tagline(BuildContext context) => GoogleFonts.inter(
        fontSize: 10,
        letterSpacing: 3,
        fontWeight: FontWeight.w600,
        color: context.skylo.accent,
      );

  static TextStyle button(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );
}
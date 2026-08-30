import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

const _kThemeModeKey = 'skylo.themeMode';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.watch(sharedPreferencesProvider))..load(),
);

/// The effective dark/light state, resolving ThemeMode.system against the
/// platform brightness. All UI branches on this, never the raw enum.
bool isEffectiveDark(ThemeMode mode) {
  final platformDark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
  return switch (mode) {
        ThemeMode.dark => true,
        ThemeMode.light => false,
        ThemeMode.system => platformDark,
      };
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferencesAsync _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.light);

  Future<void> load() async {
    final stored = await _prefs.getString(_kThemeModeKey);
    state = switch (stored) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> toggle() => set(switch (state) {
        ThemeMode.dark => ThemeMode.light,
        _ => ThemeMode.dark,
      });

  /// Ink-reveal transition: expands a circle of the new surface color
  /// from [originContext]'s position, swaps the theme beneath at 340ms,
  /// then fades the mask. Falls back to an instant swap with no overlay.
  Future<void> toggleWithReveal(BuildContext originContext) async {
    final toDark = !isEffectiveDark(state);

    final box = originContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(originContext, rootOverlay: true);
    final overlayBox =
        overlay?.context.findRenderObject() as RenderBox?;

    if (box == null || !box.attached || overlay == null || overlayBox == null) {
      await set(toDark ? ThemeMode.dark : ThemeMode.light);
      return;
    }

    final origin = box.localToGlobal(Offset.zero, ancestor: overlayBox) +
        Offset(box.size.width / 2, box.size.height / 2);

    final size = overlayBox.size;
    final dx = math.max(origin.dx, size.width - origin.dx);
    final dy = math.max(origin.dy, size.height - origin.dy);
    final radius = math.sqrt(dx * dx + dy * dy);

    final entry = OverlayEntry(
      builder: (_) => _RevealMask(
        origin: origin,
        radius: radius,
        toDark: toDark,
      ),
    );
    overlay.insert(entry);

    await Future<void>.delayed(const Duration(milliseconds: 340));
    await set(toDark ? ThemeMode.dark : ThemeMode.light);
    await Future<void>.delayed(const Duration(milliseconds: 260));
    entry.remove();
  }
}

class _RevealMask extends StatefulWidget {
  final Offset origin;
  final double radius;
  final bool toDark;

  const _RevealMask({
    required this.origin,
    required this.radius,
    required this.toDark,
  });

  @override
  State<_RevealMask> createState() => _RevealMaskState();
}

class _RevealMaskState extends State<_RevealMask>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expand;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _expand = Tween<double>(begin: 0, end: widget.radius).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.65, curve: Curves.easeOut)));
    _fade = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 1, curve: Curves.easeIn)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.toDark ? SkyloTheme.dark : SkyloTheme.light;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return FadeTransition(
            opacity: _fade,
            child: CustomPaint(
              painter: _RevealPainter(
                origin: widget.origin,
                radius: _expand.value,
                color: tokens.surface,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class _RevealPainter extends CustomPainter {
  final Offset origin;
  final double radius;
  final Color color;

  _RevealPainter({
    required this.origin,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    final paint = Paint()..color = color;
    canvas.drawCircle(origin, radius, paint);
  }

  @override
  bool shouldRepaint(_RevealPainter old) =>
      old.radius != radius || old.color != color;
}

/// Built once and cached — rebuilding ThemeData on every widget rebuild
/// forces the whole tree to re-inherit the theme and janks animations.
final cachedLightTheme = _buildTheme(SkyloTheme.light, Brightness.light);
final cachedDarkTheme = _buildTheme(SkyloTheme.dark, Brightness.dark);

ThemeData _buildTheme(SkyloTheme tokens, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: tokens.accent,
    surface: tokens.surface,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.surface,
    extensions: [tokens],
  );
}
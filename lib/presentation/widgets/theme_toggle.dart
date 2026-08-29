import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/presentation/providers/theme_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Circular ink-reveal theme transition: the new variant spreads from
/// this toggle's position. Tapping captures the origin in the root
/// overlay, expands a filled circle of the new surface color, then
/// commits the theme change underneath and fades the mask out.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

    return GestureDetector(
      onTap: () => _revealTransition(context, ref, !isDark),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? context.skylo.accent : context.skylo.hairline,
            width: 1,
          ),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
          size: 18,
          color: context.skylo.ink,
        ),
      ),
    );
  }

  Future<void> _revealTransition(
      BuildContext context, WidgetRef ref, bool toDark) async {
    final origin = _toggleOrigin(context);
    if (origin == null) {
      ref.read(themeModeProvider.notifier).toggle();
      return;
    }

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true)?.context.findRenderObject()
            as RenderBox?;
    if (overlay == null) {
      ref.read(themeModeProvider.notifier).toggle();
      return;
    }

    final size = overlay.size;
    final dx = math.max(origin.dx, size.width - origin.dx);
    final dy = math.max(origin.dy, size.height - origin.dy);
    final radius = math.sqrt(dx * dx + dy * dy);

    final overlayEntry = OverlayEntry(
      builder: (context) => _RevealMask(
        origin: origin,
        radius: radius,
        toDark: toDark,
      ),
    );

    Overlay.maybeOf(context, rootOverlay: true)?.insert(overlayEntry);

    // Let the circle finish expanding before swapping underneath.
    await Future<void>.delayed(const Duration(milliseconds: 340));
    ref.read(themeModeProvider.notifier).toggle();
    await Future<void>.delayed(const Duration(milliseconds: 260));
    overlayEntry.remove();
  }

  Offset? _toggleOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    final overlay =
        Overlay.maybeOf(context, rootOverlay: true)?.context.findRenderObject()
            as RenderBox?;
    if (overlay == null) return null;
    return box.localToGlobal(Offset.zero, ancestor: overlay) +
        Offset(box.size.width / 2, box.size.height / 2);
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
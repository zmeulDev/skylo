import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Hero temperature count-up: rolls from 0 to [temp] on load, and from the
/// previous value when it changes (e.g. place switch).
class CountUpTemp extends StatefulWidget {
  final double temp;
  final Object animateKey;
  final Duration duration;

  const CountUpTemp({
    super.key,
    required this.temp,
    required this.animateKey,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<CountUpTemp> createState() => _CountUpTempState();
}

class _CountUpTempState extends State<CountUpTemp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _from = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _animation = Tween<double>(begin: 0, end: widget.temp)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(CountUpTemp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animateKey != widget.animateKey ||
        oldWidget.temp != widget.temp) {
      _from = _animation.value;
      _animation = Tween<double>(begin: _from, end: widget.temp).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          _animation.value.round().toString(),
          style: GoogleFonts.inter(
            fontSize: 120,
            fontWeight: FontWeight.w200,
            letterSpacing: -6,
            height: 1.0,
            fontFeatures: [const FontFeature.tabularFigures()],
            color: context.skylo.ink,
          ),
        );
      },
    );
  }
}

/// 2px temp bar whose fill sweeps from 0 to the target fraction on load.
class SweepingTempBar extends StatefulWidget {
  final double fraction;
  final Object animateKey;
  final Duration duration;

  const SweepingTempBar({
    super.key,
    required this.fraction,
    required this.animateKey,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  State<SweepingTempBar> createState() => _SweepingTempBarState();
}

class _SweepingTempBarState extends State<SweepingTempBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    _animation = Tween<double>(begin: 0, end: widget.fraction)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(SweepingTempBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animateKey != widget.animateKey) {
      _animation = Tween<double>(begin: 0, end: widget.fraction).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: 2,
          color: context.skylo.hairline,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value.clamp(0.0, 1.0) == 0
                ? 0.0
                : _animation.value.clamp(0.0, 1.0),
            child: Container(color: context.skylo.ink),
          ),
        );
      },
    );
  }
}

/// Precipitation glyph pulse: opacity breathes 1.0 -> 0.55 -> 1.0 forever.
class PulsingGlyph extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PulsingGlyph({super.key, required this.child, this.enabled = true});

  @override
  State<PulsingGlyph> createState() => _PulsingGlyphState();
}

class _PulsingGlyphState extends State<PulsingGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulsingGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && oldWidget.enabled) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.55)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
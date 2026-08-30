import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Entrance animation: fade + 16px slide-up, delayed by [index] steps.
/// Restarts whenever [animateKey] changes (new place page, refresh).
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Object animateKey;
  final Duration stepDelay;
  final Duration duration;

  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.index,
    required this.animateKey,
    this.stepDelay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _startDelayed();
  }

  void _startDelayed() {
    final delay = widget.stepDelay * widget.index;
    if (delay == Duration.zero) {
      _controller.forward();
      return;
    }
    _delayTimer = Timer(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(StaggeredEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animateKey != widget.animateKey) {
      _delayTimer?.cancel();
      _startDelayed();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final slide =
            Offset(0, 16 * (1 - _animation.value));
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: slide,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Skeleton placeholder: hairline bars that pulse while data loads.
/// Same shape language as the loaded content — flat bars, no radius.
class SkeletonPulse extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;

  const SkeletonPulse({
    super.key,
    required this.width,
    required this.height,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final color = Color.lerp(
          context.skylo.hairline,
          context.skylo.muted.withValues(alpha: 0.25),
          t,
        )!;
        return Container(
          width: widget.width,
          height: widget.height,
          color: color,
        );
      },
    );
  }
}

/// Loading skeleton mirroring the home layout: hero block,
/// 8 hairline hourly rows, 5 daily rows.
class WeatherSkeleton extends StatelessWidget {
  const WeatherSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 700;
      final width = compact ? constraints.maxWidth : 680.0;
      return Center(
        child: SizedBox(
          width: width,
          child: ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
            ).add(EdgeInsets.fromLTRB(
                32, compact ? 48 : 72, 32, compact ? 48 : 96)),
            children: [
              // Header.
              SkeletonPulse(
                  width: 180 * (compact ? 0.8 : 1), height: 24),
              const SizedBox(height: 12),
              const SkeletonPulse(width: 140, height: 15),
              SizedBox(height: compact ? 56 : 88),
              // Hero temperature.
              SkeletonPulse(width: 160 * (compact ? 0.8 : 1), height: 96),
              const SizedBox(height: 8),
              const SkeletonPulse(width: 220, height: 16),
              SizedBox(height: compact ? 48 : 72),
              const _SectionSkeleton(rows: 8, rowHeight: 20, vertical: 10),
              SizedBox(height: compact ? 48 : 72),
              const _SectionSkeleton(rows: 5, rowHeight: 22, vertical: 12),
            ],
          ),
        ),
      );
    });
  }
}

class _SectionSkeleton extends StatelessWidget {
  final int rows;
  final double rowHeight;
  final double vertical;

  const _SectionSkeleton({
    required this.rows,
    required this.rowHeight,
    required this.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: vertical),
            child: Row(
              children: [
                SkeletonPulse(
                    width: 56, height: rowHeight * 0.8),
                const SizedBox(width: 16),
                Expanded(
                  child: SkeletonPulse(
                      width: double.infinity, height: rowHeight * 0.4),
                ),
                const SizedBox(width: 16),
                SkeletonPulse(width: 40, height: rowHeight * 0.8),
              ],
            ),
          ),
      ],
    );
  }
}
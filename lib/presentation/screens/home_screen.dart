import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:skylo/domain/entities/daily_forecast.dart';
import 'package:skylo/domain/entities/hourly_forecast.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/domain/entities/weather_entity.dart';
import 'package:skylo/domain/exceptions/location_permission_exception.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/providers/units_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';
import 'package:skylo/presentation/widgets/anim/entrance.dart';
import 'package:skylo/presentation/widgets/anim/motion.dart';
import 'package:skylo/presentation/widgets/day_detail_sheet.dart';
import 'package:skylo/presentation/widgets/place_tabs.dart';
import 'package:skylo/presentation/widgets/section_label.dart';
import 'package:skylo/presentation/widgets/theme_toggle.dart';
import 'package:skylo/presentation/widgets/weather_glyph.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(savedPlacesProvider);

    // Keep the page index valid when places change.
    if (_page >= places.length) {
      _page = places.length - 1;
    }

    return Scaffold(
      backgroundColor: context.skylo.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
              child: Row(
                children: [
                  Expanded(
                    child: PlaceTabs(
                      places: places,
                      index: _page.clamp(0, places.length - 1),
                      onTap: (i) {
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const ThemeToggle(),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: places.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      // Parallax: page shifts up to ±28px horizontally as it
                      // leaves/enters during a swipe.
                      double parallax = 0;
                      if (_pageController.position.haveDimensions) {
                        final page = _pageController.page ?? i.toDouble();
                      parallax = (i - page) * 28;
                    } else {
                      parallax = (i - _page) * 28.0;
                    }
                    return Transform.translate(
                      offset: Offset(parallax, 0),
                      child: child,
                    );
                  },
                  child: _PlacePage(place: places[i]),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PlacePage extends ConsumerWidget {
  final SavedPlace place;

  const _PlacePage({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(placeWeatherProvider(place));

    return weatherAsync.when(
      loading: () => const WeatherSkeleton(),
      error: (error, _) => _ErrorView(
        error: error,
        onRetry: () => ref.invalidate(placeWeatherProvider(place)),
      ),
      data: (weather) => _WeatherContent(
        weather: weather,
        place: place,
        onRemove: place.isCurrentLocation
            ? null
            : () => ref.read(savedPlacesProvider.notifier).remove(place.id),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherEntity weather;
  final SavedPlace place;
  final VoidCallback? onRemove;

  const _WeatherContent({
    required this.weather,
    required this.place,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // City-local "now" drives Today/Tomorrow labels and hour filtering.
    final cityNow = weather.localNow();
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
              StaggeredEntrance(
                animateKey: place.id,
                index: 0,
                child: _Header(weather: weather, place: place, onRemove: onRemove),
              ),
              SizedBox(height: compact ? 56 : 88),
              StaggeredEntrance(
                animateKey: place.id,
                index: 1,
                child: _CurrentBlock(weather: weather, animateKey: place.id),
              ),
              SizedBox(height: compact ? 48 : 72),
              StaggeredEntrance(
                animateKey: place.id,
                index: 2,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(text: 'Next 24 hours'),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              StaggeredEntrance(
                animateKey: place.id,
                index: 3,
                child: _HourlyTable(
                  hourly: weather.hourly,
                  animateKey: place.id,
                  localNow: cityNow,
                ),
              ),
              SizedBox(height: compact ? 48 : 72),
              StaggeredEntrance(
                animateKey: place.id,
                index: 4,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(text: '5-day outlook'),
                    SizedBox(height: 12),
                  ],
                ),
              ),
              StaggeredEntrance(
                animateKey: place.id,
                index: 5,
                child: _DailyTable(daily: weather.daily, localNow: cityNow),
              ),
              SizedBox(height: compact ? 32 : 56),
              StaggeredEntrance(
                animateKey: place.id,
                index: 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('KNOW YOUR SKY', style: AppText.tagline(context)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  final WeatherEntity weather;
  final SavedPlace place;
  final VoidCallback? onRemove;

  const _Header({
    required this.weather,
    required this.place,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // City-local time, not the viewer's.
    final now = weather.localNow();
    final title = weather.locationName.isEmpty ? place.label : weather.locationName;
    // Show the local clock for every saved city; only your own location
    // omits it (your clock is already in your pocket).
    final showClock = !place.isCurrentLocation;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.isCurrentLocation ? title : place.label,
                style: AppText.location(context),
              ),
              const SizedBox(height: 6),
              Text(
                '${DateFormat('EEEE, d MMMM').format(now)}'
                '${showClock ? ' · ${DateFormat('HH:mm').format(now)}' : ''}',
                style: AppText.condition(context).copyWith(fontSize: 15),
              ),
            ],
          ),
        ),
        if (onRemove != null)
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_outlined,
                size: 20, color: context.skylo.muted),
          ),
      ],
    );
  }
}

class _CurrentBlock extends ConsumerWidget {
  final WeatherEntity weather;
  final Object animateKey;

  const _CurrentBlock({required this.weather, required this.animateKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CountUpTemp(
              temp: units.convertTemp(weather.currentTemp),
              animateKey: animateKey,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Text(units.degreeLabel, style: AppText.degrees(context)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            WeatherGlyph(weatherCode: weather.weatherCode, size: 20),
            const SizedBox(width: 8),
            Text(
              weather.condition.toUpperCase(),
              style: AppText.tabular(context).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              'FEELS ${units.convertTemp(weather.feelsLikeTemp).round()}°',
              style: AppText.tabular(context).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
                color: context.skylo.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HourlyTable extends ConsumerWidget {
  final List<HourlyForecast> hourly;
  final Object animateKey;
  final DateTime localNow;

  const _HourlyTable({
    required this.hourly,
    required this.animateKey,
    required this.localNow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hourly.isEmpty) {
      return Text('No hourly data', style: AppText.body(context));
    }
    final units = ref.watch(unitsProvider);
    // Show the next 8 slots from the city's current time, not the viewer's.
    final cutoff = DateTime(
        localNow.year, localNow.month, localNow.day, localNow.hour);
    final rows = hourly.where((h) => !h.time.isBefore(cutoff)).take(8).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final minTemp = rows.map((r) => r.temp).reduce((a, b) => a < b ? a : b);
    final maxTemp = rows.map((r) => r.temp).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final h in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    DateFormat('HH:mm').format(h.time),
                    style: AppText.tabular(context)
                        .copyWith(color: context.skylo.muted),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: PulsingGlyph(
                    enabled: h.precipitationProbability >= 30,
                    child: WeatherGlyph(
                      weatherCode: h.weatherCode,
                      size: 18,
                      accent: h.precipitationProbability >= 30,
                    ),
                  ),
                ),
                Expanded(
                  child: SweepingTempBar(
                    fraction: _fraction(h.temp, minTemp, maxTemp),
                    animateKey: animateKey,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${units.convertTemp(h.temp).round()}°',
                    textAlign: TextAlign.right,
                    style: AppText.tabular(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  double _fraction(double temp, double minTemp, double maxTemp) {
    final range = (maxTemp - minTemp).clamp(1.0, double.infinity);
    final fraction = ((temp - minTemp) / range).clamp(0.0, 1.0);
    return fraction == 0 ? 0.03 : fraction;
  }
}

class _DailyTable extends ConsumerWidget {
  final List<DailyForecast> daily;
  final DateTime localNow;

  const _DailyTable({required this.daily, required this.localNow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (daily.isEmpty) {
      return Text('No daily data', style: AppText.body(context));
    }
    final units = ref.watch(unitsProvider);
    final today = localNow.day;
    return Column(
      children: [
        for (final day in daily)
          InkWell(
            onTap: () =>
                showDayDetailSheet(context, day, _dayLabel(day.date)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _dayLabel(day.date),
                      style: AppText.body(context).copyWith(
                        fontWeight:
                            day.date.day == today ? FontWeight.w700 : null,
                        color: day.date.day == today
                            ? context.skylo.accent
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: WeatherGlyph(
                      weatherCode: day.weatherCode,
                      size: 18,
                      accent: day.weatherCode >= 300 && day.weatherCode < 600,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${units.convertTemp(day.minTemp).round()}°',
                      textAlign: TextAlign.right,
                      style: AppText.tabular(context)
                          .copyWith(color: context.skylo.muted),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${units.convertTemp(day.maxTemp).round()}°',
                      textAlign: TextAlign.right,
                      style: AppText.tabular(context)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _dayLabel(DateTime date) {
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final diff = date.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEEE').format(date);
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isLocationError = error is LocationPermissionException;
    final isPermanentlyDenied =
        isLocationError && (error as LocationPermissionException).permanently;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isLocationError
                    ? (isPermanentlyDenied
                        ? Icons.location_off_outlined
                        : Icons.location_on_outlined)
                    : Icons.wifi_off_outlined,
                color: context.skylo.ink,
                size: 40,
              ),
              const SizedBox(height: 24),
              Text(
                isLocationError ? 'Location unavailable' : 'Weather unavailable',
                style: AppText.location(context).copyWith(fontSize: 20),
              ),
              const SizedBox(height: 12),
              Text(error.toString(), style: AppText.condition(context)),
              const SizedBox(height: 32),
              isPermanentlyDenied
                  ? TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: context.skylo.ink,
                        foregroundColor: context.skylo.surface,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      onPressed: () => Geolocator.openLocationSettings(),
                      child: Text(
                        'Open System Settings'.toUpperCase(),
                        style: AppText.button(context),
                      ),
                    )
                  : TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: context.skylo.accent,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                      onPressed: onRetry,
                      child: Text('RETRY'.toUpperCase(),
                          style: AppText.button(context)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
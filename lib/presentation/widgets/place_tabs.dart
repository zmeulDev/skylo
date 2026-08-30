import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/l10n/app_localizations.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';
import 'package:skylo/presentation/widgets/anim/entrance.dart';

/// Minimal place tabs: ALL CAPS labels, active in ink, inactive in muted.
/// The 2px red underline physically slides between tabs.
class PlaceTabs extends StatefulWidget {
  final List<SavedPlace> places;
  final int index;
  final ValueChanged<int> onTap;

  const PlaceTabs({
    super.key,
    required this.places,
    required this.index,
    required this.onTap,
  });

  @override
  State<PlaceTabs> createState() => _PlaceTabsState();
}

class _PlaceTabsState extends State<PlaceTabs> {
  final Map<int, GlobalKey> _keys = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(PlaceTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _scheduleEnsureVisible();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleEnsureVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _keys[widget.index];
      final ctx = key?.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Measure tab widths so the indicator can slide between them.
          final widths = <int, double>{};
          for (var i = 0; i < widget.places.length + 1; i++) {
            final key = _keys.putIfAbsent(i, () => GlobalKey());
            final ctx = key.currentContext;
            var w = 60.0;
            if (ctx != null) {
              final box = ctx.findRenderObject() as RenderBox?;
              if (box != null && box.hasSize) w = box.size.width;
            }
            widths[i] = w;
          }
          // Left offset of the active tab's indicator, minus scroll.
          final scrollOffset = _scrollController.hasClients
              ? _scrollController.offset
              : 0.0;
          var activeLeft = 0.0;
          var activeWidth = 0.0;
          var seen = 0.0;
          for (var i = 0; i < widths.length; i++) {
            if (i == widget.index) {
              activeLeft = seen - scrollOffset;
              activeWidth = widths[i]!;
              break;
            }
            seen += widths[i]! + 28;
          }
          return ClipRect(
            child: Stack(
              children: [
                ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.places.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 28),
                  itemBuilder: (context, i) {
                    if (i == widget.places.length) {
                      return _AddTab(key: _keys[i]);
                    }
                    final place = widget.places[i];
                    final active = i == widget.index;
                    return _Tab(
                      key: _keys[i],
                      label: (place.isCurrentLocation
                              ? AppLocalizations.of(context)!.currentLocation
                              : place.label)
                          .toUpperCase(),
                      active: active,
                      onTap: () => widget.onTap(i),
                    );
                  },
                ),
                Positioned(
                  left: activeLeft,
                  width: activeWidth,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.center,
                    height: 2,
                    child: Container(
                        width: 24, color: context.skylo.accent),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppText.label(context).copyWith(
              fontSize: 13,
              letterSpacing: 1.2,
              color: active ? context.skylo.ink : context.skylo.muted,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(width: 24, height: 2, color: Colors.transparent),
        ],
      ),
    );
  }
}

class _AddTab extends StatelessWidget {
  const _AddTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showAddPlaceSheet(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 16, color: context.skylo.muted),
          const SizedBox(height: 6),
          Container(width: 24, height: 2, color: Colors.transparent),
        ],
      ),
    );
  }
}

Future<void> showAddPlaceSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.skylo.surface,
    barrierColor: context.skylo.ink.withValues(alpha: 0.4),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (_) => const _AddPlaceSheet(),
  );
}

class _AddPlaceSheet extends ConsumerStatefulWidget {
  const _AddPlaceSheet();

  @override
  ConsumerState<_AddPlaceSheet> createState() => _AddPlaceSheetState();
}

class _AddPlaceSheetState extends ConsumerState<_AddPlaceSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom +
                MediaQuery.viewPaddingOf(context).bottom,
          ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                    width: 3, height: 14, color: context.skylo.accent),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.addAPlace,
                    style: AppText.label(context)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: AppText.location(context).copyWith(fontSize: 20),
              cursorColor: context.skylo.accent,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchCity,
                hintStyle: AppText.condition(context),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.skylo.hairline),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: context.skylo.accent, width: 2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Flexible(child: _Results(query: _controller.text)),
          ],
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  final String query;

  const _Results({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.trim().length < 2) {
      return const SizedBox.shrink();
    }
    final results = ref.watch(citySearchProvider(query));
    return results.when(
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 24),
        // Skeleton rows — hairline bars pulsing, no spinners (DESIGN.md §6).
        child: Column(
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(child: SkeletonPulse(width: double.infinity, height: 16)),
                    const SizedBox(width: 16),
                    const SkeletonPulse(width: 32, height: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(AppLocalizations.of(context)!.searchFailed,
            style: AppText.condition(context)),
      ),
      data: (list) => list.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(AppLocalizations.of(context)!.noPlacesFound,
                  style: AppText.condition(context)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  for (final result in list)
                    InkWell(
                      onTap: () {
                        ref.read(savedPlacesProvider.notifier).add(SavedPlace(
                              id:
                                  '${result.lat.toStringAsFixed(4)},${result.lon.toStringAsFixed(4)}',
                              name: result.name,
                              state: result.state,
                              country: result.country,
                              lat: result.lat,
                              lon: result.lon,
                            ));
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                result.label,
                                style: AppText.body(context),
                              ),
                            ),
                            Icon(Icons.add,
                                size: 16, color: context.skylo.muted),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
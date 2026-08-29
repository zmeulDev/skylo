import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skylo/domain/entities/saved_place.dart';
import 'package:skylo/presentation/providers/saved_places_providers.dart';
import 'package:skylo/presentation/theme/app_theme.dart';

/// Minimal place tabs: ALL CAPS labels, active in ink with red underline,
/// inactive in muted. Underline is 2px, 24px wide.
class PlaceTabs extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: places.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 28),
        itemBuilder: (context, i) {
          if (i == places.length) return const _AddTab();
          final place = places[i];
          final active = i == index;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTap(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  place.label.toUpperCase(),
                  style: AppText.label(context).copyWith(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: active ? context.skylo.ink : context.skylo.muted,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 24,
                  height: 2,
                  color: active ? context.skylo.accent : Colors.transparent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddTab extends StatelessWidget {
  const _AddTab();

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
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                Text('ADD A PLACE', style: AppText.label(context)),
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
                hintText: 'Search city',
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
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.skylo.accent,
            backgroundColor: context.skylo.hairline,
          ),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text('Search failed. Check your connection.',
            style: AppText.condition(context)),
      ),
      data: (list) => list.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('No places found.',
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
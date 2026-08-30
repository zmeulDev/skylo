# Skylo — Design & Product Notes (living document)

Accumulated user feedback and decisions from real-world testing, for future
Skylo work and for the trip app. Update as new findings come in.

## Verified user preferences (2026-08-30, Samsung SM-S938B real-device test)

- **Settings sheet pattern approved**: moving theme + units out of the header
  into a bottom-sheet ("SETTINGS", two rows: Theme, Units) got explicit
  approval ("great job, i like this a lot"). Header stays minimal: tabs +
  one 40px gear button only. Reuse this pattern for any future settings.
- Sheet rows: icon + title left, ALL CAPS state label right (LIGHT/DARK,
  °C/°F) in muted. Ink-reveal for theme runs from the tapped row's origin
  AFTER the sheet closes (overlay survives route pop).
- Minimal Swiss editorial aesthetic is confirmed as the brand. User rejected
  the first icon ("looks like a snake game from old Nokia phones") but kept
  the concept; approved "sun over horizon" mark: red disc + two ink strata
  bars on near-black. Keep this shape language for any future Skylo-family
  branding.

## Hard-won technical lessons

- **Android animation scale**: real device had all three OS animation scales
  at 0.0 (Power Saving / accessibility "Remove animations") — every app
  animation snapped instantly and looked "broken" while iOS sim was fine.
  Diagnose with:
  `adb shell settings get global animator_duration_scale`
  Fix: set all three to 1.0. Before blaming app code on Android, check this
  first. Samsung battery saver re-disables animations when it engages.
- **ThemeMode.system trap**: any toggle must resolve `system` against
  platform brightness before branching (`isEffectiveDark` in
  theme_providers.dart). Comparing raw enum values causes first-run no-ops.
- **ThemeData must be cached** (built once): rebuilding it per widget rebuild
  re-inherits the theme across the whole tree and janks all animations.
- **Fast location**: always try `getLastKnownPosition()` FIRST (instant),
  fresh GPS fix only on cold start. Fresh-first caused a 20s blank load
  indoors after permission grant.
- **macOS TCC quirk**: granting location while a request is in flight
  returns "denied" for THAT request; the grant applies to subsequent ones.
  Retry works. Also: stale queued prompts wedge `requestPermission()`
  forever — restart the app (tccutil reset if needed).
- **Text wrap in fixed columns**: percent columns need FittedBox
  scale-down + a few extra px ("100%" wrapped at 44px, fine at 48).
- **flutter_launcher_icons** is the reliable way to ship icons; manual
  Xcode asset-slot copies can silently lose against cached Assets.car.
  Source PNGs live in assets/icon/; regenerate with
  `flutter pub run flutter_launcher_icons`.
- **Bundle IDs**: keep com.zmeul.skylo in sync across iOS pbxproj, Android
  build.gradle.kts (namespace + applicationId), and MainActivity.kt package
  path. A mismatch = monkey launcher "No activities found".

## Open items / future ideas (from testing backlog)

- Auto-retry once after a location permission denial that follows a grant
  (the macOS/iOS stale-denial case) instead of showing the error card.
- Consider Isar for offline caching of weather + saved places (original
  spec called for it; SharedPreferences JSON works but won't scale to
  heavy per-day data).
- WeatherKit datasource for iOS/macOS (original spec) — currently everything
  uses free OWM 2.5.
- Rename `ThemeToggle` widget to `SettingsButton` for clarity (kept old
  name during refactor to avoid churn).
- Dock badge: could add city name or condition glyph variant later.

## Trip app carry-over (see TRIP_APP_PROMPT.md)

- The settings-sheet pattern and all lessons above apply verbatim to the
  trip app spec; update its prompt with the sheet pattern when starting it.
- User's real devices for testing: Samsung SM-S938B (Android 16, RZGYB1E58CV),
  iPhone 17 simulator (iOS 26.5), macOS. ADB at
  /Users/zml-m4/Library/Android/sdk/platform-tools/adb (not on PATH).
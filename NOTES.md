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
- **OWM city names are coarse**: the 2.5 weather response's `name` snaps
  villages to nearby towns in OWM's index (Jucu de Sus read as "Apahida"
  while the GPS fix was correct — Google Maps knew the village). Fix:
  resolve the current-location name with the platform geocoder
  (`geocoding` package: Android Geocoder / Apple CLGeocoder, same data
  Google Maps uses) in `platform_geocoder.dart`, override OWM's name only
  when they disagree. Geocoding plugin v5 is instance-based
  (`Geocoding().placemarkFromCoordinates`), no top-level functions.

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

## Alert notifications (2026-09-01, Samsung SM-S938B real-device test)

**Architecture (verified working end-to-end on device):**
- `AlertEvaluator` (unchanged, pure) → `AlertDelivery` (lib/domain/services/alert_delivery.dart):
  fetch → evaluate → dedup (`AlertDeliveryStore`, key = place+kind+place-local day,
  severe upgrades re-deliver) → `NotificationService` (lib/data/datasources/notification_service.dart).
- Two channels: `skylo_alerts_severe` (Importance.max, sound+vibration, heads-up,
  category=alarm, red `0xffe4002b`) and `skylo_alerts_watch` (silent, importance default).
  Verified on device: heads-up + EdgeLighting + vibration fire for severe; watch is silent.
- Foreground: `alertDeliveryCoordinatorProvider` listens to each place's
  `placeAlertsProvider` — zero extra fetches; delivery rides the existing refresh cycle.
- Background: `workmanager` periodic task (6h, network constraint) via
  `scheduleBackgroundAlertCheck()`; iOS uses BGAppRefreshTask (system cadence).
  Turned ON from the settings sheet toggles: permission request + schedule.
- Tap a notification → HomeScreen's PageController animates to that place's page.

**Hard-won technical lessons (this session):**
- **flutter_local_notifications 22.x requires core library desugaring** on Android:
  `isCoreLibraryDesugaringEnabled = true` + `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")`
  in android/app/build.gradle.kts. Build fails with CheckAarMetadata otherwise.
- **workmanager plugin delays forced runs**: `cmd jobscheduler run -f` triggers the job,
  but the plugin's BackgroundWorker sees "executed before schedule" and re-enqueues
  instead of running (WM-WorkerWrapper log). Deterministic background testing needs a
  **one-off debug task** (`registerOneOffTask` with short initialDelay) —
  `scheduleDebugOneOffCheck()` in background_alerts.dart, wired to the settings-sheet
  TEST NOTIFICATIONS row behind `SKYLO_DEBUG_NOTIFICATIONS=true` in .env.
- **Force-stop wipes WorkManager jobs** (Android behavior): after `am force-stop`,
  the periodic job disappears from `dumpsys jobscheduler` until the app launches again.
  Background the app with HOME for realistic testing, never force-stop.
- **Finding the live job id**: `dumpsys jobscheduler | grep BackgroundWorker` —
  run with `cmd jobscheduler run -f -n androidx.work.systemjobscheduler com.zmeul.skylo <id>`.
- **Background GPS is denied to backgrounded apps** (no foreground service): the
  current-location place's fresh fix times out (~20s, LocationService's internal
  timeout) in the background isolate; delivery catches it per-place and continues
  with saved places. Last-known shortcut still applies when a fix exists. This is
  why the per-place timeout + "never throw" contract matters.
- **Background isolate runs in a separate process** (different pid than the UI app):
  SharedPreferences state is shared (that's how alertsEnabled is read without
  Riverpod), but nothing else — no providers, no singletons. Keep the background
  path fully self-constructing (see `_runAlertCheck`).
- **Dart MCP server** is built into the SDK: `dart mcp-server` (needs Dart 3.9+).
  Configured in opencode.json as a local MCP server; requires opencode restart to
  activate. Gives launch_app/hot_reload/flutter_driver_command/run_tests tools.
- **Samsung-specific**: notifications trigger EdgeLighting + notification-history
  auto-grouping (Aggregate_ summary) for the watch channel; the severe channel's
  category=alarm earns heads-up even from the cold isolate.
- adb UI driving for Flutter (no test framework): `uiautomator dump` + tap bounds —
  Flutter views expose content-desc/text on semantic nodes; worked to open the
  settings sheet and tap TEST NOTIFICATIONS programmatically.

**Verified on device (SM-S938B, Android 16):**
- POST_NOTIFICATIONS runtime grant: granted=true
- Both channels created with correct importance; severe fires heads-up with
  vibration + EdgeLighting (log-verified `mIsInterruptive=true`)
- Cold-isolate background run: workmanager SUCCESS, prefs read, pipeline ran,
  notification posted with app closed (marker id 900010, severe channel)
- In-app alert banner shows live evaluated alerts localized (e.g. "CANICULĂ —
  mâine 15:00 — 28°") with alerts ON from settings
- Dedup verified by unit tests (alert_delivery_store_test.dart, 6 tests) and
  delivery title/dedup path (alert_delivery_test.dart, 5 tests); 48 tests green

## Trip app carry-over (see TRIP_APP_PROMPT.md)


- The settings-sheet pattern and all lessons above apply verbatim to the
  trip app spec; update its prompt with the sheet pattern when starting it.
- User's real devices for testing: Samsung SM-S938B (Android 16, RZGYB1E58CV),
  iPhone 17 simulator (iOS 26.5), macOS. ADB at
  /Users/zml-m4/Library/Android/sdk/platform-tools/adb (not on PATH).

## Home-screen widgets (2026-09-01)

**Platform floors (user decision):** iOS 26+, Android 16 (API 36)+ only.
`minSdk = 36` in android/app/build.gradle.kts,
`IPHONEOS_DEPLOYMENT_TARGET = 26.0` in all six pbxproj configs +
`MinimumOSVersion 26.0` in ios/Flutter/AppFrameworkInfo.plist (drives the
generated SwiftPackage's platform; without it SPM pins `.iOS("13.0")` and
Target Integrity fails with home-widget/workmanager needing 14.0).

**Architecture (snapshot pre-rendering, "dumb view" native widgets):**
- Dart pre-renders EVERYTHING into display strings — localized, unit-converted,
  rounded, tabular-safe — into the home_widget plugin's shared store
  (lib/data/models/widget_snapshot.dart is pure & unit-tested; the store in
  lib/data/datasources/widget_snapshot_store.dart is a thin I/O wrapper).
  Native widgets do zero business logic, zero localization, zero font-loading
  logic beyond a bundled Inter on Android.
- Widget mirrors the LAST-VIEWED place (HomeScreen page) via
  currentViewedPlaceProvider; coordinator widget rides existing providers
  (dock-badge pattern), republishes on weather refresh + units/locale change.
- Keys: `skylo.widget.*` (placeName, temp, tempUnit, feelsLike, condition,
  weatherCode, h0-3 time/temp/code, d0-4 label/min/max/code).
- Refresh cadence: app open + every weather refresh; native refresh policies
  just re-read the store (no widget-side networking, by design).
- Android: ONE resizable provider (SkyloWidgetProvider) with three layouts
  picked by width in onAppWidgetOptionsChanged (small <160dp, medium <240dp,
  large). Inter bundled as res/font (latin subsets, tnum verified in the
  ttf). Glyphs = real Material Symbols outlined paths extracted from the
  MaterialIconsOutlined-Regular.otf (512-unit viewport vector drawables);
  precip codes earn accent. values-night has the dark token variant —
  widgets follow the SYSTEM theme, not the in-app themeMode (native convention).
- iOS: WidgetKit extension target `SkyloWidgetExtension` (com.zmeul.skylo.
  SkyloWidgetExtension), kind `SkyloWidget`, 3 families (small/medium/large).
  Reads group.com.zmeul.skylo UserDefaults (App Group entitlements on BOTH
  Runner and the appex — ios/Runner/SkyloApp.entitlements +
  SkyloWidgetExtension.entitlements). SF symbols for glyphs, colorScheme
  resolves light/dark tokens. Tap → `skylo://widget?homeWidget` URL scheme
  (registered in Runner Info.plist; home_widget routes it).
- Device testing TODO (next session on the real devices): pin widget on
  SM-S938B (resize through all 3 tiers), add to iPhone home screen, verify
  snapshot appears after first app open, verify tap-through, verify dark mode
  variant, verify °F switch + language switch repaint the widget.

**Hard-won technical lessons (this session):**
- **pbxproj by hand**: valid 24-char HEX IDs only (Xcode tolerates junk chars
  but graders/tools may not); extension target needs: PBXNativeTarget,
  PBXContainerItemProxy + PBXTargetDependency (Runner depends on it),
  Embed App Extensions phase (dstSubfolderSpec = 13) on Runner, config list,
  TargetAttributes entry, and the target added to the targets list. `plutil
  -lint` catches syntax; `xcodebuild -list` catches structure.
- **Embed phase order matters**: "Embed App Extensions" must run BEFORE
  "Thin Binary" (xcode_backend embed_and_thin) or Xcode reports a build cycle
  (both produce into Runner.app).
- **GENERATE_INFOPLIST_FILE + Info.plist in a Resources phase = "multiple
  commands produce Info.plist"** — the plist belongs in INFOPLIST_FILE build
  setting only, never in Resources.
- **SPM deployment-target chain**: AppFrameworkInfo.plist MinimumOSVersion →
  generated FlutterGeneratedPluginSwiftPackage `.iOS("x")`; flutter's
  `updateMinimumDeployment` bumps the generated package only when the
  xcodebuild-resolved project target is HIGHER than the default — and
  build-settings are cached per context, so a clean may be needed after
  bumping. Symptom if stale: "requires minimum platform version 14.0 ... but
  this target supports 13.0" even with 26.0 in the pbxproj.
- **intl in pure Dart tests**: DateFormat.E(locale) throws
  LocaleDataException unless `initializeDateFormatting()` ran (the app gets
  it free from flutter_localizations delegates). In widget/none tests, call
  it in setUpAll.
- **Real "now" in renderers**: anything deriving from DateTime.now() (hourly
  cutoffs, Today labels) needs an injectable now or tests break at
  different times of day. renderWidgetSnapshot takes nowUtc.
- **home_widget 0.9.3 API**: Android prefs live in "HomeWidgetPreferences"
  (HomeWidgetPlugin.getData(context)); iOS in UserDefaults(suiteName:).
  updateWidget(androidName: 'SkyloWidgetProvider', iOSName: 'SkyloWidget') —
  Android name is the class WITHOUT package prefix; iOSName must equal the
  Widget kind string.
- **Android RemoteViews tinting**: no clean way to call setColorFilter(null)
  via RemoteViews — ship separate drawable variants instead when a glyph
  needs conditional tinting.
- **Vector drawable from Material font**: MaterialIconsOutlined-Regular.otf
  glyphs are 512 unitsPerEm — extract per-icon path with fontTools
  (SVGPathPen) and keep viewport 512; scale via android:width/height in dp.
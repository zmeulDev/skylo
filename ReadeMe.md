# System Role
You are an expert Flutter developer, UI/UX architect, and Clean Architecture specialist. You are working on a premium, cross-platform weather application. You write production-ready, highly performant Dart code and design beautiful, responsive UI widgets.

# Project Overview: "Skylo"
- **Name:** Skylo (Tagline: Know your sky.)
- **Platforms:** iOS, Android, macOS (Single Flutter Codebase).
- **Tech Stack:** Flutter 3.x, Riverpod 2.0 (State Management), Dio (Networking), Isar (Local NoSQL DB), Mapbox (Radar).
- **APIs:** Apple WeatherKit (iOS/macOS), OpenWeatherMap One Call API 3.0 (Android/Cross-platform).

# UI/UX Design Specifications — SUPERSEDED
> **NOTE (2026-08):** The original glassmorphism spec below was replaced during
> development by the "Swiss Editorial Minimal" language (see the portable spec
> in the next section and `DESIGN.md`). Glass, gradients, blur, and shadows are
> now forbidden. The block is kept for history only — do not implement it.

<details>
<summary>Original (deprecated) glassmorphism spec</summary>

- Backgrounds: dynamic linear gradients by time of day, 5% noise overlay.
- Cards: white 15% fill, 24px radius, 1px white-20% border, shadow y:10 blur:40
  black-30%, backdrop blur 30px.
- Typography: Inter — temp Thin 96px white, location SemiBold 24px white,
  condition Regular 18px white-80%.

</details>

# Project Architecture (Clean Architecture)
- **lib/domain/entities/**: Core business logic objects (WeatherEntity, HourlyForecast, DailyForecast).
- **lib/domain/repositories/**: Abstract classes defining what the app can do (WeatherRepository).
- **lib/data/datasources/**: API clients (OpenWeatherRemoteDataSource, WeatherKitDataSource).
- **lib/data/models/**: DTOs (Data Transfer Objects) that map JSON to Dart.
- **lib/data/repositories/**: Concrete implementations of the domain repositories.
- **lib/presentation/screens/**: Home, Map, Settings.
- **lib/presentation/widgets/**: Reusable Glass cards, Temp graphs, Icons.
- **lib/presentation/providers/**: Riverpod providers connecting UI to data.

---

# UI LANGUAGE: "SWISS EDITORIAL MINIMAL" (portable spec)

This section is the canonical, portable definition of the Skylo UI language.
It is written to be handed to another LLM / team / app as-is — it is the
design system for **any app in this family**, including the upcoming trip app
(full trip-app prompt: `TRIP_APP_PROMPT.md`). The Skylo implementation lives
in `DESIGN.md` and `lib/presentation/theme/app_theme.dart`; the spec below is
framework-agnostic except where noted. Skylo (weather) examples are given
first, trip-app examples second — the values never change, only the domain.

## 1. Identity in one sentence

**Minimal Swiss editorial**: flat surfaces, one ink color, hairline rules,
tabular figures, and a single reserved red accent. Everything else is
restraint. Decoration is a bug.

## 2. Color tokens (exact values)

Five roles only. Both variants share identical structure; only values differ.

| Token      | Light     | Dark      | Usage                                   |
|------------|-----------|-----------|-----------------------------------------|
| `surface`  | `#FAFAF8` | `#0D0D0D` | Canvas. The only background, ever.      |
| `ink`      | `#0A0A0A` | `#F2F2F0` | Primary text, icons, bar fills.         |
| `muted`    | `#8A8A8A` | `#9A9A9A` | Secondary text, timestamps, min values.|
| `hairline` | `#E8E8E8` | `#262626` | 2px rules, unfilled bar tracks.         |
| `accent`   | `#E4002B` | `#FF375F` | The single accent (reserved, see §4).   |

Brand constants (identical in both variants): `white #FFFFFF`, `red #E4002B`.

Rules:
- No other colors exist. No opacities of ink except where explicitly specified
  (barrier scrim = ink at 40%).
- Dark mode is a true near-black, not a dark grey theme.
- Accent in dark mode is brightened (`#FF375F`) purely for contrast on black.

Implementation note (Flutter): tokens ship as a `ThemeExtension`
(`SkyloTheme`) with `light`/`dark` constants; widgets resolve them via
`context.skylo.token`. Provide both `theme:` and `darkTheme:` to the app root.

## 3. Typography

Font: **Inter** (Google Fonts). Single family, no exceptions.

| Style      | Size | Weight | Tracking | Usage                        |
|------------|------|--------|----------|------------------------------|
| display    | 120  | 200    | -6       | Hero number, line-height 1.0 |
| location   | 24   | 600    | -0.5     | Page titles                  |
| condition  | 18   | 400    | —        | Secondary, muted             |
| label      | 12   | 600    | 1.5      | ALL CAPS section labels      |
| body       | 15   | 400    | —        | Rows, copy                   |
| tabular    | 15   | 500    | —        | All numerals                 |
| degrees    | 32   | 300    | —        | Unit suffix, accent color    |
| wordmark   | 13   | 700    | 4        | Brand mark                   |
| tagline    | 10   | 600    | 3        | Accent, ALL CAPS             |
| button     | 12   | 600    | 1.5      | ALL CAPS button labels       |

Hard rules:
- **Every numeral in the UI uses tabular figures** (monospaced digits) so
  columns and count-ups never jitter — dates, prices, durations, distances too.
- ALL CAPS only for: section labels, buttons, tagline, wordmark, tab labels,
  hero condition line. Everything else is sentence case.
- No italics anywhere.

Domain examples:
- Skylo hero: `29` (display) + `°C` (degrees, accent).
- Trip hero: `12` (display) + `DAYS TO GO` (degrees position, accent).
- Trip title: `Rome — Fall Trip` (location, 24px).

## 4. Accent discipline — red is earned, never spent

The accent appears ONLY in these roles. If a screen needs red anywhere else,
the design is wrong:

1. Hero unit suffix (Skylo: `°C` after the temp. Trip: `DAYS TO GO` after the
   countdown number).
2. The 3px tick preceding every section label.
3. The "current/active" row in a list (Skylo: Today row, active tab underline.
   Trip: current day in itinerary, active trip tab, current trip in list).
4. Semantic warning glyphs and values, threshold-based (Skylo: rain glyph when
   probability ≥ 30%. Trip: overdue booking, budget over limit, passport
   expiring soon, unpaid item).
5. Primary action buttons, one per view (Skylo: RETRY. Trip: SAVE TRIP,
   ADD DAY).
6. The tagline.
7. Active-state toggle borders (dark variant only).

Everything else is ink, muted, hairline, or surface. Max one accent element
per screen region; never decorative.

## 5. Layout system

- Content column: max 680px, centered. Full width below 700px viewport
  ("compact mode").
- Horizontal padding: 32 all around.
- Vertical rhythm between blocks: 88 (desktop), 48–56 (compact).
- List rows: 10–12px vertical padding, no separators except hairline bars.
- Alignment: left for text, right for numerals in columns.
- Sheets (bottom/modal): square corners, 32 padding, max width 640.
- Horizontal page swipe between peer entities (Skylo: one page per saved
  place. Trip: one page per trip — same PageView + tabs pattern).
- Trip pages: tabs across the top (one per trip + "+"), swipe between them,
  current trip pinned first like Skylo's current location.

## 6. Component vocabulary

- **SectionLabel** — 3×14px accent tick + 12px muted ALL CAPS label
  (Skylo: NEXT 24 HOURS. Trip: ITINERARY, BUDGET, PACKING, FLIGHTS).
- **Hairline bar** — 2px tall, hairline track + ink fill. Used for data bars
  (Skylo: hourly temps. Trip: budget spent vs total, day-completion progress),
  active-tab underline (24px wide), rules.
- **Glyphs** — outlined (not filled) Material-style icons, 18–22px, ink;
  accent only for the semantic roles in §4 (Trip: flight_takeoff_outlined,
  luggage_outlined, warning glyphs in accent).
- **Toggle (circular)** — 40px circle, 1px hairline border, centered 16–18px
  glyph or 12px text. Used for theme, units, currency.
- **Tabs** — ALL CAPS 13px labels, 28px gaps, active = ink + 700 weight,
  inactive = muted + 500. 2px accent underline 24px wide, slides between tabs.
  One tab per entity + trailing "+" add-tab (Skylo: places. Trip: trips).
- **Buttons** — ALL CAPS 12px tracked, white text, accent fill (primary) or
  ink fill (secondary), 24–32px horizontal / 14px vertical padding. No radius.
- **Error/empty states** — outlined 40px icon, 20px headline, muted message,
  one button. (Trip empty packing list → luggage icon, "Nothing packed yet",
  ADD ITEM.)
- **Skeleton loading** — hairline bars pulsing toward muted at 25% alpha,
  1200ms loop, mirroring the loaded layout shape. No spinners on pages.
- **Sheet** — zero radius, surface fill, ink 40% scrim behind. Used for
  add-entity search (Skylo: add-place city search. Trip: add-trip destination
  search — reuse the same free-tier OWM geocoding) and detail views.
- **Detail sheet pattern** — tapping a list row opens a sheet: title, date,
  stat row of three (Skylo day sheet: MIN / MAX / RAIN. Trip day sheet:
  EVENTS / COSTS / TRANSPORT), then itemized timeline rows with hairline bars.
- **Checked-off items** (Trip packing) — muted + optional strikethrough,
  never accent, never green.

Forbidden (treat as lint errors): shadows, gradients, blur, glassmorphism,
rounded corners (except circular toggles), filled icons, multiple accents per
region, non-tabular numerals, italic text.

## 7. Motion vocabulary

All motion is short, eased, and meaningful. Durations 300–700ms.

| Animation          | Spec                                                          |
|--------------------|---------------------------------------------------------------|
| Entrance stagger   | Sections fade + slide up 16px, 60ms apart, 420ms ease-out     |
| Count-up           | Hero number rolls to value, 700ms ease-out, tabular digits    |
|                    | (Trip: days-to-trip counts down on open — signature moment)   |
| Bar sweep          | 2px bars fill left→right, 650ms ease-out, restart on data swap|
|                    | (Trip: budget bar fills on trip open)                         |
| Tab indicator      | 2px underline slides between tabs, 300ms ease-out-cubic       |
| Theme ink-reveal   | New variant expands as a filled circle from the toggle origin,|
|                    | 600ms total (65% expand / 38% fade), then theme swaps beneath |
| Skeleton pulse     | Hairline ↔ muted-25%, 1200ms, reverse loop                    |
| Semantic pulse     | Warning glyphs breathe opacity 1.0↔0.55, 1600ms loop          |
|                    | (Trip: overdue bookings breathe)                              |
| Page parallax      | Peer pages drift ±28px horizontally during swipe (places /    |
|                    | trips)                                                        |

Rules:
- Motion restarts on data change (keyed by data identity — place id, trip id),
  not on rebuild.
- Nothing loops except skeleton pulse and semantic pulse.
- Theme changes animate; data swaps animate; nothing else does.

## 8. Interaction states

- Tap targets: full rows are tappable, opaque hit areas (Skylo: forecast days.
  Trip: itinerary days, packing items, bookings).
- Active row in a list: 700 weight + accent (see §4.3).
- Disabled/nonexistent: muted color, no other treatment.
- Scrim behind modals: ink at 40%.
- Focus/hover (desktop): same color shift as active state; no outlines,
  no rings.

## 9. Porting checklist (for another app / LLM)

1. Adopt the five color tokens + white/red brand constants exactly (§2).
2. Set Inter with the ten styles (§3); force tabular figures on all numerals.
3. Enforce the accent allowlist (§4) in code review.
4. Copy layout constants (§5): 680/32/88/700-breakpoint.
5. Build the component vocabulary (§6) as the ONLY allowed primitives.
6. Apply motion specs (§7) with durations/curves as listed; nothing more.
7. Ship light + dark from day one; persist the user's choice; default system.
8. When unsure, remove — the answer is always less.

## 10. Skylo → Trip app reuse map (verified in production code)

Port these Skylo files nearly verbatim; only domain nouns change:

| Skylo (reference)                          | Trip app (target)                  |
|--------------------------------------------|------------------------------------|
| `theme/app_theme.dart` (tokens + AppText)  | same file, unchanged               |
| `providers/theme_providers.dart`           | same file, unchanged               |
| `widgets/theme_toggle.dart` (ink-reveal)   | same file, unchanged               |
| `widgets/anim/entrance.dart` (stagger +    | same file, unchanged               |
| skeleton)                                  |                                    |
| `widgets/anim/motion.dart` (count-up, bar  | same file, unchanged               |
| sweep, pulse)                              |                                    |
| `widgets/section_label.dart`               | same file, unchanged               |
| `widgets/place_tabs.dart` (sliding tabs +  | `trip_tabs.dart` — SavedPlace→Trip |
| add-place sheet w/ geocoding search)       |                                    |
| `screens/home_screen.dart` (PageView +     | trip home — places→trips,          |
| parallax, per-place pages)                 | weather fetch→trip store           |
| `providers/saved_places_providers.dart`    | trips list StateNotifier + family  |
|                                            | detail provider                    |
| `data/datasources/geocoding_data_source.dart`| same file, unchanged (destination |
|                                            | search)                           |
| `domain/entities/saved_place.dart`         | Trip entity (id, name, lat/lon)    |
| `widgets/day_detail_sheet.dart` (stat row  | trip day sheet: EVENTS/COSTS/      |
| + timeline)                                | TRANSPORT + item timeline          |
| `widgets/units_toggle.dart` (°C/°F)        | currency toggle (EUR/USD/...)      |

New for trip app (no Skylo analog): Trip/ItineraryItem/Booking/BudgetEntry/
PackingItem entities, CRUD editing flows, date-range logic, local persistence
heavier than SharedPreferences (consider Isar). Everything visual already
exists above.

# Existing Data Models
We have already defined the core domain entities:
- `WeatherEntity`: currentTemp (double), feelsLikeTemp (double), condition (String), weatherCode (int), hourly (List<HourlyForecast>), daily (List<DailyForecast>).
- `HourlyForecast`: time (DateTime), temp (double), weatherCode (int), precipitationProbability (double).
- `DailyForecast`: date (DateTime), maxTemp (double), minTemp (double), weatherCode (int).
- `WeatherRepository` (Abstract): `Future<WeatherEntity> getCurrentLocationWeather()`, `Future<WeatherEntity> getWeatherForLocation(double lat, double lon)`.

# Your Task — COMPLETED
> The two tasks below were completed during development (see git history).
> They reference the deprecated glassmorphism spec and are kept for history.

1. **Data Layer Implementation:** ~~`weather_model.dart`~~ — done; evolved to
   free-tier 2.5 endpoints merged into One Call shape (One Call 3.0 requires
   a paid subscription).
2. **UI Layer Implementation:** ~~`glass_card.dart` + `home_screen.dart`~~ —
   done in the original glass style, then fully redesigned to Swiss Editorial
   Minimal (see portable spec above). Glass is deprecated; do not rebuild it.

# UI LANGUAGE: "SWISS EDITORIAL MINIMAL" — full portable spec

This document is the canonical, complete definition of the Skylo UI
language, extracted from the production code (`lib/presentation/**`). It is
written to be handed to another LLM / team / app **as-is** — it is the design
system for any app in this family, including the trip app (full prompt:
`TRIP_APP_PROMPT.md`). Everything is framework-agnostic except where noted;
Flutter implementation notes are given inline. Skylo (weather) examples come
first, trip-app examples second — the values never change, only the domain.

Source of truth in this repo: `DESIGN.md` (summary) and
`lib/presentation/theme/app_theme.dart` (tokens), plus the widget files
referenced per component below.

---

## 1. Identity in one sentence

**Minimal Swiss editorial**: flat surfaces, one ink color, hairline rules,
tabular figures, and a single reserved red accent. Everything else is
restraint. Decoration is a bug. When unsure, remove — the answer is always
less.

## 2. Color tokens (exact values)

Five roles only. Both variants share identical structure; only values differ.

| Token      | Light     | Dark      | Usage                                    |
|------------|-----------|-----------|------------------------------------------|
| `surface`  | `#FAFAF8` | `#0D0D0D` | Canvas. The only background, ever.       |
| `ink`      | `#0A0A0A` | `#F2F2F0` | Primary text, icons, bar fills.          |
| `muted`    | `#8A8A8A` | `#9A9A9A` | Secondary text, timestamps, min values. |
| `hairline` | `#E8E8E8` | `#262626` | 2px rules, unfilled bar tracks, borders. |
| `accent`   | `#E4002B` | `#FF375F` | The single accent (reserved, see §4).    |

Brand constants (identical in both variants): `white #FFFFFF`, `red #E4002B`.

Rules:
- No other colors exist. The only sanctioned opacity is **ink at 40%** (modal
  scrim) and **muted at 25%** (skeleton pulse endpoint).
- Dark mode is a true near-black, not a dark grey theme.
- Accent in dark mode is brightened (`#FF375F`) purely for contrast on black.
- The scrim uses **ink**, not black: light mode scrim = dark ink at 40%;
  dark mode scrim = light ink at 40%.

Implementation note (Flutter): tokens ship as a `ThemeExtension`
(`SkyloTheme`) with `light`/`dark` constants; widgets resolve them via
`context.skylo.token` (extension `SkyloThemeX`). Build `ThemeData` **once and
cache it** (`cachedLightTheme` / `cachedDarkTheme`) — rebuilding it per frame
forces the tree to re-inherit and janks animations. Provide both `theme:` and
`darkTheme:` to the app root; derive `ColorScheme.fromSeed(seedColor:
accent, surface: tokens.surface)` but never use scheme colors directly in UI.

## 3. Typography

Font: **Inter** (Google Fonts). Single family, no exceptions.

| Style      | Size | Weight | Tracking | Height | Color  | Usage                        |
|------------|------|--------|----------|--------|--------|------------------------------|
| `display`  | 120  | 200    | -6       | 1.0    | ink    | Hero number                  |
| `location` | 24   | 600    | -0.5     | —      | ink    | Page titles, sheet titles    |
| `condition`| 18   | 400    | —        | —      | muted  | Secondary line under titles  |
| `label`    | 12   | 600    | 1.5      | —      | muted  | ALL CAPS section labels      |
| `body`     | 15   | 400    | —        | —      | ink    | Rows, copy                   |
| `tabular`  | 15   | 500    | —        | —      | ink    | All numerals (tabular figs.) |
| `degrees`  | 32   | 300    | —        | —      | accent | Hero unit suffix             |
| `wordmark` | 13   | 700    | 4        | —      | ink    | Brand mark                   |
| `tagline`  | 10   | 600    | 3        | —      | accent | ALL CAPS, page-end signature |
| `button`   | 12   | 600    | 1.5      | —      | white  | ALL CAPS on accent/ink fills |

Derived styles used in production (copy of a base + overrides):
- **Hero condition line**: tabular base → 14px / w600 / tracking 1.2 / ink,
  ALL CAPS. Followed by a "feels like" run: same but w400 / muted, 24px gap.
- **Date/sub-line under titles**: condition base → 15px (e.g.
  `Monday, 5 May · 14:32`).
- **Tab labels**: label base → 13px / tracking 1.2; active w700 ink, inactive
  w500 muted.
- **Sheet stat values**: tabular base → 24px / w600; accent variant allowed
  for one semantic stat (e.g. rain ≥ threshold).
- **Settings row trailing state**: tabular base → 13px / w700 / tracking 1.2
  / muted, ALL CAPS.
- **Search field**: location base → 20px, ink; hint in condition style.

Hard rules:
- **Every numeral in the UI uses tabular figures** (`FontFeature
  .tabularFigures()`) so columns and count-ups never jitter — dates, prices,
  durations, distances too.
- ALL CAPS only for: section labels, buttons, tagline, wordmark, tab labels,
  hero condition line, settings state values, picker native names (where the
  script supports it). Everything else is sentence case.
- No italics anywhere. No variable-font tricks beyond Inter's weights.

Domain examples:
- Skylo hero: `29` (display) + `°C` (degrees, accent, top-padding 28 to
  optically align with the display cap height).
- Trip hero: `12` (display) + `DAYS TO GO` (degrees position, accent).
- Trip title: `Rome — Fall Trip` (location, 24px).

## 4. Accent discipline — red is earned, never spent

The accent appears ONLY in these roles. If a screen needs red anywhere else,
the design is wrong:

1. **Hero unit suffix** (Skylo: `°C`. Trip: `DAYS TO GO`).
2. **The 3×14px tick** preceding every section label and marking the active
   item in pickers.
3. **The current/active row** in a list (Skylo: Today row in outlook = w700 +
   accent. Trip: current day in itinerary, active trip in list).
4. **Semantic warning glyphs and values, threshold-based** (Skylo: precip
   glyph when probability ≥ 30%; rain/storm codes 300–599 in the outlook;
   RAIN stat when max probability ≥ 30%. Trip: overdue booking, budget over
   limit, passport expiring, unpaid item).
5. **Primary action button** — one per view (Skylo: RETRY. Trip: SAVE TRIP,
   ADD DAY).
6. **The tagline.**
7. **Active-state toggle borders** (dark variant only) and the search field's
   focused underline (2px accent).
8. **Severe alert strips** (left border + headline in accent; non-severe
   alerts stay ink).

Everything else is ink, muted, hairline, or surface. Max one accent element
per screen region; never decorative.

## 5. Layout system (exact constants)

| Constant              | Value                                   |
|-----------------------|-----------------------------------------|
| Content column        | max **680px**, centered                 |
| Compact breakpoint    | viewport width < **700px** → full width |
| Horizontal padding    | **32** all around                       |
| First block top pad   | 72 desktop / 48 compact                 |
| Hero → next section   | 88 desktop / 56 compact                 |
| Section → section     | 72 desktop / 48 compact                 |
| Last block → bottom   | 96 desktop / 48 compact                 |
| List row padding      | 10 (data rows) / 12 (outlook rows) / 14 (settings, picker, search rows) vertical |
| Text alignment        | left for text, **right for numerals** in columns |
| Sheets                | zero radius, max width 640, padding 32/32/32/40 |

Page structure:
- **Peer entities are pages, not lists**: horizontal `PageView` swipe (Skylo:
  one page per saved place. Trip: one page per trip), tabs across the top,
  current/primary entity pinned first. Tagline right-aligned at page end.
- Header row: tabs (Expanded) + 16px gap + 40px settings toggle, top padding
  24, horizontal padding 32.
- Rows never use separators; hierarchy comes from spacing and hairline data
  bars. Full rows are tappable (opaque hit areas).
- Empty/zero values render as an em-dash `—` in muted, never `0` or blank.

## 6. Component vocabulary (full specs)

### 6.0 Cards, pills, chips, badges — the policy

**This language has no cards, no pills, no chips, no badges, no toasts.**
Containers are the bug this style avoids. The sanctioned equivalents:

| You'd normally use… | Use instead                                  |
|---------------------|----------------------------------------------|
| Card                | A section (SectionLabel + rows) directly on surface |
| Pill / chip         | A tab, or a circular toggle (§6.4)           |
| Badge / tag         | A muted 12px ALL CAPS label, or the accent tick |
| Toast / snackbar    | An inline strip (alert-row pattern, §6.10)   |
| FAB                 | The trailing "+" tab (§6.5) or a sheet button |

If a design introduces a rounded, filled, or shadowed container of any kind,
it is wrong. The ONLY filled shapes in the system are: data-bar fills,
buttons, the 3px tick, the sliding tab underline, and the circular toggle.

### 6.1 SectionLabel — `widgets/section_label.dart`

The signature component. 3×14px accent tick, 10px gap, 12px muted ALL CAPS
label (w600, tracking 1.5). Used to open every section. In sheets and
pickers the identical tick+label row opens the sheet. Spacing below label:
20px (data sections) / 12–16px (sheets, lists).

### 6.2 HairlineBar — data bars (`anim/motion.dart`, `SweepingTempBar`)

2px tall bar: hairline track + ink fill, left-aligned (`centerLeft`), fill
fraction 0→1. Any quantitative comparison uses this instead of a chart:
hourly temps, budget spent, day completion. A fraction of exactly 0 renders
a **0.03 minimum** so the row still reads as "present". Never two bars
stacked, never rounded ends.

### 6.3 Glyphs — `widgets/weather_glyph.dart`

**Outlined Material icons only** (never filled), 18–22px, ink by default.
Sizes in production: 18 (row glyphs), 20 (settings rows, header close, hero
condition), 40 (error/empty states). Accent only for §4 semantic roles.
Trailing "+" add icons are 16px muted. Icon→text gap: 8 (hero) / 16
(settings rows).

### 6.4 CircularToggle — `widgets/theme_toggle.dart`, `units_toggle.dart`

The system's only "pill": a **40×40px circle, 1px hairline border**, centered
content — an 18px outlined glyph (settings) or 12px w700 text (`°C`, `°F`,
currency code). Ink content on surface. Same shape is used for theme,
units, currency — one mental model for all binary/ternary switches.

### 6.5 Tabs — `widgets/place_tabs.dart`

One tab per entity + trailing **"+" add-tab** (16px muted plus glyph, opens
the add-entity sheet). Labels ALL CAPS 13px, tracking 1.2; active = w700
ink, inactive = w500 muted. Inter-tab gap **28px**. The indicator is a
**24×2px accent underline** that *physically slides* between tabs
(300ms easeOutCubic, `AnimatedContainer` positioned from measured tab
widths). Tab strip height 36, horizontally scrollable; the active tab
auto-scrolls into view (alignment 0.1, 300ms easeOutCubic). Tapping a tab
animates the page (350ms easeOutCubic); swiping pages moves the indicator.

### 6.6 Buttons — `screens/home_screen.dart` (`_ErrorView`)

ALL CAPS 12px w600 tracking 1.5, **white text on flat fill, zero radius**.
- Primary (accent fill): padding 32h / 14v. One per view.
- Secondary (ink fill, surface text): padding 24h / 14v.
No borders, no elevation, no ripple-visible styling beyond ink wash. Sheet
actions use the same two styles.

### 6.7 List row templates (measured)

**Data/timeline row** (hourly; trip event/transport rows):
`[time 56px, muted tabular] [glyph 36px] [bar Expanded] [value 48px,
right-aligned tabular]`, vertical padding 10. Optional 5th column
(48px, right, muted, FittedBox scale-down) for a secondary numeral — em-dash
when zero.

**Summary row** (5-day outlook; trip day rows):
`[label Expanded flex 3] [glyph 36px] [min Expanded flex 2, muted,
right] [max Expanded flex 2, w700, right]`, vertical padding 12. Current
item = w700 + accent (§4.3). Whole row is an InkWell → detail sheet.

**Settings row**:
`[icon 20px ink] gap 16 [title body] [trailing state, right]`, vertical
padding 14, 12px gaps between rows. Tapping either toggles inline or opens
the sub-sheet.

**Picker row** (language; any option list):
`[3×14 tick — accent when active, transparent otherwise] gap 10 [label
body — w700 active / w400 inactive]`, vertical padding 14, 16px gap below
the section label. No checkmarks, no radios — the tick IS the check.

**Search result row**:
`[label body, Expanded] [add icon 16, muted]`, vertical padding 14, ink.

**Checked-off item** (trip packing): muted text, optional strikethrough.
Never accent, never green — completion is de-emphasis, not celebration.

### 6.8 Stat row (detail sheets) — `widgets/day_detail_sheet.dart`

Three equal `Expanded` stats under a sheet title: label (12px muted ALL CAPS)
+ 8px gap + value (24px w600 tabular; accent only for the one semantic stat,
e.g. rain ≥ 30%). Skylo: MIN / MAX / RAIN. Trip: EVENTS / COSTS / TRANSPORT.

### 6.9 Sheets (bottom/modal) + search field

`showModalBottomSheet`: **zero radius**, surface fill, scrim = ink 40%,
`isScrollControlled`, max width 640, padding LTRB(32, 32, 32, 40), bottom
inset = viewInsets + viewPadding (keyboard-safe). Internal anatomy:
SectionLabel tick row → 24–28px → content. Used for add-entity search,
settings, pickers, and detail views.

**Search field** (add-entity): text 20px (location base), hint condition
style, `autofocus`, search action; border is a plain **underline** —
hairline unfocused, **2px accent focused**; cursor accent. Query fires at
≥ 2 characters. While searching: 3 skeleton rows (§6.12). Empty result:
one muted condition-style line ("No places found" / "No destinations").
Result tap = add + dismiss.

### 6.10 Alert strip — `widgets/alert_banner.dart`

Inline strip (no toast, no banner bar): **3px left border** + padding
LTRB(20, 10, 12, 10). Headline: body 15px w700, tracking 0.4, border color;
trailing detail: label style muted. Severe = accent border + accent
headline; watch = ink. Max 3, sorted severe-first; 12px between rows, 28px
above the group. Collapses to zero height when empty. Trip analogs: overdue
booking strip, budget-over strip — same shape, §4.4 thresholds.

### 6.11 Error / empty states — `screens/home_screen.dart` (`_ErrorView`)

Centered column, max width 420, padding 32: outlined 40px ink icon → 24px →
headline (location base, 20px) → 12px → muted condition message → 32px →
one button (primary accent, or ink secondary for system-settings actions).
Empty states follow the same shape with the domain icon (trip packing →
luggage, "Nothing packed yet", ADD ITEM). One action, never two.

### 6.12 Skeletons — `widgets/anim/entrance.dart`

**No spinners anywhere on pages.** Loading = hairline bars pulsing toward
muted-25% and back, 1200ms reverse loop, easeInOut, mirroring the loaded
layout *shape exactly* (same paddings, same row heights). Home template:
header (180×24 + 140×15) → hero (160×96 + 220×16) → 8 rows (h20, pad 10) →
5 rows (h22, pad 12), compact scales header/hero to 0.8. Search template: 3
rows of (Expanded×16 + 32×16), pad 14. A skeleton must never flash shorter
than one pulse before data arrives; keep previous data on refresh
(`skipLoadingOnRefresh/Reload/Error` pattern).

### 6.13 Wordmark & tagline

Wordmark 13px w700 tracking 4 ink. Tagline 10px w600 tracking 3 accent,
ALL CAPS, **right-aligned as the last element of every page** (Skylo: KNOW
YOUR SKY. Trip: own tagline). It is the only recurring accent text.

## 7. Motion vocabulary (exact, from `anim/*.dart` + `theme_providers.dart`)

All motion is short, eased, meaningful. 300–700ms. Motion **restarts on data
identity change** (keyed by entity id / date), never on rebuild.

| Animation        | Spec                                                                  |
|------------------|-----------------------------------------------------------------------|
| Entrance stagger | Fade + slide-up 16px per section, 60ms step delay, 420ms easeOut; restarts on entity id change |
| Count-up         | Hero number rolls 0→value on first load, previous→value on change, 700ms easeOut, tabular digits (trip: days-to-go counts down on open — the signature moment) |
| Bar sweep        | 2px bars fill left→right 0→fraction, 650ms easeOut, restart on data-key change |
| Tab indicator    | 24×2 accent underline slides between measured tab positions, 300ms easeOutCubic; page animate 350ms easeOutCubic |
| Ink-reveal theme | New variant's surface color expands as a **filled circle from the toggle's screen-center origin**, radius = farthest corner; 600ms total: expand on Interval 0–0.65 easeOut, theme swaps beneath at 340ms, mask fades on Interval 0.62–1.0 easeIn (260ms); overlay lives in root overlay so it survives the settings sheet pop; instant-swap fallback if no overlay |
| Skeleton pulse   | hairline ↔ muted-25%, 1200ms, reverse loop, easeInOut                  |
| Semantic pulse   | Warning glyphs breathe opacity 1.0↔0.55, 1600ms reverse loop, easeInOut, only while the threshold is met (trip: overdue bookings breathe) |
| Page parallax    | Peer pages drift ±28px horizontally during swipe (`(i - page) * 28`)  |

Rules: nothing loops except skeleton + semantic pulse; theme changes and
data swaps animate, nothing else does; no hero-scale, no shared-axis
transitions, no springs.

## 8. Interaction states

- Full rows are tappable, opaque hit areas (`InkWell`/`GestureDetector`
  opaque).
- Active row in a list: w700 + accent (§4.3). Picker active: accent tick +
  w700.
- Disabled/nonexistent: muted color, no other treatment.
- Scrim behind modals: ink at 40%.
- Focus/hover (desktop): same color shift as active state; no outlines, no
  rings. Search focus is the one exception (2px accent underline + accent
  cursor).
- Theme choice: system default on first launch, persisted
  (`skylo.themeMode`), toggled from settings with the ink-reveal.

## 9. Porting checklist (for another app / LLM)

1. Adopt the five tokens + white/red constants exactly (§2). Cache themes.
2. Inter, the ten styles + derived styles (§3); tabular figures on ALL
   numerals, right-aligned in columns.
3. Enforce the accent allowlist (§4) in code review — treat violations as
   lint errors.
4. Copy layout constants (§5): 680 / 32 / 88 / 72 / 700-breakpoint.
5. Build §6 components as the ONLY allowed primitives. No cards, pills,
   chips, badges (§6.0) — use the equivalents table.
6. Apply motion specs (§7) exactly; nothing more.
7. Ship light + dark from day one; persist choice; default system.
8. Loading = shape-mirroring skeletons; errors/empties = §6.11; never
   spinners on pages.
9. When unsure, remove.

**Forbidden (treat as lint errors)**: shadows, gradients, blur,
glassmorphism, rounded corners (except the 40px circular toggle and the
ink-reveal circle), filled icons, multiple accents per region,
non-tabular numerals, italic text, cards/pills/chips/badges/toasts,
center-aligned body text, `0` where `—` belongs.

## 10. Skylo → Trip app reuse map (verified in production code)

Port these Skylo files nearly verbatim; only domain nouns change:

| Skylo (reference)                            | Trip app (target)                    |
|----------------------------------------------|--------------------------------------|
| `theme/app_theme.dart` (tokens + AppText)    | same file, unchanged                 |
| `providers/theme_providers.dart` (ink-reveal, cached themes) | same file, unchanged |
| `widgets/theme_toggle.dart` (40px circle → settings sheet) | same file, unchanged |
| `widgets/anim/entrance.dart` (stagger + skeletons) | same file, unchanged          |
| `widgets/anim/motion.dart` (count-up, bar sweep, pulse) | same file, unchanged |
| `widgets/section_label.dart`                 | same file, unchanged                 |
| `widgets/place_tabs.dart` (sliding tabs + add-entity sheet + search + skeleton results) | `trip_tabs.dart` — SavedPlace→Trip |
| `screens/home_screen.dart` (PageView + parallax, per-entity pages, error view) | trip home — places→trips |
| `providers/saved_places_providers.dart`      | trips StateNotifier + family detail  |
| `data/datasources/geocoding_data_source.dart`| same file, unchanged (destination search) |
| `domain/entities/saved_place.dart`           | Trip entity (id, name, lat/lon)      |
| `widgets/day_detail_sheet.dart` (stat row + timeline rows) | trip day sheet: EVENTS/COSTS/TRANSPORT |
| `widgets/units_toggle.dart` (°C/°F)          | currency toggle (EUR/USD/…)          |
| `widgets/settings_sheet.dart` (settings rows + picker pattern) | same, minus weather-specific rows |

New for the trip app (no Skylo analog): Trip/ItineraryItem/Booking/
BudgetEntry/PackingItem entities, CRUD editing flows, date-range logic,
heavier local persistence (consider Isar). Everything visual already exists
above.

---

# Existing Data Models

We have already defined the core domain entities:
- `WeatherEntity`: currentTemp (double), feelsLikeTemp (double), condition
  (String), weatherCode (int), hourly (List<HourlyForecast>), daily
  (List<DailyForecast>).
- `HourlyForecast`: time (DateTime), temp (double), weatherCode (int),
  precipitationProbability (double).
- `DailyForecast`: date (DateTime), maxTemp (double), minTemp (double),
  weatherCode (int).
- `WeatherRepository` (abstract): `Future<WeatherEntity>
  getCurrentLocationWeather()`, `Future<WeatherEntity>
  getWeatherForLocation(double lat, double lon)`.

# Your Task — COMPLETED

> The two tasks below were completed during development (see git history).
> They reference the deprecated glassmorphism spec and are kept for history.

1. **Data Layer Implementation:** ~~`weather_model.dart`~~ — done; evolved to
   free-tier 2.5 endpoints merged into One Call shape (One Call 3.0 requires
   a paid subscription).
2. **UI Layer Implementation:** ~~`glass_card.dart` + `home_screen.dart`~~ —
   done in the original glass style, then fully redesigned to Swiss Editorial
   Minimal (see portable spec above). Glass is deprecated; do not rebuild it.
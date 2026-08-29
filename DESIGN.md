# Skylo Design Language

The Skylo design language is **minimal Swiss editorial**: flat surfaces, a single
ink color, hairline rules, tabular figures, and one reserved red accent.
Everything else is restraint.

All Skylo screens and widgets must be built from the tokens in
`lib/presentation/theme/app_theme.dart`. No screen may hardcode colors, spacing,
or typography outside these tokens.

## Tokens

Defined as a `ThemeExtension` (`SkyloTheme`) so every widget resolves the active
variant via `context.skylo`. Light and dark are the same structure, only values differ.

| Token      | Light     | Dark      | Usage                                    |
|------------|-----------|-----------|------------------------------------------|
| `surface`  | `#FAFAF8` | `#0D0D0D` | Canvas. The only background.             |
| `ink`      | `#0A0A0A` | `#F2F2F0` | Primary text, glyphs, bar fills.         |
| `muted`    | `#8A8A8A` | `#9A9A9A` | Secondary text, timestamps, min temps.  |
| `hairline` | `#E8E8E8` | `#262626` | 2px separators, unfilled bar tracks.     |
| `accent`   | `#E4002B` | `#FF375F` | The single accent (see rules below).     |

Brand constants: `AppColors.red`, `AppColors.white` (identical in both variants).

## Accent rules — red is earned, never spent

The accent is reserved for exactly these roles:

1. The degree symbol after the hero temperature (`°C`).
2. The 3px tick before every section label.
3. "Today" row in the daily outlook (bold + red).
4. Precipitation glyphs when precipitation probability ≥ 30%.
5. Rain/storm glyphs in the daily outlook.
6. Primary action buttons (RETRY).
7. The tagline `KNOW YOUR SKY`.
8. Theme toggle border, dark variant only.

Everything else is ink, muted, or hairline. If a design needs red anywhere
else, the design is wrong.

## Typography

Inter only (`google_fonts`). Defined in `AppText`, always resolved against
`context` so variant colors apply.

| Style      | Size | Weight | Tracking | Notes                          |
|------------|------|--------|----------|--------------------------------|
| `display`  | 120  | 200    | -6       | Hero temperature, height 1.0. |
| `location` | 24   | 600    | -0.5     | Place name.                    |
| `condition`| 18   | 400    | —        | Secondary, muted.              |
| `label`    | 12   | 600    | 1.5      | ALL CAPS section labels.       |
| `body`     | 15   | 400    | —        | Rows and copy.                 |
| `tabular`  | 15   | 500    | —        | All numerals, tabular figures. |
| `degrees`  | 32   | 300    | —        | `°C` suffix, accent color.     |
| `wordmark` | 13   | 700    | 4        | `SKYLO`.                       |
| `tagline`  | 10   | 600    | 3        | Accent, ALL CAPS.              |
| `button`   | 12   | 600    | 1.5      | ALL CAPS, white on accent/ink. |

All numerals anywhere in the UI use `FontFeature.tabularFigures()`.

## Layout

- Content column: 680px max width, centered; full width under 700px viewport.
- Horizontal padding: 32.
- Vertical rhythm: 88 between blocks (desktop), 48–56 compact.
- Rows: hairline 2px bars, 10–12px vertical padding per row.
- Compact mode: viewport width < 700.

## Components

Built or migrated:

- `SectionLabel` — red tick + muted ALL CAPS label.
- `WeatherGlyph` — outlined Material glyphs, ink; red when `accent` is set.
- `ThemeToggle` — 40px circle, 1px border, sun/moon glyph.
- `_TempBar` pattern — hairline track + ink fill, 2px tall.
- Error states — outlined icon, headline, message, accent or ink button.
- Loading — 2px accent ring on surface.

Deprecated (do not use in new builds): `GlassCard`, gradients, blur, shadows.

## Theme behavior

- `themeModeProvider` (Riverpod StateNotifier) holds `ThemeMode`; persisted via
  `SharedPreferencesAsync` under `skylo.themeMode`.
- Toggle flips light/dark; system default on first launch.
- Theme transition: 300ms ease-out `AnimatedContainer` on surface color.
- Both `theme:` and `darkTheme:` are always provided to `MaterialApp`.

## Rules of thumb

1. Flat. No shadows, no gradients, no blur, no glass, no radius except the toggle.
2. Color = ink, muted, hairline, surface, plus reserved accent roles.
3. Numerals are tabular and right-aligned in columns.
4. One accent per screen region, never decorative.
5. Icons are outlined Material glyphs at 18–22px.
6. Buttons are ALL CAPS, 12px, tracked, accent or ink fill, white text.
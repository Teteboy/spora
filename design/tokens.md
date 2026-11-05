# SPORA — Design Tokens (from Figma "Foundations / SPORA")

## Colors — light mode

| Token | Hex | Role |
|-------|-----|------|
| primary-500 | `#2563EB` | Main action color |
| primary-600 | `#1D4ED8` | Pressed/active |
| primary-100 | `#DBEAFE` | Tinted backgrounds |
| indigo-500 | `#6366F1` | Action gradient end (#2563EB → #6366F1) |
| navy-900 | `#061426` | Dark base |
| navy-800 | `#0B1B3A` | |
| navy-700 | `#12294F` | |
| green-700 | `#0F6B45` | Clubs use green |
| green-500 | `#10B981` | Success |
| gold-400 | `#FBBF24` | Premium & Highlights tags only |
| gold-600 | `#D97706` | |
| app-bg | `#F5F7FC` | App background |
| surface | `#FFFFFF` | Cards/surfaces |
| muted | `#EEF2F9` | Muted fills |
| border | `#E2E8F0` | Borders |
| text-primary | `#0F172A` | |
| text-secondary | `#475569` | |
| text-muted | `#64748B` | |

### Semantic
success `#10B981` · warning `#F59E0B` · danger `#EF4444` · info `#2563EB` · error text (reinforced) `#B91C1C`

### Opportunity categories
recrutement `#2563EB` · détection `#10B981` · essais `#F97316` · académies `#8B5CF6` · tournois `#EAB308`

## Colors — dark mode (designed, to be bound)

app `#061426` · surface `#0F2038` · raised `#162B49` · muted `#12263F` · border `#1E3354` · text `#F1F5F9` / `#CBD5E1` / `#94A3B8`
Dark uses borders instead of shadows; 4% photo veil. No manual recoloring.

## Typography — Poppins

| Style | Size/Line | Weight | Notes |
|-------|-----------|--------|-------|
| Display | 28/34 | 800 | −0.5 px tracking |
| H1 | 22/28 | 700 | |
| H2 | 18/24 | 600 | |
| H3 | 16/22 | 600 | |
| Body large | 16/24 | 400 | |
| Body | 14/20 | 400 | |
| Body strong | 14/20 | 600 | |
| Caption | 12/16 | 400 | |
| Micro | 11/14 | 400 | |
| Eyebrow | 11/14 | 600 | +1.5 px tracking, uppercase |
| Button | 15/20 | 600 | |
| Stat number | 20/24 | 600 | tabular figures |

## Spacing

Scale: 2 / 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 48 / 64
Screen margin 16 · card padding 12–16 · section gap 24 · mobile grid 4 cols / 16 gutter

## Radii

8 · 12 inputs · 16 cards · 20 hero · 28 sheets · 999 pills

## Layout (iPhone 390×844)

status bar 47 · top bar 56 · bottom nav 80 · touch targets ≥ 44×44

## Elevation

- elev-1: `0 2 8` navy @6%
- elev-2: `0 8 24` navy @10%
- elev-3: `0 16 40` navy @16%
- glow-brand: `0 8 24` blue @30%
- Max one strong shadow per screen.

## Motion

Durations: fast 120 · base 200 · slow 320 · hero 480 ms
Easings: standard `cubic-bezier(0.2,0,0,1)` · emphasised `cubic-bezier(0.3,0,0,1.2)` (badges/success)
Transitions: tab 120 · push 280 · sheets 320 · hero-detail 320 · dialog 200
Reduced motion: fades over movement; manual carousel; no confetti.

## Icons & media

Lucide outline, 1.75 px stroke, sizes 16/20/24.
Player portraits 4:5, face in upper third. Posters 16:9 or 9:16, playback 52–56 px. Original club crests only.

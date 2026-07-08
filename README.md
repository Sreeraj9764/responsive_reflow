# responsive_reflow

Responsive & adaptive layout utilities for Flutter.

[![Pub Version](https://img.shields.io/pub/v/responsive_reflow.svg)](https://pub.dev/packages/responsive_reflow)
[![Pub Points](https://img.shields.io/pub/points/responsive_reflow)](https://pub.dev/packages/responsive_reflow/score)
[![GitHub License](https://img.shields.io/github/license/Sreeraj9764/responsive_reflow)](https://github.com/Sreeraj9764/responsive_reflow/blob/main/LICENSE)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Sreeraj9764/responsive__reflow-blue?logo=github)](https://github.com/Sreeraj9764/responsive_reflow)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg)](https://github.com/invertase/melos)

Provides Material 3 window size-class breakpoints, spacing tokens, responsive
builders, an adaptive navigation scaffold, input-density helpers, foldable
awareness, and safe-area utilities — all built on official Flutter guidance.
It **reflows** layouts by available width; it never pixel-scales like
`flutter_screenutil` or `responsive_framework`'s `AutoScale`.

## Why reflow, not scale

- **Width drives layout, never device type.** Decisions branch on the window
  width (and capabilities), so the same screen adapts on phones, foldables,
  tablets, desktop, and split-screen.
- **No `flutter_screenutil` (`.w`/`.h`)** and **no `AutoScale`.** Scaling fakes
  responsiveness and breaks text scaling/accessibility. Use real constraints,
  `Flexible`/`Expanded`, `Wrap`, and `LayoutBuilder`.

|                                | Pixel scaling (`.w`/`.h`/`.sp`, AutoScale) | Reflow (this package) |
| ------------------------------ | ------------------------------------------ | --------------------- |
| Bigger window shows            | The same UI, zoomed                        | **More content** (more columns, extra panes, sidebar) |
| System text scaling (a11y)     | Often broken — fights `.sp` math           | Respected — text and layout reflow naturally |
| Desktop window resize          | Stretched/blurry proportions               | Layout re-classifies per width, stays crisp |
| Split-screen & foldables       | Wrong — scales to a size that isn't there  | Correct — branches on the *actual* window/constraints |
| Reusable components            | Coupled to a "design size"                 | Adapt to parent constraints anywhere |
| Aligned with official guidance | No                                         | Yes — M3 window size classes + Flutter adaptive docs |

A design mockup is a *starting point* for one size class — not a fixed canvas
to scale. This package gives you the primitives to express what should
*change* between size classes.

## Material 3 breakpoints

| Window size class | Width (logical px) | `ReflowBreakpoint`        | Typical navigation        |
| ----------------- | ------------------ | --------------------- | ------------------------- |
| Compact           | `< 600`            | `ReflowBreakpoint.compact`    | Bottom navigation bar |
| Medium            | `600 – 839`        | `ReflowBreakpoint.medium`     | Navigation rail (icons) |
| Expanded          | `840 – 1199`       | `ReflowBreakpoint.expanded`   | Full sidebar          |
| Large             | `1200 – 1599`      | `ReflowBreakpoint.large`      | Full sidebar          |
| Extra large       | `≥ 1600`           | `ReflowBreakpoint.extraLarge` | Full sidebar          |

Thresholds are configurable — see [Configurable breakpoints](#configurable-breakpoints).

## Features

- **Breakpoints** — `ReflowBreakpoint` enum with comparison operators
  (`>=`, `>`, `<=`, `<`) and helpers (`isCompact`, `isExpanded`, `showsSidebar`,
  `isMobileLayout`, `isDesktopLayout`).
- **Context extension** — `context.reflow` for ergonomic access: breakpoint
  checks, M3 margins/gutters, page padding, fold detection, input mode.
- **Configurable thresholds** — `ReflowBreakpoints` (immutable config) +
  `ReflowBreakpointsTheme` (inherited override for a subtree).
- **Spacing tokens** — `ReflowSpacing`, `ReflowEdgeInsets`, `ReflowGap`, `ReflowRadius`.
- **Responsive builders** — `ReflowResponsiveBuilder` (window) and
  `ReflowConstraintResponsiveBuilder` (parent constraints), both with
  smaller-to-larger cascade fallback and `ReflowBreakpointsTheme` support.
- **Responsive values & widgets** — `ReflowResponsiveValue<T>`,
  `ReflowResponsiveVisibility`, `ReflowResponsiveRowColumn`.
- **Adaptive scaffold** — `ReflowAdaptiveScaffold` auto-switches bottom nav → rail →
  sidebar, with FAB, optional desktop app bar, animated transitions, and an
  optional `secondaryBody` split view (list–detail, fold-aware).
- **Constrained content** — `ConstrainedContent`, `ReflowPageContent`
  (max-width + responsive padding + safe area + scroll-position restoration).
- **Responsive grid** — `ReflowResponsiveGrid` and `ReflowResponsiveGrid.builder`
  (lazy) with width-derived column counts, `minColumns`/`maxColumns` clamping,
  and per-breakpoint `columns` overrides.
- **Input density** — `ReflowDensity` / `ReflowPointerModeDetector` for touch-vs-pointer
  `VisualDensity`.
- **Policy & capabilities** — `ReflowPolicy` (size-based decisions) and
  `ReflowCapability` (hardware/runtime facts).
- **Foldable awareness** — `ReflowDisplayFeatures` (hinge/fold detection).
- **Safe area & insets** — `ReflowSafeArea`, `ReflowInsets`.

## Which tool do I reach for?

| I want to… | Use |
| --- | --- |
| Switch a whole screen's layout by window size | `ReflowResponsiveBuilder` |
| Adapt a reusable component to *its own* space | `ReflowConstraintResponsiveBuilder` |
| Pick a value (columns, padding, flex) per breakpoint | `ReflowResponsiveValue<T>` |
| Quickly check the size class in `build` | `context.reflow.isCompact`, `.atLeast(…)` |
| Show/hide something above or below a breakpoint | `ReflowResponsiveVisibility` |
| Stack on phones, sit side-by-side on wider windows | `ReflowResponsiveRowColumn` |
| App shell: bottom bar → rail → sidebar | `ReflowAdaptiveScaffold` |
| List–detail two-pane layout on wide windows | `ReflowAdaptiveScaffold(secondaryBody: …)` |
| Stop content stretching on ultra-wide displays | `ConstrainedContent` / `ReflowPageContent` |
| A grid that grows columns with width | `ReflowResponsiveGrid` |
| Consistent spacing without magic numbers | `ReflowSpacing` / `ReflowGap` / `ReflowEdgeInsets` |
| Page margins that follow the M3 spec | `context.reflow.margin` / `.pagePadding` |
| Denser UI for mouse users | `ReflowDensity` / `ReflowPointerModeDetector` |
| Avoid rendering under a foldable's hinge | `ReflowDisplayFeatures` (or `secondaryBody`, which is fold-aware) |

## Usage

```dart
import 'package:responsive_reflow/responsive_reflow.dart';
```

### Responsive builder

```dart
ReflowResponsiveBuilder(
  compact: (context) => MobileLayout(),
  expanded: (context) => DesktopLayout(),
)
```

### Context extension

```dart
final reflow = context.reflow;

if (reflow.isCompact) { /* … */ }
if (reflow.atLeast(ReflowBreakpoint.medium)) { /* … */ }

Padding(padding: reflow.pagePadding, child: content);      // breakpoint-scaled
SizedBox(width: reflow.gutter);                            // M3 16/24 gutter
if (reflow.hasVerticalFold) { /* two-pane layout */ }
```

### Responsive value

```dart
final columns = const ReflowResponsiveValue<int>(
  compact: 1,
  medium: 2,
  expanded: 3,
).resolve(context);
```

### Responsive visibility & row/column

```dart
ReflowResponsiveVisibility(
  visibleFrom: ReflowBreakpoint.expanded,
  child: SecondaryPanel(),
)

ReflowResponsiveRowColumn(
  rowFrom: ReflowBreakpoint.medium,
  spacing: ReflowSpacing.lg,
  children: [LabelField(), ValueField()],
)
```

### Spacing tokens

```dart
Padding(padding: ReflowEdgeInsets.allLg, child: content)
Column(children: [widget1, ReflowGap.verticalSm, widget2])
```

### Adaptive scaffold

```dart
ReflowAdaptiveScaffold(
  destinations: const [
    ReflowDestination(icon: Icons.home, label: 'Home'),
    ReflowDestination(icon: Icons.calendar_month, label: 'Schedule'),
  ],
  currentIndex: navigationShell.currentIndex,
  onDestinationSelected: navigationShell.goBranch,
  body: navigationShell,
  floatingActionButton: const FloatingActionButton(...),
)
```

### Split view (list–detail)

`secondaryBody` appears next to `body` on expanded+ windows and is hidden on
compact/medium. When a foldable's vertical hinge splits the window, the panes
sit on either side of the fold automatically.

```dart
ReflowAdaptiveScaffold(
  destinations: destinations,
  currentIndex: index,
  onDestinationSelected: onSelect,
  body: InboxList(),
  secondaryBody: MessageDetail(),
  bodyRatio: 0.4, // 40% list, 60% detail
)
```

### Page content

```dart
ReflowPageContent(
  maxWidth: 1000,
  child: Column(children: [...]),
)
```

### Responsive grid (lazy)

```dart
ReflowResponsiveGrid.builder(
  maxItemWidth: 300,
  itemCount: items.length,
  itemBuilder: (context, i) => ItemCard(items[i]),
)
```

Clamp or fix the column count when you need tighter control:

```dart
// Never fewer than 2, never more than 4 columns:
ReflowResponsiveGrid(
  maxItemWidth: 300,
  minColumns: 2,
  maxColumns: 4,
  children: cards,
)

// Explicit columns per breakpoint:
ReflowResponsiveGrid(
  columns: const ReflowResponsiveValue(compact: 1, medium: 2, expanded: 4),
  children: cards,
)
```

### Input density

```dart
Theme(
  data: Theme.of(context).copyWith(visualDensity: ReflowDensity.density),
  child: child,
)
```

### Configurable breakpoints

```dart
ReflowBreakpointsTheme(
  breakpoints: const ReflowBreakpoints(medium: 560, expanded: 900),
  child: app,
)
```

## Migrating from flutter_screenutil

There is no 1:1 mapping — and that's the point. Replace *scaled dimensions*
with *tokens, constraints, and breakpoint decisions*:

| ScreenUtil habit | Reflow replacement |
| --- | --- |
| `ScreenUtilInit(designSize: …)` | Delete it. No design-size coupling. |
| `16.w` / `16.h` padding | `ReflowSpacing.lg`, `ReflowEdgeInsets.allLg`, or `context.reflow.pagePadding` |
| `14.sp` font sizes | Plain `TextStyle(fontSize: 14)` / theme text styles — let system text scaling work |
| `0.5.sw` (half screen width) | `Expanded`/`Flexible` flex factors, or `FractionallySizedBox` |
| Fixed card width `160.w` | `ReflowResponsiveGrid(maxItemWidth: 180)` — columns derive from width |
| `ScreenUtil().screenWidth > 600` | `context.reflow.atLeast(ReflowBreakpoint.medium)` |
| One scaled layout for all sizes | `ReflowResponsiveBuilder(compact: …, expanded: …)` |

Migration strategy: work screen by screen. First delete scaling and let the
layout break, then fix each break with the right primitive from the
[cheat sheet](#which-tool-do-i-reach-for) — usually `Expanded`, a spacing
token, a max-width wrapper, or a breakpoint branch.

## Best practices

- **Screens branch on the window, components branch on constraints.** Use
  `ReflowResponsiveBuilder` for pages and `ReflowConstraintResponsiveBuilder`
  inside reusable widgets so they also work in dialogs, panes, and split views.
- **Don't branch on `Platform.isX` or "is tablet" for layout.** A desktop
  window can be phone-sized and a tablet can be split-screened. Sizes, not
  devices.
- **Never lock orientation.** It letterboxes on foldables and breaks large
  format requirements.
- **Let text scale.** Don't tie font sizes to screen width; verify layouts at
  1.3×+ text scale — reflow-based layouts survive this, scaled ones don't.
- **Constrain reading widths.** Wrap long-form content in
  `ConstrainedContent`/`ReflowPageContent` so lines stay readable on desktop.
- **Prefer lazy grids/lists** (`ReflowResponsiveGrid.builder`) for large
  collections.
- **Test by resizing.** Run on desktop and drag the window through all
  breakpoints; that one habit catches most adaptive bugs.

## References

- [Material 3 — Applying layout: window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)
- [Flutter — Adaptive design](https://docs.flutter.dev/ui/adaptive-responsive)
- [Codelab — Building an animated responsive layout with Material 3](https://codelabs.developers.google.com/codelabs/flutter-animated-responsive-layout)

## License

MIT — see [LICENSE](https://github.com/Sreeraj9764/responsive_reflow/blob/main/LICENSE).

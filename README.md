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

## Material 3 breakpoints

| Window size class | Width (logical px) | `RrBreakpoint`        | Typical navigation        |
| ----------------- | ------------------ | --------------------- | ------------------------- |
| Compact           | `< 600`            | `RrBreakpoint.compact`    | Bottom navigation bar |
| Medium            | `600 – 839`        | `RrBreakpoint.medium`     | Navigation rail (icons) |
| Expanded          | `840 – 1199`       | `RrBreakpoint.expanded`   | Full sidebar          |
| Large             | `1200 – 1599`      | `RrBreakpoint.large`      | Full sidebar          |
| Extra large       | `≥ 1600`           | `RrBreakpoint.extraLarge` | Full sidebar          |

Thresholds are configurable — see [Configurable breakpoints](#configurable-breakpoints).

## Features

- **Breakpoints** — `RrBreakpoint` enum with comparison operators
  (`>=`, `>`, `<=`, `<`) and helpers (`isCompact`, `isExpanded`, `showsSidebar`,
  `isMobileLayout`, `isDesktopLayout`).
- **Configurable thresholds** — `RrBreakpoints` (immutable config) +
  `RrBreakpointsTheme` (inherited override for a subtree).
- **Spacing tokens** — `RrSpacing`, `RrEdgeInsets`, `RrGap`, `RrRadius`.
- **Responsive builders** — `RrResponsiveBuilder` (window) and
  `RrConstraintResponsiveBuilder` (parent constraints), both with
  smaller-to-larger cascade fallback.
- **Responsive values & widgets** — `RrResponsiveValue<T>`,
  `RrResponsiveVisibility`, `RrResponsiveRowColumn`.
- **Adaptive scaffold** — `RrAdaptiveScaffold` auto-switches bottom nav → rail →
  sidebar, with FAB, optional desktop app bar, and animated transitions.
- **Constrained content** — `ConstrainedContent`, `RrPageContent`
  (max-width + responsive padding + safe area + scroll-position restoration).
- **Responsive grid** — `RrResponsiveGrid` and `RrResponsiveGrid.builder`
  (lazy) with width-derived column counts.
- **Input density** — `RrDensity` / `RrPointerModeDetector` for touch-vs-pointer
  `VisualDensity`.
- **Policy & capabilities** — `RrPolicy` (size-based decisions) and
  `RrCapability` (hardware/runtime facts).
- **Foldable awareness** — `RrDisplayFeatures` (hinge/fold detection).
- **Safe area & insets** — `RrSafeArea`, `RrInsets`.

## Usage

```dart
import 'package:responsive_reflow/responsive_reflow.dart';
```

### Responsive builder

```dart
RrResponsiveBuilder(
  compact: (context) => MobileLayout(),
  expanded: (context) => DesktopLayout(),
)
```

### Responsive value

```dart
final columns = const RrResponsiveValue<int>(
  compact: 1,
  medium: 2,
  expanded: 3,
).resolve(context);
```

### Responsive visibility & row/column

```dart
RrResponsiveVisibility(
  visibleFrom: RrBreakpoint.expanded,
  child: SecondaryPanel(),
)

RrResponsiveRowColumn(
  rowFrom: RrBreakpoint.medium,
  spacing: RrSpacing.lg,
  children: [LabelField(), ValueField()],
)
```

### Spacing tokens

```dart
Padding(padding: RrEdgeInsets.allLg, child: content)
Column(children: [widget1, RrGap.verticalSm, widget2])
```

### Adaptive scaffold

```dart
RrAdaptiveScaffold(
  destinations: const [
    RrDestination(icon: Icons.home, label: 'Home'),
    RrDestination(icon: Icons.calendar_month, label: 'Schedule'),
  ],
  currentIndex: navigationShell.currentIndex,
  onDestinationSelected: navigationShell.goBranch,
  body: navigationShell,
  floatingActionButton: const FloatingActionButton(...),
)
```

### Page content

```dart
RrPageContent(
  maxWidth: 1000,
  child: Column(children: [...]),
)
```

### Responsive grid (lazy)

```dart
RrResponsiveGrid.builder(
  maxItemWidth: 300,
  itemCount: items.length,
  itemBuilder: (context, i) => ItemCard(items[i]),
)
```

### Input density

```dart
Theme(
  data: Theme.of(context).copyWith(visualDensity: RrDensity.density),
  child: child,
)
```

### Configurable breakpoints

```dart
RrBreakpointsTheme(
  breakpoints: const RrBreakpoints(medium: 560, expanded: 900),
  child: app,
)
```

## References

- [Material 3 — Applying layout: window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)
- [Flutter — Adaptive design](https://docs.flutter.dev/ui/adaptive-responsive)
- [Codelab — Building an animated responsive layout with Material 3](https://codelabs.developers.google.com/codelabs/flutter-animated-responsive-layout)

## License

MIT — see [LICENSE](https://github.com/Sreeraj9764/responsive_reflow/blob/main/LICENSE).

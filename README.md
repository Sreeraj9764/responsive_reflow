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
- **Configurable thresholds** — `ReflowBreakpoints` (immutable config) +
  `ReflowBreakpointsTheme` (inherited override for a subtree).
- **Spacing tokens** — `ReflowSpacing`, `ReflowEdgeInsets`, `ReflowGap`, `ReflowRadius`.
- **Responsive builders** — `ReflowResponsiveBuilder` (window) and
  `ReflowConstraintResponsiveBuilder` (parent constraints), both with
  smaller-to-larger cascade fallback.
- **Responsive values & widgets** — `ReflowResponsiveValue<T>`,
  `ReflowResponsiveVisibility`, `ReflowResponsiveRowColumn`.
- **Adaptive scaffold** — `ReflowAdaptiveScaffold` auto-switches bottom nav → rail →
  sidebar, with FAB, optional desktop app bar, and animated transitions.
- **Constrained content** — `ConstrainedContent`, `ReflowPageContent`
  (max-width + responsive padding + safe area + scroll-position restoration).
- **Responsive grid** — `ReflowResponsiveGrid` and `ReflowResponsiveGrid.builder`
  (lazy) with width-derived column counts.
- **Input density** — `ReflowDensity` / `ReflowPointerModeDetector` for touch-vs-pointer
  `VisualDensity`.
- **Policy & capabilities** — `ReflowPolicy` (size-based decisions) and
  `ReflowCapability` (hardware/runtime facts).
- **Foldable awareness** — `ReflowDisplayFeatures` (hinge/fold detection).
- **Safe area & insets** — `ReflowSafeArea`, `ReflowInsets`.

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

## References

- [Material 3 — Applying layout: window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)
- [Flutter — Adaptive design](https://docs.flutter.dev/ui/adaptive-responsive)
- [Codelab — Building an animated responsive layout with Material 3](https://codelabs.developers.google.com/codelabs/flutter-animated-responsive-layout)

## License

MIT — see [LICENSE](https://github.com/Sreeraj9764/responsive_reflow/blob/main/LICENSE).

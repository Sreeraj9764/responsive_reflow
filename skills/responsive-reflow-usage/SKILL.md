---
name: responsive-reflow-usage
description: Use when building or refactoring Flutter UI with the responsive_reflow package to create responsive/adaptive layouts. Covers choosing the right widget (builders, adaptive scaffold, grid, tokens), breakpoint-driven reflow patterns, and migrating away from pixel-scaling approaches like flutter_screenutil.
---

# Using responsive_reflow

responsive_reflow implements **reflow-based** responsive design: layouts change
structure with available width (Material 3 window size classes), they are never
pixel-scaled. Follow these rules when generating code with this package.

## Core rules

- Branch on **window width or parent constraints**, never on device type,
  `Platform.isX`, or orientation.
- Never generate scaled dimensions (`.w`, `.h`, `.sp`, design-size math).
  Use `ReflowSpacing` tokens, flex factors, and max-width constraints instead.
- Screens branch on the **window** (`ReflowResponsiveBuilder`, `context.reflow`);
  reusable components branch on **their own constraints**
  (`ReflowConstraintResponsiveBuilder`).
- Font sizes are plain logical pixels or theme text styles — let system text
  scaling work.

## Breakpoints (Material 3 defaults, configurable via ReflowBreakpointsTheme)

| Breakpoint   | Width     | Typical navigation |
| ------------ | --------- | ------------------ |
| `compact`    | <600      | bottom bar         |
| `medium`     | 600–839   | rail               |
| `expanded`   | 840–1199  | sidebar, two panes |
| `large`      | 1200–1599 | sidebar            |
| `extraLarge` | ≥1600     | sidebar            |

## Choosing the right API

| Task                                          | API                                                                                                            |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Whole-screen layout switch                    | `ReflowResponsiveBuilder(compact: …, expanded: …)`                                                             |
| Reusable component adapting to its space      | `ReflowConstraintResponsiveBuilder`                                                                            |
| Per-breakpoint value (columns, flex, padding) | `ReflowResponsiveValue<T>(compact: …).resolve(context)`                                                        |
| Quick checks in build                         | `context.reflow.isCompact`, `.atLeast(ReflowBreakpoint.medium)`                                                |
| Show/hide by breakpoint                       | `ReflowResponsiveVisibility(visibleFrom: …)`                                                                   |
| Column on phones → Row on wide                | `ReflowResponsiveRowColumn(rowFrom: …)`                                                                        |
| App shell (bottom bar → rail → sidebar)       | `ReflowAdaptiveScaffold` / `.sectioned`                                                                        |
| List–detail split view                        | `ReflowAdaptiveScaffold(secondaryBody: …, bodyRatio: …)` (fold-aware, expanded+)                               |
| Readable content width on desktop             | `ReflowPageContent` / `ConstrainedContent`                                                                     |
| Width-derived grid columns                    | `ReflowResponsiveGrid(.builder)` with `maxItemWidth`, optional `minColumns`/`maxColumns` or `columns` override |
| Consistent spacing                            | `ReflowSpacing.lg`, `ReflowGap.verticalSm`, `ReflowEdgeInsets.allLg`                                           |
| M3 margins/gutters                            | `context.reflow.margin` / `.gutter` / `.pagePadding`                                                           |
| Mouse vs touch density                        | `ReflowDensity.density`, `ReflowPointerModeDetector`                                                           |
| Foldable hinge awareness                      | `ReflowDisplayFeatures`, or `secondaryBody` which splits at the hinge                                          |

## Canonical patterns

Screen-level branching with cascade fallback (missing breakpoints fall back to
the next smaller one):

```dart
ReflowResponsiveBuilder(
  compact: (context) => const MobileLayout(),
  expanded: (context) => const DesktopLayout(),
)
```

App shell for go_router `StatefulNavigationShell`:

```dart
ReflowAdaptiveScaffold(
  destinations: const [
    ReflowDestination(icon: Icons.home, label: 'Home'),
    ReflowDestination(icon: Icons.settings, label: 'Settings'),
  ],
  currentIndex: navigationShell.currentIndex,
  onDestinationSelected: navigationShell.goBranch,
  body: navigationShell,
)
```

Feature page root:

```dart
ReflowPageContent(
  maxWidth: 1000,
  child: Column(children: [...]),
)
```

Lazy grid that grows columns with width:

```dart
ReflowResponsiveGrid.builder(
  maxItemWidth: 300,
  itemCount: items.length,
  itemBuilder: (context, i) => ItemCard(items[i]),
)
```

## Anti-patterns to reject

- `MediaQuery.of(context).size.width * 0.5` → use `Expanded`/`FractionallySizedBox`.
- `if (Platform.isAndroid) … else …` for layout → branch on `context.reflow`.
- `OrientationBuilder` near the root for layout switching → use breakpoints.
- Locking orientation — breaks foldables and large-format requirements.
- Hardcoded spacing numbers → use `ReflowSpacing` tokens.
- Eager `ReflowResponsiveGrid(children: hugeList)` → use `.builder`.

## Verification

After layout changes, run `flutter test`, then run the app on desktop and
resize the window through every breakpoint checking for overflows and
navigation-pattern switches.

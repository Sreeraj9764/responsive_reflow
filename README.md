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

## Contents

- [Why reflow, not scale](#why-reflow-not-scale)
- [Material 3 breakpoints](#material-3-breakpoints)
- [Features](#features)
- [Which tool do I reach for?](#which-tool-do-i-reach-for)
- [Usage](#usage)
- [Recipes](#recipes)
  - [go_router: adaptive shell with StatefulShellRoute](#go_router-adaptive-shell-with-statefulshellroute)
  - [go_router: sectioned sidebar with links](#go_router-sectioned-sidebar-with-links)
  - [Adaptive list–detail (route on phones, pane on desktop)](#adaptive-listdetail-route-on-phones-pane-on-desktop)
  - [Multiple shells (auth vs app)](#multiple-shells-auth-vs-app)
  - [Other routers](#other-routers)
  - [Smaller building blocks](#smaller-building-blocks)
- [Migrating from flutter_screenutil](#migrating-from-flutter_screenutil)
- [Best practices](#best-practices)

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

## Recipes

Real-world wiring for the widgets above. The go_router snippets are
illustrative — this package has **no dependency on go_router**; it works with
any routing solution (or none) because the scaffold only needs an index and a
callback.

Every recipe here is also available as a **runnable app** in
[example/](example/README.md):
[example/lib/main.dart](example/lib/main.dart) (basics, no router),
[example/lib/go_router_app/main.dart](example/lib/go_router_app/main.dart)
(deep-linkable adaptive shell), and
[example/lib/auto_route_app/main.dart](example/lib/auto_route_app/main.dart)
(`AutoTabsRouter`).

### go_router: adaptive shell with StatefulShellRoute

`ReflowAdaptiveScaffold` was designed to be the shell of a
`StatefulShellRoute.indexedStack`. Each branch keeps its own navigator stack
and scroll state; the scaffold swaps navigation chrome per breakpoint around
the shell.

```dart
final router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/schedule', builder: (_, __) => const SchedulePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        ]),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return ReflowAdaptiveScaffold(
      destinations: const [
        ReflowDestination(icon: Icons.home_outlined, label: 'Home'),
        ReflowDestination(icon: Icons.calendar_month_outlined, label: 'Schedule'),
        ReflowDestination(icon: Icons.settings_outlined, label: 'Settings'),
      ],
      currentIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        // Re-tapping the active destination resets that branch to its root.
        initialLocation: index == navigationShell.currentIndex,
      ),
      body: navigationShell,
    );
  }
}
```

Notes:

- The scaffold is **stateless with respect to navigation** — it only reflects
  `currentIndex` and reports taps. All navigation state lives in the router.
- Because each branch is preserved by `indexedStack`, switching
  bottom bar ↔ rail ↔ sidebar on window resize does not lose branch state.
- Give branch pages a `ReflowPageContent` root so their content stays readable
  when the window is wide.

### go_router: sectioned sidebar with links

Dashboards often mix *primary* destinations (shell branches) with *secondary*
pages that live inside a branch (profile, help, …). Use
`ReflowAdaptiveScaffold.sectioned`: branches participate in selection and the
compact bottom bar, links just navigate.

```dart
ReflowAdaptiveScaffold.sectioned(
  sections: [
    const ReflowNavSection(
      title: 'MAIN',
      items: [
        ReflowNavItem.branch(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          branchIndex: 0,
          showInBottomBar: true,
        ),
        ReflowNavItem.branch(
          icon: Icons.bar_chart_outlined,
          label: 'Reports',
          branchIndex: 1,
          showInBottomBar: true,
        ),
      ],
    ),
    ReflowNavSection(
      title: 'ACCOUNT',
      items: [
        ReflowNavItem.link(
          icon: Icons.person_outline,
          label: 'Profile',
          // Highlight the link when its page is the current location.
          selected: GoRouterState.of(context).uri.path == '/settings/profile',
          onTap: () => context.go('/settings/profile'),
        ),
      ],
    ),
  ],
  currentIndex: navigationShell.currentIndex,
  onDestinationSelected: navigationShell.goBranch,
  body: navigationShell,
)
```

Notes:

- Only branch items with `showInBottomBar: true` appear in the compact bottom
  bar; links never do. If nothing opts in, the scaffold falls back to all
  branch items (and hides the bar entirely if fewer than two exist).
- Derive a link's `selected:` from the current location so the sidebar
  highlight follows deep links and back navigation, not just taps.

### Adaptive list–detail (route on phones, pane on desktop)

The canonical adaptive pattern: selecting an item **pushes a route** on
compact windows but **fills the secondary pane** on expanded+ windows.
Keep the selection in state; branch in the tap handler.

```dart
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  Message? _selected;

  @override
  Widget build(BuildContext context) {
    return ReflowAdaptiveScaffold(
      destinations: destinations,
      currentIndex: 0,
      onDestinationSelected: onSelect,
      body: MessageList(
        selected: _selected,
        onMessageTap: (message) {
          if (context.reflow.isDesktopLayout) {
            // Wide window → show it in the detail pane.
            setState(() => _selected = message);
          } else {
            // Phone-sized window → navigate to a full detail page.
            context.push('/inbox/${message.id}');
          }
        },
      ),
      secondaryBody: _selected == null
          ? const EmptyDetailPlaceholder()
          : MessageDetail(message: _selected!),
      bodyRatio: 0.4, // 40% list, 60% detail
    );
  }
}
```

Notes:

- Also register the `/inbox/:id` route — it serves compact windows *and* makes
  detail pages deep-linkable on every size.
- `secondaryBody` is automatically hidden below expanded, and on foldables the
  panes split at the hinge instead of `bodyRatio`.
- If the user resizes from compact to expanded while a pushed detail page is
  open, pop it and promote the selection to the pane (listen to the breakpoint
  in `didChangeDependencies` or compare in `build`).

### Multiple shells (auth vs app)

Different areas of an app can use different shells. Only the signed-in area
needs adaptive navigation:

```dart
final router = GoRouter(
  routes: [
    // Auth flow: plain pages, no navigation chrome.
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupPage()),

    // Signed-in area: adaptive shell.
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [/* … */],
    ),
  ],
);
```

Nested shells also work: a branch page can host its own `TabBar` or a nested
`StatefulShellRoute` — `ReflowAdaptiveScaffold` only owns the *outer* chrome
(bottom bar / rail / sidebar) and never touches inner navigators. Wrap inner
layouts in `ReflowConstraintResponsiveBuilder` so they adapt to the space that
remains after the sidebar takes its width.

### Other routers

The scaffold needs only `currentIndex` + `onDestinationSelected`, so any
state-driven approach works:

- **Navigator 1.0 / no router** — keep an index in state and swap bodies
  (see [example/lib/main.dart](example/lib/main.dart)):

  ```dart
  ReflowAdaptiveScaffold(
    destinations: destinations,
    currentIndex: _index,
    onDestinationSelected: (i) => setState(() => _index = i),
    body: IndexedStack(index: _index, children: pages),
  )
  ```

- **auto_route** — wrap with `AutoTabsRouter` and map
  `tabsRouter.activeIndex` → `currentIndex` and
  `tabsRouter.setActiveIndex` → `onDestinationSelected`.
- **beamer** — use a `BeamerDelegate` per tab and drive `currentIndex` from
  the active delegate, calling `beamer.update()` on selection.

### Smaller building blocks

**`ReflowPointerModeDetector`** — install once at the root via
`MaterialApp.builder` so the whole app densifies for mouse users:

```dart
MaterialApp.router(
  routerConfig: router,
  builder: (context, child) => ReflowPointerModeDetector(
    builder: (context, mode) => Theme(
      data: Theme.of(context).copyWith(
        visualDensity: ReflowDensity.densityFor(mode),
      ),
      child: child!,
    ),
  ),
)
```

**`ReflowPolicy`** — size-based decisions outside the widget tree (blocs,
controllers, tests) without importing widget code:

```dart
const policy = ReflowPolicy();
if (policy.shouldUseMultiPane(windowWidth)) { /* preload detail data */ }

// In tests: verify decisions at exact widths, no widget pumping needed.
expect(policy.shouldUseSidebar(840), isTrue);
```

**`ReflowInsets`** — targeted MediaQuery lookups that only rebuild on the
relevant change:

```dart
// Hide the FAB while the keyboard is open:
floatingActionButton:
    ReflowInsets.keyboardVisible(context) ? null : const AddButton(),
```

**`ReflowSafeArea`** — wrap the *body*, not the whole `Scaffold`, so the app
bar keeps managing its own insets:

```dart
Scaffold(
  appBar: AppBar(title: const Text('Title')),
  body: ReflowSafeArea(top: false, child: content),
)
```

**`ReflowDisplayFeatures`** — manual hinge handling when you are not using
`secondaryBody`:

```dart
final fold = ReflowDisplayFeatures.verticalFold(context);
if (fold != null) {
  // Build your own two-pane layout on either side of fold.bounds.
}
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

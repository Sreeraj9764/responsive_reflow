## 1.2.0

 - **REFACTOR**: rename Rr* classes to Reflow* for consistency and clarity. ([52242a80](https://github.com/Sreeraj9764/responsive_reflow/commit/52242a80ddf8687edd26b4660d326112d852ac9e))
 - **FEAT**: Add example apps for go_router and auto_route integration. ([c36f2804](https://github.com/Sreeraj9764/responsive_reflow/commit/c36f28046ba1cdb6469c3406a2e2ef5976c70c69))
 - **FEAT**: update README with additional contents and recipes for adaptive layouts. ([9dd99e9a](https://github.com/Sreeraj9764/responsive_reflow/commit/9dd99e9a3edc3fc85d5ebe7d4ff8b6b2f3d9d9b7))
 - **FEAT**: enhance responsive reflow package with new context and adaptive features. ([6bfc90d2](https://github.com/Sreeraj9764/responsive_reflow/commit/6bfc90d26ffe0bf63cbf666af1b90813646768b3))

## 1.1.0

 - **FEAT**: Add melos badge to README. ([360f8743](https://github.com/Sreeraj9764/responsive_reflow/commit/360f8743d7f97007f5de229a09f7d8aa5733cfde))
 - **FEAT**: Add responsive layout utilities. ([915962a7](https://github.com/Sreeraj9764/responsive_reflow/commit/915962a7e9e97fe420dce52f080c8e13bb4cde29))

## 1.0.0

Initial public release.

- Material 3 window size-class breakpoints (`ReflowBreakpoint`, `ReflowBreakpoints`,
  `ReflowBreakpointsTheme`) with configurable thresholds.
- Spacing tokens: `ReflowSpacing`, `ReflowEdgeInsets`, `ReflowGap`, `ReflowRadius`.
- Responsive builders: `ReflowResponsiveBuilder`,
  `ReflowConstraintResponsiveBuilder`, with smaller-to-larger cascade fallback.
- Responsive values & widgets: `ReflowResponsiveValue<T>`,
  `ReflowResponsiveVisibility`, `ReflowResponsiveRowColumn`.
- Adaptive navigation scaffold `ReflowAdaptiveScaffold` (bottom nav → rail → sidebar).
- Constrained content: `ConstrainedContent`, `ReflowPageContent`.
- Responsive grid: `ReflowResponsiveGrid` and `ReflowResponsiveGrid.builder`.
- Input density helpers: `ReflowDensity`, `ReflowPointerModeDetector`.
- Policy & capabilities: `ReflowPolicy`, `ReflowCapability`.
- Foldable awareness: `ReflowDisplayFeatures`.
- Safe-area & insets: `ReflowSafeArea`, `ReflowInsets`.

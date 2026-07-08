import 'package:flutter/widgets.dart';

/// Application-level breakpoint classifications based on
/// [Material 3 window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes).
///
/// Branch on the window **size**, never on the device type. The thresholds
/// can be customised per app via [ReflowBreakpointsTheme]; the defaults follow
/// the Material 3 recommendation:
///
/// - compact: phones (<600px) — bottom navigation, single column
/// - medium: tablet portrait / large phones (600–839px) — navigation rail
/// - expanded: tablet landscape / small desktops (840–1199px) — multi-pane
/// - large: desktops (1200–1599px) — full multi-pane with sidebar
/// - extraLarge: wide desktops (≥1600px)
enum ReflowBreakpoint {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  /// Returns the breakpoint for [width] using the Material 3 default
  /// thresholds. To honour app-level overrides, prefer [of] or
  /// [ReflowBreakpoints.fromWidth].
  static ReflowBreakpoint fromWidth(double width) =>
      ReflowBreakpoints.material3.fromWidth(width);

  /// Returns the current breakpoint using [MediaQuery.sizeOf].
  ///
  /// Honours a [ReflowBreakpointsTheme] ancestor if one is present, otherwise
  /// falls back to the Material 3 default thresholds.
  static ReflowBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ReflowBreakpoints.of(context).fromWidth(width);
  }

  /// Whether this breakpoint is at least [other].
  bool operator >=(ReflowBreakpoint other) => index >= other.index;

  /// Whether this breakpoint is greater than [other].
  bool operator >(ReflowBreakpoint other) => index > other.index;

  /// Whether this breakpoint is at most [other].
  bool operator <=(ReflowBreakpoint other) => index <= other.index;

  /// Whether this breakpoint is less than [other].
  bool operator <(ReflowBreakpoint other) => index < other.index;

  /// Whether the current breakpoint shows a bottom navigation bar.
  bool get isCompact => this == ReflowBreakpoint.compact;

  /// Whether the current breakpoint shows a navigation rail.
  bool get isMedium => this == ReflowBreakpoint.medium;

  /// Whether the current breakpoint is expanded.
  bool get isExpanded => this == ReflowBreakpoint.expanded;

  /// Whether the current breakpoint is large.
  bool get isLarge => this == ReflowBreakpoint.large;

  /// Whether the current breakpoint is extra large.
  bool get isExtraLarge => this == ReflowBreakpoint.extraLarge;

  /// Whether the current breakpoint shows a full sidebar.
  bool get showsSidebar => index >= ReflowBreakpoint.expanded.index;

  /// Whether the current breakpoint is mobile-like (compact or medium).
  bool get isMobileLayout => index <= ReflowBreakpoint.medium.index;

  /// Whether the current breakpoint is desktop-like (expanded or larger).
  bool get isDesktopLayout => index >= ReflowBreakpoint.expanded.index;
}

/// The set of width thresholds that map a window width to a [ReflowBreakpoint].
///
/// Each threshold marks the **lower bound** (inclusive) of the corresponding
/// breakpoint. Anything below [medium] is [ReflowBreakpoint.compact].
///
/// The Material 3 defaults are exposed via [ReflowBreakpoints.material3]. Apps may
/// provide custom thresholds and share them through [ReflowBreakpointsTheme].
@immutable
class ReflowBreakpoints {
  const ReflowBreakpoints({
    this.medium = 600,
    this.expanded = 840,
    this.large = 1200,
    this.extraLarge = 1600,
  })  : assert(
          0 < medium && medium < expanded,
          'medium must be greater than 0 and less than expanded',
        ),
        assert(
          expanded < large && large < extraLarge,
          'thresholds must be strictly increasing',
        );

  /// Material 3 window size class thresholds (600 / 840 / 1200 / 1600).
  static const ReflowBreakpoints material3 = ReflowBreakpoints();

  /// Lower bound (inclusive) of [ReflowBreakpoint.medium].
  final double medium;

  /// Lower bound (inclusive) of [ReflowBreakpoint.expanded].
  final double expanded;

  /// Lower bound (inclusive) of [ReflowBreakpoint.large].
  final double large;

  /// Lower bound (inclusive) of [ReflowBreakpoint.extraLarge].
  final double extraLarge;

  /// Maps a window [width] to its [ReflowBreakpoint].
  ReflowBreakpoint fromWidth(double width) {
    if (width >= extraLarge) return ReflowBreakpoint.extraLarge;
    if (width >= large) return ReflowBreakpoint.large;
    if (width >= expanded) return ReflowBreakpoint.expanded;
    if (width >= medium) return ReflowBreakpoint.medium;
    return ReflowBreakpoint.compact;
  }

  /// Returns the lower-bound width of [breakpoint] under these thresholds.
  double lowerBoundOf(ReflowBreakpoint breakpoint) => switch (breakpoint) {
        ReflowBreakpoint.compact => 0,
        ReflowBreakpoint.medium => medium,
        ReflowBreakpoint.expanded => expanded,
        ReflowBreakpoint.large => large,
        ReflowBreakpoint.extraLarge => extraLarge,
      };

  /// Returns the [ReflowBreakpoints] from the nearest [ReflowBreakpointsTheme]
  /// ancestor, or the Material 3 defaults if none is present.
  static ReflowBreakpoints of(BuildContext context) {
    return ReflowBreakpointsTheme.maybeOf(context) ?? material3;
  }

  ReflowBreakpoints copyWith({
    double? medium,
    double? expanded,
    double? large,
    double? extraLarge,
  }) {
    return ReflowBreakpoints(
      medium: medium ?? this.medium,
      expanded: expanded ?? this.expanded,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflowBreakpoints &&
          runtimeType == other.runtimeType &&
          medium == other.medium &&
          expanded == other.expanded &&
          large == other.large &&
          extraLarge == other.extraLarge;

  @override
  int get hashCode => Object.hash(medium, expanded, large, extraLarge);

  @override
  String toString() =>
      'ReflowBreakpoints(medium: $medium, expanded: $expanded, '
      'large: $large, extraLarge: $extraLarge)';
}

/// Provides custom [ReflowBreakpoints] to a widget subtree.
///
/// Place near the root of the app to override the Material 3 default
/// thresholds everywhere:
///
/// ```dart
/// ReflowBreakpointsTheme(
///   breakpoints: const ReflowBreakpoints(medium: 560, expanded: 900),
///   child: MyApp(),
/// )
/// ```
class ReflowBreakpointsTheme extends InheritedWidget {
  const ReflowBreakpointsTheme({
    super.key,
    required this.breakpoints,
    required super.child,
  });

  /// The thresholds applied to descendants.
  final ReflowBreakpoints breakpoints;

  /// Returns the nearest ancestor [ReflowBreakpoints], or null if none.
  static ReflowBreakpoints? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ReflowBreakpointsTheme>()
        ?.breakpoints;
  }

  @override
  bool updateShouldNotify(ReflowBreakpointsTheme oldWidget) =>
      breakpoints != oldWidget.breakpoints;
}

/// Material 3 default width thresholds for quick manual comparisons.
///
/// Prefer [ReflowBreakpoint.of] or [ReflowBreakpoints] for layout decisions; these
/// constants exist only for rare inline checks.
abstract final class ReflowBreakpointWidth {
  static const double compact = 0;
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;
  static const double extraLarge = 1600;
}

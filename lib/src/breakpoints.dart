import 'package:flutter/widgets.dart';

/// Application-level breakpoint classifications based on
/// [Material 3 window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes).
///
/// Branch on the window **size**, never on the device type. The thresholds
/// can be customised per app via [RrBreakpointsTheme]; the defaults follow
/// the Material 3 recommendation:
///
/// - compact: phones (<600px) — bottom navigation, single column
/// - medium: tablet portrait / large phones (600–839px) — navigation rail
/// - expanded: tablet landscape / small desktops (840–1199px) — multi-pane
/// - large: desktops (1200–1599px) — full multi-pane with sidebar
/// - extraLarge: wide desktops (≥1600px)
enum RrBreakpoint {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  /// Returns the breakpoint for [width] using the Material 3 default
  /// thresholds. To honour app-level overrides, prefer [of] or
  /// [RrBreakpoints.fromWidth].
  static RrBreakpoint fromWidth(double width) =>
      RrBreakpoints.material3.fromWidth(width);

  /// Returns the current breakpoint using [MediaQuery.sizeOf].
  ///
  /// Honours a [RrBreakpointsTheme] ancestor if one is present, otherwise
  /// falls back to the Material 3 default thresholds.
  static RrBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return RrBreakpoints.of(context).fromWidth(width);
  }

  /// Whether this breakpoint is at least [other].
  bool operator >=(RrBreakpoint other) => index >= other.index;

  /// Whether this breakpoint is greater than [other].
  bool operator >(RrBreakpoint other) => index > other.index;

  /// Whether this breakpoint is at most [other].
  bool operator <=(RrBreakpoint other) => index <= other.index;

  /// Whether this breakpoint is less than [other].
  bool operator <(RrBreakpoint other) => index < other.index;

  /// Whether the current breakpoint shows a bottom navigation bar.
  bool get isCompact => this == RrBreakpoint.compact;

  /// Whether the current breakpoint shows a navigation rail.
  bool get isMedium => this == RrBreakpoint.medium;

  /// Whether the current breakpoint is expanded.
  bool get isExpanded => this == RrBreakpoint.expanded;

  /// Whether the current breakpoint is large.
  bool get isLarge => this == RrBreakpoint.large;

  /// Whether the current breakpoint is extra large.
  bool get isExtraLarge => this == RrBreakpoint.extraLarge;

  /// Whether the current breakpoint shows a full sidebar.
  bool get showsSidebar => index >= RrBreakpoint.expanded.index;

  /// Whether the current breakpoint is mobile-like (compact or medium).
  bool get isMobileLayout => index <= RrBreakpoint.medium.index;

  /// Whether the current breakpoint is desktop-like (expanded or larger).
  bool get isDesktopLayout => index >= RrBreakpoint.expanded.index;
}

/// The set of width thresholds that map a window width to a [RrBreakpoint].
///
/// Each threshold marks the **lower bound** (inclusive) of the corresponding
/// breakpoint. Anything below [medium] is [RrBreakpoint.compact].
///
/// The Material 3 defaults are exposed via [RrBreakpoints.material3]. Apps may
/// provide custom thresholds and share them through [RrBreakpointsTheme].
@immutable
class RrBreakpoints {
  const RrBreakpoints({
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
  static const RrBreakpoints material3 = RrBreakpoints();

  /// Lower bound (inclusive) of [RrBreakpoint.medium].
  final double medium;

  /// Lower bound (inclusive) of [RrBreakpoint.expanded].
  final double expanded;

  /// Lower bound (inclusive) of [RrBreakpoint.large].
  final double large;

  /// Lower bound (inclusive) of [RrBreakpoint.extraLarge].
  final double extraLarge;

  /// Maps a window [width] to its [RrBreakpoint].
  RrBreakpoint fromWidth(double width) {
    if (width >= extraLarge) return RrBreakpoint.extraLarge;
    if (width >= large) return RrBreakpoint.large;
    if (width >= expanded) return RrBreakpoint.expanded;
    if (width >= medium) return RrBreakpoint.medium;
    return RrBreakpoint.compact;
  }

  /// Returns the lower-bound width of [breakpoint] under these thresholds.
  double lowerBoundOf(RrBreakpoint breakpoint) => switch (breakpoint) {
        RrBreakpoint.compact => 0,
        RrBreakpoint.medium => medium,
        RrBreakpoint.expanded => expanded,
        RrBreakpoint.large => large,
        RrBreakpoint.extraLarge => extraLarge,
      };

  /// Returns the [RrBreakpoints] from the nearest [RrBreakpointsTheme]
  /// ancestor, or the Material 3 defaults if none is present.
  static RrBreakpoints of(BuildContext context) {
    return RrBreakpointsTheme.maybeOf(context) ?? material3;
  }

  RrBreakpoints copyWith({
    double? medium,
    double? expanded,
    double? large,
    double? extraLarge,
  }) {
    return RrBreakpoints(
      medium: medium ?? this.medium,
      expanded: expanded ?? this.expanded,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RrBreakpoints &&
          runtimeType == other.runtimeType &&
          medium == other.medium &&
          expanded == other.expanded &&
          large == other.large &&
          extraLarge == other.extraLarge;

  @override
  int get hashCode => Object.hash(medium, expanded, large, extraLarge);

  @override
  String toString() => 'RrBreakpoints(medium: $medium, expanded: $expanded, '
      'large: $large, extraLarge: $extraLarge)';
}

/// Provides custom [RrBreakpoints] to a widget subtree.
///
/// Place near the root of the app to override the Material 3 default
/// thresholds everywhere:
///
/// ```dart
/// RrBreakpointsTheme(
///   breakpoints: const RrBreakpoints(medium: 560, expanded: 900),
///   child: MyApp(),
/// )
/// ```
class RrBreakpointsTheme extends InheritedWidget {
  const RrBreakpointsTheme({
    super.key,
    required this.breakpoints,
    required super.child,
  });

  /// The thresholds applied to descendants.
  final RrBreakpoints breakpoints;

  /// Returns the nearest ancestor [RrBreakpoints], or null if none.
  static RrBreakpoints? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<RrBreakpointsTheme>()
        ?.breakpoints;
  }

  @override
  bool updateShouldNotify(RrBreakpointsTheme oldWidget) =>
      breakpoints != oldWidget.breakpoints;
}

/// Material 3 default width thresholds for quick manual comparisons.
///
/// Prefer [RrBreakpoint.of] or [RrBreakpoints] for layout decisions; these
/// constants exist only for rare inline checks.
abstract final class RrBreakpointWidth {
  static const double compact = 0;
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;
  static const double extraLarge = 1600;
}

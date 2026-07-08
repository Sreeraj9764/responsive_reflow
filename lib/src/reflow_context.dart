import 'package:flutter/widgets.dart';

import 'breakpoints.dart';
import 'display_features.dart';
import 'pointer_density.dart';
import 'responsive_padding.dart';
import 'spacing.dart';

/// Ergonomic access to the package's responsive primitives from a
/// [BuildContext].
///
/// ```dart
/// final reflow = context.reflow;
/// if (reflow.isCompact) { ... }
/// Padding(padding: reflow.pagePadding, child: ...);
/// ```
extension ReflowContext on BuildContext {
  /// Responsive information derived from this context's window metrics.
  ReflowSizing get reflow => ReflowSizing._(this);
}

/// A snapshot of responsive information for a [BuildContext].
///
/// Obtain via [ReflowContext.reflow] (`context.reflow`). All values are
/// window-derived and honour a [ReflowBreakpointsTheme] ancestor.
///
/// This intentionally exposes *size classes*, never device types — branch on
/// the space you have, not on the hardware you think you are on.
class ReflowSizing {
  ReflowSizing._(this._context);

  final BuildContext _context;

  /// The current window breakpoint.
  ReflowBreakpoint get breakpoint => ReflowBreakpoint.of(_context);

  /// The active breakpoint thresholds (theme override or Material 3 defaults).
  ReflowBreakpoints get breakpoints => ReflowBreakpoints.of(_context);

  /// The current window width in logical pixels.
  double get width => MediaQuery.sizeOf(_context).width;

  /// The current window size in logical pixels.
  Size get size => MediaQuery.sizeOf(_context);

  /// The current window orientation.
  ///
  /// Prefer branching on [breakpoint] for layout decisions; orientation is
  /// mostly useful as a secondary signal (e.g. media playback).
  Orientation get orientation => MediaQuery.orientationOf(_context);

  // --- Breakpoint checks ---

  /// Whether the window is compact (<600px by default).
  bool get isCompact => breakpoint.isCompact;

  /// Whether the window is medium (600–839px by default).
  bool get isMedium => breakpoint.isMedium;

  /// Whether the window is expanded (840–1199px by default).
  bool get isExpanded => breakpoint.isExpanded;

  /// Whether the window is large (1200–1599px by default).
  bool get isLarge => breakpoint.isLarge;

  /// Whether the window is extra large (≥1600px by default).
  bool get isExtraLarge => breakpoint.isExtraLarge;

  /// Whether the window is mobile-like (compact or medium).
  bool get isMobileLayout => breakpoint.isMobileLayout;

  /// Whether the window is desktop-like (expanded or larger).
  bool get isDesktopLayout => breakpoint.isDesktopLayout;

  /// Whether the current breakpoint is at least [other].
  ///
  /// ```dart
  /// if (context.reflow.atLeast(ReflowBreakpoint.medium)) { ... }
  /// ```
  bool atLeast(ReflowBreakpoint other) => breakpoint >= other;

  /// Whether the current breakpoint is at most [other].
  bool atMost(ReflowBreakpoint other) => breakpoint <= other;

  // --- Spacing ---

  /// Breakpoint-scaled horizontal page padding
  /// (16 / 24 / 32 / 48 — see [reflowHorizontalPadding]).
  double get horizontalPadding => reflowHorizontalPadding(_context);

  /// Breakpoint-scaled vertical page padding
  /// (16 / 16 / 24 / 32 — see [reflowVerticalPadding]).
  double get verticalPadding => reflowVerticalPadding(_context);

  /// Symmetric page padding combining [horizontalPadding] and
  /// [verticalPadding].
  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      );

  /// The Material 3 window margin for the current breakpoint:
  /// 16dp on compact, 24dp on medium and above.
  double get margin => isCompact ? ReflowSpacing.lg : ReflowSpacing.xl;

  /// The Material 3 gutter (space between panes/columns) for the current
  /// breakpoint: 16dp on compact, 24dp on medium and above.
  double get gutter => margin;

  // --- Capabilities ---

  /// Whether the window is currently split by a vertical fold/hinge.
  bool get hasVerticalFold => ReflowDisplayFeatures.hasVerticalFold(_context);

  /// The likely input mode for the ambient platform (heuristic).
  ///
  /// For per-event accuracy wrap a region in [ReflowPointerModeDetector].
  ReflowInputMode get inputMode => ReflowDensity.inputMode;
}

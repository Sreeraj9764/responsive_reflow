import 'package:flutter/widgets.dart';
import 'breakpoints.dart';

/// Describes what the current environment *can* do (hardware/runtime facts).
///
/// Keep this separate from [ReflowPolicy], which decides what the app *should* do.
/// Implement against real capability checks (camera, multi-window, etc.) or
/// override in tests.
abstract interface class ReflowCapability {
  /// Whether a physical/virtual camera is available.
  bool get hasCamera;

  /// Whether the platform supports running multiple app windows.
  bool get supportsMultiWindow;
}

/// Decides what the app *should* do, branching on window size and capabilities
/// rather than device type.
///
/// Methods are named for what they branch on (`shouldUseNavRail`), never for a
/// device ("isTablet"). This keeps decisions testable — inject a custom policy
/// in tests or per environment.
class ReflowPolicy {
  const ReflowPolicy({this.breakpoints = ReflowBreakpoints.material3});

  /// Thresholds used for size-based decisions.
  final ReflowBreakpoints breakpoints;

  /// Whether to show a navigation rail (or wider) instead of a bottom bar.
  ///
  /// True at the medium breakpoint and above (≥600 by default).
  bool shouldUseNavRail(double windowWidth) =>
      breakpoints.fromWidth(windowWidth) >= ReflowBreakpoint.medium;

  /// Whether to show a full, labelled sidebar instead of a collapsed rail.
  ///
  /// True at the expanded breakpoint and above (≥840 by default).
  bool shouldUseSidebar(double windowWidth) =>
      breakpoints.fromWidth(windowWidth) >= ReflowBreakpoint.expanded;

  /// Whether to lay content out across multiple panes.
  bool shouldUseMultiPane(double windowWidth) =>
      breakpoints.fromWidth(windowWidth) >= ReflowBreakpoint.expanded;

  /// Convenience overloads reading the window width from [context].
  bool shouldUseNavRailOf(BuildContext context) =>
      shouldUseNavRail(MediaQuery.sizeOf(context).width);

  bool shouldUseSidebarOf(BuildContext context) =>
      shouldUseSidebar(MediaQuery.sizeOf(context).width);

  bool shouldUseMultiPaneOf(BuildContext context) =>
      shouldUseMultiPane(MediaQuery.sizeOf(context).width);
}

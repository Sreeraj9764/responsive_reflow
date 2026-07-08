import 'package:flutter/widgets.dart';
import 'breakpoints.dart';
import 'spacing.dart';

/// Provides breakpoint-aware padding that adjusts based on screen size.
///
/// Larger screens get more padding, smaller screens get less.
///
/// ```dart
/// ReflowResponsivePadding(
///   child: MyContent(),
/// )
/// ```
class ReflowResponsivePadding extends StatelessWidget {
  const ReflowResponsivePadding({
    super.key,
    required this.child,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
  });

  final Widget child;

  /// Padding for compact screens. Defaults to horizontal 16.
  final EdgeInsetsGeometry? compact;

  /// Padding for medium screens. Defaults to horizontal 24.
  final EdgeInsetsGeometry? medium;

  /// Padding for expanded screens. Defaults to horizontal 32.
  final EdgeInsetsGeometry? expanded;

  /// Padding for large/extra-large screens. Defaults to horizontal 48.
  final EdgeInsetsGeometry? large;

  static const _defaultCompact =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.lg);
  static const _defaultMedium =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.xl);
  static const _defaultExpanded =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.xxl);
  static const _defaultLarge =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.xxxl);

  @override
  Widget build(BuildContext context) {
    final breakpoint = ReflowBreakpoint.of(context);

    final padding = switch (breakpoint) {
      ReflowBreakpoint.extraLarge ||
      ReflowBreakpoint.large =>
        large ?? _defaultLarge,
      ReflowBreakpoint.expanded => expanded ?? _defaultExpanded,
      ReflowBreakpoint.medium => medium ?? _defaultMedium,
      ReflowBreakpoint.compact => compact ?? _defaultCompact,
    };

    return Padding(padding: padding, child: child);
  }
}

/// Returns breakpoint-appropriate horizontal padding value.
double gsResponsiveHorizontalPadding(BuildContext context) {
  final breakpoint = ReflowBreakpoint.of(context);
  return switch (breakpoint) {
    ReflowBreakpoint.extraLarge || ReflowBreakpoint.large => ReflowSpacing.xxxl,
    ReflowBreakpoint.expanded => ReflowSpacing.xxl,
    ReflowBreakpoint.medium => ReflowSpacing.xl,
    ReflowBreakpoint.compact => ReflowSpacing.lg,
  };
}

import 'package:flutter/widgets.dart';
import 'breakpoints.dart';
import 'spacing.dart';

/// Provides breakpoint-aware padding that adjusts based on screen size.
///
/// Larger screens get more padding, smaller screens get less.
///
/// ```dart
/// RrResponsivePadding(
///   child: MyContent(),
/// )
/// ```
class RrResponsivePadding extends StatelessWidget {
  const RrResponsivePadding({
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

  static const _defaultCompact = EdgeInsets.symmetric(horizontal: RrSpacing.lg);
  static const _defaultMedium = EdgeInsets.symmetric(horizontal: RrSpacing.xl);
  static const _defaultExpanded =
      EdgeInsets.symmetric(horizontal: RrSpacing.xxl);
  static const _defaultLarge = EdgeInsets.symmetric(horizontal: RrSpacing.xxxl);

  @override
  Widget build(BuildContext context) {
    final breakpoint = RrBreakpoint.of(context);

    final padding = switch (breakpoint) {
      RrBreakpoint.extraLarge || RrBreakpoint.large => large ?? _defaultLarge,
      RrBreakpoint.expanded => expanded ?? _defaultExpanded,
      RrBreakpoint.medium => medium ?? _defaultMedium,
      RrBreakpoint.compact => compact ?? _defaultCompact,
    };

    return Padding(padding: padding, child: child);
  }
}

/// Returns breakpoint-appropriate horizontal padding value.
double gsResponsiveHorizontalPadding(BuildContext context) {
  final breakpoint = RrBreakpoint.of(context);
  return switch (breakpoint) {
    RrBreakpoint.extraLarge || RrBreakpoint.large => RrSpacing.xxxl,
    RrBreakpoint.expanded => RrSpacing.xxl,
    RrBreakpoint.medium => RrSpacing.xl,
    RrBreakpoint.compact => RrSpacing.lg,
  };
}

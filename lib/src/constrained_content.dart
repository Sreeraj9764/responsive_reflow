import 'package:flutter/widgets.dart';
import 'responsive_padding.dart';
import 'spacing.dart';

/// Wraps content with a max-width constraint, centered on large screens.
///
/// Prevents content from stretching to full width on ultra-wide displays,
/// following the Flutter large-screen guidance ("don't gobble up all of the
/// horizontal space").
///
/// ```dart
/// ConstrainedContent(
///   child: MyPageContent(),
/// )
/// ```
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  /// The content to constrain.
  final Widget child;

  /// Maximum width for the content area. Defaults to 1200.
  final double maxWidth;

  /// Optional padding around the constrained content.
  final EdgeInsetsGeometry? padding;

  /// Alignment of the constrained content within the available space.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    Widget content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return content;
  }
}

/// A page wrapper that constrains content width, applies breakpoint-aware
/// horizontal padding, and insets content within the device's safe area.
///
/// Use this as the root of feature screens.
///
/// ```dart
/// RrPageContent(
///   child: Column(children: [...]),
/// )
/// ```
class RrPageContent extends StatelessWidget {
  const RrPageContent({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
    this.verticalPadding = RrSpacing.lg,
    this.scrollable = true,
    this.safeArea = true,
    this.storageKey,
    this.alignment = Alignment.topCenter,
  });

  /// The page content.
  final Widget child;

  /// Maximum content width on large screens.
  final double maxWidth;

  /// Explicit padding override. When null, horizontal padding scales with the
  /// breakpoint (see [gsResponsiveHorizontalPadding]) and vertical padding
  /// uses [verticalPadding].
  final EdgeInsetsGeometry? padding;

  /// Vertical padding applied when [padding] is null.
  final double verticalPadding;

  /// Whether the content scrolls vertically.
  final bool scrollable;

  /// Whether to inset content within the device safe area (notches, status
  /// bar, rounded corners). Defaults to true.
  final bool safeArea;

  /// Optional key used to preserve scroll position across rebuilds, rotation,
  /// and fold/unfold. Only applies when [scrollable] is true.
  final PageStorageKey<dynamic>? storageKey;

  /// Alignment of the constrained content within the available width.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: gsResponsiveHorizontalPadding(context),
          vertical: verticalPadding,
        );

    Widget content = Padding(
      padding: resolvedPadding,
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        key: storageKey,
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}

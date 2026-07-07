import 'package:flutter/widgets.dart';
import 'spacing.dart';

/// A responsive grid that uses [SliverGridDelegateWithMaxCrossAxisExtent]
/// to automatically calculate column count based on available width.
///
/// The column count is derived from the window/parent width and
/// [maxItemWidth], never from device type — following the official Flutter
/// large-screen guidance.
///
/// ```dart
/// RrResponsiveGrid(
///   maxItemWidth: 300,
///   children: items.map((i) => ItemCard(i)).toList(),
/// )
/// ```
///
/// For long lists, prefer [RrResponsiveGrid.builder] so only visible items
/// are built.
class RrResponsiveGrid extends StatelessWidget {
  const RrResponsiveGrid({
    super.key,
    required this.children,
    this.maxItemWidth = 300,
    this.mainAxisSpacing = RrSpacing.lg,
    this.crossAxisSpacing = RrSpacing.lg,
    this.childAspectRatio = 1.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  })  : itemCount = null,
        itemBuilder = null;

  /// Lazy variant that builds only the visible items via [itemBuilder].
  ///
  /// Use this for large collections to avoid building every item up front.
  const RrResponsiveGrid.builder({
    super.key,
    required int this.itemCount,
    required Widget Function(BuildContext context, int index) this.itemBuilder,
    this.maxItemWidth = 300,
    this.mainAxisSpacing = RrSpacing.lg,
    this.crossAxisSpacing = RrSpacing.lg,
    this.childAspectRatio = 1.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : children = const [];

  /// Grid items (eager constructor). Empty for [RrResponsiveGrid.builder].
  final List<Widget> children;

  /// Number of items for the lazy [RrResponsiveGrid.builder] constructor.
  final int? itemCount;

  /// Item builder for the lazy [RrResponsiveGrid.builder] constructor.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Maximum width for each grid item. Columns auto-calculated.
  final double maxItemWidth;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// Aspect ratio of each grid item (width / height).
  final double childAspectRatio;

  /// Padding around the grid.
  final EdgeInsetsGeometry? padding;

  /// Whether the grid should shrink to fit content.
  final bool shrinkWrap;

  /// Scroll physics.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final builder = itemBuilder;
    final count = itemCount ?? children.length;
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxItemWidth,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: count,
      itemBuilder: builder ?? (context, index) => children[index],
    );
  }
}

/// A sliver version of [RrResponsiveGrid] for use inside [CustomScrollView].
class RrResponsiveSliverGrid extends StatelessWidget {
  const RrResponsiveSliverGrid({
    super.key,
    required this.delegate,
    this.maxItemWidth = 300,
    this.mainAxisSpacing = RrSpacing.lg,
    this.crossAxisSpacing = RrSpacing.lg,
    this.childAspectRatio = 1.0,
  });

  /// The child delegate (e.g. [SliverChildBuilderDelegate]).
  final SliverChildDelegate delegate;

  /// Maximum width for each grid item.
  final double maxItemWidth;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// Aspect ratio of each grid item.
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxItemWidth,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      delegate: delegate,
    );
  }
}

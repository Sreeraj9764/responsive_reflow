import 'package:flutter/widgets.dart';
import 'responsive_widgets.dart';
import 'spacing.dart';

/// A responsive grid that uses [SliverGridDelegateWithMaxCrossAxisExtent]
/// to automatically calculate column count based on available width.
///
/// The column count is derived from the window/parent width and
/// [maxItemWidth], never from device type — following the official Flutter
/// large-screen guidance.
///
/// ```dart
/// ReflowResponsiveGrid(
///   maxItemWidth: 300,
///   children: items.map((i) => ItemCard(i)).toList(),
/// )
/// ```
///
/// For long lists, prefer [ReflowResponsiveGrid.builder] so only visible items
/// are built.
class ReflowResponsiveGrid extends StatelessWidget {
  const ReflowResponsiveGrid({
    super.key,
    required this.children,
    this.maxItemWidth = 300,
    this.minColumns,
    this.maxColumns,
    this.columns,
    this.mainAxisSpacing = ReflowSpacing.lg,
    this.crossAxisSpacing = ReflowSpacing.lg,
    this.childAspectRatio = 1.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  })  : itemCount = null,
        itemBuilder = null,
        assert(minColumns == null || minColumns >= 1,
            'minColumns must be at least 1.'),
        assert(
            minColumns == null ||
                maxColumns == null ||
                minColumns <= maxColumns,
            'minColumns must not exceed maxColumns.');

  /// Lazy variant that builds only the visible items via [itemBuilder].
  ///
  /// Use this for large collections to avoid building every item up front.
  const ReflowResponsiveGrid.builder({
    super.key,
    required int this.itemCount,
    required Widget Function(BuildContext context, int index) this.itemBuilder,
    this.maxItemWidth = 300,
    this.minColumns,
    this.maxColumns,
    this.columns,
    this.mainAxisSpacing = ReflowSpacing.lg,
    this.crossAxisSpacing = ReflowSpacing.lg,
    this.childAspectRatio = 1.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  })  : children = const [],
        assert(minColumns == null || minColumns >= 1,
            'minColumns must be at least 1.'),
        assert(
            minColumns == null ||
                maxColumns == null ||
                minColumns <= maxColumns,
            'minColumns must not exceed maxColumns.');

  /// Grid items (eager constructor). Empty for [ReflowResponsiveGrid.builder].
  final List<Widget> children;

  /// Number of items for the lazy [ReflowResponsiveGrid.builder] constructor.
  final int? itemCount;

  /// Item builder for the lazy [ReflowResponsiveGrid.builder] constructor.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Maximum width for each grid item. Columns auto-calculated.
  final double maxItemWidth;

  /// Minimum number of columns, regardless of width. When set, the
  /// width-derived column count is clamped to at least this value.
  final int? minColumns;

  /// Maximum number of columns, regardless of width. When set, the
  /// width-derived column count is clamped to at most this value.
  final int? maxColumns;

  /// Explicit per-breakpoint column override. When provided, takes precedence
  /// over [maxItemWidth]/[minColumns]/[maxColumns] and uses a fixed column
  /// count resolved from the current window breakpoint.
  ///
  /// ```dart
  /// ReflowResponsiveGrid(
  ///   columns: const ReflowResponsiveValue(compact: 1, medium: 2, expanded: 4),
  ///   children: [...],
  /// )
  /// ```
  final ReflowResponsiveValue<int>? columns;

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

    final fixedColumns = columns?.resolve(context);
    if (fixedColumns != null || minColumns != null || maxColumns != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = fixedColumns ??
              _clampedColumnCount(
                availableWidth: constraints.maxWidth,
                maxItemWidth: maxItemWidth,
                crossAxisSpacing: crossAxisSpacing,
                minColumns: minColumns,
                maxColumns: maxColumns,
              );
          return GridView.builder(
            padding: padding,
            shrinkWrap: shrinkWrap,
            physics: physics,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: count,
            itemBuilder: builder ?? (context, index) => children[index],
          );
        },
      );
    }

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

/// Width-derived column count (same formula the max-extent delegate uses),
/// clamped to the optional [minColumns]/[maxColumns] bounds.
int _clampedColumnCount({
  required double availableWidth,
  required double maxItemWidth,
  required double crossAxisSpacing,
  int? minColumns,
  int? maxColumns,
}) {
  var count =
      ((availableWidth + crossAxisSpacing) / (maxItemWidth + crossAxisSpacing))
          .ceil();
  if (count < 1) count = 1;
  if (minColumns != null && count < minColumns) count = minColumns;
  if (maxColumns != null && count > maxColumns) count = maxColumns;
  return count;
}

/// A sliver version of [ReflowResponsiveGrid] for use inside [CustomScrollView].
class ReflowResponsiveSliverGrid extends StatelessWidget {
  const ReflowResponsiveSliverGrid({
    super.key,
    required this.delegate,
    this.maxItemWidth = 300,
    this.columns,
    this.mainAxisSpacing = ReflowSpacing.lg,
    this.crossAxisSpacing = ReflowSpacing.lg,
    this.childAspectRatio = 1.0,
  });

  /// The child delegate (e.g. [SliverChildBuilderDelegate]).
  final SliverChildDelegate delegate;

  /// Maximum width for each grid item.
  final double maxItemWidth;

  /// Explicit per-breakpoint column override. When provided, takes precedence
  /// over [maxItemWidth] and uses a fixed column count resolved from the
  /// current window breakpoint.
  final ReflowResponsiveValue<int>? columns;

  /// Spacing between rows.
  final double mainAxisSpacing;

  /// Spacing between columns.
  final double crossAxisSpacing;

  /// Aspect ratio of each grid item.
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final fixedColumns = columns?.resolve(context);
    return SliverGrid(
      gridDelegate: fixedColumns != null
          ? SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: fixedColumns,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            )
          : SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxItemWidth,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
      delegate: delegate,
    );
  }
}

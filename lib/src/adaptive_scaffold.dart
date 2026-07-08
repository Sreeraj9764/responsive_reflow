import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'display_features.dart';
import 'spacing.dart';

/// A navigation destination used by [ReflowAdaptiveScaffold].
class ReflowDestination {
  const ReflowDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  /// Icon shown in the navigation item.
  final IconData icon;

  /// Label shown in the navigation item.
  final String label;

  /// Icon shown when this destination is selected. Falls back to [icon].
  final IconData? selectedIcon;
}

/// A single item inside a [ReflowNavSection].
///
/// An item is either a **branch** destination (it owns a [branchIndex] and
/// participates in the selection highlight / bottom bar) or a **link** (it has
/// an [onTap] and navigates elsewhere without being a shell branch).
class ReflowNavItem {
  /// A primary destination backed by a `StatefulShellBranch` index.
  const ReflowNavItem.branch({
    required this.icon,
    required this.label,
    required int this.branchIndex,
    this.selectedIcon,
    this.showInBottomBar = false,
  })  : onTap = null,
        selected = false;

  /// A secondary navigation link (e.g. navigates to an in-shell child page).
  /// Never appears in the compact bottom bar. Pass [selected] to highlight it
  /// based on the current location (e.g. when its child page is active).
  const ReflowNavItem.link({
    required this.icon,
    required this.label,
    required VoidCallback this.onTap,
    this.selectedIcon,
    this.selected = false,
  })  : branchIndex = null,
        showInBottomBar = false;

  /// Icon shown in the navigation item.
  final IconData icon;

  /// Icon shown when this item is selected. Falls back to [icon].
  final IconData? selectedIcon;

  /// Label shown in the navigation item.
  final String label;

  /// The `StatefulShellBranch` index this item selects, or null for links.
  final int? branchIndex;

  /// Callback for link items. Null for branch items.
  final VoidCallback? onTap;

  /// Whether this branch item appears in the compact bottom navigation bar.
  final bool showInBottomBar;

  /// Whether this link item is currently active (location-derived). Always
  /// false for branch items, which are highlighted via `currentIndex`.
  final bool selected;

  /// Whether this item is a primary branch destination.
  bool get isBranch => branchIndex != null;
}

/// A titled group of [ReflowNavItem]s rendered in the sidebar / rail.
class ReflowNavSection {
  const ReflowNavSection({required this.items, this.title});

  /// Optional section header (e.g. "MAIN NAVIGATION"). Hidden when null.
  final String? title;

  /// The items in this section.
  final List<ReflowNavItem> items;
}

/// How the medium breakpoint (600–839px) renders navigation.
enum ReflowMediumNavStyle {
  /// A collapsed [NavigationRail] (icons only). Best for a flat destination set.
  rail,

  /// The full sidebar (icons + labels + sections). Best for a sectioned set.
  sidebar,
}

/// Signature for building the sidebar header (logo, branding, etc.).
typedef SidebarHeaderBuilder = Widget Function(BuildContext context);

/// Signature for building sidebar footer content (logout, settings, etc.).
typedef SidebarFooterBuilder = Widget Function(BuildContext context);

/// Default layout dimensions for [ReflowAdaptiveScaffold].
abstract final class ReflowScaffoldMetrics {
  /// Default width of the full sidebar (expanded+).
  static const double sidebarWidth = 260;

  /// Default width of the collapsed navigation rail (medium).
  static const double railWidth = 72;

  /// Icon size used inside the full sidebar.
  static const double sidebarIconSize = 22;

  /// Duration of the cross-fade when switching navigation patterns.
  static const Duration transitionDuration = Duration(milliseconds: 200);
}

/// An adaptive scaffold that automatically switches between navigation patterns
/// based on the current window width (Material 3 window size classes):
///
/// - **Compact** (<600px): Bottom navigation bar
/// - **Medium** (600–839px): Collapsed NavigationRail (icons only) or sidebar
/// - **Expanded** (840–1199px): Full sidebar with icons and labels
/// - **Large / Extra large** (≥1200px): Full sidebar, optionally extended
///
/// Designed to work with [go_router]'s `StatefulNavigationShell`. Use the
/// default constructor for a flat list of destinations, or
/// [ReflowAdaptiveScaffold.sectioned] for a grouped sidebar that mixes primary
/// branch destinations with secondary links.
///
/// ```dart
/// ReflowAdaptiveScaffold(
///   destinations: [
///     ReflowDestination(icon: Icons.home, label: 'Home'),
///     ReflowDestination(icon: Icons.calendar_month, label: 'Schedule'),
///   ],
///   currentIndex: navigationShell.currentIndex,
///   onDestinationSelected: (i) => navigationShell.goBranch(i),
///   body: navigationShell,
/// )
/// ```
class ReflowAdaptiveScaffold extends StatelessWidget {
  /// Creates an adaptive scaffold from a flat list of [destinations]. The
  /// medium breakpoint renders a [NavigationRail].
  const ReflowAdaptiveScaffold({
    super.key,
    required List<ReflowDestination> this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.secondaryBody,
    this.bodyRatio = 0.5,
    this.appBar,
    this.showAppBarOnDesktop = false,
    this.floatingActionButton,
    this.endDrawer,
    this.sidebarHeader,
    this.sidebarFooter,
    this.bottomNavigationBar,
    this.sidebarWidth = ReflowScaffoldMetrics.sidebarWidth,
    this.railWidth = ReflowScaffoldMetrics.railWidth,
    this.backgroundColor,
    this.sidebarBackgroundColor,
    this.animateTransitions = true,
  })  : sections = null,
        mediumNavStyle = ReflowMediumNavStyle.rail,
        assert(destinations.length >= 2, 'Provide at least 2 destinations.'),
        assert(bodyRatio > 0 && bodyRatio < 1,
            'bodyRatio must be between 0 and 1 (exclusive).');

  /// Creates an adaptive scaffold from grouped [sections]. The sidebar renders
  /// section headers, primary branch destinations, and secondary links. The
  /// medium breakpoint renders the sidebar by default.
  const ReflowAdaptiveScaffold.sectioned({
    super.key,
    required List<ReflowNavSection> this.sections,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.secondaryBody,
    this.bodyRatio = 0.5,
    this.appBar,
    this.showAppBarOnDesktop = false,
    this.floatingActionButton,
    this.endDrawer,
    this.sidebarHeader,
    this.sidebarFooter,
    this.bottomNavigationBar,
    this.mediumNavStyle = ReflowMediumNavStyle.sidebar,
    this.sidebarWidth = ReflowScaffoldMetrics.sidebarWidth,
    this.railWidth = ReflowScaffoldMetrics.railWidth,
    this.backgroundColor,
    this.sidebarBackgroundColor,
    this.animateTransitions = true,
  })  : destinations = null,
        assert(bodyRatio > 0 && bodyRatio < 1,
            'bodyRatio must be between 0 and 1 (exclusive).');

  /// Flat navigation destinations (default constructor). Null when [sections]
  /// is used.
  final List<ReflowDestination>? destinations;

  /// Grouped navigation sections (sectioned constructor). Null when
  /// [destinations] is used.
  final List<ReflowNavSection>? sections;

  /// Currently selected branch index.
  final int currentIndex;

  /// Callback when a destination is tapped.
  final ValueChanged<int> onDestinationSelected;

  /// The main body content (typically a `StatefulNavigationShell`).
  final Widget body;

  /// Optional secondary pane shown next to [body] on expanded and larger
  /// windows (list–detail pattern). Hidden on compact and medium windows.
  ///
  /// When the window is split by a vertical fold/hinge, the two panes are
  /// placed on either side of the fold instead of using [bodyRatio].
  final Widget? secondaryBody;

  /// Fraction of the available width given to [body] when [secondaryBody]
  /// is visible. Must be between 0 and 1 (exclusive). Defaults to 0.5.
  final double bodyRatio;

  /// Optional app bar. Shown on compact/medium layouts and, when
  /// [showAppBarOnDesktop] is true, on expanded+ layouts as well.
  final PreferredSizeWidget? appBar;

  /// Whether to show [appBar] on expanded and larger layouts. Defaults to
  /// false (the sidebar typically replaces the top bar on desktop).
  final bool showAppBarOnDesktop;

  /// Optional floating action button, shown across all layouts.
  final Widget? floatingActionButton;

  /// Optional end drawer for compact/medium layouts.
  final Widget? endDrawer;

  /// Builder for the sidebar header (shown above destinations in expanded mode).
  final SidebarHeaderBuilder? sidebarHeader;

  /// Builder for the sidebar footer (shown below destinations in sidebar mode).
  final SidebarFooterBuilder? sidebarFooter;

  /// Optional custom bottom navigation bar for the compact layout. When null, a
  /// Material [NavigationBar] is built from the bottom-bar branch items.
  final Widget? bottomNavigationBar;

  /// How the medium breakpoint renders navigation (rail or sidebar).
  final ReflowMediumNavStyle mediumNavStyle;

  /// Width of the full sidebar in expanded mode.
  final double sidebarWidth;

  /// Width of the NavigationRail in medium mode.
  final double railWidth;

  /// Background color for the scaffold body area.
  final Color? backgroundColor;

  /// Background color for the sidebar/rail.
  final Color? sidebarBackgroundColor;

  /// Whether to cross-fade between navigation patterns when the breakpoint
  /// changes. Defaults to true.
  final bool animateTransitions;

  /// Normalizes the flat or sectioned configuration to a list of sections.
  List<ReflowNavSection> get _resolvedSections {
    final sectionsList = sections;
    if (sectionsList != null) return sectionsList;
    final flat = destinations!;
    return [
      ReflowNavSection(
        items: [
          for (var i = 0; i < flat.length; i++)
            ReflowNavItem.branch(
              icon: flat[i].icon,
              selectedIcon: flat[i].selectedIcon,
              label: flat[i].label,
              branchIndex: i,
              showInBottomBar: true,
            ),
        ],
      ),
    ];
  }

  /// All branch items, flattened in section order.
  List<ReflowNavItem> get _branchItems => [
        for (final section in _resolvedSections)
          for (final item in section.items)
            if (item.isBranch) item,
      ];

  /// Branch items that appear in the compact bottom navigation bar.
  List<ReflowNavItem> get _bottomBarItems => [
        for (final item in _branchItems)
          if (item.showInBottomBar) item
      ];

  @override
  Widget build(BuildContext context) {
    final breakpoint = ReflowBreakpoint.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final layout = switch (breakpoint) {
      ReflowBreakpoint.compact => _buildCompactLayout(context, colorScheme),
      ReflowBreakpoint.medium => mediumNavStyle == ReflowMediumNavStyle.rail
          ? _buildRailLayout(context, colorScheme)
          : _buildSidebarLayout(context, colorScheme),
      ReflowBreakpoint.expanded ||
      ReflowBreakpoint.large ||
      ReflowBreakpoint.extraLarge =>
        _buildSidebarLayout(context, colorScheme),
    };

    if (!animateTransitions) return layout;

    return AnimatedSwitcher(
      duration: ReflowScaffoldMetrics.transitionDuration,
      child: KeyedSubtree(
        key: ValueKey(breakpoint.isDesktopLayout ? 'desktop' : breakpoint.name),
        child: layout,
      ),
    );
  }

  /// Compact: Standard scaffold with a bottom navigation bar.
  Widget _buildCompactLayout(BuildContext context, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: appBar,
      body: body,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar ?? _defaultBottomBar(),
    );
  }

  /// Resolves the body area: the primary [body] alone, or a two-pane
  /// split with [secondaryBody] on expanded+ windows (fold-aware).
  Widget _buildBodyArea(BuildContext context, double navWidth) {
    final secondary = secondaryBody;
    if (secondary == null) return body;

    final breakpoint = ReflowBreakpoint.of(context);
    if (breakpoint < ReflowBreakpoint.expanded) return body;

    // Fold-aware: split the panes at the hinge rather than by ratio.
    final fold = ReflowDisplayFeatures.verticalFold(context);
    if (fold != null) {
      final primaryWidth = fold.bounds.left - navWidth;
      if (primaryWidth > 0) {
        return Row(
          children: [
            SizedBox(width: primaryWidth, child: body),
            SizedBox(width: fold.bounds.width),
            Expanded(child: secondary),
          ],
        );
      }
    }

    final primaryFlex = (bodyRatio * 1000).round();
    return Row(
      children: [
        Expanded(flex: primaryFlex, child: body),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(flex: 1000 - primaryFlex, child: secondary),
      ],
    );
  }

  /// Default Material bottom bar built from the bottom-bar branch items.
  ///
  /// In sectioned mode, falls back to all branch items when no item opted in
  /// via `showInBottomBar`. Returns null (no bottom bar) when fewer than two
  /// items are available, since [NavigationBar] requires at least two.
  Widget? _defaultBottomBar() {
    var items = _bottomBarItems;
    if (items.isEmpty) items = _branchItems;
    if (items.length < 2) return null;
    final selected = items.indexWhere((it) => it.branchIndex == currentIndex);
    return NavigationBar(
      selectedIndex: selected < 0 ? 0 : selected,
      onDestinationSelected: (i) =>
          onDestinationSelected(items[i].branchIndex!),
      destinations: items
          .map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon ?? d.icon),
              label: d.label,
            ),
          )
          .toList(),
    );
  }

  /// Medium: Row with a collapsed NavigationRail + body.
  Widget _buildRailLayout(BuildContext context, ColorScheme colorScheme) {
    final items = _branchItems;
    final selected = items.indexWhere((it) => it.branchIndex == currentIndex);
    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: appBar,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selected < 0 ? null : selected,
            onDestinationSelected: (i) =>
                onDestinationSelected(items[i].branchIndex!),
            labelType: NavigationRailLabelType.selected,
            backgroundColor:
                sidebarBackgroundColor ?? colorScheme.surfaceContainerLow,
            minWidth: railWidth,
            destinations: items
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon ?? d.icon),
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildBodyArea(context, railWidth)),
        ],
      ),
    );
  }

  /// Expanded (and sectioned medium): Row with full sidebar + body.
  Widget _buildSidebarLayout(BuildContext context, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      appBar: showAppBarOnDesktop ? appBar : null,
      floatingActionButton: floatingActionButton,
      endDrawer: endDrawer,
      body: Row(
        children: [
          _ReflowSidebar(
            sections: _resolvedSections,
            currentIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            width: sidebarWidth,
            backgroundColor:
                sidebarBackgroundColor ?? colorScheme.surfaceContainerLow,
            header: sidebarHeader,
            footer: sidebarFooter,
          ),
          Expanded(child: _buildBodyArea(context, sidebarWidth)),
        ],
      ),
    );
  }
}

/// Full sidebar panel with header, sectioned navigation items, and footer.
class _ReflowSidebar extends StatelessWidget {
  const _ReflowSidebar({
    required this.sections,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.width,
    required this.backgroundColor,
    this.header,
    this.footer,
  });

  final List<ReflowNavSection> sections;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final double width;
  final Color backgroundColor;
  final SidebarHeaderBuilder? header;
  final SidebarFooterBuilder? footer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // When a link is explicitly selected (location-derived), suppress the
    // branch highlight so only the active child page's item is highlighted.
    final hasExplicitSelection =
        sections.any((s) => s.items.any((i) => i.selected));

    return Container(
      width: width,
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (logo, branding)
            if (header != null) header!(context),
            if (header != null) const SizedBox(height: ReflowSpacing.lg),

            // Sectioned navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: ReflowSpacing.sm,
                  vertical: ReflowSpacing.xs,
                ),
                children: [
                  for (final section in sections) ...[
                    if (section.title != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          ReflowSpacing.md,
                          ReflowSpacing.md,
                          ReflowSpacing.md,
                          ReflowSpacing.xs,
                        ),
                        child: Text(
                          section.title!,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    for (final item in section.items)
                      _SidebarTile(
                        item: item,
                        selected: item.selected ||
                            (item.isBranch &&
                                !hasExplicitSelection &&
                                item.branchIndex == currentIndex),
                        onBranchSelected: onDestinationSelected,
                      ),
                  ],
                ],
              ),
            ),

            // Footer (help card, logout, etc.)
            if (footer != null) ...[
              const Divider(height: 1),
              footer!(context),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single sidebar row for a branch destination or a link.
class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.onBranchSelected,
  });

  final ReflowNavItem item;
  final bool selected;
  final ValueChanged<int> onBranchSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground =
        selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ReflowSpacing.xxs),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReflowSpacing.sm),
          ),
          leading: Icon(
            selected ? (item.selectedIcon ?? item.icon) : item.icon,
            color: foreground,
            size: ReflowScaffoldMetrics.sidebarIconSize,
          ),
          title: Text(
            item.label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: foreground,
            ),
          ),
          selected: selected,
          selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
          onTap: item.isBranch
              ? () => onBranchSelected(item.branchIndex!)
              : item.onTap,
        ),
      ),
    );
  }
}

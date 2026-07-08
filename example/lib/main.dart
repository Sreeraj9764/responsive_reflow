import 'package:flutter/material.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'responsive_reflow example',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// Demonstrates the package end to end — all width-driven, never scaled:
///
/// - [ReflowAdaptiveScaffold.sectioned] (bottom nav → sidebar) with branch
///   destinations and a secondary link,
/// - a fold-aware `secondaryBody` split view,
/// - [ReflowResponsiveGrid] with per-breakpoint column overrides,
/// - [ReflowConstraintResponsiveBuilder] inside a reusable card,
/// - the `context.reflow` extension and spacing tokens.
///
/// Run on desktop and resize the window through all breakpoints.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ReflowAdaptiveScaffold.sectioned(
      sections: [
        const ReflowNavSection(
          title: 'MAIN',
          items: [
            ReflowNavItem.branch(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              branchIndex: 0,
              showInBottomBar: true,
            ),
            ReflowNavItem.branch(
              icon: Icons.grid_view_outlined,
              label: 'Grid',
              branchIndex: 1,
              showInBottomBar: true,
            ),
            ReflowNavItem.branch(
              icon: Icons.view_sidebar_outlined,
              label: 'Split view',
              branchIndex: 2,
              showInBottomBar: true,
            ),
          ],
        ),
        ReflowNavSection(
          title: 'MORE',
          items: [
            ReflowNavItem.link(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'responsive_reflow',
              ),
            ),
          ],
        ),
      ],
      currentIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      sidebarHeader: (context) => const Padding(
        padding: ReflowEdgeInsets.allLg,
        child: Text(
          'Reflow Demo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      // The split view only appears on the third destination.
      secondaryBody: _index == 2 ? const _DetailPane() : null,
      bodyRatio: 0.45,
      body: switch (_index) {
        0 => const _DashboardPage(),
        1 => const _GridPage(),
        _ => const _ListPane(),
      },
    );
  }
}

/// Shows the `context.reflow` extension and breakpoint-aware page padding.
class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    final reflow = context.reflow;
    return ReflowPageContent(
      maxWidth: 1000,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Window info', style: Theme.of(context).textTheme.titleLarge),
          ReflowGap.verticalLg,
          Card(
            child: Padding(
              padding: ReflowEdgeInsets.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Breakpoint: ${reflow.breakpoint.name}'),
                  Text('Width: ${reflow.width.toStringAsFixed(0)}px'),
                  Text('M3 margin: ${reflow.margin}px'),
                  Text('Desktop-like: ${reflow.isDesktopLayout}'),
                  Text('Input mode: ${reflow.inputMode.name}'),
                  Text('Vertical fold: ${reflow.hasVerticalFold}'),
                ],
              ),
            ),
          ),
          ReflowGap.verticalLg,
          // A reusable component that adapts to ITS OWN constraints — it
          // renders differently here vs inside a narrow pane.
          const _AdaptiveInfoCard(),
        ],
      ),
    );
  }
}

/// A reusable card that branches on parent constraints, not the window.
class _AdaptiveInfoCard extends StatelessWidget {
  const _AdaptiveInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: ReflowEdgeInsets.allLg,
        child: ReflowConstraintResponsiveBuilder(
          compact: (context, constraints) => const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.swap_horiz),
              ReflowGap.verticalSm,
              Text('Narrow parent → stacked layout'),
            ],
          ),
          medium: (context, constraints) => const Row(
            children: [
              Icon(Icons.swap_horiz),
              ReflowGap.horizontalLg,
              Expanded(child: Text('Wide parent → side-by-side layout')),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid with per-breakpoint column overrides and lazy building.
class _GridPage extends StatelessWidget {
  const _GridPage();

  @override
  Widget build(BuildContext context) {
    return ReflowPageContent(
      maxWidth: 1200,
      scrollable: false,
      child: ReflowResponsiveGrid.builder(
        columns: const ReflowResponsiveValue(
          compact: 1,
          medium: 2,
          expanded: 3,
          large: 4,
        ),
        itemCount: 24,
        itemBuilder: (context, i) => Card(
          child: Padding(
            padding: ReflowEdgeInsets.allLg,
            child: Center(child: Text('Item ${i + 1}')),
          ),
        ),
      ),
    );
  }
}

/// Primary pane of the split view (list side).
class _ListPane extends StatelessWidget {
  const _ListPane();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, i) => ListTile(
        leading: const Icon(Icons.mail_outline),
        title: Text('Conversation ${i + 1}'),
        subtitle: const Text('On expanded+ windows the detail pane '
            'appears to the right.'),
      ),
    );
  }
}

/// Secondary pane of the split view (detail side). Hidden on compact/medium.
class _DetailPane extends StatelessWidget {
  const _DetailPane();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: const Center(
        child: Padding(
          padding: ReflowEdgeInsets.allXl,
          child: Text(
            'Detail pane\n\nVisible on expanded+ windows only. '
            'On a foldable, the panes split at the hinge.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

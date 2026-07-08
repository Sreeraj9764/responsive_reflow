import 'package:flutter/material.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

import 'shared/demo_data.dart';
import 'shared/pages.dart';

// Basics showcase — every core widget, no router packages.
//
// Also see the router integrations (run with `flutter run -t`):
//   lib/go_router_app/main.dart   — StatefulShellRoute + deep-linkable inbox
//   lib/auto_route_app/main.dart  — AutoTabsRouter mapped to the scaffold
void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'responsive_reflow example',
      theme: ThemeData(useMaterial3: true),
      // Install once, above the Navigator: tune hit-target density to the
      // pointer the user is ACTUALLY using (e.g. a mouse plugged into a
      // tablet), not the device type.
      builder: (context, child) => ReflowPointerModeDetector(
        builder: (context, mode) => Theme(
          data: Theme.of(context).copyWith(
            visualDensity: ReflowDensity.densityFor(mode),
          ),
          child: child!,
        ),
      ),
      home: const HomePage(),
    );
  }
}

/// Demonstrates the package end to end — all width-driven, never scaled:
///
/// - [ReflowAdaptiveScaffold.sectioned] (bottom nav → rail → sidebar) with
///   branch destinations and a secondary link,
/// - an adaptive inbox: full-screen detail on compact, fold-aware
///   `secondaryBody` split view on expanded+,
/// - [ReflowResponsiveGrid] with per-breakpoint column overrides,
/// - [ReflowConstraintResponsiveBuilder] inside a reusable card,
/// - a settings form with [ConstrainedContent] and keyboard-inset handling,
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
  String? _selectedMessageId;

  void _openMessage(BuildContext context, String id) {
    if (context.reflow.isDesktopLayout) {
      // Wide window: show the detail in the secondary pane.
      setState(() => _selectedMessageId = id);
    } else {
      // Phone-sized window: push the detail as its own screen.
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(messageById(id)?.subject ?? 'Message')),
            body: MessageDetailPane(message: messageById(id)),
          ),
        ),
      );
    }
  }

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
              icon: Icons.inbox_outlined,
              label: 'Inbox',
              branchIndex: 1,
              showInBottomBar: true,
            ),
            ReflowNavItem.branch(
              icon: Icons.settings_outlined,
              label: 'Settings',
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
      // The split view only appears on the Inbox destination, and only on
      // expanded+ windows (fold-aware on foldables).
      secondaryBody: _index == 1
          ? MessageDetailPane(message: messageById(_selectedMessageId))
          : null,
      bodyRatio: 0.4,
      body: switch (_index) {
        0 => const DashboardPage(),
        1 => Builder(
            builder: (context) => InboxListPane(
              selectedId: _selectedMessageId,
              onMessageSelected: (id) => _openMessage(context, id),
            ),
          ),
        _ => const SettingsPage(),
      },
    );
  }
}

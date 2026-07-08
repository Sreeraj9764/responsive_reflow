import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

import '../shared/demo_data.dart';
import '../shared/pages.dart';

// go_router integration — run with:
//   flutter run -t lib/go_router_app/main.dart
//
// Shows:
// - one StatefulShellRoute.indexedStack wrapped by ReflowAdaptiveScaffold
//   (branch state survives bottom bar ↔ rail ↔ sidebar reflows),
// - retap-to-reset via goBranch(initialLocation:),
// - a deep-linkable adaptive inbox: /inbox/:id renders a full detail screen
//   on compact windows and a secondary pane next to the list on expanded+.
void main() => runApp(GoRouterExampleApp(router: buildRouter()));

GoRouter buildRouter() => GoRouter(
      initialLocation: '/dashboard',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  builder: (context, state) => const DashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/inbox',
                  builder: (context, state) => const InboxScreen(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = state.pathParameters['id']!;
                        // Same URL, different layout:
                        // - expanded+: keep the list on screen; the shell
                        //   shows the detail in `secondaryBody` (below),
                        // - compact/medium: the detail is its own screen.
                        if (context.reflow.isDesktopLayout) {
                          return InboxScreen(selectedId: id);
                        }
                        return Scaffold(
                          appBar: AppBar(
                            title: Text(messageById(id)?.subject ?? 'Message'),
                          ),
                          body: MessageDetailPane(message: messageById(id)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

class GoRouterExampleApp extends StatelessWidget {
  const GoRouterExampleApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'responsive_reflow × go_router',
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => ReflowPointerModeDetector(
        builder: (context, mode) => Theme(
          data: Theme.of(context).copyWith(
            visualDensity: ReflowDensity.densityFor(mode),
          ),
          child: child!,
        ),
      ),
      routerConfig: router,
    );
  }
}

/// The adaptive shell. go_router owns navigation state; the scaffold only
/// decides WHERE the navigation UI lives (bottom bar / rail / sidebar).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// Extracts the selected message id from `/inbox/:id`, if any.
  String? _selectedMessageId(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final segments = uri.pathSegments;
    if (segments.length == 2 && segments.first == 'inbox') {
      return segments[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = _selectedMessageId(context);
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
                applicationName: 'responsive_reflow × go_router',
              ),
            ),
          ],
        ),
      ],
      currentIndex: shell.currentIndex,
      onDestinationSelected: (index) => shell.goBranch(
        index,
        // Retap the active destination → pop that branch to its root.
        initialLocation: index == shell.currentIndex,
      ),
      sidebarHeader: (context) => const Padding(
        padding: ReflowEdgeInsets.allLg,
        child: Text(
          'Reflow × go_router',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      // Derived from the URL, so deep links like /inbox/3 open the pane
      // directly on wide windows. The scaffold only shows this on expanded+.
      secondaryBody: shell.currentIndex == 1 && selectedId != null
          ? MessageDetailPane(message: messageById(selectedId))
          : null,
      bodyRatio: 0.4,
      body: shell,
    );
  }
}

/// Inbox list. Navigation is a URL change — the route builder above decides
/// whether that URL becomes a pushed screen or a pane.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key, this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return InboxListPane(
      selectedId: selectedId,
      onMessageSelected: (id) => context.go('/inbox/$id'),
    );
  }
}

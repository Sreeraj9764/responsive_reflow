import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

import '../shared/demo_data.dart';
import '../shared/pages.dart';

part 'router.gr.dart';

// auto_route integration — see main.dart in this folder.
//
// AutoTabsRouter keeps each tab's stack alive; ReflowAdaptiveScaffold decides
// where the navigation UI lives (bottom bar / rail / sidebar) by width.

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: RootRoute.page,
          initial: true,
          children: [
            AutoRoute(page: DashboardRoute.page, initial: true),
            AutoRoute(page: InboxRoute.page),
            AutoRoute(page: SettingsRoute.page),
          ],
        ),
        // Full-screen detail, pushed on compact windows only.
        AutoRoute(page: MessageDetailRoute.page),
      ];
}

/// The adaptive shell: maps [AutoTabsRouter]'s active index onto the
/// scaffold's `currentIndex`/`onDestinationSelected`.
@RoutePage()
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [DashboardRoute(), InboxRoute(), SettingsRoute()],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
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
                    applicationName: 'responsive_reflow × auto_route',
                  ),
                ),
              ],
            ),
          ],
          currentIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          sidebarHeader: (context) => const Padding(
            padding: ReflowEdgeInsets.allLg,
            child: Text(
              'Reflow × auto_route',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          body: child,
        );
      },
    );
  }
}

@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const DashboardPage();
}

/// Self-contained adaptive inbox: pushes [MessageDetailScreen] on compact
/// windows, shows an inline detail pane on expanded+.
@RoutePage()
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    if (!context.reflow.isDesktopLayout) {
      return InboxListPane(
        onMessageSelected: (id) =>
            context.router.push(MessageDetailRoute(id: id)),
      );
    }
    return Row(
      children: [
        SizedBox(
          width: 360,
          child: InboxListPane(
            selectedId: _selectedId,
            onMessageSelected: (id) => setState(() => _selectedId = id),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: MessageDetailPane(message: messageById(_selectedId)),
        ),
      ],
    );
  }
}

@RoutePage()
class MessageDetailScreen extends StatelessWidget {
  const MessageDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(messageById(id)?.subject ?? 'Message')),
      body: MessageDetailPane(message: messageById(id)),
    );
  }
}

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsPage();
}

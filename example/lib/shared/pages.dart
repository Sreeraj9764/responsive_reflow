import 'package:flutter/material.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

import 'demo_data.dart';

// Router-agnostic pages shared by all three example apps
// (lib/main.dart, lib/go_router_app/, lib/auto_route_app/).
//
// None of these pages navigate directly — selection is reported through
// callbacks so each app can wire its own router (or plain setState).

/// Dashboard use case: per-breakpoint grid columns, `context.reflow`,
/// and a component that adapts to its *parent* constraints.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reflow = context.reflow;
    return ReflowPageContent(
      maxWidth: 1200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: Theme.of(context).textTheme.titleLarge),
          ReflowGap.verticalLg,
          // Stat cards: explicit columns per breakpoint (1 → 2 → 3).
          ReflowResponsiveGrid(
            columns: const ReflowResponsiveValue(
              compact: 1,
              medium: 2,
              expanded: 3,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final stat in demoStats) _StatCard(stat: stat),
            ],
          ),
          ReflowGap.verticalLg,
          _WindowInfoCard(reflow: reflow),
          ReflowGap.verticalLg,
          // Adapts to ITS OWN constraints — renders differently here vs
          // inside a narrow pane.
          const AdaptiveInfoCard(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: ReflowEdgeInsets.allLg,
        child: Row(
          children: [
            Icon(stat.icon, color: theme.colorScheme.primary),
            ReflowGap.horizontalLg,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(stat.value, style: theme.textTheme.titleMedium),
                Text(stat.label, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowInfoCard extends StatelessWidget {
  const _WindowInfoCard({required this.reflow});

  final ReflowSizing reflow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: ReflowEdgeInsets.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Window info', style: Theme.of(context).textTheme.titleMedium),
            ReflowGap.verticalSm,
            Text('Breakpoint: ${reflow.breakpoint.name}'),
            Text('Width: ${reflow.width.toStringAsFixed(0)}px'),
            Text('M3 margin: ${reflow.margin}px'),
            Text('Desktop-like: ${reflow.isDesktopLayout}'),
            Text('Input mode: ${reflow.inputMode.name}'),
            Text('Vertical fold: ${reflow.hasVerticalFold}'),
          ],
        ),
      ),
    );
  }
}

/// A reusable card that branches on parent constraints, not the window.
class AdaptiveInfoCard extends StatelessWidget {
  const AdaptiveInfoCard({super.key});

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

/// Inbox list pane. Reports taps through [onMessageSelected] so the host
/// app decides whether to push a route (compact) or fill a pane (desktop).
class InboxListPane extends StatelessWidget {
  const InboxListPane({
    super.key,
    required this.onMessageSelected,
    this.selectedId,
  });

  final ValueChanged<String> onMessageSelected;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: demoMessages.length,
      itemBuilder: (context, i) {
        final message = demoMessages[i];
        return ListTile(
          leading: const Icon(Icons.mail_outline),
          title: Text(message.subject),
          subtitle: Text(message.sender),
          selected: message.id == selectedId,
          onTap: () => onMessageSelected(message.id),
        );
      },
    );
  }
}

/// Inbox detail pane. Works both as a pushed screen (compact) and as a
/// `secondaryBody` pane (expanded+).
class MessageDetailPane extends StatelessWidget {
  const MessageDetailPane({super.key, this.message});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = this.message;
    if (message == null) {
      return ColoredBox(
        color: theme.colorScheme.surfaceContainerLow,
        child: const Center(child: Text('Select a conversation')),
      );
    }
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLow,
      child: ReflowPageContent(
        maxWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.subject, style: theme.textTheme.titleLarge),
            ReflowGap.verticalSm,
            Text('From: ${message.sender}', style: theme.textTheme.bodySmall),
            ReflowGap.verticalLg,
            Text(message.body),
          ],
        ),
      ),
    );
  }
}

/// Settings/form use case: readable line length via [ConstrainedContent],
/// breakpoint-aware padding, and keyboard-inset awareness.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = ReflowInsets.keyboardVisible(context);
    return Scaffold(
      // Hide the FAB while the keyboard is up — an inset-driven decision,
      // not a device-type check.
      floatingActionButton: keyboardVisible
          ? null
          : FloatingActionButton.extended(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved')),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
      body: ReflowSafeArea(
        // Forms stay readable: never wider than 640px, padding grows
        // with the breakpoint.
        child: ConstrainedContent(
          maxWidth: 640,
          child: ListView(
            padding: EdgeInsets.symmetric(
              vertical: reflowVerticalPadding(context),
            ),
            children: [
              Text('Settings', style: Theme.of(context).textTheme.titleLarge),
              ReflowGap.verticalLg,
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                ),
              ),
              ReflowGap.verticalLg,
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              ReflowGap.verticalLg,
              SwitchListTile(
                title: const Text('Notifications'),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              SwitchListTile(
                title: const Text('Dark mode'),
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              ReflowGap.verticalLg,
              Text(
                'Keyboard visible: $keyboardVisible',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

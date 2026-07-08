import 'package:flutter/material.dart';

/// A demo inbox message used by the list–detail examples.
class Message {
  const Message({
    required this.id,
    required this.sender,
    required this.subject,
    required this.body,
  });

  final String id;
  final String sender;
  final String subject;
  final String body;
}

final List<Message> demoMessages = List.generate(
  20,
  (i) => Message(
    id: '${i + 1}',
    sender: 'Sender ${i + 1}',
    subject: 'Conversation ${i + 1}',
    body: 'This is the body of conversation ${i + 1}.\n\n'
        'On compact windows this detail is pushed as its own screen; '
        'on expanded+ windows it fills the secondary pane next to the '
        'list. Same data, same widgets — only the layout reflows.',
  ),
);

Message? messageById(String? id) {
  if (id == null) return null;
  for (final m in demoMessages) {
    if (m.id == id) return m;
  }
  return null;
}

/// A demo dashboard statistic used by [DashboardPage].
class DashboardStat {
  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

const List<DashboardStat> demoStats = [
  DashboardStat(label: 'Revenue', value: r'$12.4k', icon: Icons.payments),
  DashboardStat(label: 'Orders', value: '316', icon: Icons.shopping_bag),
  DashboardStat(label: 'Visitors', value: '8,921', icon: Icons.people),
  DashboardStat(label: 'Conversion', value: '3.5%', icon: Icons.trending_up),
  DashboardStat(label: 'Refunds', value: '4', icon: Icons.replay),
  DashboardStat(label: 'Tickets', value: '12', icon: Icons.support_agent),
];

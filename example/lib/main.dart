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

/// Demonstrates [ReflowAdaptiveScaffold] (bottom nav → rail → sidebar),
/// [ReflowResponsiveGrid], and spacing tokens — all width-driven, never scaled.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ReflowAdaptiveScaffold(
      destinations: const [
        ReflowDestination(icon: Icons.home_outlined, label: 'Home'),
        ReflowDestination(icon: Icons.grid_view_outlined, label: 'Grid'),
        ReflowDestination(icon: Icons.settings_outlined, label: 'Settings'),
      ],
      currentIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      body: ReflowPageContent(
        maxWidth: 1000,
        child: ReflowResponsiveGrid.builder(
          maxItemWidth: 260,
          itemCount: 12,
          itemBuilder: (context, i) => Card(
            child: Padding(
              padding: ReflowEdgeInsets.allLg,
              child: Center(child: Text('Item ${i + 1}')),
            ),
          ),
        ),
      ),
    );
  }
}

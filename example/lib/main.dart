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

/// Demonstrates [RrAdaptiveScaffold] (bottom nav → rail → sidebar),
/// [RrResponsiveGrid], and spacing tokens — all width-driven, never scaled.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return RrAdaptiveScaffold(
      destinations: const [
        RrDestination(icon: Icons.home_outlined, label: 'Home'),
        RrDestination(icon: Icons.grid_view_outlined, label: 'Grid'),
        RrDestination(icon: Icons.settings_outlined, label: 'Settings'),
      ],
      currentIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      body: RrPageContent(
        maxWidth: 1000,
        child: RrResponsiveGrid.builder(
          maxItemWidth: 260,
          itemCount: 12,
          itemBuilder: (context, i) => Card(
            child: Padding(
              padding: RrEdgeInsets.allLg,
              child: Center(child: Text('Item ${i + 1}')),
            ),
          ),
        ),
      ),
    );
  }
}

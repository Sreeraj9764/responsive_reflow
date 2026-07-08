import 'package:flutter/material.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

import 'router.dart';

// auto_route integration — run with:
//   flutter run -t lib/auto_route_app/main.dart
//
// Requires code generation first:
//   dart run build_runner build --delete-conflicting-outputs
void main() => runApp(AutoRouteExampleApp());

class AutoRouteExampleApp extends StatelessWidget {
  AutoRouteExampleApp({super.key});

  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'responsive_reflow × auto_route',
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => ReflowPointerModeDetector(
        builder: (context, mode) => Theme(
          data: Theme.of(context).copyWith(
            visualDensity: ReflowDensity.densityFor(mode),
          ),
          child: child!,
        ),
      ),
      routerConfig: _router.config(),
    );
  }
}

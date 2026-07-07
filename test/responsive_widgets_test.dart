import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(home: child),
  );
}

void main() {
  group('RrResponsiveBuilder', () {
    testWidgets('selects compact layout on narrow window', (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 800),
        RrResponsiveBuilder(
          compact: (_) => const Text('compact'),
          expanded: (_) => const Text('expanded'),
        ),
      );
      expect(find.text('compact'), findsOneWidget);
      expect(find.text('expanded'), findsNothing);
    });

    testWidgets('selects expanded layout on wide window', (tester) async {
      await _pumpAt(
        tester,
        const Size(1000, 800),
        RrResponsiveBuilder(
          compact: (_) => const Text('compact'),
          expanded: (_) => const Text('expanded'),
        ),
      );
      expect(find.text('expanded'), findsOneWidget);
    });

    testWidgets('cascades medium down to compact when medium is absent',
        (tester) async {
      await _pumpAt(
        tester,
        const Size(700, 800), // medium under M3
        RrResponsiveBuilder(
          compact: (_) => const Text('compact'),
          expanded: (_) => const Text('expanded'),
        ),
      );
      expect(find.text('compact'), findsOneWidget);
    });

    testWidgets('generic builder receives the breakpoint', (tester) async {
      await _pumpAt(
        tester,
        const Size(900, 800),
        RrResponsiveBuilder(
          builder: (_, bp) => Text(bp.name),
        ),
      );
      expect(find.text('expanded'), findsOneWidget);
    });
  });

  group('RrResponsiveValue', () {
    testWidgets('resolves cascading values', (tester) async {
      late int columns;
      await _pumpAt(
        tester,
        const Size(900, 800),
        Builder(
          builder: (context) {
            columns = const RrResponsiveValue<int>(
              compact: 1,
              expanded: 3,
            ).resolve(context);
            return const SizedBox();
          },
        ),
      );
      expect(columns, 3);
    });

    test('resolveFor falls back to smaller breakpoints', () {
      const value = RrResponsiveValue<int>(compact: 1, medium: 2);
      expect(value.resolveFor(RrBreakpoint.compact), 1);
      expect(value.resolveFor(RrBreakpoint.medium), 2);
      expect(value.resolveFor(RrBreakpoint.large), 2);
    });
  });

  group('RrResponsiveVisibility', () {
    testWidgets('hides below visibleFrom', (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 800),
        const RrResponsiveVisibility(
          visibleFrom: RrBreakpoint.expanded,
          child: Text('panel'),
        ),
      );
      expect(find.text('panel'), findsNothing);
    });

    testWidgets('shows at/above visibleFrom', (tester) async {
      await _pumpAt(
        tester,
        const Size(900, 800),
        const RrResponsiveVisibility(
          visibleFrom: RrBreakpoint.expanded,
          child: Text('panel'),
        ),
      );
      expect(find.text('panel'), findsOneWidget);
    });
  });

  group('RrResponsiveRowColumn', () {
    testWidgets('uses Column below rowFrom', (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 800),
        const RrResponsiveRowColumn(
          rowFrom: RrBreakpoint.expanded,
          children: [Text('a'), Text('b')],
        ),
      );
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('uses Row at/above rowFrom', (tester) async {
      await _pumpAt(
        tester,
        const Size(1000, 800),
        const RrResponsiveRowColumn(
          rowFrom: RrBreakpoint.expanded,
          children: [Text('a'), Text('b')],
        ),
      );
      expect(find.byType(Row), findsWidgets);
    });
  });
}

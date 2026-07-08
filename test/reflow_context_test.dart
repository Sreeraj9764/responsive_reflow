import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: child));
}

void main() {
  group('context.reflow extension', () {
    testWidgets('reports breakpoint and checks for a compact window',
        (tester) async {
      late ReflowSizing reflow;
      await _pumpAt(
        tester,
        const Size(500, 900),
        Builder(builder: (context) {
          reflow = context.reflow;
          return const SizedBox();
        }),
      );
      expect(reflow.breakpoint, ReflowBreakpoint.compact);
      expect(reflow.isCompact, isTrue);
      expect(reflow.isDesktopLayout, isFalse);
      expect(reflow.atLeast(ReflowBreakpoint.medium), isFalse);
      expect(reflow.atMost(ReflowBreakpoint.medium), isTrue);
      expect(reflow.width, 500);
      expect(reflow.margin, ReflowSpacing.lg);
      expect(reflow.gutter, ReflowSpacing.lg);
      expect(reflow.horizontalPadding, ReflowSpacing.lg);
      expect(reflow.hasVerticalFold, isFalse);
    });

    testWidgets('reports M3 margin of 24 on medium and above', (tester) async {
      late ReflowSizing reflow;
      await _pumpAt(
        tester,
        const Size(700, 900),
        Builder(builder: (context) {
          reflow = context.reflow;
          return const SizedBox();
        }),
      );
      expect(reflow.isMedium, isTrue);
      expect(reflow.margin, ReflowSpacing.xl);
    });

    testWidgets('honours ReflowBreakpointsTheme overrides', (tester) async {
      late ReflowSizing reflow;
      await _pumpAt(
        tester,
        const Size(700, 900),
        ReflowBreakpointsTheme(
          breakpoints: const ReflowBreakpoints(medium: 720),
          child: Builder(builder: (context) {
            reflow = context.reflow;
            return const SizedBox();
          }),
        ),
      );
      // 700 < overridden medium threshold of 720 → still compact.
      expect(reflow.breakpoint, ReflowBreakpoint.compact);
      expect(reflow.breakpoints.medium, 720);
    });

    testWidgets('pagePadding combines horizontal and vertical values',
        (tester) async {
      late EdgeInsets padding;
      await _pumpAt(
        tester,
        const Size(1000, 900), // expanded
        Builder(builder: (context) {
          padding = context.reflow.pagePadding;
          return const SizedBox();
        }),
      );
      expect(padding.left, ReflowSpacing.xxl);
      expect(padding.top, ReflowSpacing.xl);
    });
  });

  group('reflowHorizontalPadding / reflowVerticalPadding', () {
    Future<(double, double)> valuesAt(WidgetTester tester, Size size) async {
      late double h;
      late double v;
      await _pumpAt(
        tester,
        size,
        Builder(builder: (context) {
          h = reflowHorizontalPadding(context);
          v = reflowVerticalPadding(context);
          return const SizedBox();
        }),
      );
      return (h, v);
    }

    testWidgets('scale with the breakpoint', (tester) async {
      expect(await valuesAt(tester, const Size(500, 900)),
          (ReflowSpacing.lg, ReflowSpacing.lg));
      expect(await valuesAt(tester, const Size(700, 900)),
          (ReflowSpacing.xl, ReflowSpacing.lg));
      expect(await valuesAt(tester, const Size(1000, 900)),
          (ReflowSpacing.xxl, ReflowSpacing.xl));
      expect(await valuesAt(tester, const Size(1300, 900)),
          (ReflowSpacing.xxxl, ReflowSpacing.xxl));
    });

    testWidgets('deprecated gs alias forwards to the new helper',
        (tester) async {
      late double deprecated;
      late double current;
      await _pumpAt(
        tester,
        const Size(1000, 900),
        Builder(builder: (context) {
          // ignore: deprecated_member_use_from_same_package
          deprecated = gsResponsiveHorizontalPadding(context);
          current = reflowHorizontalPadding(context);
          return const SizedBox();
        }),
      );
      expect(deprecated, current);
    });
  });

  group('ReflowConstraintResponsiveBuilder theme awareness', () {
    testWidgets('honours ReflowBreakpointsTheme overrides', (tester) async {
      await _pumpAt(
        tester,
        const Size(700, 900),
        ReflowBreakpointsTheme(
          breakpoints: const ReflowBreakpoints(medium: 720),
          child: ReflowConstraintResponsiveBuilder(
            compact: (context, constraints) => const Text('compact'),
            medium: (context, constraints) => const Text('medium'),
          ),
        ),
      );
      // Constraint width 700 < overridden threshold 720 → compact branch.
      expect(find.text('compact'), findsOneWidget);
      expect(find.text('medium'), findsNothing);
    });
  });

  group('ReflowResponsiveGrid column control', () {
    Widget item(int i) => SizedBox(key: ValueKey('item-$i'));

    testWidgets('maxColumns caps the width-derived column count',
        (tester) async {
      await _pumpAt(
        tester,
        const Size(1300, 900),
        ReflowResponsiveGrid(
          maxItemWidth: 200,
          maxColumns: 3,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          children: [for (var i = 0; i < 6; i++) item(i)],
        ),
      );
      // With 3 columns at width 1300, each item is ~433 wide.
      final size = tester.getSize(find.byKey(const ValueKey('item-0')));
      expect(size.width, closeTo(1300 / 3, 0.5));
    });

    testWidgets('minColumns forces more columns on narrow windows',
        (tester) async {
      await _pumpAt(
        tester,
        const Size(400, 900),
        ReflowResponsiveGrid(
          maxItemWidth: 500,
          minColumns: 2,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          children: [for (var i = 0; i < 4; i++) item(i)],
        ),
      );
      final size = tester.getSize(find.byKey(const ValueKey('item-0')));
      expect(size.width, closeTo(200, 0.5));
    });

    testWidgets('columns override resolves per breakpoint', (tester) async {
      Widget grid() => ReflowResponsiveGrid(
            columns: const ReflowResponsiveValue(compact: 1, expanded: 4),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            children: [for (var i = 0; i < 4; i++) item(i)],
          );

      await _pumpAt(tester, const Size(500, 900), grid());
      expect(
        tester.getSize(find.byKey(const ValueKey('item-0'))).width,
        closeTo(500, 0.5),
      );

      await _pumpAt(tester, const Size(1000, 900), grid());
      expect(
        tester.getSize(find.byKey(const ValueKey('item-0'))).width,
        closeTo(250, 0.5),
      );
    });
  });

  group('ReflowAdaptiveScaffold secondaryBody', () {
    Widget scaffold({double bodyRatio = 0.5}) => ReflowAdaptiveScaffold(
          destinations: const [
            ReflowDestination(icon: Icons.home, label: 'Home'),
            ReflowDestination(icon: Icons.search, label: 'Search'),
          ],
          currentIndex: 0,
          onDestinationSelected: (_) {},
          body: const ColoredBox(
              color: Colors.red, child: SizedBox.expand(key: Key('primary'))),
          secondaryBody: const ColoredBox(
              color: Colors.blue,
              child: SizedBox.expand(key: Key('secondary'))),
          bodyRatio: bodyRatio,
          animateTransitions: false,
        );

    testWidgets('is hidden on compact windows', (tester) async {
      await _pumpAt(tester, const Size(500, 900), scaffold());
      expect(find.byKey(const Key('primary')), findsOneWidget);
      expect(find.byKey(const Key('secondary')), findsNothing);
    });

    testWidgets('is hidden on medium windows', (tester) async {
      await _pumpAt(tester, const Size(700, 900), scaffold());
      expect(find.byKey(const Key('secondary')), findsNothing);
    });

    testWidgets('is shown next to body on expanded windows', (tester) async {
      await _pumpAt(tester, const Size(1000, 900), scaffold());
      expect(find.byKey(const Key('primary')), findsOneWidget);
      expect(find.byKey(const Key('secondary')), findsOneWidget);

      final primary = tester.getRect(find.byKey(const Key('primary')));
      final secondary = tester.getRect(find.byKey(const Key('secondary')));
      expect(primary.right, lessThanOrEqualTo(secondary.left));
    });

    testWidgets('bodyRatio controls the split', (tester) async {
      await _pumpAt(tester, const Size(1000, 900), scaffold(bodyRatio: 0.7));
      final primary = tester.getSize(find.byKey(const Key('primary')));
      final secondary = tester.getSize(find.byKey(const Key('secondary')));
      expect(primary.width / (primary.width + secondary.width),
          closeTo(0.7, 0.01));
    });
  });

  group('ReflowAdaptiveScaffold empty bottom bar guard', () {
    testWidgets(
        'sectioned mode with no showInBottomBar items falls back to '
        'branch items', (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 900),
        ReflowAdaptiveScaffold.sectioned(
          sections: const [
            ReflowNavSection(items: [
              ReflowNavItem.branch(
                  icon: Icons.home, label: 'Home', branchIndex: 0),
              ReflowNavItem.branch(
                  icon: Icons.search, label: 'Search', branchIndex: 1),
            ]),
          ],
          currentIndex: 0,
          onDestinationSelected: (_) {},
          body: const SizedBox(),
          animateTransitions: false,
        ),
      );
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('hides the bottom bar when fewer than two items exist',
        (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 900),
        ReflowAdaptiveScaffold.sectioned(
          sections: [
            ReflowNavSection(items: [
              const ReflowNavItem.branch(
                  icon: Icons.home, label: 'Home', branchIndex: 0),
              ReflowNavItem.link(
                  icon: Icons.info, label: 'About', onTap: () {}),
            ]),
          ],
          currentIndex: 0,
          onDestinationSelected: (_) {},
          body: const SizedBox(),
          animateTransitions: false,
        ),
      );
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('ReflowPointerModeDetector', () {
    testWidgets('seeds initial mode from the platform heuristic',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      late ReflowInputMode observed;
      await tester.pumpWidget(
        MaterialApp(
          home: ReflowPointerModeDetector(
            builder: (context, mode) {
              observed = mode;
              return const SizedBox();
            },
          ),
        ),
      );
      // Reset before the binding's post-test invariants check.
      debugDefaultTargetPlatformOverride = null;
      expect(observed, ReflowInputMode.pointer);
    });

    testWidgets('switches mode when a different pointer kind is observed',
        (tester) async {
      late ReflowInputMode observed;
      await tester.pumpWidget(
        MaterialApp(
          home: ReflowPointerModeDetector(
            initialMode: ReflowInputMode.touch,
            builder: (context, mode) {
              observed = mode;
              return const ColoredBox(color: Colors.white);
            },
          ),
        ),
      );
      expect(observed, ReflowInputMode.touch);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(100, 100));
      addTearDown(gesture.removePointer);
      await gesture.moveTo(const Offset(200, 200));
      await tester.pump();
      expect(observed, ReflowInputMode.pointer);
    });
  });
}

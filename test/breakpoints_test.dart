import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

void main() {
  group('ReflowBreakpoints.fromWidth (Material 3 thresholds)', () {
    const bp = ReflowBreakpoints.material3;

    test('boundary values map to the correct breakpoint', () {
      expect(bp.fromWidth(0), ReflowBreakpoint.compact);
      expect(bp.fromWidth(599), ReflowBreakpoint.compact);
      expect(bp.fromWidth(600), ReflowBreakpoint.medium);
      expect(bp.fromWidth(839), ReflowBreakpoint.medium);
      expect(bp.fromWidth(840), ReflowBreakpoint.expanded);
      expect(bp.fromWidth(1199), ReflowBreakpoint.expanded);
      expect(bp.fromWidth(1200), ReflowBreakpoint.large);
      expect(bp.fromWidth(1599), ReflowBreakpoint.large);
      expect(bp.fromWidth(1600), ReflowBreakpoint.extraLarge);
      expect(bp.fromWidth(4000), ReflowBreakpoint.extraLarge);
    });

    test('ReflowBreakpoint.fromWidth delegates to Material 3 defaults', () {
      expect(ReflowBreakpoint.fromWidth(599), ReflowBreakpoint.compact);
      expect(ReflowBreakpoint.fromWidth(600), ReflowBreakpoint.medium);
      expect(ReflowBreakpoint.fromWidth(1600), ReflowBreakpoint.extraLarge);
    });

    test('lowerBoundOf returns the configured thresholds', () {
      expect(bp.lowerBoundOf(ReflowBreakpoint.compact), 0);
      expect(bp.lowerBoundOf(ReflowBreakpoint.medium), 600);
      expect(bp.lowerBoundOf(ReflowBreakpoint.expanded), 840);
      expect(bp.lowerBoundOf(ReflowBreakpoint.large), 1200);
      expect(bp.lowerBoundOf(ReflowBreakpoint.extraLarge), 1600);
    });
  });

  group('ReflowBreakpoint helpers and operators', () {
    test('comparison operators', () {
      expect(ReflowBreakpoint.expanded >= ReflowBreakpoint.medium, isTrue);
      expect(ReflowBreakpoint.compact < ReflowBreakpoint.medium, isTrue);
      expect(ReflowBreakpoint.large > ReflowBreakpoint.expanded, isTrue);
      expect(ReflowBreakpoint.medium <= ReflowBreakpoint.medium, isTrue);
    });

    test('layout helper getters', () {
      expect(ReflowBreakpoint.compact.isMobileLayout, isTrue);
      expect(ReflowBreakpoint.medium.isMobileLayout, isTrue);
      expect(ReflowBreakpoint.expanded.isDesktopLayout, isTrue);
      expect(ReflowBreakpoint.expanded.showsSidebar, isTrue);
      expect(ReflowBreakpoint.compact.showsSidebar, isFalse);
    });
  });

  group('custom ReflowBreakpoints', () {
    test('honours overridden thresholds', () {
      const custom = ReflowBreakpoints(medium: 500, expanded: 900);
      expect(custom.fromWidth(499), ReflowBreakpoint.compact);
      expect(custom.fromWidth(500), ReflowBreakpoint.medium);
      expect(custom.fromWidth(899), ReflowBreakpoint.medium);
      expect(custom.fromWidth(900), ReflowBreakpoint.expanded);
    });

    test('equality and copyWith', () {
      const a = ReflowBreakpoints();
      final b = a.copyWith(medium: 560);
      expect(a == const ReflowBreakpoints(), isTrue);
      expect(b.medium, 560);
      expect(b == a, isFalse);
    });

    testWidgets('ReflowBreakpointsTheme overrides ReflowBreakpoint.of',
        (tester) async {
      late ReflowBreakpoint observed;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(560, 800)),
          child: ReflowBreakpointsTheme(
            breakpoints: const ReflowBreakpoints(medium: 500),
            child: Builder(
              builder: (context) {
                observed = ReflowBreakpoint.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      // 560 is compact under M3 (>=600) but medium under the custom theme.
      expect(observed, ReflowBreakpoint.medium);
    });
  });
}

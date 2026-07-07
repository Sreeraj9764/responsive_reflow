import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

void main() {
  group('RrBreakpoints.fromWidth (Material 3 thresholds)', () {
    const bp = RrBreakpoints.material3;

    test('boundary values map to the correct breakpoint', () {
      expect(bp.fromWidth(0), RrBreakpoint.compact);
      expect(bp.fromWidth(599), RrBreakpoint.compact);
      expect(bp.fromWidth(600), RrBreakpoint.medium);
      expect(bp.fromWidth(839), RrBreakpoint.medium);
      expect(bp.fromWidth(840), RrBreakpoint.expanded);
      expect(bp.fromWidth(1199), RrBreakpoint.expanded);
      expect(bp.fromWidth(1200), RrBreakpoint.large);
      expect(bp.fromWidth(1599), RrBreakpoint.large);
      expect(bp.fromWidth(1600), RrBreakpoint.extraLarge);
      expect(bp.fromWidth(4000), RrBreakpoint.extraLarge);
    });

    test('RrBreakpoint.fromWidth delegates to Material 3 defaults', () {
      expect(RrBreakpoint.fromWidth(599), RrBreakpoint.compact);
      expect(RrBreakpoint.fromWidth(600), RrBreakpoint.medium);
      expect(RrBreakpoint.fromWidth(1600), RrBreakpoint.extraLarge);
    });

    test('lowerBoundOf returns the configured thresholds', () {
      expect(bp.lowerBoundOf(RrBreakpoint.compact), 0);
      expect(bp.lowerBoundOf(RrBreakpoint.medium), 600);
      expect(bp.lowerBoundOf(RrBreakpoint.expanded), 840);
      expect(bp.lowerBoundOf(RrBreakpoint.large), 1200);
      expect(bp.lowerBoundOf(RrBreakpoint.extraLarge), 1600);
    });
  });

  group('RrBreakpoint helpers and operators', () {
    test('comparison operators', () {
      expect(RrBreakpoint.expanded >= RrBreakpoint.medium, isTrue);
      expect(RrBreakpoint.compact < RrBreakpoint.medium, isTrue);
      expect(RrBreakpoint.large > RrBreakpoint.expanded, isTrue);
      expect(RrBreakpoint.medium <= RrBreakpoint.medium, isTrue);
    });

    test('layout helper getters', () {
      expect(RrBreakpoint.compact.isMobileLayout, isTrue);
      expect(RrBreakpoint.medium.isMobileLayout, isTrue);
      expect(RrBreakpoint.expanded.isDesktopLayout, isTrue);
      expect(RrBreakpoint.expanded.showsSidebar, isTrue);
      expect(RrBreakpoint.compact.showsSidebar, isFalse);
    });
  });

  group('custom RrBreakpoints', () {
    test('honours overridden thresholds', () {
      const custom = RrBreakpoints(medium: 500, expanded: 900);
      expect(custom.fromWidth(499), RrBreakpoint.compact);
      expect(custom.fromWidth(500), RrBreakpoint.medium);
      expect(custom.fromWidth(899), RrBreakpoint.medium);
      expect(custom.fromWidth(900), RrBreakpoint.expanded);
    });

    test('equality and copyWith', () {
      const a = RrBreakpoints();
      final b = a.copyWith(medium: 560);
      expect(a == const RrBreakpoints(), isTrue);
      expect(b.medium, 560);
      expect(b == a, isFalse);
    });

    testWidgets('RrBreakpointsTheme overrides RrBreakpoint.of', (tester) async {
      late RrBreakpoint observed;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(560, 800)),
          child: RrBreakpointsTheme(
            breakpoints: const RrBreakpoints(medium: 500),
            child: Builder(
              builder: (context) {
                observed = RrBreakpoint.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      // 560 is compact under M3 (>=600) but medium under the custom theme.
      expect(observed, RrBreakpoint.medium);
    });
  });
}

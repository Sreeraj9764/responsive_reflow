import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

void main() {
  group('RrDensity', () {
    test('maps platforms to input modes', () {
      expect(RrDensity.inputModeFor(TargetPlatform.android), RrInputMode.touch);
      expect(RrDensity.inputModeFor(TargetPlatform.iOS), RrInputMode.touch);
      expect(RrDensity.inputModeFor(TargetPlatform.macOS), RrInputMode.pointer);
      expect(
          RrDensity.inputModeFor(TargetPlatform.windows), RrInputMode.pointer);
    });

    test('density for touch is standard, pointer is compact', () {
      expect(RrDensity.densityFor(RrInputMode.touch), VisualDensity.standard);
      final pointer = RrDensity.densityFor(RrInputMode.pointer);
      expect(pointer.horizontal, -1);
      expect(pointer.vertical, -1);
    });
  });

  group('RrPolicy', () {
    const policy = RrPolicy();

    test('size-based decisions follow Material 3 thresholds', () {
      expect(policy.shouldUseNavRail(599), isFalse);
      expect(policy.shouldUseNavRail(600), isTrue);
      expect(policy.shouldUseSidebar(839), isFalse);
      expect(policy.shouldUseSidebar(840), isTrue);
      expect(policy.shouldUseMultiPane(840), isTrue);
    });

    test('respects custom breakpoints', () {
      const custom = RrPolicy(breakpoints: RrBreakpoints(medium: 500));
      expect(custom.shouldUseNavRail(500), isTrue);
      expect(custom.shouldUseNavRail(499), isFalse);
    });

    testWidgets('context overloads read window width', (tester) async {
      late bool rail;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(700, 800)),
          child: Builder(
            builder: (context) {
              rail = const RrPolicy().shouldUseNavRailOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(rail, isTrue);
    });
  });
}

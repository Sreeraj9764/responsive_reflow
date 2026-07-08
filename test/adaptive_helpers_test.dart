import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

void main() {
  group('ReflowDensity', () {
    test('maps platforms to input modes', () {
      expect(ReflowDensity.inputModeFor(TargetPlatform.android),
          ReflowInputMode.touch);
      expect(ReflowDensity.inputModeFor(TargetPlatform.iOS),
          ReflowInputMode.touch);
      expect(ReflowDensity.inputModeFor(TargetPlatform.macOS),
          ReflowInputMode.pointer);
      expect(ReflowDensity.inputModeFor(TargetPlatform.windows),
          ReflowInputMode.pointer);
    });

    test('density for touch is standard, pointer is compact', () {
      expect(ReflowDensity.densityFor(ReflowInputMode.touch),
          VisualDensity.standard);
      final pointer = ReflowDensity.densityFor(ReflowInputMode.pointer);
      expect(pointer.horizontal, -1);
      expect(pointer.vertical, -1);
    });
  });

  group('ReflowPolicy', () {
    const policy = ReflowPolicy();

    test('size-based decisions follow Material 3 thresholds', () {
      expect(policy.shouldUseNavRail(599), isFalse);
      expect(policy.shouldUseNavRail(600), isTrue);
      expect(policy.shouldUseSidebar(839), isFalse);
      expect(policy.shouldUseSidebar(840), isTrue);
      expect(policy.shouldUseMultiPane(840), isTrue);
    });

    test('respects custom breakpoints', () {
      const custom = ReflowPolicy(breakpoints: ReflowBreakpoints(medium: 500));
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
              rail = const ReflowPolicy().shouldUseNavRailOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(rail, isTrue);
    });
  });
}

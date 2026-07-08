import 'package:flutter/widgets.dart';

/// Semantic spacing tokens to replace flutter_screenutil `.w`/`.h` usage.
///
/// Based on a 4px base unit scale. Use these instead of hardcoded values
/// or screenutil-scaled values.
///
/// ```dart
/// // Before (screenutil):
/// SizedBox(width: 16.w)
/// EdgeInsets.all(8.w)
///
/// // After:
/// SizedBox(width: ReflowSpacing.lg)
/// EdgeInsets.all(ReflowSpacing.sm)
/// ```
abstract final class ReflowSpacing {
  /// 2.0 — hairline spacing
  static const double xxs = 2.0;

  /// 4.0 — extra small
  static const double xs = 4.0;

  /// 8.0 — small
  static const double sm = 8.0;

  /// 12.0 — medium
  static const double md = 12.0;

  /// 16.0 — large (default padding)
  static const double lg = 16.0;

  /// 20.0 — large+
  static const double lgPlus = 20.0;

  /// 24.0 — extra large
  static const double xl = 24.0;

  /// 32.0 — 2x large
  static const double xxl = 32.0;

  /// 40.0 — 2x large+
  static const double xxlPlus = 40.0;

  /// 48.0 — 3x large
  static const double xxxl = 48.0;

  /// 64.0 — 4x large
  static const double xxxxl = 64.0;
}

/// Convenience [EdgeInsets] factories using [ReflowSpacing] tokens.
abstract final class ReflowEdgeInsets {
  // --- All sides ---
  static const EdgeInsets allXs = EdgeInsets.all(ReflowSpacing.xs);
  static const EdgeInsets allSm = EdgeInsets.all(ReflowSpacing.sm);
  static const EdgeInsets allMd = EdgeInsets.all(ReflowSpacing.md);
  static const EdgeInsets allLg = EdgeInsets.all(ReflowSpacing.lg);
  static const EdgeInsets allLgPlus = EdgeInsets.all(ReflowSpacing.lgPlus);
  static const EdgeInsets allXl = EdgeInsets.all(ReflowSpacing.xl);
  static const EdgeInsets allXxl = EdgeInsets.all(ReflowSpacing.xxl);

  // --- Horizontal ---
  static const EdgeInsets horizontalXs =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.xs);
  static const EdgeInsets horizontalSm =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.sm);
  static const EdgeInsets horizontalMd =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.md);
  static const EdgeInsets horizontalLg =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.lg);
  static const EdgeInsets horizontalLgPlus =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.lgPlus);
  static const EdgeInsets horizontalXl =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.xl);
  static const EdgeInsets horizontalXxl =
      EdgeInsets.symmetric(horizontal: ReflowSpacing.xxl);

  // --- Vertical ---
  static const EdgeInsets verticalXs =
      EdgeInsets.symmetric(vertical: ReflowSpacing.xs);
  static const EdgeInsets verticalSm =
      EdgeInsets.symmetric(vertical: ReflowSpacing.sm);
  static const EdgeInsets verticalMd =
      EdgeInsets.symmetric(vertical: ReflowSpacing.md);
  static const EdgeInsets verticalLg =
      EdgeInsets.symmetric(vertical: ReflowSpacing.lg);
  static const EdgeInsets verticalLgPlus =
      EdgeInsets.symmetric(vertical: ReflowSpacing.lgPlus);
  static const EdgeInsets verticalXl =
      EdgeInsets.symmetric(vertical: ReflowSpacing.xl);
  static const EdgeInsets verticalXxl =
      EdgeInsets.symmetric(vertical: ReflowSpacing.xxl);
}

/// Convenience [SizedBox] gap widgets using [ReflowSpacing] tokens.
///
/// Usage:
/// ```dart
/// Column(children: [
///   Text('Hello'),
///   ReflowGap.verticalSm,
///   Text('World'),
/// ])
/// ```
abstract final class ReflowGap {
  // --- Vertical gaps ---
  static const SizedBox verticalXxs = SizedBox(height: ReflowSpacing.xxs);
  static const SizedBox verticalXs = SizedBox(height: ReflowSpacing.xs);
  static const SizedBox verticalSm = SizedBox(height: ReflowSpacing.sm);
  static const SizedBox verticalMd = SizedBox(height: ReflowSpacing.md);
  static const SizedBox verticalLg = SizedBox(height: ReflowSpacing.lg);
  static const SizedBox verticalLgPlus = SizedBox(height: ReflowSpacing.lgPlus);
  static const SizedBox verticalXl = SizedBox(height: ReflowSpacing.xl);
  static const SizedBox verticalXxl = SizedBox(height: ReflowSpacing.xxl);
  static const SizedBox verticalXxlPlus =
      SizedBox(height: ReflowSpacing.xxlPlus);
  static const SizedBox verticalXxxl = SizedBox(height: ReflowSpacing.xxxl);

  // --- Horizontal gaps ---
  static const SizedBox horizontalXxs = SizedBox(width: ReflowSpacing.xxs);
  static const SizedBox horizontalXs = SizedBox(width: ReflowSpacing.xs);
  static const SizedBox horizontalSm = SizedBox(width: ReflowSpacing.sm);
  static const SizedBox horizontalMd = SizedBox(width: ReflowSpacing.md);
  static const SizedBox horizontalLg = SizedBox(width: ReflowSpacing.lg);
  static const SizedBox horizontalLgPlus =
      SizedBox(width: ReflowSpacing.lgPlus);
  static const SizedBox horizontalXl = SizedBox(width: ReflowSpacing.xl);
  static const SizedBox horizontalXxl = SizedBox(width: ReflowSpacing.xxl);
  static const SizedBox horizontalXxlPlus =
      SizedBox(width: ReflowSpacing.xxlPlus);
  static const SizedBox horizontalXxxl = SizedBox(width: ReflowSpacing.xxxl);
}

/// Common border radius values.
abstract final class ReflowRadius {
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  static final BorderRadius borderXs = BorderRadius.circular(xs);
  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderLg = BorderRadius.circular(lg);
  static final BorderRadius borderXl = BorderRadius.circular(xl);
  static final BorderRadius borderXxl = BorderRadius.circular(xxl);
  static final BorderRadius borderFull = BorderRadius.circular(full);
}

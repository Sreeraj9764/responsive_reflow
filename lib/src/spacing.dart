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
/// SizedBox(width: RrSpacing.lg)
/// EdgeInsets.all(RrSpacing.sm)
/// ```
abstract final class RrSpacing {
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

/// Convenience [EdgeInsets] factories using [RrSpacing] tokens.
abstract final class RrEdgeInsets {
  // --- All sides ---
  static const EdgeInsets allXs = EdgeInsets.all(RrSpacing.xs);
  static const EdgeInsets allSm = EdgeInsets.all(RrSpacing.sm);
  static const EdgeInsets allMd = EdgeInsets.all(RrSpacing.md);
  static const EdgeInsets allLg = EdgeInsets.all(RrSpacing.lg);
  static const EdgeInsets allLgPlus = EdgeInsets.all(RrSpacing.lgPlus);
  static const EdgeInsets allXl = EdgeInsets.all(RrSpacing.xl);
  static const EdgeInsets allXxl = EdgeInsets.all(RrSpacing.xxl);

  // --- Horizontal ---
  static const EdgeInsets horizontalXs =
      EdgeInsets.symmetric(horizontal: RrSpacing.xs);
  static const EdgeInsets horizontalSm =
      EdgeInsets.symmetric(horizontal: RrSpacing.sm);
  static const EdgeInsets horizontalMd =
      EdgeInsets.symmetric(horizontal: RrSpacing.md);
  static const EdgeInsets horizontalLg =
      EdgeInsets.symmetric(horizontal: RrSpacing.lg);
  static const EdgeInsets horizontalLgPlus =
      EdgeInsets.symmetric(horizontal: RrSpacing.lgPlus);
  static const EdgeInsets horizontalXl =
      EdgeInsets.symmetric(horizontal: RrSpacing.xl);
  static const EdgeInsets horizontalXxl =
      EdgeInsets.symmetric(horizontal: RrSpacing.xxl);

  // --- Vertical ---
  static const EdgeInsets verticalXs =
      EdgeInsets.symmetric(vertical: RrSpacing.xs);
  static const EdgeInsets verticalSm =
      EdgeInsets.symmetric(vertical: RrSpacing.sm);
  static const EdgeInsets verticalMd =
      EdgeInsets.symmetric(vertical: RrSpacing.md);
  static const EdgeInsets verticalLg =
      EdgeInsets.symmetric(vertical: RrSpacing.lg);
  static const EdgeInsets verticalLgPlus =
      EdgeInsets.symmetric(vertical: RrSpacing.lgPlus);
  static const EdgeInsets verticalXl =
      EdgeInsets.symmetric(vertical: RrSpacing.xl);
  static const EdgeInsets verticalXxl =
      EdgeInsets.symmetric(vertical: RrSpacing.xxl);
}

/// Convenience [SizedBox] gap widgets using [RrSpacing] tokens.
///
/// Usage:
/// ```dart
/// Column(children: [
///   Text('Hello'),
///   RrGap.verticalSm,
///   Text('World'),
/// ])
/// ```
abstract final class RrGap {
  // --- Vertical gaps ---
  static const SizedBox verticalXxs = SizedBox(height: RrSpacing.xxs);
  static const SizedBox verticalXs = SizedBox(height: RrSpacing.xs);
  static const SizedBox verticalSm = SizedBox(height: RrSpacing.sm);
  static const SizedBox verticalMd = SizedBox(height: RrSpacing.md);
  static const SizedBox verticalLg = SizedBox(height: RrSpacing.lg);
  static const SizedBox verticalLgPlus = SizedBox(height: RrSpacing.lgPlus);
  static const SizedBox verticalXl = SizedBox(height: RrSpacing.xl);
  static const SizedBox verticalXxl = SizedBox(height: RrSpacing.xxl);
  static const SizedBox verticalXxlPlus = SizedBox(height: RrSpacing.xxlPlus);
  static const SizedBox verticalXxxl = SizedBox(height: RrSpacing.xxxl);

  // --- Horizontal gaps ---
  static const SizedBox horizontalXxs = SizedBox(width: RrSpacing.xxs);
  static const SizedBox horizontalXs = SizedBox(width: RrSpacing.xs);
  static const SizedBox horizontalSm = SizedBox(width: RrSpacing.sm);
  static const SizedBox horizontalMd = SizedBox(width: RrSpacing.md);
  static const SizedBox horizontalLg = SizedBox(width: RrSpacing.lg);
  static const SizedBox horizontalLgPlus = SizedBox(width: RrSpacing.lgPlus);
  static const SizedBox horizontalXl = SizedBox(width: RrSpacing.xl);
  static const SizedBox horizontalXxl = SizedBox(width: RrSpacing.xxl);
  static const SizedBox horizontalXxlPlus = SizedBox(width: RrSpacing.xxlPlus);
  static const SizedBox horizontalXxxl = SizedBox(width: RrSpacing.xxxl);
}

/// Common border radius values.
abstract final class RrRadius {
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

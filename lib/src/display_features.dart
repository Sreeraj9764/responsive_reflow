import 'dart:ui' show DisplayFeature, DisplayFeatureState;

import 'package:flutter/widgets.dart';

/// Foldable / dual-screen awareness helpers built on
/// [MediaQuery.displayFeaturesOf].
///
/// Use these to lay out two-pane UIs that respect a device hinge or fold,
/// rather than rendering content underneath it.
abstract final class ReflowDisplayFeatures {
  /// Returns the display features (hinges, folds, cutouts) for [context].
  static List<DisplayFeature> of(BuildContext context) =>
      MediaQuery.displayFeaturesOf(context);

  /// Returns the first separating fold/hinge that splits the screen into two
  /// vertical halves (a left/right split), or null if none is present.
  ///
  /// A vertical fold is the signal to switch to a side-by-side two-pane layout.
  static DisplayFeature? verticalFold(BuildContext context) {
    for (final feature in of(context)) {
      final separates =
          feature.state == DisplayFeatureState.postureHalfOpened ||
              feature.state == DisplayFeatureState.postureFlat;
      final isVertical = feature.bounds.width >= feature.bounds.height;
      // A vertical hinge runs top-to-bottom, so its bounds are tall & narrow.
      if (separates && !isVertical && feature.bounds.top == 0) {
        return feature;
      }
    }
    return null;
  }

  /// Whether the window is currently split by a vertical fold/hinge.
  static bool hasVerticalFold(BuildContext context) =>
      verticalFold(context) != null;
}

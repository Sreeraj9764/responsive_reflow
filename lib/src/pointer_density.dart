import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// The active pointer paradigm, used to tune hit-target density.
enum RrInputMode {
  /// Touch input — standard (larger) hit targets.
  touch,

  /// Mouse / trackpad / stylus — denser hit targets are acceptable.
  pointer,
}

/// Adaptive helpers for [VisualDensity] based on the active input device.
///
/// Touch UIs need larger hit targets; mouse/trackpad users benefit from a
/// denser layout. Follow the "solve touch first, then layer on pointer
/// accelerators" guidance from the Flutter adaptive docs.
abstract final class RrDensity {
  /// Resolves the likely [RrInputMode] for the given [platform].
  ///
  /// Uses [defaultTargetPlatform] as a heuristic: Android/iOS default to touch,
  /// desktop and web default to pointer. For precise per-event detection wrap a
  /// region in [RrPointerModeDetector].
  static RrInputMode inputModeFor(TargetPlatform platform) =>
      switch (platform) {
        TargetPlatform.android || TargetPlatform.iOS => RrInputMode.touch,
        _ => RrInputMode.pointer,
      };

  /// Convenience: resolves the [RrInputMode] for the ambient platform.
  static RrInputMode get inputMode => inputModeFor(defaultTargetPlatform);

  /// Returns a [VisualDensity] tuned for the given [mode].
  ///
  /// Touch uses [VisualDensity.standard]; pointer uses a slightly compact
  /// density (−1 on both axes ≈ 4 logical px tighter per unit in Material).
  static VisualDensity densityFor(RrInputMode mode) => switch (mode) {
        RrInputMode.touch => VisualDensity.standard,
        RrInputMode.pointer => const VisualDensity(
            horizontal: -1,
            vertical: -1,
          ),
      };

  /// Convenience: resolves [VisualDensity] for the ambient platform.
  static VisualDensity get density => densityFor(inputMode);
}

/// Detects the active pointer kind from real pointer events and exposes the
/// resulting [RrInputMode] to [builder].
///
/// Unlike the platform heuristic in [RrDensity], this reflects the device the
/// user is *actually* using right now (e.g. a mouse plugged into a tablet).
///
/// ```dart
/// RrPointerModeDetector(
///   builder: (context, mode) => Theme(
///     data: Theme.of(context).copyWith(
///       visualDensity: RrDensity.densityFor(mode),
///     ),
///     child: child,
///   ),
/// )
/// ```
class RrPointerModeDetector extends StatefulWidget {
  const RrPointerModeDetector({
    super.key,
    required this.builder,
    this.initialMode = RrInputMode.touch,
  });

  /// Builds the subtree given the most recently observed [RrInputMode].
  final Widget Function(BuildContext context, RrInputMode mode) builder;

  /// Mode used before any pointer event is observed.
  final RrInputMode initialMode;

  @override
  State<RrPointerModeDetector> createState() => _RrPointerModeDetectorState();
}

class _RrPointerModeDetectorState extends State<RrPointerModeDetector> {
  late RrInputMode _mode = widget.initialMode;

  void _update(PointerEvent event) {
    final next = switch (event.kind) {
      PointerDeviceKind.touch => RrInputMode.touch,
      _ => RrInputMode.pointer,
    };
    if (next != _mode) {
      setState(() => _mode = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _update,
      onPointerHover: _update,
      child: widget.builder(context, _mode),
    );
  }
}

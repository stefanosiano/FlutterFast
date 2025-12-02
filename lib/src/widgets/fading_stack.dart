import 'package:flutter_fast/src/widgets/animated_stack.dart';
import 'package:flutter/material.dart';

/// [AnimatedStack] with fading animation.
/// The [current] child fades in, while the other children in [_childrenMap] fade out.
/// If the child key is not found [onMissingKey] is called, returning an empty Container by default.
class FadingStack extends AnimatedStack {
  FadingStack({
    super.key,
    required Map<String, Widget Function()> childrenMap,
    required super.current,
    super.duration = const Duration(milliseconds: 300),
    super.onMissingKey,
  }) : super(childrenMap.map((key, value) => MapEntry(key, (v) => Opacity(opacity: v, child: value()))));
}

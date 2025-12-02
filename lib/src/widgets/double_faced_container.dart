import 'dart:math';

import 'package:flutter/material.dart';

/// Container with two children. If [showFront] is true, [frontChild] will be shown, otherwise [backChild].
/// Changing [showFront] between two rebuilds animates between the two children for the specified [duration].
/// ```dart
/// DoubleFacedContainer(
///   showFront: myBool,
///   frontChild: (c) => child1,
///   backChild: (c) => child2,
///   duration: Duration(milliseconds: 500),
/// ),
/// ```
class DoubleFacedContainer extends StatelessWidget {
  final Widget Function(BuildContext context) frontChild;
  final Widget Function(BuildContext context) backChild;
  final bool showFront;
  final Duration duration;

  const DoubleFacedContainer(
      {super.key,
      required this.frontChild,
      required this.backChild,
      required this.showFront,
      this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: duration,
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: showFront ? 0 : 180),
      builder: (context, double value, child) {
        return Container(
          transformAlignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((value >= 90 ? value - 180 : value) * pi / 180),
          child: value >= 90 ? backChild(context) : frontChild(context),
        );
      },
    );
  }
}

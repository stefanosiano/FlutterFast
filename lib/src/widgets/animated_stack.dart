import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Stack that executes animations on its children.
/// The latest child ([current]) animates in (animationValue in [_childrenMap] increases to 1.0).
/// Other children animate out (animationValue in [_childrenMap] decreases to 0.0 and is then removed from the stack).
/// If the child key is not found [onMissingKey] is called, returning an empty Container by default.
class AnimatedStack extends StatefulWidget {
  const AnimatedStack(
    this._childrenMap, {
    super.key,
    required String current,
    Widget Function(double animationValue)? onMissingKey,
    Duration duration = const Duration(milliseconds: 300),
  })  : _current = current,
        _duration = duration,
        _onMissingKey = onMissingKey;

  /// Map of children builders associated to some keys. The builder has the animationValue passed as parameter.
  final Map<String, Widget Function(double animationValue)> _childrenMap;
  final Widget Function(double animationValue)? _onMissingKey;
  final Duration _duration;

  /// Key of the child builder that should animate in.
  final String _current;

  @override
  State<AnimatedStack> createState() => _AnimatedStackState();
}

class _AnimatedStackState extends State<AnimatedStack> {
  /// Key of the child animating in.
  String _inChild = "";

  /// Last animation value
  double _lastAnimationValue = 0.0;

  /// Keys of the children animating out.
  final List<String> _outChildren = [];

  /// Last animation values of the children animating out, in the moment the widget changed last time (_inChildKey changed).
  final Map<String, double> _outAnimationValues = {};

  @override
  Widget build(BuildContext context) {
    if (_inChild != widget._current) {
      // The child animating in is changing (it will become widget.childKey), so we add it to the out children
      if (_inChild.isNotEmpty && !_outChildren.contains(_inChild)) {
        _outChildren.add(_inChild);
      }

      // .toList() is necessary, otherwise the for loop randomly skips some values (?!?)
      for (final String outChild in _outChildren.toList()) {
        // Animations should continue from the last animation value of each child, or 0 if they were not added.
        double outValue = _outAnimationValues[outChild] ?? 0;
        // The _inChild was animating in, so we should add _lastAnimationValue to get its current animation value.
        // The _outChildren were animating out, so we should remove _lastAnimationValue to get their current animation value.
        double newOutValue = outChild == _inChild ? outValue + _lastAnimationValue : outValue - _lastAnimationValue;
        _outAnimationValues[outChild] = min(1, newOutValue);

        // We can remove any child completely animated out, as they wouldn't be drawn anyway. If newOutValue is 1 (the
        // child is completely animated in) we don't remove it, as it will animate out when a new one is coming in.
        if (newOutValue <= 0) {
          _outChildren.removeWhere((element) => element == outChild);
          _outAnimationValues.remove(outChild);
        }
      }
      _inChild = widget._current;
    }

    return TweenAnimationBuilder(
        key: ValueKey(widget._current),
        duration: widget._duration,
        curve: Curves.linear,
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, double value, child) {
          // We always update the _lastAnimationValue value
          _lastAnimationValue = value;
          // We use the last value of the child animating in, and we continue the animation from there.
          double inChildValue = (_outAnimationValues[_inChild] ?? 0) + value;
          inChildValue = min(inChildValue, 1.0);

          return Stack(
            key: ValueKey(widget._current),
            children: [
              for (String child in _outChildren)
                _childBuilder(child)
                    .call(child == _inChild ? inChildValue : max(0, _outAnimationValues[child]! - value)),
              // If the child animating in was already animating out, we keep it in the outChildren stack to keep the same order.
              if (!_outChildren.contains(_inChild)) _childBuilder(_inChild).call(inChildValue),
            ],
          );
        });
  }

  Widget Function(double) _childBuilder(String childKey) =>
      widget._childrenMap[childKey] ?? widget._onMissingKey ?? (_) => Container();
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Column with the last element being a colored [AnimatedContainer] that expands on mouse hover, like a line.
class AnimatedUnderlineContainer extends StatefulWidget {
  final Widget child;
  final void Function()? onPressed;
  final double height;
  final bool expand;
  final Color? lineColor;

  const AnimatedUnderlineContainer({
    super.key,
    required this.child,
    this.onPressed,
    this.height = 4,
    this.expand = false,
    this.lineColor,
  });

  @override
  State<AnimatedUnderlineContainer> createState() => _AnimatedUnderlineContainerState();
}

class _AnimatedUnderlineContainerState extends State<AnimatedUnderlineContainer> {
  double _underlineExpectedWidth = 0;
  double _maxWidth = 0;

  void _updateLineState(bool expand) {
    if (widget.onPressed != null) {
      setState(() => _underlineExpectedWidth = widget.expand || expand ? _maxWidth : 0);
    }
  }

  // If the size changes due to window resizing, we need to update the _maxWidth
  @override
  void didUpdateWidget(AnimatedUnderlineContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maxWidth = 0;
  }

  @override
  Widget build(BuildContext context) {
    // if _maxWidth has not been set, let's post a callback after first frame to set it
    if (_maxWidth == 0) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        if (renderBox.hasSize) {
          _maxWidth = renderBox.size.width;
          // if widget.expand is changed from previous creation, we need to start the animation
          _updateLineState(widget.expand);
        }
      });
    }
    return MouseRegion(
      cursor: widget.onPressed != null ? WidgetStateMouseCursor.clickable : MouseCursor.defer,
      onEnter: (e) => _updateLineState(true),
      onExit: (e) => _updateLineState(false),
      child: GestureDetector(
        onTap: widget.onPressed == null
            ? null
            : () {
                _updateLineState(false);
                widget.onPressed?.call();
              },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.child,
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.decelerate,
              width: _underlineExpectedWidth,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.lineColor ?? Theme.of(context).colorScheme.primary, //.withOpacity(0.75),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

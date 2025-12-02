import 'dart:math';

import 'package:flutter_fast/src/extensions/types_extensions.dart';
import 'package:flutter_fast/src/widgets/tappable_mouse_region.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Container that simulates a dropdown using an [OverlayPortal].
/// Its top center is aligns with the center bottom of the [child].
/// It's shown through an animation whenever [child] is clicked on or the mouse hovers it.
class DropdownContainer extends StatefulWidget {
  const DropdownContainer(
      {super.key,
      required this.child,
      required this.dropdownBuilder,
      this.maxDropdownHeight,
      this.maxDropdownWidth,
      required this.alignment,
      this.bodyAlignment});

  final Widget child;
  final Widget Function(BuildContext context) dropdownBuilder;
  final int? maxDropdownHeight, maxDropdownWidth;
  final Alignment alignment;
  final Alignment? bodyAlignment;

  @override
  State<DropdownContainer> createState() => _DropdownContainerState();
}

class _DropdownContainerState extends State<DropdownContainer> {
  bool _expand = false;
  bool _isHoveringHeader = false;
  bool _isClosing = false;
  bool _isHoveringBody = false;
  Rect _headerBounds = Rect.zero;
  late final OverlayPortalController _tooltipController;

  @override
  void initState() {
    super.initState();
    _tooltipController = OverlayPortalController();
  }

  @override
  Widget build(BuildContext context) {
    _InnerExpandingOverlayContainer expandableHeightContainer = _InnerExpandingOverlayContainer(
      onBodyExit: () {
        _isHoveringBody = false;
        _close();
      },
      onBodyEnter: () => _isHoveringBody = true,
      onBodyTap: () {
        _isHoveringHeader = false;
        _isHoveringBody = false;
        _close();
      },
      onBodyHover: (e) {
        // Check if we exit the area of the header by checking the position of the mouse in the overlay, as the overlay
        // is shown on top of this widget
        if (e.position.dx < _headerBounds.left ||
            e.position.dx > _headerBounds.right ||
            e.position.dy < _headerBounds.top ||
            e.position.dy > _headerBounds.bottom) {
          if (_isHoveringHeader) {
            _isHoveringHeader = false;
            _close();
          }
        } else {
          if (!_isClosing) {
            _isHoveringHeader = true;
          }
        }
      },
      expand: _expand,
      dropdownBuilder: widget.dropdownBuilder,
      maxDropdownHeight: widget.maxDropdownHeight,
      maxDropdownWidth: widget.maxDropdownWidth,
      alignment: widget.alignment,
      bodyAlignment: widget.bodyAlignment,
      tooltipController: _tooltipController,
      child: widget.child,
    );

    return TappableMouseRegion(
      onEnter: (e) => _headerFirstTimeEntered(expandableHeightContainer),
      onTap: () {
        if (_isHoveringHeader) {
          _isHoveringHeader = false;
          _close();
        } else {
          _headerFirstTimeEntered(expandableHeightContainer);
        }
      },
      child: expandableHeightContainer,
    );
  }

  /// Setup the widget and show [expandableHeightContainer] the first time the header area is entered with the mouse.
  void _headerFirstTimeEntered(_InnerExpandingOverlayContainer expandableHeightContainer) {
    if (_expand) {
      return;
    }
    setState(() {
      _isHoveringHeader = true;
      _expand = true;
      RenderBox box = context.findRenderObject() as RenderBox;
      Offset offset = box.localToGlobal(Offset.zero);
      _headerBounds = box.semanticBounds.translate(offset.dx, offset.dy);
      expandableHeightContainer.showBody();
    });
  }

  void _close() {
    if (_isHoveringBody || _isHoveringHeader) return;
    _isClosing = true;
    // Future.delayed is needed to avoid _isHoveringHeader flag mismatch when moving from body to header.
    // SchedulerBinding cannot be used as it works only once per widget render (it makes sense in initState only).
    Future.delayed(Duration.zero, () {
      if (_isHoveringBody || _isHoveringHeader) return;
      setState(() {
        _expand = false;
        _isClosing = false;
      });
    });
  }
}

class _InnerExpandingOverlayContainer extends StatelessWidget {
  _InnerExpandingOverlayContainer(
      {required this.child,
      required this.dropdownBuilder,
      required this.expand,
      required this.onBodyExit,
      required this.onBodyEnter,
      required this.onBodyTap,
      required this.onBodyHover,
      this.maxDropdownHeight,
      this.maxDropdownWidth,
      required this.alignment,
      this.bodyAlignment,
      required this.tooltipController});

  final Widget child;
  final Widget Function(BuildContext context) dropdownBuilder;
  final bool expand;
  final void Function() onBodyExit;
  final void Function() onBodyEnter;
  final void Function() onBodyTap;
  final void Function(PointerHoverEvent e) onBodyHover;
  final _link = LayerLink();
  final int? maxDropdownHeight;
  final int? maxDropdownWidth;
  final Alignment alignment;
  final Alignment? bodyAlignment;
  final OverlayPortalController tooltipController;

  void showBody() => tooltipController.show();

  // we delay the call to the next event loop, otherwise an exception is thrown during widget build
  void _delayedHideBody() => SchedulerBinding.instance.addPostFrameCallback((_) => tooltipController.hide());

  @override
  Widget build(BuildContext context) {
    /* example from https://medium.com/snapp-x/creating-custom-dropdowns-with-overlayportal-in-flutter-4f09b217cfce */
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0, end: expand ? 1 : 0),
      builder: (context, double value, child) {
        // If the dropdown is animating towards 0 and reaches 0, we call controller.hide()
        if (value == 0 && !expand) {
          _delayedHideBody();
        }
        return CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: tooltipController,
            overlayChildBuilder: (BuildContext context) {
              return TappableMouseRegion(
                onHover: onBodyHover,
                onTap: onBodyTap,
                // Transparent (needed to make it have a size) container to enable click to dismiss
                child: Container(
                  color: Colors.transparent,
                  child: CompositedTransformFollower(
                    link: _link,
                    targetAnchor: _targetAnchorAlignment(),
                    followerAnchor: _followerAnchorAlignment(),
                    child: Align(
                      alignment: _followerAnchorAlignment(),
                      // Child with constraints for animation to show dropdownBuilder
                      child: LayoutBuilder(builder: (context, constraints) {
                        // Calculate max width and height based on the current position of the widget to avoid overflowing outside the layout
                        final RenderBox renderBox = context.findRenderObject() as RenderBox;
                        final Offset position = renderBox.localToGlobal(Offset.zero);
                        final double maxHeight =
                            min(maxDropdownHeight?.toDouble() ?? double.infinity, constraints.maxHeight - position.dy);
                        final double maxWidth =
                            min(maxDropdownWidth?.toDouble() ?? double.infinity, constraints.maxWidth - position.dx);
                        return MouseRegion(
                          onExit: (e) => onBodyExit(),
                          onEnter: (e) => onBodyEnter(),
                          onHover: (_) => onBodyEnter(),
                          hitTestBehavior: HitTestBehavior.opaque,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxHeight.mul(value),
                              maxWidth: maxWidth.mul(value),
                            ),
                            child: FittedBox(fit: BoxFit.cover, child: Builder(builder: dropdownBuilder)),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Alignment _targetAnchorAlignment() => switch (alignment) {
        Alignment.centerLeft => Alignment.centerLeft,
        Alignment.center => Alignment.center,
        Alignment.centerRight => Alignment.centerRight,
        Alignment.topLeft => Alignment.topLeft,
        Alignment.topCenter => Alignment.topCenter,
        Alignment.topRight => Alignment.topRight,
        Alignment.bottomLeft => Alignment.bottomLeft,
        Alignment.bottomCenter => Alignment.bottomCenter,
        Alignment.bottomRight => Alignment.bottomRight,
        _ => alignment
      };

  Alignment _followerAnchorAlignment() =>
      bodyAlignment ??
      switch (alignment) {
        Alignment.centerLeft => Alignment.centerRight,
        Alignment.center => Alignment.center,
        Alignment.centerRight => Alignment.centerLeft,
        Alignment.topLeft => Alignment.bottomLeft,
        Alignment.topCenter => Alignment.bottomCenter,
        Alignment.topRight => Alignment.bottomRight,
        Alignment.bottomLeft => Alignment.topLeft,
        Alignment.bottomCenter => Alignment.topCenter,
        Alignment.bottomRight => Alignment.topRight,
        _ => Alignment.bottomRight
      };
}

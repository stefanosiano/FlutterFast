import 'package:flutter/widgets.dart';

class TappableMouseRegion extends MouseRegion {
  TappableMouseRegion({
    super.key,
    super.onEnter,
    super.onExit,
    super.onHover,
    super.cursor = MouseCursor.defer,
    super.opaque = true,
    super.hitTestBehavior,
    Widget? child,
    Function()? onTap,
  }) : super(child: GestureDetector(onTap: onTap, child: child));
}

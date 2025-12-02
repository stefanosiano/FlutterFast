import 'package:flutter/material.dart';

extension GestureExtensions on Widget {
  Widget onHover({
    MouseCursor cursor = MouseCursor.defer,
    Function(bool inside)? onHover,
    Function()? onTap,
  }) {
    return MouseRegion(
      cursor: cursor,
      onEnter: (b) => onHover?.call(true),
      onExit: (b) => onHover?.call(false),
      child: onTap == null ? this : GestureDetector(onTap: () => onTap.call(), child: this),
    );
  }
}

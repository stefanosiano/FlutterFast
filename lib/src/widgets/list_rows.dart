import 'dart:math';

import 'package:flutter/material.dart';

class ListRows extends StatelessWidget {
  final int count;
  final int columnCount;
  final double verticalSpacing;
  final double horizontalSpacing;
  final Widget Function(BuildContext, int) itemBuilder;

  const ListRows({
    super.key,
    required this.count,
    required this.columnCount,
    required this.itemBuilder,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final int columnLength = verticalSpacing == 0 ? (count / columnCount).ceil() : (count / columnCount).ceil() * 2 - 1;
    if (columnLength <= 0) return Container();
    return Column(
      children: List.generate(columnLength, (rowIndex) {
        return verticalSpacing == 0
            ? _buildRow(context, rowIndex)
            : rowIndex.isEven
                ? _buildRow(context, rowIndex ~/ 2)
                : SizedBox(height: verticalSpacing);
      }),
    );
  }

  Widget _buildRow(BuildContext context, int rowIndex) {
    final int startIndex = rowIndex * columnCount;
    final int rowLength =
        horizontalSpacing == 0 ? min(count - startIndex, columnCount) : min(count - startIndex, columnCount) * 2 - 1;
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          rowLength,
          (index) => horizontalSpacing == 0
              ? itemBuilder(context, startIndex + index)
              : index.isEven
                  ? itemBuilder(context, startIndex + index ~/ 2)
                  : SizedBox(width: horizontalSpacing),
        ),
      ),
    );
  }
}

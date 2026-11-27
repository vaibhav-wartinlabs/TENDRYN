import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';

/// Lays cards out in as many equal columns as fit, each at least
/// [minColumnWidth] wide (one column on phones, two on wide tablets).
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.children,
    this.minColumnWidth = 420,
    this.spacing = Dimensions.spaceMd,
  });

  final List<Widget> children;
  final double minColumnWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            ((constraints.maxWidth + spacing) / (minColumnWidth + spacing))
                .floor()
                .clamp(1, children.length.clamp(1, 4));
        if (columns == 1) {
          return Column(
            spacing: spacing,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }
        return Column(
          spacing: spacing,
          children: [
            for (var i = 0; i < children.length; i += columns)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: spacing,
                  children: [
                    for (var j = i; j < i + columns; j++)
                      Expanded(
                        child: j < children.length
                            ? children[j]
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

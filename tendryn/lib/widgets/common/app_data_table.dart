import 'package:flutter/material.dart';
import 'package:tendryn/core/constants/dimensions.dart';
import 'package:tendryn/core/theme/app_text_styles.dart';

/// One table column: a header label, a fixed width or flex share of leftover
/// space, and a cell builder.
class AppTableColumn<T> {
  const AppTableColumn({
    required this.label,
    required this.cell,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final double? width;
  final int flex;
  final AlignmentGeometry alignment;
  final Widget Function(BuildContext context, T row) cell;
}

/// Dense data table in the Tendryn style: a 44px header on the app background
/// with top and bottom borders, rows with a bottom border and hover feedback.
/// If the available width is below [minWidth] it scrolls horizontally instead
/// of squeezing the columns.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.horizontalPadding = Dimensions.sectionPadding,
    this.columnGap = Dimensions.tableColumnGap,
    this.rowMinHeight = Dimensions.tableRowMinHeight,
    this.minWidth,
    this.onRowTap,
    this.distributeColumnWidths = false,
  });

  final List<AppTableColumn<T>> columns;
  final List<T> rows;
  final double horizontalPadding;
  final double columnGap;
  final double rowMinHeight;
  final double? minWidth;
  final ValueChanged<T>? onRowTap;

  /// Uses width/flex values as proportions across the available table width.
  final bool distributeColumnWidths;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = BorderSide(
      color: scheme.outline,
      width: Dimensions.strokeDivider,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final table = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: Dimensions.tableHeaderHeight,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(bottom: border),
              ),
              child: _line(
                (c) => Text(
                  c.label,
                  style: AppTextStyles.caption.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                distributeColumnWidths: distributeColumnWidths,
              ),
            ),
            for (final row in rows)
              InkWell(
                onTap: onRowTap == null ? null : () => onRowTap!(row),
                hoverColor: scheme.primaryContainer.withValues(alpha: 0.35),
                child: Container(
                  constraints: BoxConstraints(minHeight: rowMinHeight),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: Dimensions.spaceSm,
                  ),
                  decoration: BoxDecoration(border: Border(bottom: border)),
                  child: _line(
                    (c) => c.cell(context, row),
                    distributeColumnWidths: distributeColumnWidths,
                  ),
                ),
              ),
          ],
        );

        if (minWidth != null && constraints.maxWidth < minWidth!) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: minWidth, child: table),
          );
        }
        return table;
      },
    );
  }

  Widget _line(
    Widget Function(AppTableColumn<T> column) content, {
    required bool distributeColumnWidths,
  }) {
    return Row(
      spacing: columnGap,
      children: [
        for (final c in columns)
          distributeColumnWidths
              ? Expanded(
                  flex: c.width?.round() ?? c.flex,
                  child: Align(alignment: c.alignment, child: content(c)),
                )
              : c.width == null
              ? Expanded(
                  flex: c.flex,
                  child: Align(alignment: c.alignment, child: content(c)),
                )
              : SizedBox(
                  width: c.width,
                  child: Align(alignment: c.alignment, child: content(c)),
                ),
      ],
    );
  }
}

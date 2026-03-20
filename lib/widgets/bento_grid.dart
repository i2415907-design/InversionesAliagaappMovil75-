import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

/// Celda del Bento Grid: ocupa [colSpan] columnas y [rowSpan] filas.
class BentoCell {
  final int colSpan;
  final int rowSpan;
  final Widget child;

  const BentoCell({
    this.colSpan = 1,
    this.rowSpan = 1,
    required this.child,
  });
}

/// Grid tipo Bento: 2 columnas, celdas de tamaño variable.
/// [crossAxisCount] columnas; cada BentoCell define colSpan/rowSpan.
class BentoGrid extends StatelessWidget {
  final List<BentoCell> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectBase;

  const BentoGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectBase = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cellWidth = (width - crossAxisSpacing * (crossAxisCount - 1)) / crossAxisCount;
        final baseHeight = cellWidth / childAspectBase;
        final rowHeights = <double>[];
        var rowIndex = 0;
        while (rowIndex < 100) {
          rowHeights.add(baseHeight);
          rowIndex++;
          if (rowIndex >= 20) break;
        }

        int currentRow = 0;
        int currentCol = 0;
        final positioned = <Widget>[];

        for (final cell in children) {
          final c = cell.colSpan.clamp(1, crossAxisCount);
          final r = cell.rowSpan.clamp(1, 10);
          double w = cellWidth * c + crossAxisSpacing * (c - 1);
          double h = 0;
          for (var i = 0; i < r && (currentRow + i) < rowHeights.length; i++) {
            h += rowHeights[currentRow + i];
          }
          if (r > 0 && rowHeights.length >= currentRow + r) {
            h = 0;
            for (var i = 0; i < r; i++) h += rowHeights[currentRow + i];
          } else {
            h = baseHeight * r;
          }

          final left = currentCol * (cellWidth + crossAxisSpacing);
          var top = 0.0;
          for (var i = 0; i < currentRow; i++) top += rowHeights[i] + mainAxisSpacing;

          positioned.add(
            Positioned(
              left: left,
              top: top,
              width: w,
              height: h + mainAxisSpacing * (r - 1),
              child: cell.child,
            ),
          );

          currentCol += c;
          if (currentCol >= crossAxisCount) {
            currentCol = 0;
            currentRow += r;
          }
        }

        final totalRows = currentRow + (currentCol > 0 ? 1 : 0);
        final totalHeight = totalRows * baseHeight + (totalRows - 1) * mainAxisSpacing;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            children: positioned,
          ),
        );
      },
    );
  }
}

/// Versión simple: 2 columnas, lista de widgets con span opcional.
/// [items] es lista de (Widget, {colSpan?, rowSpan?}).
class BentoGridSimple extends StatelessWidget {
  final List<BentoGridItem> items;
  final double spacing;
  final double childMinHeight;

  const BentoGridSimple({
    super.key,
    required this.items,
    this.spacing = 12,
    this.childMinHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cellW = (w - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            final span = item.colSpan ?? 1;
            final width = span == 2 ? w : cellW;
            return SizedBox(
              width: width,
              child: item.child,
            );
          }).toList(),
        );
      },
    );
  }
}

class BentoGridItem {
  final Widget child;
  final int? colSpan;
  final int? rowSpan;

  BentoGridItem({required this.child, this.colSpan, this.rowSpan});
}

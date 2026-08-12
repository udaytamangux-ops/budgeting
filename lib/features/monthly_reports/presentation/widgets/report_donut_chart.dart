import 'dart:math' as math;

import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/formatting/report_percentage_formatter.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class ReportDonutChart extends StatelessWidget {
  const ReportDonutChart({
    required this.title,
    required this.slices,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final List<ReportChartSlice> slices;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return Semantics(
        label: emptyMessage,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text(emptyMessage),
        ),
      );
    }
    final CurrencyFormatter formatter = CurrencyFormatter();
    final List<Color> colors = <Color>[
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.tertiary,
      Colors.teal.shade600,
      Colors.amber.shade700,
      Colors.purple.shade500,
    ];
    final String semantics = slices
        .map(
          (slice) =>
              '${slice.label}, ${formatter.format(slice.amount)}, '
              '${ReportPercentageFormatter.formatBasisPoints(slice.basisPoints)}',
        )
        .join('. ');
    return Semantics(
      container: true,
      label: '$title breakdown. $semantics',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool stacked = constraints.maxWidth < 520;
            final Widget chart = SizedBox.square(
              dimension: stacked ? 190 : 210,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _ReportDonutPainter(
                    basisPoints: slices
                        .map((slice) => slice.basisPoints)
                        .toList(growable: false),
                    colors: colors,
                    background: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            );
            final Widget legend = Column(
              children: <Widget>[
                for (int index = 0; index < slices.length; index += 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: Text(slices[index].label)),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            '${formatter.format(slices[index].amount)} · '
                            '${ReportPercentageFormatter.formatBasisPoints(slices[index].basisPoints)}',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
            return stacked
                ? Column(
                    children: <Widget>[
                      chart,
                      const SizedBox(height: AppSpacing.md),
                      legend,
                    ],
                  )
                : Row(
                    children: <Widget>[
                      chart,
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(child: legend),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

final class _ReportDonutPainter extends CustomPainter {
  const _ReportDonutPainter({
    required this.basisPoints,
    required this.colors,
    required this.background,
  });

  final List<int> basisPoints;
  final List<Color> colors;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2 - 8;
    final double strokeWidth = math.max(22, radius * 0.28);
    final Rect rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = background
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    double start = -math.pi / 2;
    for (int index = 0; index < basisPoints.length; index += 1) {
      final double sweep = math.pi * 2 * basisPoints[index] / 10000;
      canvas.drawArc(
        rect,
        start,
        math.max(0, sweep - 0.018),
        false,
        Paint()
          ..color = colors[index % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = strokeWidth,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_ReportDonutPainter oldDelegate) =>
      !listEquals(oldDelegate.basisPoints, basisPoints) ||
      !listEquals(oldDelegate.colors, colors) ||
      oldDelegate.background != background;
}

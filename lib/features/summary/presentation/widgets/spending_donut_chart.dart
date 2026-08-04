import 'dart:math' as math;

import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';

extension CategorySpendingGroupPresentation on CategorySpendingGroup {
  String get displayLabel => category?.visual.label ?? 'Other';

  Color get displayAccent =>
      category?.visual.foreground ?? AppColors.categorySlateAccent;

  Color get displaySurface =>
      category?.visual.background ?? AppColors.categorySlateSurface;

  IconData get displayIcon => category?.visual.icon ?? Icons.more_horiz;
}

final class SpendingDonutChart extends StatelessWidget {
  const SpendingDonutChart({
    required this.groups,
    required this.total,
    required this.currencyFormatter,
    super.key,
  });

  static const double diameter = 224;

  final List<CategorySpendingGroup> groups;
  final Money total;
  final CurrencyFormatter currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final String formattedTotal = currencyFormatter.format(total);
    final String semanticSummary = <String>[
      'Spending by category',
      'Total recorded expenses, $formattedTotal',
      ...groups.map(
        (CategorySpendingGroup group) =>
            '${group.displayLabel}, ${group.sharePercentage} percent, '
            '${currencyFormatter.format(group.amount)}',
      ),
    ].join('. ');

    return Semantics(
      key: const ValueKey<String>('spending_donut_chart'),
      container: true,
      label: semanticSummary,
      excludeSemantics: true,
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                size: const Size.square(diameter),
                painter: _SpendingDonutPainter(groups: groups, total: total),
              ),
              SizedBox(
                width: 144,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Recorded expenses',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formattedTotal,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFeatures: AppTypography.tabularFigures,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SpendingDonutPainter extends CustomPainter {
  const _SpendingDonutPainter({required this.groups, required this.total});

  final List<CategorySpendingGroup> groups;
  final Money total;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 24;
    final Offset center = size.center(Offset.zero);
    final double radius =
        math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final Rect arcBounds = Rect.fromCircle(center: center, radius: radius);
    final Paint trackPaint = Paint()
      ..color = AppColors.surfaceSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (groups.isEmpty || total.minorUnits <= 0) {
      return;
    }

    const double fullCircle = math.pi * 2;
    const double preferredGap = math.pi / 90;
    double startAngle = -math.pi / 2;
    for (final CategorySpendingGroup group in groups) {
      final double sweepAngle =
          fullCircle * group.amount.minorUnits / total.minorUnits;
      final double gap = math.min(preferredGap, sweepAngle * 0.18);
      final Paint segmentPaint = Paint()
        ..color = group.displayAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        arcBounds,
        startAngle + gap / 2,
        math.max(0, sweepAngle - gap),
        false,
        segmentPaint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SpendingDonutPainter oldDelegate) {
    if (total != oldDelegate.total ||
        groups.length != oldDelegate.groups.length) {
      return true;
    }
    for (int index = 0; index < groups.length; index += 1) {
      final CategorySpendingGroup current = groups[index];
      final CategorySpendingGroup previous = oldDelegate.groups[index];
      if (current.category != previous.category ||
          current.amount != previous.amount ||
          current.sharePercentage != previous.sharePercentage) {
        return true;
      }
    }
    return false;
  }
}

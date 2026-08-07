import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:flutter/material.dart';

final class BudgetProgressIndicator extends StatelessWidget {
  const BudgetProgressIndicator({
    required this.summary,
    required this.currencyFormatter,
    super.key,
  });

  final MonthlyBudgetSummary summary;
  final CurrencyFormatter currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final int percentage = (summary.usedFraction * 100).round();
    final String spent = currencyFormatter.format(summary.spent);
    final String remaining = currencyFormatter.format(summary.remaining);
    final double indicatorValue = summary.usedFraction.clamp(0, 1);

    return Semantics(
      label:
          'Monthly budget, $percentage percent used, $spent spent, '
          '$remaining remaining',
      value: '$percentage percent used',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget percentageLabel = Text(
                '$percentage% used',
                style: Theme.of(context).textTheme.titleMedium,
              );
              final Widget remainingLabel = Text(
                '$remaining left',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              );
              if (MediaQuery.textScalerOf(context).scale(14) > 20) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    percentageLabel,
                    const SizedBox(height: AppSpacing.xxs),
                    remainingLabel,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(child: percentageLabel),
                  remainingLabel,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            duration: AppMotion.accessibleDuration(context, AppMotion.standard),
            curve: AppMotion.emphasized,
            tween: Tween<double>(begin: 0, end: indicatorValue),
            builder: (BuildContext context, double value, Widget? child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: summary.usedFraction >= 0.9
                    ? context.appColors.warning
                    : context.appColors.primaryAction,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$spent of ${currencyFormatter.format(summary.limit)} this month',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

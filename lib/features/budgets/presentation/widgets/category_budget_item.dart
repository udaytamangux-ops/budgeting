import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';

final class CategoryBudgetItem extends StatelessWidget {
  const CategoryBudgetItem({
    required this.progress,
    required this.currencyFormatter,
    super.key,
  });

  final CategoryBudgetProgress progress;
  final CurrencyFormatter currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final String spent = currencyFormatter.format(progress.spent);
    final String limit = currencyFormatter.format(progress.limit);
    final String difference = currencyFormatter.format(
      progress.remaining.absolute,
    );
    final int percentage = (progress.usedFraction * 100).round();
    final _BudgetStatus status = progress.isExceeded
        ? _BudgetStatus.exceeded
        : progress.isNearLimit
        ? _BudgetStatus.nearLimit
        : _BudgetStatus.normal;
    final Color statusColor = switch (status) {
      _BudgetStatus.normal => AppColors.primaryAction,
      _BudgetStatus.nearLimit => AppColors.budgetWarning,
      _BudgetStatus.exceeded => AppColors.destructiveAction,
    };
    final String statusLabel = switch (status) {
      _BudgetStatus.normal => 'On track',
      _BudgetStatus.nearLimit => 'Near limit',
      _BudgetStatus.exceeded => 'Over limit',
    };
    final String differenceLabel = progress.isExceeded
        ? 'Exceeded by $difference'
        : 'Remaining $difference';

    return Semantics(
      label:
          '${progress.category.visual.label} budget. $spent spent. '
          'Limit $limit. $differenceLabel. $percentage percent used. '
          '$statusLabel.',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool shouldStack =
                    constraints.maxWidth < 360 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20;
                final Widget identity = Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: progress.category.visual.background,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Icon(
                        progress.category.visual.icon,
                        color: progress.category.visual.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            progress.category.visual.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            statusLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: statusColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                final Widget values = Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Spent $spent',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontFeatures: AppTypography.tabularFigures,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Limit $limit',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFeatures: AppTypography.tabularFigures,
                      ),
                    ),
                  ],
                );
                if (shouldStack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      identity,
                      const SizedBox(height: AppSpacing.sm),
                      Align(alignment: Alignment.centerRight, child: values),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: identity),
                    const SizedBox(width: AppSpacing.md),
                    values,
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progress.usedFraction.clamp(0, 1),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: statusColor,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    differenceLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: status == _BudgetStatus.exceeded
                          ? statusColor
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '$percentage% used',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _BudgetStatus { normal, nearLimit, exceeded }

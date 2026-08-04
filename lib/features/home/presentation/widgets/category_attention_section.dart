import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CategoryAttentionSection extends ConsumerWidget {
  const CategoryAttentionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyBudgetSummary> budget = ref.watch(
      monthlyBudgetSummaryProvider,
    );
    return budget.maybeWhen(
      data: (MonthlyBudgetSummary value) {
        final CategoryBudgetProgress? food = value.progressFor(
          TransactionCategory.food,
        );
        if (food == null) {
          return const SizedBox.shrink();
        }
        final String remaining = ref
            .watch(currencyFormatterProvider)
            .format(food.remaining);
        final String spent = ref
            .watch(currencyFormatterProvider)
            .format(food.spent);
        final int percent = (food.usedFraction * 100).round();
        final String status = food.isExceeded
            ? 'Budget exceeded'
            : food.isNearLimit
            ? 'Close to limit'
            : 'Keep an eye on this';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Category to watch',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label:
                  'Food category. $status. $spent spent. $remaining '
                  'remaining. $percent percent used.',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.surfacePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        TransactionCategory.food.visual.icon,
                        color: AppColors.budgetWarning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Food',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            status,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.budgetWarning),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$remaining remains from the food limit.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: food.usedFraction.clamp(0, 1),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                            color: AppColors.budgetWarning,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '$spent spent · $percent% used',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

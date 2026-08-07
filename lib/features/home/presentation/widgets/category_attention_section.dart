import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
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
            .format(food.remaining.absolute);
        final String spent = ref
            .watch(currencyFormatterProvider)
            .format(food.spent);
        final String limit = ref
            .watch(currencyFormatterProvider)
            .format(food.limit);
        final int percent = (food.usedFraction * 100).round();
        final _CategoryBudgetTone tone = food.isExceeded
            ? _CategoryBudgetTone.exceeded
            : food.isNearLimit
            ? _CategoryBudgetTone.nearLimit
            : _CategoryBudgetTone.normal;
        final String status = switch (tone) {
          _CategoryBudgetTone.normal => 'Within budget',
          _CategoryBudgetTone.nearLimit => '$remaining left before the limit',
          _CategoryBudgetTone.exceeded => '$remaining over the limit',
        };
        final String description = food.isExceeded
            ? '$spent spent against the $limit Food limit.'
            : '$remaining remains from the $limit Food limit.';
        final Color statusColor = switch (tone) {
          _CategoryBudgetTone.normal => context.appColors.balancePositive,
          _CategoryBudgetTone.nearLimit => context.appColors.warning,
          _CategoryBudgetTone.exceeded => context.appColors.destructiveAction,
        };
        final Color surfaceColor = switch (tone) {
          _CategoryBudgetTone.normal => context.appColors.surfacePrimary,
          _CategoryBudgetTone.nearLimit => context.appColors.warningSubtle,
          _CategoryBudgetTone.exceeded => context.appColors.dangerSubtle,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Food budget', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label:
                  'Food budget. $status. $spent spent of $limit. '
                  '$percent percent used.',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: context.appColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tone == _CategoryBudgetTone.normal
                            ? context.appColors.primarySubtle
                            : context.appColors.surfacePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        TransactionCategory.food.visual.icon,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            status,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: statusColor),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          LinearProgressIndicator(
                            value: food.usedFraction.clamp(0, 1),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                            color: statusColor,
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

enum _CategoryBudgetTone { normal, nearLimit, exceeded }

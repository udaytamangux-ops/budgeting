import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class MonthlyBudgetSection extends ConsumerWidget {
  const MonthlyBudgetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyBudgetSummary> budget = ref.watch(
      monthlyBudgetSummaryProvider,
    );
    return budget.maybeWhen(
      data: (MonthlyBudgetSummary value) {
        if (!value.hasBudget) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Monthly budget',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'No monthly budget is set.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Monthly budget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            BudgetProgressIndicator(
              summary: value,
              currencyFormatter: ref.watch(currencyFormatterProvider),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

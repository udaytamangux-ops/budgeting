import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyBudgetSummary> budget = ref.watch(
      monthlyBudgetSummaryProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: budget.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading monthly budget'),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                message: 'Your budget is unavailable. Try again.',
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              data: (MonthlyBudgetSummary value) {
                if (!value.hasBudget) {
                  return const EmptyState(
                    title: 'No monthly budget',
                    message:
                        'Set a monthly limit to understand how much is safe '
                        'to spend.',
                    icon: Icons.track_changes_outlined,
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    112,
                  ),
                  children: <Widget>[
                    Text(
                      'Monthly overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePrimary,
                        border: Border.all(color: AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: BudgetProgressIndicator(
                        summary: value,
                        currencyFormatter: ref.watch(currencyFormatterProvider),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Category limits',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...value.categories.map(
                      (CategoryBudgetProgress category) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(category.category.visual.icon),
                        title: Text(category.category.visual.label),
                        subtitle: Text(
                          '${ref.watch(currencyFormatterProvider).format(category.spent)} '
                          'of ${ref.watch(currencyFormatterProvider).format(category.limit)}',
                        ),
                        trailing: Text(
                          ref
                              .watch(currencyFormatterProvider)
                              .format(category.remaining),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class TransactionSavedBanner extends ConsumerWidget {
  const TransactionSavedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FinancialTransaction? transaction = ref.watch(
      lastSavedTransactionProvider,
    );

    return AnimatedSwitcher(
      duration: AppMotion.accessibleDuration(context, AppMotion.standard),
      child: transaction == null
          ? const SizedBox.shrink(key: ValueKey<String>('no_confirmation'))
          : _SavedBannerContent(
              key: ValueKey<String>(transaction.id),
              transaction: transaction,
            ),
    );
  }
}

final class _SavedBannerContent extends ConsumerWidget {
  const _SavedBannerContent({required this.transaction, super.key});

  final FinancialTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String amount = ref
        .watch(currencyFormatterProvider)
        .format(transaction.amount);
    final AsyncValue<MonthlyBudgetSummary> budget = ref.watch(
      monthlyBudgetSummaryProvider,
    );
    final String remaining = budget.maybeWhen(
      data: (MonthlyBudgetSummary value) {
        final CategoryBudgetProgress? category = value.progressFor(
          transaction.category,
        );
        return category == null
            ? ''
            : ref.watch(currencyFormatterProvider).format(category.remaining);
      },
      orElse: () => '',
    );
    final String description = remaining.isEmpty
        ? '$amount was added to ${transaction.category.visual.label}.'
        : '$amount was added to ${transaction.category.visual.label}. '
              '$remaining remains in this category.';

    final String savedKind = transaction.type == TransactionType.expense
        ? 'Expense'
        : 'Income';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.positiveSubtle,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ExcludeSemantics(
            child: Icon(
              Icons.check_circle_outline,
              color: AppColors.balancePositive,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  liveRegion: true,
                  label: '$savedKind added. $description',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$savedKind added',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: () {
                    ref.read(lastSavedTransactionProvider.notifier).dismiss();
                    unawaited(
                      context.push(
                        AppRoutes.transactionDetails(transaction.id),
                      ),
                    );
                  },
                  child: const Text('View transaction'),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Dismiss confirmation',
            onPressed: () =>
                ref.read(lastSavedTransactionProvider.notifier).dismiss(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

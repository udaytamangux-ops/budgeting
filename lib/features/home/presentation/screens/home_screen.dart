import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/home/presentation/widgets/available_balance_summary.dart';
import 'package:budgeting_app/features/home/presentation/widgets/category_attention_section.dart';
import 'package:budgeting_app/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:budgeting_app/features/home/presentation/widgets/monthly_budget_section.dart';
import 'package:budgeting_app/features/home/presentation/widgets/recent_transactions_section.dart';
import 'package:budgeting_app/features/home/presentation/widgets/transaction_saved_banner.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _HomeLoadState { loading, loaded, empty, error }

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _HomeLoadState loadState = ref.watch(
      transactionListProvider.select(
        (AsyncValue<List<FinancialTransaction>> value) => value.when(
          loading: () => _HomeLoadState.loading,
          error: (Object error, StackTrace stackTrace) => _HomeLoadState.error,
          data: (List<FinancialTransaction> transactions) =>
              transactions.isEmpty
              ? _HomeLoadState.empty
              : _HomeLoadState.loaded,
        ),
      ),
    );
    final String month = ref
        .watch(dateFormatterProvider)
        .monthYear(ref.watch(currentDateProvider));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Namaste', style: Theme.of(context).textTheme.titleLarge),
            Text(month, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: switch (loadState) {
              _HomeLoadState.loading => const HomeLoadingSkeleton(),
              _HomeLoadState.error => AppErrorState(
                message: 'Your financial summary is unavailable. Try again.',
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              _HomeLoadState.empty => EmptyState(
                title: 'No transactions yet',
                message:
                    'Add your first income or expense to start understanding '
                    'where your money goes.',
                icon: Icons.receipt_long_outlined,
                action: FilledButton.icon(
                  onPressed: () =>
                      _openTransactionForm(context, ref, AppRoutes.addExpense),
                  icon: const Icon(Icons.add),
                  label: const Text('Add expense'),
                ),
              ),
              _HomeLoadState.loaded => ListView(
                key: const ValueKey<String>('home_content'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  112,
                ),
                children: <Widget>[
                  const AvailableBalanceSummary(),
                  const SizedBox(height: AppSpacing.md),
                  _HomeActions(
                    onOpen: (String route) {
                      unawaited(_openTransactionForm(context, ref, route));
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const TransactionSavedBanner(),
                  const SizedBox(height: AppSpacing.xxl),
                  const MonthlyBudgetSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  const CategoryAttentionSection(),
                  const SizedBox(height: AppSpacing.xxl),
                  const RecentTransactionsSection(),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openTransactionForm(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) async {
    final FinancialTransaction? saved = await context
        .push<FinancialTransaction>(route);
    if (saved != null) {
      ref.read(lastSavedTransactionProvider.notifier).show(saved);
    }
  }
}

final class _HomeActions extends StatelessWidget {
  const _HomeActions({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool shouldStack =
            constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        final Widget addExpense = FilledButton.icon(
          key: const ValueKey<String>('home_add_expense_button'),
          onPressed: () => onOpen(AppRoutes.addExpense),
          icon: const Icon(Icons.add),
          label: const Text('Add expense'),
        );
        final Widget addIncome = OutlinedButton.icon(
          key: const ValueKey<String>('home_add_income_button'),
          onPressed: () => onOpen(AppRoutes.addIncome),
          icon: const Icon(Icons.arrow_downward),
          label: const Text('Add income'),
        );

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              addExpense,
              const SizedBox(height: AppSpacing.sm),
              addIncome,
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(child: addExpense),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: addIncome),
          ],
        );
      },
    );
  }
}

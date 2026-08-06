import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/features/home/presentation/widgets/available_balance_summary.dart';
import 'package:budgeting_app/features/home/presentation/widgets/home_header.dart';
import 'package:budgeting_app/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:budgeting_app/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:budgeting_app/features/home/presentation/widgets/recent_transactions_section.dart';
import 'package:budgeting_app/features/home/presentation/widgets/this_month_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _HomeLoadState { loading, loaded, error }

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
              _HomeLoadState.loaded,
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const HomeHeader(),
                Expanded(
                  child: switch (loadState) {
                    _HomeLoadState.loading => const HomeLoadingSkeleton(),
                    _HomeLoadState.error => AppErrorState(
                      message:
                          'Your financial summary is unavailable. Try again.',
                      onRetry: () => ref.invalidate(transactionListProvider),
                    ),
                    _HomeLoadState.loaded => ListView(
                      key: const ValueKey<String>('home_content'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.navigationClearance,
                      ),
                      children: <Widget>[
                        const AvailableBalanceSummary(),
                        const SizedBox(height: AppSpacing.md),
                        HomeQuickActions(
                          onAddExpense: () => unawaited(
                            _openTransactionForm(context, AppRoutes.addExpense),
                          ),
                          onAddIncome: () => unawaited(
                            _openTransactionForm(context, AppRoutes.addIncome),
                          ),
                        ),
                        const SizedBox(
                          key: ValueKey<String>(
                            'home_quick_actions_to_month_spacing',
                          ),
                          height: AppSpacing.section,
                        ),
                        const ThisMonthSummary(),
                        const SizedBox(height: AppSpacing.xxl),
                        const RecentTransactionsSection(),
                      ],
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTransactionForm(BuildContext context, String route) async {
    final FinancialTransaction? saved = await context
        .push<FinancialTransaction>(route);
    if (saved == null) {
      return;
    }
  }
}

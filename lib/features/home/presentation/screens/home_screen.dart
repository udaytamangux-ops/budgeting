import 'dart:async';

import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/calendar_period_navigator.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/home/presentation/widgets/available_balance_summary.dart';
import 'package:budgeting_app/features/home/presentation/widgets/home_header.dart';
import 'package:budgeting_app/features/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:budgeting_app/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:budgeting_app/features/home/presentation/widgets/recent_transactions_section.dart';
import 'package:budgeting_app/features/home/presentation/widgets/scheduled_transactions_due_surface.dart';
import 'package:budgeting_app/features/home/presentation/widgets/this_month_summary.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/sheets/new_transaction_sheet.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _HomeLoadState { loading, loaded, error }

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _HomeLoadState loadState = ref.watch(
      financialActivityListProvider.select(
        (AsyncValue<List<FinancialActivity>> value) => value.when(
          loading: () => _HomeLoadState.loading,
          error: (Object error, StackTrace stackTrace) => _HomeLoadState.error,
          data: (_) => _HomeLoadState.loaded,
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
                      onRetry: () {
                        ref.invalidate(transactionListProvider);
                        ref.invalidate(transferListProvider);
                      },
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
                        Consumer(
                          builder: (BuildContext context, WidgetRef ref, _) {
                            final CalendarPeriod selected = ref.watch(
                              effectiveSelectedCalendarPeriodProvider,
                            );
                            final CalendarPeriodBounds bounds =
                                ref
                                    .watch(calendarPeriodBoundsProvider)
                                    .valueOrNull ??
                                CalendarPeriodBounds(
                                  earliest: selected,
                                  current: selected,
                                  latest: selected,
                                );
                            final AppCalendarService service = ref.watch(
                              appCalendarServiceProvider,
                            );
                            return CalendarPeriodNavigator(
                              period: selected,
                              bounds: bounds,
                              calendarService: service,
                              onSelected: ref
                                  .read(selectedCalendarPeriodProvider.notifier)
                                  .select,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const AvailableBalanceSummary(),
                        const SizedBox(height: AppSpacing.md),
                        HomeQuickActions(
                          onAddExpense: () => unawaited(
                            _openTransactionForm(
                              context,
                              ref,
                              TransactionType.expense,
                            ),
                          ),
                          onAddIncome: () => unawaited(
                            _openTransactionForm(
                              context,
                              ref,
                              TransactionType.income,
                            ),
                          ),
                        ),
                        const ScheduledTransactionsDueSurface(),
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

  Future<void> _openTransactionForm(
    BuildContext context,
    WidgetRef ref,
    TransactionType type,
  ) async {
    final FinancialActivity? saved = await showNewTransactionSheet(
      context: context,
      ref: ref,
      requestedType: type,
    );
    if (saved == null) {
      return;
    }
  }
}

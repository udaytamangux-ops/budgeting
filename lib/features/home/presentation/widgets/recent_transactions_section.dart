import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CalendarPeriod period = ref.watch(
      effectiveSelectedCalendarPeriodProvider,
    );
    final List<FinancialTransaction> allTransactions =
        ref.watch(transactionListProvider).valueOrNull ??
        const <FinancialTransaction>[];
    final List<FinancialTransaction> transactions = allTransactions
        .where((transaction) => period.contains(transaction.occurredAt))
        .take(5)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Recent transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (transactions.isNotEmpty)
              TextButton(
                onPressed: () => context.go(AppRoutes.transactions),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (transactions.isEmpty)
          EmptyState(
            key: const ValueKey<String>('home_recent_transactions_empty_state'),
            title: allTransactions.isEmpty
                ? 'No recent transactions yet'
                : 'No transactions in ${period.displayLabel}',
            message: allTransactions.isEmpty
                ? 'Income and expenses you add will appear here.'
                : 'No recorded financial activity for this month.',
            icon: Icons.receipt_long_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              final FinancialTransaction transaction = transactions[index];
              return AnimatedSwitcher(
                duration: AppMotion.accessibleDuration(
                  context,
                  AppMotion.standard,
                ),
                child: TransactionListItem(
                  key: ValueKey<String>(transaction.id),
                  transaction: transaction,
                  onTap: () => context.push(
                    AppRoutes.transactionDetails(transaction.id),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

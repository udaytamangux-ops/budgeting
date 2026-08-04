import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
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
    final List<FinancialTransaction> transactions = ref.watch(
      transactionListProvider.select(
        (AsyncValue<List<FinancialTransaction>> value) =>
            value.valueOrNull?.take(5).toList(growable: false) ??
            const <FinancialTransaction>[],
      ),
    );

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
            TextButton(
              onPressed: () => context.go(AppRoutes.transactions),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
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
                onTap: () =>
                    context.push(AppRoutes.transactionDetails(transaction.id)),
              ),
            );
          },
        ),
      ],
    );
  }
}

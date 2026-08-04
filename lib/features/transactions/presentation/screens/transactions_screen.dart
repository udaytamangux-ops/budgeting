import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
      transactionListProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: transactions.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading transactions'),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                message: 'Transactions are unavailable. Try again.',
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              data: (List<FinancialTransaction> values) {
                if (values.isEmpty) {
                  return const EmptyState(
                    title: 'No transactions yet',
                    message:
                        'Add your first income or expense to start '
                        'understanding where your money goes.',
                    icon: Icons.receipt_long_outlined,
                  );
                }
                return ListView.separated(
                  key: const ValueKey<String>('transaction_list'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    112,
                  ),
                  itemCount: values.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    final FinancialTransaction transaction = values[index];
                    return TransactionListItem(
                      transaction: transaction,
                      onTap: () => context.push(
                        AppRoutes.transactionDetails(transaction.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

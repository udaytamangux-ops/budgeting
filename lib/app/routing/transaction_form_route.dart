import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionFormRoute extends ConsumerWidget {
  const TransactionFormRoute({
    required this.initialType,
    required this.intent,
    this.transactionId,
    this.recurringOccurrenceId,
    super.key,
  });

  final TransactionType initialType;
  final TransactionFormIntent intent;
  final String? transactionId;
  final String? recurringOccurrenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? occurrenceId = recurringOccurrenceId;
    if (occurrenceId != null) {
      final AsyncValue<RecurringTransactionOccurrence?> occurrence = ref.watch(
        recurringOccurrenceByIdProvider(occurrenceId),
      );
      return occurrence.when(
        loading: () => const Scaffold(
          body: AppLoadingIndicator(label: 'Loading scheduled transaction'),
        ),
        error: (_, _) => const Scaffold(
          body: AppErrorState(
            message: 'The scheduled transaction could not be loaded.',
          ),
        ),
        data: (RecurringTransactionOccurrence? value) {
          if (value == null) {
            return const Scaffold(
              body: AppErrorState(
                title: 'Scheduled occurrence not found',
                message: 'This scheduled occurrence is no longer waiting.',
              ),
            );
          }
          return ProviderScope(
            overrides: <Override>[
              initialRecurringOccurrenceProvider.overrideWithValue(value),
              initialTransactionTypeProvider.overrideWithValue(value.type),
              transactionFormIntentProvider.overrideWithValue(intent),
            ],
            child: const AddTransactionScreen(),
          );
        },
      );
    }
    final String? id = transactionId;
    if (id == null) {
      return ProviderScope(
        overrides: <Override>[
          initialTransactionTypeProvider.overrideWithValue(initialType),
          transactionFormIntentProvider.overrideWithValue(intent),
        ],
        child: const AddTransactionScreen(),
      );
    }

    final AsyncValue<FinancialTransaction?> transaction = ref.watch(
      transactionByIdProvider(id),
    );
    return transaction.when(
      loading: () => const Scaffold(
        body: AppLoadingIndicator(label: 'Loading transaction form'),
      ),
      error: (Object error, StackTrace stackTrace) => Scaffold(
        appBar: AppBar(
          title: Text(
            intent == TransactionFormIntent.repeat
                ? 'Repeat transaction'
                : 'Edit transaction',
          ),
        ),
        body: const AppErrorState(
          message: 'The transaction could not be loaded for editing.',
        ),
      ),
      data: (FinancialTransaction? value) {
        if (value == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                intent == TransactionFormIntent.repeat
                    ? 'Repeat transaction'
                    : 'Edit transaction',
              ),
            ),
            body: const AppErrorState(
              title: 'Transaction not found',
              message: 'This transaction is no longer available to edit.',
            ),
          );
        }
        return ProviderScope(
          overrides: <Override>[
            initialTransactionProvider.overrideWithValue(value),
            initialTransactionTypeProvider.overrideWithValue(value.type),
            transactionFormIntentProvider.overrideWithValue(intent),
          ],
          child: const AddTransactionScreen(),
        );
      },
    );
  }
}

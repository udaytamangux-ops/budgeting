import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_rule_form_controller.dart';
import 'package:budgeting_app/features/recurring/presentation/screens/recurring_rule_form_screen.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class RecurringRuleFormRoute extends ConsumerWidget {
  const RecurringRuleFormRoute({
    this.ruleId,
    this.sourceTransactionId,
    super.key,
  });

  final String? ruleId;
  final String? sourceTransactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ruleId != null) {
      return ref
          .watch(recurringRuleByIdProvider(ruleId!))
          .when(
            loading: _loading,
            error: (_, _) =>
                _error('The recurring schedule could not be loaded.'),
            data: (RecurringTransactionRule? rule) => rule == null
                ? _error('This recurring schedule is no longer available.')
                : ProviderScope(
                    overrides: <Override>[
                      initialRecurringRuleProvider.overrideWithValue(rule),
                    ],
                    child: const RecurringRuleFormScreen(),
                  ),
          );
    }
    if (sourceTransactionId != null) {
      return ref
          .watch(transactionByIdProvider(sourceTransactionId!))
          .when(
            loading: _loading,
            error: (_, _) => _error('The transaction could not be loaded.'),
            data: (FinancialTransaction? transaction) => transaction == null
                ? _error('This transaction is no longer available.')
                : ProviderScope(
                    overrides: <Override>[
                      recurringSourceTransactionProvider.overrideWithValue(
                        transaction,
                      ),
                    ],
                    child: const RecurringRuleFormScreen(),
                  ),
          );
    }
    return const RecurringRuleFormScreen();
  }

  Widget _loading() => const Scaffold(
    body: AppLoadingIndicator(label: 'Loading recurring schedule'),
  );

  Widget _error(String message) => Scaffold(
    appBar: AppBar(title: const Text('Recurring transaction')),
    body: AppErrorState(message: message),
  );
}

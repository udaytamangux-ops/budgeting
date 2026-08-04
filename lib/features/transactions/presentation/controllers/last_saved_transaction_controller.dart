import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<LastSavedTransactionController, FinancialTransaction?>
lastSavedTransactionProvider =
    NotifierProvider<LastSavedTransactionController, FinancialTransaction?>(
      LastSavedTransactionController.new,
    );

final class LastSavedTransactionController
    extends Notifier<FinancialTransaction?> {
  @override
  FinancialTransaction? build() => null;

  void show(FinancialTransaction transaction) {
    state = transaction;
  }

  void dismiss() {
    state = null;
  }
}

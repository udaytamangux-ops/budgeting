import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';

abstract interface class RecurringTransactionRepository {
  Stream<List<RecurringTransactionRule>> watchRules();

  Stream<List<RecurringTransactionOccurrence>> watchPendingOccurrences();

  Future<RecurringTransactionRule?> getRuleById(String ruleId);

  Future<RecurringTransactionOccurrence?> getOccurrenceById(
    String occurrenceId,
  );

  Future<void> createRule(RecurringTransactionRule rule);

  Future<void> updateRule(RecurringTransactionRule rule);

  Future<void> reconcileThrough({
    required DateTime today,
    required DateTime handledAt,
  });

  Future<void> recordOccurrence({
    required String occurrenceId,
    required FinancialTransaction transaction,
  });

  Future<void> skipOccurrence(String occurrenceId, {required DateTime now});

  Future<void> pauseRule(String ruleId, {required DateTime now});

  Future<void> resumeRule(
    String ruleId, {
    required DateTime resumeDate,
    required DateTime now,
  });

  Future<void> deleteRule(String ruleId, {required DateTime now});
}

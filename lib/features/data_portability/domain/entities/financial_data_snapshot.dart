import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';

final class FinancialDataSnapshot {
  const FinancialDataSnapshot({
    required this.transactions,
    required this.recurringRules,
    required this.recurringOccurrences,
  });

  final List<FinancialTransaction> transactions;
  final List<RecurringTransactionRule> recurringRules;
  final List<RecurringTransactionOccurrence> recurringOccurrences;
}

final class PortableBackup {
  const PortableBackup({
    required this.createdAtUtc,
    required this.sourceDatabaseSchemaVersion,
    required this.snapshot,
  });

  final DateTime createdAtUtc;
  final int sourceDatabaseSchemaVersion;
  final FinancialDataSnapshot snapshot;
}

final class BackupPreview {
  const BackupPreview({
    required this.backup,
    required this.fileName,
    required this.currentSnapshot,
  });

  final PortableBackup backup;
  final String fileName;
  final FinancialDataSnapshot currentSnapshot;

  DateTime get createdAtUtc => backup.createdAtUtc;
  int get transactionCount => backup.snapshot.transactions.length;
  int get recurringRuleCount => backup.snapshot.recurringRules.length;
  int get recurringOccurrenceCount =>
      backup.snapshot.recurringOccurrences.length;

  int get currentTransactionCount => currentSnapshot.transactions.length;
  int get currentRecurringRuleCount => currentSnapshot.recurringRules.length;
  int get currentRecurringOccurrenceCount =>
      currentSnapshot.recurringOccurrences.length;

  bool get currentMayContainAdditionalActivity =>
      currentTransactionCount > transactionCount ||
      currentRecurringRuleCount > recurringRuleCount ||
      currentRecurringOccurrenceCount > recurringOccurrenceCount;
}

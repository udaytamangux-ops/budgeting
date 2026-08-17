import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';

final class FinancialDataSnapshot {
  const FinancialDataSnapshot({
    required this.transactions,
    required this.recurringRules,
    required this.recurringOccurrences,
    this.customCategories = const <CustomCategory>[],
    this.transfers = const <FinancialTransfer>[],
    this.moneyPlanPreference,
    this.moneyPlanPeriods = const <MoneyPlanPeriod>[],
    this.moneyPlanCategoryMappings = const <MoneyPlanCategoryMapping>[],
  });

  final List<FinancialTransaction> transactions;
  final List<RecurringTransactionRule> recurringRules;
  final List<RecurringTransactionOccurrence> recurringOccurrences;
  final List<FinancialTransfer> transfers;
  final List<CustomCategory> customCategories;
  final MoneyPlanPreference? moneyPlanPreference;
  final List<MoneyPlanPeriod> moneyPlanPeriods;
  final List<MoneyPlanCategoryMapping> moneyPlanCategoryMappings;
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
  int get transferCount => backup.snapshot.transfers.length;

  int get currentTransactionCount => currentSnapshot.transactions.length;
  int get currentRecurringRuleCount => currentSnapshot.recurringRules.length;
  int get currentRecurringOccurrenceCount =>
      currentSnapshot.recurringOccurrences.length;
  int get currentTransferCount => currentSnapshot.transfers.length;

  bool get currentMayContainAdditionalActivity =>
      currentTransactionCount > transactionCount ||
      currentRecurringRuleCount > recurringRuleCount ||
      currentRecurringOccurrenceCount > recurringOccurrenceCount ||
      currentTransferCount > transferCount;
}

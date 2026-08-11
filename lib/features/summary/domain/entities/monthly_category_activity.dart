import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CategoryActivityRecord {
  const CategoryActivityRecord({
    required this.category,
    required this.amount,
    required this.sharePercentage,
    required this.transactionCount,
  });

  final TransactionCategory category;
  final Money amount;
  final int sharePercentage;
  final int transactionCount;
}

final class CategoryActivityGroup {
  const CategoryActivityGroup({
    required this.category,
    required this.includedCategories,
    required this.amount,
    required this.sharePercentage,
    required this.transactionCount,
  });

  final TransactionCategory? category;
  final List<TransactionCategory> includedCategories;
  final Money amount;
  final int sharePercentage;
  final int transactionCount;

  bool get isOther => category == null;

  String get selectionKey {
    if (category case final TransactionCategory value) {
      return value.name;
    }
    return 'other-${includedCategories.map((value) => value.name).join('-')}';
  }
}

final class MonthlyCategoryActivity {
  const MonthlyCategoryActivity({
    required this.month,
    required this.type,
    required this.total,
    required this.transactionCount,
    required this.records,
    required this.groups,
  });

  final DateTime month;
  final TransactionType type;
  final Money total;
  final int transactionCount;
  final List<CategoryActivityRecord> records;
  final List<CategoryActivityGroup> groups;
}

final class CategoryActivityDetails {
  const CategoryActivityDetails({
    required this.month,
    required this.type,
    required this.includedCategories,
    required this.total,
    required this.relevantMonthlyTotal,
    required this.sharePercentage,
    required this.items,
    required this.averageTransaction,
  });

  final DateTime month;
  final TransactionType type;
  final List<TransactionCategory> includedCategories;
  final Money total;
  final Money relevantMonthlyTotal;
  final int sharePercentage;
  final List<CategoryActivityItem> items;
  final Money? averageTransaction;

  int get transactionCount => items.length;

  List<FinancialTransaction> get transactions =>
      List<FinancialTransaction>.unmodifiable(
        items
            .where((item) => item.activity is TransactionActivity)
            .map((item) => (item.activity as TransactionActivity).transaction),
      );
}

final class CategoryActivityItem {
  const CategoryActivityItem({
    required this.activity,
    required this.contribution,
  });

  final FinancialActivity activity;
  final Money contribution;
}

import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CategorySpendingRecord {
  const CategorySpendingRecord({
    required this.category,
    required this.amount,
    required this.sharePercentage,
  });

  final TransactionCategory category;
  final Money amount;
  final int sharePercentage;
}

final class PaymentMethodUsageRecord {
  const PaymentMethodUsageRecord({
    required this.paymentMethod,
    required this.transactionCount,
    required this.sharePercentage,
  });

  final PaymentMethod paymentMethod;
  final int transactionCount;
  final int sharePercentage;
}

final class CategorySpendingGroup {
  const CategorySpendingGroup({
    required this.category,
    required this.includedCategories,
    required this.amount,
    required this.sharePercentage,
  });

  final TransactionCategory? category;
  final List<TransactionCategory> includedCategories;
  final Money amount;
  final int sharePercentage;

  bool get isOther => category == null;
}

final class MonthlyTransactionSummary {
  const MonthlyTransactionSummary({
    required this.financialSummary,
    required this.transactionCount,
    required this.categorySpending,
    required this.spendingGroups,
    required this.paymentMethods,
  });

  final MonthlyFinancialSummary financialSummary;
  final int transactionCount;
  final List<CategorySpendingRecord> categorySpending;
  final List<CategorySpendingGroup> spendingGroups;
  final List<PaymentMethodUsageRecord> paymentMethods;

  DateTime get month => financialSummary.month;
  Money get income => financialSummary.income;
  Money get expenses => financialSummary.expenses;
  Money get netChange => financialSummary.availableBalance;
  int get spendingCategoryCount => categorySpending.length;
}

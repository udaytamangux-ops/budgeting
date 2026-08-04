import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/budgets/domain/services/budget_policy.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class BudgetSummaryService {
  const BudgetSummaryService();

  MonthlyBudgetSummary calculateForMonth({
    required List<FinancialTransaction> transactions,
    required DateTime month,
    Money monthlyLimit = BudgetPolicy.monthlyLimit,
    Map<TransactionCategory, Money> categoryLimits =
        BudgetPolicy.categoryLimits,
  }) {
    Money spent = const Money.zero();
    final Map<TransactionCategory, Money> categorySpending =
        <TransactionCategory, Money>{};

    for (final FinancialTransaction transaction in transactions) {
      if (transaction.type != TransactionType.expense ||
          !_isInLocalMonth(transaction.occurredAt, month)) {
        continue;
      }
      spent += transaction.amount;
      categorySpending.update(
        transaction.category,
        (Money existing) => existing + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final List<CategoryBudgetProgress> categories = categoryLimits.entries
        .map(
          (MapEntry<TransactionCategory, Money> entry) =>
              CategoryBudgetProgress(
                category: entry.key,
                limit: entry.value,
                spent: categorySpending[entry.key] ?? const Money.zero(),
              ),
        )
        .toList(growable: false);

    return MonthlyBudgetSummary(
      month: DateTime(month.year, month.month),
      limit: monthlyLimit,
      spent: spent,
      categories: List<CategoryBudgetProgress>.unmodifiable(categories),
    );
  }

  bool _isInLocalMonth(DateTime timestamp, DateTime month) {
    final DateTime localTimestamp = timestamp.toLocal();
    return localTimestamp.year == month.year &&
        localTimestamp.month == month.month;
  }
}

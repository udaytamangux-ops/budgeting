import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CategoryBudgetProgress {
  const CategoryBudgetProgress({
    required this.category,
    required this.limit,
    required this.spent,
  });

  final TransactionCategory category;
  final Money limit;
  final Money spent;

  Money get remaining => limit - spent;

  double get usedFraction {
    if (limit.isZero) {
      return 0;
    }
    return spent.minorUnits / limit.minorUnits;
  }

  bool get isNearLimit => usedFraction >= 0.75;
  bool get isExceeded => spent > limit;
}

final class MonthlyBudgetSummary {
  const MonthlyBudgetSummary({
    required this.month,
    required this.limit,
    required this.spent,
    required this.categories,
  });

  final DateTime month;
  final Money limit;
  final Money spent;
  final List<CategoryBudgetProgress> categories;

  bool get hasBudget => limit.isPositive;
  Money get remaining => limit - spent;

  CategoryBudgetProgress? progressFor(TransactionCategory category) {
    for (final CategoryBudgetProgress progress in categories) {
      if (progress.category == category) {
        return progress;
      }
    }
    return null;
  }

  double get usedFraction {
    if (!hasBudget) {
      return 0;
    }
    return spent.minorUnits / limit.minorUnits;
  }
}

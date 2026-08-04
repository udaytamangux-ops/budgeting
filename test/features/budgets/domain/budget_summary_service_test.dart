import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/budgets/domain/services/budget_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const BudgetSummaryService service = BudgetSummaryService();

  test('calculates monthly and Food budget progress precisely', () {
    final MonthlyBudgetSummary summary = service.calculateForMonth(
      transactions: <FinancialTransaction>[
        buildTestTransaction(id: 'food', minorUnits: 550000),
        buildTestTransaction(
          id: 'rent',
          minorUnits: 1200000,
          category: TransactionCategory.rentAndHousing,
        ),
        buildTestTransaction(
          id: 'other-expenses',
          minorUnits: 525000,
          category: TransactionCategory.utilities,
        ),
      ],
      month: DateTime(2026, 8),
    );

    final CategoryBudgetProgress food = summary.progressFor(
      TransactionCategory.food,
    )!;
    expect(summary.spent.minorUnits, 2275000);
    expect(summary.remaining.minorUnits, 1725000);
    expect(summary.usedFraction, closeTo(0.56875, 0.000001));
    expect(food.spent.minorUnits, 550000);
    expect(food.remaining.minorUnits, 250000);
    expect(summary.allocatedBudget.minorUnits, 3350000);
    expect(summary.unallocatedBudget.minorUnits, 650000);
    expect(food.isNearLimit, isFalse);
    expect(
      summary.progressFor(TransactionCategory.utilities)!.isNearLimit,
      isTrue,
    );
    expect(
      summary.progressFor(TransactionCategory.rentAndHousing)!.isExceeded,
      isTrue,
    );
  });

  test('recalculates specified post-expense values', () {
    final MonthlyBudgetSummary summary = service.calculateForMonth(
      transactions: <FinancialTransaction>[
        buildTestTransaction(id: 'existing-food', minorUnits: 550000),
        buildTestTransaction(id: 'new-food', minorUnits: 125000),
        buildTestTransaction(
          id: 'other-expenses',
          minorUnits: 1725000,
          category: TransactionCategory.utilities,
        ),
      ],
      month: DateTime(2026, 8),
    );

    final CategoryBudgetProgress food = summary.progressFor(
      TransactionCategory.food,
    )!;
    expect(summary.spent.minorUnits, 2400000);
    expect(summary.remaining.minorUnits, 1600000);
    expect(summary.usedFraction, 0.6);
    expect(food.spent.minorUnits, 675000);
    expect(food.remaining.minorUnits, 125000);
  });
}

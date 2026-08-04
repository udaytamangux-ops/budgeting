import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/domain/services/transaction_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const TransactionSummaryService service = TransactionSummaryService();

  test('aggregates neutral monthly transaction records', () {
    final MonthlyTransactionSummary summary = service.calculateForMonth(
      transactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'salary',
          type: TransactionType.income,
          minorUnits: 6000000,
          category: TransactionCategory.salary,
          paymentMethod: PaymentMethod.bankAccount,
        ),
        buildTestTransaction(
          id: 'food',
          minorUnits: 550000,
          category: TransactionCategory.food,
          paymentMethod: PaymentMethod.eSewa,
        ),
        buildTestTransaction(
          id: 'rent',
          minorUnits: 1200000,
          category: TransactionCategory.rentAndHousing,
          paymentMethod: PaymentMethod.bankAccount,
        ),
        buildTestTransaction(
          id: 'previous-month',
          minorUnits: 900000,
          occurredAt: DateTime.utc(2026, 7, 4, 6, 15),
        ),
      ],
      month: DateTime(2026, 8),
    );

    expect(summary.income.minorUnits, 6000000);
    expect(summary.expenses.minorUnits, 1750000);
    expect(summary.netChange.minorUnits, 4250000);
    expect(summary.transactionCount, 3);
    expect(summary.spendingCategoryCount, 2);
    expect(
      summary.categorySpending.map(
        (CategorySpendingRecord record) => record.category,
      ),
      <TransactionCategory>[
        TransactionCategory.rentAndHousing,
        TransactionCategory.food,
      ],
    );
    expect(summary.categorySpending.first.sharePercentage, 69);
    expect(
      summary.paymentMethods.first.paymentMethod,
      PaymentMethod.bankAccount,
    );
    expect(summary.paymentMethods.first.transactionCount, 2);
    expect(summary.paymentMethods.first.sharePercentage, 67);
  });

  test('groups chart data into four major categories plus Other', () {
    final MonthlyTransactionSummary summary = service.calculateForMonth(
      transactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'rent',
          minorUnits: 600000,
          category: TransactionCategory.rentAndHousing,
        ),
        buildTestTransaction(
          id: 'food',
          minorUnits: 500000,
          category: TransactionCategory.food,
        ),
        buildTestTransaction(
          id: 'transport',
          minorUnits: 400000,
          category: TransactionCategory.transport,
        ),
        buildTestTransaction(
          id: 'utilities',
          minorUnits: 300000,
          category: TransactionCategory.utilities,
        ),
        buildTestTransaction(
          id: 'shopping',
          minorUnits: 200000,
          category: TransactionCategory.shopping,
        ),
        buildTestTransaction(
          id: 'health',
          minorUnits: 100000,
          category: TransactionCategory.health,
        ),
      ],
      month: DateTime(2026, 8),
    );

    expect(summary.expenses.minorUnits, 2100000);
    expect(summary.spendingGroups, hasLength(5));
    expect(
      summary.spendingGroups
          .take(4)
          .map((CategorySpendingGroup group) => group.category),
      <TransactionCategory>[
        TransactionCategory.rentAndHousing,
        TransactionCategory.food,
        TransactionCategory.transport,
        TransactionCategory.utilities,
      ],
    );
    expect(summary.spendingGroups.last.isOther, isTrue);
    expect(summary.spendingGroups.last.amount.minorUnits, 300000);
    expect(
      summary.spendingGroups.last.includedCategories,
      <TransactionCategory>[
        TransactionCategory.shopping,
        TransactionCategory.health,
      ],
    );
    expect(
      summary.spendingGroups.fold<int>(
        0,
        (int total, CategorySpendingGroup group) =>
            total + group.sharePercentage,
      ),
      100,
    );
    expect(
      summary.categorySpending.fold<int>(
        0,
        (int total, CategorySpendingRecord record) =>
            total + record.sharePercentage,
      ),
      100,
    );
  });
}

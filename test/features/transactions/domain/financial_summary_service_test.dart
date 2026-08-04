import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const FinancialSummaryService service = FinancialSummaryService();

  test('calculates monthly income, expenses, and available balance', () {
    final MonthlyFinancialSummary summary = service.calculateForMonth(
      transactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'salary',
          type: TransactionType.income,
          minorUnits: 6000000,
          category: TransactionCategory.salary,
        ),
        buildTestTransaction(id: 'expense-one', minorUnits: 2275000),
        buildTestTransaction(
          id: 'previous-month',
          minorUnits: 900000,
          occurredAt: DateTime.utc(2026, 7, 4, 6, 15),
        ),
      ],
      month: DateTime(2026, 8),
    );

    expect(summary.income.minorUnits, 6000000);
    expect(summary.expenses.minorUnits, 2275000);
    expect(summary.availableBalance.minorUnits, 3725000);
  });

  test('sorts transactions by occurrence then creation date descending', () {
    final first = buildTestTransaction(
      id: 'first',
      occurredAt: DateTime.utc(2026, 8, 4, 6),
      createdAt: DateTime.utc(2026, 8, 4, 6),
    );
    final second = buildTestTransaction(
      id: 'second',
      occurredAt: DateTime.utc(2026, 8, 4, 6),
      createdAt: DateTime.utc(2026, 8, 4, 7),
    );
    final older = buildTestTransaction(
      id: 'older',
      occurredAt: DateTime.utc(2026, 8, 3, 6),
      createdAt: DateTime.utc(2026, 8, 4, 8),
    );

    final List<FinancialTransaction> sorted = service.sortNewestFirst(
      <FinancialTransaction>[older, first, second],
    );

    expect(sorted.map((transaction) => transaction.id), <String>[
      'second',
      'first',
      'older',
    ]);
  });
}

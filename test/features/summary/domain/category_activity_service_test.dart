import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/domain/services/category_activity_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const CategoryActivityService service = CategoryActivityService();

  test('calculates expense totals, count, percentage, and integer average', () {
    final List<FinancialTransaction> transactions = <FinancialTransaction>[
      buildTestTransaction(
        id: 'food-one',
        minorUnits: 300000,
        category: TransactionCategory.food,
      ),
      buildTestTransaction(
        id: 'food-two',
        minorUnits: 300000,
        category: TransactionCategory.food,
      ),
      buildTestTransaction(
        id: 'food-three',
        minorUnits: 245000,
        category: TransactionCategory.food,
      ),
      buildTestTransaction(
        id: 'transport',
        minorUnits: 155000,
        category: TransactionCategory.transport,
      ),
    ];

    final CategoryActivityDetails details = service.calculateForCategories(
      transactions: transactions,
      month: DateTime(2026, 8),
      type: TransactionType.expense,
      categories: <TransactionCategory>[TransactionCategory.food],
    );

    expect(details.total.minorUnits, 845000);
    expect(details.relevantMonthlyTotal.minorUnits, 1000000);
    expect(details.sharePercentage, 85);
    expect(details.transactionCount, 3);
    expect(details.averageTransaction?.minorUnits, 281667);
    expect(details.averageTransaction?.minorUnits, isA<int>());
  });

  test(
    'keeps month, year, category, and transaction type filters separate',
    () {
      final FinancialTransaction expected = buildTestTransaction(
        id: 'august-food-expense',
        category: TransactionCategory.food,
        occurredAt: DateTime.utc(2026, 8, 4, 6, 15),
      );
      final List<FinancialTransaction> transactions = <FinancialTransaction>[
        expected,
        buildTestTransaction(
          id: 'july-food-expense',
          category: TransactionCategory.food,
          occurredAt: DateTime.utc(2026, 7, 4, 6, 15),
        ),
        buildTestTransaction(
          id: 'august-2025-food-expense',
          category: TransactionCategory.food,
          occurredAt: DateTime.utc(2025, 8, 4, 6, 15),
        ),
        buildTestTransaction(
          id: 'august-transport-expense',
          category: TransactionCategory.transport,
        ),
        buildTestTransaction(
          id: 'august-income',
          type: TransactionType.income,
          category: TransactionCategory.salary,
        ),
      ];

      final CategoryActivityDetails details = service.calculateForCategories(
        transactions: transactions,
        month: DateTime(2026, 8),
        type: TransactionType.expense,
        categories: <TransactionCategory>[TransactionCategory.food],
      );

      expect(details.transactions, <FinancialTransaction>[expected]);
    },
  );

  test('supports one-transaction income sources against monthly income', () {
    final CategoryActivityDetails details = service.calculateForCategories(
      transactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'salary',
          type: TransactionType.income,
          minorUnits: 4500000,
          category: TransactionCategory.salary,
        ),
        buildTestTransaction(
          id: 'freelance',
          type: TransactionType.income,
          minorUnits: 1500000,
          category: TransactionCategory.freelance,
        ),
      ],
      month: DateTime(2026, 8),
      type: TransactionType.income,
      categories: <TransactionCategory>[TransactionCategory.salary],
    );

    expect(details.total.minorUnits, 4500000);
    expect(details.relevantMonthlyTotal.minorUnits, 6000000);
    expect(details.sharePercentage, 75);
    expect(details.transactionCount, 1);
    expect(details.averageTransaction, details.total);
  });

  test('zero-total month returns finite zero values and no average', () {
    final MonthlyCategoryActivity activity = service.calculateForMonth(
      transactions: const <FinancialTransaction>[],
      month: DateTime(2026, 8),
      type: TransactionType.expense,
    );
    final CategoryActivityDetails details = service.calculateForCategories(
      transactions: const <FinancialTransaction>[],
      month: DateTime(2026, 8),
      type: TransactionType.expense,
      categories: <TransactionCategory>[TransactionCategory.food],
    );

    expect(activity.total.minorUnits, 0);
    expect(activity.groups, isEmpty);
    expect(details.total.minorUnits, 0);
    expect(details.relevantMonthlyTotal.minorUnits, 0);
    expect(details.sharePercentage, 0);
    expect(details.transactionCount, 0);
    expect(details.averageTransaction, isNull);
  });

  test(
    'group percentages remain exactly one hundred after Other aggregation',
    () {
      final MonthlyCategoryActivity activity = service.calculateForMonth(
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
        ],
        month: DateTime(2026, 8),
        type: TransactionType.expense,
      );

      expect(activity.groups, hasLength(5));
      expect(activity.groups.last.isOther, isTrue);
      expect(
        activity.groups.fold<int>(
          0,
          (int total, CategoryActivityGroup group) =>
              total + group.sharePercentage,
        ),
        100,
      );
    },
  );
}

import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/services/recent_transaction_categories_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const RecentTransactionCategoriesService service =
      RecentTransactionCategoriesService();

  test('returns no recent categories when relevant history is empty', () {
    expect(
      service.findForType(
        transactions: const <FinancialTransaction>[],
        type: TransactionType.expense,
      ),
      isEmpty,
    );
  });

  test(
    'uses recency order, removes duplicates, and limits results to three',
    () {
      final List<FinancialTransaction> transactions = <FinancialTransaction>[
        buildTestTransaction(
          id: 'food-newest',
          category: TransactionCategory.food,
          createdAt: fixedNow.add(const Duration(minutes: 6)),
        ),
        buildTestTransaction(
          id: 'transport',
          category: TransactionCategory.transport,
          createdAt: fixedNow.add(const Duration(minutes: 5)),
        ),
        buildTestTransaction(
          id: 'food-duplicate',
          category: TransactionCategory.food,
          createdAt: fixedNow.add(const Duration(minutes: 4)),
        ),
        buildTestTransaction(
          id: 'utilities',
          category: TransactionCategory.utilities,
          createdAt: fixedNow.add(const Duration(minutes: 3)),
        ),
        buildTestTransaction(
          id: 'health',
          category: TransactionCategory.health,
          createdAt: fixedNow.add(const Duration(minutes: 2)),
        ),
      ];

      expect(
        service.findForType(
          transactions: transactions,
          type: TransactionType.expense,
        ),
        <TransactionCategory>[
          TransactionCategory.food,
          TransactionCategory.transport,
          TransactionCategory.utilities,
        ],
      );
    },
  );

  test('keeps expense and income recency histories separate', () {
    final List<FinancialTransaction> transactions = <FinancialTransaction>[
      buildTestTransaction(
        id: 'salary',
        type: TransactionType.income,
        category: TransactionCategory.salary,
        createdAt: fixedNow.add(const Duration(minutes: 4)),
      ),
      buildTestTransaction(
        id: 'food',
        category: TransactionCategory.food,
        createdAt: fixedNow.add(const Duration(minutes: 3)),
      ),
      buildTestTransaction(
        id: 'freelance',
        type: TransactionType.income,
        category: TransactionCategory.freelance,
        createdAt: fixedNow.add(const Duration(minutes: 2)),
      ),
    ];

    expect(
      service.findForType(
        transactions: transactions,
        type: TransactionType.expense,
      ),
      <TransactionCategory>[TransactionCategory.food],
    );
    expect(
      service.findForType(
        transactions: transactions,
        type: TransactionType.income,
      ),
      <TransactionCategory>[
        TransactionCategory.salary,
        TransactionCategory.freelance,
      ],
    );
  });
}

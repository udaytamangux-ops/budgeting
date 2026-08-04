import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_list_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const TransactionListFilter filter = TransactionListFilter();

  test('searches, filters, groups, and orders matching transactions', () {
    final FinancialTransaction olderFood = buildTestTransaction(
      id: 'older-food',
      merchant: 'Bhat-Bhateni',
      occurredAt: DateTime.utc(2026, 8, 3, 6),
    );
    final FinancialTransaction newestFood = buildTestTransaction(
      id: 'newest-food',
      merchant: 'Kathmandu Lunch Club',
      occurredAt: DateTime.utc(2026, 8, 4, 6),
    );
    final FinancialTransaction income = buildTestTransaction(
      id: 'salary',
      type: TransactionType.income,
      category: TransactionCategory.salary,
      merchant: 'Studio payroll',
      occurredAt: DateTime.utc(2026, 8, 4, 5),
    );

    final List<TransactionDateGroup> groups = filter.apply(
      transactions: <FinancialTransaction>[olderFood, income, newestFood],
      month: DateTime(2026, 8),
      query: 'food',
      type: TransactionType.expense,
    );

    expect(groups, hasLength(2));
    expect(groups.first.date.day, 4);
    expect(groups.first.transactions.single.id, 'newest-food');
    expect(groups.last.transactions.single.id, 'older-food');
  });
}

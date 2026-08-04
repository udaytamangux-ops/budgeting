import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  test('create publishes a newest-first immutable snapshot', () async {
    final InMemoryTransactionRepository repository =
        InMemoryTransactionRepository(
          seedTransactions: <FinancialTransaction>[
            buildTestTransaction(id: 'older'),
          ],
          operationDelay: Duration.zero,
          now: () => fixedNow,
        );
    addTearDown(repository.dispose);
    final Future<List<FinancialTransaction>> updated = repository
        .watchTransactions()
        .firstWhere((List<FinancialTransaction> values) => values.length == 2);

    await repository.createTransaction(
      buildTestTransaction(
        id: 'newer',
        createdAt: fixedNow.add(const Duration(minutes: 1)),
      ),
    );

    final List<FinancialTransaction> values = await updated;
    expect(values.first.id, 'newer');
  });

  test('controlled create failure is recoverable on retry', () async {
    final InMemoryTransactionRepository repository =
        InMemoryTransactionRepository(
          seedTransactions: <FinancialTransaction>[],
          operationDelay: Duration.zero,
          now: () => fixedNow,
        );
    addTearDown(repository.dispose);
    repository.simulateNextCreateFailure();
    final FinancialTransaction transaction = buildTestTransaction();

    await expectLater(
      repository.createTransaction(transaction),
      throwsA(isA<TransactionRepositoryException>()),
    );
    await repository.createTransaction(transaction);

    expect(await repository.getTransactionById(transaction.id), isNotNull);
  });
}

import 'package:budgeting_app/app/bootstrap/app_bootstrap.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/data/sources/mock_transaction_source.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_data.dart';

void main() {
  test(
    'an in-memory repository starts empty unless fixtures are injected',
    () async {
      final InMemoryTransactionRepository repository =
          InMemoryTransactionRepository(
            operationDelay: Duration.zero,
            now: () => fixedNow,
          );
      addTearDown(repository.dispose);

      expect(await repository.watchTransactions().first, isEmpty);
    },
  );

  test('mock transaction fixtures remain available for explicit tests', () {
    final List<FinancialTransaction> fixtures =
        MockTransactionSource.buildSeedData(fixedNow);

    expect(fixtures, isNotEmpty);
    expect(
      fixtures.any((FinancialTransaction value) => value.id == 'seed-salary'),
      isTrue,
    );
    expect(
      fixtures.any(
        (FinancialTransaction value) => value.id == 'seed-food-lunch',
      ),
      isTrue,
    );
  });

  test('normal app bootstrap creates a fresh empty session', () async {
    final ProviderContainer first = await AppBootstrap.createContainer();
    final ProviderContainer second = await AppBootstrap.createContainer();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    expect(await first.read(transactionListProvider.future), isEmpty);
    expect(await second.read(transactionListProvider.future), isEmpty);
  });
}

import 'package:budgeting_app/app/bootstrap/app_bootstrap.dart';
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/data/sources/mock_transaction_source.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:drift/native.dart';
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

  test(
    'normal bootstrap uses one empty Drift database without seeding',
    () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      final ProviderContainer container = await AppBootstrap.createContainer(
        database: database,
      );
      addTearDown(container.dispose);
      addTearDown(database.close);

      expect(container.read(appDatabaseProvider), same(database));
      expect(
        container.read(transactionRepositoryProvider),
        isA<DriftTransactionRepository>(),
      );
      expect(
        container.read(transactionRepositoryProvider),
        same(container.read(transactionRepositoryProvider)),
      );
      expect(await container.read(transactionListProvider.future), isEmpty);
    },
  );
}

import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/presentation/controllers/summary_providers.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  test(
    'Summary providers derive facts only from the active guest owner',
    () async {
      final AppDatabase database = AppDatabase(NativeDatabase.memory());
      final DriftTransactionRepository guestRepository =
          DriftTransactionRepository(database);
      final DriftTransactionRepository futureUserRepository =
          DriftTransactionRepository(database, ownerScope: 'user:future-id');
      await guestRepository.createTransaction(
        buildTestTransaction(id: 'guest-expense', minorUnits: 125000),
      );
      await futureUserRepository.createTransaction(
        buildTestTransaction(
          id: 'future-user-income',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          minorUnits: 9000000,
        ),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);

      await container.read(transactionListProvider.future);
      final MonthlyTransactionSummary summary = container
          .read(monthlyTransactionSummaryForMonthProvider(fixedNow))
          .requireValue;

      expect(summary.transactionCount, 1);
      expect(summary.expenses.minorUnits, 125000);
      expect(summary.income.minorUnits, 0);
    },
  );
}

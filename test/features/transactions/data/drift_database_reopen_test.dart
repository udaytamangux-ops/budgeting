import 'dart:io';

import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  test(
    'transactions, edits, and deletions persist across file reopening',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'budgeting-drift-reopen-',
      );
      final File databaseFile = File(
        '${directory.path}${Platform.pathSeparator}transactions.sqlite',
      );
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });

      final AppDatabase databaseA = AppDatabase(NativeDatabase(databaseFile));
      final DriftTransactionRepository repositoryA = DriftTransactionRepository(
        databaseA,
      );
      final FinancialTransaction income = buildTestTransaction(
        id: 'persistent-income',
        type: TransactionType.income,
        category: TransactionCategory.salary,
        minorUnits: 4500000,
        merchant: 'Salary',
      );
      final FinancialTransaction expense = buildTestTransaction(
        id: 'persistent-expense',
        minorUnits: 845000,
        merchant: 'Food',
      );
      await repositoryA.createTransaction(income);
      await repositoryA.createTransaction(expense);
      await databaseA.close();

      final AppDatabase databaseB = AppDatabase(NativeDatabase(databaseFile));
      final DriftTransactionRepository repositoryB = DriftTransactionRepository(
        databaseB,
      );
      List<FinancialTransaction> restored = await repositoryB
          .watchTransactions()
          .first;
      expect(
        restored.map((FinancialTransaction value) => value.id),
        containsAll(<String>[income.id, expense.id]),
      );

      await repositoryB.updateTransaction(
        expense.copyWith(
          amount: const Money(minorUnits: 900000),
          updatedAt: fixedNow.add(const Duration(minutes: 1)),
        ),
      );
      final FinancialTransaction repeated = buildTestTransaction(
        id: 'persistent-repeat',
        minorUnits: expense.amount.minorUnits,
        merchant: expense.merchant,
        createdAt: fixedNow.add(const Duration(minutes: 2)),
      );
      await repositoryB.createTransaction(repeated);
      await repositoryB.deleteTransaction(income.id);
      await databaseB.close();

      final AppDatabase databaseC = AppDatabase(NativeDatabase(databaseFile));
      final DriftTransactionRepository repositoryC = DriftTransactionRepository(
        databaseC,
      );
      restored = await repositoryC.watchTransactions().first;
      expect(restored, hasLength(2));
      final FinancialTransaction edited = restored.singleWhere(
        (FinancialTransaction value) => value.id == expense.id,
      );
      expect(edited.amount.minorUnits, 900000);
      expect(
        restored
            .singleWhere(
              (FinancialTransaction value) => value.id == repeated.id,
            )
            .amount,
        repeated.amount,
      );
      await databaseC.close();
    },
  );

  test('Undo removes the persistent row across database reopening', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'budgeting-drift-undo-',
    );
    final File databaseFile = File(
      '${directory.path}${Platform.pathSeparator}transactions.sqlite',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final AppDatabase databaseA = AppDatabase(NativeDatabase(databaseFile));
    final DriftTransactionRepository repositoryA = DriftTransactionRepository(
      databaseA,
    );
    final FinancialTransaction created = buildTestTransaction(
      id: 'persistent-undo',
    );
    await repositoryA.createTransaction(created);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        transactionRepositoryProvider.overrideWithValue(repositoryA),
      ],
    );
    final LastSavedTransactionController controller = container.read(
      lastSavedTransactionProvider.notifier,
    );
    controller.show(created);
    expect(await controller.undo(), isTrue);
    container.dispose();
    await databaseA.close();

    final AppDatabase databaseB = AppDatabase(NativeDatabase(databaseFile));
    final DriftTransactionRepository repositoryB = DriftTransactionRepository(
      databaseB,
    );
    expect(await repositoryB.watchTransactions().first, isEmpty);
    await databaseB.close();
  });
}

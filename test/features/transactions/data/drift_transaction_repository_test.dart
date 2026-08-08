import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';
import '../../../support/test_database.dart';

void main() {
  late AppDatabase database;
  late DriftTransactionRepository repository;

  setUp(() {
    final ({AppDatabase database, DriftTransactionRepository repository})
    testDatabase = createInMemoryTransactionDatabase();
    database = testDatabase.database;
    repository = testDatabase.repository;
  });

  tearDown(() async {
    await database.close();
  });

  test('database and repository start empty without mock seeding', () async {
    expect(database.schemaVersion, 3);
    expect(await repository.watchTransactions().first, isEmpty);
  });

  test('every domain field round-trips with integer Money integrity', () async {
    final FinancialTransaction transaction = FinancialTransaction(
      id: 'round-trip',
      type: TransactionType.expense,
      amount: const Money(minorUnits: 900719925474099, currencyCode: 'NPR'),
      category: TransactionCategory.rentAndHousing,
      paymentMethod: PaymentMethod.eSewa,
      occurredAt: DateTime.utc(2026, 8, 3, 18, 15, 27, 421, 250),
      merchant: 'Kathmandu Housing Cooperative',
      note: 'August rent',
      createdAt: DateTime.utc(2026, 8, 3, 18, 20, 1, 200, 300),
      updatedAt: DateTime.utc(2026, 8, 3, 19, 1, 2, 300, 400),
    );

    await repository.createTransaction(transaction);
    final FinancialTransaction? restored = await repository.getTransactionById(
      transaction.id,
    );

    expect(restored, isNotNull);
    expect(restored!.id, transaction.id);
    expect(restored.type, transaction.type);
    expect(restored.amount, transaction.amount);
    expect(restored.category, transaction.category);
    expect(restored.paymentMethod, transaction.paymentMethod);
    expect(restored.occurredAt, transaction.occurredAt);
    expect(
      restored.occurredAt.toLocal().day,
      transaction.occurredAt.toLocal().day,
    );
    expect(restored.merchant, transaction.merchant);
    expect(restored.note, transaction.note);
    expect(restored.createdAt, transaction.createdAt);
    expect(restored.updatedAt, transaction.updatedAt);
  });

  test('expense, income, category, and payment keys map explicitly', () async {
    int index = 0;
    for (final TransactionCategory category in TransactionCategory.values) {
      final TransactionType type = category.supports(TransactionType.expense)
          ? TransactionType.expense
          : TransactionType.income;
      final PaymentMethod payment =
          PaymentMethod.values[index % PaymentMethod.values.length];
      await repository.createTransaction(
        buildTestTransaction(
          id: 'mapping-$index',
          type: type,
          category: category,
          paymentMethod: payment,
          createdAt: fixedNow.add(Duration(microseconds: index)),
        ),
      );
      index += 1;
    }

    final List<FinancialTransaction> restored = await repository
        .watchTransactions()
        .first;
    expect(restored, hasLength(TransactionCategory.values.length));
    for (final FinancialTransaction transaction in restored) {
      final int sourceIndex = int.parse(transaction.id.split('-').last);
      expect(transaction.category, TransactionCategory.values[sourceIndex]);
      expect(
        transaction.paymentMethod,
        PaymentMethod.values[sourceIndex % PaymentMethod.values.length],
      );
    }
    expect(
      restored.map((FinancialTransaction value) => value.type),
      containsAll(<TransactionType>[
        TransactionType.expense,
        TransactionType.income,
      ]),
    );
  });

  test('optional merchant and note remain null', () async {
    final FinancialTransaction transaction = buildTestTransaction(
      id: 'optional-null',
      merchant: null,
      note: null,
    );
    await repository.createTransaction(transaction);

    final FinancialTransaction? restored = await repository.getTransactionById(
      transaction.id,
    );
    expect(restored?.merchant, isNull);
    expect(restored?.note, isNull);
  });

  test('watch emits after insert, update, and delete', () async {
    final List<List<FinancialTransaction>> emissions =
        <List<FinancialTransaction>>[];
    final subscription = repository.watchTransactions().listen(emissions.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    final FinancialTransaction original = buildTestTransaction(id: 'watched');
    await repository.createTransaction(original);
    await pumpEventQueue();
    expect(emissions.last.single.amount.minorUnits, 125000);

    await repository.updateTransaction(
      original.copyWith(
        amount: const Money(minorUnits: 175000),
        updatedAt: fixedNow.add(const Duration(minutes: 1)),
      ),
    );
    await pumpEventQueue();
    expect(emissions.last.single.amount.minorUnits, 175000);

    await repository.deleteTransaction(original.id);
    await pumpEventQueue();
    expect(emissions.last, isEmpty);
  });

  test('multiple and rapid writes preserve newest-first ordering', () async {
    final List<Future<void>> writes = List<Future<void>>.generate(25, (
      int index,
    ) {
      return repository.createTransaction(
        buildTestTransaction(
          id: 'rapid-$index',
          occurredAt: fixedNow.add(Duration(minutes: index)),
          createdAt: fixedNow.add(Duration(microseconds: index)),
        ),
      );
    });
    await Future.wait(writes);

    final List<FinancialTransaction> restored = await repository
        .watchTransactions()
        .first;
    expect(restored, hasLength(25));
    expect(restored.first.id, 'rapid-24');
    expect(restored.last.id, 'rapid-0');
  });

  test('duplicate and missing IDs expose controlled failures', () async {
    final FinancialTransaction transaction = buildTestTransaction(
      id: 'guarded-id',
    );
    await repository.createTransaction(transaction);

    await expectLater(
      repository.createTransaction(transaction),
      throwsA(isA<TransactionRepositoryException>()),
    );
    await expectLater(
      repository.updateTransaction(buildTestTransaction(id: 'missing-update')),
      throwsA(isA<TransactionNotFoundException>()),
    );
    await expectLater(
      repository.deleteTransaction('missing-delete'),
      throwsA(isA<TransactionNotFoundException>()),
    );
  });

  test('unsupported stored enum values surface as stream errors', () async {
    await database.insertStoredTransaction(
      StoredTransactionsCompanion.insert(
        id: 'malformed',
        typeKey: 'unsupported_type',
        amountMinorUnits: 100,
        currencyCode: 'NPR',
        categoryKey: 'food',
        paymentMethodKey: 'cash',
        occurredAtUtcMicros: fixedNow.microsecondsSinceEpoch,
        createdAtUtcMicros: fixedNow.microsecondsSinceEpoch,
        updatedAtUtcMicros: fixedNow.microsecondsSinceEpoch,
      ),
    );

    await expectLater(
      repository.watchTransactions().first,
      throwsA(isA<FormatException>()),
    );
  });

  test('unknown stored payment method falls back to Other', () async {
    await database.insertStoredTransaction(
      StoredTransactionsCompanion.insert(
        id: 'unknown-payment',
        typeKey: 'expense',
        amountMinorUnits: 100,
        currencyCode: 'NPR',
        categoryKey: 'food',
        paymentMethodKey: 'future_or_malformed_method',
        occurredAtUtcMicros: fixedNow.microsecondsSinceEpoch,
        createdAtUtcMicros: fixedNow.microsecondsSinceEpoch,
        updatedAtUtcMicros: fixedNow.microsecondsSinceEpoch,
      ),
    );

    final FinancialTransaction restored =
        (await repository.watchTransactions().first).single;
    expect(restored.paymentMethod, PaymentMethod.other);
  });

  test('new rows are scoped to guest and reads remain owner-scoped', () async {
    final DriftTransactionRepository futureUserRepository =
        DriftTransactionRepository(database, ownerScope: 'user:future-id');
    final FinancialTransaction guestTransaction = buildTestTransaction(
      id: 'guest-owned',
    );
    final FinancialTransaction futureUserTransaction = buildTestTransaction(
      id: 'future-user-owned',
      type: TransactionType.income,
      category: TransactionCategory.salary,
    );

    await repository.createTransaction(guestTransaction);
    await futureUserRepository.createTransaction(futureUserTransaction);

    expect(
      (await repository.watchTransactions().first).single.id,
      guestTransaction.id,
    );
    expect(
      (await futureUserRepository.watchTransactions().first).single.id,
      futureUserTransaction.id,
    );
    expect(
      (await database.findStoredTransaction(guestTransaction.id))?.ownerScope,
      'guest',
    );
    expect(
      await repository.getTransactionById(futureUserTransaction.id),
      isNull,
    );
  });

  test('editing a row preserves its owner scope', () async {
    final DriftTransactionRepository futureUserRepository =
        DriftTransactionRepository(database, ownerScope: 'user:future-id');
    final FinancialTransaction original = buildTestTransaction(
      id: 'owner-preserved',
      type: TransactionType.income,
      category: TransactionCategory.salary,
    );
    await futureUserRepository.createTransaction(original);

    await futureUserRepository.updateTransaction(
      original.copyWith(
        amount: const Money(minorUnits: 999999),
        updatedAt: fixedNow.add(const Duration(minutes: 1)),
      ),
    );

    expect(
      (await database.findStoredTransaction(
        original.id,
        ownerScope: 'user:future-id',
      ))?.ownerScope,
      'user:future-id',
    );
    expect(await repository.getTransactionById(original.id), isNull);
  });
}

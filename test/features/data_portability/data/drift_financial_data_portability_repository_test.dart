import 'dart:convert';

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/app_database.dart'
    hide
        CustomCategory,
        RecurringTransactionOccurrence,
        RecurringTransactionRule;
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/data_portability/data/repositories/drift_financial_data_portability_repository.dart';
import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';
import 'package:budgeting_app/features/data_portability/domain/services/backup_codec.dart';
import 'package:budgeting_app/features/data_portability/domain/services/data_portability_exception.dart';
import 'package:budgeting_app/features/recurring/data/database/recurring_database_mapper.dart';
import 'package:budgeting_app/features/recurring/data/repositories/drift_recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test(
    'reads all current-owner financial rows including occurrence history',
    () async {
      final DriftFinancialDataPortabilityRepository repository =
          DriftFinancialDataPortabilityRepository(
            database,
            ownerScope: OwnerScopes.guest,
          );
      final FinancialDataSnapshot expected = _snapshot();
      await _insertSnapshot(database, expected, OwnerScopes.guest);
      await _insertSnapshot(database, _snapshot(prefix: 'other'), 'user:other');

      final FinancialDataSnapshot actual = await repository
          .readCurrentOwnerSnapshot();

      expect(actual.transactions.map((value) => value.id), <String>['tx']);
      expect(actual.recurringRules.map((value) => value.id), <String>['rule']);
      expect(actual.recurringOccurrences.map((value) => value.id), <String>[
        'occ',
      ]);
    },
  );

  test(
    'recovery backup source remains current-owner scoped and portable',
    () async {
      await _insertSnapshot(database, _snapshot(prefix: 'owner-a'), 'user:a');
      await _insertSnapshot(database, _snapshot(prefix: 'owner-b'), 'user:b');
      final DriftFinancialDataPortabilityRepository repository =
          DriftFinancialDataPortabilityRepository(
            database,
            ownerScope: 'user:b',
          );
      final FinancialDataSnapshot current = await repository
          .readCurrentOwnerSnapshot();
      final BackupCodec codec = BackupCodec(
        RecurrenceService(BikramSambatCalendarService()),
      );
      final bytes = codec.encode(
        PortableBackup(
          createdAtUtc: DateTime.utc(2026, 8, 10, 15),
          sourceDatabaseSchemaVersion: 3,
          snapshot: current,
        ),
      );

      final PortableBackup decoded = codec.decode(bytes);
      expect(decoded.snapshot.transactions.single.id, 'owner-b-tx');
      expect(decoded.snapshot.recurringRules.single.id, 'owner-b-rule');
      expect(utf8.decode(bytes), isNot(contains('user:a')));
      expect(utf8.decode(bytes), isNot(contains('user:b')));
    },
  );

  test(
    'atomically replaces current owner and preserves preferences and other owners',
    () async {
      const String currentOwner = 'user:b';
      final DriftFinancialDataPortabilityRepository repository =
          DriftFinancialDataPortabilityRepository(
            database,
            ownerScope: currentOwner,
          );
      await _insertSnapshot(database, _snapshot(prefix: 'old-b'), currentOwner);
      await _insertSnapshot(database, _snapshot(prefix: 'owner-a'), 'user:a');
      await database.writePreference('theme_mode', 'dark');
      final FinancialDataSnapshot replacement = _snapshot(prefix: 'restored');

      await repository.replaceCurrentOwnerSnapshot(replacement);

      final FinancialDataSnapshot restored = await repository
          .readCurrentOwnerSnapshot();
      expect(restored.transactions.single.id, 'restored-tx');
      expect(restored.recurringRules.single.id, 'restored-rule');
      expect(restored.recurringOccurrences.single.ruleId, 'restored-rule');
      expect(
        restored.recurringOccurrences.single.recordedTransactionId,
        'restored-tx',
      );
      expect(await database.readPreference('theme_mode'), 'dark');
      final FinancialDataSnapshot ownerA =
          await DriftFinancialDataPortabilityRepository(
            database,
            ownerScope: 'user:a',
          ).readCurrentOwnerSnapshot();
      expect(ownerA.transactions.single.id, 'owner-a-tx');
    },
  );

  test(
    'portable IDs are preserved unless another owner already uses them',
    () async {
      await _insertSnapshot(database, _snapshot(), 'user:a');
      final DriftFinancialDataPortabilityRepository ownerB =
          DriftFinancialDataPortabilityRepository(
            database,
            ownerScope: 'user:b',
          );

      await ownerB.replaceCurrentOwnerSnapshot(_snapshot());

      final FinancialDataSnapshot a =
          await DriftFinancialDataPortabilityRepository(
            database,
            ownerScope: 'user:a',
          ).readCurrentOwnerSnapshot();
      final FinancialDataSnapshot b = await ownerB.readCurrentOwnerSnapshot();
      expect(a.transactions.single.id, 'tx');
      expect(b.transactions.single.id, 'tx-restored-1');
      expect(b.recurringRules.single.id, 'rule-restored-1');
      expect(b.recurringOccurrences.single.ruleId, 'rule-restored-1');
      expect(
        b.recurringOccurrences.single.recordedTransactionId,
        'tx-restored-1',
      );
    },
  );

  test('custom category IDs and references remap portably by owner', () async {
    await _insertSnapshot(database, _snapshot(custom: true), 'user:a');
    final DriftFinancialDataPortabilityRepository ownerB =
        DriftFinancialDataPortabilityRepository(database, ownerScope: 'user:b');

    await ownerB.replaceCurrentOwnerSnapshot(_snapshot(custom: true));

    final FinancialDataSnapshot a =
        await DriftFinancialDataPortabilityRepository(
          database,
          ownerScope: 'user:a',
        ).readCurrentOwnerSnapshot();
    final FinancialDataSnapshot b = await ownerB.readCurrentOwnerSnapshot();
    expect(a.customCategories.single.id, 'custom:fitness');
    expect(b.customCategories.single.id, 'custom:fitness-restored-1');
    expect(b.transactions.single.category.name, b.customCategories.single.id);
    expect(b.recurringRules.single.category.name, b.customCategories.single.id);
    expect(
      b.recurringOccurrences.single.category.name,
      b.customCategories.single.id,
    );
  });

  test('midway insert failure rolls back the exact original state', () async {
    final DriftFinancialDataPortabilityRepository repository =
        DriftFinancialDataPortabilityRepository(
          database,
          ownerScope: OwnerScopes.guest,
        );
    await _insertSnapshot(
      database,
      _snapshot(prefix: 'original'),
      OwnerScopes.guest,
    );
    await database.customStatement('''
      CREATE TRIGGER fail_restore BEFORE INSERT ON stored_transactions
      WHEN NEW.id = 'fail-tx'
      BEGIN
        SELECT RAISE(ABORT, 'forced restore failure');
      END;
    ''');

    await expectLater(
      repository.replaceCurrentOwnerSnapshot(_snapshot(prefix: 'fail')),
      throwsA(isA<DataPortabilityException>()),
    );

    final FinancialDataSnapshot after = await repository
        .readCurrentOwnerSnapshot();
    expect(after.transactions.single.id, 'original-tx');
    expect(after.recurringRules.single.id, 'original-rule');
    expect(after.recurringOccurrences.single.id, 'original-occ');
  });

  test('restored rows remain reactive and reconcile idempotently', () async {
    final DriftFinancialDataPortabilityRepository portability =
        DriftFinancialDataPortabilityRepository(
          database,
          ownerScope: OwnerScopes.guest,
        );
    final DriftTransactionRepository transactions = DriftTransactionRepository(
      database,
    );
    final Future<List<FinancialTransaction>> nextEmission = transactions
        .watchTransactions()
        .firstWhere((values) => values.isNotEmpty);

    await portability.replaceCurrentOwnerSnapshot(_snapshot());
    expect((await nextEmission).single.id, 'tx');

    final DriftRecurringTransactionRepository recurring =
        DriftRecurringTransactionRepository(
          database,
          RecurrenceService(BikramSambatCalendarService()),
        );
    await recurring.reconcileThrough(
      today: DateTime(2026, 8, 4),
      handledAt: DateTime.utc(2026, 8, 4),
    );
    await recurring.reconcileThrough(
      today: DateTime(2026, 8, 4),
      handledAt: DateTime.utc(2026, 8, 4),
    );
    final rows = await database
        .select(database.recurringTransactionOccurrences)
        .get();
    expect(
      rows.where((row) => row.ownerScope == OwnerScopes.guest),
      hasLength(1),
    );
  });
}

FinancialDataSnapshot _snapshot({String prefix = '', bool custom = false}) {
  final String p = prefix.isEmpty ? '' : '$prefix-';
  final String categoryId = custom
      ? 'custom:${p.isEmpty ? 'fitness' : '${p}fitness'}'
      : '';
  final TransactionCategory category = custom
      ? TransactionCategory.custom(categoryId, type: TransactionType.expense)
      : TransactionCategory.food;
  final FinancialTransaction transaction = buildTestTransaction(
    id: '${p}tx',
    category: category,
  );
  final RecurringTransactionRule rule = buildTestRecurringRule(
    id: '${p}rule',
    category: category,
    firstDueDateAd: DateTime(2026, 8, 4, 12),
    nextDueDateAd: DateTime(2026, 9, 4, 12),
  );
  final RecurringTransactionOccurrence occurrence =
      RecurringTransactionOccurrence(
        id: '${p}occ',
        ruleId: rule.id,
        dueDateAd: DateTime(2026, 8, 4, 12),
        status: RecurringOccurrenceStatus.recorded,
        type: transaction.type,
        amount: transaction.amount,
        category: transaction.category,
        paymentMethod: transaction.paymentMethod,
        recordedTransactionId: transaction.id,
        handledAt: fixedNow,
        createdAt: fixedNow,
      );
  return FinancialDataSnapshot(
    customCategories: custom
        ? <CustomCategory>[
            CustomCategory(
              id: categoryId,
              type: TransactionType.expense,
              name: 'Fitness',
              normalizedName: 'fitness',
              iconKey: 'fitness',
              isArchived: false,
              createdAt: fixedNow,
              updatedAt: fixedNow,
            ),
          ]
        : const <CustomCategory>[],
    transactions: <FinancialTransaction>[transaction],
    recurringRules: <RecurringTransactionRule>[rule],
    recurringOccurrences: <RecurringTransactionOccurrence>[occurrence],
  );
}

Future<void> _insertSnapshot(
  AppDatabase database,
  FinancialDataSnapshot snapshot,
  String owner,
) async {
  for (final CustomCategory category in snapshot.customCategories) {
    await database
        .into(database.customCategories)
        .insert(
          CustomCategoriesCompanion.insert(
            id: category.id,
            ownerScope: owner,
            typeKey: category.type.name,
            name: category.name,
            normalizedName: category.normalizedName,
            iconKey: category.iconKey,
            isArchived: Value<bool>(category.isArchived),
            createdAtUtcMicros: category.createdAt.microsecondsSinceEpoch,
            updatedAtUtcMicros: category.updatedAt.microsecondsSinceEpoch,
          ),
        );
  }
  for (final FinancialTransaction transaction in snapshot.transactions) {
    await database
        .into(database.storedTransactions)
        .insert(
          TransactionDatabaseMapper.toCompanion(transaction, ownerScope: owner),
        );
  }
  for (final RecurringTransactionRule rule in snapshot.recurringRules) {
    await database
        .into(database.recurringTransactionRules)
        .insert(
          RecurringDatabaseMapper.ruleToCompanion(rule, ownerScope: owner),
        );
  }
  for (final RecurringTransactionOccurrence occurrence
      in snapshot.recurringOccurrences) {
    await database
        .into(database.recurringTransactionOccurrences)
        .insert(
          RecurringDatabaseMapper.occurrenceToCompanion(
            occurrence,
            ownerScope: owner,
          ),
        );
  }
}

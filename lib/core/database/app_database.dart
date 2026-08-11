import 'package:budgeting_app/core/database/app_database.steps.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class StoredTransactions extends Table {
  TextColumn get id => text()();

  TextColumn get typeKey => text()();

  IntColumn get amountMinorUnits => integer()();

  TextColumn get currencyCode => text()();

  TextColumn get categoryKey => text()();

  TextColumn get paymentMethodKey => text()();

  IntColumn get occurredAtUtcMicros => integer()();

  TextColumn get merchant => text().nullable()();

  TextColumn get note => text().nullable()();

  IntColumn get createdAtUtcMicros => integer()();

  IntColumn get updatedAtUtcMicros => integer()();

  TextColumn get ownerScope => text().withDefault(const Constant('guest'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class StoredPreferences extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@TableIndex(
  name: 'stored_transfers_owner_date',
  columns: <Symbol>{#ownerScope, #occurredAtUtcMicros},
)
class StoredTransfers extends Table {
  TextColumn get id => text()();
  TextColumn get ownerScope => text()();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get sourceKey => text()();
  TextColumn get destinationKey => text()();
  TextColumn get destinationName => text().nullable()();
  BoolColumn get countsAsExpense =>
      boolean().withDefault(const Constant(false))();
  TextColumn get expenseCategoryKey => text().nullable()();
  IntColumn get feeMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get occurredAtUtcMicros => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAtUtcMicros => integer()();
  IntColumn get updatedAtUtcMicros => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class RecurringTransactionRules extends Table {
  TextColumn get id => text()();
  TextColumn get ownerScope => text()();
  TextColumn get typeKey => text()();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get categoryKey => text()();
  TextColumn get paymentMethodKey => text()();
  TextColumn get merchant => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get frequencyKey => text()();
  TextColumn get recurrenceCalendarKey => text()();
  IntColumn get anchorDay => integer()();
  IntColumn get anchorMonth => integer()();
  IntColumn get anchorWeekday => integer()();
  IntColumn get firstDueDateAdUtcMicros => integer()();
  IntColumn get nextDueDateAdUtcMicros => integer()();
  TextColumn get statusKey => text()();
  IntColumn get createdAtUtcMicros => integer()();
  IntColumn get updatedAtUtcMicros => integer()();
  IntColumn get pausedAtUtcMicros => integer().nullable()();
  IntColumn get deletedAtUtcMicros => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class RecurringTransactionOccurrences extends Table {
  TextColumn get id => text()();
  TextColumn get ruleId => text()();
  TextColumn get ownerScope => text()();
  IntColumn get dueDateAdUtcMicros => integer()();
  TextColumn get statusKey => text()();
  TextColumn get typeKey => text()();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get categoryKey => text()();
  TextColumn get paymentMethodKey => text()();
  TextColumn get merchant => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get recordedTransactionId => text().nullable()();
  IntColumn get handledAtUtcMicros => integer().nullable()();
  IntColumn get createdAtUtcMicros => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
    <Column<Object>>{ownerScope, ruleId, dueDateAdUtcMicros},
  ];
}

@DriftDatabase(
  tables: <Type>[
    StoredTransactions,
    StoredPreferences,
    StoredTransfers,
    RecurringTransactionRules,
    RecurringTransactionOccurrences,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open()
    : super(
        driftDatabase(
          name: 'personal_money_tracker',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) => migrator.createAll(),
    onUpgrade: stepByStep(
      from1To2: (Migrator migrator, Schema2 schema) async {
        await migrator.addColumn(
          schema.storedTransactions,
          schema.storedTransactions.ownerScope,
        );
        await migrator.createTable(schema.storedPreferences);
      },
      from2To3: (Migrator migrator, Schema3 schema) async {
        await migrator.createTable(schema.recurringTransactionRules);
        await migrator.createTable(schema.recurringTransactionOccurrences);
      },
      from3To4: (Migrator migrator, Schema4 schema) async {
        await migrator.createTable(schema.storedTransfers);
        await migrator.createIndex(schema.storedTransfersOwnerDate);
      },
      // A short-lived, abandoned Accounts experiment also used schema v4 on
      // development devices. Those databases don't contain StoredTransfers.
      // Version 5 is a compatibility bridge that repairs that collision while
      // leaving all existing financial rows untouched.
      from4To5: (Migrator migrator, Schema5 schema) async {
        final QueryRow? storedTransfersTable = await customSelect(
          "SELECT 1 FROM sqlite_master "
          "WHERE type = 'table' AND name = 'stored_transfers' LIMIT 1",
        ).getSingleOrNull();
        if (storedTransfersTable == null) {
          await migrator.createTable(schema.storedTransfers);
        }
        await customStatement(
          'CREATE INDEX IF NOT EXISTS stored_transfers_owner_date '
          'ON stored_transfers (owner_scope, occurred_at_utc_micros)',
        );
      },
    ),
  );

  Stream<List<StoredTransaction>> watchStoredTransactionsForOwner(
    String ownerScope,
  ) {
    return (select(storedTransactions)..where(
          (StoredTransactions table) => table.ownerScope.equals(ownerScope),
        ))
        .watch();
  }

  Future<StoredTransaction?> findStoredTransaction(
    String transactionId, {
    String ownerScope = 'guest',
  }) {
    return (select(storedTransactions)..where(
          (StoredTransactions table) =>
              table.id.equals(transactionId) &
              table.ownerScope.equals(ownerScope),
        ))
        .getSingleOrNull();
  }

  Future<void> insertStoredTransaction(
    StoredTransactionsCompanion transaction,
  ) async {
    await into(storedTransactions).insert(transaction);
  }

  Future<int> updateStoredTransaction(
    String transactionId,
    StoredTransactionsCompanion transaction, {
    String ownerScope = 'guest',
  }) {
    return (update(storedTransactions)..where(
          (StoredTransactions table) =>
              table.id.equals(transactionId) &
              table.ownerScope.equals(ownerScope),
        ))
        .write(transaction);
  }

  Future<int> deleteStoredTransaction(
    String transactionId, {
    String ownerScope = 'guest',
  }) {
    return transaction(() async {
      await (update(recurringTransactionOccurrences)..where(
            (RecurringTransactionOccurrences table) =>
                table.ownerScope.equals(ownerScope) &
                table.recordedTransactionId.equals(transactionId),
          ))
          .write(
            const RecurringTransactionOccurrencesCompanion(
              recordedTransactionId: Value<String?>(null),
            ),
          );
      return (delete(storedTransactions)..where(
            (StoredTransactions table) =>
                table.id.equals(transactionId) &
                table.ownerScope.equals(ownerScope),
          ))
          .go();
    });
  }

  Stream<List<RecurringTransactionRule>> watchRecurringRulesForOwner(
    String ownerScope,
  ) {
    return (select(recurringTransactionRules)..where(
          (RecurringTransactionRules table) =>
              table.ownerScope.equals(ownerScope),
        ))
        .watch();
  }

  Stream<List<RecurringTransactionOccurrence>>
  watchRecurringOccurrencesForOwner(String ownerScope) {
    return (select(recurringTransactionOccurrences)
          ..where(
            (RecurringTransactionOccurrences table) =>
                table.ownerScope.equals(ownerScope),
          )
          ..orderBy(<OrderingTerm Function(RecurringTransactionOccurrences)>[
            (RecurringTransactionOccurrences table) =>
                OrderingTerm.asc(table.dueDateAdUtcMicros),
          ]))
        .watch();
  }

  Future<RecurringTransactionRule?> findRecurringRule(
    String ruleId, {
    required String ownerScope,
  }) {
    return (select(recurringTransactionRules)..where(
          (RecurringTransactionRules table) =>
              table.id.equals(ruleId) & table.ownerScope.equals(ownerScope),
        ))
        .getSingleOrNull();
  }

  Future<RecurringTransactionOccurrence?> findRecurringOccurrence(
    String occurrenceId, {
    required String ownerScope,
  }) {
    return (select(recurringTransactionOccurrences)..where(
          (RecurringTransactionOccurrences table) =>
              table.id.equals(occurrenceId) &
              table.ownerScope.equals(ownerScope),
        ))
        .getSingleOrNull();
  }

  Stream<String?> watchPreference(String preferenceKey) {
    return (select(storedPreferences)
          ..where((StoredPreferences table) => table.key.equals(preferenceKey)))
        .watchSingleOrNull()
        .map((StoredPreference? row) => row?.value);
  }

  Future<String?> readPreference(String preferenceKey) async {
    final StoredPreference? row =
        await (select(storedPreferences)..where(
              (StoredPreferences table) => table.key.equals(preferenceKey),
            ))
            .getSingleOrNull();
    return row?.value;
  }

  Future<void> writePreference(String preferenceKey, String value) async {
    await into(storedPreferences).insertOnConflictUpdate(
      StoredPreferencesCompanion.insert(key: preferenceKey, value: value),
    );
  }

  Future<void> deletePreference(String preferenceKey) async {
    await (delete(storedPreferences)
          ..where((StoredPreferences table) => table.key.equals(preferenceKey)))
        .go();
  }

  Stream<List<StoredTransfer>> watchStoredTransfersForOwner(String ownerScope) {
    return (select(storedTransfers)
          ..where(
            (StoredTransfers table) => table.ownerScope.equals(ownerScope),
          )
          ..orderBy(<OrderingTerm Function(StoredTransfers)>[
            (StoredTransfers table) =>
                OrderingTerm.desc(table.occurredAtUtcMicros),
            (StoredTransfers table) =>
                OrderingTerm.desc(table.createdAtUtcMicros),
          ]))
        .watch();
  }

  Future<StoredTransfer?> findStoredTransfer(
    String transferId, {
    required String ownerScope,
  }) {
    return (select(storedTransfers)..where(
          (StoredTransfers table) =>
              table.id.equals(transferId) & table.ownerScope.equals(ownerScope),
        ))
        .getSingleOrNull();
  }

  Future<void> insertStoredTransfer(StoredTransfersCompanion transfer) async {
    await into(storedTransfers).insert(transfer);
  }

  Future<int> updateStoredTransfer(
    String transferId,
    StoredTransfersCompanion transfer, {
    required String ownerScope,
  }) {
    return (update(storedTransfers)..where(
          (StoredTransfers table) =>
              table.id.equals(transferId) & table.ownerScope.equals(ownerScope),
        ))
        .write(transfer);
  }

  Future<int> deleteStoredTransfer(
    String transferId, {
    required String ownerScope,
  }) {
    return (delete(storedTransfers)..where(
          (StoredTransfers table) =>
              table.id.equals(transferId) & table.ownerScope.equals(ownerScope),
        ))
        .go();
  }
}

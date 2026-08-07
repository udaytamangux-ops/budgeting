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

@DriftDatabase(tables: <Type>[StoredTransactions, StoredPreferences])
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
  int get schemaVersion => 2;

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
    return (delete(storedTransactions)..where(
          (StoredTransactions table) =>
              table.id.equals(transactionId) &
              table.ownerScope.equals(ownerScope),
        ))
        .go();
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
}

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

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(tables: <Type>[StoredTransactions])
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (Migrator migrator) => migrator.createAll());

  Stream<List<StoredTransaction>> watchAllStoredTransactions() {
    return select(storedTransactions).watch();
  }

  Future<StoredTransaction?> findStoredTransaction(String transactionId) {
    return (select(storedTransactions)
          ..where((StoredTransactions table) => table.id.equals(transactionId)))
        .getSingleOrNull();
  }

  Future<void> insertStoredTransaction(
    StoredTransactionsCompanion transaction,
  ) async {
    await into(storedTransactions).insert(transaction);
  }

  Future<int> updateStoredTransaction(
    String transactionId,
    StoredTransactionsCompanion transaction,
  ) {
    return (update(storedTransactions)
          ..where((StoredTransactions table) => table.id.equals(transactionId)))
        .write(transaction);
  }

  Future<int> deleteStoredTransaction(String transactionId) {
    return (delete(storedTransactions)
          ..where((StoredTransactions table) => table.id.equals(transactionId)))
        .go();
  }
}

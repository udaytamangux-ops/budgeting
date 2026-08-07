// dart format width=80
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test(
    'migration from v1 to v2 preserves rows and assigns guest owner',
    () async {
      const v1.StoredTransactionsData oldTransaction =
          v1.StoredTransactionsData(
            id: 'existing-v1-transaction',
            typeKey: 'expense',
            amountMinorUnits: 987654321,
            currencyCode: 'NPR',
            categoryKey: 'food',
            paymentMethodKey: 'cash',
            occurredAtUtcMicros: 1786032000000000,
            merchant: 'Existing merchant',
            note: 'Existing note',
            createdAtUtcMicros: 1786032000000000,
            updatedAtUtcMicros: 1786032000000000,
          );
      const v2.StoredTransactionsData expectedTransaction =
          v2.StoredTransactionsData(
            id: 'existing-v1-transaction',
            typeKey: 'expense',
            amountMinorUnits: 987654321,
            currencyCode: 'NPR',
            categoryKey: 'food',
            paymentMethodKey: 'cash',
            occurredAtUtcMicros: 1786032000000000,
            merchant: 'Existing merchant',
            note: 'Existing note',
            createdAtUtcMicros: 1786032000000000,
            updatedAtUtcMicros: 1786032000000000,
            ownerScope: 'guest',
          );

      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(oldDb.storedTransactions, oldTransaction);
        },
        validateItems: (newDb) async {
          expect(<v2.StoredTransactionsData>[
            expectedTransaction,
          ], await newDb.select(newDb.storedTransactions).get());
        },
      );
    },
  );
}

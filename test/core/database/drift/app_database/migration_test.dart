// dart format width=80
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

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

  test(
    'migration from v2 to v3 preserves transactions and preferences',
    () async {
      const v2.StoredTransactionsData oldTransaction =
          v2.StoredTransactionsData(
            id: 'existing-v2-transaction',
            typeKey: 'income',
            amountMinorUnits: 4500000,
            currencyCode: 'NPR',
            categoryKey: 'salary',
            paymentMethodKey: 'bank_account',
            occurredAtUtcMicros: 1785824100000000,
            merchant: 'Existing payer',
            note: 'Existing note',
            createdAtUtcMicros: 1785824100000000,
            updatedAtUtcMicros: 1785824100000000,
            ownerScope: 'guest',
          );
      const List<v2.StoredPreferencesData> oldPreferences =
          <v2.StoredPreferencesData>[
            v2.StoredPreferencesData(key: 'access_mode', value: 'guest'),
            v2.StoredPreferencesData(key: 'theme_mode', value: 'dark'),
            v2.StoredPreferencesData(
              key: 'primary_calendar',
              value: 'bikram_sambat_bs',
            ),
            v2.StoredPreferencesData(
              key: 'calendar_setup_complete',
              value: 'true',
            ),
          ];

      await verifier.testWithDataIntegrity(
        oldVersion: 2,
        newVersion: 3,
        createOld: v2.DatabaseAtV2.new,
        createNew: v3.DatabaseAtV3.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(oldDb.storedTransactions, oldTransaction);
          batch.insertAll(oldDb.storedPreferences, oldPreferences);
        },
        validateItems: (newDb) async {
          final List<v3.StoredTransactionsData> transactions = await newDb
              .select(newDb.storedTransactions)
              .get();
          expect(transactions, hasLength(1));
          expect(transactions.single.id, oldTransaction.id);
          expect(
            transactions.single.amountMinorUnits,
            oldTransaction.amountMinorUnits,
          );
          expect(
            transactions.single.occurredAtUtcMicros,
            oldTransaction.occurredAtUtcMicros,
          );
          expect(
            transactions.single.createdAtUtcMicros,
            oldTransaction.createdAtUtcMicros,
          );
          expect(transactions.single.ownerScope, 'guest');
          expect(transactions.single.paymentMethodKey, 'bank_account');
          expect(
            await newDb.select(newDb.storedPreferences).get(),
            <v3.StoredPreferencesData>[
              for (final v2.StoredPreferencesData preference in oldPreferences)
                v3.StoredPreferencesData(
                  key: preference.key,
                  value: preference.value,
                ),
            ],
          );
          expect(
            await newDb.select(newDb.recurringTransactionRules).get(),
            isEmpty,
          );
          expect(
            await newDb.select(newDb.recurringTransactionOccurrences).get(),
            isEmpty,
          );
        },
      );
    },
  );
}

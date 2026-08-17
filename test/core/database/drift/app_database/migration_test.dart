// dart format width=80
import 'dart:io';

import 'package:budgeting_app/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;

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

  test(
    'migration from v3 to v4 preserves data and invents no transfers',
    () async {
      const v3.StoredTransactionsData transaction = v3.StoredTransactionsData(
        id: 'existing-v3-transaction',
        typeKey: 'expense',
        amountMinorUnits: 125000,
        currencyCode: 'NPR',
        categoryKey: 'food',
        paymentMethodKey: 'cash',
        occurredAtUtcMicros: 1785824100000000,
        merchant: 'Existing merchant',
        note: 'Existing note',
        createdAtUtcMicros: 1785824100000000,
        updatedAtUtcMicros: 1785824100000000,
        ownerScope: 'guest',
      );
      const v3.StoredPreferencesData preference = v3.StoredPreferencesData(
        key: 'theme_mode',
        value: 'dark',
      );

      await verifier.testWithDataIntegrity(
        oldVersion: 3,
        newVersion: 4,
        createOld: v3.DatabaseAtV3.new,
        createNew: v4.DatabaseAtV4.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(oldDb.storedTransactions, transaction);
          batch.insert(oldDb.storedPreferences, preference);
        },
        validateItems: (newDb) async {
          final transactions = await newDb
              .select(newDb.storedTransactions)
              .get();
          expect(transactions, hasLength(1));
          expect(transactions.single.id, transaction.id);
          expect(
            transactions.single.amountMinorUnits,
            transaction.amountMinorUnits,
          );
          expect(transactions.single.ownerScope, 'guest');
          expect(
            await newDb.select(newDb.storedPreferences).get(),
            <v4.StoredPreferencesData>[
              const v4.StoredPreferencesData(key: 'theme_mode', value: 'dark'),
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
          expect(await newDb.select(newDb.storedTransfers).get(), isEmpty);
        },
      );
    },
  );

  test(
    'abandoned Accounts v4 collision upgrades without losing financial data',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'budgeting-legacy-accounts-v4-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final File file = File('${directory.path}/legacy.sqlite');
      final v3.DatabaseAtV3 legacy = v3.DatabaseAtV3(NativeDatabase(file));
      await legacy
          .into(legacy.storedTransactions)
          .insert(
            const v3.StoredTransactionsData(
              id: 'legacy-financial-record',
              typeKey: 'expense',
              amountMinorUnits: 250000,
              currencyCode: 'NPR',
              categoryKey: 'food',
              paymentMethodKey: 'cash',
              occurredAtUtcMicros: 1785824100000000,
              merchant: 'Existing merchant',
              note: null,
              createdAtUtcMicros: 1785824100000000,
              updatedAtUtcMicros: 1785824100000000,
              ownerScope: 'guest',
            ),
          );
      await legacy
          .into(legacy.storedPreferences)
          .insert(
            const v3.StoredPreferencesData(key: 'theme_mode', value: 'dark'),
          );
      await legacy.customStatement(
        'ALTER TABLE stored_transactions ADD COLUMN account_id TEXT NULL',
      );
      await legacy.customStatement(
        'ALTER TABLE recurring_transaction_rules '
        'ADD COLUMN account_id TEXT NULL',
      );
      await legacy.customStatement(
        'ALTER TABLE recurring_transaction_occurrences '
        'ADD COLUMN account_id TEXT NULL',
      );
      await legacy.customStatement(
        'CREATE TABLE accounts ('
        'id TEXT NOT NULL PRIMARY KEY, owner_scope TEXT NOT NULL, '
        'name TEXT NOT NULL, type_key TEXT NOT NULL, status_key TEXT NOT NULL, '
        'created_at_utc_micros INTEGER NOT NULL, '
        'updated_at_utc_micros INTEGER NOT NULL)',
      );
      await legacy.customStatement(
        'CREATE TABLE account_balance_anchors ('
        'id TEXT NOT NULL PRIMARY KEY, owner_scope TEXT NOT NULL, '
        'account_id TEXT NOT NULL, balance_minor_units INTEGER NOT NULL, '
        'effective_date_ad_utc_micros INTEGER NOT NULL, '
        'created_at_utc_micros INTEGER NOT NULL, kind_key TEXT NOT NULL)',
      );
      await legacy.customStatement('PRAGMA user_version = 4');
      await legacy.close();

      final AppDatabase upgraded = AppDatabase(NativeDatabase(file));
      addTearDown(upgraded.close);
      expect(await upgraded.select(upgraded.storedTransfers).get(), isEmpty);
      final transactions = await upgraded
          .select(upgraded.storedTransactions)
          .get();
      expect(transactions, hasLength(1));
      expect(transactions.single.id, 'legacy-financial-record');
      expect(transactions.single.amountMinorUnits, 250000);
      expect(
        await upgraded.select(upgraded.storedPreferences).get(),
        <StoredPreference>[
          const StoredPreference(key: 'theme_mode', value: 'dark'),
        ],
      );
      expect(upgraded.schemaVersion, 7);
    },
  );

  test(
    'migration from v5 to v6 preserves financial data and adds no categories',
    () async {
      const v5.StoredTransactionsData transaction = v5.StoredTransactionsData(
        id: 'existing-v5-transaction',
        typeKey: 'expense',
        amountMinorUnits: 125000,
        currencyCode: 'NPR',
        categoryKey: 'food',
        paymentMethodKey: 'cash',
        occurredAtUtcMicros: 1785824100000000,
        merchant: 'Existing merchant',
        note: null,
        createdAtUtcMicros: 1785824100000000,
        updatedAtUtcMicros: 1785824100000000,
        ownerScope: 'guest',
      );

      await verifier.testWithDataIntegrity(
        oldVersion: 5,
        newVersion: 6,
        createOld: v5.DatabaseAtV5.new,
        createNew: v6.DatabaseAtV6.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(oldDb.storedTransactions, transaction);
          batch.insert(
            oldDb.storedPreferences,
            const v5.StoredPreferencesData(key: 'theme_mode', value: 'dark'),
          );
        },
        validateItems: (newDb) async {
          final transactions = await newDb
              .select(newDb.storedTransactions)
              .get();
          expect(transactions, hasLength(1));
          expect(transactions.single.id, transaction.id);
          expect(transactions.single.amountMinorUnits, 125000);
          expect(
            await newDb.select(newDb.storedPreferences).get(),
            <v6.StoredPreferencesData>[
              const v6.StoredPreferencesData(key: 'theme_mode', value: 'dark'),
            ],
          );
          expect(await newDb.select(newDb.customCategories).get(), isEmpty);
        },
      );
    },
  );

  test(
    'migration from v6 to v7 preserves Phase 12 data and invents no plan',
    () async {
      const v6.StoredTransactionsData transaction = v6.StoredTransactionsData(
        id: 'existing-v6-transaction',
        typeKey: 'expense',
        amountMinorUnits: 125000,
        currencyCode: 'NPR',
        categoryKey: 'custom:existing',
        paymentMethodKey: 'cash',
        occurredAtUtcMicros: 1785824100000000,
        merchant: 'Existing merchant',
        note: null,
        createdAtUtcMicros: 1785824100000000,
        updatedAtUtcMicros: 1785824100000000,
        ownerScope: 'guest',
      );
      const v6.CustomCategoriesData category = v6.CustomCategoriesData(
        id: 'custom:existing',
        ownerScope: 'guest',
        typeKey: 'expense',
        name: 'Existing category',
        normalizedName: 'existing category',
        iconKey: 'other',
        isArchived: 1,
        createdAtUtcMicros: 1785824100000000,
        updatedAtUtcMicros: 1785824100000000,
      );

      await verifier.testWithDataIntegrity(
        oldVersion: 6,
        newVersion: 7,
        createOld: v6.DatabaseAtV6.new,
        createNew: v7.DatabaseAtV7.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(oldDb.storedTransactions, transaction);
          batch.insert(oldDb.customCategories, category);
          batch.insert(
            oldDb.storedPreferences,
            const v6.StoredPreferencesData(
              key: 'onboarding_completed',
              value: 'true',
            ),
          );
        },
        validateItems: (newDb) async {
          final transactions = await newDb
              .select(newDb.storedTransactions)
              .get();
          expect(transactions, hasLength(1));
          expect(transactions.single.id, transaction.id);
          expect(transactions.single.amountMinorUnits, 125000);
          final categories = await newDb.select(newDb.customCategories).get();
          expect(categories, hasLength(1));
          expect(categories.single.id, category.id);
          expect(categories.single.isArchived, 1);
          expect(
            await newDb.select(newDb.storedPreferences).get(),
            <v7.StoredPreferencesData>[
              const v7.StoredPreferencesData(
                key: 'onboarding_completed',
                value: 'true',
              ),
            ],
          );
          expect(await newDb.select(newDb.moneyPlanPreferences).get(), isEmpty);
          expect(await newDb.select(newDb.moneyPlanPeriods).get(), isEmpty);
          expect(
            await newDb.select(newDb.moneyPlanCategoryMappings).get(),
            isEmpty,
          );
        },
      );
    },
  );
}

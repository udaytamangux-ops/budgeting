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
  name: 'custom_categories_owner_type_name',
  columns: <Symbol>{#ownerScope, #typeKey, #normalizedName},
  unique: true,
)
class CustomCategories extends Table {
  TextColumn get id => text()();
  TextColumn get ownerScope => text()();
  TextColumn get typeKey => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get iconKey => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMicros => integer()();
  IntColumn get updatedAtUtcMicros => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
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

class MoneyPlanPreferences extends Table {
  TextColumn get ownerScope => text()();
  BoolColumn get isEnabled => boolean()();
  IntColumn get createdAtUtcMicros => integer()();
  IntColumn get updatedAtUtcMicros => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{ownerScope};
}

@TableIndex(
  name: 'money_plan_periods_owner_identity',
  columns: <Symbol>{
    #ownerScope,
    #calendarSystemKey,
    #calendarYear,
    #calendarMonth,
  },
  unique: true,
)
class MoneyPlanPeriods extends Table {
  TextColumn get id => text()();
  TextColumn get ownerScope => text()();
  IntColumn get periodStartUtcMicros => integer()();
  IntColumn get periodEndExclusiveUtcMicros => integer()();
  TextColumn get calendarSystemKey => text()();
  IntColumn get calendarYear => integer()();
  IntColumn get calendarMonth => integer()();
  IntColumn get needsPercent => integer()();
  IntColumn get wantsPercent => integer()();
  IntColumn get savingsPercent => integer()();
  IntColumn get createdAtUtcMicros => integer()();
  IntColumn get updatedAtUtcMicros => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(
  name: 'money_plan_mappings_period_category',
  columns: <Symbol>{#periodId, #categoryId},
  unique: true,
)
@TableIndex(
  name: 'money_plan_mappings_owner_period',
  columns: <Symbol>{#ownerScope, #periodId},
)
class MoneyPlanCategoryMappings extends Table {
  TextColumn get id => text()();
  TextColumn get ownerScope => text()();
  TextColumn get periodId =>
      text().references(MoneyPlanPeriods, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text()();
  TextColumn get planGroupKey => text()();
  IntColumn get createdAtUtcMicros => integer()();
  IntColumn get updatedAtUtcMicros => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[
    StoredTransactions,
    StoredPreferences,
    CustomCategories,
    StoredTransfers,
    RecurringTransactionRules,
    RecurringTransactionOccurrences,
    MoneyPlanPreferences,
    MoneyPlanPeriods,
    MoneyPlanCategoryMappings,
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
  int get schemaVersion => 7;

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
      from5To6: (Migrator migrator, Schema6 schema) async {
        await migrator.createTable(schema.customCategories);
        await migrator.createIndex(schema.customCategoriesOwnerTypeName);
      },
      from6To7: (Migrator migrator, Schema7 schema) async {
        await migrator.createTable(schema.moneyPlanPreferences);
        await migrator.createTable(schema.moneyPlanPeriods);
        await migrator.createIndex(schema.moneyPlanPeriodsOwnerIdentity);
        await migrator.createTable(schema.moneyPlanCategoryMappings);
        await migrator.createIndex(schema.moneyPlanMappingsPeriodCategory);
        await migrator.createIndex(schema.moneyPlanMappingsOwnerPeriod);
      },
    ),
  );

  Stream<List<CustomCategory>> watchCustomCategoriesForOwner(
    String ownerScope,
  ) {
    return (select(customCategories)
          ..where(
            (CustomCategories table) => table.ownerScope.equals(ownerScope),
          )
          ..orderBy(<OrderingTerm Function(CustomCategories)>[
            (CustomCategories table) => OrderingTerm.asc(table.typeKey),
            (CustomCategories table) => OrderingTerm.asc(table.normalizedName),
          ]))
        .watch();
  }

  Future<List<CustomCategory>> getCustomCategoriesForOwner(String ownerScope) {
    return (select(customCategories)
          ..where(
            (CustomCategories table) => table.ownerScope.equals(ownerScope),
          )
          ..orderBy(<OrderingTerm Function(CustomCategories)>[
            (CustomCategories table) => OrderingTerm.asc(table.typeKey),
            (CustomCategories table) => OrderingTerm.asc(table.normalizedName),
          ]))
        .get();
  }

  Future<CustomCategory?> findCustomCategory(
    String categoryId, {
    required String ownerScope,
  }) {
    return (select(customCategories)..where(
          (CustomCategories table) =>
              table.id.equals(categoryId) & table.ownerScope.equals(ownerScope),
        ))
        .getSingleOrNull();
  }

  Future<void> insertCustomCategory(CustomCategoriesCompanion category) =>
      into(customCategories).insert(category);

  Future<int> updateCustomCategory(
    String categoryId,
    CustomCategoriesCompanion category, {
    required String ownerScope,
  }) {
    return (update(customCategories)..where(
          (CustomCategories table) =>
              table.id.equals(categoryId) & table.ownerScope.equals(ownerScope),
        ))
        .write(category);
  }

  Future<bool> isCustomCategoryUsed(
    String categoryId, {
    required String ownerScope,
  }) async {
    final QueryRow row = await customSelect(
      '''SELECT (
        EXISTS(SELECT 1 FROM stored_transactions WHERE owner_scope = ? AND category_key = ?)
        OR EXISTS(SELECT 1 FROM stored_transfers WHERE owner_scope = ? AND expense_category_key = ?)
        OR EXISTS(SELECT 1 FROM recurring_transaction_rules WHERE owner_scope = ? AND category_key = ?)
        OR EXISTS(SELECT 1 FROM recurring_transaction_occurrences WHERE owner_scope = ? AND category_key = ?)
      ) AS is_used''',
      variables: <Variable<Object>>[
        Variable<String>(ownerScope),
        Variable<String>(categoryId),
        Variable<String>(ownerScope),
        Variable<String>(categoryId),
        Variable<String>(ownerScope),
        Variable<String>(categoryId),
        Variable<String>(ownerScope),
        Variable<String>(categoryId),
      ],
    ).getSingle();
    return row.read<bool>('is_used');
  }

  Future<Set<String>> getUsedCategoryIds({required String ownerScope}) async {
    final List<QueryRow> rows = await _usedCategoryIdsQuery(ownerScope).get();
    return _readCategoryIds(rows);
  }

  Stream<Set<String>> watchUsedCategoryIds({required String ownerScope}) {
    return _usedCategoryIdsQuery(
      ownerScope,
      readsFrom: <ResultSetImplementation>{
        storedTransactions,
        storedTransfers,
        recurringTransactionRules,
        recurringTransactionOccurrences,
      },
    ).watch().map(_readCategoryIds);
  }

  Selectable<QueryRow> _usedCategoryIdsQuery(
    String ownerScope, {
    Set<ResultSetImplementation> readsFrom = const <ResultSetImplementation>{},
  }) {
    return customSelect(
      '''SELECT category_key AS category_id
         FROM stored_transactions
         WHERE owner_scope = ?
       UNION
       SELECT expense_category_key AS category_id
         FROM stored_transfers
         WHERE owner_scope = ? AND expense_category_key IS NOT NULL
       UNION
       SELECT category_key AS category_id
         FROM recurring_transaction_rules
         WHERE owner_scope = ?
       UNION
       SELECT category_key AS category_id
         FROM recurring_transaction_occurrences
         WHERE owner_scope = ?''',
      variables: <Variable<Object>>[
        Variable<String>(ownerScope),
        Variable<String>(ownerScope),
        Variable<String>(ownerScope),
        Variable<String>(ownerScope),
      ],
      readsFrom: readsFrom,
    );
  }

  Set<String> _readCategoryIds(List<QueryRow> rows) {
    return rows.map((QueryRow row) => row.read<String>('category_id')).toSet();
  }

  Future<int> deleteCustomCategory(
    String categoryId, {
    required String ownerScope,
  }) async {
    return transaction(() async {
      await (delete(moneyPlanCategoryMappings)..where(
            (MoneyPlanCategoryMappings table) =>
                table.categoryId.equals(categoryId) &
                table.ownerScope.equals(ownerScope),
          ))
          .go();
      return (delete(customCategories)..where(
            (CustomCategories table) =>
                table.id.equals(categoryId) &
                table.ownerScope.equals(ownerScope),
          ))
          .go();
    });
  }

  Future<bool> hasAnyFinancialData() async {
    final QueryRow row = await customSelect('''SELECT (
        EXISTS(SELECT 1 FROM stored_transactions LIMIT 1)
        OR EXISTS(SELECT 1 FROM stored_transfers LIMIT 1)
        OR EXISTS(SELECT 1 FROM recurring_transaction_rules LIMIT 1)
        OR EXISTS(SELECT 1 FROM recurring_transaction_occurrences LIMIT 1)
      ) AS has_data''').getSingle();
    return row.read<bool>('has_data');
  }

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

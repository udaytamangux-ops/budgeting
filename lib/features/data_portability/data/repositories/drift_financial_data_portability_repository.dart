import 'package:budgeting_app/core/database/app_database.dart' as db;
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';
import 'package:budgeting_app/features/data_portability/domain/repositories/financial_data_portability_repository.dart';
import 'package:budgeting_app/features/data_portability/domain/services/data_portability_exception.dart';
import 'package:budgeting_app/features/recurring/data/database/recurring_database_mapper.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart'
    as domain;
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart'
    as domain;
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/data/database/transfer_database_mapper.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:drift/drift.dart';

final class DriftFinancialDataPortabilityRepository
    implements FinancialDataPortabilityRepository {
  const DriftFinancialDataPortabilityRepository(
    this._database, {
    required this.ownerScope,
  });

  final db.AppDatabase _database;
  final String ownerScope;

  @override
  Future<FinancialDataSnapshot> readCurrentOwnerSnapshot() async {
    try {
      final List<db.StoredTransaction> transactionRows =
          await (_database.select(_database.storedTransactions)..where(
                (db.StoredTransactions table) =>
                    table.ownerScope.equals(ownerScope),
              ))
              .get();
      final List<db.RecurringTransactionRule> ruleRows =
          await (_database.select(_database.recurringTransactionRules)..where(
                (db.RecurringTransactionRules table) =>
                    table.ownerScope.equals(ownerScope),
              ))
              .get();
      final List<db.RecurringTransactionOccurrence> occurrenceRows =
          await (_database.select(_database.recurringTransactionOccurrences)
                ..where(
                  (db.RecurringTransactionOccurrences table) =>
                      table.ownerScope.equals(ownerScope),
                ))
              .get();
      final List<db.StoredTransfer> transferRows =
          await (_database.select(_database.storedTransfers)..where(
                (db.StoredTransfers table) =>
                    table.ownerScope.equals(ownerScope),
              ))
              .get();
      final List<db.CustomCategory> customCategoryRows = await _database
          .getCustomCategoriesForOwner(ownerScope);

      final List<FinancialTransaction> transactions =
          transactionRows
              .map(TransactionDatabaseMapper.fromRow)
              .toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
      final List<domain.RecurringTransactionRule> rules =
          ruleRows
              .map((row) {
                final domain.RecurringTransactionRule? mapped =
                    RecurringDatabaseMapper.ruleFromRow(row);
                if (mapped == null) {
                  throw const FormatException('Invalid rule row.');
                }
                return mapped;
              })
              .toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
      final List<domain.RecurringTransactionOccurrence> occurrences =
          occurrenceRows
              .map((row) {
                final domain.RecurringTransactionOccurrence? mapped =
                    RecurringDatabaseMapper.occurrenceFromRow(row);
                if (mapped == null) {
                  throw const FormatException('Invalid occurrence row.');
                }
                return mapped;
              })
              .toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
      final List<FinancialTransfer> transfers =
          transferRows
              .map(TransferDatabaseMapper.fromRow)
              .toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
      final List<CustomCategory> customCategories =
          customCategoryRows.map(_customCategoryFromRow).toList(growable: false)
            ..sort((a, b) => a.id.compareTo(b.id));
      return FinancialDataSnapshot(
        transactions: List<FinancialTransaction>.unmodifiable(transactions),
        recurringRules: List<domain.RecurringTransactionRule>.unmodifiable(
          rules,
        ),
        recurringOccurrences:
            List<domain.RecurringTransactionOccurrence>.unmodifiable(
              occurrences,
            ),
        transfers: List<FinancialTransfer>.unmodifiable(transfers),
        customCategories: List<CustomCategory>.unmodifiable(customCategories),
      );
    } catch (error) {
      throw DataPortabilityException(
        'Financial records could not be prepared. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> replaceCurrentOwnerSnapshot(
    FinancialDataSnapshot snapshot,
  ) async {
    try {
      await _database.transaction(() async {
        final _RestoreIds ids = await _resolveIds(snapshot);

        await (_database.delete(_database.recurringTransactionOccurrences)
              ..where(
                (db.RecurringTransactionOccurrences table) =>
                    table.ownerScope.equals(ownerScope),
              ))
            .go();
        await (_database.delete(_database.recurringTransactionRules)..where(
              (db.RecurringTransactionRules table) =>
                  table.ownerScope.equals(ownerScope),
            ))
            .go();
        await (_database.delete(_database.storedTransactions)..where(
              (db.StoredTransactions table) =>
                  table.ownerScope.equals(ownerScope),
            ))
            .go();
        await (_database.delete(_database.storedTransfers)..where(
              (db.StoredTransfers table) => table.ownerScope.equals(ownerScope),
            ))
            .go();
        await (_database.delete(_database.customCategories)..where(
              (db.CustomCategories table) =>
                  table.ownerScope.equals(ownerScope),
            ))
            .go();

        for (final CustomCategory category in snapshot.customCategories) {
          final String restoredId = ids.categories[category.id]!;
          await _database
              .into(_database.customCategories)
              .insert(
                db.CustomCategoriesCompanion.insert(
                  id: restoredId,
                  ownerScope: ownerScope,
                  typeKey: TransactionDatabaseMapper.typeToKey(category.type),
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
          final FinancialTransaction restored = _transactionWithId(
            transaction,
            ids.transactions[transaction.id]!,
            ids.categories,
          );
          await _database
              .into(_database.storedTransactions)
              .insert(
                TransactionDatabaseMapper.toCompanion(
                  restored,
                  ownerScope: ownerScope,
                ),
              );
        }
        for (final FinancialTransfer transfer in snapshot.transfers) {
          final FinancialTransfer restored = _transferWithId(
            transfer,
            ids.transfers[transfer.id]!,
            ids.categories,
          );
          await _database
              .into(_database.storedTransfers)
              .insert(
                TransferDatabaseMapper.toCompanion(
                  restored,
                  ownerScope: ownerScope,
                ),
              );
        }
        for (final domain.RecurringTransactionRule rule
            in snapshot.recurringRules) {
          final domain.RecurringTransactionRule restored = _ruleWithId(
            rule,
            ids.rules[rule.id]!,
            ids.categories,
          );
          await _database
              .into(_database.recurringTransactionRules)
              .insert(
                RecurringDatabaseMapper.ruleToCompanion(
                  restored,
                  ownerScope: ownerScope,
                ),
              );
        }
        for (final domain.RecurringTransactionOccurrence occurrence
            in snapshot.recurringOccurrences) {
          final domain.RecurringTransactionOccurrence restored =
              _occurrenceWithIds(
                occurrence,
                id: ids.occurrences[occurrence.id]!,
                ruleId: ids.rules[occurrence.ruleId]!,
                recordedTransactionId: occurrence.recordedTransactionId == null
                    ? null
                    : ids.transactions[occurrence.recordedTransactionId]!,
                categoryIds: ids.categories,
              );
          await _database
              .into(_database.recurringTransactionOccurrences)
              .insert(
                RecurringDatabaseMapper.occurrenceToCompanion(
                  restored,
                  ownerScope: ownerScope,
                ),
              );
        }
      });
    } catch (error) {
      throw DataPortabilityException(
        'The backup could not be restored. Your current records were not '
        'changed.',
        cause: error,
      );
    }
  }

  Future<_RestoreIds> _resolveIds(FinancialDataSnapshot snapshot) async {
    final Set<String> used = <String>{};
    used.addAll(
      await (_database.selectOnly(_database.storedTransfers)
            ..addColumns(<Expression<Object>>[_database.storedTransfers.id])
            ..where(
              _database.storedTransfers.ownerScope.equals(ownerScope).not(),
            ))
          .map((row) => row.read(_database.storedTransfers.id)!)
          .get(),
    );
    used.addAll(
      await (_database.selectOnly(_database.customCategories)
            ..addColumns(<Expression<Object>>[_database.customCategories.id])
            ..where(
              _database.customCategories.ownerScope.equals(ownerScope).not(),
            ))
          .map((row) => row.read(_database.customCategories.id)!)
          .get(),
    );
    used.addAll(
      await (_database.selectOnly(_database.storedTransactions)
            ..addColumns(<Expression<Object>>[_database.storedTransactions.id])
            ..where(
              _database.storedTransactions.ownerScope.equals(ownerScope).not(),
            ))
          .map((row) => row.read(_database.storedTransactions.id)!)
          .get(),
    );
    used.addAll(
      await (_database.selectOnly(_database.recurringTransactionRules)
            ..addColumns(<Expression<Object>>[
              _database.recurringTransactionRules.id,
            ])
            ..where(
              _database.recurringTransactionRules.ownerScope
                  .equals(ownerScope)
                  .not(),
            ))
          .map((row) => row.read(_database.recurringTransactionRules.id)!)
          .get(),
    );
    used.addAll(
      await (_database.selectOnly(_database.recurringTransactionOccurrences)
            ..addColumns(<Expression<Object>>[
              _database.recurringTransactionOccurrences.id,
            ])
            ..where(
              _database.recurringTransactionOccurrences.ownerScope
                  .equals(ownerScope)
                  .not(),
            ))
          .map((row) => row.read(_database.recurringTransactionOccurrences.id)!)
          .get(),
    );

    final Map<String, String> transactionIds = _allocate(
      snapshot.transactions.map((value) => value.id),
      used,
    );
    final Map<String, String> ruleIds = _allocate(
      snapshot.recurringRules.map((value) => value.id),
      used,
    );
    final Map<String, String> occurrenceIds = _allocate(
      snapshot.recurringOccurrences.map((value) => value.id),
      used,
    );
    final Map<String, String> transferIds = _allocate(
      snapshot.transfers.map((value) => value.id),
      used,
    );
    final Map<String, String> categoryIds = _allocate(
      snapshot.customCategories.map((value) => value.id),
      used,
    );
    return _RestoreIds(
      transactions: transactionIds,
      rules: ruleIds,
      occurrences: occurrenceIds,
      transfers: transferIds,
      categories: categoryIds,
    );
  }

  Map<String, String> _allocate(
    Iterable<String> requestedIds,
    Set<String> used,
  ) {
    final Map<String, String> result = <String, String>{};
    for (final String requested in requestedIds) {
      String candidate = requested;
      int suffix = 1;
      while (used.contains(candidate)) {
        candidate = '$requested-restored-${suffix++}';
      }
      used.add(candidate);
      result[requested] = candidate;
    }
    return result;
  }

  FinancialTransaction _transactionWithId(
    FinancialTransaction value,
    String id,
    Map<String, String> categoryIds,
  ) => FinancialTransaction(
    id: id,
    type: value.type,
    amount: value.amount,
    category: _categoryWithIds(value.category, categoryIds),
    paymentMethod: value.paymentMethod,
    occurredAt: value.occurredAt,
    merchant: value.merchant,
    note: value.note,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
  );

  FinancialTransfer _transferWithId(
    FinancialTransfer value,
    String id,
    Map<String, String> categoryIds,
  ) => FinancialTransfer(
    id: id,
    amount: value.amount,
    source: value.source,
    destination: value.destination,
    destinationName: value.destinationName,
    countsAsExpense: value.countsAsExpense,
    expenseCategory: value.expenseCategory == null
        ? null
        : _categoryWithIds(value.expenseCategory!, categoryIds),
    fee: value.fee,
    occurredAt: value.occurredAt,
    note: value.note,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
  );

  domain.RecurringTransactionRule _ruleWithId(
    domain.RecurringTransactionRule value,
    String id,
    Map<String, String> categoryIds,
  ) => domain.RecurringTransactionRule(
    id: id,
    type: value.type,
    amount: value.amount,
    category: _categoryWithIds(value.category, categoryIds),
    paymentMethod: value.paymentMethod,
    merchant: value.merchant,
    note: value.note,
    frequency: value.frequency,
    recurrenceCalendar: value.recurrenceCalendar,
    anchorDay: value.anchorDay,
    anchorMonth: value.anchorMonth,
    anchorWeekday: value.anchorWeekday,
    firstDueDateAd: value.firstDueDateAd,
    nextDueDateAd: value.nextDueDateAd,
    status: value.status,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
    pausedAt: value.pausedAt,
    deletedAt: value.deletedAt,
  );

  domain.RecurringTransactionOccurrence _occurrenceWithIds(
    domain.RecurringTransactionOccurrence value, {
    required String id,
    required String ruleId,
    required String? recordedTransactionId,
    required Map<String, String> categoryIds,
  }) => domain.RecurringTransactionOccurrence(
    id: id,
    ruleId: ruleId,
    dueDateAd: value.dueDateAd,
    status: value.status,
    type: value.type,
    amount: value.amount,
    category: _categoryWithIds(value.category, categoryIds),
    paymentMethod: value.paymentMethod,
    merchant: value.merchant,
    note: value.note,
    recordedTransactionId: recordedTransactionId,
    handledAt: value.handledAt,
    createdAt: value.createdAt,
  );

  TransactionCategory _categoryWithIds(
    TransactionCategory value,
    Map<String, String> categoryIds,
  ) {
    if (value.isSystem) return value;
    return TransactionCategory.custom(
      categoryIds[value.name]!,
      type: value.supports(TransactionType.expense)
          ? TransactionType.expense
          : TransactionType.income,
    );
  }

  CustomCategory _customCategoryFromRow(db.CustomCategory row) =>
      CustomCategory(
        id: row.id,
        type: TransactionDatabaseMapper.typeFromKey(row.typeKey),
        name: row.name,
        normalizedName: row.normalizedName,
        iconKey: row.iconKey,
        isArchived: row.isArchived,
        createdAt: DateTime.fromMicrosecondsSinceEpoch(
          row.createdAtUtcMicros,
          isUtc: true,
        ),
        updatedAt: DateTime.fromMicrosecondsSinceEpoch(
          row.updatedAtUtcMicros,
          isUtc: true,
        ),
      );
}

final class _RestoreIds {
  const _RestoreIds({
    required this.transactions,
    required this.rules,
    required this.occurrences,
    required this.transfers,
    required this.categories,
  });

  final Map<String, String> transactions;
  final Map<String, String> rules;
  final Map<String, String> occurrences;
  final Map<String, String> transfers;
  final Map<String, String> categories;
}

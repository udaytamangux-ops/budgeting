import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/app_database.dart' as db;
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/recurring/data/database/recurring_database_mapper.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart'
    as domain;
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart'
    as domain;
import 'package:budgeting_app/features/recurring/domain/repositories/recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurring_date_service.dart';
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:drift/drift.dart';

final class DriftRecurringTransactionRepository
    implements RecurringTransactionRepository {
  const DriftRecurringTransactionRepository(
    this._database,
    this._recurrenceService, {
    this.ownerScope = OwnerScopes.guest,
  });

  final db.AppDatabase _database;
  final RecurrenceService _recurrenceService;
  static const RecurringDateService _dateService = RecurringDateService();
  final String ownerScope;

  @override
  Stream<List<domain.RecurringTransactionRule>> watchRules() {
    return _database.watchRecurringRulesForOwner(ownerScope).map((rows) {
      final List<domain.RecurringTransactionRule> rules =
          rows
              .map(RecurringDatabaseMapper.ruleFromRow)
              .whereType<domain.RecurringTransactionRule>()
              .where(
                (domain.RecurringTransactionRule rule) =>
                    rule.status != RecurringRuleStatus.deleted,
              )
              .toList(growable: false)
            ..sort((a, b) {
              final int status = a.status.index.compareTo(b.status.index);
              return status != 0
                  ? status
                  : a.nextDueDateAd.compareTo(b.nextDueDateAd);
            });
      return rules;
    });
  }

  @override
  Stream<List<domain.RecurringTransactionOccurrence>>
  watchPendingOccurrences() {
    return _database.watchRecurringOccurrencesForOwner(ownerScope).map((rows) {
      return rows
          .map(RecurringDatabaseMapper.occurrenceFromRow)
          .whereType<domain.RecurringTransactionOccurrence>()
          .where(
            (domain.RecurringTransactionOccurrence occurrence) =>
                occurrence.status == RecurringOccurrenceStatus.pending,
          )
          .toList(growable: false);
    });
  }

  @override
  Future<domain.RecurringTransactionRule?> getRuleById(String ruleId) async {
    final db.RecurringTransactionRule? row = await _database.findRecurringRule(
      ruleId,
      ownerScope: ownerScope,
    );
    return row == null ? null : RecurringDatabaseMapper.ruleFromRow(row);
  }

  @override
  Future<domain.RecurringTransactionOccurrence?> getOccurrenceById(
    String occurrenceId,
  ) async {
    final db.RecurringTransactionOccurrence? row = await _database
        .findRecurringOccurrence(occurrenceId, ownerScope: ownerScope);
    return row == null ? null : RecurringDatabaseMapper.occurrenceFromRow(row);
  }

  @override
  Future<void> createRule(domain.RecurringTransactionRule rule) async {
    try {
      if (await _database.findRecurringRule(rule.id, ownerScope: ownerScope) !=
          null) {
        throw const RecurringRepositoryException(
          'This recurring schedule has already been saved.',
        );
      }
      await _database
          .into(_database.recurringTransactionRules)
          .insert(
            RecurringDatabaseMapper.ruleToCompanion(
              rule,
              ownerScope: ownerScope,
            ),
          );
    } on AppException {
      rethrow;
    } catch (error) {
      throw RecurringRepositoryException(
        'The recurring schedule could not be saved. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> updateRule(domain.RecurringTransactionRule rule) async {
    try {
      final int updated =
          await (_database.update(_database.recurringTransactionRules)..where(
                (db.RecurringTransactionRules table) =>
                    table.id.equals(rule.id) &
                    table.ownerScope.equals(ownerScope),
              ))
              .write(
                RecurringDatabaseMapper.ruleToCompanion(
                  rule,
                  ownerScope: ownerScope,
                ),
              );
      if (updated == 0) {
        throw const RecurringRepositoryException(
          'This recurring schedule is no longer available.',
        );
      }
    } on AppException {
      rethrow;
    } catch (error) {
      throw RecurringRepositoryException(
        'The recurring schedule could not be updated. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> reconcileThrough({
    required DateTime today,
    required DateTime handledAt,
  }) async {
    final DateTime canonicalToday = _dateService.canonicalLocalNoon(today);
    try {
      await _database.transaction(() async {
        final List<db.RecurringTransactionRule> rows =
            await (_database.select(_database.recurringTransactionRules)..where(
                  (db.RecurringTransactionRules table) =>
                      table.ownerScope.equals(ownerScope) &
                      table.statusKey.equals(
                        RecurringRuleStatus.active.stableIdentifier,
                      ),
                ))
                .get();
        for (final db.RecurringTransactionRule row in rows) {
          final domain.RecurringTransactionRule? rule =
              RecurringDatabaseMapper.ruleFromRow(row);
          if (rule == null) {
            continue;
          }
          try {
            _recurrenceService.validateRule(rule);
            await _reconcileRule(
              rule,
              through: canonicalToday,
              handledAt: handledAt,
            );
          } on FormatException {
            continue;
          } on RangeError {
            continue;
          }
        }
      });
    } catch (error) {
      throw RecurringRepositoryException(
        'Scheduled transactions could not be refreshed. Try again.',
        cause: error,
      );
    }
  }

  Future<void> _reconcileRule(
    domain.RecurringTransactionRule rule, {
    required DateTime through,
    required DateTime handledAt,
  }) async {
    DateTime candidate = _dateService.canonicalLocalNoon(rule.nextDueDateAd);
    int generated = 0;
    RecurringRuleStatus status = rule.status;
    DateTime? pausedAt = rule.pausedAt;
    while (!candidate.isAfter(through)) {
      final domain.RecurringTransactionOccurrence occurrence =
          domain.RecurringTransactionOccurrence(
            id: 'occ-${rule.id}-${candidate.microsecondsSinceEpoch}',
            ruleId: rule.id,
            dueDateAd: candidate,
            status: RecurringOccurrenceStatus.pending,
            type: rule.type,
            amount: rule.amount,
            category: rule.category,
            paymentMethod: rule.paymentMethod,
            merchant: rule.merchant,
            note: rule.note,
            createdAt: handledAt.toUtc(),
          );
      await _database
          .into(_database.recurringTransactionOccurrences)
          .insert(
            RecurringDatabaseMapper.occurrenceToCompanion(
              occurrence,
              ownerScope: ownerScope,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      generated += 1;
      if (generated > 1000) {
        throw const FormatException(
          'The recurring schedule contains too many missed dates.',
        );
      }
      try {
        final DateTime next = _recurrenceService.nextOccurrence(
          rule,
          candidate,
        );
        if (!next.isAfter(candidate)) {
          throw const FormatException('The recurring schedule cannot advance.');
        }
        candidate = next;
      } on RecurrenceRangeException {
        status = RecurringRuleStatus.paused;
        pausedAt = handledAt.toUtc();
        break;
      }
    }
    if (generated == 0) {
      return;
    }
    await (_database.update(_database.recurringTransactionRules)..where(
          (db.RecurringTransactionRules table) =>
              table.id.equals(rule.id) & table.ownerScope.equals(ownerScope),
        ))
        .write(
          db.RecurringTransactionRulesCompanion(
            nextDueDateAdUtcMicros: Value<int>(
              candidate.toUtc().microsecondsSinceEpoch,
            ),
            statusKey: Value<String>(status.stableIdentifier),
            pausedAtUtcMicros: Value<int?>(
              pausedAt?.toUtc().microsecondsSinceEpoch,
            ),
            updatedAtUtcMicros: Value<int>(
              handledAt.toUtc().microsecondsSinceEpoch,
            ),
          ),
        );
  }

  @override
  Future<void> recordOccurrence({
    required String occurrenceId,
    required FinancialTransaction transaction,
  }) async {
    try {
      await _database.transaction(() async {
        final db.RecurringTransactionOccurrence? occurrence = await _database
            .findRecurringOccurrence(occurrenceId, ownerScope: ownerScope);
        if (occurrence == null ||
            occurrence.statusKey !=
                RecurringOccurrenceStatus.pending.stableIdentifier) {
          throw const RecurringRepositoryException(
            'This scheduled occurrence is no longer waiting.',
          );
        }
        final db.StoredTransaction? duplicate = await _database
            .findStoredTransaction(transaction.id, ownerScope: ownerScope);
        if (duplicate != null) {
          throw const RecurringRepositoryException(
            'This transaction has already been saved.',
          );
        }
        await _database
            .into(_database.storedTransactions)
            .insert(
              TransactionDatabaseMapper.toCompanion(
                transaction,
                ownerScope: ownerScope,
              ),
            );
        final int updated =
            await (_database.update(_database.recurringTransactionOccurrences)
                  ..where(
                    (db.RecurringTransactionOccurrences table) =>
                        table.id.equals(occurrenceId) &
                        table.ownerScope.equals(ownerScope) &
                        table.statusKey.equals(
                          RecurringOccurrenceStatus.pending.stableIdentifier,
                        ),
                  ))
                .write(
                  db.RecurringTransactionOccurrencesCompanion(
                    statusKey: Value<String>(
                      RecurringOccurrenceStatus.recorded.stableIdentifier,
                    ),
                    recordedTransactionId: Value<String>(transaction.id),
                    handledAtUtcMicros: Value<int>(
                      transaction.createdAt.toUtc().microsecondsSinceEpoch,
                    ),
                  ),
                );
        if (updated != 1) {
          throw const RecurringRepositoryException(
            'This scheduled occurrence is no longer waiting.',
          );
        }
      });
    } on AppException {
      rethrow;
    } catch (error) {
      throw RecurringRepositoryException(
        'The scheduled transaction could not be recorded. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> skipOccurrence(
    String occurrenceId, {
    required DateTime now,
  }) async {
    try {
      final int updated =
          await (_database.update(_database.recurringTransactionOccurrences)
                ..where(
                  (db.RecurringTransactionOccurrences table) =>
                      table.id.equals(occurrenceId) &
                      table.ownerScope.equals(ownerScope) &
                      table.statusKey.equals(
                        RecurringOccurrenceStatus.pending.stableIdentifier,
                      ),
                ))
              .write(
                db.RecurringTransactionOccurrencesCompanion(
                  statusKey: Value<String>(
                    RecurringOccurrenceStatus.skipped.stableIdentifier,
                  ),
                  handledAtUtcMicros: Value<int>(
                    now.toUtc().microsecondsSinceEpoch,
                  ),
                ),
              );
      if (updated != 1) {
        throw const RecurringRepositoryException(
          'This scheduled occurrence is no longer waiting.',
        );
      }
    } on AppException {
      rethrow;
    } catch (error) {
      throw RecurringRepositoryException(
        'The scheduled occurrence could not be skipped. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> pauseRule(String ruleId, {required DateTime now}) async {
    await _setRuleStatus(
      ruleId,
      status: RecurringRuleStatus.paused,
      now: now,
      pausedAt: now,
    );
  }

  @override
  Future<void> resumeRule(
    String ruleId, {
    required DateTime resumeDate,
    required DateTime now,
  }) async {
    try {
      final domain.RecurringTransactionRule? rule = await getRuleById(ruleId);
      if (rule == null || rule.status != RecurringRuleStatus.paused) {
        throw const RecurringRepositoryException(
          'This recurring schedule is no longer paused.',
        );
      }
      final DateTime next = _recurrenceService.nextOccurrenceOnOrAfter(
        rule,
        resumeDate,
      );
      await updateRule(
        rule.copyWith(
          status: RecurringRuleStatus.active,
          nextDueDateAd: next,
          updatedAt: now.toUtc(),
          pausedAt: null,
        ),
      );
    } on AppException {
      rethrow;
    } on RecurrenceRangeException catch (error) {
      throw RecurringRepositoryException(error.message, cause: error);
    }
  }

  @override
  Future<void> deleteRule(String ruleId, {required DateTime now}) async {
    try {
      await _database.transaction(() async {
        final int updated =
            await (_database.update(_database.recurringTransactionRules)..where(
                  (db.RecurringTransactionRules table) =>
                      table.id.equals(ruleId) &
                      table.ownerScope.equals(ownerScope) &
                      table.statusKey.isNotValue(
                        RecurringRuleStatus.deleted.stableIdentifier,
                      ),
                ))
                .write(
                  db.RecurringTransactionRulesCompanion(
                    statusKey: Value<String>(
                      RecurringRuleStatus.deleted.stableIdentifier,
                    ),
                    deletedAtUtcMicros: Value<int>(
                      now.toUtc().microsecondsSinceEpoch,
                    ),
                    updatedAtUtcMicros: Value<int>(
                      now.toUtc().microsecondsSinceEpoch,
                    ),
                  ),
                );
        if (updated != 1) {
          throw const RecurringRepositoryException(
            'This recurring schedule is no longer available.',
          );
        }
        await (_database.update(_database.recurringTransactionOccurrences)
              ..where(
                (db.RecurringTransactionOccurrences table) =>
                    table.ruleId.equals(ruleId) &
                    table.ownerScope.equals(ownerScope) &
                    table.statusKey.equals(
                      RecurringOccurrenceStatus.pending.stableIdentifier,
                    ),
              ))
            .write(
              db.RecurringTransactionOccurrencesCompanion(
                statusKey: Value<String>(
                  RecurringOccurrenceStatus.skipped.stableIdentifier,
                ),
                handledAtUtcMicros: Value<int>(
                  now.toUtc().microsecondsSinceEpoch,
                ),
              ),
            );
      });
    } on AppException {
      rethrow;
    } catch (error) {
      throw RecurringRepositoryException(
        'The recurring schedule could not be deleted. Try again.',
        cause: error,
      );
    }
  }

  Future<void> _setRuleStatus(
    String ruleId, {
    required RecurringRuleStatus status,
    required DateTime now,
    DateTime? pausedAt,
  }) async {
    try {
      final int updated =
          await (_database.update(_database.recurringTransactionRules)..where(
                (db.RecurringTransactionRules table) =>
                    table.id.equals(ruleId) &
                    table.ownerScope.equals(ownerScope) &
                    table.statusKey.isNotValue(
                      RecurringRuleStatus.deleted.stableIdentifier,
                    ),
              ))
              .write(
                db.RecurringTransactionRulesCompanion(
                  statusKey: Value<String>(status.stableIdentifier),
                  pausedAtUtcMicros: Value<int?>(
                    pausedAt?.toUtc().microsecondsSinceEpoch,
                  ),
                  updatedAtUtcMicros: Value<int>(
                    now.toUtc().microsecondsSinceEpoch,
                  ),
                ),
              );
      if (updated != 1) {
        throw const RecurringRepositoryException(
          'This recurring schedule is no longer available.',
        );
      }
    } on AppException {
      rethrow;
    } catch (error) {
      throw RecurringRepositoryException(
        'The recurring schedule could not be updated. Try again.',
        cause: error,
      );
    }
  }
}

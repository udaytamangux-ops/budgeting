import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/database/app_database.dart' as db;
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart'
    as domain;
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart'
    as domain;
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:drift/drift.dart';

abstract final class RecurringDatabaseMapper {
  static db.RecurringTransactionRulesCompanion ruleToCompanion(
    domain.RecurringTransactionRule rule, {
    required String ownerScope,
  }) {
    return db.RecurringTransactionRulesCompanion(
      id: Value<String>(rule.id),
      ownerScope: Value<String>(ownerScope),
      typeKey: Value<String>(TransactionDatabaseMapper.typeToKey(rule.type)),
      amountMinorUnits: Value<int>(rule.amount.minorUnits),
      currencyCode: Value<String>(rule.amount.currencyCode),
      categoryKey: Value<String>(
        TransactionDatabaseMapper.categoryToKey(rule.category),
      ),
      paymentMethodKey: Value<String>(
        TransactionDatabaseMapper.paymentMethodToKey(rule.paymentMethod),
      ),
      merchant: Value<String?>(rule.merchant),
      note: Value<String?>(rule.note),
      frequencyKey: Value<String>(rule.frequency.stableIdentifier),
      recurrenceCalendarKey: Value<String>(
        rule.recurrenceCalendar.storageValue,
      ),
      anchorDay: Value<int>(rule.anchorDay),
      anchorMonth: Value<int>(rule.anchorMonth),
      anchorWeekday: Value<int>(rule.anchorWeekday),
      firstDueDateAdUtcMicros: Value<int>(
        rule.firstDueDateAd.toUtc().microsecondsSinceEpoch,
      ),
      nextDueDateAdUtcMicros: Value<int>(
        rule.nextDueDateAd.toUtc().microsecondsSinceEpoch,
      ),
      statusKey: Value<String>(rule.status.stableIdentifier),
      createdAtUtcMicros: Value<int>(
        rule.createdAt.toUtc().microsecondsSinceEpoch,
      ),
      updatedAtUtcMicros: Value<int>(
        rule.updatedAt.toUtc().microsecondsSinceEpoch,
      ),
      pausedAtUtcMicros: Value<int?>(
        rule.pausedAt?.toUtc().microsecondsSinceEpoch,
      ),
      deletedAtUtcMicros: Value<int?>(
        rule.deletedAt?.toUtc().microsecondsSinceEpoch,
      ),
    );
  }

  static domain.RecurringTransactionRule? ruleFromRow(
    db.RecurringTransactionRule row,
  ) {
    final RecurringFrequency? frequency = RecurringFrequencyMetadata.tryParse(
      row.frequencyKey,
    );
    final RecurringRuleStatus? status = RecurringRuleStatusMetadata.tryParse(
      row.statusKey,
    );
    final AppCalendarSystem? calendar = RecurrenceCalendarCodec.tryParse(
      row.recurrenceCalendarKey,
    );
    if (frequency == null || status == null || calendar == null) {
      return null;
    }
    try {
      final type = TransactionDatabaseMapper.typeFromKey(row.typeKey);
      return domain.RecurringTransactionRule(
        id: row.id,
        type: type,
        amount: Money(
          minorUnits: row.amountMinorUnits,
          currencyCode: row.currencyCode,
        ),
        category: TransactionDatabaseMapper.categoryFromKey(
          row.categoryKey,
          type: type,
        ),
        paymentMethod: TransactionDatabaseMapper.paymentMethodFromKey(
          row.paymentMethodKey,
        ),
        merchant: row.merchant,
        note: row.note,
        frequency: frequency,
        recurrenceCalendar: calendar,
        anchorDay: row.anchorDay,
        anchorMonth: row.anchorMonth,
        anchorWeekday: row.anchorWeekday,
        firstDueDateAd: _date(row.firstDueDateAdUtcMicros),
        nextDueDateAd: _date(row.nextDueDateAdUtcMicros),
        status: status,
        createdAt: _date(row.createdAtUtcMicros),
        updatedAt: _date(row.updatedAtUtcMicros),
        pausedAt: _nullableDate(row.pausedAtUtcMicros),
        deletedAt: _nullableDate(row.deletedAtUtcMicros),
      );
    } on FormatException {
      return null;
    }
  }

  static db.RecurringTransactionOccurrencesCompanion occurrenceToCompanion(
    domain.RecurringTransactionOccurrence occurrence, {
    required String ownerScope,
  }) {
    return db.RecurringTransactionOccurrencesCompanion(
      id: Value<String>(occurrence.id),
      ruleId: Value<String>(occurrence.ruleId),
      ownerScope: Value<String>(ownerScope),
      dueDateAdUtcMicros: Value<int>(
        occurrence.dueDateAd.toUtc().microsecondsSinceEpoch,
      ),
      statusKey: Value<String>(occurrence.status.stableIdentifier),
      typeKey: Value<String>(
        TransactionDatabaseMapper.typeToKey(occurrence.type),
      ),
      amountMinorUnits: Value<int>(occurrence.amount.minorUnits),
      currencyCode: Value<String>(occurrence.amount.currencyCode),
      categoryKey: Value<String>(
        TransactionDatabaseMapper.categoryToKey(occurrence.category),
      ),
      paymentMethodKey: Value<String>(
        TransactionDatabaseMapper.paymentMethodToKey(occurrence.paymentMethod),
      ),
      merchant: Value<String?>(occurrence.merchant),
      note: Value<String?>(occurrence.note),
      recordedTransactionId: Value<String?>(occurrence.recordedTransactionId),
      handledAtUtcMicros: Value<int?>(
        occurrence.handledAt?.toUtc().microsecondsSinceEpoch,
      ),
      createdAtUtcMicros: Value<int>(
        occurrence.createdAt.toUtc().microsecondsSinceEpoch,
      ),
    );
  }

  static domain.RecurringTransactionOccurrence? occurrenceFromRow(
    db.RecurringTransactionOccurrence row,
  ) {
    final RecurringOccurrenceStatus? status =
        RecurringOccurrenceStatusMetadata.tryParse(row.statusKey);
    if (status == null) {
      return null;
    }
    try {
      final type = TransactionDatabaseMapper.typeFromKey(row.typeKey);
      return domain.RecurringTransactionOccurrence(
        id: row.id,
        ruleId: row.ruleId,
        dueDateAd: _date(row.dueDateAdUtcMicros),
        status: status,
        type: type,
        amount: Money(
          minorUnits: row.amountMinorUnits,
          currencyCode: row.currencyCode,
        ),
        category: TransactionDatabaseMapper.categoryFromKey(
          row.categoryKey,
          type: type,
        ),
        paymentMethod: TransactionDatabaseMapper.paymentMethodFromKey(
          row.paymentMethodKey,
        ),
        merchant: row.merchant,
        note: row.note,
        recordedTransactionId: row.recordedTransactionId,
        handledAt: _nullableDate(row.handledAtUtcMicros),
        createdAt: _date(row.createdAtUtcMicros),
      );
    } on FormatException {
      return null;
    }
  }

  static DateTime _date(int micros) =>
      DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);

  static DateTime? _nullableDate(int? micros) =>
      micros == null ? null : _date(micros);
}

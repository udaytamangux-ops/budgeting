import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/database/app_database.dart' as db;
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:drift/drift.dart';

abstract final class MoneyPlanDatabaseMapper {
  static MoneyPlanPreference preferenceFromRow(db.MoneyPlanPreference row) =>
      MoneyPlanPreference(
        isEnabled: row.isEnabled,
        createdAt: _timestamp(row.createdAtUtcMicros),
        updatedAt: _timestamp(row.updatedAtUtcMicros),
      );

  static db.MoneyPlanPreferencesCompanion preferenceToCompanion(
    MoneyPlanPreference value, {
    required String ownerScope,
  }) => db.MoneyPlanPreferencesCompanion(
    ownerScope: Value<String>(ownerScope),
    isEnabled: Value<bool>(value.isEnabled),
    createdAtUtcMicros: Value<int>(value.createdAt.microsecondsSinceEpoch),
    updatedAtUtcMicros: Value<int>(value.updatedAt.microsecondsSinceEpoch),
  );

  static MoneyPlanPeriod periodFromRow(db.MoneyPlanPeriod row) {
    final AppCalendarSystem calendar = calendarFromKey(row.calendarSystemKey);
    return MoneyPlanPeriod(
      id: row.id,
      period: CalendarPeriod(
        calendarSystem: calendar,
        year: row.calendarYear,
        month: row.calendarMonth,
        startAdInclusive: _timestamp(row.periodStartUtcMicros),
        endAdExclusive: _timestamp(row.periodEndExclusiveUtcMicros),
        displayLabel:
            '${calendar.shortLabel} ${row.calendarYear}-${row.calendarMonth}',
      ),
      ratios: MoneyPlanRatios(
        needsPercent: row.needsPercent,
        wantsPercent: row.wantsPercent,
        savingsPercent: row.savingsPercent,
      ),
      createdAt: _timestamp(row.createdAtUtcMicros),
      updatedAt: _timestamp(row.updatedAtUtcMicros),
    );
  }

  static db.MoneyPlanPeriodsCompanion periodToCompanion(
    MoneyPlanPeriod value, {
    required String ownerScope,
  }) => db.MoneyPlanPeriodsCompanion(
    id: Value<String>(value.id),
    ownerScope: Value<String>(ownerScope),
    periodStartUtcMicros: Value<int>(
      value.period.startAdInclusive.microsecondsSinceEpoch,
    ),
    periodEndExclusiveUtcMicros: Value<int>(
      value.period.endAdExclusive.microsecondsSinceEpoch,
    ),
    calendarSystemKey: Value<String>(value.period.calendarSystem.storageValue),
    calendarYear: Value<int>(value.period.year),
    calendarMonth: Value<int>(value.period.month),
    needsPercent: Value<int>(value.ratios.needsPercent),
    wantsPercent: Value<int>(value.ratios.wantsPercent),
    savingsPercent: Value<int>(value.ratios.savingsPercent),
    createdAtUtcMicros: Value<int>(value.createdAt.microsecondsSinceEpoch),
    updatedAtUtcMicros: Value<int>(value.updatedAt.microsecondsSinceEpoch),
  );

  static MoneyPlanCategoryMapping mappingFromRow(
    db.MoneyPlanCategoryMapping row,
  ) => MoneyPlanCategoryMapping(
    id: row.id,
    periodId: row.periodId,
    categoryId: row.categoryId,
    group: groupFromKey(row.planGroupKey),
    createdAt: _timestamp(row.createdAtUtcMicros),
    updatedAt: _timestamp(row.updatedAtUtcMicros),
  );

  static db.MoneyPlanCategoryMappingsCompanion mappingToCompanion(
    MoneyPlanCategoryMapping value, {
    required String ownerScope,
  }) => db.MoneyPlanCategoryMappingsCompanion(
    id: Value<String>(value.id),
    ownerScope: Value<String>(ownerScope),
    periodId: Value<String>(value.periodId),
    categoryId: Value<String>(value.categoryId),
    planGroupKey: Value<String>(value.group.storageValue),
    createdAtUtcMicros: Value<int>(value.createdAt.microsecondsSinceEpoch),
    updatedAtUtcMicros: Value<int>(value.updatedAt.microsecondsSinceEpoch),
  );

  static AppCalendarSystem calendarFromKey(String key) {
    for (final AppCalendarSystem value in AppCalendarSystem.values) {
      if (value.storageValue == key) return value;
    }
    throw const FormatException('Unsupported Money Plan calendar.');
  }

  static MoneyPlanGroup groupFromKey(String key) {
    final MoneyPlanGroup? group = MoneyPlanGroupMetadata.tryParse(key);
    if (group == null || group == MoneyPlanGroup.unassigned) {
      throw const FormatException('Unsupported stored Money Plan group.');
    }
    return group;
  }

  static DateTime _timestamp(int micros) =>
      DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);
}

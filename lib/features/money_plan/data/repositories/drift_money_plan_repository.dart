import 'dart:math';

import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/app_database.dart' as db;
import 'package:budgeting_app/features/money_plan/data/database/money_plan_database_mapper.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/domain/repositories/money_plan_repository.dart';
import 'package:drift/drift.dart';

final class DriftMoneyPlanRepository implements MoneyPlanRepository {
  DriftMoneyPlanRepository(
    this._database, {
    this.ownerScope = OwnerScopes.guest,
    DateTime Function()? now,
    String Function()? createId,
  }) : _now = now ?? DateTime.now,
       _createId = createId ?? _newId;

  final db.AppDatabase _database;
  final String ownerScope;
  final DateTime Function() _now;
  final String Function() _createId;

  @override
  Stream<MoneyPlanPreference?> watchPreference() =>
      (_database.select(_database.moneyPlanPreferences)..where(
            (db.MoneyPlanPreferences table) =>
                table.ownerScope.equals(ownerScope),
          ))
          .watchSingleOrNull()
          .map(
            (db.MoneyPlanPreference? row) => row == null
                ? null
                : MoneyPlanDatabaseMapper.preferenceFromRow(row),
          );

  @override
  Future<MoneyPlanPreference?> getPreference() async {
    final db.MoneyPlanPreference? row =
        await (_database.select(_database.moneyPlanPreferences)..where(
              (db.MoneyPlanPreferences table) =>
                  table.ownerScope.equals(ownerScope),
            ))
            .getSingleOrNull();
    return row == null ? null : MoneyPlanDatabaseMapper.preferenceFromRow(row);
  }

  @override
  Stream<List<MoneyPlanPeriod>> watchPeriods() =>
      (_database.select(_database.moneyPlanPeriods)
            ..where(
              (db.MoneyPlanPeriods table) =>
                  table.ownerScope.equals(ownerScope),
            )
            ..orderBy(<OrderingTerm Function(db.MoneyPlanPeriods)>[
              (db.MoneyPlanPeriods table) =>
                  OrderingTerm.asc(table.periodStartUtcMicros),
            ]))
          .watch()
          .map(
            (List<db.MoneyPlanPeriod> rows) =>
                List<MoneyPlanPeriod>.unmodifiable(
                  rows.map(MoneyPlanDatabaseMapper.periodFromRow),
                ),
          );

  @override
  Future<List<MoneyPlanPeriod>> getPeriods() async =>
      (await (_database.select(_database.moneyPlanPeriods)
                ..where(
                  (db.MoneyPlanPeriods table) =>
                      table.ownerScope.equals(ownerScope),
                )
                ..orderBy(<OrderingTerm Function(db.MoneyPlanPeriods)>[
                  (db.MoneyPlanPeriods table) =>
                      OrderingTerm.asc(table.periodStartUtcMicros),
                ]))
              .get())
          .map(MoneyPlanDatabaseMapper.periodFromRow)
          .toList(growable: false);

  @override
  Stream<MoneyPlanPeriod?> watchPeriod(CalendarPeriod period) =>
      (_database.select(_database.moneyPlanPeriods)..where(
            (db.MoneyPlanPeriods table) =>
                table.ownerScope.equals(ownerScope) &
                table.calendarSystemKey.equals(
                  period.calendarSystem.storageValue,
                ) &
                table.calendarYear.equals(period.year) &
                table.calendarMonth.equals(period.month),
          ))
          .watchSingleOrNull()
          .map(
            (db.MoneyPlanPeriod? row) =>
                row == null ? null : MoneyPlanDatabaseMapper.periodFromRow(row),
          );

  @override
  Future<MoneyPlanPeriod?> getPeriod(CalendarPeriod period) async {
    final db.MoneyPlanPeriod? row =
        await (_database.select(_database.moneyPlanPeriods)..where(
              (db.MoneyPlanPeriods table) =>
                  table.ownerScope.equals(ownerScope) &
                  table.calendarSystemKey.equals(
                    period.calendarSystem.storageValue,
                  ) &
                  table.calendarYear.equals(period.year) &
                  table.calendarMonth.equals(period.month),
            ))
            .getSingleOrNull();
    return row == null ? null : MoneyPlanDatabaseMapper.periodFromRow(row);
  }

  @override
  Stream<List<MoneyPlanCategoryMapping>> watchMappings(String periodId) =>
      (_database.select(_database.moneyPlanCategoryMappings)..where(
            (db.MoneyPlanCategoryMappings table) =>
                table.ownerScope.equals(ownerScope) &
                table.periodId.equals(periodId),
          ))
          .watch()
          .map(
            (List<db.MoneyPlanCategoryMapping> rows) =>
                List<MoneyPlanCategoryMapping>.unmodifiable(
                  rows.map(MoneyPlanDatabaseMapper.mappingFromRow),
                ),
          );

  @override
  Future<List<MoneyPlanCategoryMapping>> getMappings(String periodId) async =>
      (await (_database.select(_database.moneyPlanCategoryMappings)..where(
                (db.MoneyPlanCategoryMappings table) =>
                    table.ownerScope.equals(ownerScope) &
                    table.periodId.equals(periodId),
              ))
              .get())
          .map(MoneyPlanDatabaseMapper.mappingFromRow)
          .toList(growable: false);

  @override
  Future<MoneyPlanPeriod> createOrUpdateCurrentPlan({
    required CalendarPeriod period,
    required MoneyPlanRatios ratios,
    required Map<String, MoneyPlanGroup> categoryGroups,
  }) async {
    _requireCurrent(period);
    try {
      return await _database.transaction(() async {
        final DateTime now = _now().toUtc();
        final MoneyPlanPeriod? existing = await getPeriod(period);
        final MoneyPlanPeriod saved = MoneyPlanPeriod(
          id: existing?.id ?? _createId(),
          period: period,
          ratios: ratios,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        );
        await _database
            .into(_database.moneyPlanPeriods)
            .insertOnConflictUpdate(
              MoneyPlanDatabaseMapper.periodToCompanion(
                saved,
                ownerScope: ownerScope,
              ),
            );
        await (_database.delete(_database.moneyPlanCategoryMappings)..where(
              (db.MoneyPlanCategoryMappings table) =>
                  table.ownerScope.equals(ownerScope) &
                  table.periodId.equals(saved.id),
            ))
            .go();
        for (final MapEntry<String, MoneyPlanGroup> entry
            in categoryGroups.entries) {
          if (entry.value == MoneyPlanGroup.unassigned) continue;
          final MoneyPlanCategoryMapping mapping = MoneyPlanCategoryMapping(
            id: _createId(),
            periodId: saved.id,
            categoryId: entry.key,
            group: entry.value,
            createdAt: now,
            updatedAt: now,
          );
          await _database
              .into(_database.moneyPlanCategoryMappings)
              .insert(
                MoneyPlanDatabaseMapper.mappingToCompanion(
                  mapping,
                  ownerScope: ownerScope,
                ),
              );
        }
        await _writePreference(enabled: true, now: now);
        return saved;
      });
    } on MoneyPlanException {
      rethrow;
    } catch (error) {
      throw MoneyPlanException(
        'Money Plan could not be saved. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<MoneyPlanPeriod?> carryForwardToCurrent(CalendarPeriod period) async {
    _requireCurrent(period);
    final MoneyPlanPreference? preference = await getPreference();
    if (preference?.isEnabled != true) return null;
    final MoneyPlanPeriod? existing = await getPeriod(period);
    if (existing != null) return existing;
    final List<MoneyPlanPeriod> previous = (await getPeriods())
        .where(
          (MoneyPlanPeriod value) =>
              value.period.startAdInclusive.isBefore(period.startAdInclusive),
        )
        .toList(growable: false);
    if (previous.isEmpty) return null;
    final MoneyPlanPeriod source = previous.last;
    final Map<String, MoneyPlanGroup> groups = <String, MoneyPlanGroup>{
      for (final MoneyPlanCategoryMapping mapping in await getMappings(
        source.id,
      ))
        mapping.categoryId: mapping.group,
    };
    return createOrUpdateCurrentPlan(
      period: period,
      ratios: source.ratios,
      categoryGroups: groups,
    );
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await _writePreference(enabled: enabled, now: _now().toUtc());
    } catch (error) {
      throw MoneyPlanException(
        'Money Plan could not be updated. Try again.',
        cause: error,
      );
    }
  }

  Future<void> _writePreference({
    required bool enabled,
    required DateTime now,
  }) async {
    final MoneyPlanPreference? current = await getPreference();
    final MoneyPlanPreference value = MoneyPlanPreference(
      isEnabled: enabled,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
    await _database
        .into(_database.moneyPlanPreferences)
        .insertOnConflictUpdate(
          MoneyPlanDatabaseMapper.preferenceToCompanion(
            value,
            ownerScope: ownerScope,
          ),
        );
  }

  void _requireCurrent(CalendarPeriod period) {
    if (!period.contains(_now())) {
      throw const MoneyPlanException(
        'Completed Money Plan periods cannot be changed.',
      );
    }
  }

  static String _newId() {
    final Random random = Random.secure();
    String hex(int length) => List<String>.generate(
      length,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return 'money-plan:${hex(8)}-${hex(4)}-${hex(4)}-${hex(4)}-${hex(12)}';
  }
}

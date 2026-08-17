import 'dart:async';

import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/domain/repositories/money_plan_repository.dart';

final class InMemoryMoneyPlanRepository implements MoneyPlanRepository {
  InMemoryMoneyPlanRepository({
    this._preference,
    List<MoneyPlanPeriod> periods = const <MoneyPlanPeriod>[],
    Map<String, List<MoneyPlanCategoryMapping>> mappings =
        const <String, List<MoneyPlanCategoryMapping>>{},
    DateTime Function()? now,
  }) : _periods = List<MoneyPlanPeriod>.from(periods),
       _mappings = <String, List<MoneyPlanCategoryMapping>>{
         for (final entry in mappings.entries)
           entry.key: List<MoneyPlanCategoryMapping>.from(entry.value),
       },
       _now = now ?? DateTime.now;

  MoneyPlanPreference? _preference;
  final List<MoneyPlanPeriod> _periods;
  final Map<String, List<MoneyPlanCategoryMapping>> _mappings;
  final DateTime Function() _now;
  int _id = 0;
  final StreamController<MoneyPlanPreference?> _preferenceChanges =
      StreamController<MoneyPlanPreference?>.broadcast();
  final StreamController<List<MoneyPlanPeriod>> _periodChanges =
      StreamController<List<MoneyPlanPeriod>>.broadcast();
  final Map<String, StreamController<List<MoneyPlanCategoryMapping>>>
  _mappingChanges =
      <String, StreamController<List<MoneyPlanCategoryMapping>>>{};

  @override
  Stream<MoneyPlanPreference?> watchPreference() async* {
    yield _preference;
    yield* _preferenceChanges.stream;
  }

  @override
  Future<MoneyPlanPreference?> getPreference() async => _preference;

  @override
  Stream<List<MoneyPlanPeriod>> watchPeriods() async* {
    yield List<MoneyPlanPeriod>.unmodifiable(_periods);
    yield* _periodChanges.stream;
  }

  @override
  Future<List<MoneyPlanPeriod>> getPeriods() async =>
      List<MoneyPlanPeriod>.unmodifiable(_periods);

  @override
  Stream<MoneyPlanPeriod?> watchPeriod(CalendarPeriod period) async* {
    yield await getPeriod(period);
    await for (final List<MoneyPlanPeriod> values in _periodChanges.stream) {
      yield values.where((value) => value.period == period).firstOrNull;
    }
  }

  @override
  Future<MoneyPlanPeriod?> getPeriod(CalendarPeriod period) async =>
      _periods.where((value) => value.period == period).firstOrNull;

  @override
  Stream<List<MoneyPlanCategoryMapping>> watchMappings(String periodId) async* {
    yield List<MoneyPlanCategoryMapping>.unmodifiable(
      _mappings[periodId] ?? const <MoneyPlanCategoryMapping>[],
    );
    final controller = _mappingChanges.putIfAbsent(
      periodId,
      StreamController<List<MoneyPlanCategoryMapping>>.broadcast,
    );
    yield* controller.stream;
  }

  @override
  Future<List<MoneyPlanCategoryMapping>> getMappings(String periodId) async =>
      List<MoneyPlanCategoryMapping>.unmodifiable(
        _mappings[periodId] ?? const <MoneyPlanCategoryMapping>[],
      );

  @override
  Future<MoneyPlanPeriod> createOrUpdateCurrentPlan({
    required CalendarPeriod period,
    required MoneyPlanRatios ratios,
    required Map<String, MoneyPlanGroup> categoryGroups,
  }) async {
    _requireCurrent(period);
    final DateTime now = _now().toUtc();
    final MoneyPlanPeriod? existing = await getPeriod(period);
    final MoneyPlanPeriod value = MoneyPlanPeriod(
      id: existing?.id ?? 'memory-plan-${_id++}',
      period: period,
      ratios: ratios,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    if (existing == null) {
      _periods.add(value);
      _periods.sort(
        (a, b) =>
            a.period.startAdInclusive.compareTo(b.period.startAdInclusive),
      );
    } else {
      _periods[_periods.indexOf(existing)] = value;
    }
    _mappings[value.id] = <MoneyPlanCategoryMapping>[
      for (final entry in categoryGroups.entries)
        if (entry.value != MoneyPlanGroup.unassigned)
          MoneyPlanCategoryMapping(
            id: 'memory-mapping-${_id++}',
            periodId: value.id,
            categoryId: entry.key,
            group: entry.value,
            createdAt: now,
            updatedAt: now,
          ),
    ];
    _preference = MoneyPlanPreference(
      isEnabled: true,
      createdAt: _preference?.createdAt ?? now,
      updatedAt: now,
    );
    _periodChanges.add(List<MoneyPlanPeriod>.unmodifiable(_periods));
    _mappingChanges[value.id]?.add(
      List<MoneyPlanCategoryMapping>.unmodifiable(_mappings[value.id]!),
    );
    _preferenceChanges.add(_preference);
    return value;
  }

  @override
  Future<MoneyPlanPeriod?> carryForwardToCurrent(CalendarPeriod period) async {
    _requireCurrent(period);
    if (_preference?.isEnabled != true) return null;
    final MoneyPlanPeriod? existing = await getPeriod(period);
    if (existing != null) return existing;
    final List<MoneyPlanPeriod> previous = _periods
        .where(
          (value) =>
              value.period.startAdInclusive.isBefore(period.startAdInclusive),
        )
        .toList(growable: false);
    if (previous.isEmpty) return null;
    final MoneyPlanPeriod source = previous.last;
    return createOrUpdateCurrentPlan(
      period: period,
      ratios: source.ratios,
      categoryGroups: <String, MoneyPlanGroup>{
        for (final mapping in await getMappings(source.id))
          mapping.categoryId: mapping.group,
      },
    );
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    final DateTime now = _now().toUtc();
    _preference = MoneyPlanPreference(
      isEnabled: enabled,
      createdAt: _preference?.createdAt ?? now,
      updatedAt: now,
    );
    _preferenceChanges.add(_preference);
  }

  Future<void> dispose() async {
    await _preferenceChanges.close();
    await _periodChanges.close();
    for (final controller in _mappingChanges.values) {
      await controller.close();
    }
  }

  void _requireCurrent(CalendarPeriod period) {
    if (!period.contains(_now())) {
      throw const MoneyPlanException(
        'Completed Money Plan periods cannot be changed.',
      );
    }
  }
}

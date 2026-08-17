import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/money_plan/data/repositories/drift_money_plan_repository.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late BikramSambatCalendarService calendar;
  int id = 0;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    calendar = BikramSambatCalendarService();
    id = 0;
  });

  tearDown(() => database.close());

  DriftMoneyPlanRepository repository({
    String owner = 'guest',
    DateTime? now,
  }) => DriftMoneyPlanRepository(
    database,
    ownerScope: owner,
    now: () => now ?? DateTime.utc(2026, 8, 15, 12),
    createId: () => 'plan-id-${id++}',
  );

  test('creates, watches, updates and disables an owner-scoped plan', () async {
    final repo = repository();
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final first = await repo.createOrUpdateCurrentPlan(
      period: period,
      ratios: MoneyPlanRatios.defaultPlan,
      categoryGroups: const <String, MoneyPlanGroup>{
        'food': MoneyPlanGroup.needs,
        'shopping': MoneyPlanGroup.wants,
        'other': MoneyPlanGroup.unassigned,
      },
    );
    expect((await repo.getPreference())?.isEnabled, isTrue);
    expect((await repo.getPeriod(period))?.id, first.id);
    expect(await repo.getMappings(first.id), hasLength(2));

    final updated = await repo.createOrUpdateCurrentPlan(
      period: period,
      ratios: MoneyPlanRatios(
        needsPercent: 60,
        wantsPercent: 25,
        savingsPercent: 15,
      ),
      categoryGroups: const <String, MoneyPlanGroup>{
        'food': MoneyPlanGroup.wants,
      },
    );
    expect(updated.id, first.id);
    expect(updated.ratios.needsPercent, 60);
    expect(
      (await repo.getMappings(first.id)).single.group,
      MoneyPlanGroup.wants,
    );

    await repo.setEnabled(false);
    expect((await repo.getPreference())?.isEnabled, isFalse);
    expect(await repo.getPeriod(period), isNotNull);
  });

  test('isolates plans by owner', () async {
    final period = calendar.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    await repository(owner: 'owner-a').createOrUpdateCurrentPlan(
      period: period,
      ratios: MoneyPlanRatios.defaultPlan,
      categoryGroups: const <String, MoneyPlanGroup>{
        'food': MoneyPlanGroup.needs,
      },
    );
    expect(await repository(owner: 'owner-b').getPeriods(), isEmpty);
    expect(await repository(owner: 'owner-b').getPreference(), isNull);
  });

  test(
    'carries ratios and explicit mappings into only the new current period',
    () async {
      final august = calendar.periodFor(
        calendarSystem: AppCalendarSystem.gregorianAd,
        year: 2026,
        month: 8,
      );
      final september = calendar.periodFor(
        calendarSystem: AppCalendarSystem.gregorianAd,
        year: 2026,
        month: 9,
      );
      final augustRepo = repository(now: DateTime.utc(2026, 8, 15, 12));
      final augustPlan = await augustRepo.createOrUpdateCurrentPlan(
        period: august,
        ratios: MoneyPlanRatios(
          needsPercent: 60,
          wantsPercent: 25,
          savingsPercent: 15,
        ),
        categoryGroups: const <String, MoneyPlanGroup>{
          'food': MoneyPlanGroup.needs,
        },
      );

      final septemberRepo = repository(now: DateTime.utc(2026, 9, 10, 12));
      final carried = await septemberRepo.carryForwardToCurrent(september);
      expect(carried?.ratios, augustPlan.ratios);
      expect(await septemberRepo.getMappings(carried!.id), hasLength(1));
      expect((await septemberRepo.getPeriod(august))?.ratios.needsPercent, 60);

      await septemberRepo.createOrUpdateCurrentPlan(
        period: september,
        ratios: MoneyPlanRatios.defaultPlan,
        categoryGroups: const <String, MoneyPlanGroup>{
          'food': MoneyPlanGroup.wants,
        },
      );
      expect((await septemberRepo.getPeriod(august))?.ratios.needsPercent, 60);
      expect(
        (await septemberRepo.getMappings(augustPlan.id)).single.group,
        MoneyPlanGroup.needs,
      );
    },
  );

  test(
    'does not create historical missing periods or edit completed periods',
    () async {
      final repo = repository(now: DateTime.utc(2026, 9, 10, 12));
      final august = calendar.periodFor(
        calendarSystem: AppCalendarSystem.gregorianAd,
        year: 2026,
        month: 8,
      );
      expect(
        () => repo.createOrUpdateCurrentPlan(
          period: august,
          ratios: MoneyPlanRatios.defaultPlan,
          categoryGroups: const <String, MoneyPlanGroup>{},
        ),
        throwsA(isA<MoneyPlanException>()),
      );
      expect(
        () => repo.carryForwardToCurrent(august),
        throwsA(isA<MoneyPlanException>()),
      );
    },
  );

  test('persists BS period identity and exact canonical boundaries', () async {
    final now = DateTime.utc(2026, 8, 15, 12);
    final period = calendar.periodForDate(
      now,
      AppCalendarSystem.bikramSambatBs,
    );
    final saved = await repository(now: now).createOrUpdateCurrentPlan(
      period: period,
      ratios: MoneyPlanRatios.defaultPlan,
      categoryGroups: const <String, MoneyPlanGroup>{},
    );
    final restored = await repository(now: now).getPeriod(period);
    expect(restored?.period.calendarSystem, AppCalendarSystem.bikramSambatBs);
    expect(restored?.period.startAdInclusive, saved.period.startAdInclusive);
    expect(restored?.period.endAdExclusive, saved.period.endAdExclusive);
  });
}

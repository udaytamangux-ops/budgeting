import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';

abstract interface class MoneyPlanRepository {
  Stream<MoneyPlanPreference?> watchPreference();

  Future<MoneyPlanPreference?> getPreference();

  Stream<List<MoneyPlanPeriod>> watchPeriods();

  Future<List<MoneyPlanPeriod>> getPeriods();

  Stream<MoneyPlanPeriod?> watchPeriod(CalendarPeriod period);

  Future<MoneyPlanPeriod?> getPeriod(CalendarPeriod period);

  Stream<List<MoneyPlanCategoryMapping>> watchMappings(String periodId);

  Future<List<MoneyPlanCategoryMapping>> getMappings(String periodId);

  Future<MoneyPlanPeriod> createOrUpdateCurrentPlan({
    required CalendarPeriod period,
    required MoneyPlanRatios ratios,
    required Map<String, MoneyPlanGroup> categoryGroups,
  });

  Future<MoneyPlanPeriod?> carryForwardToCurrent(CalendarPeriod period);

  Future<void> setEnabled(bool enabled);
}

import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/money_plan/data/repositories/drift_money_plan_repository.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/domain/repositories/money_plan_repository.dart';
import 'package:budgeting_app/features/money_plan/domain/services/money_plan_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<MoneyPlanRepository> moneyPlanRepositoryProvider =
    Provider<MoneyPlanRepository>((Ref ref) {
      return DriftMoneyPlanRepository(
        ref.watch(appDatabaseProvider),
        ownerScope: ref.watch(activeOwnerScopeProvider),
        now: ref.watch(appClockProvider),
      );
    });

final StreamProvider<MoneyPlanPreference?> moneyPlanPreferenceProvider =
    StreamProvider<MoneyPlanPreference?>((Ref ref) {
      return ref.watch(moneyPlanRepositoryProvider).watchPreference();
    });

final StreamProvider<List<MoneyPlanPeriod>> moneyPlanPeriodsProvider =
    StreamProvider<List<MoneyPlanPeriod>>((Ref ref) {
      return ref.watch(moneyPlanRepositoryProvider).watchPeriods();
    });

final StreamProviderFamily<MoneyPlanPeriod?, CalendarPeriod>
moneyPlanPeriodProvider =
    StreamProvider.family<MoneyPlanPeriod?, CalendarPeriod>((
      Ref ref,
      CalendarPeriod period,
    ) {
      return ref.watch(moneyPlanRepositoryProvider).watchPeriod(period);
    });

final StreamProviderFamily<List<MoneyPlanCategoryMapping>, String>
moneyPlanMappingsProvider =
    StreamProvider.family<List<MoneyPlanCategoryMapping>, String>((
      Ref ref,
      String periodId,
    ) {
      return ref.watch(moneyPlanRepositoryProvider).watchMappings(periodId);
    });

final class MoneyPlanViewData {
  const MoneyPlanViewData({
    required this.plan,
    required this.mappings,
    required this.summary,
  });

  final MoneyPlanPeriod plan;
  final List<MoneyPlanCategoryMapping> mappings;
  final MoneyPlanSummary summary;
}

final ProviderFamily<AsyncValue<MoneyPlanViewData?>, CalendarPeriod>
moneyPlanViewDataProvider =
    Provider.family<AsyncValue<MoneyPlanViewData?>, CalendarPeriod>((
      Ref ref,
      CalendarPeriod period,
    ) {
      final AsyncValue<MoneyPlanPeriod?> planValue = ref.watch(
        moneyPlanPeriodProvider(period),
      );
      if (planValue.hasError) {
        return AsyncError(planValue.error!, planValue.stackTrace!);
      }
      final MoneyPlanPeriod? plan = planValue.valueOrNull;
      if (planValue.isLoading) {
        return const AsyncLoading<MoneyPlanViewData?>();
      }
      if (plan == null) return const AsyncData<MoneyPlanViewData?>(null);
      final mappingsValue = ref.watch(moneyPlanMappingsProvider(plan.id));
      final activitiesValue = ref.watch(financialActivityListProvider);
      if (mappingsValue.hasError) {
        return AsyncError(mappingsValue.error!, mappingsValue.stackTrace!);
      }
      if (activitiesValue.hasError) {
        return AsyncError(activitiesValue.error!, activitiesValue.stackTrace!);
      }
      final List<MoneyPlanCategoryMapping>? mappings =
          mappingsValue.valueOrNull;
      final activities = activitiesValue.valueOrNull;
      if (mappings == null || activities == null) {
        return const AsyncLoading<MoneyPlanViewData?>();
      }
      return AsyncData<MoneyPlanViewData?>(
        MoneyPlanViewData(
          plan: plan,
          mappings: mappings,
          summary: const MoneyPlanSummaryService().calculate(
            plan: plan,
            mappings: mappings,
            activities: activities,
          ),
        ),
      );
    });

final AutoDisposeFutureProviderFamily<MoneyPlanPeriod?, CalendarPeriod>
moneyPlanCarryForwardProvider = FutureProvider.autoDispose
    .family<MoneyPlanPeriod?, CalendarPeriod>((Ref ref, CalendarPeriod period) {
      return ref
          .watch(moneyPlanRepositoryProvider)
          .carryForwardToCurrent(period);
    });

final Provider<AsyncValue<CalendarPeriodBounds>> moneyPlanPeriodBoundsProvider =
    Provider<AsyncValue<CalendarPeriodBounds>>((Ref ref) {
      final AsyncValue<CalendarPeriodBounds> base = ref.watch(
        calendarPeriodBoundsProvider,
      );
      final AsyncValue<List<MoneyPlanPeriod>> plans = ref.watch(
        moneyPlanPeriodsProvider,
      );
      if (base.hasError) return AsyncError(base.error!, base.stackTrace!);
      if (plans.hasError) return AsyncError(plans.error!, plans.stackTrace!);
      final CalendarPeriodBounds? bounds = base.valueOrNull;
      final List<MoneyPlanPeriod>? values = plans.valueOrNull;
      if (bounds == null || values == null) {
        return const AsyncLoading<CalendarPeriodBounds>();
      }
      CalendarPeriod earliest = bounds.earliest;
      for (final MoneyPlanPeriod plan in values) {
        if (plan.period.calendarSystem == bounds.current.calendarSystem &&
            plan.period.startAdInclusive.isBefore(earliest.startAdInclusive)) {
          earliest = plan.period;
        }
      }
      return AsyncData<CalendarPeriodBounds>(
        CalendarPeriodBounds(
          earliest: earliest,
          current: bounds.current,
          latest: bounds.latest,
        ),
      );
    });

final class MoneyPlanDraftState {
  const MoneyPlanDraftState({
    this.needsPercent = 50,
    this.wantsPercent = 30,
    this.savingsPercent = 20,
    this.categoryGroups = const <String, MoneyPlanGroup>{},
    this.initializedForPeriodId,
    this.isSaving = false,
    this.error,
  });

  final int needsPercent;
  final int wantsPercent;
  final int savingsPercent;
  final Map<String, MoneyPlanGroup> categoryGroups;
  final String? initializedForPeriodId;
  final bool isSaving;
  final String? error;

  int get total => needsPercent + wantsPercent + savingsPercent;
  bool get isValid =>
      needsPercent >= 0 &&
      wantsPercent >= 0 &&
      savingsPercent >= 0 &&
      needsPercent <= 100 &&
      wantsPercent <= 100 &&
      savingsPercent <= 100 &&
      total == 100;

  MoneyPlanDraftState copyWith({
    int? needsPercent,
    int? wantsPercent,
    int? savingsPercent,
    Map<String, MoneyPlanGroup>? categoryGroups,
    String? initializedForPeriodId,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) => MoneyPlanDraftState(
    needsPercent: needsPercent ?? this.needsPercent,
    wantsPercent: wantsPercent ?? this.wantsPercent,
    savingsPercent: savingsPercent ?? this.savingsPercent,
    categoryGroups: categoryGroups ?? this.categoryGroups,
    initializedForPeriodId:
        initializedForPeriodId ?? this.initializedForPeriodId,
    isSaving: isSaving ?? this.isSaving,
    error: clearError ? null : error ?? this.error,
  );
}

final NotifierProvider<MoneyPlanDraftController, MoneyPlanDraftState>
moneyPlanDraftControllerProvider =
    NotifierProvider<MoneyPlanDraftController, MoneyPlanDraftState>(
      MoneyPlanDraftController.new,
    );

final class MoneyPlanDraftController extends Notifier<MoneyPlanDraftState> {
  static final Set<TransactionCategory> _suggestedNeeds = <TransactionCategory>{
    TransactionCategory.food,
    TransactionCategory.transport,
    TransactionCategory.rentAndHousing,
    TransactionCategory.utilities,
    TransactionCategory.health,
    TransactionCategory.education,
    TransactionCategory.family,
    TransactionCategory.feesAndCharges,
  };
  static final Set<TransactionCategory> _suggestedWants = <TransactionCategory>{
    TransactionCategory.shopping,
    TransactionCategory.entertainment,
  };

  @override
  MoneyPlanDraftState build() => const MoneyPlanDraftState();

  Future<void> initialize({MoneyPlanPeriod? plan, bool force = false}) async {
    final String key = plan?.id ?? 'new';
    if (!force && state.initializedForPeriodId == key) return;
    if (plan == null) {
      final List<MoneyPlanPeriod> periods = await ref
          .read(moneyPlanRepositoryProvider)
          .getPeriods();
      if (periods.isNotEmpty) {
        final MoneyPlanPeriod source = periods.last;
        final mappings = await ref
            .read(moneyPlanRepositoryProvider)
            .getMappings(source.id);
        state = MoneyPlanDraftState(
          needsPercent: source.ratios.needsPercent,
          wantsPercent: source.ratios.wantsPercent,
          savingsPercent: source.ratios.savingsPercent,
          categoryGroups: _mappingMap(mappings),
          initializedForPeriodId: key,
        );
        return;
      }
      state = MoneyPlanDraftState(
        categoryGroups: _defaultGroups(),
        initializedForPeriodId: key,
      );
      return;
    }
    final mappings = await ref
        .read(moneyPlanRepositoryProvider)
        .getMappings(plan.id);
    state = MoneyPlanDraftState(
      needsPercent: plan.ratios.needsPercent,
      wantsPercent: plan.ratios.wantsPercent,
      savingsPercent: plan.ratios.savingsPercent,
      categoryGroups: _mappingMap(mappings),
      initializedForPeriodId: key,
    );
  }

  void setNeeds(int value) =>
      state = state.copyWith(needsPercent: value, clearError: true);

  void setWants(int value) =>
      state = state.copyWith(wantsPercent: value, clearError: true);

  void setSavings(int value) =>
      state = state.copyWith(savingsPercent: value, clearError: true);

  void setCategoryGroup(String categoryId, MoneyPlanGroup group) {
    state = state.copyWith(
      categoryGroups: <String, MoneyPlanGroup>{
        ...state.categoryGroups,
        categoryId: group,
      },
      clearError: true,
    );
  }

  Future<bool> save(CalendarPeriod period) async {
    if (state.isSaving || !state.isValid) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref
          .read(moneyPlanRepositoryProvider)
          .createOrUpdateCurrentPlan(
            period: period,
            ratios: MoneyPlanRatios(
              needsPercent: state.needsPercent,
              wantsPercent: state.wantsPercent,
              savingsPercent: state.savingsPercent,
            ),
            categoryGroups: state.categoryGroups,
          );
      state = state.copyWith(isSaving: false);
      return true;
    } on MoneyPlanException catch (error) {
      state = state.copyWith(isSaving: false, error: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        error: 'Money Plan could not be saved. Try again.',
      );
      return false;
    }
  }

  Future<bool> turnOff() async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref.read(moneyPlanRepositoryProvider).setEnabled(false);
      state = state.copyWith(isSaving: false);
      return true;
    } on MoneyPlanException catch (error) {
      state = state.copyWith(isSaving: false, error: error.message);
      return false;
    }
  }

  void reset() => state = const MoneyPlanDraftState();

  Map<String, MoneyPlanGroup> _defaultGroups() => <String, MoneyPlanGroup>{
    for (final TransactionCategory category in TransactionCategory.values.where(
      (TransactionCategory value) => value.supports(TransactionType.expense),
    ))
      category.name: _suggestedNeeds.contains(category)
          ? MoneyPlanGroup.needs
          : _suggestedWants.contains(category)
          ? MoneyPlanGroup.wants
          : MoneyPlanGroup.unassigned,
    for (final CustomCategory category
        in ref
            .read(categoryCatalogProvider)
            .customCategories
            .where(
              (CustomCategory value) => value.type == TransactionType.expense,
            ))
      category.id: MoneyPlanGroup.unassigned,
  };

  Map<String, MoneyPlanGroup> _mappingMap(
    List<MoneyPlanCategoryMapping> mappings,
  ) => <String, MoneyPlanGroup>{
    for (final MoneyPlanCategoryMapping mapping in mappings)
      mapping.categoryId: mapping.group,
  };
}

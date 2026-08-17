import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/money_plan/data/repositories/in_memory_money_plan_repository.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/presentation/controllers/money_plan_providers.dart';
import 'package:budgeting_app/features/money_plan/presentation/screens/money_plan_setup_screen.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets(
    'Summary exposes unconfigured entry and completes 50/30/20 setup',
    (WidgetTester tester) async {
      await pumpBudgetingApp(
        tester,
        seedCustomCategories: <CustomCategory>[
          CustomCategory(
            id: 'custom:pet-care',
            type: TransactionType.expense,
            name: 'Pet Care',
            normalizedName: 'pet care',
            iconKey: 'pets',
            isArchived: false,
            createdAt: fixedNow,
            updatedAt: fixedNow,
          ),
        ],
      );
      await tester.tap(find.text('Summary'));
      await tester.pumpAndSettle();

      final Finder setupEntry = find.byKey(
        const ValueKey<String>('setup_money_plan_summary'),
      );
      await _bringSummaryActionIntoView(tester, setupEntry);
      expect(setupEntry, findsOneWidget);
      await tester.tap(setupEntry);
      await tester.pumpAndSettle();

      expect(find.text('Choose your plan split'), findsOneWidget);
      expect(find.text('Total 100%'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Needs'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Wants'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Savings target'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey<String>('needs_percent')),
        '45',
      );
      await tester.pump();
      expect(find.text('5% still needs to be assigned.'), findsOneWidget);
      final FilledButton review = tester.widget<FilledButton>(
        find.byKey(const ValueKey<String>('review_plan_categories')),
      );
      expect(review.onPressed, isNull);

      await tester.enterText(
        find.byKey(const ValueKey<String>('needs_percent')),
        '60',
      );
      await tester.pump();
      expect(
        find.text('Reduce the plan by 10% to reach 100%.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey<String>('review_plan_categories')),
            )
            .onPressed,
        isNull,
      );

      await tester.enterText(
        find.byKey(const ValueKey<String>('needs_percent')),
        '50',
      );
      await tester.pump();
      await tester.drag(find.byType(ListView).last, const Offset(0, -160));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('review_plan_categories')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Review your categories'), findsOneWidget);
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(MoneyPlanCategoryMappingScreen)),
      );
      final Map<String, MoneyPlanGroup> suggestedGroups = container
          .read(moneyPlanDraftControllerProvider)
          .categoryGroups;
      expect(
        suggestedGroups[TransactionCategory.transport.name],
        MoneyPlanGroup.needs,
      );
      expect(
        suggestedGroups[TransactionCategory.utilities.name],
        MoneyPlanGroup.needs,
      );
      expect(
        suggestedGroups[TransactionCategory.shopping.name],
        MoneyPlanGroup.wants,
      );
      expect(
        suggestedGroups[TransactionCategory.entertainment.name],
        MoneyPlanGroup.wants,
      );
      expect(
        suggestedGroups[TransactionCategory.other.name],
        MoneyPlanGroup.unassigned,
      );
      expect(suggestedGroups['custom:pet-care'], MoneyPlanGroup.unassigned);
      final Finder mappingList = find.byKey(
        const ValueKey<String>('money_plan_category_mapping_list'),
      );
      final Finder mappingScroll = find.descendant(
        of: mappingList,
        matching: find.byType(Scrollable),
      );
      Finder groupLabel(MoneyPlanGroup group) => find.byKey(
        ValueKey<String>('money_plan_group_${group.storageValue}'),
      );
      expect(groupLabel(MoneyPlanGroup.needs), findsOneWidget);
      await tester.scrollUntilVisible(
        groupLabel(MoneyPlanGroup.wants),
        200,
        scrollable: mappingScroll,
      );
      expect(groupLabel(MoneyPlanGroup.wants), findsOneWidget);
      await tester.scrollUntilVisible(
        groupLabel(MoneyPlanGroup.unassigned),
        200,
        scrollable: mappingScroll,
      );
      expect(groupLabel(MoneyPlanGroup.unassigned), findsOneWidget);
      expect(find.text('Pet Care'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('money_plan_group_savings')),
        findsNothing,
      );

      final Finder save = find.byKey(const ValueKey<String>('save_money_plan'));
      await tester.scrollUntilVisible(save, 200, scrollable: mappingScroll);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Money Plan'), findsWidgets);
      expect(find.text('No plan income recorded yet'), findsOneWidget);
    },
  );

  testWidgets('configured plan shows income, groups, targets and unassigned', (
    WidgetTester tester,
  ) async {
    final period = BikramSambatCalendarService().periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final MoneyPlanPeriod plan = MoneyPlanPeriod(
      id: 'plan-august',
      period: period,
      ratios: MoneyPlanRatios.defaultPlan,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
    final InMemoryMoneyPlanRepository repository = InMemoryMoneyPlanRepository(
      preference: MoneyPlanPreference(
        isEnabled: true,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
      periods: <MoneyPlanPeriod>[plan],
      mappings: <String, List<MoneyPlanCategoryMapping>>{
        plan.id: <MoneyPlanCategoryMapping>[
          _mapping('food', MoneyPlanGroup.needs, plan.id),
          _mapping('shopping', MoneyPlanGroup.wants, plan.id),
        ],
      },
      now: () => fixedNow,
    );
    addTearDown(repository.dispose);
    final TransactionCategory custom = TransactionCategory.custom(
      'custom:pet-care',
      type: TransactionType.expense,
    );
    await pumpBudgetingApp(
      tester,
      moneyPlanRepository: repository,
      seedCustomCategories: <CustomCategory>[
        CustomCategory(
          id: custom.name,
          type: TransactionType.expense,
          name: 'Pet Care',
          normalizedName: 'pet care',
          iconKey: 'pets',
          isArchived: false,
          createdAt: fixedNow,
          updatedAt: fixedNow,
        ),
      ],
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'salary',
          type: TransactionType.income,
          category: TransactionCategory.salary,
          minorUnits: 6000000,
        ),
        buildTestTransaction(
          id: 'food',
          category: TransactionCategory.food,
          minorUnits: 2400000,
        ),
        buildTestTransaction(
          id: 'shopping',
          category: TransactionCategory.shopping,
          minorUnits: 1400000,
        ),
        buildTestTransaction(id: 'pet', category: custom, minorUnits: 200000),
      ],
    );
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder open = find.byKey(
      const ValueKey<String>('view_money_plan_summary'),
    );
    await _bringSummaryActionIntoView(tester, open);
    await tester.tap(open);
    await tester.pumpAndSettle();

    expect(
      find.text('Based on NPR 60,000 recorded income this month.'),
      findsOneWidget,
    );
    expect(find.text('NPR 24,000 recorded'), findsOneWidget);
    expect(find.text('NPR 30,000 target · Plan 50%'), findsOneWidget);
    expect(find.text('NPR 14,000 recorded'), findsOneWidget);
    expect(find.text('NPR 18,000 target · Plan 30%'), findsOneWidget);
    expect(find.text('Unassigned spending'), findsOneWidget);
    expect(find.text('NPR 2,000'), findsWidgets);
    expect(find.textContaining('NPR 20,000 currently remains'), findsOneWidget);
  });

  testWidgets(
    'back discards unsaved ratio edits and reopening reloads saved plan',
    (WidgetTester tester) async {
      final MoneyPlanPeriod plan = _planFor(2026, 8, id: 'editable-plan');
      final InMemoryMoneyPlanRepository repository = _repositoryWithPlan(plan);
      addTearDown(repository.dispose);
      await pumpBudgetingApp(tester, moneyPlanRepository: repository);

      await _openMoneyPlanEditor(tester);
      await _enterRatios(tester, needs: 70, wants: 20, savings: 10);
      expect(find.text('Total 100%'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        (await repository.getPeriod(plan.period))!.ratios,
        MoneyPlanRatios.defaultPlan,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Edit'));
      await tester.pumpAndSettle();
      _expectRatioText(tester, needs: 50, wants: 30, savings: 20);
    },
  );

  testWidgets('Save changes explicitly persists valid ratio edits', (
    WidgetTester tester,
  ) async {
    final MoneyPlanPeriod plan = _planFor(2026, 8, id: 'saved-edit-plan');
    final InMemoryMoneyPlanRepository repository = _repositoryWithPlan(plan);
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, moneyPlanRepository: repository);

    await _openMoneyPlanEditor(tester);
    await _enterRatios(tester, needs: 60, wants: 20, savings: 20);
    final Finder save = find.byKey(
      const ValueKey<String>('save_money_plan_changes'),
    );
    await _bringSplitActionIntoView(tester, save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(
      (await repository.getPeriod(plan.period))!.ratios,
      MoneyPlanRatios(needsPercent: 60, wantsPercent: 20, savingsPercent: 20),
    );
    await tester.tap(find.widgetWithText(TextButton, 'Edit'));
    await tester.pumpAndSettle();
    _expectRatioText(tester, needs: 60, wants: 20, savings: 20);
  });

  testWidgets('Review categories preserves draft without committing ratios', (
    WidgetTester tester,
  ) async {
    final MoneyPlanPeriod plan = _planFor(2026, 8, id: 'review-draft-plan');
    final InMemoryMoneyPlanRepository repository = _repositoryWithPlan(plan);
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, moneyPlanRepository: repository);

    await _openMoneyPlanEditor(tester);
    await _enterRatios(tester, needs: 70, wants: 20, savings: 10);
    final Finder review = find.byKey(
      const ValueKey<String>('review_plan_categories'),
    );
    await _bringSplitActionIntoView(tester, review);
    await tester.tap(review);
    await tester.pumpAndSettle();

    expect(find.text('Review your categories'), findsOneWidget);
    expect(
      (await repository.getPeriod(plan.period))!.ratios,
      MoneyPlanRatios.defaultPlan,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    final MoneyPlanDraftState draft = ProviderScope.containerOf(
      tester.element(find.byType(MoneyPlanSplitScreen)),
    ).read(moneyPlanDraftControllerProvider);
    expect(draft.needsPercent, 70);
    expect(draft.wantsPercent, 20);
    expect(draft.savingsPercent, 10);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Edit'));
    await tester.pumpAndSettle();
    _expectRatioText(tester, needs: 50, wants: 30, savings: 20);
  });

  testWidgets('invalid ratio edits block Save and leave repository unchanged', (
    WidgetTester tester,
  ) async {
    final MoneyPlanPeriod plan = _planFor(2026, 8, id: 'invalid-edit-plan');
    final InMemoryMoneyPlanRepository repository = _repositoryWithPlan(plan);
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, moneyPlanRepository: repository);

    await _openMoneyPlanEditor(tester);
    await _enterRatios(tester, needs: 45, wants: 30, savings: 20);
    expect(find.text('5% still needs to be assigned.'), findsOneWidget);
    final Finder saveFinder = find.byKey(
      const ValueKey<String>('save_money_plan_changes'),
    );
    await _bringSplitActionIntoView(tester, saveFinder);
    final FilledButton save = tester.widget<FilledButton>(saveFinder);
    expect(save.onPressed, isNull);
    expect(
      (await repository.getPeriod(plan.period))!.ratios,
      MoneyPlanRatios.defaultPlan,
    );
  });

  testWidgets('Refund-only period presents factual no-plan-income state', (
    WidgetTester tester,
  ) async {
    final InMemoryMoneyPlanRepository repository = _configuredRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(
      tester,
      moneyPlanRepository: repository,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          type: TransactionType.income,
          category: TransactionCategory.refund,
          minorUnits: 100000,
        ),
      ],
    );
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder open = find.byKey(
      const ValueKey<String>('view_money_plan_summary'),
    );
    await _bringSummaryActionIntoView(tester, open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(find.text('No plan income recorded yet'), findsOneWidget);
    expect(find.textContaining('Refunds are not included'), findsOneWidget);
  });

  testWidgets(
    'Summary distinguishes a disabled plan from an unconfigured one',
    (WidgetTester tester) async {
      final MoneyPlanPeriod plan = _planFor(2026, 8, id: 'disabled-plan');
      final InMemoryMoneyPlanRepository repository =
          InMemoryMoneyPlanRepository(
            preference: MoneyPlanPreference(
              isEnabled: false,
              createdAt: fixedNow,
              updatedAt: fixedNow,
            ),
            periods: <MoneyPlanPeriod>[plan],
            now: () => fixedNow,
          );
      addTearDown(repository.dispose);
      await pumpBudgetingApp(tester, moneyPlanRepository: repository);
      await tester.tap(find.text('Summary'));
      await tester.pumpAndSettle();

      final Finder action = find.byKey(
        const ValueKey<String>('view_disabled_money_plan_summary'),
      );
      await _bringSummaryActionIntoView(tester, action);
      expect(find.text('Currently off'), findsOneWidget);
      expect(find.text('Set up Money Plan'), findsNothing);
    },
  );

  testWidgets('completed plan periods are read-only', (
    WidgetTester tester,
  ) async {
    final MoneyPlanPeriod july = _planFor(2026, 7, id: 'july-plan');
    final MoneyPlanPeriod august = _planFor(2026, 8, id: 'august-plan');
    final InMemoryMoneyPlanRepository repository = InMemoryMoneyPlanRepository(
      preference: MoneyPlanPreference(
        isEnabled: true,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
      periods: <MoneyPlanPeriod>[july, august],
      now: () => fixedNow,
    );
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, moneyPlanRepository: repository);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder open = find.byKey(
      const ValueKey<String>('view_money_plan_summary'),
    );
    await _bringSummaryActionIntoView(tester, open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'Edit'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Edit'), findsNothing);
  });

  testWidgets('a period before setup shows a factual historical empty state', (
    WidgetTester tester,
  ) async {
    final MoneyPlanPeriod august = _planFor(2026, 8, id: 'august-plan');
    final InMemoryMoneyPlanRepository repository = InMemoryMoneyPlanRepository(
      preference: MoneyPlanPreference(
        isEnabled: true,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
      periods: <MoneyPlanPeriod>[august],
      now: () => fixedNow,
    );
    addTearDown(repository.dispose);
    await pumpBudgetingApp(
      tester,
      moneyPlanRepository: repository,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'july-expense',
          occurredAt: DateTime.utc(2026, 7, 4, 12),
        ),
      ],
    );
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder open = find.byKey(
      const ValueKey<String>('view_money_plan_summary'),
    );
    await _bringSummaryActionIntoView(tester, open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Money Plan for July 2026'), findsOneWidget);
    expect(
      find.text('Your Money Plan started in August 2026.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Edit'), findsNothing);
  });

  testWidgets('Money Plan remains usable at 320px, 2x text and dark mode', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await pumpBudgetingApp(tester, themePreference: AppThemePreference.dark);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder setupEntry = find.byKey(
      const ValueKey<String>('setup_money_plan_summary'),
    );
    await _bringSummaryActionIntoView(tester, setupEntry);
    await tester.tap(setupEntry);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Choose your plan split'), findsOneWidget);
  });

  testWidgets('Money Plan remains usable at 768px with reduced motion', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    });
    await pumpBudgetingApp(tester);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final Finder setupEntry = find.byKey(
      const ValueKey<String>('setup_money_plan_summary'),
    );
    await _bringSummaryActionIntoView(tester, setupEntry);
    await tester.tap(setupEntry);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Choose your plan split'), findsOneWidget);
  });
}

Future<void> _bringSummaryActionIntoView(
  WidgetTester tester,
  Finder action,
) async {
  final Finder summary = find.byKey(const ValueKey<String>('summary_content'));
  await tester.scrollUntilVisible(
    action,
    240,
    scrollable: find.descendant(of: summary, matching: find.byType(Scrollable)),
  );
  await tester.pumpAndSettle();
}

Future<void> _openMoneyPlanEditor(WidgetTester tester) async {
  await tester.tap(find.text('Summary'));
  await tester.pumpAndSettle();
  final Finder open = find.byKey(
    const ValueKey<String>('view_money_plan_summary'),
  );
  await _bringSummaryActionIntoView(tester, open);
  await tester.tap(open);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(TextButton, 'Edit'));
  await tester.pumpAndSettle();
}

Future<void> _enterRatios(
  WidgetTester tester, {
  required int needs,
  required int wants,
  required int savings,
}) async {
  await tester.enterText(
    find.byKey(const ValueKey<String>('needs_percent')),
    '$needs',
  );
  await tester.enterText(
    find.byKey(const ValueKey<String>('wants_percent')),
    '$wants',
  );
  await tester.enterText(
    find.byKey(const ValueKey<String>('savings_percent')),
    '$savings',
  );
  await tester.pump();
}

void _expectRatioText(
  WidgetTester tester, {
  required int needs,
  required int wants,
  required int savings,
}) {
  expect(
    tester
        .widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey<String>('needs_percent')),
            matching: find.byType(TextField),
          ),
        )
        .controller!
        .text,
    '$needs',
  );
  expect(
    tester
        .widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey<String>('wants_percent')),
            matching: find.byType(TextField),
          ),
        )
        .controller!
        .text,
    '$wants',
  );
  expect(
    tester
        .widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey<String>('savings_percent')),
            matching: find.byType(TextField),
          ),
        )
        .controller!
        .text,
    '$savings',
  );
}

Future<void> _bringSplitActionIntoView(
  WidgetTester tester,
  Finder action,
) async {
  final Finder split = find.byKey(
    const ValueKey<String>('money_plan_split_list'),
  );
  await tester.scrollUntilVisible(
    action,
    160,
    scrollable: find
        .descendant(of: split, matching: find.byType(Scrollable))
        .first,
  );
  await tester.pumpAndSettle();
}

InMemoryMoneyPlanRepository _repositoryWithPlan(MoneyPlanPeriod plan) =>
    InMemoryMoneyPlanRepository(
      preference: MoneyPlanPreference(
        isEnabled: true,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
      periods: <MoneyPlanPeriod>[plan],
      now: () => fixedNow,
    );

MoneyPlanCategoryMapping _mapping(
  String categoryId,
  MoneyPlanGroup group,
  String periodId,
) => MoneyPlanCategoryMapping(
  id: 'mapping-$categoryId',
  periodId: periodId,
  categoryId: categoryId,
  group: group,
  createdAt: fixedNow,
  updatedAt: fixedNow,
);

MoneyPlanPeriod _planFor(int year, int month, {required String id}) {
  final period = BikramSambatCalendarService().periodFor(
    calendarSystem: AppCalendarSystem.gregorianAd,
    year: year,
    month: month,
  );
  return MoneyPlanPeriod(
    id: id,
    period: period,
    ratios: MoneyPlanRatios.defaultPlan,
    createdAt: fixedNow,
    updatedAt: fixedNow,
  );
}

InMemoryMoneyPlanRepository _configuredRepository() {
  final period = BikramSambatCalendarService().periodFor(
    calendarSystem: AppCalendarSystem.gregorianAd,
    year: 2026,
    month: 8,
  );
  final MoneyPlanPeriod plan = MoneyPlanPeriod(
    id: 'plan-august',
    period: period,
    ratios: MoneyPlanRatios.defaultPlan,
    createdAt: fixedNow,
    updatedAt: fixedNow,
  );
  return InMemoryMoneyPlanRepository(
    preference: MoneyPlanPreference(
      isEnabled: true,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    ),
    periods: <MoneyPlanPeriod>[plan],
    now: () => fixedNow,
  );
}

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/domain/services/money_plan_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  final period = BikramSambatCalendarService().periodFor(
    calendarSystem: AppCalendarSystem.gregorianAd,
    year: 2026,
    month: 8,
  );
  final plan = MoneyPlanPeriod(
    id: 'plan-august',
    period: period,
    ratios: MoneyPlanRatios.defaultPlan,
    createdAt: fixedNow,
    updatedAt: fixedNow,
  );
  final mappings = <MoneyPlanCategoryMapping>[
    MoneyPlanCategoryMapping(
      id: 'map-food',
      periodId: plan.id,
      categoryId: TransactionCategory.food.name,
      group: MoneyPlanGroup.needs,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    ),
    MoneyPlanCategoryMapping(
      id: 'map-shopping',
      periodId: plan.id,
      categoryId: TransactionCategory.shopping.name,
      group: MoneyPlanGroup.wants,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    ),
    MoneyPlanCategoryMapping(
      id: 'map-family',
      periodId: plan.id,
      categoryId: TransactionCategory.family.name,
      group: MoneyPlanGroup.needs,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    ),
    MoneyPlanCategoryMapping(
      id: 'map-fees',
      periodId: plan.id,
      categoryId: TransactionCategory.feesAndCharges.name,
      group: MoneyPlanGroup.needs,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    ),
  ];
  const service = MoneyPlanSummaryService();

  group('MoneyPlanRatios', () {
    test('accepts default and custom ratios totaling 100', () {
      expect(MoneyPlanRatios.defaultPlan.total, 100);
      expect(
        MoneyPlanRatios(
          needsPercent: 60,
          wantsPercent: 25,
          savingsPercent: 15,
        ).total,
        100,
      );
    });

    test('rejects invalid totals and out-of-range values', () {
      expect(
        () => MoneyPlanRatios(
          needsPercent: 50,
          wantsPercent: 30,
          savingsPercent: 19,
        ),
        throwsArgumentError,
      );
      expect(
        () => MoneyPlanRatios(
          needsPercent: 50,
          wantsPercent: 30,
          savingsPercent: 21,
        ),
        throwsArgumentError,
      );
      expect(
        () => MoneyPlanRatios(
          needsPercent: -1,
          wantsPercent: 81,
          savingsPercent: 20,
        ),
        throwsArgumentError,
      );
      expect(
        () => MoneyPlanRatios(
          needsPercent: 101,
          wantsPercent: 0,
          savingsPercent: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  test('uses eligible recorded income and excludes Refund', () {
    final summary = service.calculate(
      plan: plan,
      mappings: mappings,
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            id: 'salary',
            type: TransactionType.income,
            category: TransactionCategory.salary,
            minorUnits: 10001,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'custom-income',
            type: TransactionType.income,
            category: TransactionCategory.custom(
              'custom:income',
              type: TransactionType.income,
            ),
            minorUnits: 5000,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'refund',
            type: TransactionType.income,
            category: TransactionCategory.refund,
            minorUnits: 7000,
          ),
        ),
      ],
    );
    expect(summary.planIncome.minorUnits, 15001);
    expect(
      summary.needsTarget.minorUnits +
          summary.wantsTarget.minorUnits +
          summary.savingsTarget.minorUnits,
      15001,
    );
    expect(summary.needsTarget.minorUnits, 7501);
    expect(summary.wantsTarget.minorUnits, 4500);
    expect(summary.savingsTarget.minorUnits, 3000);
  });

  test('uses deterministic Needs, Wants and Savings remainder tie order', () {
    final tiedPlan = MoneyPlanPeriod(
      id: 'tie',
      period: period,
      ratios: MoneyPlanRatios(
        needsPercent: 34,
        wantsPercent: 33,
        savingsPercent: 33,
      ),
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
    final summary = service.calculate(
      plan: tiedPlan,
      mappings: const <MoneyPlanCategoryMapping>[],
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            type: TransactionType.income,
            category: TransactionCategory.salary,
            minorUnits: 1,
          ),
        ),
      ],
    );
    expect(summary.needsTarget.minorUnits, 1);
    expect(summary.wantsTarget.minorUnits, 0);
    expect(summary.savingsTarget.minorUnits, 0);
  });

  test('classifies expense, counted transfer, fee and missing mapping', () {
    final summary = service.calculate(
      plan: plan,
      mappings: mappings,
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            id: 'salary',
            type: TransactionType.income,
            category: TransactionCategory.salary,
            minorUnits: 100000,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'food',
            category: TransactionCategory.food,
            minorUnits: 20000,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'shopping',
            category: TransactionCategory.shopping,
            minorUnits: 10000,
          ),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'other',
            category: TransactionCategory.other,
            minorUnits: 5000,
          ),
        ),
        TransferActivity(buildTestTransfer(id: 'normal')),
        TransferActivity(
          buildTestTransfer(
            id: 'counted',
            minorUnits: 7000,
            countsAsExpense: true,
            expenseCategory: TransactionCategory.family,
            feeMinorUnits: 100,
          ),
        ),
      ],
    );
    expect(summary.needsRecorded.minorUnits, 27100);
    expect(summary.wantsRecorded.minorUnits, 10000);
    expect(summary.unassignedRecorded.minorUnits, 5000);
    expect(summary.totalRecordedSpending.minorUnits, 42100);
    expect(summary.remainingAfterSpending.minorUnits, 57900);
    expect(summary.unassignedCategoryIds, <String>{'other'});
  });

  test('keeps a negative remaining value factual', () {
    final summary = service.calculate(
      plan: plan,
      mappings: mappings,
      activities: <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(
            type: TransactionType.income,
            category: TransactionCategory.salary,
            minorUnits: 1000,
          ),
        ),
        TransactionActivity(buildTestTransaction(minorUnits: 2000)),
      ],
    );
    expect(summary.remainingAfterSpending.minorUnits, -1000);
  });

  test('stable custom category identity keeps its mapping after rename', () {
    final mapping = MoneyPlanCategoryMapping(
      id: 'mapping',
      periodId: plan.id,
      categoryId: 'custom:stable-id',
      group: MoneyPlanGroup.wants,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
    expect(mapping.categoryId, 'custom:stable-id');
  });
}

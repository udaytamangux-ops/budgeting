import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/domain/services/financial_effect_service.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class MoneyPlanSummaryService {
  const MoneyPlanSummaryService({
    this.financialEffectService = const FinancialEffectService(),
  });

  final FinancialEffectService financialEffectService;

  MoneyPlanSummary calculate({
    required MoneyPlanPeriod plan,
    required Iterable<MoneyPlanCategoryMapping> mappings,
    required Iterable<FinancialActivity> activities,
  }) {
    final Map<String, MoneyPlanGroup> groupByCategory =
        <String, MoneyPlanGroup>{
          for (final MoneyPlanCategoryMapping mapping in mappings)
            mapping.categoryId: mapping.group,
        };
    Money planIncome = const Money.zero();
    Money needsRecorded = const Money.zero();
    Money wantsRecorded = const Money.zero();
    Money unassignedRecorded = const Money.zero();
    Money totalRecordedSpending = const Money.zero();
    final Set<String> unassignedCategoryIds = <String>{};

    for (final FinancialActivity activity in activities) {
      if (!plan.period.contains(activity.occurredAt)) continue;
      final FinancialEffect effect = financialEffectService.forActivity(
        activity,
      );
      if (activity case TransactionActivity(:final transaction)
          when transaction.type == TransactionType.income &&
              transaction.category != TransactionCategory.refund) {
        planIncome += effect.incomeImpact;
      }
      totalRecordedSpending += effect.expenseImpact;
      for (final MapEntry<TransactionCategory, Money> contribution
          in effect.expenseCategoryContributions.entries) {
        switch (groupByCategory[contribution.key.name] ??
            MoneyPlanGroup.unassigned) {
          case MoneyPlanGroup.needs:
            needsRecorded += contribution.value;
          case MoneyPlanGroup.wants:
            wantsRecorded += contribution.value;
          case MoneyPlanGroup.unassigned:
            unassignedRecorded += contribution.value;
            unassignedCategoryIds.add(contribution.key.name);
        }
      }
    }

    final List<Money> targets = _apportion(planIncome, plan.ratios);
    return MoneyPlanSummary(
      planIncome: planIncome,
      needsTarget: targets[0],
      needsRecorded: needsRecorded,
      wantsTarget: targets[1],
      wantsRecorded: wantsRecorded,
      savingsTarget: targets[2],
      unassignedRecorded: unassignedRecorded,
      totalRecordedSpending: totalRecordedSpending,
      remainingAfterSpending: planIncome - totalRecordedSpending,
      unassignedCategoryIds: unassignedCategoryIds,
    );
  }

  List<Money> _apportion(Money income, MoneyPlanRatios ratios) {
    if (!income.isPositive) {
      return const <Money>[Money.zero(), Money.zero(), Money.zero()];
    }
    final BigInt total = BigInt.from(income.minorUnits);
    final List<int> percentages = <int>[
      ratios.needsPercent,
      ratios.wantsPercent,
      ratios.savingsPercent,
    ];
    final List<BigInt> bases = <BigInt>[];
    final List<BigInt> remainders = <BigInt>[];
    for (final int percentage in percentages) {
      final BigInt numerator = total * BigInt.from(percentage);
      bases.add(numerator ~/ BigInt.from(100));
      remainders.add(numerator.remainder(BigInt.from(100)));
    }
    final int remaining = (total - bases.fold(BigInt.zero, (a, b) => a + b))
        .toInt();
    final List<int> order = <int>[0, 1, 2]
      ..sort((int a, int b) {
        final int remainder = remainders[b].compareTo(remainders[a]);
        return remainder != 0 ? remainder : a.compareTo(b);
      });
    for (int index = 0; index < remaining; index += 1) {
      bases[order[index]] += BigInt.one;
    }
    return List<Money>.generate(
      3,
      (int index) => Money(
        minorUnits: bases[index].toInt(),
        currencyCode: income.currencyCode,
      ),
      growable: false,
    );
  }
}

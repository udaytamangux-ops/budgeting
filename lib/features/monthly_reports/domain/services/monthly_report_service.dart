import 'dart:math' as math;

import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/domain/services/financial_effect_service.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_comparison_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';

final class MonthlyReportService {
  const MonthlyReportService(this._calendarService);

  final AppCalendarService _calendarService;

  MonthlyReportData build({
    required CalendarPeriod period,
    required List<FinancialActivity> activities,
    required DateTime now,
    DateTime? endExclusiveOverride,
  }) {
    final CalendarPeriod current = _calendarService.currentPeriod(
      period.calendarSystem,
      now: now,
    );
    final bool isMonthToDate = period == current;
    final DateTime naturalEnd = isMonthToDate
        ? _nextUtcDay(now).isBefore(period.endAdExclusive)
              ? _nextUtcDay(now)
              : period.endAdExclusive
        : period.endAdExclusive;
    final DateTime reportEnd = endExclusiveOverride == null
        ? naturalEnd
        : _earlier(endExclusiveOverride, period.endAdExclusive);
    final List<FinancialActivity> scoped = activities
        .where(
          (FinancialActivity activity) =>
              !activity.occurredAt.isBefore(period.startAdInclusive) &&
              activity.occurredAt.isBefore(reportEnd),
        )
        .toList(growable: false);

    Money income = const Money.zero();
    Money expenses = const Money.zero();
    Money movement = const Money.zero();
    Money countedTransfers = const Money.zero();
    Money fees = const Money.zero();
    int transferCount = 0;
    final Map<TransactionCategory, Money> expenseAmounts = {};
    final Map<TransactionCategory, int> expenseCounts = {};
    final Map<TransactionCategory, Money> incomeAmounts = {};
    final Map<TransactionCategory, int> incomeCounts = {};
    RankedReportActivity? largestExpense;
    RankedReportActivity? largestIncome;
    const FinancialEffectService effects = FinancialEffectService();

    for (final FinancialActivity activity in scoped) {
      final FinancialEffect effect = effects.forActivity(activity);
      income += effect.incomeImpact;
      expenses += effect.expenseImpact;
      for (final entry in effect.expenseCategoryContributions.entries) {
        expenseAmounts.update(
          entry.key,
          (Money value) => value + entry.value,
          ifAbsent: () => entry.value,
        );
        expenseCounts.update(
          entry.key,
          (int value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      switch (activity) {
        case TransactionActivity(:final transaction):
          if (transaction.type == TransactionType.income) {
            incomeAmounts.update(
              transaction.category,
              (Money value) => value + transaction.amount,
              ifAbsent: () => transaction.amount,
            );
            incomeCounts.update(
              transaction.category,
              (int value) => value + 1,
              ifAbsent: () => 1,
            );
            final RankedReportActivity candidate = RankedReportActivity(
              activity: activity,
              rankedAmount: transaction.amount,
              label: transaction.merchant ?? transaction.category.displayLabel,
              detail: transaction.category.displayLabel,
            );
            largestIncome = _largerActivity(largestIncome, candidate);
          } else {
            final RankedReportActivity candidate = RankedReportActivity(
              activity: activity,
              rankedAmount: transaction.amount,
              label: transaction.merchant ?? transaction.category.displayLabel,
              detail: transaction.category.displayLabel,
            );
            largestExpense = _largerActivity(largestExpense, candidate);
          }
        case TransferActivity(:final transfer):
          transferCount += 1;
          movement += transfer.amount;
          fees += transfer.fee;
          if (transfer.countsAsExpense) {
            countedTransfers += transfer.amount;
            final String destination =
                transfer.destinationName ?? transfer.destination.label;
            final RankedReportActivity candidate = RankedReportActivity(
              activity: activity,
              rankedAmount: transfer.amount,
              label: '${transfer.source.label} → $destination',
              detail: 'Transfer · Counted as expense',
            );
            largestExpense = _largerActivity(largestExpense, candidate);
          }
      }
    }

    final List<ReportCategoryTotal> expenseCategories = _categoryTotals(
      expenseAmounts,
      expenseCounts,
      expenses,
    );
    final List<ReportCategoryTotal> incomeCategories = _categoryTotals(
      incomeAmounts,
      incomeCounts,
      income,
    );
    return MonthlyReportData(
      period: period,
      isMonthToDate: isMonthToDate,
      incomeTotal: income,
      expenseTotal: expenses,
      netChange: income - expenses,
      activityCount: scoped.length,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
      expenseChart: _chartSlices(expenseCategories),
      incomeChart: _chartSlices(incomeCategories),
      transferSummary: TransferReportSummary(
        count: transferCount,
        movementTotal: movement,
        countedAsExpenseTotal: countedTransfers,
        feeTotal: fees,
      ),
      highestExpenseCategory: expenseCategories.firstOrNull,
      largestExpenseActivity: largestExpense,
      largestIncomeSource: incomeCategories.firstOrNull,
      largestIncomeActivity: largestIncome,
      activities: effects.sortNewestFirst(scoped),
    );
  }

  MonthlyComparisonData compare({
    required CalendarPeriod selectedPeriod,
    required List<FinancialActivity> activities,
    required DateTime now,
  }) {
    final CalendarPeriod previous = _calendarService.previousPeriod(
      selectedPeriod,
    );
    final CalendarPeriod currentPeriod = _calendarService.currentPeriod(
      selectedPeriod.calendarSystem,
      now: now,
    );
    final bool partial = selectedPeriod == currentPeriod;
    final DateTime currentEnd = partial
        ? _earlier(_nextUtcDay(now), selectedPeriod.endAdExclusive)
        : selectedPeriod.endAdExclusive;
    final int elapsedDays = math.max(
      1,
      currentEnd.difference(selectedPeriod.startAdInclusive).inDays,
    );
    final DateTime previousEnd = partial
        ? _earlier(
            previous.startAdInclusive.add(Duration(days: elapsedDays)),
            previous.endAdExclusive,
          )
        : previous.endAdExclusive;
    final MonthlyReportData current = build(
      period: selectedPeriod,
      activities: activities,
      now: now,
      endExclusiveOverride: currentEnd,
    );
    final MonthlyReportData prior = build(
      period: previous,
      activities: activities,
      now: now,
      endExclusiveOverride: previousEnd,
    );
    final List<ReportCategoryDelta> expenseDeltas = _deltas(
      current.expenseCategories,
      prior.expenseCategories,
    );
    final List<ReportCategoryDelta> incomeDeltas = _deltas(
      current.incomeCategories,
      prior.incomeCategories,
    );
    final Money netDelta = current.netChange - prior.netChange;
    final bool positive = prior.activityCount > 0 && netDelta.isPositive;
    return MonthlyComparisonData(
      currentPeriod: selectedPeriod,
      previousPeriod: previous,
      currentEndExclusive: currentEnd,
      previousEndExclusive: previousEnd,
      isPartialComparison: partial,
      income: ReportMetricComparison(
        current: current.incomeTotal,
        previous: prior.incomeTotal,
      ),
      expenses: ReportMetricComparison(
        current: current.expenseTotal,
        previous: prior.expenseTotal,
      ),
      netChange: ReportMetricComparison(
        current: current.netChange,
        previous: prior.netChange,
      ),
      expenseCategoryDeltas: expenseDeltas,
      incomeCategoryDeltas: incomeDeltas,
      previousActivityCount: prior.activityCount,
      explanation: _explanation(
        priorActivityCount: prior.activityCount,
        netDelta: netDelta,
        expenseDelta: current.expenseTotal - prior.expenseTotal,
        expenseDeltas: expenseDeltas,
        partial: partial,
      ),
      hasPositiveFactualMessage: positive,
    );
  }

  List<ReportCategoryTotal> _categoryTotals(
    Map<TransactionCategory, Money> amounts,
    Map<TransactionCategory, int> counts,
    Money total,
  ) {
    final List<MapEntry<TransactionCategory, Money>> sorted =
        amounts.entries.where((entry) => entry.value.isPositive).toList()
          ..sort((a, b) {
            final int amount = b.value.compareTo(a.value);
            return amount != 0 ? amount : a.key.index.compareTo(b.key.index);
          });
    final List<int> basisPoints = _allocateBasisPoints(
      sorted.map((entry) => entry.value.minorUnits).toList(growable: false),
      total.minorUnits,
    );
    return List<ReportCategoryTotal>.unmodifiable(
      List<ReportCategoryTotal>.generate(
        sorted.length,
        (int index) => ReportCategoryTotal(
          category: sorted[index].key,
          amount: sorted[index].value,
          basisPoints: basisPoints[index],
          activityCount: counts[sorted[index].key] ?? 0,
        ),
      ),
    );
  }

  List<int> _allocateBasisPoints(List<int> amounts, int total) {
    if (amounts.isEmpty || total <= 0) {
      return List<int>.filled(amounts.length, 0);
    }
    final List<int> values = List<int>.filled(amounts.length, 0);
    final List<int> remainders = List<int>.filled(amounts.length, 0);
    int allocated = 0;
    for (int index = 0; index < amounts.length; index += 1) {
      final int scaled = amounts[index] * 10000;
      values[index] = scaled ~/ total;
      remainders[index] = scaled % total;
      allocated += values[index];
    }
    final List<int> order = List<int>.generate(amounts.length, (int i) => i)
      ..sort((a, b) {
        final int remainder = remainders[b].compareTo(remainders[a]);
        return remainder != 0 ? remainder : a.compareTo(b);
      });
    for (int i = 0; i < 10000 - allocated; i += 1) {
      values[order[i % order.length]] += 1;
    }
    return List<int>.unmodifiable(values);
  }

  List<ReportChartSlice> _chartSlices(List<ReportCategoryTotal> categories) {
    const int visible = 5;
    if (categories.length <= visible) {
      return List<ReportChartSlice>.unmodifiable(
        categories.map(
          (item) => ReportChartSlice(
            label: item.category.displayLabel,
            amount: item.amount,
            basisPoints: item.basisPoints,
            categories: <TransactionCategory>[item.category],
          ),
        ),
      );
    }
    final List<ReportCategoryTotal> major = categories
        .take(visible - 1)
        .toList();
    final List<ReportCategoryTotal> small = categories
        .skip(visible - 1)
        .toList();
    Money otherAmount = const Money.zero();
    int otherBasisPoints = 0;
    for (final item in small) {
      otherAmount += item.amount;
      otherBasisPoints += item.basisPoints;
    }
    return List<ReportChartSlice>.unmodifiable(<ReportChartSlice>[
      ...major.map(
        (item) => ReportChartSlice(
          label: item.category.displayLabel,
          amount: item.amount,
          basisPoints: item.basisPoints,
          categories: <TransactionCategory>[item.category],
        ),
      ),
      ReportChartSlice(
        label: 'Other',
        amount: otherAmount,
        basisPoints: otherBasisPoints,
        categories: small.map((item) => item.category).toList(growable: false),
      ),
    ]);
  }

  List<ReportCategoryDelta> _deltas(
    List<ReportCategoryTotal> current,
    List<ReportCategoryTotal> previous,
  ) {
    final Map<TransactionCategory, Money> currentMap = {
      for (final item in current) item.category: item.amount,
    };
    final Map<TransactionCategory, Money> previousMap = {
      for (final item in previous) item.category: item.amount,
    };
    final Set<TransactionCategory> categories = {
      ...currentMap.keys,
      ...previousMap.keys,
    };
    final List<ReportCategoryDelta> values = categories
        .map(
          (category) => ReportCategoryDelta(
            category: category,
            current: currentMap[category] ?? const Money.zero(),
            previous: previousMap[category] ?? const Money.zero(),
          ),
        )
        .where((value) => !value.delta.isZero)
        .toList();
    values.sort((a, b) {
      final int amount = b.delta.minorUnits.abs().compareTo(
        a.delta.minorUnits.abs(),
      );
      return amount != 0
          ? amount
          : a.category.index.compareTo(b.category.index);
    });
    return List<ReportCategoryDelta>.unmodifiable(values);
  }

  RankedReportActivity _largerActivity(
    RankedReportActivity? current,
    RankedReportActivity candidate,
  ) {
    if (current == null) return candidate;
    final int amount = candidate.rankedAmount.compareTo(current.rankedAmount);
    if (amount > 0 ||
        (amount == 0 &&
            candidate.activity.id.compareTo(current.activity.id) < 0)) {
      return candidate;
    }
    return current;
  }

  String _explanation({
    required int priorActivityCount,
    required Money netDelta,
    required Money expenseDelta,
    required List<ReportCategoryDelta> expenseDeltas,
    required bool partial,
  }) {
    if (priorActivityCount == 0) {
      return 'Not enough recorded activity to compare with the previous month yet.';
    }
    final String context = partial
        ? ' compared with the same point last month.'
        : ' compared with the previous month.';
    if (netDelta.isPositive) {
      return 'Nice — your recorded net change improved by '
          '${_plainMoney(netDelta)}$context';
    }
    if (expenseDelta.isPositive) {
      final List<String> increases = expenseDeltas
          .where((value) => value.delta.isPositive)
          .take(2)
          .map((value) => value.category.displayLabel)
          .toList(growable: false);
      final String detail = increases.isEmpty
          ? ''
          : ' The largest increases were ${increases.join(' and ')}.';
      return 'Your recorded expenses were ${_plainMoney(expenseDelta)} higher'
          '$context$detail';
    }
    if (expenseDelta.isNegative) {
      return 'Your recorded expenses were ${_plainMoney(expenseDelta.absolute)} lower$context';
    }
    return 'Your recorded net change was ${_plainMoney(netDelta.absolute)} lower$context';
  }

  String _plainMoney(Money value) {
    final int absolute = value.minorUnits.abs();
    final int whole = absolute ~/ 100;
    final int minor = absolute % 100;
    return minor == 0
        ? 'NPR $whole'
        : 'NPR $whole.${minor.toString().padLeft(2, '0')}';
  }

  DateTime _nextUtcDay(DateTime value) {
    final DateTime utc = value.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day + 1);
  }

  DateTime _earlier(DateTime first, DateTime second) =>
      first.isBefore(second) ? first : second;
}

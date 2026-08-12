import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class ReportMetricComparison {
  const ReportMetricComparison({required this.current, required this.previous});

  final Money current;
  final Money previous;

  Money get delta => current - previous;

  int? get changeBasisPoints {
    if (previous.isZero) return null;
    final int numerator = delta.minorUnits * 10000;
    final int denominator = previous.minorUnits.abs();
    final int absolute = numerator.abs();
    final int rounded = (absolute + denominator ~/ 2) ~/ denominator;
    return numerator.isNegative ? -rounded : rounded;
  }
}

final class ReportCategoryDelta {
  const ReportCategoryDelta({
    required this.category,
    required this.current,
    required this.previous,
  });

  final TransactionCategory category;
  final Money current;
  final Money previous;

  Money get delta => current - previous;
}

final class MonthlyComparisonData {
  const MonthlyComparisonData({
    required this.currentPeriod,
    required this.previousPeriod,
    required this.currentEndExclusive,
    required this.previousEndExclusive,
    required this.isPartialComparison,
    required this.income,
    required this.expenses,
    required this.netChange,
    required this.expenseCategoryDeltas,
    required this.incomeCategoryDeltas,
    required this.previousActivityCount,
    required this.explanation,
    required this.hasPositiveFactualMessage,
  });

  final CalendarPeriod currentPeriod;
  final CalendarPeriod previousPeriod;
  final DateTime currentEndExclusive;
  final DateTime previousEndExclusive;
  final bool isPartialComparison;
  final ReportMetricComparison income;
  final ReportMetricComparison expenses;
  final ReportMetricComparison netChange;
  final List<ReportCategoryDelta> expenseCategoryDeltas;
  final List<ReportCategoryDelta> incomeCategoryDeltas;
  final int previousActivityCount;
  final String explanation;
  final bool hasPositiveFactualMessage;

  bool get hasComparableData => previousActivityCount > 0;
}

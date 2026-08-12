import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class ReportCategoryTotal {
  const ReportCategoryTotal({
    required this.category,
    required this.amount,
    required this.basisPoints,
    required this.activityCount,
  });

  final TransactionCategory category;
  final Money amount;
  final int basisPoints;
  final int activityCount;
}

final class ReportChartSlice {
  const ReportChartSlice({
    required this.label,
    required this.amount,
    required this.basisPoints,
    required this.categories,
  });

  final String label;
  final Money amount;
  final int basisPoints;
  final List<TransactionCategory> categories;
}

final class TransferReportSummary {
  const TransferReportSummary({
    required this.count,
    required this.movementTotal,
    required this.countedAsExpenseTotal,
    required this.feeTotal,
  });

  final int count;
  final Money movementTotal;
  final Money countedAsExpenseTotal;
  final Money feeTotal;
}

final class RankedReportActivity {
  const RankedReportActivity({
    required this.activity,
    required this.rankedAmount,
    required this.label,
    required this.detail,
  });

  final FinancialActivity activity;
  final Money rankedAmount;
  final String label;
  final String detail;
}

final class MonthlyReportData {
  const MonthlyReportData({
    required this.period,
    required this.isMonthToDate,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.netChange,
    required this.activityCount,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.expenseChart,
    required this.incomeChart,
    required this.transferSummary,
    required this.highestExpenseCategory,
    required this.largestExpenseActivity,
    required this.largestIncomeSource,
    required this.largestIncomeActivity,
    required this.activities,
  });

  final CalendarPeriod period;
  final bool isMonthToDate;
  final Money incomeTotal;
  final Money expenseTotal;
  final Money netChange;
  final int activityCount;
  final List<ReportCategoryTotal> expenseCategories;
  final List<ReportCategoryTotal> incomeCategories;
  final List<ReportChartSlice> expenseChart;
  final List<ReportChartSlice> incomeChart;
  final TransferReportSummary transferSummary;
  final ReportCategoryTotal? highestExpenseCategory;
  final RankedReportActivity? largestExpenseActivity;
  final ReportCategoryTotal? largestIncomeSource;
  final RankedReportActivity? largestIncomeActivity;
  final List<FinancialActivity> activities;

  bool get isEmpty => activities.isEmpty;
}

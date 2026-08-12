final class MonthlyReportExportOptions {
  const MonthlyReportExportOptions({
    this.includeVisualCharts = true,
    this.includeMonthComparison = true,
    this.includeActivityList = true,
  });

  final bool includeVisualCharts;
  final bool includeMonthComparison;
  final bool includeActivityList;

  MonthlyReportExportOptions copyWith({
    bool? includeVisualCharts,
    bool? includeMonthComparison,
    bool? includeActivityList,
  }) => MonthlyReportExportOptions(
    includeVisualCharts: includeVisualCharts ?? this.includeVisualCharts,
    includeMonthComparison:
        includeMonthComparison ?? this.includeMonthComparison,
    includeActivityList: includeActivityList ?? this.includeActivityList,
  );
}

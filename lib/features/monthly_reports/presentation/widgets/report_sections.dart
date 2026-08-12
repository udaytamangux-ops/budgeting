import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
import 'package:flutter/material.dart';

final class ReportMetricGrid extends StatelessWidget {
  const ReportMetricGrid({required this.report, super.key});

  final MonthlyReportData report;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    final List<(String, String)> values = <(String, String)>[
      ('Income', formatter.format(report.incomeTotal)),
      ('Expenses', formatter.format(report.expenseTotal)),
      ('Net change', formatter.formatSigned(report.netChange)),
      ('Activity', '${report.activityCount} recorded'),
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 520 ? 4 : 2;
        final double textScale = MediaQuery.textScalerOf(context).scale(1);
        final double itemExtent = 92 + (textScale - 1).clamp(0, 2) * 64;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: itemExtent,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: values.length,
          itemBuilder: (BuildContext context, int index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      values[index].$1,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        values[index].$2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

final class ReportCategoryList extends StatelessWidget {
  const ReportCategoryList({
    required this.title,
    required this.values,
    required this.emptyMessage,
    this.maximumItems,
    super.key,
  });

  final String title;
  final List<ReportCategoryTotal> values;
  final String emptyMessage;
  final int? maximumItems;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    final List<ReportCategoryTotal> visible = maximumItems == null
        ? values
        : values.take(maximumItems!).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        if (visible.isEmpty)
          Text(emptyMessage)
        else
          for (final ReportCategoryTotal item in visible)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Text(item.category.displayLabel)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    formatter.format(item.amount),
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

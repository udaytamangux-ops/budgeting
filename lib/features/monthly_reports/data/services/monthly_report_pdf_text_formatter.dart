import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_comparison_data.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';

final class MonthlyReportPdfMetricText {
  const MonthlyReportPdfMetricText({required this.label, required this.value});

  final String label;
  final String value;
}

final class MonthlyReportPdfComparisonText {
  const MonthlyReportPdfComparisonText({
    required this.periods,
    required this.scope,
    required this.metrics,
    required this.explanation,
  });

  final String periods;
  final String scope;
  final List<MonthlyReportPdfMetricText> metrics;
  final String explanation;
}

final class MonthlyReportPdfTextFormatter {
  MonthlyReportPdfTextFormatter({CurrencyFormatter? currencyFormatter})
    : _currencyFormatter = currencyFormatter ?? CurrencyFormatter();

  final CurrencyFormatter _currencyFormatter;

  static const List<String> _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String header({required bool isMonthToDate}) =>
      isMonthToDate ? 'MONTH TO DATE' : 'MONTHLY REPORT';

  String money(Money money) {
    return _currencyFormatter.format(money).replaceFirst('\u2212', '-');
  }

  String generatedAt(DateTime value) {
    final DateTime local = value.toLocal();
    final int displayHour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final String period = local.hour < 12 ? 'AM' : 'PM';
    final String minute = local.minute.toString().padLeft(2, '0');
    return 'Generated ${local.day} ${_monthNames[local.month - 1]} '
        '${local.year}, $displayHour:$minute $period';
  }

  MonthlyReportPdfComparisonText comparison(MonthlyComparisonData value) {
    final String scope = value.isPartialComparison
        ? 'Compared with the same elapsed portion of the previous month.'
        : 'Compared with the previous month.';
    return MonthlyReportPdfComparisonText(
      periods:
          '${value.currentPeriod.displayLabel} vs ${value.previousPeriod.displayLabel}',
      scope: scope,
      metrics: value.hasComparableData
          ? <MonthlyReportPdfMetricText>[
              _comparisonMetric('Income', value.income),
              _comparisonMetric('Expenses', value.expenses),
              _comparisonMetric('Net change', value.netChange),
            ]
          : const <MonthlyReportPdfMetricText>[],
      explanation: value.explanation,
    );
  }

  MonthlyReportPdfMetricText _comparisonMetric(
    String label,
    ReportMetricComparison value,
  ) {
    final int? change = value.changeBasisPoints;
    final String changeText = change == null
        ? 'Not comparable'
        : _comparisonPercent(change);
    return MonthlyReportPdfMetricText(
      label: label,
      value: '${money(value.previous)} -> ${money(value.current)}  $changeText',
    );
  }

  String _comparisonPercent(int basisPoints) {
    final String sign = basisPoints < 0 ? '-' : '';
    final int absolute = basisPoints.abs();
    final int whole = absolute ~/ 100;
    final int fraction = absolute % 100;
    return fraction == 0
        ? '$sign$whole%'
        : '$sign$whole.${fraction.toString().padLeft(2, '0')}%';
  }
}

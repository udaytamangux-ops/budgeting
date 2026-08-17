import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/formatting/report_percentage_formatter.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/monthly_reports/data/services/monthly_report_pdf_text_formatter.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_comparison_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_export_options.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

final class MonthlyReportPdfService {
  MonthlyReportPdfService(
    this._calendarService, {
    MonthlyReportPdfTextFormatter? textFormatter,
    this._categoryLabelFor,
  }) : _textFormatter = textFormatter ?? MonthlyReportPdfTextFormatter();

  static const List<String> activityTableHeaders = <String>[
    'Date',
    'Type',
    'Description',
    'Category',
    'Payment',
    'Amount',
  ];

  static const Map<int, pw.TableColumnWidth> _activityColumnWidths =
      <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(14),
        1: pw.FlexColumnWidth(11),
        2: pw.FlexColumnWidth(30),
        3: pw.FlexColumnWidth(14),
        4: pw.FlexColumnWidth(15),
        5: pw.FlexColumnWidth(16),
      };

  final AppCalendarService _calendarService;
  final MonthlyReportPdfTextFormatter _textFormatter;
  final String Function(TransactionCategory category)? _categoryLabelFor;

  String _categoryLabel(TransactionCategory category) =>
      _categoryLabelFor?.call(category) ?? category.displayLabel;

  Future<Uint8List> generate({
    required MonthlyReportData report,
    required MonthlyComparisonData comparison,
    required MonthlyReportExportOptions options,
    required DateTime generatedAt,
  }) async {
    final pw.Font regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
    );
    final pw.Font bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
    );
    final pw.Font devanagari = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf'),
    );
    final pw.Document document = pw.Document(
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        fontFallback: <pw.Font>[devanagari],
      ),
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text(
            _textFormatter.header(isMonthToDate: report.isMonthToDate),
            style: const pw.TextStyle(
              color: PdfColors.blueGrey700,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        footer: (pw.Context context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(
              _textFormatter.generatedAt(generatedAt),
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (pw.Context context) => <pw.Widget>[
          pw.Text(
            report.period.displayLabel,
            style: const pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(_secondaryRange(report)),
          pw.SizedBox(height: 20),
          _metricTable(report),
          pw.SizedBox(height: 20),
          _categoryTable('Where your money went', report.expenseCategories),
          pw.SizedBox(height: 16),
          _categoryTable(
            'Where your income came from',
            report.incomeCategories,
          ),
          if (report.transferSummary.count > 0) ...<pw.Widget>[
            pw.SizedBox(height: 16),
            _transferSummary(report),
          ],
          if (report.highestExpenseCategory != null ||
              report.largestIncomeSource != null) ...<pw.Widget>[
            pw.SizedBox(height: 16),
            _highlights(report),
          ],
          if (options.includeVisualCharts) ...<pw.Widget>[
            pw.NewPage(),
            pw.Text(
              'Visual breakdown',
              style: const pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            _chartSection('Expenses', report.expenseChart),
            pw.SizedBox(height: 20),
            _chartSection('Income', report.incomeChart),
          ],
          if (options.includeMonthComparison) ...<pw.Widget>[
            if (options.includeVisualCharts && !comparison.hasComparableData)
              pw.SizedBox(height: 24)
            else
              pw.NewPage(),
            _comparisonSection(comparison),
          ],
          if (options.includeActivityList) ...<pw.Widget>[
            pw.NewPage(),
            ..._activityWidgets(report),
          ],
          pw.SizedBox(height: 18),
          pw.Divider(color: PdfColors.grey400),
          pw.Text(
            'This report reflects records entered in the app. Transfers are shown as movement and only affect expenses when explicitly counted as expense; transfer fees always affect expenses.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
    return document.save();
  }

  String _secondaryRange(MonthlyReportData report) {
    final AppCalendarSystem secondary =
        report.period.calendarSystem == AppCalendarSystem.gregorianAd
        ? AppCalendarSystem.bikramSambatBs
        : AppCalendarSystem.gregorianAd;
    final DateTime last = report.period.endAdExclusive.subtract(
      const Duration(days: 1),
    );
    return '${_calendarService.formatDate(report.period.startAdInclusive, secondary)} - '
        '${_calendarService.formatDate(last, secondary)}';
  }

  pw.Widget _metricTable(MonthlyReportData report) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: <pw.TableRow>[
        pw.TableRow(
          children: <pw.Widget>[
            _metricCell('Income', _money(report.incomeTotal.minorUnits)),
            _metricCell('Expenses', _money(report.expenseTotal.minorUnits)),
          ],
        ),
        pw.TableRow(
          children: <pw.Widget>[
            _metricCell('Net change', _money(report.netChange.minorUnits)),
            _metricCell('Recorded activity', '${report.activityCount}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _metricCell(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.all(12),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );

  pw.Widget _categoryTable(String title, List<ReportCategoryTotal> values) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        if (values.isEmpty)
          pw.Text('No recorded activity in this section.')
        else
          pw.TableHelper.fromTextArray(
            headers: <String>['Category', 'Amount', 'Share', 'Items'],
            data: values
                .map(
                  (ReportCategoryTotal value) => <String>[
                    value.displayLabel,
                    _money(value.amount.minorUnits),
                    ReportPercentageFormatter.formatBasisPoints(
                      value.basisPoints,
                    ),
                    '${value.activityCount}',
                  ],
                )
                .toList(growable: false),
            headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
          ),
      ],
    );
  }

  pw.Widget _transferSummary(MonthlyReportData report) {
    final TransferReportSummary value = report.transferSummary;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'Transfer activity',
          style: const pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          '${value.count} transfers - ${_money(value.movementTotal.minorUnits)} moved',
        ),
        pw.Text(
          '${_money(value.countedAsExpenseTotal.minorUnits)} counted as expense',
        ),
        pw.Text('${_money(value.feeTotal.minorUnits)} in transfer fees'),
      ],
    );
  }

  pw.Widget _highlights(MonthlyReportData report) {
    final List<List<String>> values = <List<String>>[
      if (report.highestExpenseCategory case final value?)
        <String>[
          'Highest expense category',
          value.displayLabel,
          _money(value.amount.minorUnits),
        ],
      if (report.largestExpenseActivity case final value?)
        <String>[
          'Largest expense activity',
          value.label,
          _money(value.rankedAmount.minorUnits),
        ],
      if (report.largestIncomeSource case final value?)
        <String>[
          'Largest income source',
          value.displayLabel,
          _money(value.amount.minorUnits),
        ],
      if (report.largestIncomeActivity case final value?)
        <String>[
          'Largest income activity',
          value.label,
          _money(value.rankedAmount.minorUnits),
        ],
    ];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'Period highlights',
          style: const pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: <String>['Measure', 'Recorded activity', 'Amount'],
          data: values,
          headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 5,
          ),
        ),
      ],
    );
  }

  pw.Widget _chartSection(String title, List<ReportChartSlice> values) {
    const List<PdfColor> colors = <PdfColor>[
      PdfColors.indigo600,
      PdfColors.teal600,
      PdfColors.orange600,
      PdfColors.pink500,
      PdfColors.blueGrey500,
    ];
    if (values.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text('No recorded ${title.toLowerCase()} for this period.'),
        ],
      );
    }
    if (values.length == 1) {
      final ReportChartSlice value = values.single;
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value.label,
            style: const pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(_money(value.amount.minorUnits)),
          pw.Text(
            '${ReportPercentageFormatter.formatBasisPoints(value.basisPoints)} of recorded ${title.toLowerCase()}',
          ),
        ],
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.SizedBox(
              width: 180,
              height: 180,
              child: pw.Chart(
                grid: pw.PieGrid(),
                datasets: <pw.Dataset>[
                  for (int index = 0; index < values.length; index += 1)
                    pw.PieDataSet(
                      value: values[index].amount.minorUnits,
                      color: colors[index % colors.length],
                      innerRadius: 50,
                      legendPosition: pw.PieLegendPosition.none,
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                children: <pw.Widget>[
                  for (int index = 0; index < values.length; index += 1)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 7),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Container(
                            width: 9,
                            height: 9,
                            margin: const pw.EdgeInsets.only(top: 2, right: 6),
                            color: colors[index % colors.length],
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              '${values[index].label} - ${_money(values[index].amount.minorUnits)} (${ReportPercentageFormatter.formatBasisPoints(values[index].basisPoints)})',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _comparisonSection(MonthlyComparisonData comparison) {
    final MonthlyReportPdfComparisonText content = _textFormatter.comparison(
      comparison,
    );
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'Month comparison',
          style: const pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(content.periods),
        pw.Text(content.scope),
        pw.SizedBox(height: 14),
        for (final MonthlyReportPdfMetricText metric in content.metrics)
          _comparisonRow(metric),
        if (content.metrics.isNotEmpty) pw.SizedBox(height: 12),
        pw.Text(content.explanation),
      ],
    );
  }

  pw.Widget _comparisonRow(MonthlyReportPdfMetricText value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(child: pw.Text(value.label)),
          pw.Text(value.value),
        ],
      ),
    );
  }

  List<pw.Widget> _activityWidgets(MonthlyReportData report) {
    return <pw.Widget>[
      pw.Text(
        'Recorded activity',
        style: const pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 10),
      if (report.activities.isEmpty)
        pw.Text('No recorded activity for this period.')
      else
        pw.TableHelper.fromTextArray(
          headers: activityTableHeaders,
          columnWidths: _activityColumnWidths,
          data: report.activities.map(_activityRow).toList(growable: false),
          headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 4,
          ),
        ),
    ];
  }

  List<String> _activityRow(FinancialActivity activity) {
    return switch (activity) {
      TransactionActivity(:final transaction) => <String>[
        _calendarService.formatDate(
          transaction.occurredAt,
          AppCalendarSystem.gregorianAd,
        ),
        transaction.type == TransactionType.expense ? 'Expense' : 'Income',
        transaction.merchant ?? _categoryLabel(transaction.category),
        _categoryLabel(transaction.category),
        transaction.paymentMethod.label,
        _money(transaction.amount.minorUnits),
      ],
      TransferActivity(:final transfer) => <String>[
        _calendarService.formatDate(
          transfer.occurredAt,
          AppCalendarSystem.gregorianAd,
        ),
        'Transfer',
        '${transfer.source.label} -> ${transfer.destinationDisplayName}'
            '${transfer.countsAsExpense ? ' - Counted as expense' : ''}'
            '${transfer.fee.isPositive ? ' - Fee ${_money(transfer.fee.minorUnits)}' : ''}',
        transfer.expenseCategory == null
            ? '-'
            : _categoryLabel(transfer.expenseCategory!),
        '-',
        _money(transfer.amount.minorUnits),
      ],
    };
  }

  String _money(int minorUnits) {
    return _textFormatter.money(Money(minorUnits: minorUnits));
  }
}

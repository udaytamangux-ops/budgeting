import 'dart:async';
import 'dart:typed_data';

import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/data_portability/domain/services/local_document_service.dart';
import 'package:budgeting_app/features/data_portability/presentation/controllers/data_portability_controller.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/monthly_reports/data/services/monthly_report_pdf_service.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_comparison_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_export_options.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/controllers/monthly_report_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<MonthlyReportPdfService> monthlyReportPdfServiceProvider =
    Provider<MonthlyReportPdfService>((Ref ref) {
      final catalog = ref.watch(categoryCatalogProvider);
      return MonthlyReportPdfService(
        ref.watch(appCalendarServiceProvider),
        categoryLabelFor: (category) => catalog.resolve(category).label,
      );
    });

final class MonthlyReportExportState {
  const MonthlyReportExportState({this.isBusy = false, this.feedback});

  final bool isBusy;
  final String? feedback;
}

final AutoDisposeNotifierProvider<
  MonthlyReportExportController,
  MonthlyReportExportState
>
monthlyReportExportControllerProvider =
    NotifierProvider.autoDispose<
      MonthlyReportExportController,
      MonthlyReportExportState
    >(MonthlyReportExportController.new);

final class MonthlyReportExportController
    extends AutoDisposeNotifier<MonthlyReportExportState> {
  @override
  MonthlyReportExportState build() => const MonthlyReportExportState();

  void clearFeedback() {
    state = const MonthlyReportExportState();
  }

  Future<bool> exportPdf(MonthlyReportExportOptions options) async {
    if (state.isBusy) return false;
    final MonthlyReportData? report = ref
        .read(monthlyReportProvider)
        .valueOrNull;
    final MonthlyComparisonData? comparison = ref
        .read(monthlyComparisonProvider)
        .valueOrNull;
    if (report == null || comparison == null) {
      state = const MonthlyReportExportState(
        feedback: 'The monthly report is still loading. Try again.',
      );
      return false;
    }
    state = const MonthlyReportExportState(isBusy: true);
    try {
      final DateTime now = ref.read(appClockProvider)();
      final Uint8List bytes = await ref
          .read(monthlyReportPdfServiceProvider)
          .generate(
            report: report,
            comparison: comparison,
            options: options,
            generatedAt: now,
          );
      final DocumentSaveResult result = await ref
          .read(localDocumentServiceProvider)
          .save(
            suggestedName: _fileName(report.period, 'monthly-report', 'pdf'),
            extension: 'pdf',
            bytes: bytes,
          );
      state = MonthlyReportExportState(
        feedback: result == DocumentSaveResult.saved
            ? 'Monthly report PDF saved.'
            : 'PDF export cancelled.',
      );
      return result == DocumentSaveResult.saved;
    } catch (_) {
      state = const MonthlyReportExportState(
        feedback: 'The monthly report PDF could not be saved. Try again.',
      );
      return false;
    }
  }

  Future<bool> exportCsv() async {
    if (state.isBusy) return false;
    final MonthlyReportData? report = ref
        .read(monthlyReportProvider)
        .valueOrNull;
    final List<FinancialActivity>? activities = ref
        .read(financialActivityListProvider)
        .valueOrNull;
    if (report == null || activities == null) {
      state = const MonthlyReportExportState(
        feedback: 'The monthly report is still loading. Try again.',
      );
      return false;
    }
    state = const MonthlyReportExportState(isBusy: true);
    try {
      final List<FinancialTransaction> transactions = <FinancialTransaction>[];
      final List<FinancialTransfer> transfers = <FinancialTransfer>[];
      for (final FinancialActivity activity in activities) {
        switch (activity) {
          case TransactionActivity(:final transaction):
            transactions.add(transaction);
          case TransferActivity(:final transfer):
            transfers.add(transfer);
        }
      }
      final Uint8List bytes = ref
          .read(transactionCsvServiceProvider)
          .encodeForPeriod(
            transactions: transactions,
            transfers: transfers,
            period: report.period,
          );
      final DocumentSaveResult result = await ref
          .read(localDocumentServiceProvider)
          .save(
            suggestedName: _fileName(report.period, 'monthly-activity', 'csv'),
            extension: 'csv',
            bytes: bytes,
          );
      state = MonthlyReportExportState(
        feedback: result == DocumentSaveResult.saved
            ? 'Monthly activity CSV saved.'
            : 'CSV export cancelled.',
      );
      return result == DocumentSaveResult.saved;
    } catch (_) {
      state = const MonthlyReportExportState(
        feedback: 'The monthly activity CSV could not be saved. Try again.',
      );
      return false;
    }
  }

  String _fileName(CalendarPeriod period, String kind, String extension) {
    final String month = period.month.toString().padLeft(2, '0');
    return 'budgeting-$kind-${period.calendarSystem.shortLabel.toLowerCase()}-'
        '${period.year}-$month.$extension';
  }
}

Future<void> showMonthlyReportExportSheet({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  MonthlyReportExportOptions options = const MonthlyReportExportOptions();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Export monthly report',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose the sections to include. The PDF is created locally on this device.',
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: options.includeVisualCharts,
                  title: const Text('Visual charts'),
                  onChanged: (bool? value) => setState(() {
                    options = options.copyWith(
                      includeVisualCharts: value ?? false,
                    );
                  }),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: options.includeMonthComparison,
                  title: const Text('Month comparison'),
                  onChanged: (bool? value) => setState(() {
                    options = options.copyWith(
                      includeMonthComparison: value ?? false,
                    );
                  }),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: options.includeActivityList,
                  title: const Text('Recorded activity list'),
                  onChanged: (bool? value) => setState(() {
                    options = options.copyWith(
                      includeActivityList: value ?? false,
                    );
                  }),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    unawaited(
                      ref
                          .read(monthlyReportExportControllerProvider.notifier)
                          .exportPdf(options),
                    );
                  },
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('Create PDF'),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/data_portability/domain/services/local_document_service.dart';
import 'package:budgeting_app/features/data_portability/domain/services/transaction_csv_service.dart';
import 'package:budgeting_app/features/data_portability/presentation/controllers/data_portability_controller.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/monthly_reports/domain/services/monthly_report_service.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/controllers/monthly_report_export_controller.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/controllers/monthly_report_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  test(
    'monthly CSV uses the selected period and reports picker cancellation',
    () async {
      final BikramSambatCalendarService calendar =
          BikramSambatCalendarService();
      final period = calendar.periodFor(
        calendarSystem: AppCalendarSystem.gregorianAd,
        year: 2026,
        month: 8,
      );
      final List<FinancialActivity> activities = <FinancialActivity>[
        TransactionActivity(
          buildTestTransaction(id: 'august', merchant: 'August activity'),
        ),
        TransactionActivity(
          buildTestTransaction(
            id: 'july',
            merchant: 'July activity',
            occurredAt: DateTime.utc(2026, 7, 31),
          ),
        ),
      ];
      final report = MonthlyReportService(calendar).build(
        period: period,
        activities: activities,
        now: DateTime.utc(2026, 8, 4),
      );
      final _FakeDocumentService documents = _FakeDocumentService();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          localDocumentServiceProvider.overrideWithValue(documents),
          transactionCsvServiceProvider.overrideWithValue(
            TransactionCsvService(calendar),
          ),
          monthlyReportProvider.overrideWithValue(AsyncData(report)),
          financialActivityListProvider.overrideWithValue(
            AsyncData(activities),
          ),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        monthlyReportExportControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final bool saved = await container
          .read(monthlyReportExportControllerProvider.notifier)
          .exportCsv();

      expect(saved, isFalse);
      expect(
        documents.suggestedName,
        'budgeting-monthly-activity-ad-2026-08.csv',
      );
      expect(documents.extension, 'csv');
      final String csv = utf8.decode(documents.bytes!.sublist(3));
      expect(csv, contains('August activity'));
      expect(csv, isNot(contains('July activity')));
      expect(
        container.read(monthlyReportExportControllerProvider).feedback,
        'CSV export cancelled.',
      );
    },
  );
}

final class _FakeDocumentService implements LocalDocumentService {
  String? suggestedName;
  String? extension;
  Uint8List? bytes;

  @override
  Future<SelectedDocument?> openJson({required int maximumBytes}) async => null;

  @override
  Future<DocumentSaveResult> save({
    required String suggestedName,
    required String extension,
    required Uint8List bytes,
  }) async {
    this.suggestedName = suggestedName;
    this.extension = extension;
    this.bytes = bytes;
    return DocumentSaveResult.cancelled;
  }
}

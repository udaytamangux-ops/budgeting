import 'dart:convert';

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/features/data_portability/domain/services/transaction_csv_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  final TransactionCsvService service = TransactionCsvService(
    BikramSambatCalendarService(),
  );

  test('exports deterministic UTF-8 BOM CSV with AD and BS dates', () {
    final bytes = service.encode(<FinancialTransaction>[
      buildTestTransaction(
        id: 'later',
        type: TransactionType.income,
        minorUnits: 150000,
        category: TransactionCategory.salary,
        paymentMethod: PaymentMethod.bankAccount,
        merchant: 'पारिश्रमिक',
        note: 'Quoted "value"\nsecond line',
        occurredAt: DateTime.utc(2026, 8, 8, 12),
        createdAt: DateTime.utc(2026, 8, 8, 13),
      ),
      buildTestTransaction(
        id: 'earlier',
        minorUnits: 150050,
        paymentMethod: PaymentMethod.eSewa,
        merchant: 'Cafe, Patan',
        occurredAt: DateTime.utc(2026, 8, 7, 12),
        createdAt: DateTime.utc(2026, 8, 7, 13),
      ),
    ]);
    final String csv = utf8.decode(bytes);

    expect(bytes.take(3), <int>[0xef, 0xbb, 0xbf]);
    expect(csv, startsWith(TransactionCsvService.headers.join(',')));
    expect(csv, contains('7 August 2026,22 Shrawan 2083,Expense,1500.50'));
    expect(csv, contains('8 August 2026,23 Shrawan 2083,Income,1500'));
    expect(csv, contains('eSewa'));
    expect(csv, contains(PaymentMethod.bankAccount.label));
    expect(csv, contains('"Cafe, Patan"'));
    expect(csv, contains('"Quoted ""value""\nsecond line"'));
    expect(csv, contains('पारिश्रमिक'));
    expect(
      csv.indexOf('7 August 2026'),
      lessThan(csv.indexOf('8 August 2026')),
    );
  });

  test('empty export still contains the complete header', () {
    final String csv = utf8.decode(service.encode(const []));
    expect(csv.trim(), TransactionCsvService.headers.join(','));
  });
}

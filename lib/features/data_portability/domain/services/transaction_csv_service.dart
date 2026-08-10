import 'dart:convert';
import 'dart:typed_data';

import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class TransactionCsvService {
  const TransactionCsvService(this._calendarService);

  static const List<String> headers = <String>[
    'Date (AD)',
    'Date (BS)',
    'Type',
    'Amount (NPR)',
    'Category',
    'Payment method',
    'Merchant/Payer',
    'Note',
    'Created at',
  ];

  final AppCalendarService _calendarService;

  /// Includes a UTF-8 BOM so spreadsheet applications detect Nepali Unicode
  /// reliably. Values remain standards-compliant UTF-8 CSV.
  Uint8List encode(List<FinancialTransaction> transactions) {
    final List<FinancialTransaction> ordered =
        List<FinancialTransaction>.of(transactions)
          ..sort((FinancialTransaction a, FinancialTransaction b) {
            final int date = a.occurredAt.compareTo(b.occurredAt);
            if (date != 0) return date;
            final int created = a.createdAt.compareTo(b.createdAt);
            if (created != 0) return created;
            return a.id.compareTo(b.id);
          });
    final StringBuffer csv = StringBuffer('\uFEFF')
      ..writeln(headers.map(_escape).join(','));
    for (final FinancialTransaction transaction in ordered) {
      final List<String> row = <String>[
        _calendarService.formatDate(
          transaction.occurredAt,
          AppCalendarSystem.gregorianAd,
        ),
        _calendarService.formatDate(
          transaction.occurredAt,
          AppCalendarSystem.bikramSambatBs,
        ),
        transaction.type == TransactionType.expense ? 'Expense' : 'Income',
        _amount(transaction.amount.minorUnits),
        transaction.category.displayLabel,
        transaction.paymentMethod.label,
        transaction.merchant ?? '',
        transaction.note ?? '',
        transaction.createdAt.toUtc().toIso8601String(),
      ];
      csv.writeln(row.map(_escape).join(','));
    }
    return Uint8List.fromList(utf8.encode(csv.toString()));
  }

  String _amount(int minorUnits) {
    final bool negative = minorUnits < 0;
    final int absolute = minorUnits.abs();
    final int whole = absolute ~/ 100;
    final int minor = absolute % 100;
    final String sign = negative ? '-' : '';
    return minor == 0
        ? '$sign$whole'
        : '$sign$whole.${minor.toString().padLeft(2, '0')}';
  }

  String _escape(String value) {
    if (!value.contains(RegExp('[,"\r\n]'))) return value;
    return '"${value.replaceAll('"', '""')}"';
  }
}

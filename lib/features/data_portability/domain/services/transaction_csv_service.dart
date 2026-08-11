import 'dart:convert';
import 'dart:typed_data';

import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';

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
    'Transfer From',
    'Transfer To',
    'Transfer Destination',
    'Count as expense',
    'Expense category',
    'Transfer fee',
  ];

  final AppCalendarService _calendarService;

  /// Includes a UTF-8 BOM so spreadsheet applications detect Nepali Unicode.
  Uint8List encode(
    List<FinancialTransaction> transactions, {
    List<FinancialTransfer> transfers = const <FinancialTransfer>[],
  }) {
    final List<FinancialActivity> activities =
        <FinancialActivity>[
          ...transactions.map(TransactionActivity.new),
          ...transfers.map(TransferActivity.new),
        ]..sort((FinancialActivity a, FinancialActivity b) {
          final int date = a.occurredAt.compareTo(b.occurredAt);
          if (date != 0) return date;
          final int created = a.createdAt.compareTo(b.createdAt);
          if (created != 0) return created;
          return a.id.compareTo(b.id);
        });
    final StringBuffer csv = StringBuffer('\uFEFF')
      ..writeln(headers.map(_escape).join(','));
    for (final FinancialActivity activity in activities) {
      csv.writeln(_row(activity).map(_escape).join(','));
    }
    return Uint8List.fromList(utf8.encode(csv.toString()));
  }

  List<String> _row(FinancialActivity activity) {
    final List<String> common = <String>[
      _calendarService.formatDate(
        activity.occurredAt,
        AppCalendarSystem.gregorianAd,
      ),
      _calendarService.formatDate(
        activity.occurredAt,
        AppCalendarSystem.bikramSambatBs,
      ),
    ];
    return switch (activity) {
      TransactionActivity(:final transaction) => <String>[
        ...common,
        transaction.type == TransactionType.expense ? 'Expense' : 'Income',
        _amount(transaction.amount.minorUnits),
        transaction.category.displayLabel,
        transaction.paymentMethod.label,
        transaction.merchant ?? '',
        transaction.note ?? '',
        transaction.createdAt.toUtc().toIso8601String(),
        '',
        '',
        '',
        '',
        '',
        '',
      ],
      TransferActivity(:final transfer) => <String>[
        ...common,
        'Transfer',
        _amount(transfer.amount.minorUnits),
        '',
        '',
        '',
        transfer.note ?? '',
        transfer.createdAt.toUtc().toIso8601String(),
        transfer.source.label,
        transfer.destination.label,
        transfer.destinationName ?? '',
        transfer.countsAsExpense ? 'Yes' : 'No',
        transfer.expenseCategory?.displayLabel ?? '',
        _amount(transfer.fee.minorUnits),
      ],
    };
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

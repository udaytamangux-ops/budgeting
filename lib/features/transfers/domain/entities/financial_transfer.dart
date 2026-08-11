import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';

final class FinancialTransfer {
  FinancialTransfer({
    required this.id,
    required this.amount,
    required this.source,
    required this.destination,
    required this.countsAsExpense,
    required this.fee,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.destinationName,
    this.expenseCategory,
    this.note,
  }) : assert(id != ''),
       assert(amount.minorUnits > 0),
       assert(fee.minorUnits >= 0),
       assert(occurredAt.isUtc),
       assert(createdAt.isUtc),
       assert(updatedAt.isUtc),
       assert(
         destination.requiresName
             ? destinationName != null && destinationName != ''
             : destinationName == null,
       ),
       assert(countsAsExpense == (expenseCategory != null)),
       assert(
         expenseCategory == null ||
             expenseCategory.supports(TransactionType.expense),
       );

  static const Object _notProvided = Object();

  final String id;
  final Money amount;
  final TransferSource source;
  final TransferDestination destination;
  final String? destinationName;
  final bool countsAsExpense;
  final TransactionCategory? expenseCategory;
  final Money fee;
  final DateTime occurredAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get destinationDisplayName => destinationName ?? destination.label;

  FinancialTransfer copyWith({
    Money? amount,
    TransferSource? source,
    TransferDestination? destination,
    Object? destinationName = _notProvided,
    bool? countsAsExpense,
    Object? expenseCategory = _notProvided,
    Money? fee,
    DateTime? occurredAt,
    Object? note = _notProvided,
    DateTime? updatedAt,
  }) {
    return FinancialTransfer(
      id: id,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      destinationName: identical(destinationName, _notProvided)
          ? this.destinationName
          : destinationName as String?,
      countsAsExpense: countsAsExpense ?? this.countsAsExpense,
      expenseCategory: identical(expenseCategory, _notProvided)
          ? this.expenseCategory
          : expenseCategory as TransactionCategory?,
      fee: fee ?? this.fee,
      occurredAt: occurredAt ?? this.occurredAt,
      note: identical(note, _notProvided) ? this.note : note as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

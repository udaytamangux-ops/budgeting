import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class FinancialTransaction {
  FinancialTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.note,
  }) : assert(id != ''),
       assert(amount.minorUnits > 0),
       assert(occurredAt.isUtc),
       assert(createdAt.isUtc),
       assert(updatedAt.isUtc);

  static const Object _notProvided = Object();

  final String id;
  final TransactionType type;
  final Money amount;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final DateTime occurredAt;
  final String? merchant;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialTransaction copyWith({
    TransactionType? type,
    Money? amount,
    TransactionCategory? category,
    PaymentMethod? paymentMethod,
    DateTime? occurredAt,
    Object? merchant = _notProvided,
    Object? note = _notProvided,
    DateTime? updatedAt,
  }) {
    return FinancialTransaction(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      occurredAt: occurredAt ?? this.occurredAt,
      merchant: identical(merchant, _notProvided)
          ? this.merchant
          : merchant as String?,
      note: identical(note, _notProvided) ? this.note : note as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class RecurringTransactionOccurrence {
  const RecurringTransactionOccurrence({
    required this.id,
    required this.ruleId,
    required this.dueDateAd,
    required this.status,
    required this.type,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.createdAt,
    this.merchant,
    this.note,
    this.recordedTransactionId,
    this.handledAt,
  });

  final String id;
  final String ruleId;
  final DateTime dueDateAd;
  final RecurringOccurrenceStatus status;
  final TransactionType type;
  final Money amount;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final String? merchant;
  final String? note;
  final String? recordedTransactionId;
  final DateTime? handledAt;
  final DateTime createdAt;
}

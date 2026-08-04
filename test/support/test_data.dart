import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final DateTime fixedNow = DateTime.utc(2026, 8, 4, 6, 15);

FinancialTransaction buildTestTransaction({
  String id = 'test-transaction',
  TransactionType type = TransactionType.expense,
  int minorUnits = 125000,
  TransactionCategory category = TransactionCategory.food,
  PaymentMethod paymentMethod = PaymentMethod.cash,
  String? merchant = 'Lunch at Thamel',
  String? note = 'Team lunch',
  DateTime? occurredAt,
  DateTime? createdAt,
}) {
  final DateTime created = createdAt ?? fixedNow;
  return FinancialTransaction(
    id: id,
    type: type,
    amount: Money(minorUnits: minorUnits),
    category: category,
    paymentMethod: paymentMethod,
    occurredAt: occurredAt ?? DateTime.utc(2026, 8, 4, 6, 15),
    merchant: merchant,
    note: note,
    createdAt: created,
    updatedAt: created,
  );
}

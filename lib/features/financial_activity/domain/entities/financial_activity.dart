import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';

enum FinancialActivityType { expense, income, transfer }

sealed class FinancialActivity {
  const FinancialActivity();

  String get id;
  FinancialActivityType get type;
  Money get amount;
  DateTime get occurredAt;
  DateTime get createdAt;
  DateTime get updatedAt;
  String? get note;
}

final class TransactionActivity extends FinancialActivity {
  const TransactionActivity(this.transaction);

  final FinancialTransaction transaction;

  @override
  String get id => transaction.id;

  @override
  FinancialActivityType get type => transaction.type == TransactionType.income
      ? FinancialActivityType.income
      : FinancialActivityType.expense;

  @override
  Money get amount => transaction.amount;

  @override
  DateTime get occurredAt => transaction.occurredAt;

  @override
  DateTime get createdAt => transaction.createdAt;

  @override
  DateTime get updatedAt => transaction.updatedAt;

  @override
  String? get note => transaction.note;
}

final class TransferActivity extends FinancialActivity {
  const TransferActivity(this.transfer);

  final FinancialTransfer transfer;

  @override
  String get id => transfer.id;

  @override
  FinancialActivityType get type => FinancialActivityType.transfer;

  @override
  Money get amount => transfer.amount;

  @override
  DateTime get occurredAt => transfer.occurredAt;

  @override
  DateTime get createdAt => transfer.createdAt;

  @override
  DateTime get updatedAt => transfer.updatedAt;

  @override
  String? get note => transfer.note;
}

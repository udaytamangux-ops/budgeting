import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:drift/drift.dart';

abstract final class TransactionDatabaseMapper {
  static StoredTransactionsCompanion toCompanion(
    FinancialTransaction transaction, {
    required String ownerScope,
  }) {
    return StoredTransactionsCompanion(
      id: Value<String>(transaction.id),
      typeKey: Value<String>(typeToKey(transaction.type)),
      amountMinorUnits: Value<int>(transaction.amount.minorUnits),
      currencyCode: Value<String>(transaction.amount.currencyCode),
      categoryKey: Value<String>(categoryToKey(transaction.category)),
      paymentMethodKey: Value<String>(
        paymentMethodToKey(transaction.paymentMethod),
      ),
      occurredAtUtcMicros: Value<int>(
        transaction.occurredAt.toUtc().microsecondsSinceEpoch,
      ),
      merchant: Value<String?>(transaction.merchant),
      note: Value<String?>(transaction.note),
      createdAtUtcMicros: Value<int>(
        transaction.createdAt.toUtc().microsecondsSinceEpoch,
      ),
      updatedAtUtcMicros: Value<int>(
        transaction.updatedAt.toUtc().microsecondsSinceEpoch,
      ),
      ownerScope: Value<String>(ownerScope),
    );
  }

  static FinancialTransaction fromRow(StoredTransaction row) {
    return FinancialTransaction(
      id: row.id,
      type: typeFromKey(row.typeKey),
      amount: Money(
        minorUnits: row.amountMinorUnits,
        currencyCode: row.currencyCode,
      ),
      category: categoryFromKey(row.categoryKey),
      paymentMethod: paymentMethodFromKey(row.paymentMethodKey),
      occurredAt: DateTime.fromMicrosecondsSinceEpoch(
        row.occurredAtUtcMicros,
        isUtc: true,
      ),
      merchant: row.merchant,
      note: row.note,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(
        row.createdAtUtcMicros,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(
        row.updatedAtUtcMicros,
        isUtc: true,
      ),
    );
  }

  static String typeToKey(TransactionType type) => switch (type) {
    TransactionType.expense => 'expense',
    TransactionType.income => 'income',
  };

  static TransactionType typeFromKey(String key) => switch (key) {
    'expense' => TransactionType.expense,
    'income' => TransactionType.income,
    _ => throw const FormatException('Unsupported stored transaction type.'),
  };

  static String paymentMethodToKey(PaymentMethod method) =>
      method.stableIdentifier;

  static PaymentMethod paymentMethodFromKey(String key) =>
      PaymentMethodCodec.decode(key);

  static String categoryToKey(TransactionCategory category) =>
      switch (category) {
        TransactionCategory.food => 'food',
        TransactionCategory.transport => 'transport',
        TransactionCategory.rentAndHousing => 'rent_and_housing',
        TransactionCategory.utilities => 'utilities',
        TransactionCategory.shopping => 'shopping',
        TransactionCategory.health => 'health',
        TransactionCategory.education => 'education',
        TransactionCategory.entertainment => 'entertainment',
        TransactionCategory.family => 'family',
        TransactionCategory.feesAndCharges => 'fees_and_charges',
        TransactionCategory.salary => 'salary',
        TransactionCategory.freelance => 'freelance',
        TransactionCategory.business => 'business',
        TransactionCategory.allowance => 'allowance',
        TransactionCategory.remittance => 'remittance',
        TransactionCategory.gift => 'gift',
        TransactionCategory.refund => 'refund',
        TransactionCategory.other => 'other',
      };

  static TransactionCategory categoryFromKey(String key) => switch (key) {
    'food' => TransactionCategory.food,
    'transport' => TransactionCategory.transport,
    'rent_and_housing' => TransactionCategory.rentAndHousing,
    'utilities' => TransactionCategory.utilities,
    'shopping' => TransactionCategory.shopping,
    'health' => TransactionCategory.health,
    'education' => TransactionCategory.education,
    'entertainment' => TransactionCategory.entertainment,
    'family' => TransactionCategory.family,
    'fees_and_charges' => TransactionCategory.feesAndCharges,
    'salary' => TransactionCategory.salary,
    'freelance' => TransactionCategory.freelance,
    'business' => TransactionCategory.business,
    'allowance' => TransactionCategory.allowance,
    'remittance' => TransactionCategory.remittance,
    'gift' => TransactionCategory.gift,
    'refund' => TransactionCategory.refund,
    'other' => TransactionCategory.other,
    _ => throw const FormatException(
      'Unsupported stored transaction category.',
    ),
  };
}

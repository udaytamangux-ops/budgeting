import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/services/recent_payment_methods_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const RecentPaymentMethodsService service = RecentPaymentMethodsService();

  test('returns at most three distinct methods, most recently used first', () {
    final List<FinancialTransaction> transactions = <FinancialTransaction>[
      _transaction('cash-old', PaymentMethod.cash, 1),
      _transaction('card', PaymentMethod.card, 2),
      _transaction('cash-new', PaymentMethod.cash, 3),
      _transaction('esewa', PaymentMethod.eSewa, 4),
      _transaction('khalti', PaymentMethod.khalti, 5),
    ];

    expect(
      service.findForType(
        transactions: transactions,
        type: TransactionType.expense,
      ),
      <PaymentMethod>[
        PaymentMethod.khalti,
        PaymentMethod.eSewa,
        PaymentMethod.cash,
      ],
    );
  });

  test('keeps expense and income histories separate', () {
    final List<FinancialTransaction> transactions = <FinancialTransaction>[
      _transaction('expense', PaymentMethod.eSewa, 1),
      _transaction(
        'income',
        PaymentMethod.bankAccount,
        2,
        type: TransactionType.income,
      ),
    ];

    expect(
      service.findForType(
        transactions: transactions,
        type: TransactionType.expense,
      ),
      <PaymentMethod>[PaymentMethod.eSewa],
    );
    expect(
      service.findForType(
        transactions: transactions,
        type: TransactionType.income,
      ),
      <PaymentMethod>[PaymentMethod.bankAccount],
    );
  });

  test('non-positive limit returns no methods', () {
    expect(
      service.findForType(
        transactions: <FinancialTransaction>[
          _transaction('cash', PaymentMethod.cash, 1),
        ],
        type: TransactionType.expense,
        limit: 0,
      ),
      isEmpty,
    );
  });
}

FinancialTransaction _transaction(
  String id,
  PaymentMethod method,
  int minutes, {
  TransactionType type = TransactionType.expense,
}) {
  return buildTestTransaction(
    id: id,
    type: type,
    category: type == TransactionType.expense
        ? TransactionCategory.food
        : TransactionCategory.salary,
    paymentMethod: method,
    createdAt: fixedNow.add(Duration(minutes: minutes)),
  );
}

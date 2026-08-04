import 'dart:math';

import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

abstract final class MockTransactionSource {
  static List<FinancialTransaction> buildSeedData(DateTime now) {
    final DateTime localNow = now.toLocal();

    DateTime occurredOn(int preferredDay) {
      final int safeDay = min(preferredDay, localNow.day);
      return DateTime(localNow.year, localNow.month, safeDay, 12).toUtc();
    }

    DateTime createdMinutesAgo(int minutes) {
      return now.toUtc().subtract(Duration(minutes: minutes));
    }

    return <FinancialTransaction>[
      FinancialTransaction(
        id: 'seed-food-lunch',
        type: TransactionType.expense,
        amount: const Money(minorUnits: 330000),
        category: TransactionCategory.food,
        paymentMethod: PaymentMethod.eSewa,
        occurredAt: occurredOn(4),
        merchant: 'Kathmandu Lunch Club',
        note: 'Team lunch',
        createdAt: createdMinutesAgo(50),
        updatedAt: createdMinutesAgo(50),
      ),
      FinancialTransaction(
        id: 'seed-food-groceries',
        type: TransactionType.expense,
        amount: const Money(minorUnits: 220000),
        category: TransactionCategory.food,
        paymentMethod: PaymentMethod.card,
        occurredAt: occurredOn(3),
        merchant: 'Bhat-Bhateni',
        note: 'Weekly groceries',
        createdAt: createdMinutesAgo(90),
        updatedAt: createdMinutesAgo(90),
      ),
      FinancialTransaction(
        id: 'seed-utilities',
        type: TransactionType.expense,
        amount: const Money(minorUnits: 325000),
        category: TransactionCategory.utilities,
        paymentMethod: PaymentMethod.eSewa,
        occurredAt: occurredOn(3),
        merchant: 'Nepal Telecom',
        createdAt: createdMinutesAgo(100),
        updatedAt: createdMinutesAgo(100),
      ),
      FinancialTransaction(
        id: 'seed-transport',
        type: TransactionType.expense,
        amount: const Money(minorUnits: 200000),
        category: TransactionCategory.transport,
        paymentMethod: PaymentMethod.cash,
        occurredAt: occurredOn(2),
        merchant: 'Pathao rides',
        createdAt: createdMinutesAgo(120),
        updatedAt: createdMinutesAgo(120),
      ),
      FinancialTransaction(
        id: 'seed-rent',
        type: TransactionType.expense,
        amount: const Money(minorUnits: 1200000),
        category: TransactionCategory.rentAndHousing,
        paymentMethod: PaymentMethod.bankAccount,
        occurredAt: occurredOn(1),
        merchant: 'Monthly rent',
        createdAt: createdMinutesAgo(140),
        updatedAt: createdMinutesAgo(140),
      ),
      FinancialTransaction(
        id: 'seed-salary',
        type: TransactionType.income,
        amount: const Money(minorUnits: 6000000),
        category: TransactionCategory.salary,
        paymentMethod: PaymentMethod.bankAccount,
        occurredAt: occurredOn(1),
        merchant: 'Monthly salary',
        createdAt: createdMinutesAgo(160),
        updatedAt: createdMinutesAgo(160),
      ),
    ];
  }
}

import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';

final class FinancialEffect {
  const FinancialEffect({
    required this.incomeImpact,
    required this.expenseImpact,
    required this.expenseCategoryContributions,
  });

  final Money incomeImpact;
  final Money expenseImpact;
  final Map<TransactionCategory, Money> expenseCategoryContributions;
}

final class FinancialEffectService {
  const FinancialEffectService();

  FinancialEffect forActivity(FinancialActivity activity) => switch (activity) {
    TransactionActivity(:final transaction) => forTransaction(transaction),
    TransferActivity(:final transfer) => forTransfer(transfer),
  };

  FinancialEffect forTransaction(FinancialTransaction transaction) {
    if (transaction.type == TransactionType.income) {
      return FinancialEffect(
        incomeImpact: transaction.amount,
        expenseImpact: const Money.zero(),
        expenseCategoryContributions: const <TransactionCategory, Money>{},
      );
    }
    return FinancialEffect(
      incomeImpact: const Money.zero(),
      expenseImpact: transaction.amount,
      expenseCategoryContributions: <TransactionCategory, Money>{
        transaction.category: transaction.amount,
      },
    );
  }

  FinancialEffect forTransfer(FinancialTransfer transfer) {
    Money expense = const Money.zero();
    final Map<TransactionCategory, Money> contributions =
        <TransactionCategory, Money>{};
    if (transfer.countsAsExpense) {
      expense += transfer.amount;
      contributions[transfer.expenseCategory!] = transfer.amount;
    }
    if (transfer.fee.isPositive) {
      expense += transfer.fee;
      contributions.update(
        TransactionCategory.feesAndCharges,
        (Money current) => current + transfer.fee,
        ifAbsent: () => transfer.fee,
      );
    }
    return FinancialEffect(
      incomeImpact: const Money.zero(),
      expenseImpact: expense,
      expenseCategoryContributions:
          Map<TransactionCategory, Money>.unmodifiable(contributions),
    );
  }

  List<FinancialActivity> sortNewestFirst(
    Iterable<FinancialActivity> activities,
  ) {
    final List<FinancialActivity> sorted = activities.toList();
    sorted.sort((FinancialActivity first, FinancialActivity second) {
      final int occurred = second.occurredAt.compareTo(first.occurredAt);
      if (occurred != 0) return occurred;
      final int created = second.createdAt.compareTo(first.createdAt);
      if (created != 0) return created;
      return second.id.compareTo(first.id);
    });
    return List<FinancialActivity>.unmodifiable(sorted);
  }
}

import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HomePeriodFinancials {
  const HomePeriodFinancials({
    required this.period,
    required this.monthly,
    required this.closingRecordedBalance,
  });

  final CalendarPeriod period;
  final MonthlyFinancialSummary monthly;
  final Money closingRecordedBalance;
}

final Provider<AsyncValue<HomePeriodFinancials>> homePeriodFinancialsProvider =
    Provider<AsyncValue<HomePeriodFinancials>>((Ref ref) {
      final CalendarPeriod period = ref.watch(
        effectiveSelectedCalendarPeriodProvider,
      );
      return ref.watch(transactionListProvider).whenData((transactions) {
        final MonthlyFinancialSummary monthly = const FinancialSummaryService()
            .calculateForPeriod(transactions: transactions, period: period);
        Money balance = const Money.zero();
        for (final FinancialTransaction transaction in transactions) {
          if (!transaction.occurredAt.isBefore(period.endAdExclusive)) {
            continue;
          }
          balance = transaction.type == TransactionType.income
              ? balance + transaction.amount
              : balance - transaction.amount;
        }
        return HomePeriodFinancials(
          period: period,
          monthly: monthly,
          closingRecordedBalance: balance,
        );
      });
    });

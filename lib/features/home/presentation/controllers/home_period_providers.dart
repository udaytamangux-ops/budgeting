import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';
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
      return ref.watch(financialActivityListProvider).whenData((activities) {
        final transactions = activities
            .whereType<TransactionActivity>()
            .map((value) => value.transaction)
            .toList(growable: false);
        final transfers = activities
            .whereType<TransferActivity>()
            .map((value) => value.transfer)
            .toList(growable: false);
        final MonthlyFinancialSummary monthly = const FinancialSummaryService()
            .calculateForPeriod(
              transactions: transactions,
              transfers: transfers,
              period: period,
            );
        final Money balance = const FinancialSummaryService()
            .closingRecordedBalanceThrough(
              activities: activities,
              endAdExclusive: period.endAdExclusive,
            );
        return HomePeriodFinancials(
          period: period,
          monthly: monthly,
          closingRecordedBalance: balance,
        );
      });
    });

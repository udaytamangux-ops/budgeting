import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/domain/services/category_activity_service.dart';
import 'package:budgeting_app/features/summary/domain/services/transaction_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef MonthlyCategoryActivityRequest = ({
  DateTime month,
  TransactionType type,
});

final class CategoryActivityDetailsRequest {
  CategoryActivityDetailsRequest({
    required DateTime month,
    required this.type,
    required List<TransactionCategory> categories,
  }) : month = DateTime(month.year, month.month),
       categories = List<TransactionCategory>.unmodifiable(categories);

  final DateTime month;
  final TransactionType type;
  final List<TransactionCategory> categories;

  @override
  bool operator ==(Object other) {
    if (other is! CategoryActivityDetailsRequest ||
        month != other.month ||
        type != other.type ||
        categories.length != other.categories.length) {
      return false;
    }
    for (int index = 0; index < categories.length; index += 1) {
      if (categories[index] != other.categories[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(month, type, Object.hashAll(categories));
}

final ProviderFamily<
  AsyncValue<MonthlyCategoryActivity>,
  MonthlyCategoryActivityRequest
>
monthlyCategoryActivityProvider =
    Provider.family<
      AsyncValue<MonthlyCategoryActivity>,
      MonthlyCategoryActivityRequest
    >((Ref ref, request) {
      return ref
          .watch(transactionListProvider)
          .whenData(
            (List<FinancialTransaction> transactions) =>
                const CategoryActivityService().calculateForMonth(
                  transactions: transactions,
                  month: request.month,
                  type: request.type,
                ),
          );
    });

final ProviderFamily<
  AsyncValue<CategoryActivityDetails>,
  CategoryActivityDetailsRequest
>
categoryActivityDetailsProvider =
    Provider.family<
      AsyncValue<CategoryActivityDetails>,
      CategoryActivityDetailsRequest
    >((Ref ref, request) {
      return ref
          .watch(transactionListProvider)
          .whenData(
            (List<FinancialTransaction> transactions) =>
                const CategoryActivityService().calculateForCategories(
                  transactions: transactions,
                  month: request.month,
                  type: request.type,
                  categories: request.categories,
                ),
          );
    });

final ProviderFamily<AsyncValue<MonthlyTransactionSummary>, DateTime>
monthlyTransactionSummaryForMonthProvider =
    Provider.family<AsyncValue<MonthlyTransactionSummary>, DateTime>((
      Ref ref,
      DateTime month,
    ) {
      final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
        transactionListProvider,
      );
      return transactions.whenData(
        (List<FinancialTransaction> value) => const TransactionSummaryService()
            .calculateForMonth(transactions: value, month: month),
      );
    });

final Provider<AsyncValue<MonthlyTransactionSummary>>
currentMonthlyTransactionSummaryProvider =
    Provider<AsyncValue<MonthlyTransactionSummary>>((Ref ref) {
      final DateTime currentDate = ref.watch(currentDateProvider);
      return ref.watch(
        monthlyTransactionSummaryForMonthProvider(
          DateTime(currentDate.year, currentDate.month),
        ),
      );
    });

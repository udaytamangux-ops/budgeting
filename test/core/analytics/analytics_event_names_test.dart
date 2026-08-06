import 'package:budgeting_app/core/analytics/analytics_event_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core-flow analytics event names remain stable', () {
    expect(
      <String>{
        AnalyticsEventNames.recentCategorySelected,
        AnalyticsEventNames.paymentMethodReused,
        AnalyticsEventNames.quickDateSelected,
        AnalyticsEventNames.transactionRepeatStarted,
        AnalyticsEventNames.transactionRepeated,
        AnalyticsEventNames.transactionCreated,
        AnalyticsEventNames.transactionCreateUndone,
        AnalyticsEventNames.summaryCategorySelected,
        AnalyticsEventNames.summaryAllCategoriesSelected,
        AnalyticsEventNames.categoryDetailsOpened,
        AnalyticsEventNames.categoryTransactionOpened,
      },
      <String>{
        'recent_category_selected',
        'payment_method_reused',
        'quick_date_selected',
        'transaction_repeat_started',
        'transaction_repeated',
        'transaction_created',
        'transaction_create_undone',
        'summary_category_selected',
        'summary_all_categories_selected',
        'category_details_opened',
        'category_transaction_opened',
      },
    );
  });
}

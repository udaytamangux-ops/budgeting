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
      },
      <String>{
        'recent_category_selected',
        'payment_method_reused',
        'quick_date_selected',
        'transaction_repeat_started',
        'transaction_repeated',
        'transaction_created',
        'transaction_create_undone',
      },
    );
  });
}

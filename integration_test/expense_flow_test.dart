import 'package:budgeting_app/app/app.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home to expense save to updated Home to details', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.utc(2026, 8, 4, 6, 15);
    final InMemoryTransactionRepository repository =
        InMemoryTransactionRepository(now: () => now);
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          appClockProvider.overrideWithValue(() => now),
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
        child: const BudgetingApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey<String>('home_content')),
      const Offset(0, -160),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '1250',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('payment_method_field')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('payment_method_field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash').last);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('optional_fields_toggle')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('merchant_input')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('merchant_input')),
      'Lunch at Thamel',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('NPR 0'), findsOneWidget);
    expect(find.text('NPR 1,250'), findsOneWidget);
    expect(find.text('1 transaction recorded'), findsOneWidget);
    expect(find.text('Spent across 1 category'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'Recorded balance, .*NPR 1,250.*Monthly income, NPR 0.*'
          r'Monthly expenses, NPR 1,250',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Recorded balance'), findsOneWidget);
    expect(find.text('Monthly budget'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Lunch at Thamel'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lunch at Thamel'), findsOneWidget);
    final TransactionListItem firstItem = tester
        .widgetList<TransactionListItem>(find.byType(TransactionListItem))
        .first;
    expect(firstItem.transaction.merchant, 'Lunch at Thamel');

    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('NPR 1,250'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);

    final List<FinancialTransaction> transactions = await repository
        .watchTransactions()
        .first;
    expect(transactions.first.merchant, 'Lunch at Thamel');
  });
}

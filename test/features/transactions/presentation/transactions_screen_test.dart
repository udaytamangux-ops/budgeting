import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('transactions are grouped and searchable with clear filters', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('2 August 2026'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('2 August 2026'), findsOneWidget);
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, 1000),
      1000,
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('transaction_search_field')),
      'Bhat-Bhateni',
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(TransactionListItem),
        matching: find.text('Bhat-Bhateni'),
      ),
      findsOneWidget,
    );
    expect(find.text('Kathmandu Lunch Club'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey<String>('transaction_search_field')),
      'not a merchant',
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(find.text('No matching transactions'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('clear_transaction_filters')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kathmandu Lunch Club'), findsOneWidget);
    expect(find.text('No matching transactions'), findsNothing);
  });

  testWidgets('completely empty history offers the existing add journey', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpBudgetingApp(tester);
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('No activity yet'), findsOneWidget);
    expect(
      find.text('Your expenses, income and transfers will appear here.'),
      findsOneWidget,
    );
    expect(find.text('Add your first activity'), findsOneWidget);
    final Finder action = find.byKey(
      const ValueKey<String>('empty_transactions_add_button'),
    );
    expect(action, findsOneWidget);
    expect(tester.getSemantics(action).label, 'Add your first activity');

    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('Add transaction'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a month without matches remains distinct from empty history', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'previous-month-only',
          occurredAt: DateTime.utc(2026, 7, 12, 6, 15),
        ),
      ],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('No transactions in August 2026'), findsOneWidget);
    expect(
      find.text('No recorded financial activity for this month.'),
      findsOneWidget,
    );
    expect(find.text('No transactions recorded yet'), findsNothing);
    expect(find.text('Current month'), findsNothing);
  });
}

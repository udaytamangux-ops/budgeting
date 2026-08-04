import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Transaction Details displays the complete record', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction();
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('NPR 1,250'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Lunch at Thamel'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Team lunch'), findsOneWidget);
    expect(find.text('4 August 2026'), findsOneWidget);
  });

  testWidgets('Delete confirmation explains the financial consequence', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction();
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('delete_transaction_button')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('delete_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete this transaction?'), findsOneWidget);
    expect(find.text('Food · NPR 1,250 · 4 August 2026'), findsOneWidget);
    expect(
      find.text(
        'Deleting it will update your available balance and monthly budget.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Delete transaction'),
      findsOneWidget,
    );
  });
}

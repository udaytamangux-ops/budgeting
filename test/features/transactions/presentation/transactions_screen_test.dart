import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('transactions are grouped and searchable with clear filters', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('2 August 2026'), findsOneWidget);

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
}

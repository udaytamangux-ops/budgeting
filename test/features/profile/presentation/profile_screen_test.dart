import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('Profile shows mock identity and preference structure', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Aarav Shrestha'), findsOneWidget);
    expect(find.text('aarav.shrestha@example.com'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('NPR · Nepalese rupee'), findsOneWidget);
    expect(find.text('Date format'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Not configured'), findsOneWidget);
    expect(find.text('Budget reminders are off'), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('privacy_and_data_setting')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text('Review how your records are stored and managed'),
      findsOneWidget,
    );
    expect(
      find.text('Understand where prototype data is stored'),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.text('Developer information'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Developer information'), findsOneWidget);
    expect(find.text('Debug information'), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('privacy_and_data_setting')),
      -280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('privacy_and_data_setting')),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Transactions and preferences in this prototype'),
      findsOneWidget,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('New Transaction sheet exposes a truthful Transfer form', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpBudgetingApp(tester);

    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('transaction_type_transfer')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add transaction'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('transfer_source_selector')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('transfer_destination_selector')),
      160,
      scrollable: _formScrollable(),
    );
    expect(
      find.byKey(const ValueKey<String>('transfer_destination_selector')),
      findsOneWidget,
    );
    expect(find.text('Payment method'), findsNothing);
    expect(find.text('Merchant (optional)'), findsNothing);
    await tester.drag(_formScrollable(), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(find.text('Count as expense'), findsOneWidget);
    expect(find.text('Expense category'), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets(
    'Count as expense reveals category and blank transfer stays neutral',
    (WidgetTester tester) async {
      await pumpBudgetingApp(tester);
      await tester.tap(
        find.byKey(const ValueKey<String>('central_add_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('transaction_type_transfer')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Amount must be greater than NPR 0.'), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('transfer_counts_as_expense')),
        180,
        scrollable: _formScrollable(),
      );
      await tester.drag(_formScrollable(), const Offset(0, -40));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('transfer_counts_as_expense')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Expense category'), findsOneWidget);
      expect(find.text('Save transfer'), findsOneWidget);
    },
  );
}

Finder _formScrollable() => find
    .descendant(
      of: find.byKey(const ValueKey<String>('add_transfer_form_scroll')),
      matching: find.byType(Scrollable),
    )
    .first;

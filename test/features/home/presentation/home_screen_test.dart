import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('Home renders the connected monthly financial summary', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    expect(find.text('NPR 37,250'), findsOneWidget);
    expect(find.text('NPR 60,000'), findsOneWidget);
    expect(find.text('NPR 22,750'), findsOneWidget);
    expect(find.text('57% used'), findsOneWidget);
    expect(find.text('NPR 17,250 left'), findsOneWidget);
    expect(find.text('NPR 2,500 remains from the food limit.'), findsOneWidget);
  });

  testWidgets('Home renders a useful empty state', (WidgetTester tester) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: const <FinancialTransaction>[],
    );

    expect(find.text('No transactions yet'), findsOneWidget);
    expect(
      find.text(
        'Add your first income or expense to start understanding where your money goes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Add expense'), findsOneWidget);
  });

  testWidgets('Home renders loading and repository error states', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      transactionStream: const Stream<List<FinancialTransaction>>.empty(),
    );
    expect(find.bySemanticsLabel('Loading financial summary'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpBudgetingApp(
      tester,
      transactionStream: Stream<List<FinancialTransaction>>.error(
        StateError('Controlled repository failure'),
      ),
    );
    expect(
      find.text('Your financial summary is unavailable. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}

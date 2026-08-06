import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category route contains only explicit non-financial context', () {
    final CategoryDetailsRouteData data = CategoryDetailsRouteData(
      type: TransactionType.expense,
      categories: <TransactionCategory>[
        TransactionCategory.food,
        TransactionCategory.transport,
      ],
      month: DateTime(2026, 7, 18),
    );

    final String route = AppRoutes.categoryDetails(data);

    expect(route, contains('/expense/food%2Ctransport'));
    expect(route, contains('year=2026&month=7'));
    expect(route, isNot(contains('NPR')));
    expect(route, isNot(contains('amount')));
    expect(route, isNot(contains('merchant')));
  });

  test('route parsing preserves type, categories, month, and year', () {
    final CategoryDetailsRouteData? parsed = CategoryDetailsRouteData.tryParse(
      typeIdentifier: 'income',
      categoryIdentifiers: 'salary,freelance',
      year: '2026',
      month: '7',
    );

    expect(parsed, isNotNull);
    expect(parsed?.type, TransactionType.income);
    expect(parsed?.categories, <TransactionCategory>[
      TransactionCategory.salary,
      TransactionCategory.freelance,
    ]);
    expect(parsed?.month, DateTime(2026, 7));
  });

  test('route parsing rejects invalid and type-incompatible identifiers', () {
    expect(
      CategoryDetailsRouteData.tryParse(
        typeIdentifier: 'income',
        categoryIdentifiers: 'food',
        year: '2026',
        month: '7',
      ),
      isNull,
    );
    expect(
      CategoryDetailsRouteData.tryParse(
        typeIdentifier: 'expense',
        categoryIdentifiers: 'food',
        year: '2026',
        month: '13',
      ),
      isNull,
    );
  });
}

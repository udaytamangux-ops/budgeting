import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
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

  test('BS category routes preserve their calendar period identifier', () {
    final CategoryDetailsRouteData data = CategoryDetailsRouteData(
      type: TransactionType.expense,
      categories: const <TransactionCategory>[TransactionCategory.food],
      period: BikramSambatCalendarService().periodFor(
        calendarSystem: AppCalendarSystem.bikramSambatBs,
        year: 2083,
        month: 4,
      ),
    );

    final Uri route = Uri.parse(AppRoutes.categoryDetails(data));
    final CategoryDetailsRouteData? parsed = CategoryDetailsRouteData.tryParse(
      typeIdentifier: 'expense',
      categoryIdentifiers: 'food',
      calendarSystem: route.queryParameters['calendar'],
      year: route.queryParameters['year'],
      month: route.queryParameters['month'],
    );

    expect(route.queryParameters['calendar'], 'bikram_sambat_bs');
    expect(parsed?.period.calendarSystem, AppCalendarSystem.bikramSambatBs);
    expect(parsed?.period.year, 2083);
    expect(parsed?.period.month, 4);
    expect(parsed?.period.startAdInclusive, DateTime.utc(2026, 7, 17));
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

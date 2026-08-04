import 'package:budgeting_app/features/transactions/domain/services/transaction_date_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const TransactionDateService service = TransactionDateService();

  test('today normalizes to the local calendar date', () {
    expect(service.today(DateTime(2026, 8, 4, 18, 30)), DateTime(2026, 8, 4));
  });

  test('yesterday crosses month and year boundaries correctly', () {
    expect(service.yesterday(DateTime(2027, 1, 1, 9)), DateTime(2026, 12, 31));
    expect(service.yesterday(DateTime(2028, 3, 1, 9)), DateTime(2028, 2, 29));
  });

  test('identifies today, yesterday, and a chosen date', () {
    final DateTime currentDate = DateTime(2026, 8, 4, 9);

    expect(
      service.selectionFor(
        selectedDate: DateTime(2026, 8, 4, 18),
        currentDate: currentDate,
      ),
      QuickDateSelection.today,
    );
    expect(
      service.selectionFor(
        selectedDate: DateTime(2026, 8, 3),
        currentDate: currentDate,
      ),
      QuickDateSelection.yesterday,
    );
    expect(
      service.selectionFor(
        selectedDate: DateTime(2026, 7, 31),
        currentDate: currentDate,
      ),
      QuickDateSelection.chosenDate,
    );
  });
}

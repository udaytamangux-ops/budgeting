import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('adds minor units without losing precision', () {
      const Money first = Money(minorUnits: 125050);
      const Money second = Money(minorUnits: 49950);

      expect(first + second, const Money(minorUnits: 175000));
    });

    test('subtracts minor units without losing precision', () {
      const Money available = Money(minorUnits: 4000000);
      const Money spent = Money(minorUnits: 2400000);

      expect(available - spent, const Money(minorUnits: 1600000));
    });

    test('compares values in the same currency', () {
      const Money smaller = Money(minorUnits: 125000);
      const Money larger = Money(minorUnits: 2400000);

      expect(smaller < larger, isTrue);
      expect(larger > smaller, isTrue);
      expect(smaller.compareTo(const Money(minorUnits: 125000)), 0);
    });

    test('rejects arithmetic across currencies', () {
      const Money npr = Money(minorUnits: 100, currencyCode: 'NPR');
      const Money usd = Money(minorUnits: 100, currencyCode: 'USD');

      expect(() => npr + usd, throwsArgumentError);
    });
  });
}

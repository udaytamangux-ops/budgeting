import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final CurrencyFormatter formatter = CurrencyFormatter();

  test('formats whole NPR values without unnecessary decimals', () {
    expect(formatter.format(const Money(minorUnits: 6000000)), 'NPR 60,000');
  });

  test('formats minor units when they are present', () {
    expect(formatter.format(const Money(minorUnits: 125050)), 'NPR 1,250.50');
  });

  test('formats negative values with a typographic minus', () {
    expect(formatter.format(const Money(minorUnits: -125000)), '−NPR 1,250');
  });

  test('formats positive net changes with an explicit plus sign', () {
    expect(
      formatter.formatSigned(const Money(minorUnits: 3725000)),
      '+NPR 37,250',
    );
    expect(
      formatter.formatSigned(const Money(minorUnits: -125000)),
      '−NPR 1,250',
    );
  });
}

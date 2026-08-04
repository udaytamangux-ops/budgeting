import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:intl/intl.dart';

final class CurrencyFormatter {
  CurrencyFormatter({String locale = 'en_NP'})
    : _integerFormatter = NumberFormat.decimalPattern(locale);

  final NumberFormat _integerFormatter;

  String format(Money money) {
    final int absoluteMinorUnits = money.minorUnits.abs();
    final int wholeUnits = absoluteMinorUnits ~/ 100;
    final int remainingMinorUnits = absoluteMinorUnits % 100;
    final String groupedWholeUnits = _integerFormatter.format(wholeUnits);
    final String decimalPart = remainingMinorUnits == 0
        ? ''
        : '.${remainingMinorUnits.toString().padLeft(2, '0')}';
    final String sign = money.isNegative ? '−' : '';
    return '$sign${money.currencyCode} $groupedWholeUnits$decimalPart';
  }
}

import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/formatting/date_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<CurrencyFormatter> currencyFormatterProvider =
    Provider<CurrencyFormatter>((Ref ref) => CurrencyFormatter());

final Provider<DateFormatter> dateFormatterProvider = Provider<DateFormatter>(
  (Ref ref) => DateFormatter(),
);

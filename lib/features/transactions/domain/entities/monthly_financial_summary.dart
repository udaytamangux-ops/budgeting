import 'package:budgeting_app/features/transactions/domain/entities/money.dart';

final class MonthlyFinancialSummary {
  const MonthlyFinancialSummary({
    required this.month,
    required this.income,
    required this.expenses,
  });

  final DateTime month;
  final Money income;
  final Money expenses;

  Money get availableBalance => income - expenses;
}

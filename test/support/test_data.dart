import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final DateTime fixedNow = DateTime.utc(2026, 8, 4, 6, 15);

FinancialTransaction buildTestTransaction({
  String id = 'test-transaction',
  TransactionType type = TransactionType.expense,
  int minorUnits = 125000,
  TransactionCategory category = TransactionCategory.food,
  PaymentMethod paymentMethod = PaymentMethod.cash,
  String? merchant = 'Lunch at Thamel',
  String? note = 'Team lunch',
  DateTime? occurredAt,
  DateTime? createdAt,
}) {
  final DateTime created = createdAt ?? fixedNow;
  return FinancialTransaction(
    id: id,
    type: type,
    amount: Money(minorUnits: minorUnits),
    category: category,
    paymentMethod: paymentMethod,
    occurredAt: occurredAt ?? DateTime.utc(2026, 8, 4, 6, 15),
    merchant: merchant,
    note: note,
    createdAt: created,
    updatedAt: created,
  );
}

RecurringTransactionRule buildTestRecurringRule({
  String id = 'rule-rent',
  TransactionType type = TransactionType.expense,
  int minorUnits = 2500000,
  TransactionCategory category = TransactionCategory.rentAndHousing,
  PaymentMethod paymentMethod = PaymentMethod.bankAccount,
  String? merchant = 'Landlord',
  RecurringFrequency frequency = RecurringFrequency.monthly,
  AppCalendarSystem calendar = AppCalendarSystem.gregorianAd,
  DateTime? firstDueDateAd,
  DateTime? nextDueDateAd,
  RecurringRuleStatus status = RecurringRuleStatus.active,
}) {
  final DateTime due = firstDueDateAd ?? DateTime(2026, 8, 4, 12);
  final DateTime nextDue = nextDueDateAd ?? DateTime(2026, 9, 4, 12);
  return RecurringTransactionRule(
    id: id,
    type: type,
    amount: Money(minorUnits: minorUnits),
    category: category,
    paymentMethod: paymentMethod,
    merchant: merchant,
    frequency: frequency,
    recurrenceCalendar: calendar,
    anchorDay: due.day,
    anchorMonth: due.month,
    anchorWeekday: due.weekday,
    firstDueDateAd: due,
    nextDueDateAd: nextDue,
    status: status,
    createdAt: fixedNow,
    updatedAt: fixedNow,
  );
}

RecurringTransactionOccurrence buildTestRecurringOccurrence({
  String id = 'occ-rule-rent-2026-08-04',
  String ruleId = 'rule-rent',
  DateTime? dueDateAd,
  TransactionType type = TransactionType.expense,
  int minorUnits = 2500000,
  TransactionCategory category = TransactionCategory.rentAndHousing,
  PaymentMethod paymentMethod = PaymentMethod.bankAccount,
  String? merchant = 'Landlord',
}) {
  return RecurringTransactionOccurrence(
    id: id,
    ruleId: ruleId,
    dueDateAd: dueDateAd ?? DateTime(2026, 8, 4, 12),
    status: RecurringOccurrenceStatus.pending,
    type: type,
    amount: Money(minorUnits: minorUnits),
    category: category,
    paymentMethod: paymentMethod,
    merchant: merchant,
    createdAt: fixedNow,
  );
}

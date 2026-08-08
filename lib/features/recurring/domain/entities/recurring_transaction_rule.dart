import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class RecurringTransactionRule {
  const RecurringTransactionRule({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.frequency,
    required this.recurrenceCalendar,
    required this.anchorDay,
    required this.anchorMonth,
    required this.anchorWeekday,
    required this.firstDueDateAd,
    required this.nextDueDateAd,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.merchant,
    this.note,
    this.pausedAt,
    this.deletedAt,
  });

  static const Object _notProvided = Object();

  final String id;
  final TransactionType type;
  final Money amount;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final String? merchant;
  final String? note;
  final RecurringFrequency frequency;
  final AppCalendarSystem recurrenceCalendar;
  final int anchorDay;
  final int anchorMonth;
  final int anchorWeekday;
  final DateTime firstDueDateAd;
  final DateTime nextDueDateAd;
  final RecurringRuleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pausedAt;
  final DateTime? deletedAt;

  bool get isActive => status == RecurringRuleStatus.active;

  RecurringTransactionRule copyWith({
    TransactionType? type,
    Money? amount,
    TransactionCategory? category,
    PaymentMethod? paymentMethod,
    Object? merchant = _notProvided,
    Object? note = _notProvided,
    RecurringFrequency? frequency,
    AppCalendarSystem? recurrenceCalendar,
    int? anchorDay,
    int? anchorMonth,
    int? anchorWeekday,
    DateTime? firstDueDateAd,
    DateTime? nextDueDateAd,
    RecurringRuleStatus? status,
    DateTime? updatedAt,
    Object? pausedAt = _notProvided,
    Object? deletedAt = _notProvided,
  }) {
    return RecurringTransactionRule(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchant: identical(merchant, _notProvided)
          ? this.merchant
          : merchant as String?,
      note: identical(note, _notProvided) ? this.note : note as String?,
      frequency: frequency ?? this.frequency,
      recurrenceCalendar: recurrenceCalendar ?? this.recurrenceCalendar,
      anchorDay: anchorDay ?? this.anchorDay,
      anchorMonth: anchorMonth ?? this.anchorMonth,
      anchorWeekday: anchorWeekday ?? this.anchorWeekday,
      firstDueDateAd: firstDueDateAd ?? this.firstDueDateAd,
      nextDueDateAd: nextDueDateAd ?? this.nextDueDateAd,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pausedAt: identical(pausedAt, _notProvided)
          ? this.pausedAt
          : pausedAt as DateTime?,
      deletedAt: identical(deletedAt, _notProvided)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

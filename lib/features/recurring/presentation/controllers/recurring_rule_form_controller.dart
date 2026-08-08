import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurring_date_service.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecurringRuleFormPhase { editing, saving, success, failure }

final Provider<RecurringTransactionRule?> initialRecurringRuleProvider =
    Provider<RecurringTransactionRule?>(
      (Ref ref) => null,
      dependencies: const [],
    );

final Provider<FinancialTransaction?> recurringSourceTransactionProvider =
    Provider<FinancialTransaction?>((Ref ref) => null, dependencies: const []);

final class RecurringRuleFormState {
  const RecurringRuleFormState({
    required this.type,
    required this.amountInput,
    required this.paymentMethod,
    required this.merchant,
    required this.note,
    required this.frequency,
    required this.recurrenceCalendar,
    required this.firstDueDateAd,
    required this.anchorDay,
    required this.anchorMonth,
    required this.anchorWeekday,
    required this.phase,
    this.category,
    this.amountError,
    this.categoryError,
    this.dateError,
    this.submissionError,
    this.isEditing = false,
  });

  static const Object _notProvided = Object();

  final TransactionType type;
  final String amountInput;
  final TransactionCategory? category;
  final PaymentMethod paymentMethod;
  final String merchant;
  final String note;
  final RecurringFrequency frequency;
  final AppCalendarSystem recurrenceCalendar;
  final DateTime firstDueDateAd;
  final int anchorDay;
  final int anchorMonth;
  final int anchorWeekday;
  final RecurringRuleFormPhase phase;
  final String? amountError;
  final String? categoryError;
  final String? dateError;
  final String? submissionError;
  final bool isEditing;

  bool get isSaving => phase == RecurringRuleFormPhase.saving;

  RecurringRuleFormState copyWith({
    TransactionType? type,
    String? amountInput,
    Object? category = _notProvided,
    PaymentMethod? paymentMethod,
    String? merchant,
    String? note,
    RecurringFrequency? frequency,
    AppCalendarSystem? recurrenceCalendar,
    DateTime? firstDueDateAd,
    int? anchorDay,
    int? anchorMonth,
    int? anchorWeekday,
    RecurringRuleFormPhase? phase,
    Object? amountError = _notProvided,
    Object? categoryError = _notProvided,
    Object? dateError = _notProvided,
    Object? submissionError = _notProvided,
  }) {
    return RecurringRuleFormState(
      type: type ?? this.type,
      amountInput: amountInput ?? this.amountInput,
      category: identical(category, _notProvided)
          ? this.category
          : category as TransactionCategory?,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      recurrenceCalendar: recurrenceCalendar ?? this.recurrenceCalendar,
      firstDueDateAd: firstDueDateAd ?? this.firstDueDateAd,
      anchorDay: anchorDay ?? this.anchorDay,
      anchorMonth: anchorMonth ?? this.anchorMonth,
      anchorWeekday: anchorWeekday ?? this.anchorWeekday,
      phase: phase ?? this.phase,
      amountError: identical(amountError, _notProvided)
          ? this.amountError
          : amountError as String?,
      categoryError: identical(categoryError, _notProvided)
          ? this.categoryError
          : categoryError as String?,
      dateError: identical(dateError, _notProvided)
          ? this.dateError
          : dateError as String?,
      submissionError: identical(submissionError, _notProvided)
          ? this.submissionError
          : submissionError as String?,
      isEditing: isEditing,
    );
  }
}

final AutoDisposeNotifierProvider<
  RecurringRuleFormController,
  RecurringRuleFormState
>
recurringRuleFormControllerProvider =
    NotifierProvider.autoDispose<
      RecurringRuleFormController,
      RecurringRuleFormState
    >(
      RecurringRuleFormController.new,
      dependencies: <ProviderOrFamily>[
        initialRecurringRuleProvider,
        recurringSourceTransactionProvider,
      ],
    );

final class RecurringRuleFormController
    extends AutoDisposeNotifier<RecurringRuleFormState> {
  static const RecurringDateService _dateService = RecurringDateService();

  @override
  RecurringRuleFormState build() {
    final RecurringTransactionRule? existing = ref.watch(
      initialRecurringRuleProvider,
    );
    if (existing != null) {
      return RecurringRuleFormState(
        type: existing.type,
        amountInput: _editableAmount(existing.amount),
        category: existing.category,
        paymentMethod: existing.paymentMethod,
        merchant: existing.merchant ?? '',
        note: existing.note ?? '',
        frequency: existing.frequency,
        recurrenceCalendar: existing.recurrenceCalendar,
        firstDueDateAd: existing.firstDueDateAd,
        anchorDay: existing.anchorDay,
        anchorMonth: existing.anchorMonth,
        anchorWeekday: existing.anchorWeekday,
        phase: RecurringRuleFormPhase.editing,
        isEditing: true,
      );
    }

    final FinancialTransaction? source = ref.watch(
      recurringSourceTransactionProvider,
    );
    final DateTime today = _dateService.canonicalLocalNoon(
      ref.watch(currentDateProvider),
    );
    final AppCalendarSystem calendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final RecurrenceService recurrenceService = ref.read(
      recurrenceServiceProvider,
    );
    if (source != null) {
      final anchors = recurrenceService.anchorsFor(source.occurredAt, calendar);
      final RecurringTransactionRule prototype = _prototype(
        id: 'source-preview',
        type: source.type,
        amount: source.amount,
        category: source.category,
        paymentMethod: source.paymentMethod,
        merchant: source.merchant,
        note: source.note,
        frequency: RecurringFrequency.monthly,
        calendar: calendar,
        firstDueDate: source.occurredAt,
        nextDueDate: source.occurredAt,
        anchors: anchors,
        now: ref.read(appClockProvider)().toUtc(),
      );
      final DateTime firstDue = recurrenceService.nextOccurrence(
        prototype,
        source.occurredAt,
      );
      return RecurringRuleFormState(
        type: source.type,
        amountInput: _editableAmount(source.amount),
        category: source.category,
        paymentMethod: source.paymentMethod,
        merchant: source.merchant ?? '',
        note: source.note ?? '',
        frequency: RecurringFrequency.monthly,
        recurrenceCalendar: calendar,
        firstDueDateAd: firstDue,
        anchorDay: anchors.day,
        anchorMonth: anchors.month,
        anchorWeekday: anchors.weekday,
        phase: RecurringRuleFormPhase.editing,
      );
    }

    final anchors = recurrenceService.anchorsFor(today, calendar);
    return RecurringRuleFormState(
      type: TransactionType.expense,
      amountInput: '',
      paymentMethod: TransactionType.expense.defaultPaymentMethod,
      merchant: '',
      note: '',
      frequency: RecurringFrequency.monthly,
      recurrenceCalendar: calendar,
      firstDueDateAd: today,
      anchorDay: anchors.day,
      anchorMonth: anchors.month,
      anchorWeekday: anchors.weekday,
      phase: RecurringRuleFormPhase.editing,
    );
  }

  void updateType(TransactionType type) {
    state = state.copyWith(
      type: type,
      category: state.category?.supports(type) == true ? state.category : null,
      paymentMethod: type.defaultPaymentMethod,
      categoryError: null,
    );
  }

  void updateAmount(String value) {
    state = state.copyWith(amountInput: value, amountError: null);
  }

  void updateCategory(TransactionCategory category) {
    state = state.copyWith(category: category, categoryError: null);
  }

  void updatePaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void updateMerchant(String value) => state = state.copyWith(merchant: value);

  void updateNote(String value) => state = state.copyWith(note: value);

  void updateFrequency(RecurringFrequency frequency) {
    state = state.copyWith(frequency: frequency, submissionError: null);
  }

  void updateCalendar(AppCalendarSystem calendar) {
    final anchors = ref
        .read(recurrenceServiceProvider)
        .anchorsFor(state.firstDueDateAd, calendar);
    state = state.copyWith(
      recurrenceCalendar: calendar,
      anchorDay: anchors.day,
      anchorMonth: anchors.month,
      anchorWeekday: anchors.weekday,
      submissionError: null,
    );
  }

  void updateFirstDueDate(DateTime date) {
    final DateTime canonical = _dateService.canonicalLocalNoon(date);
    final anchors = ref
        .read(recurrenceServiceProvider)
        .anchorsFor(canonical, state.recurrenceCalendar);
    state = state.copyWith(
      firstDueDateAd: canonical,
      anchorDay: anchors.day,
      anchorMonth: anchors.month,
      anchorWeekday: anchors.weekday,
      dateError: null,
      submissionError: null,
    );
  }

  DateTime previewNextDate() {
    if (!state.isEditing) {
      return state.firstDueDateAd;
    }
    final DateTime now = ref.read(currentDateProvider);
    final RecurringTransactionRule preview = _prototype(
      id: 'edit-preview',
      type: state.type,
      amount:
          AddTransactionController.parseAmount(state.amountInput) ??
          const Money(minorUnits: 1),
      category:
          state.category ??
          (state.type == TransactionType.expense
              ? TransactionCategory.other
              : TransactionCategory.salary),
      paymentMethod: state.paymentMethod,
      merchant: null,
      note: null,
      frequency: state.frequency,
      calendar: state.recurrenceCalendar,
      firstDueDate: state.firstDueDateAd,
      nextDueDate: state.firstDueDateAd,
      anchors: (
        day: state.anchorDay,
        month: state.anchorMonth,
        weekday: state.anchorWeekday,
      ),
      now: ref.read(appClockProvider)().toUtc(),
    );
    return ref
        .read(recurrenceServiceProvider)
        .nextOccurrenceOnOrAfter(preview, now);
  }

  Future<RecurringTransactionRule?> submit() async {
    if (state.isSaving) {
      return null;
    }
    final Money? amount = AddTransactionController.parseAmount(
      state.amountInput,
    );
    final String? amountError = amount == null || !amount.isPositive
        ? 'Enter an amount greater than NPR 0.'
        : null;
    final String? categoryError = state.category == null
        ? state.type == TransactionType.expense
              ? 'Choose a category.'
              : 'Choose an income source.'
        : null;
    final DateTime nowValue = ref.read(appClockProvider)();
    final DateTime today = _dateService.canonicalLocalNoon(nowValue);
    final String? dateError =
        !state.isEditing &&
            _dateService.compare(state.firstDueDateAd, today) < 0
        ? 'Choose today or a future first due date.'
        : null;
    if (amountError != null || categoryError != null || dateError != null) {
      state = state.copyWith(
        amountError: amountError,
        categoryError: categoryError,
        dateError: dateError,
      );
      return null;
    }
    state = state.copyWith(
      phase: RecurringRuleFormPhase.saving,
      amountError: null,
      categoryError: null,
      dateError: null,
      submissionError: null,
    );

    final RecurringTransactionRule? existing = ref.read(
      initialRecurringRuleProvider,
    );
    final DateTime now = nowValue.toUtc();
    final String? merchant = _emptyToNull(state.merchant);
    final String? note = _emptyToNull(state.note);
    RecurringTransactionRule draft = _prototype(
      id: existing?.id ?? 'rec-${now.microsecondsSinceEpoch}',
      type: state.type,
      amount: amount!,
      category: state.category!,
      paymentMethod: state.paymentMethod,
      merchant: merchant,
      note: note,
      frequency: state.frequency,
      calendar: state.recurrenceCalendar,
      firstDueDate: state.firstDueDateAd,
      nextDueDate: state.firstDueDateAd,
      anchors: (
        day: state.anchorDay,
        month: state.anchorMonth,
        weekday: state.anchorWeekday,
      ),
      now: now,
      existing: existing,
    );
    try {
      final RecurrenceService service = ref.read(recurrenceServiceProvider);
      service.nextOccurrence(draft, draft.firstDueDateAd);
      if (existing != null) {
        draft = draft.copyWith(
          nextDueDateAd: service.nextOccurrenceOnOrAfter(draft, today),
        );
        await ref
            .read(recurringTransactionRepositoryProvider)
            .updateRule(draft);
      } else {
        await ref
            .read(recurringTransactionRepositoryProvider)
            .createRule(draft);
      }
      await ref
          .read(recurringTransactionRepositoryProvider)
          .reconcileThrough(today: today, handledAt: now);
      state = state.copyWith(phase: RecurringRuleFormPhase.success);
      ref.invalidate(recurringReconciliationProvider);
      return draft;
    } on RecurrenceRangeException catch (error) {
      state = state.copyWith(
        phase: RecurringRuleFormPhase.failure,
        submissionError: error.message,
      );
    } on AppException catch (error) {
      state = state.copyWith(
        phase: RecurringRuleFormPhase.failure,
        submissionError: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        phase: RecurringRuleFormPhase.failure,
        submissionError:
            'The recurring schedule could not be saved. Try again.',
      );
    }
    return null;
  }

  static RecurringTransactionRule _prototype({
    required String id,
    required TransactionType type,
    required Money amount,
    required TransactionCategory category,
    required PaymentMethod paymentMethod,
    required String? merchant,
    required String? note,
    required RecurringFrequency frequency,
    required AppCalendarSystem calendar,
    required DateTime firstDueDate,
    required DateTime nextDueDate,
    required ({int day, int month, int weekday}) anchors,
    required DateTime now,
    RecurringTransactionRule? existing,
  }) {
    return RecurringTransactionRule(
      id: id,
      type: type,
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      merchant: merchant,
      note: note,
      frequency: frequency,
      recurrenceCalendar: calendar,
      anchorDay: anchors.day,
      anchorMonth: anchors.month,
      anchorWeekday: anchors.weekday,
      firstDueDateAd: _dateService.canonicalLocalNoon(firstDueDate),
      nextDueDateAd: _dateService.canonicalLocalNoon(nextDueDate),
      status: existing?.status ?? RecurringRuleStatus.active,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      pausedAt: existing?.pausedAt,
      deletedAt: existing?.deletedAt,
    );
  }

  static String _editableAmount(Money money) {
    final int whole = money.minorUnits ~/ 100;
    final int minor = money.minorUnits % 100;
    return minor == 0 ? '$whole' : '$whole.${minor.toString().padLeft(2, '0')}';
  }

  static String? _emptyToNull(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

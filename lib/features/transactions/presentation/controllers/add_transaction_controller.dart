import 'package:budgeting_app/core/analytics/analytics_event_names.dart';
import 'package:budgeting_app/core/analytics/app_analytics.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/services/transaction_date_service.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AddTransactionSubmissionPhase { editing, saving, success, failure }

enum TransactionFormIntent { create, edit, repeat, recurringOccurrence }

final class AddTransactionState {
  const AddTransactionState({
    required this.type,
    required this.amountInput,
    required this.paymentMethod,
    required this.occurredDate,
    required this.merchant,
    required this.note,
    required this.submissionPhase,
    this.selectedCategory,
    this.amountError,
    this.categoryError,
    this.submissionError,
    this.savedTransaction,
    this.isEditing = false,
    this.isRepeatDraft = false,
    this.isRecurringOccurrenceDraft = false,
  });

  factory AddTransactionState.initial({
    required DateTime currentDate,
    required TransactionType type,
    required PaymentMethod paymentMethod,
  }) {
    return AddTransactionState(
      type: type,
      amountInput: '',
      paymentMethod: paymentMethod,
      occurredDate: const TransactionDateService().today(currentDate),
      merchant: '',
      note: '',
      submissionPhase: AddTransactionSubmissionPhase.editing,
    );
  }

  factory AddTransactionState.fromTransaction(
    FinancialTransaction transaction, {
    required bool isEditing,
    required bool isRepeatDraft,
    DateTime? currentDate,
  }) {
    return AddTransactionState(
      type: transaction.type,
      amountInput: _editableAmount(transaction.amount),
      paymentMethod: transaction.paymentMethod,
      occurredDate: isRepeatDraft
          ? const TransactionDateService().today(currentDate!)
          : const TransactionDateService().localCalendarDate(
              transaction.occurredAt,
            ),
      merchant: transaction.merchant ?? '',
      note: transaction.note ?? '',
      selectedCategory: transaction.category,
      submissionPhase: AddTransactionSubmissionPhase.editing,
      isEditing: isEditing,
      isRepeatDraft: isRepeatDraft,
    );
  }

  factory AddTransactionState.fromRecurringOccurrence(
    RecurringTransactionOccurrence occurrence,
  ) {
    return AddTransactionState(
      type: occurrence.type,
      amountInput: _editableAmount(occurrence.amount),
      paymentMethod: occurrence.paymentMethod,
      occurredDate: occurrence.dueDateAd.toLocal(),
      merchant: occurrence.merchant ?? '',
      note: occurrence.note ?? '',
      selectedCategory: occurrence.category,
      submissionPhase: AddTransactionSubmissionPhase.editing,
      isRecurringOccurrenceDraft: true,
    );
  }

  final TransactionType type;
  final String amountInput;
  final TransactionCategory? selectedCategory;
  final PaymentMethod paymentMethod;
  final DateTime occurredDate;
  final String merchant;
  final String note;
  final String? amountError;
  final String? categoryError;
  final String? submissionError;
  final AddTransactionSubmissionPhase submissionPhase;
  final FinancialTransaction? savedTransaction;
  final bool isEditing;
  final bool isRepeatDraft;
  final bool isRecurringOccurrenceDraft;

  bool get isSubmitting =>
      submissionPhase == AddTransactionSubmissionPhase.saving;

  bool get canSubmit {
    final Money? parsedAmount = AddTransactionController.parseAmount(
      amountInput,
    );
    return !isSubmitting &&
        parsedAmount != null &&
        parsedAmount.isPositive &&
        selectedCategory != null;
  }

  AddTransactionState copyWith({
    TransactionType? type,
    String? amountInput,
    TransactionCategory? selectedCategory,
    bool clearSelectedCategory = false,
    PaymentMethod? paymentMethod,
    DateTime? occurredDate,
    String? merchant,
    String? note,
    Object? amountError = _notProvided,
    Object? categoryError = _notProvided,
    Object? submissionError = _notProvided,
    AddTransactionSubmissionPhase? submissionPhase,
    FinancialTransaction? savedTransaction,
  }) {
    return AddTransactionState(
      type: type ?? this.type,
      amountInput: amountInput ?? this.amountInput,
      selectedCategory: clearSelectedCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      occurredDate: occurredDate ?? this.occurredDate,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      amountError: identical(amountError, _notProvided)
          ? this.amountError
          : amountError as String?,
      categoryError: identical(categoryError, _notProvided)
          ? this.categoryError
          : categoryError as String?,
      submissionError: identical(submissionError, _notProvided)
          ? this.submissionError
          : submissionError as String?,
      submissionPhase: submissionPhase ?? this.submissionPhase,
      savedTransaction: savedTransaction ?? this.savedTransaction,
      isEditing: isEditing,
      isRepeatDraft: isRepeatDraft,
      isRecurringOccurrenceDraft: isRecurringOccurrenceDraft,
    );
  }

  static const Object _notProvided = Object();

  static String _editableAmount(Money money) {
    final int whole = money.minorUnits ~/ 100;
    final int minor = money.minorUnits % 100;
    return minor == 0 ? '$whole' : '$whole.${minor.toString().padLeft(2, '0')}';
  }
}

final Provider<FinancialTransaction?> initialTransactionProvider =
    Provider<FinancialTransaction?>((Ref ref) => null, dependencies: const []);

final Provider<TransactionType> initialTransactionTypeProvider =
    Provider<TransactionType>(
      (Ref ref) => TransactionType.expense,
      dependencies: const [],
    );

final Provider<TransactionFormIntent> transactionFormIntentProvider =
    Provider<TransactionFormIntent>(
      (Ref ref) => TransactionFormIntent.create,
      dependencies: const [],
    );

final Provider<RecurringTransactionOccurrence?>
initialRecurringOccurrenceProvider = Provider<RecurringTransactionOccurrence?>(
  (Ref ref) => null,
  dependencies: const [],
);

final AutoDisposeNotifierProvider<AddTransactionController, AddTransactionState>
addTransactionControllerProvider =
    NotifierProvider.autoDispose<AddTransactionController, AddTransactionState>(
      AddTransactionController.new,
      dependencies: <ProviderOrFamily>[
        initialTransactionProvider,
        initialTransactionTypeProvider,
        transactionFormIntentProvider,
        initialRecurringOccurrenceProvider,
      ],
    );

final class AddTransactionController
    extends AutoDisposeNotifier<AddTransactionState> {
  @override
  AddTransactionState build() {
    final RecurringTransactionOccurrence? recurringOccurrence = ref.watch(
      initialRecurringOccurrenceProvider,
    );
    if (recurringOccurrence != null) {
      return AddTransactionState.fromRecurringOccurrence(recurringOccurrence);
    }
    final FinancialTransaction? existing = ref.watch(
      initialTransactionProvider,
    );
    final TransactionFormIntent intent = ref.watch(
      transactionFormIntentProvider,
    );
    if (existing != null) {
      return AddTransactionState.fromTransaction(
        existing,
        isEditing: intent == TransactionFormIntent.edit,
        isRepeatDraft: intent == TransactionFormIntent.repeat,
        currentDate: ref.watch(currentDateProvider),
      );
    }
    final TransactionType initialType = ref.watch(
      initialTransactionTypeProvider,
    );
    final List<PaymentMethod> recentMethods =
        ref.read(recentPaymentMethodsProvider(initialType)).valueOrNull ??
        const <PaymentMethod>[];
    return AddTransactionState.initial(
      currentDate: ref.watch(currentDateProvider),
      type: initialType,
      paymentMethod: _initialPaymentMethod(initialType, recentMethods),
    );
  }

  void updateType(TransactionType type) {
    if (type == state.type) {
      return;
    }
    final TransactionCategory? currentCategory = state.selectedCategory;
    state = state.copyWith(
      type: type,
      clearSelectedCategory:
          currentCategory != null && !currentCategory.supports(type),
      categoryError: null,
      submissionError: null,
      submissionPhase: AddTransactionSubmissionPhase.editing,
      paymentMethod: state.isEditing
          ? state.paymentMethod
          : _initialPaymentMethod(
              type,
              ref.read(recentPaymentMethodsProvider(type)).valueOrNull ??
                  const <PaymentMethod>[],
            ),
    );
  }

  void updateAmount(String input) {
    final Money? amount = parseAmount(input);
    final String? error = switch ((input, amount)) {
      ('', _) => null,
      (_, null) => 'Enter a valid amount with up to two decimal places.',
      (_, final Money value) when !value.isPositive =>
        'Amount must be greater than NPR 0.',
      _ => null,
    };
    state = state.copyWith(
      amountInput: input,
      amountError: error,
      submissionError: null,
      submissionPhase: AddTransactionSubmissionPhase.editing,
    );
  }

  void selectCategory(TransactionCategory category) {
    if (!category.supports(state.type)) {
      return;
    }
    state = state.copyWith(
      selectedCategory: category,
      categoryError: null,
      submissionError: null,
      submissionPhase: AddTransactionSubmissionPhase.editing,
    );
  }

  void selectRecentCategory(TransactionCategory category) {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.recentCategorySelected);
    selectCategory(category);
  }

  void updatePaymentMethod(PaymentMethod paymentMethod) {
    state = state.copyWith(paymentMethod: paymentMethod);
  }

  void selectRecentPaymentMethod(PaymentMethod paymentMethod) {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.paymentMethodReused);
    updatePaymentMethod(paymentMethod);
  }

  void updateOccurredDate(DateTime occurredDate) {
    state = state.copyWith(
      occurredDate: const TransactionDateService().localCalendarDate(
        occurredDate,
      ),
    );
  }

  void selectQuickDate(DateTime occurredDate) {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.quickDateSelected);
    updateOccurredDate(occurredDate);
  }

  void updateMerchant(String merchant) {
    state = state.copyWith(merchant: merchant);
  }

  void updateNote(String note) {
    state = state.copyWith(note: note);
  }

  Future<FinancialTransaction?> submit() async {
    if (state.isSubmitting) {
      return null;
    }

    final Money? amount = parseAmount(state.amountInput);
    final String? amountError = amount == null
        ? 'Enter an amount.'
        : amount.isPositive
        ? null
        : 'Amount must be greater than NPR 0.';
    final String? categoryError = state.selectedCategory == null
        ? state.type == TransactionType.expense
              ? 'Choose a category.'
              : 'Choose an income source.'
        : null;

    if (amountError != null || categoryError != null) {
      state = state.copyWith(
        amountError: amountError,
        categoryError: categoryError,
        submissionPhase: AddTransactionSubmissionPhase.editing,
      );
      return null;
    }

    state = state.copyWith(
      amountError: null,
      categoryError: null,
      submissionError: null,
      submissionPhase: AddTransactionSubmissionPhase.saving,
    );

    final FinancialTransaction? existing = state.isEditing
        ? ref.read(initialTransactionProvider)
        : null;
    final RecurringTransactionOccurrence? recurringOccurrence = ref.read(
      initialRecurringOccurrenceProvider,
    );
    final DateTime now = ref.read(appClockProvider)().toUtc();
    final DateTime localDate = state.occurredDate.toLocal();
    final DateTime occurredAt = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
      12,
    ).toUtc();
    final String? merchant = _emptyToNull(state.merchant);
    final String? note = _emptyToNull(state.note);
    final FinancialTransaction transaction = existing == null
        ? FinancialTransaction(
            id: 'txn-${now.microsecondsSinceEpoch}',
            type: state.type,
            amount: amount!,
            category: state.selectedCategory!,
            paymentMethod: state.paymentMethod,
            occurredAt: occurredAt,
            merchant: merchant,
            note: note,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            type: state.type,
            amount: amount!,
            category: state.selectedCategory!,
            paymentMethod: state.paymentMethod,
            occurredAt: occurredAt,
            merchant: merchant,
            note: note,
            updatedAt: now,
          );

    try {
      final TransactionRepository repository = ref.read(
        transactionRepositoryProvider,
      );
      if (recurringOccurrence != null) {
        await ref
            .read(recurringTransactionRepositoryProvider)
            .recordOccurrence(
              occurrenceId: recurringOccurrence.id,
              transaction: transaction,
            );
      } else if (existing == null) {
        await repository.createTransaction(transaction);
      } else {
        await repository.updateTransaction(transaction);
      }
      state = state.copyWith(
        submissionPhase: AddTransactionSubmissionPhase.success,
        savedTransaction: transaction,
      );
      if (!state.isEditing) {
        ref
            .read(appAnalyticsProvider)
            .recordEvent(
              state.isRepeatDraft
                  ? AnalyticsEventNames.transactionRepeated
                  : AnalyticsEventNames.transactionCreated,
            );
      }
      return transaction;
    } on AppException catch (error) {
      state = state.copyWith(
        submissionPhase: AddTransactionSubmissionPhase.failure,
        submissionError: error.message,
      );
      return null;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'budgeting_app',
          context: ErrorDescription('while saving a transaction'),
        ),
      );
      state = state.copyWith(
        submissionPhase: AddTransactionSubmissionPhase.failure,
        submissionError: 'Something went wrong while saving. Try again.',
      );
      return null;
    }
  }

  static Money? parseAmount(String input) {
    final String normalized = input.trim();
    if (!RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(normalized)) {
      return null;
    }
    final List<String> parts = normalized.split('.');
    final int? wholeUnits = int.tryParse(parts.first);
    if (wholeUnits == null) {
      return null;
    }
    final int minorUnits = parts.length == 1 || parts[1].isEmpty
        ? 0
        : int.parse(parts[1].padRight(2, '0'));
    return Money(minorUnits: wholeUnits * 100 + minorUnits);
  }

  static String? _emptyToNull(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  PaymentMethod _initialPaymentMethod(
    TransactionType type,
    List<PaymentMethod> recentMethods,
  ) {
    return recentMethods.firstOrNull ?? type.defaultPaymentMethod;
  }
}

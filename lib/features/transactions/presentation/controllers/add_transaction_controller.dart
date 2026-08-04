import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AddTransactionSubmissionPhase { editing, saving, success, failure }

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
  });

  factory AddTransactionState.initial(DateTime currentDate) {
    return AddTransactionState(
      type: TransactionType.expense,
      amountInput: '',
      paymentMethod: PaymentMethod.cash,
      occurredDate: currentDate.toLocal(),
      merchant: '',
      note: '',
      submissionPhase: AddTransactionSubmissionPhase.editing,
    );
  }

  factory AddTransactionState.fromTransaction(
    FinancialTransaction transaction,
  ) {
    return AddTransactionState(
      type: transaction.type,
      amountInput: _editableAmount(transaction.amount),
      paymentMethod: transaction.paymentMethod,
      occurredDate: transaction.occurredAt.toLocal(),
      merchant: transaction.merchant ?? '',
      note: transaction.note ?? '',
      selectedCategory: transaction.category,
      submissionPhase: AddTransactionSubmissionPhase.editing,
      isEditing: true,
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

final AutoDisposeNotifierProvider<AddTransactionController, AddTransactionState>
addTransactionControllerProvider =
    NotifierProvider.autoDispose<AddTransactionController, AddTransactionState>(
      AddTransactionController.new,
      dependencies: <ProviderOrFamily>[
        initialTransactionProvider,
        initialTransactionTypeProvider,
      ],
    );

final class AddTransactionController
    extends AutoDisposeNotifier<AddTransactionState> {
  @override
  AddTransactionState build() {
    final FinancialTransaction? existing = ref.watch(
      initialTransactionProvider,
    );
    if (existing != null) {
      return AddTransactionState.fromTransaction(existing);
    }
    final AddTransactionState initial = AddTransactionState.initial(
      ref.watch(currentDateProvider),
    );
    return initial.copyWith(type: ref.watch(initialTransactionTypeProvider));
  }

  void updateType(TransactionType type) {
    final TransactionCategory? currentCategory = state.selectedCategory;
    state = state.copyWith(
      type: type,
      clearSelectedCategory:
          currentCategory != null && !currentCategory.supports(type),
      categoryError: null,
      submissionError: null,
      submissionPhase: AddTransactionSubmissionPhase.editing,
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

  void updatePaymentMethod(PaymentMethod paymentMethod) {
    state = state.copyWith(paymentMethod: paymentMethod);
  }

  void updateOccurredDate(DateTime occurredDate) {
    state = state.copyWith(occurredDate: occurredDate);
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
        ? 'Choose a category.'
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

    final FinancialTransaction? existing = ref.read(initialTransactionProvider);
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
      if (existing == null) {
        await repository.createTransaction(transaction);
      } else {
        await repository.updateTransaction(transaction);
      }
      state = state.copyWith(
        submissionPhase: AddTransactionSubmissionPhase.success,
        savedTransaction: transaction,
      );
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
}

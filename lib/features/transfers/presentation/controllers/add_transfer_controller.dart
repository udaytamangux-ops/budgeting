import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/services/transaction_amount_calculator.dart';
import 'package:budgeting_app/features/transactions/domain/services/transaction_date_service.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:budgeting_app/features/transfers/domain/repositories/transfer_repository.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransferFormIntent { create, edit, repeat }

enum AddTransferSubmissionPhase { editing, saving, success, failure }

final class AddTransferState {
  const AddTransferState({
    required this.amountInput,
    required this.source,
    required this.destination,
    required this.destinationName,
    required this.countsAsExpense,
    required this.feeInput,
    required this.occurredDate,
    required this.note,
    required this.submissionPhase,
    this.expenseCategory,
    this.amountError,
    this.destinationNameError,
    this.categoryError,
    this.feeError,
    this.dateError,
    this.submissionError,
    this.savedTransfer,
    this.isEditing = false,
    this.isRepeatDraft = false,
    this.hasChangedOccurredDate = false,
  });

  factory AddTransferState.initial(DateTime currentDate) => AddTransferState(
    amountInput: '',
    source: TransferSource.bankAccount,
    destination: TransferDestination.cash,
    destinationName: '',
    countsAsExpense: false,
    feeInput: '',
    occurredDate: const TransactionDateService().today(currentDate),
    note: '',
    submissionPhase: AddTransferSubmissionPhase.editing,
  );

  factory AddTransferState.fromTransfer(
    FinancialTransfer transfer, {
    required bool isEditing,
    required bool isRepeatDraft,
    required DateTime currentDate,
  }) => AddTransferState(
    amountInput: _editableAmount(transfer.amount),
    source: transfer.source,
    destination: transfer.destination,
    destinationName: transfer.destinationName ?? '',
    countsAsExpense: transfer.countsAsExpense,
    expenseCategory: transfer.expenseCategory,
    feeInput: transfer.fee.isZero ? '' : _editableAmount(transfer.fee),
    occurredDate: isRepeatDraft
        ? const TransactionDateService().today(currentDate)
        : const TransactionDateService().localCalendarDate(transfer.occurredAt),
    note: transfer.note ?? '',
    submissionPhase: AddTransferSubmissionPhase.editing,
    isEditing: isEditing,
    isRepeatDraft: isRepeatDraft,
  );

  final String amountInput;
  final TransferSource source;
  final TransferDestination destination;
  final String destinationName;
  final bool countsAsExpense;
  final TransactionCategory? expenseCategory;
  final String feeInput;
  final DateTime occurredDate;
  final String note;
  final String? amountError;
  final String? destinationNameError;
  final String? categoryError;
  final String? feeError;
  final String? dateError;
  final String? submissionError;
  final AddTransferSubmissionPhase submissionPhase;
  final FinancialTransfer? savedTransfer;
  final bool isEditing;
  final bool isRepeatDraft;
  final bool hasChangedOccurredDate;

  bool get isSubmitting => submissionPhase == AddTransferSubmissionPhase.saving;

  bool get canSubmit {
    final Money? amount = AddTransactionController.parseAmount(amountInput);
    final Money? fee = feeInput.trim().isEmpty
        ? const Money.zero()
        : AddTransactionController.parseAmount(feeInput);
    return !isSubmitting &&
        amount?.isPositive == true &&
        fee != null &&
        !fee.isNegative &&
        (!destination.requiresName || destinationName.trim().isNotEmpty) &&
        (!countsAsExpense || expenseCategory != null) &&
        dateError == null;
  }

  AddTransferState copyWith({
    String? amountInput,
    TransferSource? source,
    TransferDestination? destination,
    String? destinationName,
    bool? countsAsExpense,
    TransactionCategory? expenseCategory,
    bool clearExpenseCategory = false,
    String? feeInput,
    DateTime? occurredDate,
    String? note,
    Object? amountError = _sentinel,
    Object? destinationNameError = _sentinel,
    Object? categoryError = _sentinel,
    Object? feeError = _sentinel,
    Object? dateError = _sentinel,
    Object? submissionError = _sentinel,
    AddTransferSubmissionPhase? submissionPhase,
    FinancialTransfer? savedTransfer,
    bool? hasChangedOccurredDate,
  }) => AddTransferState(
    amountInput: amountInput ?? this.amountInput,
    source: source ?? this.source,
    destination: destination ?? this.destination,
    destinationName: destinationName ?? this.destinationName,
    countsAsExpense: countsAsExpense ?? this.countsAsExpense,
    expenseCategory: clearExpenseCategory
        ? null
        : expenseCategory ?? this.expenseCategory,
    feeInput: feeInput ?? this.feeInput,
    occurredDate: occurredDate ?? this.occurredDate,
    note: note ?? this.note,
    amountError: identical(amountError, _sentinel)
        ? this.amountError
        : amountError as String?,
    destinationNameError: identical(destinationNameError, _sentinel)
        ? this.destinationNameError
        : destinationNameError as String?,
    categoryError: identical(categoryError, _sentinel)
        ? this.categoryError
        : categoryError as String?,
    feeError: identical(feeError, _sentinel)
        ? this.feeError
        : feeError as String?,
    dateError: identical(dateError, _sentinel)
        ? this.dateError
        : dateError as String?,
    submissionError: identical(submissionError, _sentinel)
        ? this.submissionError
        : submissionError as String?,
    submissionPhase: submissionPhase ?? this.submissionPhase,
    savedTransfer: savedTransfer ?? this.savedTransfer,
    isEditing: isEditing,
    isRepeatDraft: isRepeatDraft,
    hasChangedOccurredDate:
        hasChangedOccurredDate ?? this.hasChangedOccurredDate,
  );

  static const Object _sentinel = Object();

  static String _editableAmount(Money money) {
    final int whole = money.minorUnits ~/ 100;
    final int minor = money.minorUnits % 100;
    return minor == 0 ? '$whole' : '$whole.${minor.toString().padLeft(2, '0')}';
  }
}

final class NewTransferDraft {
  const NewTransferDraft({
    required this.form,
    required this.calculatorExpression,
    required this.calculatorInteracted,
    required this.calculatorShowValidationError,
  });

  final AddTransferState form;
  final String calculatorExpression;
  final bool calculatorInteracted;
  final bool calculatorShowValidationError;

  NewTransferDraft copyWith({
    AddTransferState? form,
    String? calculatorExpression,
    bool? calculatorInteracted,
    bool? calculatorShowValidationError,
  }) => NewTransferDraft(
    form: form ?? this.form,
    calculatorExpression: calculatorExpression ?? this.calculatorExpression,
    calculatorInteracted: calculatorInteracted ?? this.calculatorInteracted,
    calculatorShowValidationError:
        calculatorShowValidationError ?? this.calculatorShowValidationError,
  );
}

final Provider<FinancialTransfer?> initialTransferProvider =
    Provider<FinancialTransfer?>((Ref ref) => null, dependencies: const []);
final Provider<TransferFormIntent> transferFormIntentProvider =
    Provider<TransferFormIntent>(
      (Ref ref) => TransferFormIntent.create,
      dependencies: const [],
    );
final Provider<bool> newTransferSheetModeProvider = Provider<bool>(
  (Ref ref) => false,
  dependencies: const <ProviderOrFamily>[],
);
final Provider<NewTransferDraft?> initialNewTransferDraftProvider =
    Provider<NewTransferDraft?>(
      (Ref ref) => null,
      dependencies: const <ProviderOrFamily>[],
    );

final NotifierProvider<NewTransferDraftSessionController, NewTransferDraft?>
newTransferDraftSessionProvider =
    NotifierProvider<NewTransferDraftSessionController, NewTransferDraft?>(
      NewTransferDraftSessionController.new,
    );

final class NewTransferDraftSessionController
    extends Notifier<NewTransferDraft?> {
  @override
  NewTransferDraft? build() => null;

  void updateForm(AddTransferState form) {
    if (form.submissionPhase == AddTransferSubmissionPhase.saving ||
        form.submissionPhase == AddTransferSubmissionPhase.success) {
      return;
    }
    state = state == null
        ? NewTransferDraft(
            form: form,
            calculatorExpression: form.amountInput,
            calculatorInteracted: false,
            calculatorShowValidationError: false,
          )
        : state!.copyWith(form: form);
  }

  void updateCalculator({
    required AddTransferState form,
    required String expression,
    required bool interacted,
    required bool showValidationError,
  }) {
    state = NewTransferDraft(
      form: form,
      calculatorExpression: expression,
      calculatorInteracted: interacted,
      calculatorShowValidationError: showValidationError,
    );
  }

  void clear() => state = null;
}

final AutoDisposeNotifierProvider<AddTransferController, AddTransferState>
addTransferControllerProvider =
    NotifierProvider.autoDispose<AddTransferController, AddTransferState>(
      AddTransferController.new,
      dependencies: <ProviderOrFamily>[
        initialTransferProvider,
        transferFormIntentProvider,
        newTransferSheetModeProvider,
        initialNewTransferDraftProvider,
      ],
    );

final class AddTransferController
    extends AutoDisposeNotifier<AddTransferState> {
  @override
  AddTransferState build() {
    final NewTransferDraft? draft = ref.watch(initialNewTransferDraftProvider);
    if (ref.watch(newTransferSheetModeProvider) && draft != null) {
      return draft.form;
    }
    final FinancialTransfer? transfer = ref.watch(initialTransferProvider);
    final TransferFormIntent intent = ref.watch(transferFormIntentProvider);
    if (transfer != null) {
      return AddTransferState.fromTransfer(
        transfer,
        isEditing: intent == TransferFormIntent.edit,
        isRepeatDraft: intent == TransferFormIntent.repeat,
        currentDate: ref.watch(currentDateProvider),
      );
    }
    return AddTransferState.initial(ref.watch(currentDateProvider));
  }

  void updateAmount(String value) => state = state.copyWith(
    amountInput: value,
    amountError: _positiveMoneyError(value, required: false),
    submissionError: null,
  );
  void updateSource(TransferSource value) =>
      state = state.copyWith(source: value);
  void updateDestination(TransferDestination value) => state = state.copyWith(
    destination: value,
    destinationName: value.requiresName ? state.destinationName : '',
    destinationNameError: null,
  );
  void updateDestinationName(String value) => state = state.copyWith(
    destinationName: value,
    destinationNameError: null,
  );
  void updateCountsAsExpense(bool value) => state = state.copyWith(
    countsAsExpense: value,
    clearExpenseCategory: !value,
    categoryError: null,
  );
  void selectExpenseCategory(TransactionCategory value) {
    if (!value.supports(TransactionType.expense)) return;
    state = state.copyWith(expenseCategory: value, categoryError: null);
  }

  void updateFee(String value) => state = state.copyWith(
    feeInput: value,
    feeError: _feeError(value),
    submissionError: null,
  );
  void updateNote(String value) => state = state.copyWith(note: value);

  void updateOccurredDate(DateTime value) {
    final DateTime selected = const TransactionDateService().localCalendarDate(
      value,
    );
    final DateTime today = const TransactionDateService().today(
      ref.read(currentDateProvider),
    );
    if (selected.isAfter(today)) {
      state = state.copyWith(
        dateError: 'Choose Today or an earlier date.',
        hasChangedOccurredDate: true,
      );
      return;
    }
    state = state.copyWith(
      occurredDate: selected,
      dateError: null,
      hasChangedOccurredDate: true,
      submissionError: null,
    );
  }

  Future<FinancialTransfer?> submit() async {
    if (state.isSubmitting) return null;
    final Money? amount = AddTransactionController.parseAmount(
      state.amountInput,
    );
    final Money? fee = state.feeInput.trim().isEmpty
        ? const Money.zero()
        : AddTransactionController.parseAmount(state.feeInput);
    final String? amountError = _positiveMoneyError(
      state.amountInput,
      required: true,
    );
    final String? feeError = _feeError(state.feeInput);
    final String? destinationError =
        state.destination.requiresName && state.destinationName.trim().isEmpty
        ? '${state.destination.destinationFieldLabel} is required.'
        : null;
    final bool selectedCategoryArchived =
        state.expenseCategory?.isCustom == true &&
        ref
            .read(categoryCatalogProvider)
            .resolve(state.expenseCategory!)
            .isArchived;
    final String? categoryError =
        state.countsAsExpense && state.expenseCategory == null
        ? 'Choose an expense category.'
        : state.countsAsExpense && selectedCategoryArchived && !state.isEditing
        ? 'Choose an active expense category before saving.'
        : null;
    final FinancialTransfer? existing = state.isEditing
        ? ref.read(initialTransferProvider)
        : null;
    final DateTime today = const TransactionDateService().today(
      ref.read(currentDateProvider),
    );
    final bool future = state.occurredDate.isAfter(today);
    final bool unchangedLegacyFuture =
        existing != null &&
        future &&
        !state.hasChangedOccurredDate &&
        _sameDate(existing.occurredAt, state.occurredDate);
    final String? dateError = future && !unchangedLegacyFuture
        ? 'Choose Today or an earlier date.'
        : state.dateError;
    if (amountError != null ||
        feeError != null ||
        destinationError != null ||
        categoryError != null ||
        dateError != null) {
      state = state.copyWith(
        amountError: amountError,
        feeError: feeError,
        destinationNameError: destinationError,
        categoryError: categoryError,
        dateError: dateError,
      );
      return null;
    }
    state = state.copyWith(
      submissionPhase: AddTransferSubmissionPhase.saving,
      submissionError: null,
    );
    final DateTime now = ref.read(appClockProvider)().toUtc();
    final DateTime local = state.occurredDate.toLocal();
    final DateTime occurredAt =
        existing != null && !state.hasChangedOccurredDate
        ? existing.occurredAt
        : DateTime(local.year, local.month, local.day, 12).toUtc();
    final String? destinationName = state.destination.requiresName
        ? _emptyToNull(state.destinationName)
        : null;
    final String? note = _emptyToNull(state.note);
    final FinancialTransfer transfer = existing == null
        ? FinancialTransfer(
            id: 'trf-${now.microsecondsSinceEpoch}',
            amount: amount!,
            source: state.source,
            destination: state.destination,
            destinationName: destinationName,
            countsAsExpense: state.countsAsExpense,
            expenseCategory: state.countsAsExpense
                ? state.expenseCategory
                : null,
            fee: fee!,
            occurredAt: occurredAt,
            note: note,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            amount: amount!,
            source: state.source,
            destination: state.destination,
            destinationName: destinationName,
            countsAsExpense: state.countsAsExpense,
            expenseCategory: state.countsAsExpense
                ? state.expenseCategory
                : null,
            fee: fee!,
            occurredAt: occurredAt,
            note: note,
            updatedAt: now,
          );
    try {
      final TransferRepository repository = ref.read(
        transferRepositoryProvider,
      );
      if (existing == null) {
        await repository.createTransfer(transfer);
      } else {
        await repository.updateTransfer(transfer);
      }
      state = state.copyWith(
        submissionPhase: AddTransferSubmissionPhase.success,
        savedTransfer: transfer,
      );
      return transfer;
    } on AppException catch (error) {
      state = state.copyWith(
        submissionPhase: AddTransferSubmissionPhase.failure,
        submissionError: error.message,
      );
      return null;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'budgeting_app',
          context: ErrorDescription('while saving a transfer'),
        ),
      );
      state = state.copyWith(
        submissionPhase: AddTransferSubmissionPhase.failure,
        submissionError: 'The transfer could not be saved. Try again.',
      );
      return null;
    }
  }

  static String? _positiveMoneyError(String value, {required bool required}) {
    if (value.trim().isEmpty) return required ? 'Enter an amount.' : null;
    final Money? money = AddTransactionController.parseAmount(value);
    if (money == null) {
      return 'Enter a valid amount with up to two decimal places.';
    }
    if (!money.isPositive) return 'Amount must be greater than NPR 0.';
    if (BigInt.from(money.minorUnits) >
        TransactionAmountCalculator.maximumMinorUnits) {
      return 'Amount is larger than the supported limit.';
    }
    return null;
  }

  static String? _feeError(String value) {
    if (value.trim().isEmpty) return null;
    final Money? fee = AddTransactionController.parseAmount(value);
    if (fee == null) return 'Enter a valid fee with up to two decimal places.';
    if (fee.isNegative) return 'Transfer fee cannot be negative.';
    if (BigInt.from(fee.minorUnits) >
        TransactionAmountCalculator.maximumMinorUnits) {
      return 'Transfer fee is larger than the supported limit.';
    }
    return null;
  }

  static String? _emptyToNull(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _sameDate(DateTime a, DateTime b) {
    final DateTime first = a.toLocal();
    final DateTime second = b.toLocal();
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

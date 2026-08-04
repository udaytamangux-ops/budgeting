import 'dart:async';

import 'package:budgeting_app/core/analytics/analytics_event_names.dart';
import 'package:budgeting_app/core/analytics/app_analytics.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UndoTransactionPhase { ready, undoing, failure }

final class CreatedTransactionConfirmation {
  const CreatedTransactionConfirmation({
    required this.transaction,
    this.phase = UndoTransactionPhase.ready,
    this.errorMessage,
  });

  final FinancialTransaction transaction;
  final UndoTransactionPhase phase;
  final String? errorMessage;

  bool get isUndoing => phase == UndoTransactionPhase.undoing;

  CreatedTransactionConfirmation copyWith({
    UndoTransactionPhase? phase,
    String? errorMessage,
  }) {
    return CreatedTransactionConfirmation(
      transaction: transaction,
      phase: phase ?? this.phase,
      errorMessage: errorMessage,
    );
  }
}

final NotifierProvider<
  LastSavedTransactionController,
  CreatedTransactionConfirmation?
>
lastSavedTransactionProvider =
    NotifierProvider<
      LastSavedTransactionController,
      CreatedTransactionConfirmation?
    >(LastSavedTransactionController.new);

final class LastSavedTransactionController
    extends Notifier<CreatedTransactionConfirmation?> {
  static const Duration confirmationDuration = Duration(seconds: 8);

  Timer? _expiryTimer;

  @override
  CreatedTransactionConfirmation? build() {
    ref.onDispose(_cancelExpiry);
    return null;
  }

  void show(FinancialTransaction transaction) {
    _cancelExpiry();
    state = CreatedTransactionConfirmation(transaction: transaction);
    _expiryTimer = Timer(confirmationDuration, () {
      if (state?.transaction.id == transaction.id) {
        state = null;
      }
    });
  }

  void dismiss({String? transactionId}) {
    if (transactionId != null && state?.transaction.id != transactionId) {
      return;
    }
    _cancelExpiry();
    state = null;
  }

  Future<bool> undo() async {
    final CreatedTransactionConfirmation? confirmation = state;
    if (confirmation == null || confirmation.isUndoing) {
      return false;
    }
    final String transactionId = confirmation.transaction.id;
    _cancelExpiry();
    state = confirmation.copyWith(phase: UndoTransactionPhase.undoing);

    try {
      final TransactionRepository repository = ref.read(
        transactionRepositoryProvider,
      );
      await repository.deleteTransaction(transactionId);
      ref
          .read(appAnalyticsProvider)
          .recordEvent(AnalyticsEventNames.transactionCreateUndone);
      if (state?.transaction.id == transactionId) {
        state = null;
      }
      return true;
    } on AppException catch (error) {
      _showFailure(transactionId, 'Undo failed. ${error.message}');
      return false;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'budgeting_app',
          context: ErrorDescription('while undoing a created transaction'),
        ),
      );
      _showFailure(
        transactionId,
        'Undo failed. The transaction is still recorded. Try again.',
      );
      return false;
    }
  }

  void _showFailure(String transactionId, String message) {
    final CreatedTransactionConfirmation? current = state;
    if (current?.transaction.id != transactionId) {
      return;
    }
    state = current!.copyWith(
      phase: UndoTransactionPhase.failure,
      errorMessage: message,
    );
  }

  void _cancelExpiry() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
  }
}

import 'dart:async';

import 'package:budgeting_app/core/analytics/analytics_event_names.dart';
import 'package:budgeting_app/core/analytics/app_analytics.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transfers/domain/repositories/transfer_repository.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UndoTransactionPhase { ready, undoing, failure }

final class CreatedTransactionConfirmation {
  const CreatedTransactionConfirmation({
    required this.activity,
    this.phase = UndoTransactionPhase.ready,
    this.errorMessage,
  });

  final FinancialActivity activity;
  FinancialTransaction get transaction =>
      (activity as TransactionActivity).transaction;
  final UndoTransactionPhase phase;
  final String? errorMessage;

  bool get isUndoing => phase == UndoTransactionPhase.undoing;

  CreatedTransactionConfirmation copyWith({
    UndoTransactionPhase? phase,
    String? errorMessage,
  }) {
    return CreatedTransactionConfirmation(
      activity: activity,
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

  void show(Object value) {
    final FinancialActivity activity = switch (value) {
      final FinancialActivity activity => activity,
      final FinancialTransaction transaction => TransactionActivity(
        transaction,
      ),
      _ => throw ArgumentError.value(value, 'value'),
    };
    _cancelExpiry();
    state = CreatedTransactionConfirmation(activity: activity);
    _expiryTimer = Timer(confirmationDuration, () {
      if (state?.activity.id == activity.id) {
        state = null;
      }
    });
  }

  void dismiss({String? transactionId}) {
    if (transactionId != null && state?.activity.id != transactionId) {
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
    final String transactionId = confirmation.activity.id;
    _cancelExpiry();
    state = confirmation.copyWith(phase: UndoTransactionPhase.undoing);

    try {
      switch (confirmation.activity) {
        case TransactionActivity():
          final TransactionRepository repository = ref.read(
            transactionRepositoryProvider,
          );
          await repository.deleteTransaction(transactionId);
        case TransferActivity():
          final TransferRepository repository = ref.read(
            transferRepositoryProvider,
          );
          await repository.deleteTransfer(transactionId);
      }
      ref
          .read(appAnalyticsProvider)
          .recordEvent(AnalyticsEventNames.transactionCreateUndone);
      if (state?.activity.id == transactionId) {
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
    if (current?.activity.id != transactionId) {
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

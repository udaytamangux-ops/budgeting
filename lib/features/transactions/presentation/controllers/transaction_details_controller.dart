import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionDetailsActionState {
  const TransactionDetailsActionState({
    this.isDeleting = false,
    this.errorMessage,
  });

  final bool isDeleting;
  final String? errorMessage;
}

final AutoDisposeNotifierProviderFamily<
  TransactionDetailsController,
  TransactionDetailsActionState,
  String
>
transactionDetailsControllerProvider = NotifierProvider.autoDispose
    .family<
      TransactionDetailsController,
      TransactionDetailsActionState,
      String
    >(TransactionDetailsController.new);

final class TransactionDetailsController
    extends AutoDisposeFamilyNotifier<TransactionDetailsActionState, String> {
  @override
  TransactionDetailsActionState build(String transactionId) {
    return const TransactionDetailsActionState();
  }

  Future<bool> deleteTransaction() async {
    if (state.isDeleting) {
      return false;
    }
    state = const TransactionDetailsActionState(isDeleting: true);
    try {
      final TransactionRepository repository = ref.read(
        transactionRepositoryProvider,
      );
      await repository.deleteTransaction(arg);
      return true;
    } on AppException catch (error) {
      state = TransactionDetailsActionState(errorMessage: error.message);
      return false;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'budgeting_app',
          context: ErrorDescription('while deleting a transaction'),
        ),
      );
      state = const TransactionDetailsActionState(
        errorMessage: 'The transaction could not be deleted. Try again.',
      );
      return false;
    }
  }
}

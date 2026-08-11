import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transfers/domain/repositories/transfer_repository.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransferDetailsActionState {
  const TransferDetailsActionState({
    this.isDeleting = false,
    this.errorMessage,
  });

  final bool isDeleting;
  final String? errorMessage;
}

final transferDetailsControllerProvider = NotifierProvider.autoDispose
    .family<TransferDetailsController, TransferDetailsActionState, String>(
      TransferDetailsController.new,
    );

final class TransferDetailsController
    extends AutoDisposeFamilyNotifier<TransferDetailsActionState, String> {
  @override
  TransferDetailsActionState build(String arg) =>
      const TransferDetailsActionState();

  Future<bool> deleteTransfer() async {
    if (state.isDeleting) return false;
    state = const TransferDetailsActionState(isDeleting: true);
    try {
      final TransferRepository repository = ref.read(
        transferRepositoryProvider,
      );
      await repository.deleteTransfer(arg);
      return true;
    } on AppException catch (error) {
      state = TransferDetailsActionState(errorMessage: error.message);
      return false;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'budgeting_app',
          context: ErrorDescription('while deleting a transfer'),
        ),
      );
      state = const TransferDetailsActionState(
        errorMessage: 'The transfer could not be deleted. Try again.',
      );
      return false;
    }
  }
}

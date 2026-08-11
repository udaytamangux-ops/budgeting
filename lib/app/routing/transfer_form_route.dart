import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/add_transfer_controller.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:budgeting_app/features/transfers/presentation/screens/add_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransferFormRoute extends ConsumerWidget {
  const TransferFormRoute({
    required this.transferId,
    required this.intent,
    super.key,
  });

  final String transferId;
  final TransferFormIntent intent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(transferByIdProvider(transferId))
        .when(
          loading: () => const Scaffold(
            body: AppLoadingIndicator(label: 'Loading transfer form'),
          ),
          error: (_, _) => const Scaffold(
            body: AppErrorState(message: 'The transfer could not be loaded.'),
          ),
          data: (FinancialTransfer? transfer) {
            if (transfer == null) {
              return const Scaffold(
                body: AppErrorState(
                  title: 'Transfer not found',
                  message: 'This transfer is no longer available to edit.',
                ),
              );
            }
            return ProviderScope(
              overrides: <Override>[
                initialTransferProvider.overrideWithValue(transfer),
                transferFormIntentProvider.overrideWithValue(intent),
              ],
              child: const AddTransferScreen(),
            );
          },
        );
  }
}

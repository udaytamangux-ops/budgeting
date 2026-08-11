import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/features/transfers/data/repositories/drift_transfer_repository.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/repositories/transfer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<TransferRepository> transferRepositoryProvider =
    Provider<TransferRepository>((Ref ref) {
      return DriftTransferRepository(
        ref.watch(appDatabaseProvider),
        ownerScope: ref.watch(activeOwnerScopeProvider),
      );
    });

final StreamProvider<List<FinancialTransfer>> transferListProvider =
    StreamProvider<List<FinancialTransfer>>((Ref ref) {
      return ref.watch(transferRepositoryProvider).watchTransfers();
    });

final ProviderFamily<AsyncValue<FinancialTransfer?>, String>
transferByIdProvider = Provider.family<AsyncValue<FinancialTransfer?>, String>((
  Ref ref,
  String id,
) {
  return ref.watch(transferListProvider).whenData((
    List<FinancialTransfer> values,
  ) {
    for (final FinancialTransfer transfer in values) {
      if (transfer.id == id) return transfer;
    }
    return null;
  });
});

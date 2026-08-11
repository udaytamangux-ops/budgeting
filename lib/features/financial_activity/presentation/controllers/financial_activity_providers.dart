import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/domain/services/financial_effect_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AsyncValue<List<FinancialActivity>>>
financialActivityListProvider = Provider<AsyncValue<List<FinancialActivity>>>((
  Ref ref,
) {
  final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
    transactionListProvider,
  );
  final AsyncValue<List<FinancialTransfer>> transfers = ref.watch(
    transferListProvider,
  );
  if (transactions case AsyncError(:final error, :final stackTrace)) {
    if (kDebugMode) {
      debugPrint('Transaction activity stream failed: $error');
    }
    return AsyncValue<List<FinancialActivity>>.error(error, stackTrace);
  }
  if (transfers case AsyncError(:final error, :final stackTrace)) {
    if (kDebugMode) {
      debugPrint('Transfer activity stream failed: $error');
    }
    return AsyncValue<List<FinancialActivity>>.error(error, stackTrace);
  }
  final List<FinancialTransaction>? transactionValues =
      transactions.valueOrNull;
  final List<FinancialTransfer>? transferValues = transfers.valueOrNull;
  if (transactionValues == null || transferValues == null) {
    return const AsyncValue<List<FinancialActivity>>.loading();
  }
  return AsyncValue<List<FinancialActivity>>.data(
    const FinancialEffectService().sortNewestFirst(<FinancialActivity>[
      ...transactionValues.map(TransactionActivity.new),
      ...transferValues.map(TransferActivity.new),
    ]),
  );
});

final ProviderFamily<AsyncValue<FinancialActivity?>, String>
financialActivityByIdProvider =
    Provider.family<AsyncValue<FinancialActivity?>, String>((
      Ref ref,
      String id,
    ) {
      return ref.watch(financialActivityListProvider).whenData((values) {
        for (final FinancialActivity activity in values) {
          if (activity.id == id) return activity;
        }
        return null;
      });
    });

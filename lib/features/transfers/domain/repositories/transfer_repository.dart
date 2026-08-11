import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';

abstract interface class TransferRepository {
  Stream<List<FinancialTransfer>> watchTransfers();

  Future<FinancialTransfer?> getTransferById(String transferId);

  Future<void> createTransfer(FinancialTransfer transfer);

  Future<void> updateTransfer(FinancialTransfer transfer);

  Future<void> deleteTransfer(String transferId);
}

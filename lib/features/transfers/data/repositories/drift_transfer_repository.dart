import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transfers/data/database/transfer_database_mapper.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/repositories/transfer_repository.dart';

final class DriftTransferRepository implements TransferRepository {
  const DriftTransferRepository(
    this._database, {
    this.ownerScope = OwnerScopes.guest,
  });

  final AppDatabase _database;
  final String ownerScope;

  @override
  Stream<List<FinancialTransfer>> watchTransfers() {
    return _database
        .watchStoredTransfersForOwner(ownerScope)
        .map(
          (List<StoredTransfer> rows) => List<FinancialTransfer>.unmodifiable(
            rows.map(TransferDatabaseMapper.fromRow),
          ),
        );
  }

  @override
  Future<FinancialTransfer?> getTransferById(String transferId) async {
    try {
      final StoredTransfer? row = await _database.findStoredTransfer(
        transferId,
        ownerScope: ownerScope,
      );
      return row == null ? null : TransferDatabaseMapper.fromRow(row);
    } catch (error) {
      throw TransferRepositoryException(
        'The transfer could not be loaded. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> createTransfer(FinancialTransfer transfer) async {
    try {
      if (await _database.findStoredTransfer(
            transfer.id,
            ownerScope: ownerScope,
          ) !=
          null) {
        throw const TransferRepositoryException(
          'This transfer has already been saved.',
        );
      }
      await _database.insertStoredTransfer(
        TransferDatabaseMapper.toCompanion(transfer, ownerScope: ownerScope),
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw TransferRepositoryException(
        'The transfer could not be saved. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> updateTransfer(FinancialTransfer transfer) async {
    try {
      final int updated = await _database.updateStoredTransfer(
        transfer.id,
        TransferDatabaseMapper.toCompanion(transfer, ownerScope: ownerScope),
        ownerScope: ownerScope,
      );
      if (updated == 0) throw TransferNotFoundException(transfer.id);
    } on AppException {
      rethrow;
    } catch (error) {
      throw TransferRepositoryException(
        'The transfer could not be updated. Try again.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteTransfer(String transferId) async {
    try {
      final int deleted = await _database.deleteStoredTransfer(
        transferId,
        ownerScope: ownerScope,
      );
      if (deleted == 0) throw TransferNotFoundException(transferId);
    } on AppException {
      rethrow;
    } catch (error) {
      throw TransferRepositoryException(
        'The transfer could not be deleted. Try again.',
        cause: error,
      );
    }
  }
}

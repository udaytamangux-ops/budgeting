import 'dart:async';

import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/repositories/transfer_repository.dart';

final class InMemoryTransferRepository implements TransferRepository {
  InMemoryTransferRepository({List<FinancialTransfer>? seedTransfers})
    : _transfers = List<FinancialTransfer>.of(
        seedTransfers ?? const <FinancialTransfer>[],
      );

  final List<FinancialTransfer> _transfers;
  final StreamController<List<FinancialTransfer>> _changes =
      StreamController<List<FinancialTransfer>>.broadcast(sync: true);

  @override
  Stream<List<FinancialTransfer>> watchTransfers() async* {
    yield _snapshot();
    yield* _changes.stream;
  }

  @override
  Future<FinancialTransfer?> getTransferById(String transferId) async {
    return _transfers.cast<FinancialTransfer?>().firstWhere(
      (FinancialTransfer? value) => value?.id == transferId,
      orElse: () => null,
    );
  }

  @override
  Future<void> createTransfer(FinancialTransfer transfer) async {
    if (_transfers.any((FinancialTransfer value) => value.id == transfer.id)) {
      throw const TransferRepositoryException(
        'This transfer has already been saved.',
      );
    }
    _transfers.add(transfer);
    _emit();
  }

  @override
  Future<void> updateTransfer(FinancialTransfer transfer) async {
    final int index = _transfers.indexWhere(
      (FinancialTransfer value) => value.id == transfer.id,
    );
    if (index < 0) throw TransferNotFoundException(transfer.id);
    _transfers[index] = transfer;
    _emit();
  }

  @override
  Future<void> deleteTransfer(String transferId) async {
    final int before = _transfers.length;
    _transfers.removeWhere((FinancialTransfer value) => value.id == transferId);
    if (before == _transfers.length) {
      throw TransferNotFoundException(transferId);
    }
    _emit();
  }

  void dispose() => unawaited(_changes.close());

  List<FinancialTransfer> _snapshot() {
    final List<FinancialTransfer> values =
        List<FinancialTransfer>.of(_transfers)..sort((
          FinancialTransfer a,
          FinancialTransfer b,
        ) {
          final int occurred = b.occurredAt.compareTo(a.occurredAt);
          return occurred != 0 ? occurred : b.createdAt.compareTo(a.createdAt);
        });
    return List<FinancialTransfer>.unmodifiable(values);
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(_snapshot());
  }
}

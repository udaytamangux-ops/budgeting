import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:drift/drift.dart';

abstract final class TransferDatabaseMapper {
  static StoredTransfersCompanion toCompanion(
    FinancialTransfer transfer, {
    required String ownerScope,
  }) {
    return StoredTransfersCompanion(
      id: Value<String>(transfer.id),
      ownerScope: Value<String>(ownerScope),
      amountMinorUnits: Value<int>(transfer.amount.minorUnits),
      currencyCode: Value<String>(transfer.amount.currencyCode),
      sourceKey: Value<String>(transfer.source.stableIdentifier),
      destinationKey: Value<String>(transfer.destination.stableIdentifier),
      destinationName: Value<String?>(transfer.destinationName),
      countsAsExpense: Value<bool>(transfer.countsAsExpense),
      expenseCategoryKey: Value<String?>(
        transfer.expenseCategory == null
            ? null
            : TransactionDatabaseMapper.categoryToKey(
                transfer.expenseCategory!,
              ),
      ),
      feeMinorUnits: Value<int>(transfer.fee.minorUnits),
      occurredAtUtcMicros: Value<int>(
        transfer.occurredAt.toUtc().microsecondsSinceEpoch,
      ),
      note: Value<String?>(transfer.note),
      createdAtUtcMicros: Value<int>(
        transfer.createdAt.toUtc().microsecondsSinceEpoch,
      ),
      updatedAtUtcMicros: Value<int>(
        transfer.updatedAt.toUtc().microsecondsSinceEpoch,
      ),
    );
  }

  static FinancialTransfer fromRow(StoredTransfer row) {
    final TransferSource? source = TransferSourceMetadata.tryParse(
      row.sourceKey,
    );
    final TransferDestination? destination =
        TransferDestinationMetadata.tryParse(row.destinationKey);
    if (source == null || destination == null) {
      throw const FormatException('Unsupported stored transfer endpoint.');
    }
    return FinancialTransfer(
      id: row.id,
      amount: Money(
        minorUnits: row.amountMinorUnits,
        currencyCode: row.currencyCode,
      ),
      source: source,
      destination: destination,
      destinationName: row.destinationName,
      countsAsExpense: row.countsAsExpense,
      expenseCategory: row.expenseCategoryKey == null
          ? null
          : TransactionDatabaseMapper.categoryFromKey(row.expenseCategoryKey!),
      fee: Money(minorUnits: row.feeMinorUnits, currencyCode: row.currencyCode),
      occurredAt: DateTime.fromMicrosecondsSinceEpoch(
        row.occurredAtUtcMicros,
        isUtc: true,
      ),
      note: row.note,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(
        row.createdAtUtcMicros,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(
        row.updatedAtUtcMicros,
        isUtc: true,
      ),
    );
  }
}

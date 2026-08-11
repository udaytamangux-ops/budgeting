import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/data/repositories/drift_transfer_repository.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('round-trips every transfer field with integer Money', () async {
    final repository = DriftTransferRepository(database);
    final transfer = buildTestTransfer(
      minorUnits: 900719925474,
      destination: TransferDestination.person,
      destinationName: 'Mom',
      countsAsExpense: true,
      expenseCategory: TransactionCategory.family,
      feeMinorUnits: 1050,
      note: 'Family support',
    );

    await repository.createTransfer(transfer);
    final restored = await repository.getTransferById(transfer.id);

    expect(restored?.amount.minorUnits, 900719925474);
    expect(restored?.source, transfer.source);
    expect(restored?.destination, TransferDestination.person);
    expect(restored?.destinationName, 'Mom');
    expect(restored?.countsAsExpense, isTrue);
    expect(restored?.expenseCategory, TransactionCategory.family);
    expect(restored?.fee.minorUnits, 1050);
    expect(restored?.occurredAt, transfer.occurredAt);
    expect(restored?.note, transfer.note);
  });

  test('create update delete streams remain owner scoped', () async {
    final ownerA = DriftTransferRepository(database, ownerScope: 'owner-a');
    final ownerB = DriftTransferRepository(database, ownerScope: 'owner-b');
    final transfer = buildTestTransfer(id: 'shared-id');
    await ownerA.createTransfer(transfer);
    await ownerB.createTransfer(
      buildTestTransfer(id: 'owner-b-transfer', note: 'Owner B'),
    );

    expect(await ownerA.watchTransfers().first, hasLength(1));
    expect((await ownerB.watchTransfers().first).single.note, 'Owner B');

    await ownerA.updateTransfer(transfer.copyWith(note: 'Updated A'));
    expect((await ownerA.getTransferById(transfer.id))?.note, 'Updated A');
    expect((await ownerB.getTransferById('owner-b-transfer'))?.note, 'Owner B');

    await ownerA.deleteTransfer(transfer.id);
    expect(await ownerA.getTransferById(transfer.id), isNull);
    expect(await ownerB.getTransferById('owner-b-transfer'), isNotNull);
  });
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';
import 'package:budgeting_app/features/data_portability/domain/services/backup_codec.dart';
import 'package:budgeting_app/features/data_portability/domain/services/backup_exceptions.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final BackupCodec codec = BackupCodec(
    RecurrenceService(BikramSambatCalendarService()),
  );

  test('v2 backup round-trips full financial state exactly', () {
    final PortableBackup original = _backup();
    final Uint8List firstEncoding = codec.encode(original);
    final PortableBackup restored = codec.decode(firstEncoding);
    final Uint8List secondEncoding = codec.encode(restored);

    expect(utf8.decode(secondEncoding), utf8.decode(firstEncoding));
    expect(restored.sourceDatabaseSchemaVersion, 3);
    expect(
      restored.snapshot.transactions.single.amount.minorUnits,
      900719925474,
    );
    expect(
      restored.snapshot.transactions.single.note,
      'Line one\nनेपाली, "text"',
    );
    expect(
      restored.snapshot.recurringRules.single.status,
      RecurringRuleStatus.deleted,
    );
    expect(
      restored.snapshot.recurringOccurrences.last.recordedTransactionId,
      isNull,
    );

    final Map<String, Object?> json = jsonDecode(utf8.decode(firstEncoding));
    expect(json['backupFormatVersion'], 2);
    expect(json.toString(), isNot(contains('ownerScope')));
    expect(json.toString(), isNot(contains('theme_mode')));
  });

  test('empty financial state is a valid deterministic v2 backup', () {
    final PortableBackup backup = PortableBackup(
      createdAtUtc: DateTime.utc(2026, 8, 8, 12),
      sourceDatabaseSchemaVersion: 3,
      snapshot: const FinancialDataSnapshot(
        transactions: <FinancialTransaction>[],
        recurringRules: <RecurringTransactionRule>[],
        recurringOccurrences: <RecurringTransactionOccurrence>[],
      ),
    );
    final PortableBackup decoded = codec.decode(codec.encode(backup));
    expect(decoded.snapshot.transactions, isEmpty);
    expect(decoded.snapshot.recurringRules, isEmpty);
    expect(decoded.snapshot.recurringOccurrences, isEmpty);
  });

  test('v2 supports all categories, payment methods and recurrence states', () {
    final DateTime now = DateTime.utc(2026, 8, 8, 12);
    final List<FinancialTransaction> transactions = <FinancialTransaction>[];
    for (int index = 0; index < TransactionCategory.values.length; index++) {
      final TransactionCategory category = TransactionCategory.values[index];
      final TransactionType type = category.supports(TransactionType.expense)
          ? TransactionType.expense
          : TransactionType.income;
      transactions.add(
        FinancialTransaction(
          id: 'tx-$index',
          type: type,
          amount: Money(minorUnits: index + 1),
          category: category,
          paymentMethod:
              PaymentMethod.values[index % PaymentMethod.values.length],
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    final RecurrenceService recurrence = RecurrenceService(
      BikramSambatCalendarService(),
    );
    final List<RecurringTransactionRule> rules = <RecurringTransactionRule>[];
    final List<RecurringTransactionOccurrence> occurrences =
        <RecurringTransactionOccurrence>[];
    for (int index = 0; index < RecurringFrequency.values.length; index++) {
      final AppCalendarSystem calendar = index.isEven
          ? AppCalendarSystem.gregorianAd
          : AppCalendarSystem.bikramSambatBs;
      final anchors = recurrence.anchorsFor(now, calendar);
      final RecurringRuleStatus status = RecurringRuleStatus.values[index];
      final RecurringTransactionRule rule = RecurringTransactionRule(
        id: 'rule-$index',
        type: TransactionType.expense,
        amount: Money(minorUnits: 100 + index),
        category: TransactionCategory.food,
        paymentMethod: PaymentMethod.values[index],
        frequency: RecurringFrequency.values[index],
        recurrenceCalendar: calendar,
        anchorDay: anchors.day,
        anchorMonth: anchors.month,
        anchorWeekday: anchors.weekday,
        firstDueDateAd: now,
        nextDueDateAd: now.add(Duration(days: 30 * (index + 1))),
        status: status,
        createdAt: now,
        updatedAt: now,
        pausedAt: status == RecurringRuleStatus.paused ? now : null,
        deletedAt: status == RecurringRuleStatus.deleted ? now : null,
      );
      rules.add(rule);
      final RecurringOccurrenceStatus occurrenceStatus =
          RecurringOccurrenceStatus.values[index];
      occurrences.add(
        RecurringTransactionOccurrence(
          id: 'occ-$index',
          ruleId: rule.id,
          dueDateAd: now,
          status: occurrenceStatus,
          type: rule.type,
          amount: rule.amount,
          category: rule.category,
          paymentMethod: rule.paymentMethod,
          recordedTransactionId:
              occurrenceStatus == RecurringOccurrenceStatus.recorded
              ? transactions.first.id
              : null,
          handledAt: occurrenceStatus == RecurringOccurrenceStatus.pending
              ? null
              : now,
          createdAt: now,
        ),
      );
    }
    final PortableBackup restored = codec.decode(
      codec.encode(
        PortableBackup(
          createdAtUtc: now,
          sourceDatabaseSchemaVersion: 3,
          snapshot: FinancialDataSnapshot(
            transactions: transactions,
            recurringRules: rules,
            recurringOccurrences: occurrences,
          ),
        ),
      ),
    );
    expect(
      restored.snapshot.transactions.map((value) => value.category).toSet(),
      TransactionCategory.values.toSet(),
    );
    expect(
      restored.snapshot.transactions
          .map((value) => value.paymentMethod)
          .toSet(),
      PaymentMethod.values.toSet(),
    );
    expect(
      restored.snapshot.recurringRules.map((value) => value.frequency).toSet(),
      RecurringFrequency.values.toSet(),
    );
    expect(
      restored.snapshot.recurringOccurrences
          .map((value) => value.status)
          .toSet(),
      RecurringOccurrenceStatus.values.toSet(),
    );
  });

  test('v1 remains restorable and does not invent transfers', () {
    final Map<String, Object?> legacy = _json(codec);
    legacy['backupFormatVersion'] = 1;
    _records(legacy).remove('transfers');

    final PortableBackup restored = codec.decode(
      Uint8List.fromList(utf8.encode(jsonEncode(legacy))),
    );

    expect(restored.snapshot.transactions, hasLength(1));
    expect(restored.snapshot.transfers, isEmpty);
  });

  group('validation rejects before producing a snapshot', () {
    test('empty, malformed, missing and unsupported versions', () {
      expect(
        () => codec.decode(Uint8List(0)),
        throwsA(isA<BackupValidationException>()),
      );
      expect(
        () => codec.decode(Uint8List.fromList(utf8.encode('{no'))),
        throwsA(isA<BackupValidationException>()),
      );
      final Map<String, Object?> missing = _json(codec);
      missing.remove('backupFormatVersion');
      expect(
        () => _decode(codec, missing),
        throwsA(isA<BackupValidationException>()),
      );
      final Map<String, Object?> unsupported = _json(codec);
      unsupported['backupFormatVersion'] = 3;
      expect(
        () => _decode(codec, unsupported),
        throwsA(
          isA<BackupValidationException>().having(
            (error) => error.issue,
            'issue',
            BackupValidationIssue.unsupportedVersion,
          ),
        ),
      );
    });

    test('wrong field types and invalid stable identifiers', () {
      final Map<String, Object?> wrongType = _json(codec);
      wrongType['currency'] = 7;
      expect(
        () => _decode(codec, wrongType),
        throwsA(isA<BackupValidationException>()),
      );

      for (final String field in <String>[
        'type',
        'category',
        'paymentMethod',
      ]) {
        final Map<String, Object?> invalid = _json(codec);
        _transactions(invalid).single[field] = 'unsupported';
        expect(
          () => _decode(codec, invalid),
          throwsA(isA<BackupValidationException>()),
        );
      }
    });

    test('invalid Money, AD date, timestamp and recurring anchors', () {
      final Map<String, Object?> money = _json(codec);
      _transactions(money).single['amountMinorUnits'] = 1.5;
      expect(
        () => _decode(codec, money),
        throwsA(isA<BackupValidationException>()),
      );

      final Map<String, Object?> date = _json(codec);
      _transactions(date).single['dateAd'] = '2026-02-31';
      expect(
        () => _decode(codec, date),
        throwsA(isA<BackupValidationException>()),
      );

      final Map<String, Object?> timestamp = _json(codec);
      _transactions(timestamp).single['createdAtUtc'] = '2026-08-08T12:00:00';
      expect(
        () => _decode(codec, timestamp),
        throwsA(isA<BackupValidationException>()),
      );

      final Map<String, Object?> anchor = _json(codec);
      _rules(anchor).single['anchorDay'] = 33;
      expect(
        () => _decode(codec, anchor),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('invalid recurrence identifiers are rejected', () {
      for (final String field in <String>[
        'frequency',
        'recurrenceCalendar',
        'status',
      ]) {
        final Map<String, Object?> invalid = _json(codec);
        _rules(invalid).single[field] = 'unsupported';
        expect(
          () => _decode(codec, invalid),
          throwsA(isA<BackupValidationException>()),
        );
      }
      final Map<String, Object?> occurrence = _json(codec);
      _occurrences(occurrence).first['status'] = 'unsupported';
      expect(
        () => _decode(codec, occurrence),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('duplicate IDs, duplicate rule dates and broken links', () {
      final Map<String, Object?> duplicateTransaction = _json(codec);
      _transactions(duplicateTransaction).add(
        Map<String, Object?>.from(_transactions(duplicateTransaction).single),
      );
      expect(
        () => _decode(codec, duplicateTransaction),
        throwsA(isA<BackupValidationException>()),
      );

      final Map<String, Object?> missingRule = _json(codec);
      _occurrences(missingRule).first['ruleId'] = 'missing';
      expect(
        () => _decode(codec, missingRule),
        throwsA(isA<BackupValidationException>()),
      );

      final Map<String, Object?> missingTransaction = _json(codec);
      _occurrences(missingTransaction).first['recordedTransactionId'] =
          'missing';
      expect(
        () => _decode(codec, missingTransaction),
        throwsA(isA<BackupValidationException>()),
      );

      final Map<String, Object?> duplicateDate = _json(codec);
      final Map<String, Object?> duplicate = Map<String, Object?>.from(
        _occurrences(duplicateDate).first,
      );
      duplicate['id'] = 'another-occurrence';
      _occurrences(duplicateDate).add(duplicate);
      expect(
        () => _decode(codec, duplicateDate),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('oversized file is rejected without parsing', () {
      expect(
        () => codec.decode(Uint8List(BackupCodec.maximumFileBytes + 1)),
        throwsA(
          isA<BackupValidationException>().having(
            (error) => error.issue,
            'issue',
            BackupValidationIssue.oversized,
          ),
        ),
      );
    });
  });
}

PortableBackup _backup() {
  final DateTime created = DateTime.utc(2026, 8, 8, 12);
  final FinancialTransaction transaction = FinancialTransaction(
    id: 'tx-1',
    type: TransactionType.expense,
    amount: const Money(minorUnits: 900719925474),
    category: TransactionCategory.food,
    paymentMethod: PaymentMethod.eSewa,
    occurredAt: DateTime.utc(2026, 8, 7, 12),
    merchant: 'Cafe, Kathmandu',
    note: 'Line one\nनेपाली, "text"',
    createdAt: created,
    updatedAt: created.add(const Duration(minutes: 5)),
  );
  final RecurringTransactionRule rule = RecurringTransactionRule(
    id: 'rule-1',
    type: TransactionType.expense,
    amount: const Money(minorUnits: 150050),
    category: TransactionCategory.rentAndHousing,
    paymentMethod: PaymentMethod.bankAccount,
    frequency: RecurringFrequency.monthly,
    recurrenceCalendar: AppCalendarSystem.bikramSambatBs,
    anchorDay: 22,
    anchorMonth: 4,
    anchorWeekday: DateTime.friday,
    firstDueDateAd: DateTime.utc(2026, 8, 7, 12),
    nextDueDateAd: DateTime.utc(2026, 9, 8, 12),
    status: RecurringRuleStatus.deleted,
    createdAt: created,
    updatedAt: created,
    deletedAt: created,
  );
  final List<RecurringTransactionOccurrence> occurrences =
      <RecurringTransactionOccurrence>[
        RecurringTransactionOccurrence(
          id: 'occ-recorded',
          ruleId: rule.id,
          dueDateAd: DateTime.utc(2026, 8, 7, 12),
          status: RecurringOccurrenceStatus.recorded,
          type: transaction.type,
          amount: transaction.amount,
          category: transaction.category,
          paymentMethod: transaction.paymentMethod,
          recordedTransactionId: transaction.id,
          handledAt: created,
          createdAt: created,
        ),
        RecurringTransactionOccurrence(
          id: 'occ-recorded-deleted-tx',
          ruleId: rule.id,
          dueDateAd: DateTime.utc(2026, 7, 7, 12),
          status: RecurringOccurrenceStatus.recorded,
          type: transaction.type,
          amount: transaction.amount,
          category: transaction.category,
          paymentMethod: transaction.paymentMethod,
          handledAt: created,
          createdAt: created,
        ),
      ];
  return PortableBackup(
    createdAtUtc: created,
    sourceDatabaseSchemaVersion: 3,
    snapshot: FinancialDataSnapshot(
      transactions: <FinancialTransaction>[transaction],
      transfers: <FinancialTransfer>[
        FinancialTransfer(
          id: 'transfer-1',
          amount: const Money(minorUnits: 200000),
          source: TransferSource.bankAccount,
          destination: TransferDestination.person,
          destinationName: 'Mom',
          countsAsExpense: true,
          expenseCategory: TransactionCategory.family,
          fee: const Money(minorUnits: 1000),
          occurredAt: DateTime.utc(2026, 8, 7, 12),
          note: 'Family transfer',
          createdAt: created,
          updatedAt: created,
        ),
      ],
      recurringRules: <RecurringTransactionRule>[rule],
      recurringOccurrences: occurrences,
    ),
  );
}

Map<String, Object?> _json(BackupCodec codec) =>
    jsonDecode(utf8.decode(codec.encode(_backup()))) as Map<String, Object?>;

void _decode(BackupCodec codec, Map<String, Object?> value) =>
    codec.decode(Uint8List.fromList(utf8.encode(jsonEncode(value))));

Map<String, Object?> _records(Map<String, Object?> value) =>
    value['records']! as Map<String, Object?>;

List<Map<String, Object?>> _transactions(Map<String, Object?> value) =>
    (_records(value)['transactions']! as List<Object?>)
        .cast<Map<String, Object?>>();

List<Map<String, Object?>> _rules(Map<String, Object?> value) =>
    (_records(value)['recurringRules']! as List<Object?>)
        .cast<Map<String, Object?>>();

List<Map<String, Object?>> _occurrences(Map<String, Object?> value) =>
    (_records(value)['recurringOccurrences']! as List<Object?>)
        .cast<Map<String, Object?>>();

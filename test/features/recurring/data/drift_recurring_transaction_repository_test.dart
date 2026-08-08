import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/recurring/data/repositories/drift_recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart'
    as domain;
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart'
    as domain;
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurring_date_service.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  late AppDatabase database;
  late DriftRecurringTransactionRepository repository;
  late DriftTransactionRepository transactionRepository;
  final RecurrenceService service = RecurrenceService(
    BikramSambatCalendarService(),
  );
  const RecurringDateService dateService = RecurringDateService();

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftRecurringTransactionRepository(database, service);
    transactionRepository = DriftTransactionRepository(database);
  });

  tearDown(() => database.close());

  domain.RecurringTransactionRule buildRule({
    String id = 'rule-1',
    RecurringFrequency frequency = RecurringFrequency.monthly,
    DateTime? firstDue,
    DateTime? nextDue,
    Money amount = const Money(minorUnits: 120000),
    RecurringRuleStatus status = RecurringRuleStatus.active,
    AppCalendarSystem calendar = AppCalendarSystem.gregorianAd,
    String? merchant = 'Internet',
  }) {
    final DateTime first = dateService.canonicalLocalNoon(
      firstDue ?? DateTime(2026, 6, 1),
    );
    final anchors = service.anchorsFor(first, calendar);
    return domain.RecurringTransactionRule(
      id: id,
      type: TransactionType.expense,
      amount: amount,
      category: TransactionCategory.utilities,
      paymentMethod: PaymentMethod.eSewa,
      merchant: merchant,
      note: 'Monthly service',
      frequency: frequency,
      recurrenceCalendar: calendar,
      anchorDay: anchors.day,
      anchorMonth: anchors.month,
      anchorWeekday: anchors.weekday,
      firstDueDateAd: first,
      nextDueDateAd: dateService.canonicalLocalNoon(nextDue ?? first),
      status: status,
      createdAt: fixedNow,
      updatedAt: fixedNow,
      pausedAt: status == RecurringRuleStatus.paused ? fixedNow : null,
    );
  }

  test('database starts with no recurring rules or occurrences', () async {
    expect(await repository.watchRules().first, isEmpty);
    expect(await repository.watchPendingOccurrences().first, isEmpty);
    expect(database.schemaVersion, 3);
  });

  test('create persists every rule field with stable identifiers', () async {
    final domain.RecurringTransactionRule rule = buildRule();
    await repository.createRule(rule);

    final domain.RecurringTransactionRule restored = (await repository
        .getRuleById(rule.id))!;
    expect(restored.type, rule.type);
    expect(restored.amount, rule.amount);
    expect(restored.category, rule.category);
    expect(restored.paymentMethod, rule.paymentMethod);
    expect(restored.frequency, rule.frequency);
    expect(restored.recurrenceCalendar, rule.recurrenceCalendar);
    expect(restored.anchorDay, rule.anchorDay);
    expect(restored.firstDueDateAd, rule.firstDueDateAd);
    final RecurringTransactionRule row = await database
        .select(database.recurringTransactionRules)
        .getSingle();
    expect(row.frequencyKey, 'monthly');
    expect(row.recurrenceCalendarKey, 'gregorian_ad');
    expect(row.paymentMethodKey, 'esewa');
    expect(row.ownerScope, 'guest');
  });

  test('reconciliation is lazy, idempotent, and oldest first', () async {
    final domain.RecurringTransactionRule rule = buildRule();
    await repository.createRule(rule);

    await repository.reconcileThrough(
      today: DateTime(2026, 5, 31),
      handledAt: fixedNow,
    );
    expect(await repository.watchPendingOccurrences().first, isEmpty);

    await repository.reconcileThrough(
      today: DateTime(2026, 8, 1),
      handledAt: fixedNow,
    );
    await repository.reconcileThrough(
      today: DateTime(2026, 8, 1),
      handledAt: fixedNow,
    );
    final List<domain.RecurringTransactionOccurrence> pending = await repository
        .watchPendingOccurrences()
        .first;
    expect(pending, hasLength(3));
    expect(pending.map((value) => value.dueDateAd.toLocal().month), <int>[
      6,
      7,
      8,
    ]);
    expect(
      await database.select(database.recurringTransactionOccurrences).get(),
      hasLength(3),
    );
    expect(
      (await repository.getRuleById(rule.id))!.nextDueDateAd.toLocal().month,
      9,
    );
  });

  test('occurrence snapshot is unchanged when rule is edited', () async {
    final domain.RecurringTransactionRule rule = buildRule();
    await repository.createRule(rule);
    await repository.reconcileThrough(
      today: DateTime(2026, 6, 1),
      handledAt: fixedNow,
    );
    final domain.RecurringTransactionOccurrence waiting =
        (await repository.watchPendingOccurrences().first).single;

    await repository.updateRule(
      rule.copyWith(
        amount: const Money(minorUnits: 150000),
        nextDueDateAd: DateTime(2026, 7, 1, 12).toUtc(),
        updatedAt: fixedNow.add(const Duration(minutes: 1)),
      ),
    );

    final domain.RecurringTransactionOccurrence unchanged = (await repository
        .getOccurrenceById(waiting.id))!;
    expect(unchanged.amount.minorUnits, 120000);
    expect((await repository.getRuleById(rule.id))!.amount.minorUnits, 150000);
  });

  test('owner scopes isolate rules and pending occurrences', () async {
    final DriftRecurringTransactionRepository userRepository =
        DriftRecurringTransactionRepository(
          database,
          service,
          ownerScope: 'user:future-id',
        );
    await repository.createRule(buildRule(id: 'guest-rule'));
    await userRepository.createRule(buildRule(id: 'user-rule'));
    await repository.reconcileThrough(
      today: DateTime(2026, 6, 1),
      handledAt: fixedNow,
    );
    await userRepository.reconcileThrough(
      today: DateTime(2026, 6, 1),
      handledAt: fixedNow,
    );

    expect((await repository.watchRules().first).single.id, 'guest-rule');
    expect((await userRepository.watchRules().first).single.id, 'user-rule');
    expect(
      (await repository.watchPendingOccurrences().first).single.ruleId,
      'guest-rule',
    );
  });

  test('record atomically creates transaction and marks occurrence', () async {
    await repository.createRule(buildRule());
    await repository.reconcileThrough(
      today: DateTime(2026, 6, 1),
      handledAt: fixedNow,
    );
    final domain.RecurringTransactionOccurrence occurrence =
        (await repository.watchPendingOccurrences().first).single;
    final FinancialTransaction transaction = buildTestTransaction(
      id: 'recorded-from-occurrence',
      occurredAt: occurrence.dueDateAd,
      paymentMethod: occurrence.paymentMethod,
    );

    await repository.recordOccurrence(
      occurrenceId: occurrence.id,
      transaction: transaction,
    );

    expect(await repository.watchPendingOccurrences().first, isEmpty);
    expect(
      (await transactionRepository.watchTransactions().first).single.id,
      transaction.id,
    );
    final RecurringTransactionOccurrence row = await database
        .select(database.recurringTransactionOccurrences)
        .getSingle();
    expect(row.statusKey, 'recorded');
    expect(row.recordedTransactionId, transaction.id);
  });

  test(
    'failed record leaves occurrence pending and creates no duplicate',
    () async {
      await repository.createRule(buildRule());
      await repository.reconcileThrough(
        today: DateTime(2026, 6, 1),
        handledAt: fixedNow,
      );
      final domain.RecurringTransactionOccurrence occurrence =
          (await repository.watchPendingOccurrences().first).single;
      final FinancialTransaction duplicate = buildTestTransaction(
        id: 'duplicate',
      );
      await transactionRepository.createTransaction(duplicate);

      expect(
        () => repository.recordOccurrence(
          occurrenceId: occurrence.id,
          transaction: duplicate,
        ),
        throwsA(isA<RecurringRepositoryException>()),
      );
      expect(await repository.watchPendingOccurrences().first, hasLength(1));
      expect(
        await transactionRepository.watchTransactions().first,
        hasLength(1),
      );
    },
  );

  test('skip handles only one occurrence and creates no transaction', () async {
    await repository.createRule(buildRule());
    await repository.reconcileThrough(
      today: DateTime(2026, 7, 1),
      handledAt: fixedNow,
    );
    final List<domain.RecurringTransactionOccurrence> pending = await repository
        .watchPendingOccurrences()
        .first;
    await repository.skipOccurrence(pending.first.id, now: fixedNow);

    expect(await repository.watchPendingOccurrences().first, hasLength(1));
    expect(await transactionRepository.watchTransactions().first, isEmpty);
    final RecurringTransactionOccurrence skipped = await (database.select(
      database.recurringTransactionOccurrences,
    )..where((table) => table.id.equals(pending.first.id))).getSingle();
    expect(skipped.statusKey, 'skipped');
    expect(skipped.handledAtUtcMicros, fixedNow.microsecondsSinceEpoch);
  });

  test('pause retains pending and resume skips pause-period backlog', () async {
    await repository.createRule(buildRule());
    await repository.reconcileThrough(
      today: DateTime(2026, 6, 1),
      handledAt: fixedNow,
    );
    await repository.pauseRule('rule-1', now: DateTime.utc(2026, 6, 2));
    await repository.reconcileThrough(
      today: DateTime(2026, 9, 15),
      handledAt: DateTime.utc(2026, 9, 15),
    );
    expect(await repository.watchPendingOccurrences().first, hasLength(1));

    await repository.resumeRule(
      'rule-1',
      resumeDate: DateTime(2026, 9, 15),
      now: DateTime.utc(2026, 9, 15),
    );
    final domain.RecurringTransactionRule resumed = (await repository
        .getRuleById('rule-1'))!;
    expect(resumed.status, RecurringRuleStatus.active);
    expect(resumed.nextDueDateAd.toLocal(), DateTime(2026, 10, 1, 12));
    expect(await repository.watchPendingOccurrences().first, hasLength(1));
  });

  test('resume is inclusive when the date is a valid occurrence', () async {
    await repository.createRule(buildRule(status: RecurringRuleStatus.paused));
    await repository.resumeRule(
      'rule-1',
      resumeDate: DateTime(2026, 8, 1),
      now: DateTime.utc(2026, 8, 1),
    );
    expect(
      (await repository.getRuleById('rule-1'))!.nextDueDateAd.toLocal(),
      DateTime(2026, 8, 1, 12),
    );
  });

  test(
    'delete hides rule, dismisses pending, and preserves transactions',
    () async {
      await transactionRepository.createTransaction(buildTestTransaction());
      await repository.createRule(buildRule());
      await repository.reconcileThrough(
        today: DateTime(2026, 6, 1),
        handledAt: fixedNow,
      );
      await repository.deleteRule('rule-1', now: fixedNow);

      expect(await repository.watchRules().first, isEmpty);
      expect(await repository.watchPendingOccurrences().first, isEmpty);
      expect(
        await transactionRepository.watchTransactions().first,
        hasLength(1),
      );
      expect(
        (await database.select(database.recurringTransactionRules).getSingle())
            .statusKey,
        'deleted',
      );
    },
  );

  test(
    'deleting a recorded transaction clears link without reopening due',
    () async {
      await repository.createRule(buildRule());
      await repository.reconcileThrough(
        today: DateTime(2026, 6, 1),
        handledAt: fixedNow,
      );
      final domain.RecurringTransactionOccurrence occurrence =
          (await repository.watchPendingOccurrences().first).single;
      final FinancialTransaction transaction = buildTestTransaction(
        id: 'linked-transaction',
      );
      await repository.recordOccurrence(
        occurrenceId: occurrence.id,
        transaction: transaction,
      );

      await transactionRepository.deleteTransaction(transaction.id);

      final RecurringTransactionOccurrence row = await database
          .select(database.recurringTransactionOccurrences)
          .getSingle();
      expect(row.statusKey, 'recorded');
      expect(row.recordedTransactionId, isNull);
      expect(await repository.watchPendingOccurrences().first, isEmpty);
    },
  );

  test('corrupted rule is bounded and does not block a valid rule', () async {
    final domain.RecurringTransactionRule invalid = buildRule(
      id: 'invalid',
    ).copyWith(anchorDay: 0);
    await database
        .into(database.recurringTransactionRules)
        .insert(
          RecurringTransactionRulesCompanion.insert(
            id: invalid.id,
            ownerScope: 'guest',
            typeKey: 'expense',
            amountMinorUnits: 100,
            currencyCode: 'NPR',
            categoryKey: 'utilities',
            paymentMethodKey: 'cash',
            frequencyKey: 'monthly',
            recurrenceCalendarKey: 'gregorian_ad',
            anchorDay: 0,
            anchorMonth: 6,
            anchorWeekday: 1,
            firstDueDateAdUtcMicros:
                invalid.firstDueDateAd.microsecondsSinceEpoch,
            nextDueDateAdUtcMicros:
                invalid.nextDueDateAd.microsecondsSinceEpoch,
            statusKey: 'active',
            createdAtUtcMicros: fixedNow.microsecondsSinceEpoch,
            updatedAtUtcMicros: fixedNow.microsecondsSinceEpoch,
          ),
        );
    await repository.createRule(buildRule(id: 'valid'));

    await repository.reconcileThrough(
      today: DateTime(2026, 6, 1),
      handledAt: fixedNow,
    );

    expect(
      (await repository.watchPendingOccurrences().first).single.ruleId,
      'valid',
    );
  });
}

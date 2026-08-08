import 'dart:async';

import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/repositories/recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurring_date_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';

final class InMemoryRecurringTransactionRepository
    implements RecurringTransactionRepository {
  InMemoryRecurringTransactionRepository(
    this._recurrenceService,
    this._transactionRepository, {
    Iterable<RecurringTransactionRule> rules =
        const <RecurringTransactionRule>[],
    Iterable<RecurringTransactionOccurrence> occurrences =
        const <RecurringTransactionOccurrence>[],
  }) : _rules = <String, RecurringTransactionRule>{
         for (final RecurringTransactionRule rule in rules) rule.id: rule,
       },
       _occurrences = <String, RecurringTransactionOccurrence>{
         for (final RecurringTransactionOccurrence occurrence in occurrences)
           occurrence.id: occurrence,
       };

  final RecurrenceService _recurrenceService;
  final TransactionRepository _transactionRepository;
  final Map<String, RecurringTransactionRule> _rules;
  final Map<String, RecurringTransactionOccurrence> _occurrences;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );
  static const RecurringDateService _dateService = RecurringDateService();

  void dispose() => _changes.close();

  @override
  Stream<List<RecurringTransactionRule>> watchRules() async* {
    yield _visibleRules();
    await for (final _ in _changes.stream) {
      yield _visibleRules();
    }
  }

  @override
  Stream<List<RecurringTransactionOccurrence>>
  watchPendingOccurrences() async* {
    yield _pendingOccurrences();
    await for (final _ in _changes.stream) {
      yield _pendingOccurrences();
    }
  }

  List<RecurringTransactionRule> _visibleRules() {
    final List<RecurringTransactionRule> values =
        _rules.values
            .where((rule) => rule.status != RecurringRuleStatus.deleted)
            .toList(growable: false)
          ..sort((a, b) => a.nextDueDateAd.compareTo(b.nextDueDateAd));
    return values;
  }

  List<RecurringTransactionOccurrence> _pendingOccurrences() {
    final List<RecurringTransactionOccurrence> values =
        _occurrences.values
            .where(
              (occurrence) =>
                  occurrence.status == RecurringOccurrenceStatus.pending,
            )
            .toList(growable: false)
          ..sort((a, b) => a.dueDateAd.compareTo(b.dueDateAd));
    return values;
  }

  @override
  Future<RecurringTransactionRule?> getRuleById(String ruleId) async =>
      _rules[ruleId];

  @override
  Future<RecurringTransactionOccurrence?> getOccurrenceById(
    String occurrenceId,
  ) async => _occurrences[occurrenceId];

  @override
  Future<void> createRule(RecurringTransactionRule rule) async {
    if (_rules.containsKey(rule.id)) {
      throw const RecurringRepositoryException(
        'This recurring schedule has already been saved.',
      );
    }
    _rules[rule.id] = rule;
    _notify();
  }

  @override
  Future<void> updateRule(RecurringTransactionRule rule) async {
    if (!_rules.containsKey(rule.id)) {
      throw const RecurringRepositoryException(
        'This recurring schedule is no longer available.',
      );
    }
    _rules[rule.id] = rule;
    _notify();
  }

  @override
  Future<void> reconcileThrough({
    required DateTime today,
    required DateTime handledAt,
  }) async {
    final DateTime through = _dateService.canonicalLocalNoon(today);
    bool changed = false;
    for (final RecurringTransactionRule original in List.of(_rules.values)) {
      if (!original.isActive) {
        continue;
      }
      try {
        _recurrenceService.validateRule(original);
      } on FormatException {
        continue;
      } on RangeError {
        continue;
      }
      RecurringTransactionRule rule = original;
      DateTime candidate = _dateService.canonicalLocalNoon(rule.nextDueDateAd);
      int generated = 0;
      while (!candidate.isAfter(through)) {
        final String id = 'occ-${rule.id}-${candidate.microsecondsSinceEpoch}';
        final bool alreadyExisted = _occurrences.containsKey(id);
        _occurrences.putIfAbsent(
          id,
          () => RecurringTransactionOccurrence(
            id: id,
            ruleId: rule.id,
            dueDateAd: candidate,
            status: RecurringOccurrenceStatus.pending,
            type: rule.type,
            amount: rule.amount,
            category: rule.category,
            paymentMethod: rule.paymentMethod,
            merchant: rule.merchant,
            note: rule.note,
            createdAt: handledAt.toUtc(),
          ),
        );
        changed = changed || !alreadyExisted;
        generated += 1;
        if (generated > 1000) {
          throw const RecurringRepositoryException(
            'This recurring schedule contains too many missed dates.',
          );
        }
        try {
          candidate = _recurrenceService.nextOccurrence(rule, candidate);
        } on RecurrenceRangeException {
          rule = rule.copyWith(
            status: RecurringRuleStatus.paused,
            pausedAt: handledAt.toUtc(),
          );
          break;
        }
      }
      if (generated > 0) {
        _rules[rule.id] = rule.copyWith(
          nextDueDateAd: candidate,
          updatedAt: handledAt.toUtc(),
        );
        changed = true;
      }
    }
    if (changed) {
      _notify();
    }
  }

  @override
  Future<void> recordOccurrence({
    required String occurrenceId,
    required FinancialTransaction transaction,
  }) async {
    final RecurringTransactionOccurrence? occurrence =
        _occurrences[occurrenceId];
    if (occurrence == null ||
        occurrence.status != RecurringOccurrenceStatus.pending) {
      throw const RecurringRepositoryException(
        'This scheduled occurrence is no longer waiting.',
      );
    }
    await _transactionRepository.createTransaction(transaction);
    _occurrences[occurrenceId] = RecurringTransactionOccurrence(
      id: occurrence.id,
      ruleId: occurrence.ruleId,
      dueDateAd: occurrence.dueDateAd,
      status: RecurringOccurrenceStatus.recorded,
      type: occurrence.type,
      amount: occurrence.amount,
      category: occurrence.category,
      paymentMethod: occurrence.paymentMethod,
      merchant: occurrence.merchant,
      note: occurrence.note,
      recordedTransactionId: transaction.id,
      handledAt: transaction.createdAt,
      createdAt: occurrence.createdAt,
    );
    _notify();
  }

  @override
  Future<void> skipOccurrence(
    String occurrenceId, {
    required DateTime now,
  }) async {
    final RecurringTransactionOccurrence? occurrence =
        _occurrences[occurrenceId];
    if (occurrence == null ||
        occurrence.status != RecurringOccurrenceStatus.pending) {
      throw const RecurringRepositoryException(
        'This scheduled occurrence is no longer waiting.',
      );
    }
    _occurrences[occurrenceId] = _handledOccurrence(
      occurrence,
      RecurringOccurrenceStatus.skipped,
      now,
    );
    _notify();
  }

  @override
  Future<void> pauseRule(String ruleId, {required DateTime now}) async {
    final RecurringTransactionRule? rule = _rules[ruleId];
    if (rule == null) {
      throw const RecurringRepositoryException(
        'This recurring schedule is no longer available.',
      );
    }
    _rules[ruleId] = rule.copyWith(
      status: RecurringRuleStatus.paused,
      pausedAt: now.toUtc(),
      updatedAt: now.toUtc(),
    );
    _notify();
  }

  @override
  Future<void> resumeRule(
    String ruleId, {
    required DateTime resumeDate,
    required DateTime now,
  }) async {
    final RecurringTransactionRule? rule = _rules[ruleId];
    if (rule == null || rule.status != RecurringRuleStatus.paused) {
      throw const RecurringRepositoryException(
        'This recurring schedule is no longer paused.',
      );
    }
    _rules[ruleId] = rule.copyWith(
      status: RecurringRuleStatus.active,
      pausedAt: null,
      nextDueDateAd: _recurrenceService.nextOccurrenceOnOrAfter(
        rule,
        resumeDate,
      ),
      updatedAt: now.toUtc(),
    );
    _notify();
  }

  @override
  Future<void> deleteRule(String ruleId, {required DateTime now}) async {
    final RecurringTransactionRule? rule = _rules[ruleId];
    if (rule == null) {
      throw const RecurringRepositoryException(
        'This recurring schedule is no longer available.',
      );
    }
    _rules[ruleId] = rule.copyWith(
      status: RecurringRuleStatus.deleted,
      deletedAt: now.toUtc(),
      updatedAt: now.toUtc(),
    );
    for (final MapEntry<String, RecurringTransactionOccurrence> entry
        in List.of(_occurrences.entries)) {
      if (entry.value.ruleId == ruleId &&
          entry.value.status == RecurringOccurrenceStatus.pending) {
        _occurrences[entry.key] = _handledOccurrence(
          entry.value,
          RecurringOccurrenceStatus.skipped,
          now,
        );
      }
    }
    _notify();
  }

  RecurringTransactionOccurrence _handledOccurrence(
    RecurringTransactionOccurrence occurrence,
    RecurringOccurrenceStatus status,
    DateTime now,
  ) {
    return RecurringTransactionOccurrence(
      id: occurrence.id,
      ruleId: occurrence.ruleId,
      dueDateAd: occurrence.dueDateAd,
      status: status,
      type: occurrence.type,
      amount: occurrence.amount,
      category: occurrence.category,
      paymentMethod: occurrence.paymentMethod,
      merchant: occurrence.merchant,
      note: occurrence.note,
      recordedTransactionId: occurrence.recordedTransactionId,
      handledAt: now.toUtc(),
      createdAt: occurrence.createdAt,
    );
  }

  void _notify() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}

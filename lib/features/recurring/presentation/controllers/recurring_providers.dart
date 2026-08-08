import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/recurring/data/repositories/drift_recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/repositories/recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<RecurrenceService> recurrenceServiceProvider =
    Provider<RecurrenceService>((Ref ref) {
      return RecurrenceService(ref.watch(appCalendarServiceProvider));
    });

final Provider<RecurringTransactionRepository>
recurringTransactionRepositoryProvider =
    Provider<RecurringTransactionRepository>((Ref ref) {
      return DriftRecurringTransactionRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(recurrenceServiceProvider),
        ownerScope: ref.watch(activeOwnerScopeProvider),
      );
    });

final StreamProvider<List<RecurringTransactionRule>> recurringRulesProvider =
    StreamProvider<List<RecurringTransactionRule>>((Ref ref) {
      return ref.watch(recurringTransactionRepositoryProvider).watchRules();
    });

final StreamProvider<List<RecurringTransactionOccurrence>>
pendingRecurringOccurrencesProvider =
    StreamProvider<List<RecurringTransactionOccurrence>>((Ref ref) {
      return ref
          .watch(recurringTransactionRepositoryProvider)
          .watchPendingOccurrences();
    });

final ProviderFamily<AsyncValue<RecurringTransactionOccurrence?>, String>
recurringOccurrenceByIdProvider =
    Provider.family<AsyncValue<RecurringTransactionOccurrence?>, String>((
      Ref ref,
      String occurrenceId,
    ) {
      return ref.watch(pendingRecurringOccurrencesProvider).whenData((values) {
        return values.where((value) => value.id == occurrenceId).firstOrNull;
      });
    });

final ProviderFamily<AsyncValue<RecurringTransactionRule?>, String>
recurringRuleByIdProvider =
    Provider.family<AsyncValue<RecurringTransactionRule?>, String>((
      Ref ref,
      String ruleId,
    ) {
      return ref.watch(recurringRulesProvider).whenData((values) {
        return values.where((value) => value.id == ruleId).firstOrNull;
      });
    });

final FutureProvider<void> recurringReconciliationProvider =
    FutureProvider<void>((Ref ref) async {
      final DateTime now = ref.read(appClockProvider)();
      await ref
          .read(recurringTransactionRepositoryProvider)
          .reconcileThrough(today: now, handledAt: now);
    });

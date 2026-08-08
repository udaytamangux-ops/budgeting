import 'package:budgeting_app/core/errors/app_exception.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/recurring/domain/repositories/recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class RecurringActionsState {
  const RecurringActionsState({
    this.busyIds = const <String>{},
    this.errorMessage,
  });

  final Set<String> busyIds;
  final String? errorMessage;

  bool isBusy(String id) => busyIds.contains(id);
}

final AutoDisposeNotifierProvider<
  RecurringActionsController,
  RecurringActionsState
>
recurringActionsControllerProvider =
    NotifierProvider.autoDispose<
      RecurringActionsController,
      RecurringActionsState
    >(RecurringActionsController.new);

final class RecurringActionsController
    extends AutoDisposeNotifier<RecurringActionsState> {
  @override
  RecurringActionsState build() => const RecurringActionsState();

  Future<bool> skip(String occurrenceId) {
    return _run(
      occurrenceId,
      (RecurringTransactionRepository repository, DateTime now) =>
          repository.skipOccurrence(occurrenceId, now: now),
    );
  }

  Future<bool> pause(String ruleId) {
    return _run(
      ruleId,
      (RecurringTransactionRepository repository, DateTime now) =>
          repository.pauseRule(ruleId, now: now),
    );
  }

  Future<bool> resume(String ruleId) {
    return _run(
      ruleId,
      (RecurringTransactionRepository repository, DateTime now) =>
          repository.resumeRule(ruleId, resumeDate: now, now: now),
    );
  }

  Future<bool> delete(String ruleId) {
    return _run(
      ruleId,
      (RecurringTransactionRepository repository, DateTime now) =>
          repository.deleteRule(ruleId, now: now),
    );
  }

  Future<bool> _run(
    String id,
    Future<void> Function(
      RecurringTransactionRepository repository,
      DateTime now,
    )
    operation,
  ) async {
    if (state.isBusy(id)) {
      return false;
    }
    state = RecurringActionsState(busyIds: <String>{...state.busyIds, id});
    try {
      await operation(
        ref.read(recurringTransactionRepositoryProvider),
        ref.read(appClockProvider)().toUtc(),
      );
      state = RecurringActionsState(
        busyIds: <String>{...state.busyIds}..remove(id),
      );
      ref.invalidate(recurringReconciliationProvider);
      return true;
    } on AppException catch (error) {
      state = RecurringActionsState(
        busyIds: <String>{...state.busyIds}..remove(id),
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = RecurringActionsState(
        busyIds: <String>{...state.busyIds}..remove(id),
        errorMessage: 'The recurring schedule could not be updated. Try again.',
      );
      return false;
    }
  }
}

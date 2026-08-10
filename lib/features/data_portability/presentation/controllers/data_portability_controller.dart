import 'dart:typed_data';

import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/data_portability/data/repositories/drift_financial_data_portability_repository.dart';
import 'package:budgeting_app/features/data_portability/data/services/system_document_service.dart';
import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';
import 'package:budgeting_app/features/data_portability/domain/repositories/financial_data_portability_repository.dart';
import 'package:budgeting_app/features/data_portability/domain/services/backup_codec.dart';
import 'package:budgeting_app/features/data_portability/domain/services/backup_exceptions.dart';
import 'package:budgeting_app/features/data_portability/domain/services/data_portability_exception.dart';
import 'package:budgeting_app/features/data_portability/domain/services/local_document_service.dart';
import 'package:budgeting_app/features/data_portability/domain/services/transaction_csv_service.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<FinancialDataPortabilityRepository>
financialDataPortabilityRepositoryProvider =
    Provider<FinancialDataPortabilityRepository>((Ref ref) {
      return DriftFinancialDataPortabilityRepository(
        ref.watch(appDatabaseProvider),
        ownerScope: ref.watch(activeOwnerScopeProvider),
      );
    });

final Provider<LocalDocumentService> localDocumentServiceProvider =
    Provider<LocalDocumentService>((Ref ref) {
      return const SystemDocumentService();
    });

final Provider<BackupCodec> backupCodecProvider = Provider<BackupCodec>((
  Ref ref,
) {
  return BackupCodec(ref.watch(recurrenceServiceProvider));
});

final Provider<TransactionCsvService> transactionCsvServiceProvider =
    Provider<TransactionCsvService>((Ref ref) {
      return TransactionCsvService(ref.watch(appCalendarServiceProvider));
    });

enum DataPortabilityOperation { exportCsv, backup, restore }

final class DataPortabilityState {
  const DataPortabilityState({
    this.operation,
    this.feedback,
    this.pendingBackup,
    this.pendingFileName,
  });

  final DataPortabilityOperation? operation;
  final String? feedback;
  final PortableBackup? pendingBackup;
  final String? pendingFileName;

  bool get isBusy => operation != null;

  DataPortabilityState copyWith({
    DataPortabilityOperation? operation,
    bool clearOperation = false,
    String? feedback,
    bool clearFeedback = false,
    PortableBackup? pendingBackup,
    bool clearPendingBackup = false,
    String? pendingFileName,
  }) => DataPortabilityState(
    operation: clearOperation ? null : operation ?? this.operation,
    feedback: clearFeedback ? null : feedback ?? this.feedback,
    pendingBackup: clearPendingBackup
        ? null
        : pendingBackup ?? this.pendingBackup,
    pendingFileName: clearPendingBackup
        ? null
        : pendingFileName ?? this.pendingFileName,
  );
}

final AutoDisposeNotifierProvider<
  DataPortabilityController,
  DataPortabilityState
>
dataPortabilityControllerProvider =
    NotifierProvider.autoDispose<
      DataPortabilityController,
      DataPortabilityState
    >(DataPortabilityController.new);

final class DataPortabilityController
    extends AutoDisposeNotifier<DataPortabilityState> {
  @override
  DataPortabilityState build() => const DataPortabilityState();

  void clearFeedback() {
    state = state.copyWith(clearFeedback: true);
  }

  void cancelPendingRestore() {
    state = state.copyWith(clearPendingBackup: true, clearFeedback: true);
  }

  Future<bool> exportTransactions() async {
    if (state.isBusy) return false;
    state = state.copyWith(
      operation: DataPortabilityOperation.exportCsv,
      clearFeedback: true,
    );
    try {
      final FinancialDataSnapshot snapshot = await ref
          .read(financialDataPortabilityRepositoryProvider)
          .readCurrentOwnerSnapshot();
      final Uint8List bytes = ref
          .read(transactionCsvServiceProvider)
          .encode(snapshot.transactions);
      final DocumentSaveResult result = await ref
          .read(localDocumentServiceProvider)
          .save(
            suggestedName: _fileName('transactions', 'csv'),
            extension: 'csv',
            bytes: bytes,
          );
      state = state.copyWith(
        clearOperation: true,
        feedback: result == DocumentSaveResult.saved
            ? 'Transaction CSV saved.'
            : 'Export cancelled.',
      );
      return result == DocumentSaveResult.saved;
    } catch (_) {
      state = state.copyWith(
        clearOperation: true,
        feedback: 'Transactions could not be exported. Try again.',
      );
      return false;
    }
  }

  Future<bool> createBackup() async {
    if (state.isBusy) return false;
    state = state.copyWith(
      operation: DataPortabilityOperation.backup,
      clearFeedback: true,
    );
    try {
      final FinancialDataSnapshot snapshot = await ref
          .read(financialDataPortabilityRepositoryProvider)
          .readCurrentOwnerSnapshot();
      final PortableBackup backup = PortableBackup(
        createdAtUtc: ref.read(appClockProvider)().toUtc(),
        sourceDatabaseSchemaVersion: ref
            .read(appDatabaseProvider)
            .schemaVersion,
        snapshot: snapshot,
      );
      final Uint8List bytes = ref.read(backupCodecProvider).encode(backup);
      final DocumentSaveResult result = await ref
          .read(localDocumentServiceProvider)
          .save(
            suggestedName: _fileName('backup', 'json'),
            extension: 'json',
            bytes: bytes,
          );
      state = state.copyWith(
        clearOperation: true,
        feedback: result == DocumentSaveResult.saved
            ? 'Backup saved.'
            : 'Backup cancelled.',
      );
      return result == DocumentSaveResult.saved;
    } catch (_) {
      state = state.copyWith(
        clearOperation: true,
        feedback: 'The backup could not be created. Try again.',
      );
      return false;
    }
  }

  Future<BackupPreview?> selectBackup() async {
    if (state.isBusy) return null;
    state = state.copyWith(
      operation: DataPortabilityOperation.restore,
      clearFeedback: true,
      clearPendingBackup: true,
    );
    try {
      final SelectedDocument? document = await ref
          .read(localDocumentServiceProvider)
          .openJson(maximumBytes: BackupCodec.maximumFileBytes);
      if (document == null) {
        state = state.copyWith(
          clearOperation: true,
          feedback: 'Restore cancelled.',
        );
        return null;
      }
      final PortableBackup backup = ref
          .read(backupCodecProvider)
          .decode(document.bytes);
      final FinancialDataSnapshot currentSnapshot = await ref
          .read(financialDataPortabilityRepositoryProvider)
          .readCurrentOwnerSnapshot();
      state = state.copyWith(
        clearOperation: true,
        pendingBackup: backup,
        pendingFileName: document.name,
      );
      return BackupPreview(
        backup: backup,
        fileName: document.name,
        currentSnapshot: currentSnapshot,
      );
    } on BackupValidationException catch (error) {
      state = state.copyWith(
        clearOperation: true,
        clearPendingBackup: true,
        feedback: error.message,
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        clearOperation: true,
        clearPendingBackup: true,
        feedback: 'The selected backup could not be read. Try again.',
      );
      return null;
    }
  }

  Future<bool> backUpCurrentAndRestore() async {
    final PortableBackup? selectedBackup = state.pendingBackup;
    if (selectedBackup == null || state.isBusy) return false;
    state = state.copyWith(
      operation: DataPortabilityOperation.restore,
      clearFeedback: true,
    );
    DocumentSaveResult recoveryResult;
    try {
      // Re-read immediately before saving so the recovery file represents the
      // current owner state at the destructive-operation boundary.
      final FinancialDataSnapshot currentSnapshot = await ref
          .read(financialDataPortabilityRepositoryProvider)
          .readCurrentOwnerSnapshot();
      final PortableBackup recoveryBackup = PortableBackup(
        createdAtUtc: ref.read(appClockProvider)().toUtc(),
        sourceDatabaseSchemaVersion: ref
            .read(appDatabaseProvider)
            .schemaVersion,
        snapshot: currentSnapshot,
      );
      recoveryResult = await ref
          .read(localDocumentServiceProvider)
          .save(
            suggestedName: _recoveryFileName(),
            extension: 'json',
            bytes: ref.read(backupCodecProvider).encode(recoveryBackup),
          );
    } catch (_) {
      state = state.copyWith(
        clearOperation: true,
        clearPendingBackup: true,
        feedback:
            'Current data could not be backed up, so the restore was not '
            'started.',
      );
      return false;
    }
    if (recoveryResult == DocumentSaveResult.cancelled) {
      state = state.copyWith(
        clearOperation: true,
        clearPendingBackup: true,
        feedback: 'Restore cancelled. Current records were not changed.',
      );
      return false;
    }

    try {
      await ref
          .read(financialDataPortabilityRepositoryProvider)
          .replaceCurrentOwnerSnapshot(selectedBackup.snapshot);
      try {
        ref.invalidate(recurringReconciliationProvider);
        await ref.read(recurringReconciliationProvider.future);
      } catch (_) {
        state = state.copyWith(
          clearOperation: true,
          clearPendingBackup: true,
          feedback:
              'Backup restored. Your previous data was saved as a recovery '
              'backup. Scheduled items could not be refreshed right now.',
        );
        return true;
      }
      state = state.copyWith(
        clearOperation: true,
        clearPendingBackup: true,
        feedback:
            'Backup restored. Your previous data was saved as a recovery '
            'backup.',
      );
      return true;
    } on DataPortabilityException catch (error) {
      state = state.copyWith(
        clearOperation: true,
        clearPendingBackup: true,
        feedback: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        clearOperation: true,
        clearPendingBackup: true,
        feedback:
            'The backup could not be restored. Your current records were '
            'not changed.',
      );
      return false;
    }
  }

  String _fileName(String kind, String extension) {
    final DateTime now = ref.read(appClockProvider)().toLocal();
    final String day =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return 'budgeting-$kind-$day.$extension';
  }

  String _recoveryFileName() {
    final DateTime now = ref.read(appClockProvider)().toLocal();
    final String day =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final String time =
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
    return 'budgeting-recovery-before-restore-$day-$time.json';
  }
}

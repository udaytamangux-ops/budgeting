import 'dart:typed_data';

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/database/app_database.dart'
    hide RecurringTransactionOccurrence, RecurringTransactionRule;
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';
import 'package:budgeting_app/features/data_portability/domain/repositories/financial_data_portability_repository.dart';
import 'package:budgeting_app/features/data_portability/domain/services/backup_codec.dart';
import 'package:budgeting_app/features/data_portability/domain/services/local_document_service.dart';
import 'package:budgeting_app/features/data_portability/presentation/controllers/data_portability_controller.dart';
import 'package:budgeting_app/features/profile/presentation/screens/privacy_and_data_screen.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const FinancialDataSnapshot emptySnapshot = FinancialDataSnapshot(
    transactions: <FinancialTransaction>[],
    recurringRules: <RecurringTransactionRule>[],
    recurringOccurrences: <RecurringTransactionOccurrence>[],
  );
  final FinancialDataSnapshot currentSnapshot = FinancialDataSnapshot(
    transactions: <FinancialTransaction>[
      buildTestTransaction(id: 'current-transaction'),
    ],
    recurringRules: const <RecurringTransactionRule>[],
    recurringOccurrences: const <RecurringTransactionOccurrence>[],
  );

  testWidgets('shows three accessible data actions and backup warning', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(emptySnapshot);
    final _FakeDocuments documents = _FakeDocuments();
    await _pump(tester, repository: repository, documents: documents);

    expect(find.text('Export transactions'), findsOneWidget);
    expect(find.text('Backup data'), findsOneWidget);
    expect(find.text('Restore backup'), findsOneWidget);
    expect(find.text('Advanced data tools'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Export transactions as a CSV spreadsheet'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Store them somewhere you trust'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('backup_data')));
    await tester.pumpAndSettle();
    expect(find.text('Create backup?'), findsOneWidget);
    expect(find.textContaining('not encrypted'), findsOneWidget);
  });

  testWidgets('picker cancellation is neutral and does not restore', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(emptySnapshot);
    final _FakeDocuments documents = _FakeDocuments();
    await _pump(tester, repository: repository, documents: documents);

    await tester.tap(find.byKey(const ValueKey<String>('restore_backup')));
    await tester.pumpAndSettle();

    expect(repository.replaceCalls, 0);
    expect(find.text('Restore cancelled.'), findsOneWidget);
  });

  testWidgets(
    'export and backup save cancellation are not reported as errors',
    (WidgetTester tester) async {
      final _FakeRepository repository = _FakeRepository(emptySnapshot);
      final _FakeDocuments documents = _FakeDocuments();
      await _pump(tester, repository: repository, documents: documents);

      await tester.tap(
        find.byKey(const ValueKey<String>('export_transactions')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Export cancelled.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('backup_data')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose save location'));
      await tester.pumpAndSettle();
      expect(find.text('Backup cancelled.'), findsOneWidget);
      expect(documents.saveCalls, 2);
    },
  );

  testWidgets('invalid backup never reaches repository replacement', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(emptySnapshot);
    final _FakeDocuments documents = _FakeDocuments(
      selected: SelectedDocument(
        name: 'invalid.json',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
      ),
    );
    await _pump(tester, repository: repository, documents: documents);

    await tester.tap(find.byKey(const ValueKey<String>('restore_backup')));
    await tester.pumpAndSettle();

    expect(repository.replaceCalls, 0);
    expect(
      find.text('This does not appear to be a valid backup file.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'valid backup compares current data and cancel leaves it intact',
    (WidgetTester tester) async {
      final _FakeRepository repository = _FakeRepository(currentSnapshot);
      final BackupCodec codec = BackupCodec(
        RecurrenceService(BikramSambatCalendarService()),
      );
      final _FakeDocuments documents = _FakeDocuments(
        selected: SelectedDocument(
          name: 'a-very-long-financial-backup-file-name.json',
          bytes: codec.encode(
            PortableBackup(
              createdAtUtc: DateTime.utc(2026, 8, 8, 12),
              sourceDatabaseSchemaVersion: 3,
              snapshot: emptySnapshot,
            ),
          ),
        ),
      );
      await _pump(tester, repository: repository, documents: documents);

      await tester.tap(find.byKey(const ValueKey<String>('restore_backup')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('restore_backup_preview')),
        findsOneWidget,
      );
      expect(find.text('Restore backup from 8 August 2026?'), findsOneWidget);
      expect(find.text('Selected backup'), findsOneWidget);
      expect(find.text('Current app'), findsOneWidget);
      expect(find.text('0 transactions'), findsOneWidget);
      expect(find.text('1 transactions'), findsOneWidget);
      expect(find.text('0 recurring schedules'), findsNWidgets(2));
      expect(find.text('0 scheduled-history items'), findsNWidgets(2));
      expect(
        find.textContaining('activity that may not exist'),
        findsOneWidget,
      );
      expect(find.textContaining('calendar preference'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.replaceCalls, 0);
      expect(repository.snapshot.transactions.single.id, 'current-transaction');
    },
  );

  testWidgets(
    'Back up and restore saves current v1 backup before replacing data',
    (WidgetTester tester) async {
      final _FakeRepository repository = _FakeRepository(currentSnapshot);
      final BackupCodec codec = BackupCodec(
        RecurrenceService(BikramSambatCalendarService()),
      );
      final _FakeDocuments documents = _FakeDocuments(
        selected: _backupDocument(codec, emptySnapshot),
        saveResult: DocumentSaveResult.saved,
      );
      await _pump(tester, repository: repository, documents: documents);

      await tester.tap(find.byKey(const ValueKey<String>('restore_backup')));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(
          'Back up current financial data and restore backup from '
          '8 August 2026',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Back up & restore'));
      await tester.pumpAndSettle();

      expect(documents.savedDocuments, hasLength(1));
      expect(
        documents.savedDocuments.single.suggestedName,
        'budgeting-recovery-before-restore-2026-08-10-2045.json',
      );
      final PortableBackup recovery = codec.decode(
        documents.savedDocuments.single.bytes,
      );
      expect(BackupCodec.backupFormatVersion, 1);
      expect(recovery.snapshot.transactions.single.id, 'current-transaction');
      expect(repository.replaceCalls, 1);
      expect(repository.snapshot.transactions, isEmpty);
      expect(find.textContaining('saved as a recovery backup'), findsOneWidget);
    },
  );

  testWidgets('recovery save cancellation prevents restore mutation', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(currentSnapshot);
    final BackupCodec codec = BackupCodec(
      RecurrenceService(BikramSambatCalendarService()),
    );
    final _FakeDocuments documents = _FakeDocuments(
      selected: _backupDocument(codec, emptySnapshot),
    );
    await _pump(tester, repository: repository, documents: documents);

    await _openPreviewAndConfirm(tester);

    expect(documents.saveCalls, 1);
    expect(repository.replaceCalls, 0);
    expect(repository.snapshot.transactions.single.id, 'current-transaction');
    expect(
      find.text('Restore cancelled. Current records were not changed.'),
      findsOneWidget,
    );
  });

  testWidgets('recovery save failure prevents restore mutation', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(currentSnapshot);
    final BackupCodec codec = BackupCodec(
      RecurrenceService(BikramSambatCalendarService()),
    );
    final _FakeDocuments documents = _FakeDocuments(
      selected: _backupDocument(codec, emptySnapshot),
      saveError: StateError('save failed'),
    );
    await _pump(tester, repository: repository, documents: documents);

    await _openPreviewAndConfirm(tester);

    expect(repository.replaceCalls, 0);
    expect(repository.snapshot.transactions.single.id, 'current-transaction');
    expect(
      find.text(
        'Current data could not be backed up, so the restore was not started.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('restore failure occurs only after recovery save', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(
      currentSnapshot,
      replaceError: StateError('restore failed'),
    );
    final BackupCodec codec = BackupCodec(
      RecurrenceService(BikramSambatCalendarService()),
    );
    final _FakeDocuments documents = _FakeDocuments(
      selected: _backupDocument(codec, emptySnapshot),
      saveResult: DocumentSaveResult.saved,
    );
    await _pump(tester, repository: repository, documents: documents);

    await _openPreviewAndConfirm(tester);

    expect(documents.savedDocuments, hasLength(1));
    expect(repository.replaceCalls, 1);
    expect(repository.snapshot.transactions.single.id, 'current-transaction');
    expect(find.textContaining('could not be restored'), findsOneWidget);
  });

  for (final double width in <double>[320, 768]) {
    testWidgets('data actions fit ${width.toInt()}px at 2x text in dark mode', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1200);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(
        tester,
        repository: _FakeRepository(emptySnapshot),
        documents: _FakeDocuments(),
        themeMode: ThemeMode.dark,
      );
      expect(find.text('Export transactions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final double width in <double>[320, 768]) {
    for (final ThemeMode themeMode in <ThemeMode>[
      ThemeMode.light,
      ThemeMode.dark,
    ]) {
      testWidgets('restore preview is accessible at ${width.toInt()}px and 2x '
          '$themeMode', (WidgetTester tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 1200);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final BackupCodec codec = BackupCodec(
          RecurrenceService(BikramSambatCalendarService()),
        );
        await _pump(
          tester,
          repository: _FakeRepository(currentSnapshot),
          documents: _FakeDocuments(
            selected: _backupDocument(codec, emptySnapshot),
          ),
          themeMode: themeMode,
        );

        await tester.dragUntilVisible(
          find.byKey(const ValueKey<String>('restore_backup')),
          find.byKey(const ValueKey<String>('privacy_and_data_content')),
          const Offset(0, -240),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey<String>('restore_backup')));
        await tester.pumpAndSettle();

        expect(find.text('Back up & restore'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

SelectedDocument _backupDocument(
  BackupCodec codec,
  FinancialDataSnapshot snapshot,
) => SelectedDocument(
  name: 'historical-backup.json',
  bytes: codec.encode(
    PortableBackup(
      createdAtUtc: DateTime.utc(2026, 8, 8, 12),
      sourceDatabaseSchemaVersion: 3,
      snapshot: snapshot,
    ),
  ),
);

Future<void> _openPreviewAndConfirm(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey<String>('restore_backup')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Back up & restore'));
  await tester.pumpAndSettle();
}

Future<void> _pump(
  WidgetTester tester, {
  required _FakeRepository repository,
  required _FakeDocuments documents,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final AppDatabase database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(database),
        financialDataPortabilityRepositoryProvider.overrideWithValue(
          repository,
        ),
        localDocumentServiceProvider.overrideWithValue(documents),
        primaryCalendarProvider.overrideWith(
          (Ref ref) =>
              Stream<AppCalendarSystem>.value(AppCalendarSystem.gregorianAd),
        ),
        recurringReconciliationProvider.overrideWith((Ref ref) async {}),
        appClockProvider.overrideWithValue(() => DateTime(2026, 8, 10, 20, 45)),
      ],
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: const PrivacyAndDataScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final class _FakeRepository implements FinancialDataPortabilityRepository {
  _FakeRepository(this.snapshot, {this.replaceError});

  FinancialDataSnapshot snapshot;
  final Object? replaceError;
  int replaceCalls = 0;

  @override
  Future<FinancialDataSnapshot> readCurrentOwnerSnapshot() async => snapshot;

  @override
  Future<void> replaceCurrentOwnerSnapshot(FinancialDataSnapshot value) async {
    replaceCalls += 1;
    if (replaceError != null) throw replaceError!;
    snapshot = value;
  }
}

final class _FakeDocuments implements LocalDocumentService {
  _FakeDocuments({
    this.selected,
    this.saveResult = DocumentSaveResult.cancelled,
    this.saveError,
  });

  final SelectedDocument? selected;
  final DocumentSaveResult saveResult;
  final Object? saveError;
  int saveCalls = 0;
  final List<_SavedDocument> savedDocuments = <_SavedDocument>[];

  @override
  Future<SelectedDocument?> openJson({required int maximumBytes}) async =>
      selected;

  @override
  Future<DocumentSaveResult> save({
    required String suggestedName,
    required String extension,
    required Uint8List bytes,
  }) async {
    saveCalls += 1;
    if (saveError != null) throw saveError!;
    if (saveResult == DocumentSaveResult.saved) {
      savedDocuments.add(
        _SavedDocument(suggestedName: suggestedName, bytes: bytes),
      );
    }
    return saveResult;
  }
}

final class _SavedDocument {
  const _SavedDocument({required this.suggestedName, required this.bytes});

  final String suggestedName;
  final Uint8List bytes;
}

import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/onboarding/data/repositories/drift_onboarding_preference_repository.dart';
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftOnboardingPreferenceRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftOnboardingPreferenceRepository(database);
  });

  tearDown(() => database.close());

  test('genuinely fresh state initializes incomplete only once', () async {
    await repository.initializeForCurrentInstallation();
    expect(await repository.isCompleted(), isFalse);

    await database.writePreference('access_mode', 'guest');
    await repository.initializeForCurrentInstallation();
    expect(await repository.isCompleted(), isFalse);
  });

  test('established preference state skips new onboarding', () async {
    await database.writePreference('access_mode', 'guest');
    await repository.initializeForCurrentInstallation();

    expect(await repository.isCompleted(), isTrue);
  });

  test('existing financial data is also an established signal', () async {
    final DateTime now = DateTime.utc(2026, 8, 17, 12);
    await database.insertStoredTransaction(
      TransactionDatabaseMapper.toCompanion(
        FinancialTransaction(
          id: 'existing',
          type: TransactionType.expense,
          amount: const Money(minorUnits: 10000),
          category: TransactionCategory.food,
          paymentMethod: PaymentMethod.cash,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
        ),
        ownerScope: 'guest',
      ),
    );

    await repository.initializeForCurrentInstallation();
    expect(await repository.isCompleted(), isTrue);
  });

  test('completion persists and updates the watch stream', () async {
    await repository.initializeForCurrentInstallation();
    final Future<bool> next = repository.watchCompleted().firstWhere(
      (bool value) => value,
    );

    await repository.complete();

    expect(await next, isTrue);
    expect(await repository.isCompleted(), isTrue);
  });
}

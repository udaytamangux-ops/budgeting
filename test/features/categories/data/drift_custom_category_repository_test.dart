import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/database/app_database.dart'
    hide
        CustomCategory,
        MoneyPlanCategoryMapping,
        MoneyPlanPeriod,
        MoneyPlanPreference;
import 'package:budgeting_app/features/categories/data/repositories/drift_custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/repositories/custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/domain/services/category_icon_keys.dart';
import 'package:budgeting_app/features/money_plan/data/repositories/drift_money_plan_repository.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late int idSequence;
  late DriftCustomCategoryRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    idSequence = 0;
    repository = DriftCustomCategoryRepository(
      database,
      ownerScope: 'owner-a',
      now: () => DateTime.utc(2026, 8, 17, 12),
      createId: () => 'custom:test-${idSequence++}',
    );
  });

  tearDown(() => database.close());

  test('creates owner-scoped expense and income categories', () async {
    final CustomCategory expense = await repository.create(
      type: TransactionType.expense,
      name: '  Fitness  ',
      iconKey: CategoryIconKeys.fallback,
    );
    final CustomCategory income = await repository.create(
      type: TransactionType.income,
      name: 'Fitness',
      iconKey: 'work',
    );

    expect(expense.name, 'Fitness');
    expect(expense.normalizedName, 'fitness');
    expect(expense.reference.isCustom, isTrue);
    expect(income.type, TransactionType.income);
    expect(await repository.getCategories(), hasLength(2));

    final otherOwner = DriftCustomCategoryRepository(
      database,
      ownerScope: 'owner-b',
    );
    expect(await otherOwner.getCategories(), isEmpty);
  });

  test(
    'rejects normalized duplicates and system category collisions',
    () async {
      await repository.create(
        type: TransactionType.expense,
        name: 'Gym membership',
        iconKey: 'health',
      );

      expect(
        () => repository.create(
          type: TransactionType.expense,
          name: ' gym   MEMBERSHIP ',
          iconKey: 'health',
        ),
        throwsA(isA<CustomCategoryException>()),
      );
      expect(
        () => repository.create(
          type: TransactionType.expense,
          name: ' FOOD ',
          iconKey: 'food',
        ),
        throwsA(isA<CustomCategoryException>()),
      );
    },
  );

  test(
    'rename changes resolved history label without rewriting transaction',
    () async {
      final CustomCategory created = await repository.create(
        type: TransactionType.expense,
        name: 'Gym',
        iconKey: 'health',
      );
      final transactions = DriftTransactionRepository(
        database,
        ownerScope: 'owner-a',
      );
      await transactions.createTransaction(
        FinancialTransaction(
          id: 'historical',
          type: TransactionType.expense,
          amount: const Money(minorUnits: 250000),
          category: created.reference,
          paymentMethod: PaymentMethod.cash,
          occurredAt: DateTime.utc(2026, 8, 10, 12),
          createdAt: DateTime.utc(2026, 8, 10, 12),
          updatedAt: DateTime.utc(2026, 8, 10, 12),
        ),
      );

      final CustomCategory renamed = await repository.update(
        id: created.id,
        name: 'Fitness',
        iconKey: 'health',
      );
      final FinancialTransaction restored = (await transactions
          .getTransactionById('historical'))!;

      expect(restored.category.name, created.id);
      expect(
        CategoryCatalog(<CustomCategory>[
          renamed,
        ]).resolve(restored.category).label,
        'Fitness',
      );
      expect(await repository.isUsed(created.id), isTrue);
      expect(await repository.getUsedIds(), contains(created.id));
      expect(
        () => repository.deleteUnused(created.id),
        throwsA(isA<CustomCategoryException>()),
      );
    },
  );

  test('archive, restore and delete-unused lifecycle is explicit', () async {
    final CustomCategory created = await repository.create(
      type: TransactionType.expense,
      name: 'Subscriptions',
      iconKey: 'subscriptions',
    );
    await repository.archive(created.id);
    CustomCategory current = (await repository.getById(created.id))!;
    expect(current.isArchived, isTrue);
    expect(
      CategoryCatalog(<CustomCategory>[current])
          .availableFor(TransactionType.expense)
          .any(
            (CategoryDefinition item) => item.reference == created.reference,
          ),
      isFalse,
    );

    await repository.restore(created.id);
    current = (await repository.getById(created.id))!;
    expect(current.isArchived, isFalse);
    await repository.archive(created.id);
    await repository.deleteUnused(created.id);
    expect(await repository.getById(created.id), isNull);
  });

  test('deleting an unused category cleans its Money Plan mappings', () async {
    final CustomCategory created = await repository.create(
      type: TransactionType.expense,
      name: 'Occasional costs',
      iconKey: 'other',
    );
    final planRepository = DriftMoneyPlanRepository(
      database,
      ownerScope: 'owner-a',
      now: () => DateTime.utc(2026, 8, 17, 12),
      createId: () => 'money-plan-test-id',
    );
    final period = BikramSambatCalendarService().periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );
    final MoneyPlanPeriod plan = await planRepository.createOrUpdateCurrentPlan(
      period: period,
      ratios: MoneyPlanRatios.defaultPlan,
      categoryGroups: <String, MoneyPlanGroup>{
        created.id: MoneyPlanGroup.wants,
      },
    );
    expect(await planRepository.getMappings(plan.id), hasLength(1));

    await repository.archive(created.id);
    await repository.deleteUnused(created.id);

    expect(await repository.getById(created.id), isNull);
    expect(await planRepository.getMappings(plan.id), isEmpty);
  });

  test(
    'enforces ten active custom categories independently per type',
    () async {
      for (
        int index = 0;
        index < CategoryNameRules.maximumActivePerType;
        index++
      ) {
        await repository.create(
          type: TransactionType.expense,
          name: 'Custom $index',
          iconKey: 'other',
        );
      }

      expect(
        () => repository.create(
          type: TransactionType.expense,
          name: 'Custom extra',
          iconKey: 'other',
        ),
        throwsA(isA<CustomCategoryException>()),
      );
      expect(
        await repository.create(
          type: TransactionType.income,
          name: 'Custom extra',
          iconKey: 'other',
        ),
        isA<CustomCategory>(),
      );
    },
  );
}

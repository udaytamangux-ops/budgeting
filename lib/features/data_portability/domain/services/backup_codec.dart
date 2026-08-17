import 'dart:convert';
import 'dart:typed_data';

import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/domain/services/category_icon_keys.dart';
import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';
import 'package:budgeting_app/features/data_portability/domain/services/backup_exceptions.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';

final class BackupCodec {
  const BackupCodec(this._recurrenceService);

  static const int backupFormatVersion = 4;
  static const int maximumFileBytes = 10 * 1024 * 1024;
  static const int maximumRecordsPerCollection = 100000;
  static const String currency = 'NPR';

  final RecurrenceService _recurrenceService;

  Uint8List encode(PortableBackup backup) {
    final Map<String, Object?> document = <String, Object?>{
      'backupFormatVersion': backupFormatVersion,
      'createdAtUtc': _timestamp(backup.createdAtUtc),
      'currency': currency,
      'source': <String, Object?>{
        'databaseSchemaVersion': backup.sourceDatabaseSchemaVersion,
      },
      'records': <String, Object?>{
        'moneyPlanPreference': backup.snapshot.moneyPlanPreference == null
            ? null
            : _moneyPlanPreferenceToJson(backup.snapshot.moneyPlanPreference!),
        'moneyPlanPeriods': backup.snapshot.moneyPlanPeriods
            .map(_moneyPlanPeriodToJson)
            .toList(growable: false),
        'moneyPlanCategoryMappings': backup.snapshot.moneyPlanCategoryMappings
            .map(_moneyPlanMappingToJson)
            .toList(growable: false),
        'customCategories': backup.snapshot.customCategories
            .map(_customCategoryToJson)
            .toList(growable: false),
        'transactions': backup.snapshot.transactions
            .map(_transactionToJson)
            .toList(growable: false),
        'transfers': backup.snapshot.transfers
            .map(_transferToJson)
            .toList(growable: false),
        'recurringRules': backup.snapshot.recurringRules
            .map(_ruleToJson)
            .toList(growable: false),
        'recurringOccurrences': backup.snapshot.recurringOccurrences
            .map(_occurrenceToJson)
            .toList(growable: false),
      },
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(document)));
  }

  PortableBackup decode(Uint8List bytes) {
    if (bytes.length > maximumFileBytes) {
      throw const BackupValidationException(
        BackupValidationIssue.oversized,
        'This backup file is larger than the supported 10 MB limit.',
      );
    }
    if (bytes.isEmpty) {
      throw _malformed();
    }

    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    } on FormatException {
      throw _malformed();
    }
    final Map<String, Object?> root = _object(decoded);
    final int version = _integer(root, 'backupFormatVersion');
    if (version < 1 || version > backupFormatVersion) {
      throw const BackupValidationException(
        BackupValidationIssue.unsupportedVersion,
        'This backup was created by a newer or unsupported app version. '
        'Update the app or use a compatible backup.',
      );
    }
    if (_string(root, 'currency') != currency) {
      throw _malformed();
    }
    final Map<String, Object?> source = _object(root['source']);
    final int schemaVersion = _integer(source, 'databaseSchemaVersion');
    if (schemaVersion < 1) {
      throw _malformed();
    }
    final Map<String, Object?> records = _object(root['records']);
    final List<Object?> customCategoryValues = version >= 3
        ? _array(records, 'customCategories')
        : const <Object?>[];
    final List<Object?> transactionValues = _array(records, 'transactions');
    final List<Object?> ruleValues = _array(records, 'recurringRules');
    final List<Object?> occurrenceValues = _array(
      records,
      'recurringOccurrences',
    );
    final List<Object?> transferValues = version >= 2
        ? _array(records, 'transfers')
        : const <Object?>[];
    final Object? moneyPlanPreferenceValue = version >= 4
        ? _requiredValue(records, 'moneyPlanPreference')
        : null;
    final List<Object?> moneyPlanPeriodValues = version >= 4
        ? _array(records, 'moneyPlanPeriods')
        : const <Object?>[];
    final List<Object?> moneyPlanMappingValues = version >= 4
        ? _array(records, 'moneyPlanCategoryMappings')
        : const <Object?>[];
    _checkCollectionSize(transactionValues);
    _checkCollectionSize(customCategoryValues);
    _checkCollectionSize(ruleValues);
    _checkCollectionSize(occurrenceValues);
    _checkCollectionSize(transferValues);
    _checkCollectionSize(moneyPlanPeriodValues);
    _checkCollectionSize(moneyPlanMappingValues);

    final List<CustomCategory> customCategories = customCategoryValues
        .map((Object? value) => _customCategoryFromJson(_object(value)))
        .toList(growable: false);
    _validateCustomCategories(customCategories);
    final Map<String, CustomCategory> customById = <String, CustomCategory>{
      for (final CustomCategory value in customCategories) value.id: value,
    };
    final List<FinancialTransaction> transactions = transactionValues
        .map(
          (Object? value) => _transactionFromJson(_object(value), customById),
        )
        .toList(growable: false);
    final List<RecurringTransactionRule> rules = ruleValues
        .map((Object? value) => _ruleFromJson(_object(value), customById))
        .toList(growable: false);
    final List<RecurringTransactionOccurrence> occurrences = occurrenceValues
        .map((Object? value) => _occurrenceFromJson(_object(value), customById))
        .toList(growable: false);
    final List<FinancialTransfer> transfers = transferValues
        .map((Object? value) => _transferFromJson(_object(value), customById))
        .toList(growable: false);
    _validateRelationships(transactions, rules, occurrences, transfers);
    final MoneyPlanPreference? moneyPlanPreference =
        moneyPlanPreferenceValue == null
        ? null
        : _moneyPlanPreferenceFromJson(_object(moneyPlanPreferenceValue));
    final List<MoneyPlanPeriod> moneyPlanPeriods = moneyPlanPeriodValues
        .map((Object? value) => _moneyPlanPeriodFromJson(_object(value)))
        .toList(growable: false);
    final List<MoneyPlanCategoryMapping> moneyPlanMappings =
        moneyPlanMappingValues
            .map((Object? value) => _moneyPlanMappingFromJson(_object(value)))
            .toList(growable: false);
    _validateMoneyPlan(
      preference: moneyPlanPreference,
      periods: moneyPlanPeriods,
      mappings: moneyPlanMappings,
      customById: customById,
    );

    return PortableBackup(
      createdAtUtc: _parseTimestamp(_string(root, 'createdAtUtc')),
      sourceDatabaseSchemaVersion: schemaVersion,
      snapshot: FinancialDataSnapshot(
        transactions: List<FinancialTransaction>.unmodifiable(transactions),
        recurringRules: List<RecurringTransactionRule>.unmodifiable(rules),
        recurringOccurrences: List<RecurringTransactionOccurrence>.unmodifiable(
          occurrences,
        ),
        transfers: List<FinancialTransfer>.unmodifiable(transfers),
        customCategories: List<CustomCategory>.unmodifiable(customCategories),
        moneyPlanPreference: moneyPlanPreference,
        moneyPlanPeriods: List<MoneyPlanPeriod>.unmodifiable(moneyPlanPeriods),
        moneyPlanCategoryMappings: List<MoneyPlanCategoryMapping>.unmodifiable(
          moneyPlanMappings,
        ),
      ),
    );
  }

  Map<String, Object?> _moneyPlanPreferenceToJson(MoneyPlanPreference value) =>
      <String, Object?>{
        'isEnabled': value.isEnabled,
        'createdAtUtc': _timestamp(value.createdAt),
        'updatedAtUtc': _timestamp(value.updatedAt),
      };

  MoneyPlanPreference _moneyPlanPreferenceFromJson(Map<String, Object?> json) {
    final DateTime createdAt = _parseTimestamp(_string(json, 'createdAtUtc'));
    final DateTime updatedAt = _parseTimestamp(_string(json, 'updatedAtUtc'));
    if (updatedAt.isBefore(createdAt)) throw _malformed();
    return MoneyPlanPreference(
      isEnabled: _boolean(json, 'isEnabled'),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> _moneyPlanPeriodToJson(MoneyPlanPeriod value) =>
      <String, Object?>{
        'id': value.id,
        'periodStartAd': _date(value.period.startAdInclusive),
        'periodEndExclusiveAd': _date(value.period.endAdExclusive),
        'calendarSystem': value.period.calendarSystem.storageValue,
        'calendarYear': value.period.year,
        'calendarMonth': value.period.month,
        'needsPercent': value.ratios.needsPercent,
        'wantsPercent': value.ratios.wantsPercent,
        'savingsPercent': value.ratios.savingsPercent,
        'createdAtUtc': _timestamp(value.createdAt),
        'updatedAtUtc': _timestamp(value.updatedAt),
      };

  MoneyPlanPeriod _moneyPlanPeriodFromJson(Map<String, Object?> json) {
    final AppCalendarSystem? calendar = _calendar(
      _string(json, 'calendarSystem'),
    );
    if (calendar == null) throw _malformed();
    final int year = _integer(json, 'calendarYear');
    final int month = _integer(json, 'calendarMonth');
    late final MoneyPlanRatios ratios;
    try {
      ratios = MoneyPlanRatios(
        needsPercent: _integer(json, 'needsPercent'),
        wantsPercent: _integer(json, 'wantsPercent'),
        savingsPercent: _integer(json, 'savingsPercent'),
      );
    } on ArgumentError {
      throw _malformed();
    }
    late final CalendarPeriod expected;
    try {
      expected = _calendarService.periodFor(
        calendarSystem: calendar,
        year: year,
        month: month,
      );
    } on Object {
      throw _malformed();
    }
    final DateTime start = _parseDate(_string(json, 'periodStartAd'));
    final DateTime end = _parseDate(_string(json, 'periodEndExclusiveAd'));
    if (_date(start) != _date(expected.startAdInclusive) ||
        _date(end) != _date(expected.endAdExclusive)) {
      throw _malformed();
    }
    final DateTime createdAt = _parseTimestamp(_string(json, 'createdAtUtc'));
    final DateTime updatedAt = _parseTimestamp(_string(json, 'updatedAtUtc'));
    if (updatedAt.isBefore(createdAt)) throw _malformed();
    return MoneyPlanPeriod(
      id: _nonEmptyString(json, 'id'),
      period: expected,
      ratios: ratios,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> _moneyPlanMappingToJson(
    MoneyPlanCategoryMapping value,
  ) => <String, Object?>{
    'id': value.id,
    'periodId': value.periodId,
    'categoryId': value.categoryId,
    'group': value.group.storageValue,
    'createdAtUtc': _timestamp(value.createdAt),
    'updatedAtUtc': _timestamp(value.updatedAt),
  };

  MoneyPlanCategoryMapping _moneyPlanMappingFromJson(
    Map<String, Object?> json,
  ) {
    final MoneyPlanGroup? group = MoneyPlanGroupMetadata.tryParse(
      _string(json, 'group'),
    );
    if (group == null || group == MoneyPlanGroup.unassigned) {
      throw _malformed();
    }
    final DateTime createdAt = _parseTimestamp(_string(json, 'createdAtUtc'));
    final DateTime updatedAt = _parseTimestamp(_string(json, 'updatedAtUtc'));
    if (updatedAt.isBefore(createdAt)) throw _malformed();
    return MoneyPlanCategoryMapping(
      id: _nonEmptyString(json, 'id'),
      periodId: _nonEmptyString(json, 'periodId'),
      categoryId: _nonEmptyString(json, 'categoryId'),
      group: group,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  void _validateMoneyPlan({
    required MoneyPlanPreference? preference,
    required List<MoneyPlanPeriod> periods,
    required List<MoneyPlanCategoryMapping> mappings,
    required Map<String, CustomCategory> customById,
  }) {
    if (preference == null && (periods.isNotEmpty || mappings.isNotEmpty)) {
      throw _malformed();
    }
    _uniqueIds(periods.map((MoneyPlanPeriod value) => value.id));
    _uniqueIds(mappings.map((MoneyPlanCategoryMapping value) => value.id));
    final Set<String> periodIds = periods
        .map((MoneyPlanPeriod value) => value.id)
        .toSet();
    final Set<String> identities = <String>{};
    for (final MoneyPlanPeriod period in periods) {
      if (!identities.add(period.period.identifier)) throw _malformed();
    }
    final Set<String> mappingKeys = <String>{};
    for (final MoneyPlanCategoryMapping mapping in mappings) {
      if (!periodIds.contains(mapping.periodId) ||
          !mappingKeys.add('${mapping.periodId}|${mapping.categoryId}')) {
        throw _malformed();
      }
      final TransactionCategory? system =
          TransactionCategory.systemFromIdentifier(mapping.categoryId);
      final CustomCategory? custom = customById[mapping.categoryId];
      if ((system == null || !system.supports(TransactionType.expense)) &&
          (custom == null || custom.type != TransactionType.expense)) {
        throw _malformed();
      }
    }
  }

  static final BikramSambatCalendarService _calendarService =
      BikramSambatCalendarService();

  AppCalendarSystem? _calendar(String value) {
    for (final AppCalendarSystem calendar in AppCalendarSystem.values) {
      if (calendar.storageValue == value) return calendar;
    }
    return null;
  }

  Map<String, Object?> _customCategoryToJson(CustomCategory value) =>
      <String, Object?>{
        'id': value.id,
        'type': TransactionDatabaseMapper.typeToKey(value.type),
        'name': value.name,
        'normalizedName': value.normalizedName,
        'iconKey': value.iconKey,
        'isArchived': value.isArchived,
        'createdAtUtc': _timestamp(value.createdAt),
        'updatedAtUtc': _timestamp(value.updatedAt),
      };

  CustomCategory _customCategoryFromJson(Map<String, Object?> json) {
    final String id = _nonEmptyString(json, 'id');
    final TransactionType type = _type(_string(json, 'type'));
    final String name = CategoryNameRules.clean(_string(json, 'name'));
    final String normalized = _string(json, 'normalizedName');
    final String iconKey = _string(json, 'iconKey');
    final DateTime createdAt = _parseTimestamp(_string(json, 'createdAtUtc'));
    final DateTime updatedAt = _parseTimestamp(_string(json, 'updatedAtUtc'));
    if (!TransactionCategory.isCustomIdentifier(id) ||
        name.isEmpty ||
        name.length > CategoryNameRules.maximumLength ||
        normalized != CategoryNameRules.normalize(name) ||
        !CategoryIconKeys.isSupported(iconKey) ||
        updatedAt.isBefore(createdAt)) {
      throw _malformed();
    }
    return CustomCategory(
      id: id,
      type: type,
      name: name,
      normalizedName: normalized,
      iconKey: iconKey,
      isArchived: _boolean(json, 'isArchived'),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  void _validateCustomCategories(List<CustomCategory> values) {
    _uniqueIds(values.map((CustomCategory value) => value.id));
    final Set<String> names = <String>{};
    final Map<TransactionType, int> active = <TransactionType, int>{};
    for (final CustomCategory value in values) {
      if (!names.add('${value.type.name}|${value.normalizedName}')) {
        throw _malformed();
      }
      final bool systemCollision = TransactionCategory.values
          .where(
            (TransactionCategory category) => category.supports(value.type),
          )
          .any(
            (TransactionCategory category) =>
                CategoryNameRules.normalize(category.systemLabel ?? '') ==
                value.normalizedName,
          );
      if (systemCollision) throw _malformed();
      if (!value.isArchived) {
        active[value.type] = (active[value.type] ?? 0) + 1;
        if (active[value.type]! > CategoryNameRules.maximumActivePerType) {
          throw _malformed();
        }
      }
    }
  }

  Map<String, Object?> _transactionToJson(FinancialTransaction value) =>
      <String, Object?>{
        'id': value.id,
        'type': TransactionDatabaseMapper.typeToKey(value.type),
        'amountMinorUnits': value.amount.minorUnits,
        'currency': value.amount.currencyCode,
        'category': TransactionDatabaseMapper.categoryToKey(value.category),
        'paymentMethod': TransactionDatabaseMapper.paymentMethodToKey(
          value.paymentMethod,
        ),
        'dateAd': _date(value.occurredAt),
        'merchantOrPayer': value.merchant,
        'note': value.note,
        'createdAtUtc': _timestamp(value.createdAt),
        'updatedAtUtc': _timestamp(value.updatedAt),
      };

  Map<String, Object?> _transferToJson(FinancialTransfer value) =>
      <String, Object?>{
        'id': value.id,
        'amountMinorUnits': value.amount.minorUnits,
        'currency': value.amount.currencyCode,
        'source': value.source.stableIdentifier,
        'destination': value.destination.stableIdentifier,
        'destinationName': value.destinationName,
        'countsAsExpense': value.countsAsExpense,
        'expenseCategory': value.expenseCategory == null
            ? null
            : TransactionDatabaseMapper.categoryToKey(value.expenseCategory!),
        'feeMinorUnits': value.fee.minorUnits,
        'dateAd': _date(value.occurredAt),
        'note': value.note,
        'createdAtUtc': _timestamp(value.createdAt),
        'updatedAtUtc': _timestamp(value.updatedAt),
      };

  Map<String, Object?> _ruleToJson(RecurringTransactionRule value) =>
      <String, Object?>{
        'id': value.id,
        'type': TransactionDatabaseMapper.typeToKey(value.type),
        'amountMinorUnits': value.amount.minorUnits,
        'currency': value.amount.currencyCode,
        'category': TransactionDatabaseMapper.categoryToKey(value.category),
        'paymentMethod': TransactionDatabaseMapper.paymentMethodToKey(
          value.paymentMethod,
        ),
        'merchantOrPayer': value.merchant,
        'note': value.note,
        'frequency': value.frequency.stableIdentifier,
        'recurrenceCalendar': value.recurrenceCalendar.storageValue,
        'anchorDay': value.anchorDay,
        'anchorMonth': value.anchorMonth,
        'anchorWeekday': value.anchorWeekday,
        'firstDueDateAd': _date(value.firstDueDateAd),
        'nextDueDateAd': _date(value.nextDueDateAd),
        'status': value.status.stableIdentifier,
        'createdAtUtc': _timestamp(value.createdAt),
        'updatedAtUtc': _timestamp(value.updatedAt),
        'pausedAtUtc': _nullableTimestamp(value.pausedAt),
        'deletedAtUtc': _nullableTimestamp(value.deletedAt),
      };

  Map<String, Object?> _occurrenceToJson(
    RecurringTransactionOccurrence value,
  ) => <String, Object?>{
    'id': value.id,
    'ruleId': value.ruleId,
    'dueDateAd': _date(value.dueDateAd),
    'status': value.status.stableIdentifier,
    'type': TransactionDatabaseMapper.typeToKey(value.type),
    'amountMinorUnits': value.amount.minorUnits,
    'currency': value.amount.currencyCode,
    'category': TransactionDatabaseMapper.categoryToKey(value.category),
    'paymentMethod': TransactionDatabaseMapper.paymentMethodToKey(
      value.paymentMethod,
    ),
    'merchantOrPayer': value.merchant,
    'note': value.note,
    'recordedTransactionId': value.recordedTransactionId,
    'handledAtUtc': _nullableTimestamp(value.handledAt),
    'createdAtUtc': _timestamp(value.createdAt),
  };

  FinancialTransaction _transactionFromJson(
    Map<String, Object?> json,
    Map<String, CustomCategory> customById,
  ) {
    final String id = _nonEmptyString(json, 'id');
    final TransactionType type = _type(_string(json, 'type'));
    final Money amount = _money(json);
    final TransactionCategory category = _category(
      _string(json, 'category'),
      type,
      customById,
    );
    if (!category.supports(type)) {
      throw _malformed();
    }
    return FinancialTransaction(
      id: id,
      type: type,
      amount: amount,
      category: category,
      paymentMethod: _paymentMethod(_string(json, 'paymentMethod')),
      occurredAt: _parseDate(_string(json, 'dateAd')),
      merchant: _nullableString(json, 'merchantOrPayer'),
      note: _nullableString(json, 'note'),
      createdAt: _parseTimestamp(_string(json, 'createdAtUtc')),
      updatedAt: _parseTimestamp(_string(json, 'updatedAtUtc')),
    ).._validateTransactionTimes();
  }

  FinancialTransfer _transferFromJson(
    Map<String, Object?> json,
    Map<String, CustomCategory> customById,
  ) {
    final TransferSource? source = TransferSourceMetadata.tryParse(
      _string(json, 'source'),
    );
    final TransferDestination? destination =
        TransferDestinationMetadata.tryParse(_string(json, 'destination'));
    if (source == null || destination == null) throw _malformed();
    final String? destinationName = _nullableString(
      json,
      'destinationName',
    )?.trim();
    final bool countsAsExpense = _boolean(json, 'countsAsExpense');
    final String? categoryKey = _nullableString(json, 'expenseCategory');
    final TransactionCategory? category = categoryKey == null
        ? null
        : _category(categoryKey, TransactionType.expense, customById);
    final int feeMinorUnits = _integer(json, 'feeMinorUnits');
    if (feeMinorUnits < 0 ||
        (destinationName?.length ?? 0) > 60 ||
        destination.requiresName != (destinationName?.isNotEmpty == true) ||
        countsAsExpense != (category != null) ||
        (category != null && !category.supports(TransactionType.expense))) {
      throw _malformed();
    }
    final FinancialTransfer transfer = FinancialTransfer(
      id: _nonEmptyString(json, 'id'),
      amount: _money(json),
      source: source,
      destination: destination,
      destinationName: destination.requiresName ? destinationName : null,
      countsAsExpense: countsAsExpense,
      expenseCategory: category,
      fee: Money(minorUnits: feeMinorUnits, currencyCode: currency),
      occurredAt: _parseDate(_string(json, 'dateAd')),
      note: _nullableString(json, 'note'),
      createdAt: _parseTimestamp(_string(json, 'createdAtUtc')),
      updatedAt: _parseTimestamp(_string(json, 'updatedAtUtc')),
    );
    if (transfer.updatedAt.isBefore(transfer.createdAt)) throw _malformed();
    return transfer;
  }

  RecurringTransactionRule _ruleFromJson(
    Map<String, Object?> json,
    Map<String, CustomCategory> customById,
  ) {
    final TransactionType type = _type(_string(json, 'type'));
    final TransactionCategory category = _category(
      _string(json, 'category'),
      type,
      customById,
    );
    final RecurringFrequency? frequency = RecurringFrequencyMetadata.tryParse(
      _string(json, 'frequency'),
    );
    final AppCalendarSystem? calendar = RecurrenceCalendarCodec.tryParse(
      _string(json, 'recurrenceCalendar'),
    );
    final RecurringRuleStatus? status = RecurringRuleStatusMetadata.tryParse(
      _string(json, 'status'),
    );
    if (frequency == null || calendar == null || status == null) {
      throw _malformed();
    }
    final RecurringTransactionRule rule = RecurringTransactionRule(
      id: _nonEmptyString(json, 'id'),
      type: type,
      amount: _money(json),
      category: category,
      paymentMethod: _paymentMethod(_string(json, 'paymentMethod')),
      merchant: _nullableString(json, 'merchantOrPayer'),
      note: _nullableString(json, 'note'),
      frequency: frequency,
      recurrenceCalendar: calendar,
      anchorDay: _integer(json, 'anchorDay'),
      anchorMonth: _integer(json, 'anchorMonth'),
      anchorWeekday: _integer(json, 'anchorWeekday'),
      firstDueDateAd: _parseDate(_string(json, 'firstDueDateAd')),
      nextDueDateAd: _parseDate(_string(json, 'nextDueDateAd')),
      status: status,
      createdAt: _parseTimestamp(_string(json, 'createdAtUtc')),
      updatedAt: _parseTimestamp(_string(json, 'updatedAtUtc')),
      pausedAt: _nullableTimestampFromJson(json, 'pausedAtUtc'),
      deletedAt: _nullableTimestampFromJson(json, 'deletedAtUtc'),
    );
    final ({int day, int month, int weekday}) expectedAnchors =
        _recurrenceService.anchorsFor(
          rule.firstDueDateAd,
          rule.recurrenceCalendar,
        );
    if (!category.supports(type) ||
        rule.nextDueDateAd.isBefore(rule.firstDueDateAd) ||
        rule.updatedAt.isBefore(rule.createdAt) ||
        rule.anchorDay != expectedAnchors.day ||
        rule.anchorMonth != expectedAnchors.month ||
        rule.anchorWeekday != expectedAnchors.weekday) {
      throw _malformed();
    }
    try {
      _recurrenceService.validateRule(rule);
    } on Object {
      throw _malformed();
    }
    if (status == RecurringRuleStatus.active &&
        (rule.pausedAt != null || rule.deletedAt != null)) {
      throw _malformed();
    }
    if (status == RecurringRuleStatus.paused && rule.pausedAt == null) {
      throw _malformed();
    }
    if (status == RecurringRuleStatus.paused && rule.deletedAt != null) {
      throw _malformed();
    }
    if (status == RecurringRuleStatus.deleted && rule.deletedAt == null) {
      throw _malformed();
    }
    return rule;
  }

  RecurringTransactionOccurrence _occurrenceFromJson(
    Map<String, Object?> json,
    Map<String, CustomCategory> customById,
  ) {
    final TransactionType type = _type(_string(json, 'type'));
    final TransactionCategory category = _category(
      _string(json, 'category'),
      type,
      customById,
    );
    final RecurringOccurrenceStatus? status =
        RecurringOccurrenceStatusMetadata.tryParse(_string(json, 'status'));
    if (status == null || !category.supports(type)) {
      throw _malformed();
    }
    final String? recordedId = _nullableString(json, 'recordedTransactionId');
    final DateTime? handledAt = _nullableTimestampFromJson(
      json,
      'handledAtUtc',
    );
    if (status == RecurringOccurrenceStatus.pending &&
        (recordedId != null || handledAt != null)) {
      throw _malformed();
    }
    if (status == RecurringOccurrenceStatus.skipped &&
        (recordedId != null || handledAt == null)) {
      throw _malformed();
    }
    if (status == RecurringOccurrenceStatus.recorded && handledAt == null) {
      throw _malformed();
    }
    return RecurringTransactionOccurrence(
      id: _nonEmptyString(json, 'id'),
      ruleId: _nonEmptyString(json, 'ruleId'),
      dueDateAd: _parseDate(_string(json, 'dueDateAd')),
      status: status,
      type: type,
      amount: _money(json),
      category: category,
      paymentMethod: _paymentMethod(_string(json, 'paymentMethod')),
      merchant: _nullableString(json, 'merchantOrPayer'),
      note: _nullableString(json, 'note'),
      recordedTransactionId: recordedId,
      handledAt: handledAt,
      createdAt: _parseTimestamp(_string(json, 'createdAtUtc')),
    );
  }

  void _validateRelationships(
    List<FinancialTransaction> transactions,
    List<RecurringTransactionRule> rules,
    List<RecurringTransactionOccurrence> occurrences,
    List<FinancialTransfer> transfers,
  ) {
    final Set<String> transactionIds = _uniqueIds(
      transactions.map((value) => value.id),
    );
    final Set<String> ruleIds = _uniqueIds(rules.map((value) => value.id));
    _uniqueIds(occurrences.map((value) => value.id));
    _uniqueIds(transfers.map((value) => value.id));
    final Set<String> ruleDates = <String>{};
    for (final RecurringTransactionOccurrence occurrence in occurrences) {
      if (!ruleIds.contains(occurrence.ruleId)) {
        throw _malformed();
      }
      final String identity =
          '${occurrence.ruleId}|${_date(occurrence.dueDateAd)}';
      if (!ruleDates.add(identity)) {
        throw _malformed();
      }
      final String? recordedId = occurrence.recordedTransactionId;
      if (recordedId != null && !transactionIds.contains(recordedId)) {
        throw _malformed();
      }
    }
  }

  Set<String> _uniqueIds(Iterable<String> ids) {
    final Set<String> result = <String>{};
    for (final String id in ids) {
      if (!result.add(id)) {
        throw _malformed();
      }
    }
    return result;
  }

  Money _money(Map<String, Object?> json) {
    final int minorUnits = _integer(json, 'amountMinorUnits');
    if (minorUnits <= 0 || _string(json, 'currency') != currency) {
      throw _malformed();
    }
    return Money(minorUnits: minorUnits, currencyCode: currency);
  }

  TransactionType _type(String value) {
    try {
      return TransactionDatabaseMapper.typeFromKey(value);
    } on FormatException {
      throw _malformed();
    }
  }

  TransactionCategory _category(
    String value,
    TransactionType type,
    Map<String, CustomCategory> customById,
  ) {
    final TransactionCategory? system =
        TransactionCategory.systemFromIdentifier(value);
    if (system != null && system.supports(type)) return system;
    final CustomCategory? custom = customById[value];
    if (custom != null && custom.type == type) return custom.reference;
    throw _malformed();
  }

  PaymentMethod _paymentMethod(String value) {
    final PaymentMethod method = TransactionDatabaseMapper.paymentMethodFromKey(
      value,
    );
    if (method.stableIdentifier != value) {
      throw _malformed();
    }
    return method;
  }

  Map<String, Object?> _object(Object? value) {
    if (value is! Map<String, Object?>) {
      throw _malformed();
    }
    return value;
  }

  List<Object?> _array(Map<String, Object?> value, String key) {
    final Object? result = value[key];
    if (result is! List<Object?>) {
      throw _malformed();
    }
    return result;
  }

  Object? _requiredValue(Map<String, Object?> value, String key) {
    if (!value.containsKey(key)) throw _malformed();
    return value[key];
  }

  String _string(Map<String, Object?> value, String key) {
    final Object? result = value[key];
    if (result is! String) {
      throw _malformed();
    }
    return result;
  }

  String _nonEmptyString(Map<String, Object?> value, String key) {
    final String result = _string(value, key);
    if (result.trim().isEmpty) {
      throw _malformed();
    }
    return result;
  }

  String? _nullableString(Map<String, Object?> value, String key) {
    if (!value.containsKey(key)) {
      throw _malformed();
    }
    final Object? result = value[key];
    if (result != null && result is! String) {
      throw _malformed();
    }
    return result as String?;
  }

  int _integer(Map<String, Object?> value, String key) {
    final Object? result = value[key];
    if (result is! int) {
      throw _malformed();
    }
    return result;
  }

  bool _boolean(Map<String, Object?> value, String key) {
    final Object? result = value[key];
    if (result is! bool) throw _malformed();
    return result;
  }

  DateTime? _nullableTimestampFromJson(Map<String, Object?> value, String key) {
    final String? raw = _nullableString(value, key);
    return raw == null ? null : _parseTimestamp(raw);
  }

  DateTime _parseDate(String value) {
    final RegExpMatch? match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})$',
    ).firstMatch(value);
    if (match == null) {
      throw _malformed();
    }
    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);
    final DateTime result = DateTime.utc(year, month, day, 12);
    if (result.year != year || result.month != month || result.day != day) {
      throw _malformed();
    }
    return result;
  }

  DateTime _parseTimestamp(String value) {
    if (!value.endsWith('Z')) {
      throw _malformed();
    }
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) {
      throw _malformed();
    }
    return parsed;
  }

  void _checkCollectionSize(List<Object?> values) {
    if (values.length > maximumRecordsPerCollection) {
      throw _malformed();
    }
  }

  String _date(DateTime value) {
    final DateTime utc = value.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }

  String _timestamp(DateTime value) => value.toUtc().toIso8601String();

  String? _nullableTimestamp(DateTime? value) =>
      value == null ? null : _timestamp(value);

  BackupValidationException _malformed() => const BackupValidationException(
    BackupValidationIssue.malformed,
    'This does not appear to be a valid backup file.',
  );
}

extension on FinancialTransaction {
  void _validateTransactionTimes() {
    if (updatedAt.isBefore(createdAt)) {
      throw const BackupValidationException(
        BackupValidationIssue.malformed,
        'This does not appear to be a valid backup file.',
      );
    }
  }
}

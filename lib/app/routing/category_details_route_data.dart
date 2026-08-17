import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CategoryDetailsRouteData {
  CategoryDetailsRouteData({
    required this.type,
    required List<TransactionCategory> categories,
    DateTime? month,
    CalendarPeriod? period,
  }) : categories = List<TransactionCategory>.unmodifiable(categories),
       period = period ?? _periodForGregorianMonth(month) {
    if (categories.isEmpty) {
      throw ArgumentError.value(
        categories,
        'categories',
        'At least one category is required.',
      );
    }
    if (categories.any(
      (TransactionCategory category) => !category.supports(type),
    )) {
      throw ArgumentError.value(
        categories,
        'categories',
        'Every category must support the transaction type.',
      );
    }
  }

  final TransactionType type;
  final List<TransactionCategory> categories;
  final CalendarPeriod period;

  DateTime get month =>
      DateTime(period.startAdInclusive.year, period.startAdInclusive.month);

  String get categoryIdentifiers =>
      categories.map((TransactionCategory category) => category.name).join(',');

  static CategoryDetailsRouteData? tryParse({
    required String? typeIdentifier,
    required String? categoryIdentifiers,
    required String? year,
    required String? month,
    String? calendarSystem,
  }) {
    final TransactionType? type = _transactionType(typeIdentifier);
    final int? parsedYear = int.tryParse(year ?? '');
    final int? parsedMonth = int.tryParse(month ?? '');
    if (type == null ||
        parsedYear == null ||
        parsedMonth == null ||
        parsedYear < 1 ||
        parsedMonth < 1 ||
        parsedMonth > 12 ||
        categoryIdentifiers == null) {
      return null;
    }

    final List<TransactionCategory> categories = <TransactionCategory>[];
    for (final String identifier in categoryIdentifiers.split(',')) {
      final TransactionCategory? category = _category(identifier, type);
      if (category == null || !category.supports(type)) {
        return null;
      }
      if (!categories.contains(category)) {
        categories.add(category);
      }
    }
    if (categories.isEmpty) {
      return null;
    }
    final AppCalendarSystem system = AppCalendarSystemLabels.fromStoredValue(
      calendarSystem,
    );
    try {
      return CategoryDetailsRouteData(
        type: type,
        categories: categories,
        period: BikramSambatCalendarService().periodFor(
          calendarSystem: system,
          year: parsedYear,
          month: parsedMonth,
        ),
      );
    } on RangeError {
      return null;
    }
  }

  static TransactionType? _transactionType(String? identifier) {
    for (final TransactionType type in TransactionType.values) {
      if (type.name == identifier) {
        return type;
      }
    }
    return null;
  }

  static TransactionCategory? _category(
    String identifier,
    TransactionType type,
  ) {
    return TransactionCategory.systemFromIdentifier(identifier) ??
        (TransactionCategory.isCustomIdentifier(identifier)
            ? TransactionCategory.custom(identifier, type: type)
            : null);
  }

  static CalendarPeriod _periodForGregorianMonth(DateTime? month) {
    if (month == null) {
      throw ArgumentError('A calendar period or Gregorian month is required.');
    }
    return BikramSambatCalendarService().periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: month.year,
      month: month.month,
    );
  }
}

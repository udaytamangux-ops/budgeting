import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';

enum MoneyPlanGroup { needs, wants, unassigned }

extension MoneyPlanGroupMetadata on MoneyPlanGroup {
  String get storageValue => switch (this) {
    MoneyPlanGroup.needs => 'needs',
    MoneyPlanGroup.wants => 'wants',
    MoneyPlanGroup.unassigned => 'unassigned',
  };

  String get label => switch (this) {
    MoneyPlanGroup.needs => 'Needs',
    MoneyPlanGroup.wants => 'Wants',
    MoneyPlanGroup.unassigned => 'Unassigned',
  };

  static MoneyPlanGroup? tryParse(String value) {
    for (final MoneyPlanGroup group in MoneyPlanGroup.values) {
      if (group.storageValue == value) return group;
    }
    return null;
  }
}

final class MoneyPlanRatios {
  factory MoneyPlanRatios({
    required int needsPercent,
    required int wantsPercent,
    required int savingsPercent,
  }) {
    for (final int value in <int>[needsPercent, wantsPercent, savingsPercent]) {
      if (value < 0 || value > 100) {
        throw ArgumentError('Money Plan percentages must be from 0 to 100.');
      }
    }
    if (needsPercent + wantsPercent + savingsPercent != 100) {
      throw ArgumentError('Money Plan percentages must total 100.');
    }
    return MoneyPlanRatios._(
      needsPercent: needsPercent,
      wantsPercent: wantsPercent,
      savingsPercent: savingsPercent,
    );
  }

  const MoneyPlanRatios._({
    required this.needsPercent,
    required this.wantsPercent,
    required this.savingsPercent,
  });

  static const MoneyPlanRatios defaultPlan = MoneyPlanRatios._(
    needsPercent: 50,
    wantsPercent: 30,
    savingsPercent: 20,
  );

  final int needsPercent;
  final int wantsPercent;
  final int savingsPercent;

  int get total => needsPercent + wantsPercent + savingsPercent;

  @override
  bool operator ==(Object other) =>
      other is MoneyPlanRatios &&
      needsPercent == other.needsPercent &&
      wantsPercent == other.wantsPercent &&
      savingsPercent == other.savingsPercent;

  @override
  int get hashCode => Object.hash(needsPercent, wantsPercent, savingsPercent);
}

final class MoneyPlanPreference {
  const MoneyPlanPreference({
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class MoneyPlanPeriod {
  const MoneyPlanPeriod({
    required this.id,
    required this.period,
    required this.ratios,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final CalendarPeriod period;
  final MoneyPlanRatios ratios;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class MoneyPlanCategoryMapping {
  MoneyPlanCategoryMapping({
    required this.id,
    required this.periodId,
    required this.categoryId,
    required this.group,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (group == MoneyPlanGroup.unassigned) {
      throw ArgumentError('Unassigned categories are represented by no row.');
    }
  }

  final String id;
  final String periodId;
  final String categoryId;
  final MoneyPlanGroup group;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class MoneyPlanSummary {
  MoneyPlanSummary({
    required this.planIncome,
    required this.needsTarget,
    required this.needsRecorded,
    required this.wantsTarget,
    required this.wantsRecorded,
    required this.savingsTarget,
    required this.unassignedRecorded,
    required this.totalRecordedSpending,
    required this.remainingAfterSpending,
    required Set<String> unassignedCategoryIds,
  }) : unassignedCategoryIds = Set<String>.unmodifiable(unassignedCategoryIds);

  final Money planIncome;
  final Money needsTarget;
  final Money needsRecorded;
  final Money wantsTarget;
  final Money wantsRecorded;
  final Money savingsTarget;
  final Money unassignedRecorded;
  final Money totalRecordedSpending;
  final Money remainingAfterSpending;
  final Set<String> unassignedCategoryIds;

  bool get hasPlanIncome => planIncome.isPositive;
}

final class MoneyPlanException implements Exception {
  const MoneyPlanException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

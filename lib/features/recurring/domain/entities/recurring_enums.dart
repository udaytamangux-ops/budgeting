import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';

enum RecurringFrequency { weekly, monthly, yearly }

extension RecurringFrequencyMetadata on RecurringFrequency {
  String get stableIdentifier => switch (this) {
    RecurringFrequency.weekly => 'weekly',
    RecurringFrequency.monthly => 'monthly',
    RecurringFrequency.yearly => 'yearly',
  };

  String get label => switch (this) {
    RecurringFrequency.weekly => 'Weekly',
    RecurringFrequency.monthly => 'Monthly',
    RecurringFrequency.yearly => 'Yearly',
  };

  static RecurringFrequency? tryParse(String value) => switch (value) {
    'weekly' => RecurringFrequency.weekly,
    'monthly' => RecurringFrequency.monthly,
    'yearly' => RecurringFrequency.yearly,
    _ => null,
  };
}

enum RecurringRuleStatus { active, paused, deleted }

extension RecurringRuleStatusMetadata on RecurringRuleStatus {
  String get stableIdentifier => switch (this) {
    RecurringRuleStatus.active => 'active',
    RecurringRuleStatus.paused => 'paused',
    RecurringRuleStatus.deleted => 'deleted',
  };

  static RecurringRuleStatus? tryParse(String value) => switch (value) {
    'active' => RecurringRuleStatus.active,
    'paused' => RecurringRuleStatus.paused,
    'deleted' => RecurringRuleStatus.deleted,
    _ => null,
  };
}

enum RecurringOccurrenceStatus { pending, recorded, skipped }

extension RecurringOccurrenceStatusMetadata on RecurringOccurrenceStatus {
  String get stableIdentifier => switch (this) {
    RecurringOccurrenceStatus.pending => 'pending',
    RecurringOccurrenceStatus.recorded => 'recorded',
    RecurringOccurrenceStatus.skipped => 'skipped',
  };

  static RecurringOccurrenceStatus? tryParse(String value) => switch (value) {
    'pending' => RecurringOccurrenceStatus.pending,
    'recorded' => RecurringOccurrenceStatus.recorded,
    'skipped' => RecurringOccurrenceStatus.skipped,
    _ => null,
  };
}

extension RecurrenceCalendarCodec on AppCalendarSystem {
  static AppCalendarSystem? tryParse(String value) => switch (value) {
    'gregorian_ad' => AppCalendarSystem.gregorianAd,
    'bikram_sambat_bs' => AppCalendarSystem.bikramSambatBs,
    _ => null,
  };
}

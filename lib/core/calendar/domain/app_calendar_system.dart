enum AppCalendarSystem { gregorianAd, bikramSambatBs }

extension AppCalendarSystemLabels on AppCalendarSystem {
  String get storageValue => switch (this) {
    AppCalendarSystem.gregorianAd => 'gregorian_ad',
    AppCalendarSystem.bikramSambatBs => 'bikram_sambat_bs',
  };

  String get shortLabel => switch (this) {
    AppCalendarSystem.gregorianAd => 'AD',
    AppCalendarSystem.bikramSambatBs => 'BS',
  };

  String get title => switch (this) {
    AppCalendarSystem.gregorianAd => 'AD — Gregorian',
    AppCalendarSystem.bikramSambatBs => 'BS — Bikram Sambat',
  };

  String get description => switch (this) {
    AppCalendarSystem.gregorianAd => 'International calendar',
    AppCalendarSystem.bikramSambatBs => 'Nepali calendar',
  };

  String get semanticName => switch (this) {
    AppCalendarSystem.gregorianAd => 'Gregorian, AD',
    AppCalendarSystem.bikramSambatBs => 'Bikram Sambat, BS',
  };

  static AppCalendarSystem fromStoredValue(String? value) {
    return AppCalendarSystem.values
            .where((AppCalendarSystem system) => system.storageValue == value)
            .firstOrNull ??
        AppCalendarSystem.gregorianAd;
  }
}

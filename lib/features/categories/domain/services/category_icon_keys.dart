abstract final class CategoryIconKeys {
  static const String fallback = 'other';
  static const List<String> customChoices = <String>[
    'food',
    'transport',
    'home',
    'utilities',
    'shopping',
    'health',
    'education',
    'entertainment',
    'family',
    'receipt',
    'work',
    'laptop',
    'business',
    'wallet',
    'globe',
    'gift',
    'refund',
    'fitness',
    'travel',
    'pets',
    'savings',
    'subscriptions',
    fallback,
  ];

  static bool isSupported(String value) => customChoices.contains(value);
}

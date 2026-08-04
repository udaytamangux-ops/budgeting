abstract final class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String home = '/app/home';
  static const String transactions = '/app/transactions';
  static const String budgets = '/app/budgets';
  static const String summary = budgets;
  static const String profile = '/app/profile';
  static const String addExpense = '/app/add-transaction';
  static const String addIncome = '/app/add-transaction?type=income';

  static String transactionDetails(String transactionId) {
    return '$transactions/${Uri.encodeComponent(transactionId)}';
  }

  static String editTransaction(String transactionId) {
    return '$addExpense?transactionId=${Uri.encodeComponent(transactionId)}';
  }

  static String repeatTransaction(String transactionId) {
    return '$addExpense?repeatTransactionId='
        '${Uri.encodeComponent(transactionId)}';
  }
}

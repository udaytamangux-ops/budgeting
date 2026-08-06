import 'package:budgeting_app/app/routing/category_details_route_data.dart';

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

  static String categoryDetails(CategoryDetailsRouteData data) {
    return '${_categoryDetailsPath(data)}${_categoryQuery(data)}';
  }

  static String categoryTransactionDetails(
    CategoryDetailsRouteData data,
    String transactionId,
  ) {
    return '${_categoryDetailsPath(data)}/transactions/'
        '${Uri.encodeComponent(transactionId)}${_categoryQuery(data)}';
  }

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

  static String _categoryDetailsPath(CategoryDetailsRouteData data) {
    return '$summary/category/${Uri.encodeComponent(data.type.name)}/'
        '${Uri.encodeComponent(data.categoryIdentifiers)}';
  }

  static String _categoryQuery(CategoryDetailsRouteData data) {
    return '?year=${data.month.year}&month=${data.month.month}';
  }
}

import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';

abstract final class AppRoutes {
  static const String access = '/access';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String calendarSetup = '/calendar-setup';
  static const String welcome = access;
  static const String login = signIn;
  static const String signup = signUp;
  static const String onboarding = '/onboarding';
  static const String home = '/app/home';
  static const String transactions = '/app/transactions';
  static const String budgets = '/app/budgets';
  static const String summary = budgets;
  static const String profile = '/app/profile';
  static const String privacyAndData = '/app/profile/privacy-and-data';
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
    return '?calendar=${data.period.calendarSystem.storageValue}'
        '&year=${data.period.year}&month=${data.period.month}';
  }
}

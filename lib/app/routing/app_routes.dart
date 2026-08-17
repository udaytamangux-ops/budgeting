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
  static const String categories = '/app/profile/categories';
  static const String recurring = '/app/recurring';
  static const String createRecurring = '/app/recurring/new';
  static const String addExpense = '/app/add-transaction';
  static const String addIncome = '/app/add-transaction?type=income';
  static const String addTransfer = '/app/add-transaction?type=transfer';
  static const String monthlyReport = '/app/budgets/monthly-report';
  static const String monthlyVisualReport = '$monthlyReport/visual';
  static const String monthlyComparison = '$monthlyReport/comparison';
  static const String moneyPlan = '$summary/money-plan';
  static const String moneyPlanSetup = '$moneyPlan/setup';
  static const String moneyPlanSetupCategories = '$moneyPlan/setup/categories';
  static const String moneyPlanEdit = '$moneyPlan/edit';
  static const String moneyPlanEditCategories = '$moneyPlan/edit/categories';
  static const String moneyPlanCategories = '$moneyPlan/categories';

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

  static String transferDetails(String transferId) {
    return '$transactions/transfers/${Uri.encodeComponent(transferId)}';
  }

  static String editTransfer(String transferId) {
    return '$addExpense?transferId=${Uri.encodeComponent(transferId)}';
  }

  static String repeatTransfer(String transferId) {
    return '$addExpense?repeatTransferId=${Uri.encodeComponent(transferId)}';
  }

  static String editTransaction(String transactionId) {
    return '$addExpense?transactionId=${Uri.encodeComponent(transactionId)}';
  }

  static String repeatTransaction(String transactionId) {
    return '$addExpense?repeatTransactionId='
        '${Uri.encodeComponent(transactionId)}';
  }

  static String recordRecurringOccurrence(String occurrenceId) {
    return '$addExpense?occurrenceId=${Uri.encodeComponent(occurrenceId)}';
  }

  static String makeRecurring(String transactionId) {
    return '$createRecurring?sourceTransactionId='
        '${Uri.encodeComponent(transactionId)}';
  }

  static String editRecurring(String ruleId) {
    return '$recurring/${Uri.encodeComponent(ruleId)}/edit';
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

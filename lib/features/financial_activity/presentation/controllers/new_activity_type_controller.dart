import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<NewActivityTypeController, FinancialActivityType>
newActivityTypeProvider =
    NotifierProvider<NewActivityTypeController, FinancialActivityType>(
      NewActivityTypeController.new,
    );

final class NewActivityTypeController extends Notifier<FinancialActivityType> {
  @override
  FinancialActivityType build() => FinancialActivityType.expense;

  void select(FinancialActivityType value) => state = value;

  void reset() => state = FinancialActivityType.expense;
}

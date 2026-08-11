import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:budgeting_app/features/transfers/presentation/widgets/transfer_list_item.dart';
import 'package:flutter/widgets.dart';

final class FinancialActivityListItem extends StatelessWidget {
  const FinancialActivityListItem({
    required this.activity,
    required this.onTap,
    this.showDate = true,
    this.displayAmount,
    super.key,
  });

  final FinancialActivity activity;
  final VoidCallback onTap;
  final bool showDate;
  final Money? displayAmount;

  @override
  Widget build(BuildContext context) => switch (activity) {
    TransactionActivity(:final transaction) => TransactionListItem(
      transaction: transaction,
      onTap: onTap,
      showDate: showDate,
    ),
    TransferActivity(:final transfer) => TransferListItem(
      transfer: transfer,
      onTap: onTap,
      showDate: showDate,
      displayAmount: displayAmount,
    ),
  };
}

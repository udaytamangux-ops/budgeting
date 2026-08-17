import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_comparison_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/monthly_reports/domain/services/monthly_report_service.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<MonthlyReportService> monthlyReportServiceProvider =
    Provider<MonthlyReportService>((Ref ref) {
      final catalog = ref.watch(categoryCatalogProvider);
      return MonthlyReportService(
        ref.watch(appCalendarServiceProvider),
        categoryLabelFor: (category) => catalog.resolve(category).label,
      );
    });

final Provider<AsyncValue<MonthlyReportData>> monthlyReportProvider =
    Provider<AsyncValue<MonthlyReportData>>((Ref ref) {
      final period = ref.watch(effectiveSelectedCalendarPeriodProvider);
      final DateTime now = ref.watch(currentDateProvider);
      return ref
          .watch(financialActivityListProvider)
          .whenData(
            (List<FinancialActivity> activities) => ref
                .read(monthlyReportServiceProvider)
                .build(period: period, activities: activities, now: now),
          );
    });

final Provider<AsyncValue<MonthlyComparisonData>> monthlyComparisonProvider =
    Provider<AsyncValue<MonthlyComparisonData>>((Ref ref) {
      final period = ref.watch(effectiveSelectedCalendarPeriodProvider);
      final DateTime now = ref.watch(currentDateProvider);
      return ref
          .watch(financialActivityListProvider)
          .whenData(
            (List<FinancialActivity> activities) => ref
                .read(monthlyReportServiceProvider)
                .compare(
                  selectedPeriod: period,
                  activities: activities,
                  now: now,
                ),
          );
    });

// lib/Screens/crm/crm_main_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Screens/crm/crm_calendar_screen.dart';
import 'package:templink/Screens/crm/crm_cases_screen.dart';
import 'package:templink/Screens/crm/crm_companies_screen.dart';
import 'package:templink/Screens/crm/crm_contacts_screen.dart';
import 'package:templink/Screens/crm/crm_dashboard_screen.dart';
import 'package:templink/Screens/crm/crm_deals_screen.dart';
import 'package:templink/Screens/crm/crm_email_screen.dart';
import 'package:templink/Screens/crm/crm_leads_screen.dart';
import 'package:templink/Screens/crm/crm_meetings_screen.dart';
import 'package:templink/Screens/crm/crm_notes_screen.dart';
import 'package:templink/Screens/crm/crm_pipeline_screen.dart';
import 'package:templink/Screens/crm/crm_products_screen.dart';
import 'package:templink/Screens/crm/crm_quotations_screen.dart';
import 'package:templink/Screens/crm/crm_reports_screen.dart';
import 'package:templink/Screens/crm/crm_settings_screen.dart';
import 'package:templink/Screens/crm/crm_tasks_screen.dart';

class CrmMainScreen extends StatelessWidget {
  final int subpageIndex;
  final Function(int)? onNavigateSubmenu;

  const CrmMainScreen({
    Key? key,
    required this.subpageIndex,
    this.onNavigateSubmenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (subpageIndex) {
      case 0:
        return CrmDashboardScreen(onNavigateSubmenu: onNavigateSubmenu);
      case 1:
        return const CrmLeadsScreen();
      case 2:
        return const CrmContactsScreen();
      case 3:
        return const CrmCompaniesScreen();
      case 4:
        return const CrmDealsScreen();
      case 5:
        return const CrmPipelineScreen();
      case 6:
        return const CrmTasksScreen();
      case 7:
        return const CrmCalendarScreen();
      case 8:
        return const CrmMeetingsScreen();
      case 9:
        return const CrmNotesScreen();
      case 10:
        return const CrmEmailScreen();
      case 11:
        return const CrmCasesScreen();
      case 12:
        return const CrmProductsScreen();
      case 13:
        return const CrmQuotationsScreen();
      case 14:
        return const CrmReportsScreen();
      case 15:
        return const CrmSettingsScreen();
      default:
        return CrmDashboardScreen(onNavigateSubmenu: onNavigateSubmenu);
    }
  }
}

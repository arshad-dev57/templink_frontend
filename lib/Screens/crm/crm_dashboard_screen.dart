// lib/Screens/crm/crm_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_kpi_card.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateSubmenu;

  const CrmDashboardScreen({Key? key, this.onNavigateSubmenu}) : super(key: key);

  @override
  State<CrmDashboardScreen> createState() => _CrmDashboardScreenState();
}

class _CrmDashboardScreenState extends State<CrmDashboardScreen> {
  bool _isLoading = true;
  CrmDashboardData? _data;
  List<CrmTeamMember> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      CrmApiService.getDashboardAnalytics(),
      CrmApiService.getTeamMembers(),
    ]);

    if (mounted) {
      setState(() {
        _data = results[0] as CrmDashboardData?;
        _teamMembers = results[1] as List<CrmTeamMember>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CrmTheme.primaryColor),
      );
    }

    final d = _data ?? CrmDashboardData(role: 'employer');

    return RefreshIndicator(
      onRefresh: _loadData,
      color: CrmTheme.primaryColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CrmHeader(
              title: d.role == 'employee' ? 'My CRM Dashboard' : 'Organization CRM Dashboard',
              subtitle: d.role == 'employee'
                  ? 'Track your assigned leads, ongoing deals, tasks, and sales activity.'
                  : 'Holistic organization pipeline, lead conversion, revenue, and team metrics.',
              icon: Icons.dashboard_outlined,
              onRefresh: _loadData,
              actionLabel: 'New Lead',
              actionIcon: Icons.person_add_outlined,
              onAction: () async {
                final ok = await CrmDialogs.showLeadDialog(
                  context,
                  teamMembers: _teamMembers,
                );
                if (ok == true) _loadData();
              },
            ),

            // Top KPI Row (Responsive grid)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 1100 ? 4 : (width > 650 ? 2 : 1);

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: width > 1100 ? 1.6 : 1.9,
                  children: [
                    CrmKpiCard(
                      title: 'Total Active Leads',
                      value: d.totalLeads.toString(),
                      subtitle: '${d.qualifiedLeads} qualified leads',
                      icon: Icons.filter_alt_outlined,
                      accentColor: CrmTheme.sky,
                      trend: '+${d.newLeads} new',
                      isPositive: true,
                    ),
                    CrmKpiCard(
                      title: 'Pipeline Deal Value',
                      value: '\$${d.pipelineValue.toStringAsFixed(0)}',
                      subtitle: '${d.openDealsCount} active deals in pipeline',
                      icon: Icons.monetization_on_outlined,
                      accentColor: CrmTheme.violet,
                      trend: 'Weighted: \$${d.weightedPipelineValue.toStringAsFixed(0)}',
                      isPositive: true,
                    ),
                    CrmKpiCard(
                      title: 'Won Deal Revenue',
                      value: '\$${d.wonRevenue.toStringAsFixed(0)}',
                      subtitle: '${d.wonDealsCount} deals closed won (${d.winRate}% win rate)',
                      icon: Icons.check_circle_outline,
                      accentColor: CrmTheme.emerald,
                      trend: '${d.winRate}% win rate',
                      isPositive: true,
                    ),
                    CrmKpiCard(
                      title: 'Pending Activities',
                      value: d.upcomingActivitiesCount.toString(),
                      subtitle: '${d.overdueActivities} overdue follow-ups',
                      icon: Icons.calendar_today_outlined,
                      accentColor: d.overdueActivities > 0 ? CrmTheme.rose : CrmTheme.amber,
                      trend: d.overdueActivities > 0 ? '${d.overdueActivities} overdue' : 'On track',
                      isPositive: d.overdueActivities == 0,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Middle Section: Pipeline Stages + Quick Actions
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                final pipelineWidget = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: CrmTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pipeline Funnel Stages',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CrmTheme.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => widget.onNavigateSubmenu?.call(5), // pipeline
                            child: const Text('View Full Board →'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (d.dealsByStage.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No deals recorded in the pipeline yet.',
                              style: TextStyle(color: CrmTheme.textMuted),
                            ),
                          ),
                        )
                      else
                        ...d.dealsByStage.map((st) {
                          final name = st['name']?.toString() ?? '';
                          final count = (st['count'] as num?)?.toInt() ?? 0;
                          final totalVal = (st['totalValue'] as num?)?.toDouble() ?? 0.0;
                          final maxVal = d.pipelineValue > 0 ? d.pipelineValue : 1;
                          final percent = (totalVal / maxVal).clamp(0.05, 1.0);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: CrmTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '$count deals · \$${totalVal.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: CrmTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 8,
                                    backgroundColor: CrmTheme.borderLight,
                                    valueColor: const AlwaysStoppedAnimation<Color>(CrmTheme.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );

                final quickActionsWidget = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: CrmTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Operations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CrmTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _quickActionButton(
                        icon: Icons.person_add_alt,
                        label: 'Add New Lead',
                        color: CrmTheme.sky,
                        onTap: () async {
                          final ok = await CrmDialogs.showLeadDialog(context, teamMembers: _teamMembers);
                          if (ok == true) _loadData();
                        },
                      ),
                      const SizedBox(height: 10),
                      _quickActionButton(
                        icon: Icons.handshake_outlined,
                        label: 'Create Opportunity Deal',
                        color: CrmTheme.violet,
                        onTap: () async {
                          final ok = await CrmDialogs.showDealDialog(context);
                          if (ok == true) _loadData();
                        },
                      ),
                      const SizedBox(height: 10),
                      _quickActionButton(
                        icon: Icons.event_available,
                        label: 'Schedule Meeting / Call',
                        color: CrmTheme.emerald,
                        onTap: () async {
                          final ok = await CrmDialogs.showActivityDialog(
                            context,
                            defaultType: 'meeting',
                            teamMembers: _teamMembers,
                          );
                          if (ok == true) _loadData();
                        },
                      ),
                      const SizedBox(height: 10),
                      _quickActionButton(
                        icon: Icons.mail_outline,
                        label: 'Send Email Communication',
                        color: CrmTheme.amber,
                        onTap: () async {
                          final ok = await CrmDialogs.showComposeEmailDialog(context);
                          if (ok == true) _loadData();
                        },
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: pipelineWidget),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: quickActionsWidget),
                    ],
                  );
                }

                return Column(
                  children: [
                    pipelineWidget,
                    const SizedBox(height: 20),
                    quickActionsWidget,
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Team Sales Performance Leaderboard (for authorized users)
            if (d.teamPerformance.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: CrmTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Sales Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CrmTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(CrmTheme.bgLight),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('Employee / Member', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Deals Owned', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Won Deals', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Won Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Active Pipeline', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: d.teamPerformance.map((tp) {
                          return DataRow(cells: [
                            DataCell(Text(tp['name'] ?? 'Team Member', style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(tp['totalDeals']?.toString() ?? '0')),
                            DataCell(Text(tp['wonDeals']?.toString() ?? '0', style: const TextStyle(color: CrmTheme.emerald, fontWeight: FontWeight.bold))),
                            DataCell(Text('\$${(tp['wonRevenue'] as num?)?.toStringAsFixed(0) ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('\$${(tp['pipelineValue'] as num?)?.toStringAsFixed(0) ?? '0'}')),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Recent Leads Table
            Container(
              padding: const EdgeInsets.all(20),
              decoration: CrmTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Leads',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CrmTheme.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigateSubmenu?.call(1), // leads
                        child: const Text('View All Leads →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (d.recentLeads.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No leads in your CRM yet. Create your first lead above!',
                          style: TextStyle(color: CrmTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(CrmTheme.bgLight),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('Lead ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Est. Value', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: d.recentLeads.map((l) {
                          return DataRow(cells: [
                            DataCell(Text(l.leadId, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                            DataCell(Text(l.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(l.company.isNotEmpty ? l.company : '—')),
                            DataCell(CrmBadge.status(l.status)),
                            DataCell(CrmBadge.priority(l.priority)),
                            DataCell(Text(l.estimatedDealValue > 0 ? '\$${l.estimatedDealValue.toStringAsFixed(0)}' : '—')),
                            DataCell(Text(l.assignedTo?.fullName ?? 'Unassigned')),
                          ]);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}

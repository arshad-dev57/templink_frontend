// lib/Screens/crm/crm_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmReportsScreen extends StatefulWidget {
  const CrmReportsScreen({Key? key}) : super(key: key);

  @override
  State<CrmReportsScreen> createState() => _CrmReportsScreenState();
}

class _CrmReportsScreenState extends State<CrmReportsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _reports = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final data = await CrmApiService.getReportsAndAnalytics();
    if (mounted) {
      setState(() {
        _reports = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor));
    }

    final monthlyRevenue = (_reports['monthlyRevenue'] as List<dynamic>?) ?? [];
    final sourceBreakdown = (_reports['sourceBreakdown'] as List<dynamic>?) ?? [];
    final stageFunnel = (_reports['stageFunnel'] as List<dynamic>?) ?? [];
    final repPerformance = (_reports['repPerformance'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmHeader(
            title: 'Reports & Sales Analytics',
            subtitle: 'Real-time performance analytics, revenue trajectories, channel effectiveness, and conversion funnels.',
            icon: Icons.analytics_outlined,
            onRefresh: _loadReports,
          ),

          // Row 1: Funnel & Sources
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              final funnelCard = Container(
                padding: const EdgeInsets.all(20),
                decoration: CrmTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pipeline Stage Funnel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (stageFunnel.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No funnel data available')))
                    else
                      ...stageFunnel.map((sf) {
                        final name = sf['stageName']?.toString() ?? '';
                        final count = (sf['dealsCount'] as num?)?.toInt() ?? 0;
                        final amount = (sf['totalAmount'] as num?)?.toDouble() ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                child: Container(
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: CrmTheme.primaryColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '$count deals · \$${amount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CrmTheme.primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              );

              final sourcesCard = Container(
                padding: const EdgeInsets.all(20),
                decoration: CrmTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lead Source Conversion Efficiency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (sourceBreakdown.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No lead source records yet')))
                    else
                      ...sourceBreakdown.map((sb) {
                        final src = sb['source']?.toString() ?? 'other';
                        final total = (sb['total'] as num?)?.toInt() ?? 0;
                        final conv = (sb['converted'] as num?)?.toInt() ?? 0;
                        final rate = (sb['conversionRate'] as num?)?.toDouble() ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(src.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('$conv/$total converted (${rate.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: total > 0 ? (conv / total).clamp(0.0, 1.0) : 0,
                                  minHeight: 6,
                                  backgroundColor: CrmTheme.borderLight,
                                  valueColor: const AlwaysStoppedAnimation<Color>(CrmTheme.emerald),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: funnelCard),
                    const SizedBox(width: 20),
                    Expanded(child: sourcesCard),
                  ],
                );
              }
              return Column(
                children: [
                  funnelCard,
                  const SizedBox(height: 20),
                  sourcesCard,
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Row 2: Sales Team Performance Table
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CrmTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sales Representative Win Rates & Revenue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                if (repPerformance.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No rep performance data recorded yet')))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(CrmTheme.bgLight),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('Sales Representative', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Total Deals Handled', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Deals Won', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Won Revenue Generated', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Win Rate %', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: repPerformance.map((rp) {
                        final rate = (rp['winRate'] as num?)?.toDouble() ?? 0.0;
                        return DataRow(cells: [
                          DataCell(Text(rp['name']?.toString() ?? 'Representative', style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(rp['dealsCount']?.toString() ?? '0')),
                          DataCell(Text(rp['wonCount']?.toString() ?? '0', style: const TextStyle(color: CrmTheme.emerald, fontWeight: FontWeight.bold))),
                          DataCell(Text('\$${(rp['wonRevenue'] as num?)?.toStringAsFixed(0) ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('${rate.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: rate >= 50 ? CrmTheme.emerald : CrmTheme.amber))),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

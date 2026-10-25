// lib/Screens/crm/crm_cases_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmCasesScreen extends StatefulWidget {
  const CrmCasesScreen({Key? key}) : super(key: key);

  @override
  State<CrmCasesScreen> createState() => _CrmCasesScreenState();
}

class _CrmCasesScreenState extends State<CrmCasesScreen> {
  bool _isLoading = true;
  List<CrmCase> _cases = [];
  Map<String, dynamic> _pagination = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatus = '';
  String _selectedPriority = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await CrmApiService.getCases(
      search: _searchCtrl.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      page: _currentPage,
    );
    if (mounted) {
      setState(() {
        _cases = res['cases'] as List<CrmCase>;
        _pagination = res['pagination'] as Map<String, dynamic>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmHeader(
            title: 'Customer Support / Cases',
            subtitle: 'Manage client issue tickets, resolution workflows, and support requests.',
            icon: Icons.support_agent_outlined,
            onRefresh: _loadData,
            actionLabel: 'New Support Case',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showCaseDialog(context);
              if (ok == true) _loadData();
            },
          ),

          // Filter bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CrmTheme.cardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _loadData(),
                    decoration: CrmTheme.inputDecoration(
                      hintText: 'Search cases by title or case ID...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: CrmTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Statuses'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Statuses')),
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'waiting_customer', child: Text('Waiting')),
                      DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                      DropdownMenuItem(value: 'closed', child: Text('Closed')),
                    ],
                    onChanged: (v) {
                      _selectedStatus = v ?? '';
                      _currentPage = 1;
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _currentPage = 1;
                    _loadData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CrmTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cases Table
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _cases.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'No Support Cases Found',
                        message: 'Log incoming tickets and track customer resolution times.',
                        actionLabel: 'Log Case',
                        onAction: () async {
                          final ok = await CrmDialogs.showCaseDialog(context);
                          if (ok == true) _loadData();
                        },
                      )
                    : Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(CrmTheme.bgLight),
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('Case ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Created Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _cases.map((c) {
                                return DataRow(cells: [
                                  DataCell(Text(c.caseId, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                                  DataCell(Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(c.type.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                  DataCell(CrmBadge.priority(c.priority)),
                                  DataCell(CrmBadge.status(c.status)),
                                  DataCell(Text('${c.createdAt.month}/${c.createdAt.day}/${c.createdAt.year}')),
                                  DataCell(
                                    PopupMenuButton<String>(
                                      tooltip: 'Update Status',
                                      icon: const Icon(Icons.more_vert, size: 18),
                                      onSelected: (st) async {
                                        await CrmApiService.updateCase(c.id, {'status': st});
                                        _loadData();
                                      },
                                      itemBuilder: (ctx) => const [
                                        PopupMenuItem(value: 'open', child: Text('Mark Open')),
                                        PopupMenuItem(value: 'in_progress', child: Text('Mark In Progress')),
                                        PopupMenuItem(value: 'resolved', child: Text('Mark Resolved ✅', style: TextStyle(color: CrmTheme.emerald))),
                                        PopupMenuItem(value: 'closed', child: Text('Close Case')),
                                      ],
                                    ),
                                  ),
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

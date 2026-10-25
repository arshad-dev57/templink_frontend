// lib/Screens/crm/crm_leads_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmLeadsScreen extends StatefulWidget {
  const CrmLeadsScreen({Key? key}) : super(key: key);

  @override
  State<CrmLeadsScreen> createState() => _CrmLeadsScreenState();
}

class _CrmLeadsScreenState extends State<CrmLeadsScreen> {
  bool _isLoading = true;
  List<CrmLead> _leads = [];
  Map<String, dynamic> _pagination = {};
  List<CrmTeamMember> _teamMembers = [];

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
    final results = await Future.wait([
      CrmApiService.getLeads(
        search: _searchCtrl.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        page: _currentPage,
        limit: 12,
      ),
      CrmApiService.getTeamMembers(),
    ]);

    if (mounted) {
      final res = results[0] as Map<String, dynamic>;
      setState(() {
        _leads = res['leads'] as List<CrmLead>;
        _pagination = res['pagination'] as Map<String, dynamic>;
        _teamMembers = results[1] as List<CrmTeamMember>;
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
            title: 'Leads Management',
            subtitle: 'Capture, qualify, assign, and convert sales leads into active customers.',
            icon: Icons.filter_alt_outlined,
            onRefresh: _loadData,
            actionLabel: 'Add Lead',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showLeadDialog(context, teamMembers: _teamMembers);
              if (ok == true) {
                _loadData();
              } else if (ok == false) {
                if (mounted) {
                  Get.snackbar(
                    'Save Failed',
                    'Could not create the lead. Please try again.',
                    backgroundColor: CrmTheme.rose,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 3),
                  );
                }
              }
            },
          ),

          // Filters Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CrmTheme.cardDecoration,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) {
                      _currentPage = 1;
                      _loadData();
                    },
                    decoration: CrmTheme.inputDecoration(
                      hintText: 'Search leads by name, email, company...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: CrmTheme.textMuted),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Statuses'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Statuses')),
                      DropdownMenuItem(value: 'new', child: Text('New')),
                      DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
                      DropdownMenuItem(value: 'qualified', child: Text('Qualified')),
                      DropdownMenuItem(value: 'converted', child: Text('Converted')),
                      DropdownMenuItem(value: 'lost', child: Text('Lost')),
                    ],
                    onChanged: (v) {
                      _selectedStatus = v ?? '';
                      _currentPage = 1;
                      _loadData();
                    },
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Priorities'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Priorities')),
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                    ],
                    onChanged: (v) {
                      _selectedPriority = v ?? '';
                      _currentPage = 1;
                      _loadData();
                    },
                  ),
                ),
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
                if (_searchCtrl.text.isNotEmpty || _selectedStatus.isNotEmpty || _selectedPriority.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      _selectedStatus = '';
                      _selectedPriority = '';
                      _currentPage = 1;
                      _loadData();
                    },
                    child: const Text('Reset', style: TextStyle(color: CrmTheme.rose)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Main Table / List
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)),
                  )
                : _leads.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: 'No Leads Found',
                        message: 'No leads matched your filter criteria or you have not created any leads yet.',
                        actionLabel: 'Create Lead',
                        onAction: () async {
                          final ok = await CrmDialogs.showLeadDialog(context, teamMembers: _teamMembers);
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
                                DataColumn(label: Text('Lead ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Est. Value', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _leads.map((lead) {
                                return DataRow(cells: [
                                  DataCell(Text(lead.leadId, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(lead.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (lead.email.isNotEmpty)
                                          Text(lead.email, style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(lead.company.isNotEmpty ? lead.company : '—')),
                                  DataCell(CrmBadge.status(lead.status)),
                                  DataCell(CrmBadge.priority(lead.priority)),
                                  DataCell(Text(lead.estimatedDealValue > 0 ? '\$${lead.estimatedDealValue.toStringAsFixed(0)}' : '—')),
                                  DataCell(Text(lead.assignedTo?.fullName ?? 'Unassigned')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!lead.isConverted)
                                          IconButton(
                                            icon: const Icon(Icons.transform, size: 18, color: CrmTheme.emerald),
                                            tooltip: 'Convert Lead to Contact & Deal',
                                            onPressed: () async {
                                              final ok = await CrmDialogs.showConvertLeadDialog(context, lead);
                                              if (ok == true) {
                                                Get.snackbar('Converted', 'Lead successfully converted to Contact & Deal', backgroundColor: CrmTheme.emeraldSoft);
                                                _loadData();
                                              }
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: CrmTheme.sky),
                                          tooltip: 'Edit',
                                          onPressed: () async {
                                            final ok = await CrmDialogs.showLeadDialog(context, lead: lead, teamMembers: _teamMembers);
                                            if (ok == true) _loadData();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                                          tooltip: 'Delete',
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Lead'),
                                                content: Text('Are you sure you want to delete "${lead.name}"?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    style: ElevatedButton.styleFrom(backgroundColor: CrmTheme.rose, foregroundColor: Colors.white),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await CrmApiService.deleteLead(lead.id);
                                              _loadData();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                          // Pagination Controls
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${_leads.length} of ${_pagination['totalItems'] ?? _leads.length} leads',
                                  style: const TextStyle(fontSize: 13, color: CrmTheme.textSecondary),
                                ),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: _currentPage > 1
                                          ? () {
                                              setState(() => _currentPage--);
                                              _loadData();
                                            }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      child: const Text('Previous'),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Page $_currentPage of ${_pagination['totalPages'] ?? 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: _currentPage < (_pagination['totalPages'] ?? 1)
                                          ? () {
                                              setState(() => _currentPage++);
                                              _loadData();
                                            }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      child: const Text('Next'),
                                    ),
                                  ],
                                ),
                              ],
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

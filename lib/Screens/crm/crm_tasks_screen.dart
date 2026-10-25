// lib/Screens/crm/crm_tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmTasksScreen extends StatefulWidget {
  const CrmTasksScreen({Key? key}) : super(key: key);

  @override
  State<CrmTasksScreen> createState() => _CrmTasksScreenState();
}

class _CrmTasksScreenState extends State<CrmTasksScreen> {
  bool _isLoading = true;
  List<CrmActivity> _activities = [];
  List<CrmTeamMember> _teamMembers = [];
  Map<String, dynamic> _pagination = {};

  String _selectedType = '';
  String _selectedStatus = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      CrmApiService.getActivities(
        activityType: _selectedType,
        status: _selectedStatus,
        page: _currentPage,
        limit: 15,
      ),
      CrmApiService.getTeamMembers(),
    ]);

    if (mounted) {
      final res = results[0] as Map<String, dynamic>;
      setState(() {
        _activities = res['activities'] as List<CrmActivity>;
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
            title: 'Tasks & Activities',
            subtitle: 'Schedule follow-up tasks, client actions, assignments, and deadlines.',
            icon: Icons.check_circle_outline,
            onRefresh: _loadData,
            actionLabel: 'New Activity',
            actionIcon: Icons.add_task,
            onAction: () async {
              final ok = await CrmDialogs.showActivityDialog(context, teamMembers: _teamMembers);
              if (ok == true) _loadData();
            },
          ),

          // Filters Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CrmTheme.cardDecoration,
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Types'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Types')),
                      DropdownMenuItem(value: 'task', child: Text('Tasks')),
                      DropdownMenuItem(value: 'call', child: Text('Calls')),
                      DropdownMenuItem(value: 'meeting', child: Text('Meetings')),
                      DropdownMenuItem(value: 'follow_up', child: Text('Follow-ups')),
                    ],
                    onChanged: (v) {
                      _selectedType = v ?? '';
                      _currentPage = 1;
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Statuses'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Statuses')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (v) {
                      _selectedStatus = v ?? '';
                      _currentPage = 1;
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
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

          // Table / List
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _activities.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.task_alt_outlined,
                        title: 'No Activities',
                        message: 'Keep your sales momentum going by setting follow-ups and action items.',
                        actionLabel: 'Add Task',
                        onAction: () async {
                          final ok = await CrmDialogs.showActivityDialog(context, teamMembers: _teamMembers);
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
                                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Activity Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Assigned Member', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _activities.map((act) {
                                return DataRow(cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Icon(
                                          act.activityType == 'meeting'
                                              ? Icons.videocam_outlined
                                              : (act.activityType == 'call' ? Icons.phone_outlined : Icons.check_box_outlined),
                                          size: 16,
                                          color: CrmTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(act.activityType.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(act.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (act.description.isNotEmpty)
                                          Text(act.description, style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary), maxLines: 1),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${act.dueDate.month}/${act.dueDate.day}/${act.dueDate.year}',
                                      style: TextStyle(
                                        color: act.isOverdue ? CrmTheme.rose : CrmTheme.textPrimary,
                                        fontWeight: act.isOverdue ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  DataCell(CrmBadge.priority(act.priority)),
                                  DataCell(CrmBadge.status(act.status)),
                                  DataCell(Text(act.assignedTo?.fullName ?? 'Unassigned')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (act.status != 'completed')
                                          IconButton(
                                            icon: const Icon(Icons.check_circle, size: 20, color: CrmTheme.emerald),
                                            tooltip: 'Mark Complete',
                                            onPressed: () async {
                                              await CrmApiService.updateActivityStatus(act.id, 'completed');
                                              _loadData();
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                                          tooltip: 'Delete',
                                          onPressed: () async {
                                            await CrmApiService.deleteActivity(act.id);
                                            _loadData();
                                          },
                                        ),
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

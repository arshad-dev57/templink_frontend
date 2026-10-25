// lib/Screens/crm/crm_meetings_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CrmMeetingsScreen extends StatefulWidget {
  const CrmMeetingsScreen({Key? key}) : super(key: key);

  @override
  State<CrmMeetingsScreen> createState() => _CrmMeetingsScreenState();
}

class _CrmMeetingsScreenState extends State<CrmMeetingsScreen> {
  bool _isLoading = true;
  List<CrmActivity> _items = [];
  String _selectedFilter = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await CrmApiService.getMeetingsAndCalls(type: _selectedFilter);
    if (mounted) {
      setState(() {
        _items = res['items'] as List<CrmActivity>;
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
            title: 'Meetings & Calls',
            subtitle: 'Log outbound customer calls, discovery meetings, product demos, and client reviews.',
            icon: Icons.video_call_outlined,
            onRefresh: _loadData,
            actionLabel: 'Schedule Meeting',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showActivityDialog(context, defaultType: 'meeting');
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
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Meetings & Calls'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Events')),
                      DropdownMenuItem(value: 'meeting', child: Text('Video & In-Person Meetings')),
                      DropdownMenuItem(value: 'call', child: Text('Phone Calls')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedFilter = v ?? '');
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await CrmDialogs.showActivityDialog(context, defaultType: 'call');
                    if (ok == true) _loadData();
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Log Phone Call'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: CrmTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Table / Cards
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _items.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.videocam_off_outlined,
                        title: 'No Meetings or Calls',
                        message: 'Schedule client demo calls and meetings to keep records updated.',
                        actionLabel: 'Schedule Meeting',
                        onAction: () async {
                          final ok = await CrmDialogs.showActivityDialog(context, defaultType: 'meeting');
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
                                DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Scheduled Date & Time', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Meeting Link / Details', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _items.map((item) {
                                return DataRow(cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Icon(item.activityType == 'meeting' ? Icons.videocam : Icons.phone, size: 16, color: CrmTheme.primaryColor),
                                        const SizedBox(width: 6),
                                        Text(item.activityType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text('${item.dueDate.month}/${item.dueDate.day}/${item.dueDate.year}')),
                                  DataCell(Text('${item.durationMinutes} min')),
                                  DataCell(CrmBadge.status(item.status)),
                                  DataCell(
                                    item.meetingLink.isNotEmpty
                                        ? InkWell(
                                            onTap: () async {
                                              final uri = Uri.tryParse(item.meetingLink);
                                              if (uri != null) launchUrl(uri);
                                            },
                                            child: const Text('Join Link 🔗', style: TextStyle(color: CrmTheme.sky, decoration: TextDecoration.underline)),
                                          )
                                        : Text(item.location.isNotEmpty ? item.location : '—'),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (item.status != 'completed')
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline, size: 18, color: CrmTheme.emerald),
                                            tooltip: 'Mark Completed',
                                            onPressed: () async {
                                              await CrmApiService.updateActivityStatus(item.id, 'completed');
                                              _loadData();
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                                          tooltip: 'Delete',
                                          onPressed: () async {
                                            await CrmApiService.deleteActivity(item.id);
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

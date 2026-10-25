// lib/Screens/crm/crm_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmSettingsScreen extends StatefulWidget {
  const CrmSettingsScreen({Key? key}) : super(key: key);

  @override
  State<CrmSettingsScreen> createState() => _CrmSettingsScreenState();
}

class _CrmSettingsScreenState extends State<CrmSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, dynamic> _settings = {};
  List<CrmTeamMember> _teamMembers = [];
  String _defaultCurrency = 'USD';

  List<Map<String, dynamic>> _pipelineStages = [];
  List<Map<String, dynamic>> _employeePermissions = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      CrmApiService.getSettings(),
      CrmApiService.getTeamMembers(),
    ]);

    if (mounted) {
      final s = results[0] as Map<String, dynamic>;
      final tm = results[1] as List<CrmTeamMember>;

      final stages = (s['pipelineStages'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];

      final perms = (s['employeePermissions'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];

      // Ensure every team member has an entry in permissions
      for (var member in tm) {
        if (member.role == 'employee') {
          final exists = perms.any((p) => p['employeeId']?.toString() == member.id);
          if (!exists) {
            perms.add({
              'employeeId': member.id,
              'name': member.fullName,
              'canViewAllLeads': false,
              'canCreateLeads': true,
              'canEditLeads': true,
              'canDeleteLeads': false,
              'canViewDeals': true,
              'canManageDeals': true,
              'canViewReports': false,
              'canManageSettings': false,
            });
          }
        }
      }

      setState(() {
        _settings = s;
        _teamMembers = tm;
        _defaultCurrency = s['defaultCurrency']?.toString() ?? 'USD';
        _pipelineStages = stages;
        _employeePermissions = perms;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final ok = await CrmApiService.updateSettings({
      'defaultCurrency': _defaultCurrency,
      'pipelineStages': _pipelineStages,
      'employeePermissions': _employeePermissions,
    });

    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        Get.snackbar('Success', 'CRM settings and permissions saved successfully!', backgroundColor: CrmTheme.emeraldSoft);
      } else {
        Get.snackbar('Error', 'Failed to save settings. Please verify permissions.', backgroundColor: CrmTheme.roseSoft);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmHeader(
            title: 'CRM Settings & Authorization',
            subtitle: 'Configure sales stages, currency preferences, and granular employee access permissions.',
            icon: Icons.settings_suggest_outlined,
            onRefresh: _loadSettings,
            actionLabel: _isSaving ? 'Saving...' : 'Save Settings',
            actionIcon: Icons.save_outlined,
            onAction: _isSaving ? null : _saveSettings,
          ),

          // Section 1: General Preferences
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CrmTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('General Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: DropdownButtonFormField<String>(
                    value: _defaultCurrency,
                    decoration: CrmTheme.inputDecoration(hintText: 'Default Currency', labelText: 'Default Currency'),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar (\$)')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro (€)')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound (£)')),
                      DropdownMenuItem(value: 'AED', child: Text('AED - UAE Dirham')),
                      DropdownMenuItem(value: 'CAD', child: Text('CAD - Canadian Dollar')),
                    ],
                    onChanged: (v) => setState(() => _defaultCurrency = v ?? 'USD'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Pipeline Stages
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CrmTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sales Pipeline Stages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Configurable stages and default close probability % for deals:', style: TextStyle(fontSize: 13, color: CrmTheme.textSecondary)),
                const SizedBox(height: 16),
                ..._pipelineStages.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final stage = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CrmTheme.bgLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CrmTheme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: CrmTheme.border, borderRadius: BorderRadius.circular(4)),
                          child: Text('#${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: stage['name']?.toString() ?? '',
                            decoration: const InputDecoration(isDense: true, labelText: 'Stage Name'),
                            onChanged: (v) => stage['name'] = v,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            initialValue: stage['probability']?.toString() ?? '20',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(isDense: true, labelText: 'Probability %'),
                            onChanged: (v) => stage['probability'] = int.tryParse(v) ?? 20,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Employee CRM Permissions Matrix
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CrmTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Employee Access Control & Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Enforce server-validated permissions for each team member working in CRM:', style: TextStyle(fontSize: 13, color: CrmTheme.textSecondary)),
                const SizedBox(height: 16),
                if (_employeePermissions.isEmpty)
                  const Text('No employees found on team.', style: TextStyle(color: CrmTheme.textMuted))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(CrmTheme.bgLight),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('Employee', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('View All Leads', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Create Leads', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Edit Leads', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Delete Leads', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Manage Deals', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('View Reports', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Manage Settings', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _employeePermissions.map((perm) {
                        final empId = perm['employeeId']?.toString();
                        final member = _teamMembers.firstWhereOrNull((m) => m.id == empId);
                        final name = member?.fullName ?? perm['name'] ?? 'Employee';

                        return DataRow(cells: [
                          DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Checkbox(
                            value: perm['canViewAllLeads'] == true,
                            activeColor: CrmTheme.primaryColor,
                            onChanged: (v) => setState(() => perm['canViewAllLeads'] = v!),
                          )),
                          DataCell(Checkbox(
                            value: perm['canCreateLeads'] == true,
                            activeColor: CrmTheme.primaryColor,
                            onChanged: (v) => setState(() => perm['canCreateLeads'] = v!),
                          )),
                          DataCell(Checkbox(
                            value: perm['canEditLeads'] == true,
                            activeColor: CrmTheme.primaryColor,
                            onChanged: (v) => setState(() => perm['canEditLeads'] = v!),
                          )),
                          DataCell(Checkbox(
                            value: perm['canDeleteLeads'] == true,
                            activeColor: CrmTheme.primaryColor,
                            onChanged: (v) => setState(() => perm['canDeleteLeads'] = v!),
                          )),
                          DataCell(Checkbox(
                            value: perm['canManageDeals'] == true,
                            activeColor: CrmTheme.primaryColor,
                            onChanged: (v) => setState(() => perm['canManageDeals'] = v!),
                          )),
                          DataCell(Checkbox(
                            value: perm['canViewReports'] == true,
                            activeColor: CrmTheme.primaryColor,
                            onChanged: (v) => setState(() => perm['canViewReports'] = v!),
                          )),
                          DataCell(Checkbox(
                            value: perm['canManageSettings'] == true,
                            activeColor: CrmTheme.primaryColor,
                            onChanged: (v) => setState(() => perm['canManageSettings'] = v!),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSettings,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(_isSaving ? 'Saving...' : 'Apply & Save Permissions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CrmTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
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

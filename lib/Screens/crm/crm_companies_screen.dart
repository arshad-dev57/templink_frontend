// lib/Screens/crm/crm_companies_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmCompaniesScreen extends StatefulWidget {
  const CrmCompaniesScreen({Key? key}) : super(key: key);

  @override
  State<CrmCompaniesScreen> createState() => _CrmCompaniesScreenState();
}

class _CrmCompaniesScreenState extends State<CrmCompaniesScreen> {
  bool _isLoading = true;
  List<CrmCompany> _companies = [];
  Map<String, dynamic> _pagination = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedType = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await CrmApiService.getCompanies(
      search: _searchCtrl.text.trim(),
      type: _selectedType,
      page: _currentPage,
      limit: 12,
    );

    if (mounted) {
      setState(() {
        _companies = res['companies'] as List<CrmCompany>;
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
            title: 'Companies & Accounts',
            subtitle: 'Target customer accounts, partner organizations, and business client records.',
            icon: Icons.business_outlined,
            onRefresh: _loadData,
            actionLabel: 'New Company',
            actionIcon: Icons.add_business_outlined,
            onAction: () async {
              final ok = await CrmDialogs.showCompanyDialog(context);
              if (ok == true) _loadData();
            },
          ),

          // Filters Card
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
                      hintText: 'Search companies by name, website, industry...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: CrmTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Types'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Types')),
                      DropdownMenuItem(value: 'prospect', child: Text('Prospect')),
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                      DropdownMenuItem(value: 'partner', child: Text('Partner')),
                      DropdownMenuItem(value: 'vendor', child: Text('Vendor')),
                    ],
                    onChanged: (v) {
                      _selectedType = v ?? '';
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

          // Companies Table
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _companies.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.business_center_outlined,
                        title: 'No Companies Found',
                        message: 'Track organizations and enterprise accounts you do business with.',
                        actionLabel: 'Add Company',
                        onAction: () async {
                          final ok = await CrmDialogs.showCompanyDialog(context);
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
                                DataColumn(label: Text('Company ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Website', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Industry', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Annual Revenue', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Account Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _companies.map((company) {
                                return DataRow(cells: [
                                  DataCell(Text(company.companyId, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                                  DataCell(Text(company.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(company.website.isNotEmpty ? company.website : '—', style: const TextStyle(color: CrmTheme.sky))),
                                  DataCell(Text(company.industry.isNotEmpty ? company.industry : '—')),
                                  DataCell(Text(company.annualRevenue > 0 ? '\$${company.annualRevenue.toStringAsFixed(0)}' : '—')),
                                  DataCell(CrmBadge.status(company.type)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: CrmTheme.sky),
                                          onPressed: () async {
                                            final ok = await CrmDialogs.showCompanyDialog(context, company: company);
                                            if (ok == true) _loadData();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Company'),
                                                content: Text('Delete company "${company.name}"?'),
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
                                              await CrmApiService.deleteCompany(company.id);
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
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

// lib/Screens/crm/crm_contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmContactsScreen extends StatefulWidget {
  const CrmContactsScreen({Key? key}) : super(key: key);

  @override
  State<CrmContactsScreen> createState() => _CrmContactsScreenState();
}

class _CrmContactsScreenState extends State<CrmContactsScreen> {
  bool _isLoading = true;
  List<CrmContact> _contacts = [];
  List<CrmCompany> _companies = [];
  Map<String, dynamic> _pagination = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStage = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      CrmApiService.getContacts(
        search: _searchCtrl.text.trim(),
        lifecycleStage: _selectedStage,
        page: _currentPage,
        limit: 12,
      ),
      CrmApiService.getCompanies(limit: 100),
    ]);

    if (mounted) {
      final res = results[0] as Map<String, dynamic>;
      final comps = results[1] as Map<String, dynamic>;
      setState(() {
        _contacts = res['contacts'] as List<CrmContact>;
        _pagination = res['pagination'] as Map<String, dynamic>;
        _companies = comps['companies'] as List<CrmCompany>;
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
            title: 'Contacts Directory',
            subtitle: 'Central directory of individual business contacts, decision makers, and champions.',
            icon: Icons.people_alt_outlined,
            onRefresh: _loadData,
            actionLabel: 'New Contact',
            actionIcon: Icons.person_add_outlined,
            onAction: () async {
              final ok = await CrmDialogs.showContactDialog(context, companies: _companies);
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
                      hintText: 'Search contacts by name, email, phone, job title...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: CrmTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: DropdownButtonFormField<String>(
                    value: _selectedStage,
                    decoration: CrmTheme.inputDecoration(hintText: 'All Stages'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Stages')),
                      DropdownMenuItem(value: 'lead', child: Text('Lead')),
                      DropdownMenuItem(value: 'subscriber', child: Text('Subscriber')),
                      DropdownMenuItem(value: 'opportunity', child: Text('Opportunity')),
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                    ],
                    onChanged: (v) {
                      _selectedStage = v ?? '';
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

          // Contacts Table
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _contacts.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.person_off_outlined,
                        title: 'No Contacts Found',
                        message: 'Build your customer contact list by adding key individuals and decision makers.',
                        actionLabel: 'Add Contact',
                        onAction: () async {
                          final ok = await CrmDialogs.showContactDialog(context, companies: _companies);
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
                                DataColumn(label: Text('Contact ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Email & Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Job Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Lifecycle Stage', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _contacts.map((contact) {
                                return DataRow(cells: [
                                  DataCell(Text(contact.contactId, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                                  DataCell(Text(contact.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (contact.email.isNotEmpty) Text(contact.email, style: const TextStyle(fontSize: 12)),
                                        if (contact.phone.isNotEmpty) Text(contact.phone, style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(contact.jobTitle.isNotEmpty ? contact.jobTitle : '—')),
                                  DataCell(Text(contact.companyName.isNotEmpty ? contact.companyName : '—')),
                                  DataCell(CrmBadge.status(contact.lifecycleStage)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: CrmTheme.sky),
                                          onPressed: () async {
                                            final ok = await CrmDialogs.showContactDialog(context, contact: contact, companies: _companies);
                                            if (ok == true) _loadData();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Contact'),
                                                content: Text('Delete contact "${contact.fullName}"?'),
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
                                              await CrmApiService.deleteContact(contact.id);
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

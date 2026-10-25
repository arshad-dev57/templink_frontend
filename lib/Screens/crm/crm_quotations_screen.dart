// lib/Screens/crm/crm_quotations_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmQuotationsScreen extends StatefulWidget {
  const CrmQuotationsScreen({Key? key}) : super(key: key);

  @override
  State<CrmQuotationsScreen> createState() => _CrmQuotationsScreenState();
}

class _CrmQuotationsScreenState extends State<CrmQuotationsScreen> {
  bool _isLoading = true;
  List<CrmQuotation> _quotations = [];
  Map<String, dynamic> _pagination = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedStatus = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await CrmApiService.getQuotations(
      search: _searchCtrl.text.trim(),
      status: _selectedStatus,
      page: _currentPage,
    );
    if (mounted) {
      setState(() {
        _quotations = res['quotations'] as List<CrmQuotation>;
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
            title: 'Quotations & Proposals',
            subtitle: 'Generate pricing quotations, customer proposals, and line-item estimates.',
            icon: Icons.request_quote_outlined,
            onRefresh: _loadData,
            actionLabel: 'New Proposal',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showQuotationDialog(context);
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
                      hintText: 'Search quotations by number or title...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: CrmTheme.textMuted),
                    ),
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
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(value: 'sent', child: Text('Sent')),
                      DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                      DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                      DropdownMenuItem(value: 'expired', child: Text('Expired')),
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

          // Quotations Table
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _quotations.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.description_outlined,
                        title: 'No Quotations Found',
                        message: 'Build itemized commercial proposals with taxes, discounts, and terms.',
                        actionLabel: 'Create Quotation',
                        onAction: () async {
                          final ok = await CrmDialogs.showQuotationDialog(context);
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
                                DataColumn(label: Text('Quote #', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Client / Company', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Items', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _quotations.map((q) {
                                return DataRow(cells: [
                                  DataCell(Text(q.quoteNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                                  DataCell(Text(q.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (q.companyName.isNotEmpty) Text(q.companyName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        if (q.contactName.isNotEmpty) Text(q.contactName, style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text('${q.items.length} items')),
                                  DataCell(Text('\$${q.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.emerald))),
                                  DataCell(CrmBadge.status(q.status)),
                                  DataCell(
                                    PopupMenuButton<String>(
                                      tooltip: 'Update Status',
                                      icon: const Icon(Icons.more_vert, size: 18),
                                      onSelected: (st) async {
                                        await CrmApiService.updateQuotationStatus(q.id, st);
                                        _loadData();
                                      },
                                      itemBuilder: (ctx) => const [
                                        PopupMenuItem(value: 'sent', child: Text('Mark as Sent')),
                                        PopupMenuItem(value: 'accepted', child: Text('Mark Accepted 🎉', style: TextStyle(color: CrmTheme.emerald))),
                                        PopupMenuItem(value: 'rejected', child: Text('Mark Rejected', style: TextStyle(color: CrmTheme.rose))),
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

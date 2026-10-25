// lib/Screens/crm/crm_deals_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmDealsScreen extends StatefulWidget {
  const CrmDealsScreen({Key? key}) : super(key: key);

  @override
  State<CrmDealsScreen> createState() => _CrmDealsScreenState();
}

class _CrmDealsScreenState extends State<CrmDealsScreen> {
  bool _isLoading = true;
  List<CrmDeal> _deals = [];
  List<CrmCompany> _companies = [];
  List<CrmContact> _contacts = [];
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
      CrmApiService.getDeals(
        search: _searchCtrl.text.trim(),
        stage: _selectedStage,
        page: _currentPage,
        limit: 12,
      ),
      CrmApiService.getCompanies(limit: 100),
      CrmApiService.getContacts(limit: 100),
    ]);

    if (mounted) {
      final res = results[0] as Map<String, dynamic>;
      final comps = results[1] as Map<String, dynamic>;
      final conts = results[2] as Map<String, dynamic>;
      setState(() {
        _deals = res['deals'] as List<CrmDeal>;
        _pagination = res['pagination'] as Map<String, dynamic>;
        _companies = comps['companies'] as List<CrmCompany>;
        _contacts = conts['contacts'] as List<CrmContact>;
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
            title: 'Deals & Opportunities',
            subtitle: 'Track active sales negotiations, revenue forecasts, and opportunity stages.',
            icon: Icons.monetization_on_outlined,
            onRefresh: _loadData,
            actionLabel: 'New Deal',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showDealDialog(
                context,
                companies: _companies,
                contacts: _contacts,
              );
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
                      hintText: 'Search deals by title or ID...',
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
                      DropdownMenuItem(value: 'lead_in', child: Text('Lead In')),
                      DropdownMenuItem(value: 'contact_made', child: Text('Contact Made')),
                      DropdownMenuItem(value: 'needs_discovery', child: Text('Discovery')),
                      DropdownMenuItem(value: 'proposal_sent', child: Text('Proposal Sent')),
                      DropdownMenuItem(value: 'negotiation', child: Text('Negotiation')),
                      DropdownMenuItem(value: 'closed_won', child: Text('Closed Won')),
                      DropdownMenuItem(value: 'closed_lost', child: Text('Closed Lost')),
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

          // Deals Table
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _deals.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.paid_outlined,
                        title: 'No Deals Found',
                        message: 'Log revenue opportunities and monitor stage progression.',
                        actionLabel: 'Create Deal',
                        onAction: () async {
                          final ok = await CrmDialogs.showDealDialog(context, companies: _companies, contacts: _contacts);
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
                                DataColumn(label: Text('Deal ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Stage', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Probability', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Company / Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Owner', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _deals.map((deal) {
                                return DataRow(cells: [
                                  DataCell(Text(deal.dealId, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                                  DataCell(Text(deal.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text('\$${deal.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(CrmBadge.status(deal.stage)),
                                  DataCell(Text('${deal.probability.toStringAsFixed(0)}%')),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (deal.companyName.isNotEmpty) Text(deal.companyName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        if (deal.contactName.isNotEmpty) Text(deal.contactName, style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(deal.assignedTo?.fullName ?? 'Unassigned')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PopupMenuButton<String>(
                                          tooltip: 'Change Stage',
                                          icon: const Icon(Icons.arrow_drop_down_circle_outlined, size: 18, color: CrmTheme.primaryColor),
                                          onSelected: (newStage) async {
                                            await CrmApiService.updateDealStage(deal.id, newStage);
                                            _loadData();
                                          },
                                          itemBuilder: (ctx) => [
                                            const PopupMenuItem(value: 'lead_in', child: Text('Lead In')),
                                            const PopupMenuItem(value: 'contact_made', child: Text('Contact Made')),
                                            const PopupMenuItem(value: 'needs_discovery', child: Text('Needs Discovery')),
                                            const PopupMenuItem(value: 'proposal_sent', child: Text('Proposal Sent')),
                                            const PopupMenuItem(value: 'negotiation', child: Text('Negotiation')),
                                            const PopupMenuItem(value: 'closed_won', child: Text('Closed Won 🎉', style: TextStyle(color: CrmTheme.emerald, fontWeight: FontWeight.bold))),
                                            const PopupMenuItem(value: 'closed_lost', child: Text('Closed Lost', style: TextStyle(color: CrmTheme.rose))),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: CrmTheme.sky),
                                          onPressed: () async {
                                            final ok = await CrmDialogs.showDealDialog(context, deal: deal, companies: _companies, contacts: _contacts);
                                            if (ok == true) _loadData();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Deal'),
                                                content: Text('Delete deal "${deal.title}"?'),
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
                                              await CrmApiService.deleteDeal(deal.id);
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

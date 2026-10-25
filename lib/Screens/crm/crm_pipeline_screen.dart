// lib/Screens/crm/crm_pipeline_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmPipelineScreen extends StatefulWidget {
  const CrmPipelineScreen({Key? key}) : super(key: key);

  @override
  State<CrmPipelineScreen> createState() => _CrmPipelineScreenState();
}

class _CrmPipelineScreenState extends State<CrmPipelineScreen> {
  bool _isLoading = true;
  List<CrmPipelineColumn> _columns = [];

  @override
  void initState() {
    super.initState();
    _loadPipeline();
  }

  Future<void> _loadPipeline() async {
    setState(() => _isLoading = true);
    final columns = await CrmApiService.getSalesPipeline();
    if (mounted) {
      setState(() {
        _columns = columns;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmHeader(
            title: 'Visual Sales Pipeline',
            subtitle: 'Kanban view of deals across qualification, negotiation, and closing stages.',
            icon: Icons.view_column_outlined,
            onRefresh: _loadPipeline,
            actionLabel: 'New Deal',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showDealDialog(context);
              if (ok == true) _loadPipeline();
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor))
                : _columns.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.view_kanban_outlined,
                        title: 'No Pipeline Data',
                        message: 'Your pipeline stages are empty. Create deals to populate the sales board.',
                        actionLabel: 'Create Deal',
                        onAction: () async {
                          final ok = await CrmDialogs.showDealDialog(context);
                          if (ok == true) _loadPipeline();
                        },
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _columns.map((col) => _buildColumn(col)).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(CrmPipelineColumn col) {
    Color colColor = CrmTheme.primaryColor;
    if (col.id == 'closed_won') colColor = CrmTheme.emerald;
    if (col.id == 'closed_lost') colColor = CrmTheme.rose;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: CrmTheme.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CrmTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: const Border(bottom: BorderSide(color: CrmTheme.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: colColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          col.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CrmTheme.borderLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        col.dealsCount.toString(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${col.totalAmount.toStringAsFixed(0)} (wt: \$${col.weightedAmount.toStringAsFixed(0)})',
                  style: const TextStyle(fontSize: 12, color: CrmTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Cards list
          Expanded(
            child: col.deals.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No deals in this stage', style: TextStyle(fontSize: 12, color: CrmTheme.textMuted)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: col.deals.length,
                    itemBuilder: (ctx, i) => _buildDealCard(col.deals[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealCard(CrmDeal deal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CrmTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(deal.dealId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CrmTheme.primaryColor)),
              PopupMenuButton<String>(
                tooltip: 'Move to Stage',
                icon: const Icon(Icons.more_horiz, size: 16, color: CrmTheme.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (newStage) async {
                  await CrmApiService.updateDealStage(deal.id, newStage);
                  _loadPipeline();
                },
                itemBuilder: (ctx) => _columns
                    .map((c) => PopupMenuItem(
                          value: c.id,
                          child: Text('Move to: ${c.name}'),
                        ))
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            deal.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CrmTheme.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          if (deal.companyName.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.business, size: 12, color: CrmTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    deal.companyName,
                    style: const TextStyle(fontSize: 11, color: CrmTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${deal.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CrmTheme.emerald),
              ),
              Text(
                '${deal.probability.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11, color: CrmTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

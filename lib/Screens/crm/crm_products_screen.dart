// lib/Screens/crm/crm_products_screen.dart
import 'package:flutter/material.dart';
import 'package:templink/Models/crm_models.dart';
import 'package:templink/Services/crm_api_service.dart';
import 'package:templink/widgets/crm/crm_badge.dart';
import 'package:templink/widgets/crm/crm_dialogs.dart';
import 'package:templink/widgets/crm/crm_empty_state.dart';
import 'package:templink/widgets/crm/crm_header.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmProductsScreen extends StatefulWidget {
  const CrmProductsScreen({Key? key}) : super(key: key);

  @override
  State<CrmProductsScreen> createState() => _CrmProductsScreenState();
}

class _CrmProductsScreenState extends State<CrmProductsScreen> {
  bool _isLoading = true;
  List<CrmProduct> _products = [];
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
    final res = await CrmApiService.getProducts(
      search: _searchCtrl.text.trim(),
      type: _selectedType,
      page: _currentPage,
    );
    if (mounted) {
      setState(() {
        _products = res['products'] as List<CrmProduct>;
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
            title: 'Products & Services',
            subtitle: 'Catalog of business offerings, billable services, SKUs, and standard pricing.',
            icon: Icons.inventory_2_outlined,
            onRefresh: _loadData,
            actionLabel: 'Add Product / Service',
            actionIcon: Icons.add,
            onAction: () async {
              final ok = await CrmDialogs.showProductDialog(context);
              if (ok == true) _loadData();
            },
          ),

          // Search & Filter
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
                      hintText: 'Search products by SKU or name...',
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
                      DropdownMenuItem(value: 'service', child: Text('Services')),
                      DropdownMenuItem(value: 'product', child: Text('Physical Products')),
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

          // Table
          Container(
            decoration: CrmTheme.cardDecoration,
            child: _isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: CrmTheme.primaryColor)))
                : _products.isEmpty
                    ? CrmEmptyState(
                        icon: Icons.inventory_outlined,
                        title: 'No Products in Catalog',
                        message: 'Add items and services to quickly populate quotations and deals.',
                        actionLabel: 'Add Offering',
                        onAction: () async {
                          final ok = await CrmDialogs.showProductDialog(context);
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
                                DataColumn(label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Offering Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _products.map((p) {
                                return DataRow(cells: [
                                  DataCell(Text(p.sku, style: const TextStyle(fontWeight: FontWeight.bold, color: CrmTheme.primaryColor))),
                                  DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(p.type.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                  DataCell(Text(p.category)),
                                  DataCell(Text('\$${p.unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(CrmBadge.status(p.isActive ? 'active' : 'inactive')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: CrmTheme.sky),
                                          onPressed: () async {
                                            final ok = await CrmDialogs.showProductDialog(context, product: p);
                                            if (ok == true) _loadData();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: CrmTheme.rose),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Delete Product'),
                                                content: Text('Delete "${p.name}"?'),
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
                                              await CrmApiService.deleteProduct(p.id);
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

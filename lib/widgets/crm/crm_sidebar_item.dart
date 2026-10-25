// lib/widgets/crm/crm_sidebar_item.dart
import 'package:flutter/material.dart';
import 'package:templink/widgets/crm/crm_theme.dart';

class CrmSubmenuItemDef {
  final int index;
  final String label;
  final IconData icon;

  const CrmSubmenuItemDef(this.index, this.label, this.icon);
}

const List<CrmSubmenuItemDef> kCrmSubmenuItems = [
  CrmSubmenuItemDef(0, 'CRM Dashboard', Icons.dashboard_outlined),
  CrmSubmenuItemDef(1, 'Leads', Icons.filter_alt_outlined),
  CrmSubmenuItemDef(2, 'Contacts', Icons.people_alt_outlined),
  CrmSubmenuItemDef(3, 'Companies / Accounts', Icons.business_outlined),
  CrmSubmenuItemDef(4, 'Deals / Opportunities', Icons.monetization_on_outlined),
  CrmSubmenuItemDef(5, 'Sales Pipeline', Icons.view_column_outlined),
  CrmSubmenuItemDef(6, 'Tasks & Activities', Icons.check_circle_outline),
  CrmSubmenuItemDef(7, 'Calendar & Follow-ups', Icons.calendar_month_outlined),
  CrmSubmenuItemDef(8, 'Meetings & Calls', Icons.video_call_outlined),
  CrmSubmenuItemDef(9, 'Notes', Icons.note_alt_outlined),
  CrmSubmenuItemDef(10, 'Email Communication', Icons.email_outlined),
  CrmSubmenuItemDef(11, 'Customer Support / Cases', Icons.support_agent_outlined),
  CrmSubmenuItemDef(12, 'Products & Services', Icons.inventory_2_outlined),
  CrmSubmenuItemDef(13, 'Quotations / Proposals', Icons.request_quote_outlined),
  CrmSubmenuItemDef(14, 'Reports & Analytics', Icons.analytics_outlined),
  CrmSubmenuItemDef(15, 'CRM Settings', Icons.settings_suggest_outlined),
];

class CrmSidebarItem extends StatelessWidget {
  final bool isExpanded;
  final bool isSubmenuOpen;
  final int selectedSubmenuIndex;
  final bool isCrmActive;
  final VoidCallback onToggleCrm;
  final Function(int) onSelectSubmenu;

  const CrmSidebarItem({
    Key? key,
    required this.isExpanded,
    required this.isSubmenuOpen,
    required this.selectedSubmenuIndex,
    required this.isCrmActive,
    required this.onToggleCrm,
    required this.onSelectSubmenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) {
      // Collapsed rail mode: Show single icon with popup menu for 16 submenus
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: PopupMenuButton<int>(
          tooltip: 'CRM System',
          icon: Icon(
            Icons.hub_outlined,
            color: isCrmActive ? CrmTheme.primaryColor : Colors.grey.shade500,
            size: 20,
          ),
          onSelected: onSelectSubmenu,
          itemBuilder: (ctx) => kCrmSubmenuItems.map((item) {
            final isSel = isCrmActive && selectedSubmenuIndex == item.index;
            return PopupMenuItem<int>(
              value: item.index,
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 18,
                    color: isSel ? CrmTheme.primaryColor : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? CrmTheme.primaryColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    // Expanded sidebar mode
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main CRM Header Row
          InkWell(
            onTap: onToggleCrm,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isCrmActive
                    ? CrmTheme.primaryColor.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hub_outlined,
                    color: isCrmActive ? CrmTheme.primaryColor : Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'CRM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCrmActive
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isCrmActive
                                ? CrmTheme.primaryColor
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: CrmTheme.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '16',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: CrmTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSubmenuOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),

          // Submenu items
          if (isSubmenuOpen) ...[
            const SizedBox(height: 2),
            Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isCrmActive
                        ? CrmTheme.primaryColor.withOpacity(0.3)
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: kCrmSubmenuItems.map((item) {
                  final isSel = isCrmActive && selectedSubmenuIndex == item.index;

                  return InkWell(
                    onTap: () => onSelectSubmenu(item.index),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel
                            ? CrmTheme.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 15,
                            color: isSel
                                ? CrmTheme.primaryColor
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSel
                                    ? CrmTheme.primaryColor
                                    : Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (isSel)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: CrmTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CrmDrawerItem extends StatefulWidget {
  final int selectedSubmenuIndex;
  final bool isCrmActive;
  final Function(int) onSelectSubmenu;

  const CrmDrawerItem({
    Key? key,
    required this.selectedSubmenuIndex,
    required this.isCrmActive,
    required this.onSelectSubmenu,
  }) : super(key: key);

  @override
  State<CrmDrawerItem> createState() => _CrmDrawerItemState();
}

class _CrmDrawerItemState extends State<CrmDrawerItem> {
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.isCrmActive;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: Icon(
            Icons.hub_outlined,
            color: widget.isCrmActive ? CrmTheme.primaryColor : Colors.grey.shade600,
            size: 20,
          ),
          title: Row(
            children: [
              Text(
                'CRM',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isCrmActive ? FontWeight.bold : FontWeight.w600,
                  color: widget.isCrmActive ? CrmTheme.primaryColor : Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: CrmTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '16 Modules',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: CrmTheme.primaryColor),
                ),
              ),
            ],
          ),
          trailing: Icon(
            _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.grey.shade400,
            size: 18,
          ),
          onTap: () => setState(() => _isOpen = !_isOpen),
        ),
        if (_isOpen)
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: kCrmSubmenuItems.map((item) {
                final isSel = widget.isCrmActive && widget.selectedSubmenuIndex == item.index;

                return ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  leading: Icon(
                    item.icon,
                    size: 16,
                    color: isSel ? CrmTheme.primaryColor : Colors.grey.shade500,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? CrmTheme.primaryColor : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    widget.onSelectSubmenu(item.index);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/proposal_controller.dart';
import 'package:templink/Employee/Screens/Employee_Contract_Screen.dart';
import 'package:templink/Models/proposals_model.dart';
import 'package:templink/Utils/colors.dart';

class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({Key? key}) : super(key: key);

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
  final ProposalController controller = Get.put(ProposalController());
  final TextEditingController searchController = TextEditingController();
  bool isGridView = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    controller.updateSearch(searchController.text);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'My Project Proposals',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.grey.shade200, height: 0.5),
        ),
        actions: [
          if (isWeb)
            Container(
              margin: const EdgeInsets.only(right: 16),
              height: 34,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _toggleButton(Icons.grid_view_rounded, 'Grid', true),
                  Container(width: 0.5, color: Colors.grey.shade300),
                  _toggleButton(Icons.table_rows_rounded, 'Table', false),
                ],
              ),
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          );
        }

        return Column(
          children: [
            // ── Single Compact Toolbar ──────────────────────────────
            _buildToolbar(isWeb),
            // ── Stats Bar ──────────────────────────────────────────
            _buildStatsBar(isWeb),
            const SizedBox(height: 4),
            // ── Content ────────────────────────────────────────────
            Expanded(
              child: isWeb
                  ? _buildWebLayout()
                  : _buildMobileLayout(),
            ),
          ],
        );
      }),
    );
  }

  // ─── Toggle Button ──────────────────────────────────────────────────
  Widget _toggleButton(IconData icon, String label, bool value) {
    final isActive = isGridView == value;
    return GestureDetector(
      onTap: () => setState(() => isGridView = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 34,
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(value ? const BorderRadius.only(
            topLeft: Radius.circular(7),
            bottomLeft: Radius.circular(7),
          ).topLeft.x : 0),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16,
                color: isActive ? Colors.black87 : Colors.grey.shade500),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Single Toolbar Row: Search + Sort + Tabs ────────────────────────
  Widget _buildToolbar(bool isWeb) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: isWeb ? 2 : 3,
            child: _buildSearchField(),
          ),
          if (isWeb) ...[
            const SizedBox(width: 10),
            // Sort
            _buildSortDropdown(),
          ],
          const SizedBox(width: 10),
          // Status Tabs (scrollable)
          Expanded(
            flex: isWeb ? 3 : 4,
            child: _buildStatusTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, color: Colors.grey, size: 16),
          ),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search proposals...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    searchController.clear();
                    controller.updateSearch('');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.close, size: 14, color: Colors.grey),
                  ),
                )
              : const SizedBox(width: 8)),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Obx(() => Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.sortBy.value,
              icon: const Icon(Icons.unfold_more, size: 16, color: Colors.grey),
              isDense: true,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              items: ['Date', 'Match Score', 'Budget']
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) controller.updateSortBy(v);
              },
            ),
          ),
        ));
  }

  Widget _buildStatusTabs() {
    return SizedBox(
      height: 36,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.statusTabs.length,
            itemBuilder: (context, index) {
              final status = controller.statusTabs[index];
              final isSelected = controller.selectedStatus.value == status;
              final count = controller.getCountByStatus(status);

              Color tabColor = _statusColor(status);

              return GestureDetector(
                onTap: () => controller.updateStatus(status),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? tabColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? tabColor : Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : tabColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : tabColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue.shade600;
      case 'accepted':
        return Colors.green.shade600;
      case 'rejected':
        return Colors.red.shade500;
      default:
        return primary;
    }
  }

  // ─── Stats Bar ──────────────────────────────────────────────────────
  Widget _buildStatsBar(bool isWeb) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Obx(() {
        final stats = [
          _StatItem('Total', controller.totalProposals.toString(),
              Colors.blue.shade600, Icons.assignment_outlined),
          _StatItem('Submitted', controller.submittedCount.toString(),
              Colors.orange.shade600, Icons.send_outlined),
          _StatItem('Accepted', controller.acceptedCount.toString(),
              Colors.green.shade600, Icons.check_circle_outline),
          _StatItem('Rejected', controller.rejectedCount.toString(),
              Colors.red.shade500, Icons.cancel_outlined),
        ];

        return isWeb
            ? Row(
                children: stats
                    .map((s) => Expanded(child: _buildStatPill(s)))
                    .toList()
                    .expand((w) => [w, const SizedBox(width: 10)])
                    .toList()
                  ..removeLast(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: stats
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _buildStatPill(s),
                          ))
                      .toList(),
                ),
              );
      }),
    );
  }

  Widget _buildStatPill(_StatItem s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: s.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: s.color.withOpacity(0.2), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 15, color: s.color),
          const SizedBox(width: 6),
          Text(
            s.value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: s.color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            s.label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ─── Web Layout ──────────────────────────────────────────────────────
  Widget _buildWebLayout() {
    final proposals = controller.filteredProposals
        .where((p) => p.statusType != 'withdrawn')
        .toList();

    if (proposals.isEmpty) return _buildEmptyState();
    return isGridView
        ? _buildGridView(proposals)
        : _buildTableView(proposals);
  }

  // ─── Mobile Layout ───────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    final proposals = controller.filteredProposals
        .where((p) => p.statusType != 'withdrawn')
        .toList();

    if (proposals.isEmpty) return _buildEmptyState();

    if (controller.selectedStatus.value == 'All') {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (controller.getProposalsByStatusType('submitted').isNotEmpty)
            _buildMobileStatusSection('Submitted',
                controller.getProposalsByStatusType('submitted'),
                Colors.blue.shade600),
          if (controller.getProposalsByStatusType('accepted').isNotEmpty)
            _buildMobileStatusSection('Accepted',
                controller.getProposalsByStatusType('accepted'),
                Colors.green.shade600),
          if (controller.getProposalsByStatusType('rejected').isNotEmpty)
            _buildMobileStatusSection('Rejected',
                controller.getProposalsByStatusType('rejected'),
                Colors.red.shade500),
        ],
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: proposals.length,
        itemBuilder: (context, index) => _buildProposalCard(proposals[index]),
      );
    }
  }

  // ─── Grid View ───────────────────────────────────────────────────────
  Widget _buildGridView(List<ProposalModel> proposals) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.82,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: proposals.length,
      itemBuilder: (context, index) =>
          _buildGridProposalCard(proposals[index]),
    );
  }

  Widget _buildGridProposalCard(ProposalModel proposal) {
    final statusColor = proposal.statusColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.project.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        proposal.project.employerSnapshot.displayName,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    proposal.displayStatus,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _matchBadge(proposal.matchScore),
                  const SizedBox(height: 8),
                  _gridDetailItem(Icons.attach_money, proposal.displayBudget),
                  const SizedBox(height: 3),
                  _gridDetailItem(Icons.schedule, proposal.project.duration),
                  const SizedBox(height: 3),
                  _gridDetailItem(
                      Icons.send_outlined, 'Sent ${proposal.displayDate}'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.grey.shade200, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message_outlined,
                            size: 12, color: statusColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            proposal.coverLetter,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
            ),
            child: Row(children: _getGridActionButtons(proposal)),
          ),
        ],
      ),
    );
  }

  Widget _matchBadge(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 11, color: Colors.green),
          const SizedBox(width: 3),
          Text(
            '$score%',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _gridDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Widget> _getGridActionButtons(ProposalModel proposal) {
    switch (proposal.statusType) {
      case 'submitted':
        return [
          Expanded(
            child: _actionBtn(
              'Withdraw',
              onTap: () => _showWithdrawDialog(proposal),
              color: Colors.red.shade600,
              outlined: true,
            ),
          ),
        ];
      case 'accepted':
        final isCompleted = proposal.contractStatus == 'COMPLETED';
        return [
          Expanded(
            child: _actionBtn('Chat',
                onTap: () => Get.snackbar('Info', 'Chat feature coming soon'),
                color: primary,
                outlined: true),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _actionBtn(
              isCompleted ? 'View' : 'Sign',
              onTap: () => Get.to(() => EmployeeContractScreen(
                    projectId: proposal.project.id,
                    viewOnly: isCompleted,
                  )),
              color: Colors.green.shade600,
            ),
          ),
        ];
      default:
        return [
          Expanded(
            child: _actionBtn('Details', onTap: () {}, color: primary, outlined: true),
          ),
        ];
    }
  }

  Widget _actionBtn(String label,
      {required VoidCallback onTap,
      required Color color,
      bool outlined = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color, width: 0.8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: outlined ? color : Colors.white,
          ),
        ),
      ),
    );
  }

  // ─── Table View ──────────────────────────────────────────────────────
  Widget _buildTableView(List<ProposalModel> proposals) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 16,
          headingRowHeight: 44,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 64,
          headingRowColor: MaterialStateProperty.resolveWith(
            (states) => Colors.grey.shade50,
          ),
          headingTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          dataTextStyle: const TextStyle(fontSize: 12),
          dividerThickness: 0.5,
          columns: const [
            DataColumn(label: Text('PROJECT')),
            DataColumn(label: Text('CLIENT')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('BUDGET')),
            DataColumn(label: Text('MATCH')),
            DataColumn(label: Text('SUBMITTED')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: proposals.map((p) {
            return DataRow(cells: [
              DataCell(SizedBox(
                width: 180,
                child: Text(p.project.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              )),
              DataCell(Text(p.project.employerSnapshot.displayName)),
              DataCell(_statusBadge(p.displayStatus, p.statusColor)),
              DataCell(Text(p.displayBudget)),
              DataCell(_matchBadge(p.matchScore)),
              DataCell(Text(p.displayDate)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: _getTableActionButtons(p),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  List<Widget> _getTableActionButtons(ProposalModel proposal) {
    switch (proposal.statusType) {
      case 'submitted':
        return [
          TextButton(
            onPressed: () => _showWithdrawDialog(proposal),
            style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('Withdraw', style: TextStyle(fontSize: 11)),
          ),
        ];
      case 'accepted':
        return [
          TextButton(
            onPressed: () => Get.snackbar('Info', 'Chat coming soon'),
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('Chat', style: TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () => Get.to(() =>
                EmployeeContractScreen(projectId: proposal.project.id)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(56, 28),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Sign', style: TextStyle(fontSize: 11)),
          ),
        ];
      default:
        return [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(56, 28),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('View', style: TextStyle(fontSize: 11)),
          ),
        ];
    }
  }

  // ─── Mobile Section ──────────────────────────────────────────────────
  Widget _buildMobileStatusSection(
      String title, List<ProposalModel> proposals, Color color) {
    final filtered =
        proposals.where((p) => p.statusType != 'withdrawn').toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${filtered.length}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
        ),
        ...filtered.map((p) => _buildProposalCard(p)),
        const SizedBox(height: 12),
      ],
    );
  }

  // ─── Mobile Card ─────────────────────────────────────────────────────
  Widget _buildProposalCard(ProposalModel proposal) {
    final statusColor = proposal.statusColor;
    final statusType = proposal.statusType;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 10, color: primary),
                          SizedBox(width: 3),
                          Text('PROJECT',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: primary)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _statusBadge(proposal.displayStatus, statusColor),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        proposal.project.employerSnapshot.displayName
                                .isNotEmpty
                            ? proposal
                                .project.employerSnapshot.displayName[0]
                            : 'C',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(proposal.project.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                              proposal
                                  .project.employerSnapshot.displayName,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    _matchBadge(proposal.matchScore),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 5,
                  children: [
                    _detailItem(Icons.attach_money, proposal.displayBudget),
                    _detailItem(Icons.schedule, proposal.project.duration),
                    _detailItem(Icons.send_outlined,
                        'Sent ${proposal.displayDate}'),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.message_outlined,
                          size: 13, color: statusColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusMessage(statusType),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor),
                            ),
                            const SizedBox(height: 1),
                            Text(proposal.coverLetter,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (statusType == 'accepted')
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                            width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 12, color: Colors.green),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'You\'ll receive: \$${proposal.youWillReceive}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                  top: BorderSide(
                      color: Colors.grey.shade200, width: 0.5)),
            ),
            child: Row(children: _getMobileActionButtons(proposal)),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(String statusType) {
    switch (statusType) {
      case 'submitted':
        return 'Your Proposal';
      case 'accepted':
        return 'Accepted!';
      case 'rejected':
        return 'Feedback';
      default:
        return 'Message';
    }
  }

  List<Widget> _getMobileActionButtons(ProposalModel proposal) {
    switch (proposal.statusType) {
      case 'submitted':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showWithdrawDialog(proposal),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
              ),
              child: const Text('Withdraw',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ];
      case 'accepted':
        final isCompleted = proposal.contractStatus == 'COMPLETED';
        final hasActive = proposal.hasActiveContract;
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  Get.snackbar('Info', 'Chat feature coming soon'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
              ),
              child: const Text('Chat',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          if (!isCompleted) ...[
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.to(() => EmployeeContractScreen(
                      projectId: proposal.project.id,
                      viewOnly: hasActive,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasActive ? Colors.blue.shade600 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 0,
                ),
                child: Text(hasActive ? 'View' : 'Sign',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ];
      case 'rejected':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
              ),
              child: Text('Feedback',
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
              ),
              child: const Text('Similar',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ];
      default:
        return [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                elevation: 0,
              ),
              child: const Text('View Details',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ];
    }
  }

  Widget _detailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade400),
        const SizedBox(width: 3),
        Text(text,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final hasSearch = controller.searchQuery.value.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.assignment_outlined,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No proposals found' : 'No Proposals Yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try searching with different keywords'
                  : 'You haven\'t applied to any projects yet.\nStart browsing and submit your first proposal!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 17),
                label: const Text('Browse Projects'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Withdraw Dialog ─────────────────────────────────────────────────
  void _showWithdrawDialog(ProposalModel proposal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Withdraw Proposal?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to withdraw your proposal for "${proposal.project.title}"?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.withdrawProposal(proposal.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Withdraw', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Model ─────────────────────────────────────────────────────
class _StatItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  _StatItem(this.label, this.value, this.color, this.icon);
}
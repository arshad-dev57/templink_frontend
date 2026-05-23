import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_timesheet_controller.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _bg = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border = Color(0xFFE5E7EB);
const _text1 = Color(0xFF111827);
const _text2 = Color(0xFF6B7280);
const _text3 = Color(0xFF9CA3AF);
const _success = Color(0xFF16A34A);
const _warning = Color(0xFFF59E0B);
const _error = Color(0xFFDC2626);
const _info = Color(0xFF3B82F6);
const _radius = 12.0;

class EmployerTimesheetApprovalScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const EmployerTimesheetApprovalScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

  @override
  State<EmployerTimesheetApprovalScreen> createState() => _EmployerTimesheetApprovalScreenState();
}

class _EmployerTimesheetApprovalScreenState extends State<EmployerTimesheetApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EmployerTimesheetController controller = Get.put(EmployerTimesheetController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            controller.setFilter('pending');
            break;
          case 1:
            controller.setFilter('approved');
            break;
          case 2:
            controller.setFilter('rejected');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    if (isWeb && !widget.showSidebar) {
      return Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildWebTopBar(),
            Expanded(child: _buildBody(isWeb, isDesktop)),
          ],
        ),
      );
    }

    if (isWeb) {
      return _buildFullWebLayout(isDesktop);
    }

    return _buildMobileLayout();
  }

  // ==================== WEB FULL LAYOUT ====================
  Widget _buildFullWebLayout(bool isDesktop) {
    final sidebarW = isDesktop ? 280.0 : 240.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          Container(
            width: sidebarW,
            decoration: BoxDecoration(
              color: _surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(2, 0)),
              ],
            ),
            child: _buildWebSidebar(),
          ),
          Expanded(
            child: Column(
              children: [
                _buildWebTopBar(),
                Expanded(child: _buildBody(true, isDesktop)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSidebar() {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.access_time, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Templink', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Column(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text('Timesheet Approvals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Review employee timesheets', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: _border))),
          child: Column(
            children: [
              _webNavItem(Icons.home_outlined, 'Dashboard', () {}),
              const SizedBox(height: 8),
              _webNavItem(Icons.arrow_back, 'Back', () {
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!();
                } else {
                  Get.back();
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _webNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _text2),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, color: _text2)),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: _surface, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ]),
      child: Row(
        children: [
          const Text('Timesheet Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_outlined, size: 20),
            onPressed: _showSearchDialog,
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => controller.fetchAllTimesheets(),
            tooltip: 'Refresh',
          ),
          if (!widget.showSidebar) ...[
            const SizedBox(width: 8),
            CircleAvatar(radius: 18, backgroundColor: primary.withOpacity(0.1), child: Icon(Icons.person, size: 18, color: primary)),
          ],
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _text1),
          onPressed: widget.onBackPressed ?? () => Get.back(),
        ),
        title: const Text('Timesheet Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => controller.fetchAllTimesheets(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          indicatorWeight: 2,
          labelColor: primary,
          unselectedLabelColor: _text3,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Pending (${controller.totalPending})'),
            const Tab(text: 'Approved'),
            const Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: _buildBody(false, false),
    );
  }

  // ==================== MAIN BODY ====================
  Widget _buildBody(bool isWeb, bool isDesktop) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredTimesheets.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      return Column(
        children: [
          _buildSummaryCards(isWeb),
          Expanded(
            child: controller.filteredTimesheets.isEmpty
                ? _buildEmptyState()
                : isWeb
                    ? _buildWebTimesheetGrid(controller.filteredTimesheets, isDesktop)
                    : _buildMobileTimesheetList(controller.filteredTimesheets),
          ),
        ],
      );
    });
  }

  // ==================== SUMMARY CARDS ====================
  Widget _buildSummaryCards(bool isWeb) {
    if (isWeb) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildSummaryCardWeb('Pending', '${controller.totalPending}', _warning, Icons.pending, 'requests'),
            const SizedBox(width: 16),
            _buildSummaryCardWeb('Hours', '${controller.totalHoursPending.toStringAsFixed(0)}h', _info, Icons.timer, 'pending hours'),
            const SizedBox(width: 16),
            _buildSummaryCardWeb('Approved', '${controller.totalApproved}', _success, Icons.check_circle, 'timesheets'),
            const SizedBox(width: 16),
            _buildSummaryCardWeb('Rejected', '${controller.totalRejected}', _error, Icons.cancel, 'timesheets'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: _surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCardMobile('Pending', '${controller.totalPending}', _warning, Icons.pending),
          _buildSummaryCardMobile('Hours', '${controller.totalHoursPending.toStringAsFixed(0)}h', _info, Icons.timer),
          _buildSummaryCardMobile('Approved', '${controller.totalApproved}', _success, Icons.check_circle),
          _buildSummaryCardMobile('Rejected', '${controller.totalRejected}', _error, Icons.cancel),
        ],
      ),
    );
  }

  Widget _buildSummaryCardWeb(String label, String value, Color color, IconData icon, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 13, color: _text2)),
                Text(subtitle, style: TextStyle(fontSize: 10, color: _text3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardMobile(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: _text2)),
      ],
    );
  }

  // ==================== WEB TIMESHEET GRID ====================
  Widget _buildWebTimesheetGrid(List<Map<String, dynamic>> timesheets, bool isDesktop) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.15,
      ),
      itemCount: timesheets.length,
      itemBuilder: (context, index) => _buildTimesheetCardWeb(timesheets[index]),
    );
  }

  // ==================== WEB TIMESHEET CARD ====================
  Widget _buildTimesheetCardWeb(Map<String, dynamic> timesheet) {
    final status = timesheet['status'] ?? 'pending';
    final statusColor = status == 'approved' ? _success : (status == 'rejected' ? _error : _warning);
    final statusText = status == 'approved' ? 'APPROVED' : (status == 'rejected' ? 'REJECTED' : 'PENDING');
    
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
              ),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      timesheet['employeeInitials'] ?? '--',
                      style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timesheet['employeeName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.formatDateRange(timesheet['weekStart'], timesheet['weekEnd']),
                        style: TextStyle(fontSize: 11, color: _text2),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTimeStat('Total Hours', '${timesheet['totalHours'] ?? 0}h', _info),
                    const SizedBox(width: 12),
                    _buildTimeStat('Regular', '${timesheet['regularHours'] ?? 0}h', _success),
                    const SizedBox(width: 12),
                    _buildTimeStat('Overtime', '${timesheet['overtimeHours'] ?? 0}h', _warning),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Action Buttons
                if (status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showRejectDialog(timesheet),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _error,
                            side: BorderSide(color: _error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isProcessing.value ? null : () => _showApproveDialog(timesheet),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: controller.isProcessing.value
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Approve'),
                        )),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showTimesheetDetails(timesheet),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE TIMESHEET LIST ====================
  Widget _buildMobileTimesheetList(List<Map<String, dynamic>> timesheets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timesheets.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildTimesheetCardMobile(timesheets[index]),
      ),
    );
  }

  // ==================== MOBILE TIMESHEET CARD ====================
  Widget _buildTimesheetCardMobile(Map<String, dynamic> timesheet) {
    final status = timesheet['status'] ?? 'pending';
    final statusColor = status == 'approved' ? _success : (status == 'rejected' ? _error : _warning);
    final statusText = status == 'approved' ? 'APPROVED' : (status == 'rejected' ? 'REJECTED' : 'PENDING');
    
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () => _showTimesheetDetails(timesheet),
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        timesheet['employeeInitials'] ?? '--',
                        style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timesheet['employeeName'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.formatDateRange(timesheet['weekStart'], timesheet['weekEnd']),
                          style: TextStyle(fontSize: 11, color: _text2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeStat('Total', '${timesheet['totalHours'] ?? 0}h', _info),
                  _buildTimeStat('Regular', '${timesheet['regularHours'] ?? 0}h', _success),
                  _buildTimeStat('Overtime', '${timesheet['overtimeHours'] ?? 0}h', _warning),
                ],
              ),
              if (status == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRejectDialog(timesheet),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _error,
                          side: BorderSide(color: _error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isProcessing.value ? null : () => _showApproveDialog(timesheet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: controller.isProcessing.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Approve'),
                      )),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 10, color: _text3)),
        ],
      ),
    );
  }

  // ==================== TIMESHEET DETAILS MODAL ====================
  void _showTimesheetDetails(Map<String, dynamic> timesheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Header
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          timesheet['employeeInitials'] ?? '--',
                          style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timesheet['employeeName'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _text1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.formatDateRange(timesheet['weekStart'], timesheet['weekEnd']),
                            style: TextStyle(fontSize: 13, color: _text2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStat('Total', '${timesheet['totalHours'] ?? 0}h', _info),
                      _buildDetailStat('Regular', '${timesheet['regularHours'] ?? 0}h', _success),
                      _buildDetailStat('Overtime', '${timesheet['overtimeHours'] ?? 0}h', _warning),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Daily Breakdown
                const Text('Daily Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
                const SizedBox(height: 12),
                
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: timesheet['dailyEntries']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final entry = timesheet['dailyEntries'][index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(
                                  entry['day'] ?? '',
                                  style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['project'] ?? 'No Project',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: _text1),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry['task'] ?? 'No Task',
                                    style: TextStyle(fontSize: 11, color: _text2),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${entry['hours']}h',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _info),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: _text2)),
      ],
    );
  }

  // ==================== SEARCH DIALOG ====================
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Search Timesheets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by employee name...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (value) => controller.search(value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchController.clear();
              controller.search('');
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: _text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
  }

  // ==================== APPROVE DIALOG ====================
  void _showApproveDialog(Map<String, dynamic> timesheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Timesheet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(
          'Approve ${timesheet['employeeName']}\'s timesheet?',
          style: const TextStyle(fontSize: 14, color: _text2),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: _text2))),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value ? null : () async {
              bool success = await controller.approveTimesheet(timesheet['id']);
              if (success) {
                Navigator.pop(context);
                _showSnackbar(controller.successMessage.value, _success);
              } else {
                _showSnackbar(controller.errorMessage.value, _error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: controller.isProcessing.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Approve'),
          )),
        ],
      ),
    );
  }

  // ==================== REJECT DIALOG ====================
  void _showRejectDialog(Map<String, dynamic> timesheet) {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Timesheet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject ${timesheet['employeeName']}\'s timesheet?',
              style: const TextStyle(fontSize: 14, color: _text2),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Please provide a reason...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: _text2))),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value ? null : () async {
              if (reasonController.text.isEmpty) {
                _showSnackbar('Please provide a reason', _error);
                return;
              }
              bool success = await controller.rejectTimesheet(timesheet['id'], reasonController.text);
              if (success) {
                Navigator.pop(context);
                _showSnackbar(controller.successMessage.value, _success);
              } else {
                _showSnackbar(controller.errorMessage.value, _error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: controller.isProcessing.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Reject'),
          )),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(Icons.inbox, size: 40, color: primary),
          ),
          const SizedBox(height: 20),
          const Text('No timesheets found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
          const SizedBox(height: 8),
          Text('No timesheets match your criteria', style: TextStyle(fontSize: 13, color: _text2)),
        ],
      ),
    );
  }

  // ==================== SNACKBAR ====================
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
// lib/Employer/Screens/employer_leave_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_leave_controller.dart';
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

class EmployerLeaveApprovalScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const EmployerLeaveApprovalScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

  @override
  State<EmployerLeaveApprovalScreen> createState() => _EmployerLeaveApprovalScreenState();
}

class _EmployerLeaveApprovalScreenState extends State<EmployerLeaveApprovalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EmployerLeaveController controller = Get.put(EmployerLeaveController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                child: const Icon(Icons.beach_access_outlined, color: Colors.white, size: 18),
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
                const Icon(Icons.beach_access, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text('Leave Approvals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Manage employee leave requests', style: TextStyle(color: Colors.white70, fontSize: 11)),
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
          const Text('Leave Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => controller.refreshAllData(),
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
        title: const Text('Leave Approvals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => controller.refreshAllData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          indicatorWeight: 2,
          labelColor: primary,
          unselectedLabelColor: _text3,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _buildBody(false, false),
    );
  }

  // ==================== MAIN BODY ====================
  Widget _buildBody(bool isWeb, bool isDesktop) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPendingTab(isWeb, isDesktop),
        _buildHistoryTab(isWeb, isDesktop),
      ],
    );
  }

  // ==================== PENDING TAB ====================
  Widget _buildPendingTab(bool isWeb, bool isDesktop) {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingRequests.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      if (controller.pendingRequests.isEmpty) {
        return _buildEmptyState('No Pending Requests', 'All caught up!', Icons.check_circle_outline);
      }

      if (isWeb) {
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 2 : 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemCount: controller.pendingRequests.length,
          itemBuilder: (context, index) => _buildPendingRequestCardWeb(controller.pendingRequests[index]),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.pendingRequests.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPendingRequestCardMobile(controller.pendingRequests[index]),
        ),
      );
    });
  }

  // ==================== PENDING CARD WEB ====================
  Widget _buildPendingRequestCardWeb(Map<String, dynamic> request) {
    final typeColor = controller.getLeaveTypeColor(request['type'] ?? 'Leave');
    
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
              color: typeColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
              ),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      request['employeeInitials'] ?? '--',
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['employeeName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          request['type'] ?? 'Leave',
                          style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    '${request['days'] ?? 0} ${request['days'] == 1 ? 'day' : 'days'}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _text2),
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today_outlined, 'Date Range', controller.formatDateRange(request['fromDate'], request['toDate'])),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.info_outline, 'Reason', request['reason'] ?? 'No reason provided'),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Footer with actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applied ${controller.getTimeAgo(request['appliedOn'])}',
                      style: TextStyle(fontSize: 11, color: _text3),
                    ),
                    Row(
                      children: [
                        _buildActionButton(Icons.close, _error, () => _showRejectDialog(request)),
                        const SizedBox(width: 12),
                        Obx(() => _buildActionButton(
                          Icons.check,
                          _success,
                          controller.isProcessing.value ? null : () => _approveRequest(request['id']),
                          isLoading: controller.isProcessing.value,
                        )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PENDING CARD MOBILE ====================
  Widget _buildPendingRequestCardMobile(Map<String, dynamic> request) {
    final typeColor = controller.getLeaveTypeColor(request['type'] ?? 'Leave');
    
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      request['employeeInitials'] ?? '--',
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['employeeName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(request['type'] ?? 'Leave', style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                            child: Text('${request['days'] ?? 0} days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _text2)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            _buildInfoRow(Icons.calendar_today_outlined, 'Date Range', controller.formatDateRange(request['fromDate'], request['toDate'])),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.info_outline, 'Reason', request['reason'] ?? 'No reason provided'),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Applied ${controller.getTimeAgo(request['appliedOn'])}', style: TextStyle(fontSize: 11, color: _text3)),
                Row(
                  children: [
                    _buildActionButton(Icons.close, _error, () => _showRejectDialog(request), size: 32, iconSize: 16),
                    const SizedBox(width: 8),
                    Obx(() => _buildActionButton(
                      Icons.check,
                      _success,
                      controller.isProcessing.value ? null : () => _approveRequest(request['id']),
                      isLoading: controller.isProcessing.value,
                      size: 32,
                      iconSize: 16,
                    )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HISTORY TAB ====================
  Widget _buildHistoryTab(bool isWeb, bool isDesktop) {
    return Obx(() {
      if (controller.isLoading.value && controller.approvedRequests.isEmpty && controller.rejectedRequests.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      final hasData = controller.approvedRequests.isNotEmpty || controller.rejectedRequests.isNotEmpty;
      
      if (!hasData) {
        return _buildEmptyState('No History Found', 'No leave requests processed yet', Icons.history);
      }

      return Column(
        children: [
          // Stats Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: _surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Approved', '${controller.totalApproved}', _success, Icons.check_circle),
                _buildStatItem('Rejected', '${controller.totalRejected}', _error, Icons.cancel),
                _buildStatItem('Days', '${controller.totalDaysApproved}', _info, Icons.calendar_today),
              ],
            ),
          ),
          
          // History List
          Expanded(
            child: isWeb
                ? GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: controller.approvedRequests.length + controller.rejectedRequests.length,
                    itemBuilder: (context, index) {
                      if (index < controller.approvedRequests.length) {
                        return _buildHistoryCardWeb(controller.approvedRequests[index], true);
                      } else {
                        return _buildHistoryCardWeb(
                          controller.rejectedRequests[index - controller.approvedRequests.length],
                          false
                        );
                      }
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.approvedRequests.length + controller.rejectedRequests.length,
                    itemBuilder: (context, index) {
                      if (index < controller.approvedRequests.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHistoryCardMobile(controller.approvedRequests[index], true),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHistoryCardMobile(
                            controller.rejectedRequests[index - controller.approvedRequests.length],
                            false
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      );
    });
  }

  // ==================== HISTORY CARD WEB ====================
  Widget _buildHistoryCardWeb(Map<String, dynamic> request, bool isApproved) {
    final typeColor = controller.getLeaveTypeColor(request['type'] ?? 'Leave');
    final statusColor = isApproved ? _success : _error;
    final statusText = isApproved ? 'APPROVED' : 'REJECTED';
    
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_radius),
                topRight: Radius.circular(_radius),
              ),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      request['employeeInitials'] ?? '--',
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['employeeName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request['type']} • ${request['days']} days',
                        style: TextStyle(fontSize: 11, color: _text2),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
                  child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.calendar_today_outlined, 'Date Range', controller.formatDateRange(request['fromDate'], request['toDate'])),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Applied ${controller.getTimeAgo(request['appliedOn'])}', style: TextStyle(fontSize: 10, color: _text3)),
                    if (request['approvedBy'] != null)
                      Text('by ${request['approvedBy']['name'] ?? 'Manager'}', style: TextStyle(fontSize: 10, color: _text3)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HISTORY CARD MOBILE ====================
  Widget _buildHistoryCardMobile(Map<String, dynamic> request, bool isApproved) {
    final typeColor = controller.getLeaveTypeColor(request['type'] ?? 'Leave');
    final statusColor = isApproved ? _success : _error;
    final statusText = isApproved ? 'APPROVED' : 'REJECTED';
    
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      request['employeeInitials'] ?? '--',
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['employeeName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request['type']} • ${request['days']} days',
                        style: TextStyle(fontSize: 11, color: _text2),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
                  child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, 'Date Range', controller.formatDateRange(request['fromDate'], request['toDate'])),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Applied ${controller.getTimeAgo(request['appliedOn'])}', style: TextStyle(fontSize: 10, color: _text3)),
                if (request['approvedBy'] != null)
                  Text('by ${request['approvedBy']['name'] ?? 'Manager'}', style: TextStyle(fontSize: 10, color: _text3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STAT ITEM ====================
  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: _text2)),
      ],
    );
  }

  // ==================== INFO ROW ====================
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _text3),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: _text3)),
              Text(value, style: TextStyle(fontSize: 12, color: _text2), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== ACTION BUTTON ====================
  Widget _buildActionButton(IconData icon, Color color, VoidCallback? onTap, {double size = 36, double iconSize = 18, bool isLoading = false}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(width: iconSize - 4, height: iconSize - 4, child: CircularProgressIndicator(strokeWidth: 2, color: color))
              : Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 13, color: _text2)),
          ],
        ),
      ),
    );
  }

  // ==================== ACTION METHODS ====================
  void _approveRequest(String leaveId) async {
    bool success = await controller.approveLeave(leaveId);
    if (success) {
      _showSnackbar(controller.successMessage.value, _success);
    } else {
      _showSnackbar(controller.errorMessage.value, _error);
    }
  }

  void _showRejectDialog(Map<String, dynamic> request) {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Leave Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject ${request['employeeName']}\'s leave request?',
              style: const TextStyle(fontSize: 13, color: _text2),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _text2)),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value ? null : () async {
              if (reasonController.text.isEmpty) {
                _showSnackbar('Please provide a reason', _error);
                return;
              }
              bool success = await controller.rejectLeave(request['id'], reasonController.text);
              if (success) {
                Navigator.pop(context);
                _showSnackbar(controller.successMessage.value, _success);
              } else {
                _showSnackbar(controller.errorMessage.value, _error);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: controller.isProcessing.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Reject'),
          )),
        ],
      ),
    );
  }

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
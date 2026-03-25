// lib/Employer/Screens/employer_leave_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_leave_controller.dart';
import '../../Utils/colors.dart';

class EmployerLeaveApprovalScreen extends StatefulWidget {
  const EmployerLeaveApprovalScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Leave Approvals',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAllData(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ============== PENDING TAB ==============
  Widget _buildPendingTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.pendingRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green[200],
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All caught up!',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.pendingRequests.length,
        itemBuilder: (context, index) {
          final request = controller.pendingRequests[index];
          return _buildPendingRequestCard(request);
        },
      );
    });
  }

  Widget _buildPendingRequestCard(Map<String, dynamic> request) {
    final typeColor = controller.getLeaveTypeColor(request['type'] ?? 'Leave');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with employee info
          Row(
            children: [
              // Avatar with type color background
              CircleAvatar(
                radius: 24,
                backgroundColor: typeColor.withOpacity(0.1),
                child: Text(
                  request['employeeInitials'] ?? '--',
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Employee name and leave type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['employeeName'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        request['type'] ?? 'Leave',
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Days badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${request['days'] ?? 0} ${request['days'] == 1 ? 'day' : 'days'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Date range
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(
                controller.formatDateRange(request['fromDate'], request['toDate']),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Reason
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request['reason'] ?? 'No reason provided',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Footer with time and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applied ${controller.getTimeAgo(request['appliedOn'])}',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
              
              // Action buttons
              Row(
                children: [
                  // Reject button
                  GestureDetector(
                    onTap: () => _showRejectDialog(request),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.red, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Approve button
                  Obx(() {
                    return GestureDetector(
                      onTap: controller.isProcessing.value
                          ? null
                          : () => _approveRequest(request['id']),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: controller.isProcessing.value
                              ? Colors.green.withOpacity(0.3)
                              : Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: controller.isProcessing.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.green,
                                ),
                              )
                            : const Icon(Icons.check, color: Colors.green, size: 18),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============== HISTORY TAB ==============
  Widget _buildHistoryTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Stats summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Approved',
                    '${controller.totalApproved}',
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildStatItem(
                    'Rejected',
                    '${controller.totalRejected}',
                    Colors.red,
                    Icons.cancel,
                  ),
                  _buildStatItem(
                    'Days',
                    '${controller.totalDaysApproved}',
                    Colors.blue,
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
            
            // History list
            Expanded(
              child: controller.approvedRequests.isEmpty && 
                     controller.rejectedRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No history found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.approvedRequests.length + 
                                 controller.rejectedRequests.length,
                      itemBuilder: (context, index) {
                        if (index < controller.approvedRequests.length) {
                          return _buildHistoryCard(
                            controller.approvedRequests[index],
                          );
                        } else {
                          return _buildHistoryCard(
                            controller.rejectedRequests[
                              index - controller.approvedRequests.length
                            ],
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> request) {
    final typeColor = controller.getLeaveTypeColor(request['type'] ?? 'Leave');
    final statusColor = controller.getStatusColor(request['status'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: typeColor.withOpacity(0.1),
                child: Text(
                  request['employeeInitials'] ?? '--',
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request['type']} • ${request['days']} days',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request['status'].toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.formatDateRange(request['fromDate'], request['toDate']),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              if (request['approvedBy'] != null)
                Text(
                  'by ${request['approvedBy']['name'] ?? 'Manager'}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============== ACTION METHODS ==============
  void _approveRequest(String leaveId) async {
    bool success = await controller.approveLeave(leaveId);
    
    if (success) {
      _showSnackbar(controller.successMessage.value, Colors.green);
    } else {
      _showSnackbar(controller.errorMessage.value, Colors.red);
    }
  }

  void _showRejectDialog(Map<String, dynamic> request) {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Reject Leave Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to reject ${request['employeeName']}\'s leave request?',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Reason for rejection',
                    hintText: 'Please provide a reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isProcessing.value
                      ? null
                      : () async {
                          if (reasonController.text.isEmpty) {
                            _showSnackbar('Please provide a reason', Colors.red);
                            return;
                          }
                          
                          bool success = await controller.rejectLeave(
                            request['id'],
                            reasonController.text,
                          );
                          
                          if (success) {
                            Navigator.pop(context);
                            _showSnackbar(controller.successMessage.value, Colors.green);
                          } else {
                            _showSnackbar(controller.errorMessage.value, Colors.red);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isProcessing.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Reject'),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
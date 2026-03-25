import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_timesheet_controller.dart';
import 'package:templink/widgets/timesheet_approval_card.dart';
import '../../Utils/colors.dart';


class EmployerTimesheetApprovalScreen extends StatefulWidget {
  const EmployerTimesheetApprovalScreen({Key? key}) : super(key: key);

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
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
          'Timesheet Approvals',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          onTap: (index) {
            switch (index) {
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
          },
          tabs: [
            Tab(text: 'Pending (${controller.totalPending})'),
            const Tab(text: 'Approved'),
            const Tab(text: 'Rejected'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllTimesheets(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Summary Cards
            _buildSummaryCards(),
            
            // Timesheet List
            Expanded(
              child: _buildTimesheetList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard(
            'Pending',
            '${controller.totalPending}',
            Icons.pending,
            Colors.orange,
          ),
          _buildSummaryCard(
            'Hours',
            '${controller.totalHoursPending.toStringAsFixed(0)}h',
            Icons.timer,
            Colors.blue,
          ),
          _buildSummaryCard(
            'Approved',
            '${controller.totalApproved}',
            Icons.check_circle,
            Colors.green,
          ),
          _buildSummaryCard(
            'Rejected',
            '${controller.totalRejected}',
            Icons.cancel,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
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

  Widget _buildTimesheetList() {
    final timesheets = controller.filteredTimesheets;
    
    if (timesheets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No timesheets found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: timesheets.length,
      itemBuilder: (context, index) {
        final timesheet = timesheets[index];
        return TimesheetApprovalCard(
          timesheet: timesheet,
          onTap: () => _showTimesheetDetails(timesheet),
          onApprove: () => _showApproveDialog(timesheet),
          onReject: () => _showRejectDialog(timesheet),
        );
      },
    );
  }

  void _showTimesheetDetails(Map<String, dynamic> timesheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primary.withOpacity(0.1),
                      child: Text(
                        timesheet['employeeInitials'] ?? '--',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.formatDateRange(
                              timesheet['weekStart'],
                              timesheet['weekEnd'],
                            ),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
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
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStat('Total', '${timesheet['totalHours'] ?? 0}h', Colors.blue),
                      _buildDetailStat('Regular', '${timesheet['regularHours'] ?? 0}h', Colors.green),
                      _buildDetailStat('Overtime', '${timesheet['overtimeHours'] ?? 0}h', Colors.orange),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Daily Breakdown
                const Text(
                  'Daily Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  entry['day'] ?? '',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry['task'] ?? 'No Task',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${entry['hours']}h',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Search Timesheets'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search by employee name...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (value) {
            controller.search(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchController.clear();
              controller.search('');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(Map<String, dynamic> timesheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Approve Timesheet'),
        content: Text(
          'Are you sure you want to approve ${timesheet['employeeName']}\'s timesheet for ${controller.formatDateRange(timesheet['weekStart'], timesheet['weekEnd'])}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() {
            return ElevatedButton(
              onPressed: controller.isProcessing.value
                  ? null
                  : () async {
                      bool success = await controller.approveTimesheet(timesheet['id']);
                      if (success) {
                        Navigator.pop(context);
                        _showSnackbar(controller.successMessage.value, Colors.green);
                      } else {
                        _showSnackbar(controller.errorMessage.value, Colors.red);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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
                  : const Text('Approve'),
            );
          }),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> timesheet) {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Reject Timesheet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject ${timesheet['employeeName']}\'s timesheet?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
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
            child: const Text('Cancel'),
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
                      
                      bool success = await controller.rejectTimesheet(
                        timesheet['id'],
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
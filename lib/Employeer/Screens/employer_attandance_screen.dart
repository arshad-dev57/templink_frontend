// lib/Employer/Screens/employer_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_attendance_history_controller.dart';
import '../../Utils/colors.dart';

class EmployerAttendanceScreen extends StatefulWidget {
  const EmployerAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<EmployerAttendanceScreen> createState() => _EmployerAttendanceScreenState();
}

class _EmployerAttendanceScreenState extends State<EmployerAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final EmployerAttendanceHistoryController controller = Get.put(EmployerAttendanceHistoryController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Today'),          
            Tab(text: 'Employee-wise'),  
            Tab(text: 'Monthly Trend'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _showDateSelector,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAll(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),             
          _buildEmployeeWiseTab(),      
          _buildMonthlyTrendTab(),   
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return Obx(() {
      if (controller.isLoadingToday.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withBlue(primary.blue + 20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTodayStat('Present', controller.todayPresentString, Colors.green),
                      _buildTodayStat('Late', controller.todayLateString, Colors.orange),
                      _buildTodayStat('Absent', controller.todayAbsentString, Colors.red),
                      _buildTodayStat('Leave', controller.todayLeaveString, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: controller.todayAttendanceBarValue,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.todayPresentPercentage}% Present Today',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today\'s Records',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${controller.todayAttendanceList.length} employees',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildDailyAttendanceList(),
            
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
  Widget _buildTodayStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
  Widget _buildDailyAttendanceList() {
    return Obx(() {
      if (controller.todayAttendanceList.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No attendance records for today',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.todayAttendanceList.length,
        itemBuilder: (context, index) {
          final record = controller.todayAttendanceList[index];
          return _buildAttendanceRecord(record);
        },
      );
    });
  }
    Widget _buildAttendanceRecord(Map<String, dynamic> record) {
    final status = record['status'] ?? 'absent';
    final checkIn = record['checkIn'] != null 
        ? DateTime.parse(record['checkIn']).toLocal() 
        : null;
    final checkOut = record['checkOut'] != null 
        ? DateTime.parse(record['checkOut']).toLocal() 
        : null;
    final isLate = record['isLate'] ?? false;
    final lateMinutes = record['lateMinutes'] ?? 0;
    final totalHours = record['totalHours'];
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Present';
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Late';
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Absent';
        break;
      case 'leave':
        statusColor = Colors.blue;
        statusIcon = Icons.beach_access;
        statusText = 'On Leave';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Text(
                      record['initials'] ?? '--',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record['title'] ?? 'Employee',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
                    Row(
            children: [
                            Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          Text(
                            'Check In',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            checkIn != null 
                                ? '${checkIn.hour.toString().padLeft(2, '0')}:${checkIn.minute.toString().padLeft(2, '0')}'
                                : '--:--',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: checkIn != null ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          Text(
                            'Check Out',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            checkOut != null 
                                ? '${checkOut.hour.toString().padLeft(2, '0')}:${checkOut.minute.toString().padLeft(2, '0')}'
                                : '--:--',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: checkOut != null ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLate && status == 'late') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Late by $lateMinutes minutes',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status == 'leave' && record['leaveDetails'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${record['leaveDetails']['type'] ?? 'Leave'}: ${record['leaveDetails']['reason'] ?? 'No reason'}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (checkOut != null && totalHours != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.timer, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Total: ${totalHours.toString()} hrs',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildEmployeeWiseTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.employees.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          _buildViewSelector(),
          Expanded(
            child: controller.selectedEmployee.value == null
                ? _buildEmployeeList()
                : _buildEmployeeDetail(),
          ),
        ],
      );
    });
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildViewOption('monthly', 'Monthly'),
                  _buildViewOption('yearly', 'Yearly'),
                  _buildViewOption('custom', 'Custom'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => GestureDetector(
            onTap: _showDateSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    controller.selectedPeriod.value,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildViewOption(String value, String label) {
    return Expanded(
      child: Obx(() => GestureDetector(
        onTap: () => controller.setView(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: controller.selectedView.value == value
                ? primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: controller.selectedView.value == value
                  ? Colors.white
                  : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      )),
    );
  }
  Widget _buildEmployeeList() {
    if (controller.employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No attendance data found',
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
      itemCount: controller.employees.length,
      itemBuilder: (context, index) {
        final employee = controller.employees[index];
        return _buildEmployeeCard(employee);
      },
    );
  }
  String _parseHours(dynamic value) {
    if (value == null) return '0h';
    String strVal = value.toString().trim();
    if (strVal.isEmpty || strVal == 'null' || strVal == 'undefined') return '0h';
    if (strVal.contains('{') || strVal.contains('}') || strVal.contains(r'$')) return '0h';
    if (strVal.endsWith('h')) {
      final parsed = double.tryParse(strVal.replaceAll('h', '').trim());
      if (parsed == null || parsed <= 0) return '0h';
      return '${parsed.toStringAsFixed(1)}h';
    }
    final numVal = double.tryParse(strVal);
    if (numVal == null || numVal <= 0) return '0h';
    return '${numVal.toStringAsFixed(1)}h';
  }

  // Employee Card
  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    final stats = employee['stats'] ?? {};
    final workingHours = _parseHours(stats['workingHours']);
    final overtimeVal = _parseHours(stats['overtime']);
    final showOvertime = overtimeVal != '0h' && overtimeVal != '0.0h';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          controller.fetchEmployeeDetails(employee['employeeId']);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Text(
                      employee['initials'] ?? '--',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${employee['designation'] ?? ''} • ${employee['department'] ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),

              const SizedBox(height: 16),

              // Attendance Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttendanceStat('Present', '${stats['present'] ?? 0}', Colors.green),
                  _buildAttendanceStat('Absent', '${stats['absent'] ?? 0}', Colors.red),
                  _buildAttendanceStat('Late', '${stats['late'] ?? 0}', Colors.orange),
                  _buildAttendanceStat('Leave', '${stats['leave'] ?? 0}', Colors.blue),
                ],
              ),

              const SizedBox(height: 12),

              // Working Hours + Overtime Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Working: $workingHours',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (showOvertime)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'OT: $overtimeVal',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color) {
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

  Widget _buildEmployeeDetail() {
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final employee = controller.selectedEmployee.value;
      if (employee == null) return const SizedBox();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: controller.clearSelectedEmployee,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    employee['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Employee info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Text(
                      employee['initials'] ?? '--',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['designation'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee['department'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            if (controller.employeeRecords.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Records',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...controller.employeeRecords.map((record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(controller.getStatusColor(record['status']))
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: Color(
                                int.parse(controller.getStatusColor(record['status']))
                              ),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.formatDate(DateTime.parse(record['date'])),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.login, size: 12, color: Colors.grey[400]),
                                    const SizedBox(width: 2),
                                    Text(
                                      record['checkIn'] != null
                                          ? controller.formatTime(DateTime.parse(record['checkIn']))
                                          : '--:--',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.logout, size: 12, color: Colors.grey[400]),
                                    const SizedBox(width: 2),
                                    Text(
                                      record['checkOut'] != null
                                          ? controller.formatTime(DateTime.parse(record['checkOut']))
                                          : '--:--',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(controller.getStatusColor(record['status']))
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.getStatusText(record['status']),
                              style: TextStyle(
                                color: Color(
                                  int.parse(controller.getStatusColor(record['status']))
                                ),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  // ============== MONTHLY TREND TAB (unchanged) ==============
  Widget _buildMonthlyTrendTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.trendData.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrendChart(),
            const SizedBox(height: 24),
            _buildMonthlyBreakdown(),
          ],
        ),
      );
    });
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Yearly Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() => GestureDetector(
                onTap: _showYearPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${controller.selectedYear.value}',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: primary, size: 16),
                    ],
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.trendData.length,
              itemBuilder: (context, index) {
                final data = controller.trendData[index];
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            // Present bar
                            Container(
                              width: 30,
                              margin: const EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: (data['present'] ?? 0) * 1.5,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Late indicator
                            Positioned(
                              top: 10,
                              left: 0,
                              child: Container(
                                width: 20,
                                height: (data['late'] ?? 0) * 0.8,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['month'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Present', Colors.green),
              const SizedBox(width: 16),
              _buildLegendItem('Late', Colors.orange),
              const SizedBox(width: 16),
              _buildLegendItem('Absent', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMonthlyBreakdown() {
    if (controller.trendData.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              const TableRow(
                children: [
                  Text('Month', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('Present', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
                  Text('Absent', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
                  Text('Late', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
                  Text('Leave', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
              ...controller.trendData.map((month) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(month['month'] ?? '', style: const TextStyle(fontSize: 12)),
                  ),
                  Text('${month['present'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontSize: 12)),
                  Text('${month['absent'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 12)),
                  Text('${month['late'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange, fontSize: 12)),
                  Text('${month['leave'] ?? 0}', textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontSize: 12)),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  // ============== DATE SELECTORS (for Employee-wise tab) ==============
  void _showDateSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month, color: Colors.blue),
                ),
                title: const Text('Monthly View'),
                subtitle: Obx(() => Text(
                  '${_getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}'
                )),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showMonthPicker();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.green),
                ),
                title: const Text('Yearly View'),
                subtitle: Obx(() => Text('${controller.selectedYear.value}')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showYearPicker();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.date_range, color: Colors.orange),
                ),
                title: const Text('Custom Range'),
                subtitle: Obx(() {
                  if (controller.customStartDate.value != null && 
                      controller.customEndDate.value != null) {
                    return Text(
                      '${controller.customStartDate.value!.day} ${_getMonthName(controller.customStartDate.value!.month)} - '
                      '${controller.customEndDate.value!.day} ${_getMonthName(controller.customEndDate.value!.month)} ${controller.customEndDate.value!.year}'
                    );
                  }
                  return const Text('Select any date range');
                }),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showCustomRangePicker();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(controller.selectedYear.value, controller.selectedMonth.value),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDatePickerMode: DatePickerMode.year,
      selectableDayPredicate: (DateTime date) => false,
    );

    if (picked != null) {
      controller.setMonth(picked.month);
      controller.setYear(picked.year);
    }
  }

  void _showYearPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(controller.selectedYear.value),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      controller.setYear(picked.year);
    }
  }

  void _showCustomRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: controller.customStartDate.value != null && 
          controller.customEndDate.value != null
          ? DateTimeRange(
              start: controller.customStartDate.value!,
              end: controller.customEndDate.value!
            )
          : null,
    );

    if (picked != null) {
      controller.setCustomRange(picked.start, picked.end);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
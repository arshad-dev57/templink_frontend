// lib/Employer/Screens/employer_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_attendance_history_controller.dart';
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

class EmployerAttendanceScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const EmployerAttendanceScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

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
                child: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
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
                const Icon(Icons.assignment_turned_in, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text('Attendance', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Track employee attendance', style: TextStyle(color: Colors.white70, fontSize: 11)),
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
          const Text('Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: _showDateSelector,
            tooltip: 'Select Date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => controller.refreshAll(),
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
        title: const Text('Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _showDateSelector,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => controller.refreshAll(),
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
            Tab(text: 'Today'),
            Tab(text: 'Employee-wise'),
            Tab(text: 'Monthly'),
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
        _buildTodayTab(isWeb, isDesktop),
        _buildEmployeeWiseTab(isWeb, isDesktop),
        _buildMonthlyTrendTab(isWeb),
      ],
    );
  }

  // ==================== TODAY TAB ====================
  Widget _buildTodayTab(bool isWeb, bool isDesktop) {
    return Obx(() {
      if (controller.isLoadingToday.value) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      if (isWeb) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTodaySummaryCardWeb(),
              const SizedBox(height: 20),
              _buildTodayRecordsGrid(controller.todayAttendanceList, isDesktop),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            _buildTodaySummaryCardMobile(),
            const SizedBox(height: 16),
            _buildTodayRecordsList(controller.todayAttendanceList),
          ],
        ),
      );
    });
  }

  Widget _buildTodaySummaryCardWeb() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('Present', controller.todayPresentString, _success, Icons.check_circle),
          _buildSummaryStat('Late', controller.todayLateString, _warning, Icons.access_time),
          _buildSummaryStat('Absent', controller.todayAbsentString, _error, Icons.cancel),
          _buildSummaryStat('Leave', controller.todayLeaveString, _info, Icons.beach_access),
        ],
      ),
    );
  }

  Widget _buildTodaySummaryCardMobile() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat('Present', controller.todayPresentString, _success, Icons.check_circle),
              _buildSummaryStat('Late', controller.todayLateString, _warning, Icons.access_time),
              _buildSummaryStat('Absent', controller.todayAbsentString, _error, Icons.cancel),
              _buildSummaryStat('Leave', controller.todayLeaveString, _info, Icons.beach_access),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: controller.todayAttendanceBarValue,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(_success),
            ),
          ),
          const SizedBox(height: 8),
          Text('${controller.todayPresentPercentage}% Present Today', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildTodayRecordsGrid(List<Map<String, dynamic>> records, bool isDesktop) {
    if (records.isEmpty) {
      return _buildEmptyState('No attendance records for today');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: records.length,
      itemBuilder: (context, index) => _buildAttendanceRecordCard(records[index]),
    );
  }

  Widget _buildTodayRecordsList(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return _buildEmptyState('No attendance records for today');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: records.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildAttendanceRecordCard(records[index]),
      ),
    );
  }

  // ==================== ATTENDANCE RECORD CARD ====================
  Widget _buildAttendanceRecordCard(Map<String, dynamic> record) {
    final status = record['status'] ?? 'absent';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(status);
    
    final checkIn = record['checkIn'] != null ? DateTime.parse(record['checkIn']).toLocal() : null;
    final checkOut = record['checkOut'] != null ? DateTime.parse(record['checkOut']).toLocal() : null;
    final isLate = record['isLate'] ?? false;
    final lateMinutes = record['lateMinutes'] ?? 0;

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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: primary.withOpacity(0.1),
                      child: Text(record['initials'] ?? '--', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(width: 12, height: 12, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record['name'] ?? 'Unknown', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1)),
                      Text(record['title'] ?? 'Employee', style: TextStyle(fontSize: 12, color: _text2)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTimeBox('Check In', checkIn != null ? '${checkIn.hour.toString().padLeft(2, '0')}:${checkIn.minute.toString().padLeft(2, '0')}' : '--:--', _success),
                const SizedBox(width: 8),
                _buildTimeBox('Check Out', checkOut != null ? '${checkOut.hour.toString().padLeft(2, '0')}:${checkOut.minute.toString().padLeft(2, '0')}' : '--:--', _error),
              ],
            ),
            if (isLate && status == 'late') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: _warning, size: 14),
                    const SizedBox(width: 6),
                    Text('Late by $lateMinutes minutes', style: TextStyle(color: _warning, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String label, String time, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Icon(label == 'Check In' ? Icons.login : Icons.logout, size: 14, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 9, color: _text3)),
            Text(time, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1)),
          ],
        ),
      ),
    );
  }

  // ==================== EMPLOYEE-WISE TAB ====================
  Widget _buildEmployeeWiseTab(bool isWeb, bool isDesktop) {
    return Obx(() {
      if (controller.isLoading.value && controller.employees.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      return Column(
        children: [
          _buildViewSelector(isWeb),
          Expanded(
            child: controller.selectedEmployee.value == null
                ? isWeb
                    ? _buildEmployeeGrid(controller.employees, isDesktop)
                    : _buildEmployeeList(controller.employees)
                : _buildEmployeeDetailView(isWeb),
          ),
        ],
      );
    });
  }

  Widget _buildViewSelector(bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      color: _surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
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
              decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: primary, size: 14),
                  const SizedBox(width: 4),
                  Text(controller.selectedPeriod.value, style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12)),
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
            color: controller.selectedView.value == value ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            color: controller.selectedView.value == value ? Colors.white : _text2,
            fontWeight: FontWeight.w600, fontSize: 13,
          )),
        ),
      )),
    );
  }

  Widget _buildEmployeeGrid(List<Map<String, dynamic>> employees, bool isDesktop) {
    if (employees.isEmpty) {
      return _buildEmptyState('No attendance data found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) => _buildEmployeeCard(employees[index]),
    );
  }

  Widget _buildEmployeeList(List<Map<String, dynamic>> employees) {
    if (employees.isEmpty) {
      return _buildEmptyState('No attendance data found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employees.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildEmployeeCard(employees[index]),
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> employee) {
    final stats = employee['stats'] ?? {};
    final workingHours = _parseHours(stats['workingHours']);
    final overtimeVal = _parseHours(stats['overtime']);
    final showOvertime = overtimeVal != '0h' && overtimeVal != '0.0h';

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => controller.fetchEmployeeDetails(employee['employeeId']),
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 28, backgroundColor: primary.withOpacity(0.1), child: Text(employee['initials'] ?? '--', style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee['name'] ?? 'Unknown', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1)),
                        Text('${employee['designation'] ?? ''} • ${employee['department'] ?? ''}', style: TextStyle(fontSize: 11, color: _text2)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: _text3, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBadge('Present', '${stats['present'] ?? 0}', _success),
                  _buildStatBadge('Absent', '${stats['absent'] ?? 0}', _error),
                  _buildStatBadge('Late', '${stats['late'] ?? 0}', _warning),
                  _buildStatBadge('Leave', '${stats['leave'] ?? 0}', _info),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: _text3),
                      const SizedBox(width: 4),
                      Text('Working: $workingHours', style: TextStyle(fontSize: 11, color: _text2)),
                    ],
                  ),
                  if (showOvertime)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: _warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('OT: $overtimeVal', style: TextStyle(color: _warning, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: _text3)),
      ],
    );
  }

  Widget _buildEmployeeDetailView(bool isWeb) {
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      final employee = controller.selectedEmployee.value;
      if (employee == null) return const SizedBox();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: controller.clearSelectedEmployee),
                const SizedBox(width: 8),
                Expanded(child: Text(employee['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
              child: Row(
                children: [
                  CircleAvatar(radius: 40, backgroundColor: primary.withOpacity(0.1), child: Text(employee['initials'] ?? '--', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 20))),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee['designation'] ?? '', style: TextStyle(color: _text2, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(employee['department'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (controller.employeeRecords.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Records', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...controller.employeeRecords.map((record) => _buildDailyRecordRow(record)),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDailyRecordRow(Map<String, dynamic> record) {
    final statusColor = _getStatusColor(record['status']);
    final statusText = _getStatusText(record['status']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.calendar_today, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.formatDate(DateTime.parse(record['date'])), style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.login, size: 12, color: _text3),
                    const SizedBox(width: 2),
                    Text(record['checkIn'] != null ? controller.formatTime(DateTime.parse(record['checkIn'])) : '--:--', style: TextStyle(fontSize: 11, color: _text2)),
                    const SizedBox(width: 8),
                    Icon(Icons.logout, size: 12, color: _text3),
                    const SizedBox(width: 2),
                    Text(record['checkOut'] != null ? controller.formatTime(DateTime.parse(record['checkOut'])) : '--:--', style: TextStyle(fontSize: 11, color: _text2)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==================== MONTHLY TREND TAB ====================
  Widget _buildMonthlyTrendTab(bool isWeb) {
    return Obx(() {
      if (controller.isLoading.value && controller.trendData.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Yearly Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Obx(() => GestureDetector(
                        onTap: _showYearPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Text('${controller.selectedYear.value}', style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12)),
                              const Icon(Icons.arrow_drop_down, color: primary, size: 16),
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
                                    Container(
                                      width: 30, margin: const EdgeInsets.only(left: 15),
                                      decoration: BoxDecoration(color: _success.withOpacity(0.2), borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                        Container(height: (data['present'] ?? 0) * 1.5, width: 30, decoration: BoxDecoration(color: _success, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
                                      ]),
                                    ),
                                    Positioned(
                                      top: 10, left: 0,
                                      child: Container(width: 20, height: (data['late'] ?? 0) * 0.8, decoration: BoxDecoration(color: _warning, borderRadius: BorderRadius.circular(2))),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(data['month'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
                      _buildLegendItem('Present', _success),
                      const SizedBox(width: 16),
                      _buildLegendItem('Late', _warning),
                      const SizedBox(width: 16),
                      _buildLegendItem('Absent', _error),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (controller.trendData.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
                child: Column(
                  children: [
                    const Text('Monthly Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: isWeb ? 40 : 20,
                        headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[50]),
                        columns: const [
                          DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.w600))),
                          DataColumn(label: Text('Present', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                          DataColumn(label: Text('Absent', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                          DataColumn(label: Text('Late', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                          DataColumn(label: Text('Leave', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                        ],
                        rows: controller.trendData.map((month) => DataRow(
                          cells: [
                            DataCell(Text(month['month'] ?? '')),
                            DataCell(Text('${month['present'] ?? 0}', style: const TextStyle(color: _success))),
                            DataCell(Text('${month['absent'] ?? 0}', style: const TextStyle(color: _error))),
                            DataCell(Text('${month['late'] ?? 0}', style: const TextStyle(color: _warning))),
                            DataCell(Text('${month['leave'] ?? 0}', style: const TextStyle(color: _info))),
                          ],
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  // ==================== HELPER METHODS ====================
  String _parseHours(dynamic value) {
    if (value == null) return '0h';
    String strVal = value.toString().trim();
    if (strVal.isEmpty || strVal == 'null') return '0h';
    if (strVal.endsWith('h')) {
      final parsed = double.tryParse(strVal.replaceAll('h', '').trim());
      if (parsed == null || parsed <= 0) return '0h';
      return '${parsed.toStringAsFixed(1)}h';
    }
    final numVal = double.tryParse(strVal);
    if (numVal == null || numVal <= 0) return '0h';
    return '${numVal.toStringAsFixed(1)}h';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present': return _success;
      case 'late': return _warning;
      case 'absent': return _error;
      case 'leave': return _info;
      default: return _text3;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present': return Icons.check_circle;
      case 'late': return Icons.access_time;
      case 'absent': return Icons.cancel;
      case 'leave': return Icons.beach_access;
      default: return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present': return 'Present';
      case 'late': return 'Late';
      case 'absent': return 'Absent';
      case 'leave': return 'On Leave';
      default: return 'Unknown';
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(Icons.inbox, size: 40, color: primary)),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text1)),
        ],
      ),
    );
  }

  // ==================== DATE SELECTORS ====================
  void _showDateSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDateOption(Icons.calendar_month, 'Monthly View', () {
              Navigator.pop(context);
              _showMonthPicker();
            }, Colors.blue),
            _buildDateOption(Icons.calendar_today, 'Yearly View', () {
              Navigator.pop(context);
              _showYearPicker();
            }, Colors.green),
            _buildDateOption(Icons.date_range, 'Custom Range', () {
              Navigator.pop(context);
              _showCustomRangePicker();
            }, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildDateOption(IconData icon, String title, VoidCallback onTap, Color color) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
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
    if (picked != null) controller.setYear(picked.year);
  }

  void _showCustomRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: controller.customStartDate.value != null && controller.customEndDate.value != null
          ? DateTimeRange(start: controller.customStartDate.value!, end: controller.customEndDate.value!)
          : null,
    );
    if (picked != null) controller.setCustomRange(picked.start, picked.end);
  }
}
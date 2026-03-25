// screens/employer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:templink/Employee/Controllers/employee_leave_controller.dart';
import 'package:templink/Employee/Screens/employee_leave_screen.dart';
import 'package:templink/Employeer/Controller/employer_attandance_dashboard_controller.dart';
import 'package:templink/Employeer/Screens/Employer_Job_Applications_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_my_jobs_screens.dart';
import 'package:templink/Employeer/Screens/Employer_tasks_screen.dart';
import 'package:templink/Employeer/Screens/employer_attandance_screen.dart';
import 'package:templink/Employeer/Screens/employer_interested_screen.dart';
import 'package:templink/Employeer/Screens/employer_leave_approval_screen.dart';
import 'package:templink/Employeer/Screens/employer_payroll_screen.dart';
import 'package:templink/Employeer/Screens/employer_timesheet_approval_screen.dart';
import 'package:templink/Employeer/Screens/hired_employees_screen.dart';
import 'package:templink/Utils/colors.dart';

class EmployerHubDashboardScreen extends StatefulWidget {
  const EmployerHubDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmployerHubDashboardScreen> createState() =>
      _EmployerHubDashboardScreenState();
}

class _EmployerHubDashboardScreenState
    extends State<EmployerHubDashboardScreen> {
  
  // Controllers
  final EmployerAttendanceDashboardController dashboardController = Get.put(EmployerAttendanceDashboardController());

  // Today's leave requests
  final List<Map<String, dynamic>> todayLeaves = [
    {
      'name': 'Emily Davis',
      'initials': 'ED',
      'type': 'Annual Leave',
      'duration': 'Full Day',
      'reason': 'Family vacation',
      'avatarColor': Colors.blue,
    },
    {
      'name': 'Ali Hassan',
      'initials': 'AH',
      'type': 'Sick Leave',
      'duration': 'Half Day',
      'reason': 'Doctor appointment',
      'avatarColor': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> recentActivities = [
    {
      'message': 'John Doe checked in at 08:52',
      'time': '9:02 AM',
      'icon': Icons.login_rounded,
      'color': Colors.green,
    },
    {
      'message': 'Sarah Smith checked in at 08:48',
      'time': '8:50 AM',
      'icon': Icons.login_rounded,
      'color': Colors.green,
    },
    {
      'message': 'Mike Johnson marked late – 09:18',
      'time': '9:20 AM',
      'icon': Icons.schedule,
      'color': Colors.orange,
    },
    {
      'message': 'Emily Davis requested leave',
      'time': 'Yesterday',
      'icon': Icons.event_available_outlined,
      'color': primary,
    },
  ];

  // ── Helpers ──
  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _stringToTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing time: $e');
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // ── Office Timing Dialog ──
  void _showOfficeTimingDialog() {
    TimeOfDay tempStart = _stringToTimeOfDay(dashboardController.checkInTime.value);
    TimeOfDay tempEnd = _stringToTimeOfDay(dashboardController.checkOutTime.value);
    int tempGracePeriod = dashboardController.gracePeriod.value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(Icons.access_time_rounded,
                        color: primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Office Hours',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Employees checking in after grace period will be marked Late.',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 12, height: 1.5),
                ),
                const SizedBox(height: 20),
                _buildTimePickerRow(
                  ctx,
                  label: 'Check-in Time',
                  icon: Icons.login_rounded,
                  time: tempStart,
                  color: Colors.green,
                  onTap: () async {
                    final p = await showTimePicker(
                        context: ctx, initialTime: tempStart);
                    if (p != null) setDialogState(() => tempStart = p);
                  },
                ),
                const SizedBox(height: 12),
                _buildTimePickerRow(
                  ctx,
                  label: 'Check-out Time',
                  icon: Icons.logout_rounded,
                  time: tempEnd,
                  color: Colors.red,
                  onTap: () async {
                    final p = await showTimePicker(
                        context: ctx, initialTime: tempEnd);
                    if (p != null) setDialogState(() => tempEnd = p);
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grace Period',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$tempGracePeriod min',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: tempGracePeriod.toDouble(),
                      min: 0,
                      max: 30,
                      divisions: 30,
                      activeColor: primary,
                      inactiveColor: Colors.grey[300],
                      label: '$tempGracePeriod minutes',
                      onChanged: (value) {
                        setDialogState(() {
                          tempGracePeriod = value.toInt();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0 min',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          '30 min',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Employees checking in after ${_formatTime(_addMinutes(tempStart, tempGracePeriod))} will be marked LATE',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => dashboardController.isUpdatingOfficeHours.value
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              String checkInStr = _timeOfDayToString(tempStart);
                              String checkOutStr = _timeOfDayToString(tempEnd);
                              
                              bool success = await dashboardController.updateOfficeHours(
                                checkIn: checkInStr,
                                checkOut: checkOutStr,
                                gracePeriod: tempGracePeriod,
                              );
                              
                              if (success) {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(dashboardController.successMessage.value),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                Navigator.pop(ctx);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(dashboardController.errorMessage.value),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Save Office Hours',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(BuildContext ctx,
      {required String label,
      required IconData icon,
      required TimeOfDay time,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(_formatTime(time),
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ]),
          const Spacer(),
          Icon(Icons.edit_outlined, color: color.withOpacity(0.5), size: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            dashboardController.refreshAllStats(),
            // dashboardController.refreshAttendance(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroHeader(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildStatsRow(context),
              const SizedBox(height: 24),
              _buildOfficeTiming(context),
              const SizedBox(height: 24),
              _buildTodayAttendance(context), // 👈 Updated with real data
              const SizedBox(height: 24),
              _buildTodayLeaves(),
              const SizedBox(height: 24),
              _buildTaskSummary(context),
              const SizedBox(height: 24),
              _buildRecentActivitySection(context),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Dashboard',
        style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () {},
              ),
            ),
            Positioned(
              top: 10,
              right: 18,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.business_rounded, size: 32, color: primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tech Solutions Inc.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.white60),
                    const SizedBox(width: 3),
                    Text('San Francisco, CA',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFF69F0AE), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('Verified',
                            style: TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Overview'),
          const SizedBox(height: 14),
          Obx(() {
            if (dashboardController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Row(children: [
                  _statCard(
                    'Total Team', 
                    dashboardController.totalTeamString, 
                    Icons.groups_rounded, 
                    primary,
                    onTap: () {
                      Get.to(HiredEmployeesScreen());
                    },
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    'Recieved Applicantions', 
                    dashboardController.jobApplicationsString, 
                    Icons.work_outline_rounded, 
                    Colors.orange,
                    onTap: () {
                      Get.to(EmployerJobApplicationsScreen());
                    },
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _statCard(
                    'Requested Candidates', 
                    dashboardController.hiringRequestsString, 
                    Icons.person_off_rounded, 
                    Colors.red,
                    onTap: () {
                      Get.to(EmployerInterestedScreen());
                    },
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    'My Jobs', 
                    dashboardController.activeJobsString, 
                    Icons.business_center, 
                    Colors.red,
                    onTap: () {
                      Get.to(EmployerJobsScreen());
                    },
                  ),
                ]),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    String count,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.07),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficeTiming(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Office Hours'),
          const SizedBox(height: 14),
          Obx(() {
            if (dashboardController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return GestureDetector(
              onTap: _showOfficeTimingDialog,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(children: [
                  Expanded(
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.login_rounded,
                            color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Check-in',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                            Obx(() => Text(
                                  dashboardController.formattedCheckIn,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      letterSpacing: -0.3),
                                )),
                          ]),
                    ]),
                  ),
                  Column(children: [
                    Container(
                      width: 1,
                      height: 32,
                      color: Colors.grey.withOpacity(0.15),
                    ),
                  ]),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Check-out',
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                              Obx(() => Text(
                                    dashboardController.formattedCheckOut,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: -0.3),
                                  )),
                            ]),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Icon(Icons.edit_outlined, color: primary, size: 14),
                      const SizedBox(width: 4),
                      Text('Edit',
                          style: TextStyle(
                              color: primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              Icon(Icons.info_outline, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Obx(() => Text(
                'Grace period: ${dashboardController.gracePeriod} min. Late after ${dashboardController.formattedLateThreshold}',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              )),
            ]),
          ),
        ],
      ),
    );
  }

  // ==================== UPDATED TODAY'S ATTENDANCE SECTION ====================
  Widget _buildTodayAttendance(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionLabel("Today's Attendance"),
              _buildViewAllButton(() {
                Get.to(EmployerAttendanceScreen());
              }),
            ],
          ),
          const SizedBox(height: 14),
          
          // Loading state
          Obx(() {
            if (dashboardController.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Summary Banner
            return Container(
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
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _attendancePill(
                      dashboardController.presentCountString, 
                      'Present', 
                      Colors.green
                    ),
                    _vDivider(),
                    _attendancePill(
                      dashboardController.lateCountString, 
                      'Late', 
                      Colors.orange
                    ),
                    _vDivider(),
                    _attendancePill(
                      dashboardController.absentCountString, 
                      'Absent', 
                      Colors.red
                    ),
                    _vDivider(),
                    _attendancePill(
                      dashboardController.leaveCountString, 
                      'Leave', 
                      Colors.blue
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Attendance Rate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance Rate',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${dashboardController.presentPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: dashboardController.presentBarValue,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Summary Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${dashboardController.presentPercentage}% Present',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${dashboardController.absentTotal} Absent',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ]),
            );
          }),
          
          const SizedBox(height: 16),
          
          // Quick Employee List (Top 3)
          Obx(() {
            if (dashboardController.attendanceList.isEmpty) {
              return const SizedBox();
            }
            
            return Column(
              children: dashboardController.attendanceList
                  .take(3)
                  .map((employee) => _buildEmployeeRow(employee))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _attendancePill(String count, String label, Color color) {
    return Column(children: [
      Text(count,
          style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.8), fontSize: 11)),
    ]);
  }

  Widget _vDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.2),
    );
  }

  // Employee Row for quick view
  Widget _buildEmployeeRow(Map<String, dynamic> employee) {
    Color statusColor = dashboardController.getStatusColor(employee['status'] ?? 'absent');
    String statusText = dashboardController.getStatusText(employee['status'] ?? 'absent');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: primary.withOpacity(0.1),
            child: Text(
              employee['initials'] ?? '--',
              style: TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  employee['title'] ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (employee['checkIn'] != null)
            Text(
              dashboardController.formatDateTime(DateTime.parse(employee['checkIn'])),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }// ==================== TODAY'S LEAVES SECTION WITH EMPTY STATE ====================
Widget _buildTodayLeaves() {
  return Obx(() {
    // Leave controller ko Get karo
    final leaveController = Get.put(EmployeeLeaveController());
    
    // Sirf pending leaves filter karo jo aaj ki hain
    final todayLeaves = leaveController.todayPendingLeaves;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Today's Leaves",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (todayLeaves.isNotEmpty) // ✅ Sirf tab count dikhao jab kuch ho
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${todayLeaves.length}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
           
            ],
          ),
          const SizedBox(height: 12),
          
          // ✅ Empty State ya List
          if (todayLeaves.isEmpty)
            _buildEmptyLeavesState()
          else
            Column(
              children: todayLeaves.map((leave) => _buildLeaveCard(leave)).toList(),
            ),
        ],
      ),
    );
  });
}

// ==================== EMPTY STATE WIDGET ====================
Widget _buildEmptyLeavesState() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
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
      children: [
        Icon(
          Icons.beach_access,
          size: 48,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 12),
        Text(
          'No leave requests for today',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'All clear! No one is on leave today',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    ),
  );
}

// ==================== LEAVE CARD ====================
Widget _buildLeaveCard(Map<String, dynamic> leave) {
  Color typeColor = leave['type'] == 'Annual Leave'
      ? Colors.blue
      : leave['type'] == 'Sick Leave'
          ? Colors.green
          : leave['type'] == 'Casual Leave'
              ? Colors.orange
              : Colors.purple;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
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
    child: Row(
      children: [
        // Avatar with type color
        CircleAvatar(
          radius: 24,
          backgroundColor: typeColor.withOpacity(0.1),
          child: Icon(
            leave['type'] == 'Annual Leave'
                ? Icons.beach_access
                : leave['type'] == 'Sick Leave'
                    ? Icons.local_hospital
                    : Icons.access_time,
            color: typeColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        
        // Leave Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leave['type'] ?? 'Leave Request',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateRange(leave['fromDate'], leave['toDate']),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Reason: ${leave['reason'] ?? 'Not specified'}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'PENDING',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}


String _formatDateRange(String? from, String? to) {
  if (from == null || to == null) return '';
  try {
    final fromDate = DateTime.parse(from);
    final toDate = DateTime.parse(to);
    final dateFormat = DateFormat('MMM dd');
    
    if (fromDate.day == toDate.day) {
      return dateFormat.format(fromDate);
    }
    return '${dateFormat.format(fromDate)} - ${dateFormat.format(toDate)}';
  } catch (e) {
    return '$from - $to';
  }
}
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Quick Actions'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionBtn(Icons.calendar_month_rounded, 'Attendance',
                  Colors.orange, onTap: () {
                Get.to(EmployerAttendanceScreen());
              }),
               _actionBtn(Icons.timer, 'Timesheet',
                  const Color.fromARGB(255, 152, 142, 181), onTap: () {
                Get.to(EmployerTimesheetApprovalScreen());
              }),
            
              _actionBtn(Icons.check_circle_outline_rounded, 'Leave Approvals',
                  Colors.green, onTap: () {
                Get.to(EmployerLeaveApprovalScreen());
              }),
              _actionBtn(Icons.people_outline_rounded, 'Team',
                  const Color(0xFF7C4DFF), onTap: () {
                Get.to(HiredEmployeesScreen());
              }),
            ],
          ),
       
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildTaskSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Get.to(() => const EmployerTasksScreen());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.assignment, color: primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Task Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right, color: primary, size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTaskStat('Pending', '8', Colors.orange),
                    _buildTaskStat('In Progress', '10', Colors.blue),
                    _buildTaskStat('Completed', '6', Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '3 tasks due this week',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '2 Overdue',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskStat(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 20,
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

  Widget _buildRecentActivitySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionLabel('Recent Activity'),
              _buildViewAllButton(() {}),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(recentActivities.length, (i) {
                final a = recentActivities[i];
                final isLast = i == recentActivities.length - 1;
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (a['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(a['icon'] as IconData,
                            color: a['color'] as Color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(a['message'],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      Text(a['time'],
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 10)),
                    ]),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 62,
                      endIndent: 14,
                      color: Colors.grey.withOpacity(0.08),
                    ),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2));
  }

  Widget _buildViewAllButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Text('View All',
            style: TextStyle(
                color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 2),
        Icon(Icons.chevron_right, color: primary, size: 16),
      ]),
    );
  }
}
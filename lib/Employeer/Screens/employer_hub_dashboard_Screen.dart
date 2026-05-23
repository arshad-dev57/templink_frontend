import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:templink/Employee/Controllers/employee_leave_controller.dart';
import 'package:templink/Employee/Screens/employee_leave_screen.dart';
import 'package:templink/Employeer/Controller/employer_attandance_dashboard_controller.dart';
import 'package:templink/Employeer/Controller/employer_task_controller.dart';
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
    extends State<EmployerHubDashboardScreen> with TickerProviderStateMixin {
  final EmployerAttendanceDashboardController dashboardController =
      Get.put(EmployerAttendanceDashboardController());
  final TaskController taskController = Get.put(TaskController());

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

  @override
  void initState() {
    super.initState();
    taskController.initForEmployer();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showOfficeTimingDialog() {
    TimeOfDay tempStart =
        _stringToTimeOfDay(dashboardController.checkInTime.value);
    TimeOfDay tempEnd =
        _stringToTimeOfDay(dashboardController.checkOutTime.value);
    int tempGracePeriod = dashboardController.gracePeriod.value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
                  Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, primary.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.access_time_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Office Hours',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: -0.5)),
                        Text('Configure work schedule',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Time pickers
                  _buildTimePickerRow(ctx,
                      label: 'Check-in Time',
                      icon: Icons.login_rounded,
                      time: tempStart,
                      color: const Color(0xFF22C55E),
                      onTap: () async {
                        final p = await showTimePicker(
                            context: ctx, initialTime: tempStart);
                        if (p != null) setDialogState(() => tempStart = p);
                      }),
                  const SizedBox(height: 10),
                  _buildTimePickerRow(ctx,
                      label: 'Check-out Time',
                      icon: Icons.logout_rounded,
                      time: tempEnd,
                      color: const Color(0xFFEF4444),
                      onTap: () async {
                        final p = await showTimePicker(
                            context: ctx, initialTime: tempEnd);
                        if (p != null) setDialogState(() => tempEnd = p);
                      }),
                  const SizedBox(height: 20),

                  // Grace Period Slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Grace Period',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                    fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('$tempGracePeriod min',
                                  style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            thumbColor: primary,
                            activeTrackColor: primary,
                            inactiveTrackColor: Colors.grey[200],
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape:
                                const RoundSliderOverlayShape(overlayRadius: 16),
                          ),
                          child: Slider(
                            value: tempGracePeriod.toDouble(),
                            min: 0,
                            max: 30,
                            divisions: 30,
                            label: '$tempGracePeriod minutes',
                            onChanged: (value) {
                              setDialogState(() =>
                                  tempGracePeriod = value.toInt());
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0 min',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[400])),
                            Text('30 min',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey[400])),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Info Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                          size: 15, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Late after ${_formatTime(_addMinutes(tempStart, tempGracePeriod))}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  Obx(() => dashboardController.isUpdatingOfficeHours.value
                      ? const Center(
                          child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool success =
                                  await dashboardController.updateOfficeHours(
                                checkIn: _timeOfDayToString(tempStart),
                                checkOut: _timeOfDayToString(tempEnd),
                                gracePeriod: tempGracePeriod,
                              );
                              if (success) {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(dashboardController
                                        .successMessage.value),
                                    backgroundColor:
                                        const Color(0xFF22C55E),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                                Navigator.pop(ctx);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(dashboardController
                                        .errorMessage.value),
                                    backgroundColor:
                                        const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Save Changes',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: -0.2)),
                          ),
                        )),
                ],
              ),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.3)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit_rounded, color: color, size: 14),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          color: primary,
          onRefresh: () async {
            await Future.wait([
              dashboardController.refreshAllStats(),
              taskController.fetchTasks(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(context),
                const SizedBox(height: 28),
                _buildQuickActions(context),
                const SizedBox(height: 28),
                _buildStatsRow(context),
                const SizedBox(height: 28),
                _buildOfficeTiming(context),
                const SizedBox(height: 28),
                _buildTodayAttendance(context),
                const SizedBox(height: 28),
                _buildTodayLeaves(),
                const SizedBox(height: 28),
                _buildTaskSummary(context),
                const SizedBox(height: 40),
              ],
            ),
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
      toolbarHeight: 64,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                  color: Colors.white)),
          Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w400)),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () {},
              ),
            ),
            Positioned(
              top: 11,
              right: 19,
              child: Container(
                width: 8,
                height: 8,
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
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 60,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 36),
            child: Row(
              children: [
                // Company Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.business_rounded,
                      size: 30, color: primary),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: Colors.white.withOpacity(0.6)),
                        const SizedBox(width: 3),
                        Text('San Francisco, CA',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 12)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            const Text('Verified',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== OVERVIEW STATS ====================
  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Overview'),
          const SizedBox(height: 16),
          Obx(() {
            if (dashboardController.isLoading.value) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()));
            }
            return Column(
              children: [
                Row(children: [
                  _statCard(
                    'Total Team',
                    dashboardController.totalTeamString,
                    Icons.groups_rounded,
                    primary,
                    subtitle: 'Active members',
                    onTap: () => Get.to(HiredEmployeesScreen()),
                  ),
                  const SizedBox(width: 14),
                  _statCard(
                    'Applications',
                    dashboardController.jobApplicationsString,
                    Icons.inbox_rounded,
                    const Color(0xFFF97316),
                    subtitle: 'Received',
                    onTap: () => Get.to(EmployerJobApplicationsScreen()),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  _statCard(
                    'Candidates',
                    dashboardController.hiringRequestsString,
                    Icons.person_search_rounded,
                    const Color(0xFF8B5CF6),
                    subtitle: 'Requested',
                    onTap: () => Get.to(EmployerInterestedScreen()),
                  ),
                  const SizedBox(width: 14),
                  _statCard(
                    'Active Jobs',
                    dashboardController.activeJobsString,
                    Icons.work_rounded,
                    const Color(0xFF06B6D4),
                    subtitle: 'Open positions',
                    onTap: () => Get.to(EmployerJobsScreen()),
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
    String subtitle = '',
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: Colors.grey[300]),
                ],
              ),
              const SizedBox(height: 14),
              Text(count,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.2)),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== OFFICE TIMING ====================
  Widget _buildOfficeTiming(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Office Hours'),
          const SizedBox(height: 16),
          Obx(() {
            if (dashboardController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return GestureDetector(
              onTap: _showOfficeTimingDialog,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(children: [
                      // Check In
                      Expanded(
                        child: _timeBlock(
                          label: 'Check-in',
                          time: dashboardController.formattedCheckIn,
                          icon: Icons.login_rounded,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                      // Divider with arrow
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 1.5,
                                  color: Colors.grey[200],
                                ),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 16, color: Colors.grey[300]),
                                Container(
                                  width: 20,
                                  height: 1.5,
                                  color: Colors.grey[200],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('8h shift',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      // Check Out
                      Expanded(
                        child: _timeBlock(
                          label: 'Check-out',
                          time: dashboardController.formattedCheckOut,
                          icon: Icons.logout_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    // Grace period bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Grace period: ${dashboardController.gracePeriod} min  ·  Late after ${dashboardController.formattedLateThreshold}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Icon(Icons.edit_rounded,
                                color: primary, size: 12),
                            const SizedBox(width: 4),
                            Text('Edit',
                                style: TextStyle(
                                    color: primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _timeBlock(
      {required String label,
      required String time,
      required IconData icon,
      required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 8),
        Text(time,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.5)),
      ],
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.calendar_month_rounded,
        'label': 'Attendance',
        'color': const Color(0xFFF97316),
        'onTap': () => Get.to(EmployerAttendanceScreen()),
      },
      {
        'icon': Icons.timer_rounded,
        'label': 'Timesheet',
        'color': const Color(0xFF8B5CF6),
        'onTap': () => Get.to(EmployerTimesheetApprovalScreen()),
      },
      {
        'icon': Icons.check_circle_outline_rounded,
        'label': 'Leaves',
        'color': const Color(0xFF22C55E),
        'onTap': () => Get.to(EmployerLeaveApprovalScreen()),
      },
      {
        'icon': Icons.people_outline_rounded,
        'label': 'Team',
        'color': const Color(0xFF06B6D4),
        'onTap': () => Get.to(HiredEmployeesScreen()),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          Row(
            children: actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: action == actions.last ? 0 : 10),
                  child: _actionChip(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    color: action['color'] as Color,
                    onTap: action['onTap'] as VoidCallback,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1)),
        ]),
      ),
    );
  }

  // ==================== TODAY'S ATTENDANCE ====================
  Widget _buildTodayAttendance(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle("Today's Attendance"),
              _viewAllBtn(() => Get.to(EmployerAttendanceScreen())),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (dashboardController.isLoading.value) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()));
            }

            return Column(
              children: [
                // Main Banner
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, Color.lerp(primary, Colors.blue, 0.3)!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(children: [
                    // Four Stat Pills
                    Row(
                      children: [
                        _attendancePill(
                            dashboardController.presentCountString,
                            'Present',
                            const Color(0xFF4ADE80)),
                        _vDivider(),
                        _attendancePill(dashboardController.lateCountString,
                            'Late', const Color(0xFFFBBF24)),
                        _vDivider(),
                        _attendancePill(dashboardController.absentCountString,
                            'Absent', const Color(0xFFFC8181)),
                        _vDivider(),
                        _attendancePill(dashboardController.leaveCountString,
                            'Leave', const Color(0xFF93C5FD)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress bar
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Attendance Rate',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            Text('${dashboardController.presentPercentage}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: -0.3)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: dashboardController.presentBarValue,
                            minHeight: 7,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4ADE80)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${dashboardController.presentPercentage}% present',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 11),
                            ),
                            Text(
                              '${dashboardController.absentTotal} absent',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
                ),

                const SizedBox(height: 14),

                // Employee Quick List
                if (dashboardController.attendanceList.isNotEmpty)
                  Container(
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
                    child: Column(
                      children: dashboardController.attendanceList
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => Column(
                                children: [
                                  _buildEmployeeRow(e.value),
                                  if (e.key < 2)
                                    Divider(
                                        height: 1,
                                        indent: 60,
                                        color: Colors.grey[100]),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _attendancePill(String count, String label, Color color) {
    return Expanded(
      child: Column(children: [
        Text(count,
            style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _vDivider() {
    return Container(
        width: 1, height: 36, color: Colors.white.withOpacity(0.15));
  }

  Widget _buildEmployeeRow(Map<String, dynamic> employee) {
    Color statusColor =
        dashboardController.getStatusColor(employee['status'] ?? 'absent');
    String statusText =
        dashboardController.getStatusText(employee['status'] ?? 'absent');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              employee['initials'] ?? '--',
              style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(employee['name'] ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: -0.2)),
              Text(employee['title'] ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
        ),
        if (employee['checkIn'] != null)
          Text(
            dashboardController
                .formatDateTime(DateTime.parse(employee['checkIn'])),
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500),
          ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(statusText,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2)),
        ),
      ]),
    );
  }

  // ==================== TODAY'S LEAVES ====================
  Widget _buildTodayLeaves() {
    return Obx(() {
      final leaveController = Get.put(EmployeeLeaveController());
      final todayLeaves = leaveController.todayPendingLeaves;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _sectionTitle("Today's Leaves"),
                  if (todayLeaves.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${todayLeaves.length}',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]
                ]),
              ],
            ),
            const SizedBox(height: 16),
            if (todayLeaves.isEmpty)
              _buildEmptyLeavesState()
            else
              Column(
                children:
                    todayLeaves.map((l) => _buildLeaveCard(l)).toList(),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyLeavesState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.beach_access_rounded,
              size: 28, color: Colors.grey[300]),
        ),
        const SizedBox(height: 12),
        Text('All clear today!',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text('No pending leave requests',
            style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ]),
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave) {
    final typeColors = {
      'Annual Leave': const Color(0xFF3B82F6),
      'Sick Leave': const Color(0xFF22C55E),
      'Casual Leave': const Color(0xFFF97316),
    };
    final typeIcons = {
      'Annual Leave': Icons.beach_access_rounded,
      'Sick Leave': Icons.local_hospital_rounded,
      'Casual Leave': Icons.access_time_rounded,
    };
    Color typeColor = typeColors[leave['type']] ?? const Color(0xFF8B5CF6);
    IconData typeIcon =
        typeIcons[leave['type']] ?? Icons.event_note_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leave['type'] ?? 'Leave Request',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: -0.2)),
              const SizedBox(height: 3),
              Text(_formatDateRange(leave['fromDate'], leave['toDate']),
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              Text('${leave['reason'] ?? 'Not specified'}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('PENDING',
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3)),
        ),
      ]),
    );
  }

  String _formatDateRange(String? from, String? to) {
    if (from == null || to == null) return '';
    try {
      final fromDate = DateTime.parse(from);
      final toDate = DateTime.parse(to);
      final fmt = DateFormat('MMM dd');
      return fromDate.day == toDate.day
          ? fmt.format(fromDate)
          : '${fmt.format(fromDate)} – ${fmt.format(toDate)}';
    } catch (e) {
      return '$from - $to';
    }
  }

  // ==================== TASK SUMMARY ====================
  Widget _buildTaskSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Task Summary'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Get.to(() => const EmployerTasksScreen()),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(Icons.assignment_rounded,
                                color: primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text('Tasks',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3)),
                        ]),
                        Row(children: [
                          Text('View All',
                              style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          Icon(Icons.chevron_right_rounded,
                              color: primary, size: 16),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Row
                  Obx(() {
                    final stats = taskController.summaryStats;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(children: [
                        _taskStatBlock('${stats['pending']}', 'Pending',
                            const Color(0xFFF97316)),
                        _taskDot(),
                        _taskStatBlock('${stats['inProgress']}', 'In Progress',
                            const Color(0xFF3B82F6)),
                        _taskDot(),
                        _taskStatBlock('${stats['completed']}', 'Done',
                            const Color(0xFF22C55E)),
                      ]),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
                    ),
                    child: Obx(() {
                      final now = DateTime.now();
                      final tasks = taskController.allTasks;

                      final dueThisWeek = tasks.where((t) {
                        if (t['status'] == 'completed' ||
                            t['status'] == 'cancelled') return false;
                        try {
                          final dueDate = DateTime.parse('${t['dueDate']}');
                          final diff = dueDate.difference(now).inDays;
                          return diff >= 0 && diff <= 7;
                        } catch (e) {
                          return false;
                        }
                      }).length;

                      final overdueTasks = tasks.where((t) {
                        if (t['status'] == 'completed' ||
                            t['status'] == 'cancelled') return false;
                        try {
                          return DateTime.parse('${t['dueDate']}')
                              .isBefore(now);
                        } catch (e) {
                          return false;
                        }
                      }).length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.event_rounded,
                                size: 13,
                                color: dueThisWeek > 0
                                    ? Colors.red[400]
                                    : Colors.grey[500]),
                            const SizedBox(width: 5),
                            Text(
                              '$dueThisWeek due this week',
                              style: TextStyle(
                                  color: dueThisWeek > 0
                                      ? Colors.red[400]
                                      : Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: overdueTasks > 0
                                  ? Colors.orange.withOpacity(0.1)
                                  : const Color(0xFF22C55E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              overdueTasks > 0
                                  ? '$overdueTasks Overdue'
                                  : 'All on track',
                              style: TextStyle(
                                  color: overdueTasks > 0
                                      ? Colors.orange
                                      : const Color(0xFF22C55E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskStatBlock(String count, String label, Color color) {
    return Expanded(
      child: Column(children: [
        Text(count,
            style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _taskDot() {
    return Container(
        width: 1, height: 36, color: Colors.grey[100]);
  }

  // ==================== SHARED HELPERS ====================
  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: Color(0xFF111827)));
  }

  Widget _viewAllBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Text('View All',
            style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        Icon(Icons.chevron_right_rounded, color: primary, size: 16),
      ]),
    );
  }
}
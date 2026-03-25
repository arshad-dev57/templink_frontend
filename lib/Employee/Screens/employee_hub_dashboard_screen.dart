// lib/Employee/Screens/employee_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/employee_attendance_controller.dart';
import 'package:templink/Employee/Screens/employee_leave_screen.dart';
import 'package:templink/Employee/Screens/employee_tasks_screen.dart';
import 'package:templink/Employee/Screens/employee_timesheet_screen.dart';
import '../../Utils/colors.dart';
import '../Screens/employee_profile_screen.dart';

class EmployeeHubDashboardScreen extends StatefulWidget {
  const EmployeeHubDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeHubDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeHubDashboardScreen> {
  final EmployeeAttendanceController attendanceController = Get.put(EmployeeAttendanceController());
  
  // Dummy data for UI (will be replaced with controller data)
  final Map<String, dynamic> employeeData = {
    'name': 'John Doe',
    'title': 'Senior Flutter Developer',
    'initials': 'JD',
    'rating': 4.8,
    'reviews': 24,
    'memberSince': '2024',
    'pointsBalance': 1250,
    'isVerified': true,
    'photoUrl': null,
  };

  final Map<String, dynamic> stats = {
    'totalEarnings': '\$4,250',
    'activeJobs': 3,
    'completedTasks': 12,
    'hoursWorked': 86,
    'upcomingDeadlines': 2,
  };

  final Map<String, dynamic> todayStatus = {
    'isCheckedIn': false,
    'checkInTime': null,
    'currentTask': 'Design Homepage UI',
    'taskProgress': 0.65,
    'breakTime': '45 min',
  };

  final List<Map<String, dynamic>> activeTasks = [
    {
      'title': 'Design Homepage UI',
      'project': 'E-commerce App',
      'deadline': 'Dec 25, 2024',
      'progress': 0.65,
      'priority': 'high',
      'status': 'in_progress',
    },
    {
      'title': 'API Integration',
      'project': 'Payment Gateway',
      'deadline': 'Dec 23, 2024',
      'progress': 0.30,
      'priority': 'urgent',
      'status': 'in_progress',
    },
    {
      'title': 'Bug Fixing',
      'project': 'Login Module',
      'deadline': 'Dec 22, 2024',
      'progress': 0.90,
      'priority': 'high',
      'status': 'review',
    },
  ];

  final List<Map<String, dynamic>> appliedJobs = [
    {
      'title': 'Senior Flutter Developer',
      'company': 'Tech Solutions Inc.',
      'status': 'under_review',
      'appliedDate': '2 days ago',
      'salary': '\$40-50/hr',
    },
    {
      'title': 'Mobile App Developer',
      'company': 'Innovation Labs',
      'status': 'interview',
      'appliedDate': '5 days ago',
      'salary': '\$35-45/hr',
    },
  ];

  final List<Map<String, dynamic>> recentEarnings = [
    {
      'project': 'E-commerce App',
      'amount': '\$850',
      'date': 'Dec 20, 2024',
      'status': 'paid',
    },
    {
      'project': 'Payment Gateway',
      'amount': '\$600',
      'date': 'Dec 18, 2024',
      'status': 'pending',
    },
  ];

  final List<Map<String, dynamic>> upcomingDeadlines = [
    {
      'task': 'API Integration',
      'dueDate': 'Dec 23, 2024',
      'daysLeft': 2,
    },
    {
      'task': 'Design Homepage',
      'dueDate': 'Dec 25, 2024',
      'daysLeft': 4,
    },
  ];

  final List<Map<String, dynamic>> recentActivities = [
    {
      'action': 'Task Completed',
      'description': 'Login page bug fixed',
      'time': '2 hours ago',
      'icon': Icons.task_alt,
      'color': Colors.green,
    },
    {
      'action': 'Payment Received',
      'description': '\$850 credited to wallet',
      'time': '1 day ago',
      'icon': Icons.payments,
      'color': Colors.blue,
    },
    {
      'action': 'Leave Approved',
      'description': 'Dec 24-26 approved',
      'time': '2 days ago',
      'icon': Icons.event_available,
      'color': Colors.orange,
    },
    {
      'action': 'New Task Assigned',
      'description': 'API Integration task',
      'time': '3 days ago',
      'icon': Icons.assignment,
      'color': primary,
    },
  ];

  final List<Map<String, dynamic>> quickActions = [
    {'icon': Icons.task_alt, 'label': 'Tasks', 'color': Colors.blue},
    {'icon': Icons.timer, 'label': 'Timesheet', 'color': Colors.green},
    {'icon': Icons.beach_access, 'label': 'Leave', 'color': Colors.purple},
    {'icon': Icons.person, 'label': 'Profile', 'color': primary},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeHeader(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildTodayStatus(),
            const SizedBox(height: 20),
          
            _buildActiveTasks(),
            const SizedBox(height: 20),
         
          
            _buildUpcomingDeadlines(),
            const SizedBox(height: 20),
          
          ],
        ),
      ),
    );
  }

  // App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Dashboard',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        // Points Balance
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Obx(() => Text(
                '${attendanceController.pointsBalance} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              )),
            ],
          ),
        ),
        // Notifications
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
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
              top: 8,
              right: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
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

  // Employee Header
  Widget _buildEmployeeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Photo
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.1),
              border: Border.all(color: primary.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                employeeData['initials'],
                style: TextStyle(
                  color: primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Employee Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      employeeData['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (employeeData['isVerified'])
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  employeeData['title'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          '${employeeData['rating']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          ' (${employeeData['reviews']} reviews)',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Since ${employeeData['memberSince']}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
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
  // Today's Status with Complete Logic
  Widget _buildTodayStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final isCheckingIn = attendanceController.isCheckingIn.value;
        final isCheckingOut = attendanceController.isCheckingOut.value;
        
        // Get current time and office hours
        final now = DateTime.now();
        final officeStart = attendanceController.getOfficeStartDateTime();
        final officeEnd = attendanceController.getOfficeEndDateTime();
        final checkInStart = attendanceController.getCheckInStartTime();
        final checkInDeadline = attendanceController.getCheckInDeadline();
        final checkOutEnd = attendanceController.getCheckOutEndTime();
        
        // Determine states
        bool canCheckIn = attendanceController.canCheckIn();
        bool canCheckOut = attendanceController.canCheckOut();
        bool isBeforeOfficeHours = now.isBefore(officeStart);
        bool isAfterOfficeHours = now.isAfter(officeEnd);
        bool isWithinCheckInWindow = now.isAfter(checkInStart) && now.isBefore(checkInDeadline);
       bool isWithinCheckOutWindow = attendanceController.canCheckOut();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withBlue(primary.blue + 30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Office Hours Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Office Hours: ${attendanceController.formattedOfficeStart} - ${attendanceController.formattedOfficeEnd}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Today\'s Attendance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Status with appropriate message
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: attendanceController.statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            attendanceController.statusText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      // Show appropriate messages based on state
                      if (!attendanceController.isCheckedIn.value && !attendanceController.isCheckedOut.value) ...[
                        if (isBeforeOfficeHours) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Check-in starts at ${attendanceController.formattedCheckInStart}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ] else if (isWithinCheckInWindow) ...[
                          const SizedBox(height: 4),
                          Text(
                            'You can check in now',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (now.isAfter(checkInDeadline) && now.isBefore(officeEnd)) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'YOU ARE ABSENT TODAY',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else if (isAfterOfficeHours) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Office hours are over',
                            style: TextStyle(
                              color: Colors.orange[300],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                      
                      // Check-in/out times if available
                      if (attendanceController.isCheckedIn.value && 
                          !attendanceController.isCheckedOut.value) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Check-in: ${attendanceController.checkInTimeFormatted}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        if (attendanceController.isLate.value)
                          Text(
                            'Late by ${attendanceController.lateMinutes} min',
                            style: TextStyle(
                              color: Colors.orange[300],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (now.isAfter(officeEnd))
                          Text(
                            'You can check out until ${attendanceController.formattedCheckOutEnd}',
                            style: TextStyle(
                              color: Colors.orange[300],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                      
                      if (attendanceController.isCheckedOut.value) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Check-in: ${attendanceController.checkInTimeFormatted}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Check-out: ${attendanceController.checkOutTimeFormatted}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          'Total: ${attendanceController.totalHours.toStringAsFixed(1)} hrs',
                          style: TextStyle(
                            color: Colors.green[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Button logic based on time
                  if (isCheckingIn || isCheckingOut)
                    const CircularProgressIndicator(color: Colors.white)
                  else if (attendanceController.isCheckedOut.value)
                    // Already checked out
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (attendanceController.isCheckedIn.value)
                    // Checked in - show checkout if within window
                    isWithinCheckOutWindow
                        ? ElevatedButton(
                            onPressed: () async {
                              bool success = await attendanceController.checkOut(
                                locationName: 'Office Location',
                              );
                              if (success) {
                                Get.snackbar(
                                  'Success',
                                  attendanceController.successMessage.value,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                                attendanceController.getTodayAttendance();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Check Out',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              now.isAfter(checkOutEnd) ? 'Check-out closed' : 'Check-out at ${attendanceController.formattedOfficeEnd}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          )
                  else if (isWithinCheckInWindow)
                    // Can check in
                    ElevatedButton(
                      onPressed: () async {
                        bool success = await attendanceController.checkIn(
                          locationName: 'Office Location',
                        );
                        if (success) {
                          Get.snackbar(
                            'Success',
                            attendanceController.successMessage.value,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                          attendanceController.getTodayAttendance();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Check In',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (isBeforeOfficeHours)
                    // Before office hours
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Check-in at ${attendanceController.formattedCheckInStart}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // After deadline - absent
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ABSENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Current Task
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.task_alt, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Task',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            todayStatus['currentTask'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(todayStatus['taskProgress'] * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Quick Actions
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return _buildQuickActionItem(
                  icon: action['icon'],
                  label: action['label'],
                  color: action['color'],
                  onTap: () {
                    _navigateToScreen(action['label']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Active Tasks
  Widget _buildActiveTasks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => const EmployeeTasksScreen());
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                      ),
                    ),
                    Icon(Icons.chevron_right, color: primary, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activeTasks.map((task) => _buildTaskItem(task)),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    Color priorityColor = task['priority'] == 'urgent'
        ? Colors.red
        : task['priority'] == 'high'
            ? Colors.orange
            : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task['project'],
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
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task['priority'].toUpperCase(),
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${task['deadline']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${(task['progress'] * 100).toInt()}%',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: LinearProgressIndicator(
                      value: task['progress'],
                      minHeight: 4,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Upcoming Deadlines
  Widget _buildUpcomingDeadlines() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Upcoming Deadlines',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...upcomingDeadlines.map((deadline) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${deadline['daysLeft']}',
                        style: TextStyle(
                          color: deadline['daysLeft'] < 3 ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                          deadline['task'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Due: ${deadline['dueDate']}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deadline['daysLeft'] < 3
                          ? Colors.red.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${deadline['daysLeft']} days left',
                      style: TextStyle(
                        color: deadline['daysLeft'] < 3 ? Colors.red : Colors.orange,
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
    );
  }

  // Recent Activity
  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
            child: Column(
              children: List.generate(recentActivities.length, (index) {
                final activity = recentActivities[index];
                final isLast = index == recentActivities.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: (activity['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity['icon'] as IconData,
                              color: activity['color'] as Color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['action'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activity['description'],
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            activity['time'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 70,
                        endIndent: 16,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Helper
  void _navigateToScreen(String label) {
    switch (label) {
      case 'Tasks':
        Get.to(() => const EmployeeTasksScreen());
        break;
      case 'Timesheet':
        Get.to(() => const EmployeeTimesheetScreen());
        break;
      case 'Leave':
        Get.to(() => const EmployeeLeaveScreen());
      
      
        break;
      case 'Profile':
        Get.to(() => const EmployeeProfileScreen());
        break;
    }
  }
}
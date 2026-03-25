// lib/Employer/Screens/employer_tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/colors.dart';
import 'employer_create_task_screen.dart';
import 'employer_task_detail_screen.dart';
import 'employer_task_report_screen.dart';

class EmployerTasksScreen extends StatefulWidget {
  const EmployerTasksScreen({Key? key}) : super(key: key);

  @override
  State<EmployerTasksScreen> createState() => _EmployerTasksScreenState();
}

class _EmployerTasksScreenState extends State<EmployerTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'All';

  // Tasks data
  final List<Map<String, dynamic>> allTasks = [
    {
      'id': 'T001',
      'title': 'Design Homepage UI',
      'description': 'Create modern homepage design with Figma',
      'assignedTo': 'Sarah Smith',
      'assignedToId': '002',
      'assignedBy': 'John Manager',
      'department': 'Design',
      'priority': 'high',
      'status': 'in_progress',
      'dueDate': '2024-12-25',
      'createdDate': '2024-12-20',
      'estimatedHours': 8,
      'loggedHours': 3.5,
      'attachments': 2,
      'comments': 5,
    },
    {
      'id': 'T002',
      'title': 'API Integration',
      'description': 'Integrate payment gateway API',
      'assignedTo': 'John Doe',
      'assignedToId': '001',
      'assignedBy': 'John Manager',
      'department': 'Development',
      'priority': 'urgent',
      'status': 'pending',
      'dueDate': '2024-12-23',
      'createdDate': '2024-12-19',
      'estimatedHours': 16,
      'loggedHours': 0,
      'attachments': 1,
      'comments': 2,
    },
    {
      'id': 'T003',
      'title': 'Bug Fixing',
      'description': 'Fix login page bugs on production',
      'assignedTo': 'Mike Johnson',
      'assignedToId': '003',
      'assignedBy': 'John Manager',
      'department': 'Development',
      'priority': 'high',
      'status': 'review',
      'dueDate': '2024-12-22',
      'createdDate': '2024-12-18',
      'estimatedHours': 4,
      'loggedHours': 4,
      'attachments': 0,
      'comments': 3,
    },
    {
      'id': 'T004',
      'title': 'Client Meeting',
      'description': 'Weekly sync with client',
      'assignedTo': 'Emily Davis',
      'assignedToId': '004',
      'assignedBy': 'John Manager',
      'department': 'Management',
      'priority': 'medium',
      'status': 'completed',
      'dueDate': '2024-12-21',
      'createdDate': '2024-12-15',
      'estimatedHours': 2,
      'loggedHours': 2,
      'attachments': 0,
      'comments': 1,
    },
    {
      'id': 'T005',
      'title': 'Database Optimization',
      'description': 'Optimize slow queries',
      'assignedTo': 'Ali Hassan',
      'assignedToId': '005',
      'assignedBy': 'John Manager',
      'department': 'Development',
      'priority': 'high',
      'status': 'in_progress',
      'dueDate': '2024-12-26',
      'createdDate': '2024-12-20',
      'estimatedHours': 12,
      'loggedHours': 5,
      'attachments': 3,
      'comments': 4,
    },
  ];

  // Employees list for reports section
  final List<Map<String, dynamic>> employees = [
    {
      'name': 'John Doe',
      'initials': 'JD',
      'department': 'Development',
      'completed': 12,
      'pending': 4,
      'performance': 85,
    },
    {
      'name': 'Sarah Smith',
      'initials': 'SS',
      'department': 'Design',
      'completed': 8,
      'pending': 6,
      'performance': 75,
    },
    {
      'name': 'Mike Johnson',
      'initials': 'MJ',
      'department': 'Development',
      'completed': 10,
      'pending': 3,
      'performance': 90,
    },
    {
      'name': 'Emily Davis',
      'initials': 'ED',
      'department': 'Management',
      'completed': 5,
      'pending': 2,
      'performance': 100,
    },
    {
      'name': 'Ali Hassan',
      'initials': 'AH',
      'department': 'Development',
      'completed': 7,
      'pending': 5,
      'performance': 70,
    },
  ];

  // Summary stats
  final Map<String, dynamic> taskStats = {
    'total': 24,
    'pending': 8,
    'inProgress': 10,
    'completed': 6,
    'overdue': 3,
  };

  // Department wise tasks
  final List<Map<String, dynamic>> departmentTasks = [
    {'dept': 'Development', 'total': 12, 'completed': 5, 'pending': 7},
    {'dept': 'Design', 'total': 6, 'completed': 2, 'pending': 4},
    {'dept': 'Management', 'total': 4, 'completed': 1, 'pending': 3},
    {'dept': 'Marketing', 'total': 2, 'completed': 0, 'pending': 2},
  ];

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
          'Task Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'All Tasks'),
            Tab(text: 'Reports'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () {
              Get.to(() => const EmployerCreateTaskScreen());
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildAllTasksTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  // ============== OVERVIEW TAB ==============
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildTaskStatusChart(),
          const SizedBox(height: 24),
          _buildDepartmentProgress(),
          const SizedBox(height: 24),
          _buildUpcomingDeadlines(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Tasks', '${taskStats['total']}', Icons.assignment, primary),
        _buildStatCard('Pending', '${taskStats['pending']}', Icons.pending, Colors.orange),
        _buildStatCard('In Progress', '${taskStats['inProgress']}', Icons.autorenew, Colors.blue),
        _buildStatCard('Completed', '${taskStats['completed']}', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusChart() {
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
            'Task Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator('Pending', taskStats['pending'], Colors.orange),
              _buildStatusIndicator('In Progress', taskStats['inProgress'], Colors.blue),
              _buildStatusIndicator('Completed', taskStats['completed'], Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: taskStats['completed'] / taskStats['total'],
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${((taskStats['completed'] / taskStats['total']) * 100).toStringAsFixed(0)}% Completed',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                '${taskStats['overdue']} Overdue',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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

  Widget _buildDepartmentProgress() {
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
            'Department Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...departmentTasks.map((dept) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dept['dept'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${dept['completed']}/${dept['total']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: dept['completed'] / dept['total'],
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      dept['completed'] / dept['total'] > 0.7
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines() {
    final upcomingTasks = allTasks
        .where((t) => t['status'] != 'completed')
        .toList()
        .take(3)
        .toList();

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
                'Upcoming Deadlines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcomingTasks.map((task) => _buildDeadlineItem(task)),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(Map<String, dynamic> task) {
    final dueDate = DateTime.parse(task['dueDate']);
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getPriorityColor(task['priority']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.task_alt,
              color: _getPriorityColor(task['priority']),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Assigned to: ${task['assignedTo']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: daysLeft < 2 ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$daysLeft days left',
                  style: TextStyle(
                    color: daysLeft < 2 ? Colors.red : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                task['dueDate'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============== ALL TASKS TAB ==============
  Widget _buildAllTasksTab() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allTasks.length,
            itemBuilder: (context, index) {
              return _buildTaskCard(allTasks[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Pending', 'In Progress', 'Completed', 'Overdue'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = filter == selectedFilter;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
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
          Get.to(() => EmployerTaskDetailScreen(task: task));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task['priority']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getPriorityIcon(task['priority']),
                      color: _getPriorityColor(task['priority']),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      color: _getStatusColor(task['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(task['status']),
                      style: TextStyle(
                        color: _getStatusColor(task['status']),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTaskInfo(Icons.person_outline, task['assignedTo']),
                  _buildTaskInfo(Icons.calendar_today, task['dueDate']),
                  _buildTaskInfo(Icons.timer, '${task['loggedHours']}/${task['estimatedHours']}h'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTaskMeta(Icons.attach_file, '${task['attachments']}'),
                  const SizedBox(width: 16),
                  _buildTaskMeta(Icons.comment, '${task['comments']}'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task['priority']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task['priority'].toUpperCase(),
                      style: TextStyle(
                        color: _getPriorityColor(task['priority']),
                        fontSize: 9,
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
    );
  }

  Widget _buildTaskInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskMeta(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 2),
        Text(
          count,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ============== REPORTS TAB ==============
  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEmployeePerformance(),
          const SizedBox(height: 20),
          _buildTaskCompletionRate(),
          const SizedBox(height: 20),
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildEmployeePerformance() {
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
                'Employee Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => const EmployerTaskReportScreen());
                },
                child: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...employees.take(3).map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primary.withOpacity(0.1),
                  child: Text(
                    e['initials'],
                    style: TextStyle(
                      color: primary,
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
                        e['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e['performance'] / 100,
                          minHeight: 4,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            e['performance'] > 80 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${e['performance']}%',
                  style: TextStyle(
                    color: e['performance'] > 80 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTaskCompletionRate() {
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
            'Task Completion Rate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompletionStat('This Week', '12/18', '67%', Colors.orange),
              _buildCompletionStat('This Month', '45/60', '75%', Colors.green),
              _buildCompletionStat('Average', '85/120', '71%', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStat(String label, String tasks, String percentage, Color color) {
    return Column(
      children: [
        Text(
          percentage,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tasks,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReports() {
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
            'Recent Reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pie_chart, color: Colors.blue, size: 18),
            ),
            title: const Text('Weekly Task Summary'),
            subtitle: const Text('Dec 15 - Dec 21, 2024'),
            trailing: const Icon(Icons.download_outlined),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assessment, color: Colors.green, size: 18),
            ),
            title: const Text('Employee Performance'),
            subtitle: const Text('December 2024'),
            trailing: const Icon(Icons.download_outlined),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return Icons.priority_high;
      case 'high':
        return Icons.trending_up;
      case 'medium':
        return Icons.remove;
      default:
        return Icons.trending_down;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'review':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'review':
        return 'REVIEW';
      case 'completed':
        return 'DONE';
      default:
        return status.toUpperCase();
    }
  }
}
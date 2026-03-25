// lib/Employer/Screens/employer_task_report_screen.dart
import 'package:flutter/material.dart';
import '../../Utils/colors.dart';

class EmployerTaskReportScreen extends StatelessWidget {
  const EmployerTaskReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Task Reports',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeReportCard(
              name: 'John Doe',
              department: 'Development',
              tasksCompleted: 12,
              tasksPending: 4,
              onTime: 85,
            ),
            const SizedBox(height: 12),
            _buildEmployeeReportCard(
              name: 'Sarah Smith',
              department: 'Design',
              tasksCompleted: 8,
              tasksPending: 6,
              onTime: 75,
            ),
            const SizedBox(height: 12),
            _buildEmployeeReportCard(
              name: 'Mike Johnson',
              department: 'Development',
              tasksCompleted: 10,
              tasksPending: 3,
              onTime: 90,
            ),
            const SizedBox(height: 12),
            _buildEmployeeReportCard(
              name: 'Emily Davis',
              department: 'Management',
              tasksCompleted: 5,
              tasksPending: 2,
              onTime: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeReportCard({
    required String name,
    required String department,
    required int tasksCompleted,
    required int tasksPending,
    required int onTime,
  }) {
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: primary.withOpacity(0.1),
                child: Text(
                  name.split(' ').map((e) => e[0]).join(''),
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      department,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReportStat('Completed', '$tasksCompleted', Colors.green),
              _buildReportStat('Pending', '$tasksPending', Colors.orange),
              _buildReportStat('On Time', '$onTime%', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
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
}
// screens/hired_employees_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/hired_employee_controller.dart';
import 'package:templink/Employeer/model/hired_employee_model.dart';
import 'package:templink/Utils/colors.dart';

class HiredEmployeesScreen extends StatelessWidget {
  HiredEmployeesScreen({Key? key}) : super(key: key);

  final controller = Get.put(HiredEmployeeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Team'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Obx(() => _buildSummaryCards()),
          
          // Status Filter Tabs
          _buildStatusFilter(),
          
          // Employees List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.hiredEmployees.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hiredEmployees.isEmpty) {
                return const Center(
                  child: Text('No employees found'),
                );
              }

              return _buildEmployeesList();
            }),
          ),
        ],
      ),
    );
  }

  // Summary Cards Widget
  Widget _buildSummaryCards() {
    final summary = controller.summary.value;
    if (summary == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSummaryCard(
            title: 'Total',
            count: summary.total,
            color: primary,
            icon: Icons.people,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            title: 'Active',
            count: summary.active,
            color: Colors.green,
            icon: Icons.work,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            title: 'Left',
            count: summary.left,
            color: Colors.orange,
            icon: Icons.exit_to_app,
          ),
          const SizedBox(width: 8),
          _buildSummaryCard(
            title: 'Terminated',
            count: summary.terminated,
            color: Colors.red,
            icon: Icons.cancel,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Status Filter Tabs
  Widget _buildStatusFilter() {
    final statuses = ['all', 'active', 'left', 'terminated'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return Obx(() {
            final isSelected = controller.selectedStatus.value == status;
            return GestureDetector(
              onTap: () => controller.changeStatus(status),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Employees List
  Widget _buildEmployeesList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
          controller.loadNextPage();
        }
        return true;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.hiredEmployees.length + (controller.isLoadMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.hiredEmployees.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final employee = controller.hiredEmployees[index];
          return _buildEmployeeCard(employee);
        },
      ),
    );
  }

  // Employee Card
  Widget _buildEmployeeCard(HiredEmployee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to employee details screen
          Get.toNamed('/employee-details', arguments: employee);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Photo + Name + Status
              Row(
                children: [
                  // Profile Photo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: employee.employeeDetails.employeeProfile.photoUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(employee.employeeDetails.employeeProfile.photoUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey[300],
                    ),
                    child: employee.employeeDetails.employeeProfile.photoUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Name and Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.employeeDetails.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.employeeDetails.employeeProfile.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(employee.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.getStatusColor(employee.status),
                      ),
                    ),
                    child: Text(
                      controller.getStatusText(employee.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.getStatusColor(employee.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Job Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.work_outline,
                      label: 'Job Title',
                      value: employee.jobTitle,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.attach_money,
                      label: 'Hourly Rate',
                      value: '\$${employee.employeeDetails.employeeProfile.hourlyRate}/hr',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Category and Experience
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.category,
                      label: 'Category',
                      value: employee.employeeDetails.employeeProfile.category,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      icon: Icons.star,
                      label: 'Experience',
                      value: employee.employeeDetails.employeeProfile.experienceLevel,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Skills
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: employee.employeeDetails.employeeProfile.skills
                    .take(3) // Max 3 skills dikhao
                    .map((skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 11,
                              color: primary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              
              const SizedBox(height: 12),
              
              // Footer: Hired Date + Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hired Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Hired: ${_formatDate(employee.hiredAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${employee.employeeDetails.employeeProfile.rating.toStringAsFixed(1)} (${employee.employeeDetails.employeeProfile.totalReviews})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Left Info (if left)
              if (employee.status == 'left' && employee.leftReason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Left on: ${_formatDate(employee.leftAt!)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Reason: ${employee.leftReason}',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Info Row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper: Format Date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
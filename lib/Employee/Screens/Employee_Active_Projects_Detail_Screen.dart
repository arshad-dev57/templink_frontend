// screens/employee/employee_project_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/Employee_Active_Project_Controller.dart';
import 'package:templink/Employee/Screens/Employee_Submit_Work_Screen.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart'; 
import 'package:templink/Utils/colors.dart';
import 'package:intl/intl.dart';

class EmployeeProjectDetailsScreen extends StatelessWidget {
  final EmployeeActiveProjectModel project;
  final controller = Get.find<EmployeeActiveProjectController>();
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  EmployeeProjectDetailsScreen({
    super.key,
    required this.project,
  }) {
    // ✅ Fetch latest details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProjectDetails(project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          project.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchProjectDetails(project.id),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ USE selectedProject if available, otherwise fallback to passed project
        final displayProject = controller.selectedProject.value ?? project;
        
        // Debug prints
        print('🎯 Displaying project: ${displayProject.title}');
        print('📊 Milestones count: ${displayProject.milestones.length}');
        if (displayProject.milestones.isNotEmpty) {
          print('✅ First milestone: ${displayProject.milestones.first.title} - ${displayProject.milestones.first.status}');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employer Info Card
              _buildEmployerCard(displayProject),
              
              const SizedBox(height: 20),
              
              // Project Progress Card
              _buildProgressCard(displayProject),
              
              const SizedBox(height: 20),
              
              // Project Details Card
              _buildProjectDetailsCard(displayProject),
              
              const SizedBox(height: 20),
              
              // Milestones Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Milestones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${displayProject.completedMilestones}/${displayProject.totalMilestones} Completed',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Milestones List
              if (displayProject.milestones.isEmpty)
                _buildEmptyMilestones()
              else
                ...displayProject.milestones.map((milestone) => 
                  _buildMilestoneCard(displayProject, milestone)
                ).toList(),
              
              const SizedBox(height: 20),
              
              // Payment Summary Card
              _buildPaymentSummaryCard(displayProject),
              
              const SizedBox(height: 20),
              
              // Contract Info Card
              _buildContractCard(displayProject),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== EMPLOYER CARD ====================
  Widget _buildEmployerCard(EmployeeActiveProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Employer Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              image: project.employerLogo != null
                  ? DecorationImage(
                      image: NetworkImage(project.employerLogo!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: project.employerLogo == null
                ? Center(
                    child: Text(
                      project.employerName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Employer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project.employerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.employerSnapshot['rating'] ?? '4.5'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • ${project.contractStatus}',
                      style: TextStyle(
                        color: project.statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Message Button
          Container(
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: primary),
              onPressed: () {
                // Navigate to chat
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROGRESS CARD ====================
  Widget _buildProgressCard(EmployeeActiveProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: project.progressPercentage,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(project.progressPercentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                label: 'Total Budget',
                value: currencyFormat.format(project.totalBudget),
              ),
              _buildProgressStat(
                label: 'Paid',
                value: currencyFormat.format(project.totalPaid),
              ),
              _buildProgressStat(
                label: 'Remaining',
                value: currencyFormat.format(project.remainingAmount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat({required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailsCard(EmployeeActiveProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Description
          _buildDetailRow(
            icon: Icons.description,
            label: 'Description',
            value: project.description,
          ),
          const Divider(),
          
          // Category & Duration
          Row(
            children: [
              Expanded(
                child: _buildDetailRow(
                  icon: Icons.category,
                  label: 'Category',
                  value: project.category,
                ),
              ),
              Expanded(
                child: _buildDetailRow(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: project.duration,
                ),
              ),
            ],
          ),
          const Divider(),
          
          // Experience Level
          _buildDetailRow(
            icon: Icons.psychology,
            label: 'Experience Level',
            value: project.experienceLevel,
          ),
          const Divider(),
          const Text(
            'Skills Required',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 12,
                    color: primary,
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(),
          const Text(
            'Deliverables',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...project.deliverables.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: primary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMilestones() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No milestones added yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(EmployeeActiveProjectModel project, Milestone milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: milestone.isFunded
              ? Colors.green.withOpacity(0.3)
              : milestone.isCompleted
                  ? Colors.green
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: milestone.statusColor.withOpacity(0.1),
            ),
            child: Icon(
              _getMilestoneIcon(milestone),
              color: milestone.statusColor,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  milestone.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: milestone.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  milestone.statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: milestone.statusColor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
              Text(
                currencyFormat.format(milestone.amount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (milestone.dueDate != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(milestone.dueDate!),
                  style: TextStyle(
                    fontSize: 12,
                    color: milestone.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    milestone.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status Timeline
                  _buildStatusTimeline(milestone),
                  
                  const SizedBox(height: 16),
                  
                  // Action Button for Funded Milestones
                  if (milestone.isFunded) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                         Get.to(EmployeeSubmitWorkScreen(
                          milestone: milestone,
                          project: project,
                         ));
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Submit Work'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Show submission info if already submitted
                  if (milestone.isSubmitted) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_top, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Work Submitted',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                                Text(
                                  'Waiting for employer review',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Show approval info
                  if (milestone.isApproved) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.thumb_up, color: Colors.purple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Approved',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple,
                                  ),
                                ),
                                Text(
                                  'Payment will be released soon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (milestone.isReleased) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payment, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment Released',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Amount added to your wallet',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(Milestone milestone) {
    final steps = [
      {'label': 'Funded', 'status': milestone.isFunded},
      {'label': 'Submitted', 'status': milestone.isSubmitted},
      {'label': 'Approved', 'status': milestone.isApproved},
      {'label': 'Released', 'status': milestone.isReleased},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: steps[index ~/ 2]['status'] as bool &&
                      steps[index ~/ 2 + 1]['status'] as bool
                  ? Colors.green
                  : Colors.grey[300],
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isCompleted = steps[stepIndex]['status'] as bool;

        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : Colors.grey[300],
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            size: isCompleted ? 16 : 12,
            color: Colors.white,
          ),
        );
      }),
    );
  }

  Widget _buildPaymentSummaryCard(EmployeeActiveProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow(
            'Total Budget',
            currencyFormat.format(project.totalBudget),
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            'Paid Amount',
            currencyFormat.format(project.totalPaid),
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildPaymentRow(
            'Pending',
            currencyFormat.format(project.remainingAmount),
            color: Colors.orange,
          ),
          const Divider(height: 24),
          _buildPaymentRow(
            'Your Earnings',
            currencyFormat.format(project.totalPaid),
            isBold: true,
            color: primary,
          ),
          if (project.lastPaymentAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last payment: ${DateFormat('MMM dd, yyyy').format(project.lastPaymentAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildContractCard(EmployeeActiveProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contract Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildContractRow('Contract #', project.contractNumber),
          const SizedBox(height: 8),
          _buildContractRow('Status', project.contractStatus),
          if (project.signedAt != null) ...[
            const SizedBox(height: 8),
            _buildContractRow(
              'Signed on',
              DateFormat('MMM dd, yyyy').format(project.signedAt!),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // View contract
              Get.toNamed('/employee/contract', arguments: project.contractId);
            },
            icon: const Icon(Icons.description),
            label: const Text('View Contract'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getMilestoneIcon(Milestone milestone) {
    if (milestone.isReleased) return Icons.payment;
    if (milestone.isApproved) return Icons.thumb_up;
    if (milestone.isSubmitted) return Icons.upload_file;
    if (milestone.isFunded) return Icons.play_arrow;
    return Icons.lock;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) return 'Overdue';
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    return DateFormat('MMM dd').format(date);
  }
}
// lib/Employeer/Screens/project_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employeer_MileStone_Payment_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_Invoice_Screen.dart';
import 'package:templink/Employeer/Screens/employer_view_work_screen.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';

class EmployerProjectDetailsScreen extends StatelessWidget {
  final EmployerProject project;
  final controller = Get.put(EmployerProjectsController());
  
  EmployerProjectDetailsScreen({required this.project});

  Color get primaryColor => primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          project.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMyProjectsWithProposals(),
          ),
        ],
      ),
      body: Obx(() {
        final updatedProject = controller.projects.firstWhere(
          (p) => p.id == project.id,
          orElse: () => project,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(updatedProject),
              const SizedBox(height: 20),
              if (updatedProject.Status == 'COMPLETED')
                _buildCompletedProjectSection(updatedProject),
              _buildMilestonesHeader(updatedProject),
              const SizedBox(height: 16),
              if (updatedProject.hasMilestones)
                ...updatedProject.milestones.asMap().entries.map((entry) {
                  final index = entry.key;
                  final milestone = entry.value;
                  return _buildMilestoneCard(updatedProject, milestone, index);
                }).toList()
              else
                _buildEmptyMilestones(),
              const SizedBox(height: 20),
              _buildPaymentSummaryCard(updatedProject),
              const SizedBox(height: 20),
              _buildProjectDetailsCard(updatedProject),
            ],
          ),
        );
      }),
    );
  }

  // ==================== COMPLETED PROJECT SECTION WITH RATING ====================
  Widget _buildCompletedProjectSection(EmployerProject project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Project Completed! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'All milestones have been successfully completed.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Paid',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${project.totalPaidAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Completed On',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Invoice Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewInvoice(project.id),
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  label: const Text(
                    'View Invoice',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadInvoice(project.id),
                  icon: const Icon(Icons.download),
                  label: const Text(
                    'Download PDF',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // ⭐ Rating Button
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _checkAndShowRating(project),
                  icon: const Icon(Icons.star, color: Colors.white),
                  label: const Text(
                    'Rate Freelancer',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== RATING METHODS ====================
  void _checkAndShowRating(EmployerProject project) async {
    final isRated = await controller.checkIfRated(project.id);
    
    if (isRated) {
      Get.snackbar(
        'Already Rated',
        'You have already rated this freelancer',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    _showRatingDialog(project);
  }

  void _showRatingDialog(EmployerProject project) {
    int rating = 0;
    final reviewController = TextEditingController();
    
    // Get employee details from accepted proposal
    String employeeId = '';
    String employeeName = 'Freelancer';
    
    final acceptedProposal = project.proposals.firstWhere(
      (p) => p.status == 'ACCEPTED',
      // orElse: () => project.proposals.isNotEmpty ? project.proposals.first : null,
    );
    
    if (acceptedProposal != null) {
      employeeId = acceptedProposal.employee.id;
      employeeName = acceptedProposal.employee.displayName;
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Rate Freelancer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: primaryColor,
                        child: Text(
                          employeeName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Freelancer',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              employeeName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Tap to rate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  rating > 0 ? '$rating Star${rating > 1 ? 's' : ''}' : '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: rating > 0 ? Colors.amber : Colors.transparent,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your review (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: rating > 0
                    ? () {
                        Get.back();
                        controller.submitRating(
                          projectId: project.id,
                          employeeId: employeeId,
                          rating: rating,
                          review: reviewController.text.isNotEmpty 
                              ? reviewController.text 
                              : null,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== NAVIGATION METHODS ====================
  void _viewInvoice(String projectId) {
    Get.to(() => EmployerInvoiceViewScreen(projectId: projectId));
  }

  void _downloadInvoice(String projectId) {
    Get.snackbar(
      'Downloading',
      'Your invoice is being downloaded...',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // ==================== UI BUILDING METHODS ====================
  Widget _buildProgressCard(EmployerProject project) {
    final progress = project.progressPercentage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                icon: Icons.attach_money,
                label: 'Paid',
                value: '\$${project.totalPaidAmount.toStringAsFixed(0)}',
              ),
              _buildProgressStat(
                icon: Icons.pending_actions,
                label: 'Pending',
                value: '\$${project.remainingAmount.toStringAsFixed(0)}',
              ),
              _buildProgressStat(
                icon: Icons.home,
                label: 'Milestones',
                value: '${project.completedMilestones.length}/${project.milestoneCount}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesHeader(EmployerProject project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Project Milestones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${project.completedMilestones.length}/${project.milestoneCount} Completed',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMilestones() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.military_tech_sharp,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No milestones added yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(EmployerProject project, Milestone milestone, int index) {
    final isPreviousCompleted = index == 0 || 
        project.milestones[index - 1].isCompleted;
    final isLocked = milestone.status == 'PENDING' && !isPreviousCompleted;
    final isCurrent = milestone.status == 'PENDING' && isPreviousCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked 
              ? Colors.grey.withOpacity(0.3)
              : milestone.isCompleted 
                  ? Colors.green.withOpacity(0.5)
                  : primaryColor.withOpacity(0.3),
          width: 1.5,
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
              color: _getMilestoneStatusColor(milestone, isLocked).withOpacity(0.1),
            ),
            child: Icon(
              _getMilestoneIcon(milestone, isLocked),
              color: _getMilestoneStatusColor(milestone, isLocked),
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Milestone ${index + 1}: ${milestone.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLocked ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMilestoneStatusColor(milestone, isLocked).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getMilestoneStatusText(milestone, isLocked, isCurrent),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getMilestoneStatusColor(milestone, isLocked),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
              Text(
                '\$${milestone.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              if (milestone.dueDate != null) ...[
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
                    color: Colors.grey[600],
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
                  Text(
                    milestone.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(milestone),
                  const SizedBox(height: 16),
                  if (!isLocked) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildActionButton(project, milestone, isCurrent),
                  ],
                  if (isLocked) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Complete previous milestone first',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
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
      {'label': 'Payment', 'status': milestone.isFunded || milestone.isSubmitted || milestone.isCompleted},
      {'label': 'Work', 'status': milestone.isSubmitted || milestone.isCompleted},
      {'label': 'Approval', 'status': milestone.isApproved || milestone.isReleased},
      {'label': 'Release', 'status': milestone.isReleased},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: steps[index ~/ 2]['status'] as bool && steps[index ~/ 2 + 1]['status'] as bool
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

  Widget _buildActionButton(EmployerProject project, Milestone milestone, bool isCurrent) {
    switch (milestone.status) {
      case 'SUBMITTED':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:(){
                  Get.to(EmployerViewWorkScreen(
                    milestone: milestone,
                    project: project,
                  ));
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('View Work'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'PENDING':
        if (isCurrent) {
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => MilestonePaymentScreen(
                      project: project,
                      milestone: milestone,
                    ));
                  },
                  icon: const Icon(Icons.payment, size: 18),
                  label: Text('Pay \$${milestone.amount.toStringAsFixed(0)}'),
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
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMilestoneDetails(milestone),
                  icon: const Icon(Icons.info, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text(
                'Waiting for previous milestone',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        );

      case 'FUNDED':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text(
                'Waiting for freelancer to submit work',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        );

      case 'APPROVED':
      case 'RELEASED':
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                milestone.status == 'RELEASED' 
                    ? 'Payment Released'
                    : 'Approved - Payment Pending',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPaymentSummaryCard(EmployerProject project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPaymentRow('Total Budget:', '\$${project.maxBudget}'),
              _buildPaymentRow('Paid:', '\$${project.totalPaidAmount}', color: Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPaymentRow('Remaining:', '\$${project.remainingAmount}', color: Colors.orange),
              _buildPaymentRow('Platform Fee:', '\$${(project.maxBudget * 0.1).toStringAsFixed(0)}', color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: project.progressPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              project.progressPercentage == 1.0 ? Colors.green : primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDetailsCard(EmployerProject project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          _buildDetailRow(Icons.description, 'Description', project.description),
          const Divider(),
          _buildDetailRow(Icons.category, 'Category', project.category),
          const Divider(),
          _buildDetailRow(Icons.timer, 'Duration', project.duration),
          const Divider(),
          _buildDetailRow(Icons.psychology, 'Experience', project.experienceLevel),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryColor.withOpacity(0.7)),
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

  // Helper Methods
  Color _getMilestoneStatusColor(Milestone milestone, bool isLocked) {
    if (isLocked) return Colors.grey;
    if (milestone.isReleased) return Colors.green;
    if (milestone.isApproved) return Colors.purple;
    if (milestone.isSubmitted) return Colors.orange;
    if (milestone.isFunded) return Colors.blue;
    return primaryColor;
  }

  IconData _getMilestoneIcon(Milestone milestone, bool isLocked) {
    if (isLocked) return Icons.lock;
    if (milestone.isReleased) return Icons.payment;
    if (milestone.isApproved) return Icons.thumb_up;
    if (milestone.isSubmitted) return Icons.visibility;
    if (milestone.isFunded) return Icons.account_balance_wallet;
    return Icons.home;
  }

  String _getMilestoneStatusText(Milestone milestone, bool isLocked, bool isCurrent) {
    if (isLocked) return 'LOCKED';
    if (milestone.isReleased) return 'RELEASED';
    if (milestone.isApproved) return 'APPROVED';
    if (milestone.isSubmitted) return 'SUBMITTED';
    if (milestone.isFunded) return 'FUNDED';
    if (isCurrent) return 'READY TO PAY';
    return 'PENDING';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference < 0) return 'Overdue';
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMilestoneDetails(Milestone milestone) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  milestone.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              milestone.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Amount: \$${milestone.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
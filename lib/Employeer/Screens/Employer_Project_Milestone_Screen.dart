// lib/Employeer/Screens/project_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employeer_MileStone_Payment_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_Invoice_Screen.dart';
import 'package:templink/Employeer/Screens/employer_view_work_screen.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _bg      = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border  = Color(0xFFE5E7EB);
const _text1   = Color(0xFF111827);
const _text2   = Color(0xFF6B7280);
const _text3   = Color(0xFF9CA3AF);
const _green   = Color(0xFF16A34A);
const _amber   = Color(0xFFF59E0B);
const _red     = Color(0xFFDC2626);
const _radius  = 12.0;

class EmployerProjectDetailsScreen extends StatelessWidget {
  final EmployerProject project;
  final bool showSidebar;
  final VoidCallback? onBackPressed;

  const EmployerProjectDetailsScreen({
    Key? key,
    required this.project,
    this.showSidebar = true,
    this.onBackPressed,
  }) : super(key: key);

  Color get primaryColor => primary;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    final controller = Get.find<EmployerProjectsController>();

    if (isWeb && !showSidebar) {
      return Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildWebAppBar(controller),
            Expanded(
              child: _buildBody(controller),
            ),
          ],
        ),
      );
    }

    if (isWeb) {
      return Scaffold(
        backgroundColor: _bg,
        body: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildWebAppBar(controller),
                  Expanded(
                    child: _buildBody(controller),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          project.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed ?? () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => controller.fetchMyProjectsWithProposals(),
          ),
        ],
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildWebAppBar(EmployerProjectsController controller) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBackPressed ?? () => Get.back(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, size: 18, color: _text2),
                  const SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontSize: 13, color: _text2)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            project.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20, color: _text2),
            onPressed: () => controller.fetchMyProjectsWithProposals(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(EmployerProjectsController controller) {
    return Obx(() {
      final updatedProject = controller.projects.firstWhere(
        (p) => p.id == project.id,
        orElse: () => project,
      );

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressCard(updatedProject),
            const SizedBox(height: 20),
            if (updatedProject.Status == 'COMPLETED')
              _buildCompletedProjectSection(updatedProject, controller),
            _buildMilestonesHeader(updatedProject),
            const SizedBox(height: 16),
            if (updatedProject.hasMilestones)
              ...updatedProject.milestones.asMap().entries.map((entry) {
                final index = entry.key;
                final milestone = entry.value;
                return _buildMilestoneCard(updatedProject, milestone, index, controller);
              }).toList()
            else
              _buildEmptyMilestones(),
            const SizedBox(height: 20),
            _buildPaymentSummaryCard(updatedProject),
            const SizedBox(height: 20),
            _buildProjectDetailsCard(updatedProject),
            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }

  // ==================== COMPLETED PROJECT SECTION WITH RATING ====================
  Widget _buildCompletedProjectSection(EmployerProject project, EmployerProjectsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_green, _green.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Project Completed! 🎉',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'All milestones have been successfully completed.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
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
                    const Text('Total Paid', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${project.totalPaidAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Completed On', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewInvoice(project.id),
                  icon: const Icon(Icons.receipt_long, size: 16, color: Colors.white),
                  label: const Text('View Invoice', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _downloadInvoice(project.id),
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _green,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _checkAndShowRating(project, controller),
                  icon: const Icon(Icons.star, size: 16, color: Colors.white),
                  label: const Text('Rate Freelancer', style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  void _checkAndShowRating(EmployerProject project, EmployerProjectsController controller) async {
    final isRated = await controller.checkIfRated(project.id);
    
    if (isRated) {
      Get.snackbar('Already Rated', 'You have already rated this freelancer',
          backgroundColor: Colors.blue, colorText: Colors.white);
      return;
    }

    _showRatingDialog(project, controller);
  }

  void _showRatingDialog(EmployerProject project, EmployerProjectsController controller) {
    int rating = 0;
    final reviewController = TextEditingController();
    
    String employeeId = '';
    String employeeName = 'Freelancer';
    
    final acceptedProposal = project.proposals.firstWhere(
      (p) => p.status == 'ACCEPTED',
    );
    
    if (acceptedProposal != null) {
      employeeId = acceptedProposal.employee.id;
      employeeName = acceptedProposal.employee.displayName;
    }

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Rate Freelancer', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        radius: 18,
                        backgroundColor: primaryColor,
                        child: Text(employeeName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Freelancer', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(employeeName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tap to rate', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () => setState(() => rating = index + 1),
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                if (rating > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('$rating Star${rating > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your review (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Skip')),
              ElevatedButton(
                onPressed: rating > 0
                    ? () {
                        Get.back();
                        controller.submitRating(
                          projectId: project.id,
                          employeeId: employeeId,
                          rating: rating,
                          review: reviewController.text.isNotEmpty ? reviewController.text : null,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _viewInvoice(String projectId) => Get.to(() => EmployerInvoiceViewScreen(projectId: projectId));
  void _downloadInvoice(String projectId) {
    Get.snackbar('Downloading', 'Your invoice is being downloaded...',
        backgroundColor: Colors.green, colorText: Colors.white);
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
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overall Progress', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(icon: Icons.attach_money, label: 'Paid', value: '\$${project.totalPaidAmount.toStringAsFixed(0)}'),
              _buildProgressStat(icon: Icons.pending_actions, label: 'Pending', value: '\$${project.remainingAmount.toStringAsFixed(0)}'),
              _buildProgressStat(icon: Icons.home, label: 'Milestones', value: '${project.completedMilestones.length}/${project.milestoneCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
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
        const Text('Project Milestones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Text(
            '${project.completedMilestones.length}/${project.milestoneCount} Completed',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMilestones() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.military_tech_sharp, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No milestones added yet', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(EmployerProject project, Milestone milestone, int index, EmployerProjectsController controller) {
    final isPreviousCompleted = index == 0 || project.milestones[index - 1].isCompleted;
    final isLocked = milestone.status == 'PENDING' && !isPreviousCompleted;
    final isCurrent = milestone.status == 'PENDING' && isPreviousCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? Colors.grey.withOpacity(0.3)
              : milestone.isCompleted ? _green.withOpacity(0.5)
              : primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getMilestoneStatusColor(milestone, isLocked).withOpacity(0.1),
            ),
            child: Icon(_getMilestoneIcon(milestone, isLocked),
                color: _getMilestoneStatusColor(milestone, isLocked), size: 18),
          ),
          title: Text(
            'Milestone ${index + 1}: ${milestone.title}',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                color: isLocked ? _text3 : _text1),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.attach_money, size: 12, color: _text3),
              const SizedBox(width: 4),
              Text('\$${milestone.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: _text2)),
              if (milestone.dueDate != null) ...[
                Container(width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 6), decoration: const BoxDecoration(color: _text3, shape: BoxShape.circle)),
                Icon(Icons.calendar_today, size: 10, color: _text3),
                const SizedBox(width: 4),
                Text(_formatDate(milestone.dueDate!), style: TextStyle(fontSize: 11, color: _text3)),
              ],
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getMilestoneStatusColor(milestone, isLocked).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_getMilestoneStatusText(milestone, isLocked, isCurrent),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: _getMilestoneStatusColor(milestone, isLocked))),
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(milestone.description,
                      style: TextStyle(fontSize: 12, color: _text2, height: 1.4)),
                  const SizedBox(height: 12),
                  _buildStatusTimeline(milestone),
                  const SizedBox(height: 12),
                  if (!isLocked) ...[
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    _buildActionButton(project, milestone, isCurrent, controller),
                  ],
                  if (isLocked) ...[
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 14, color: _text3),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Complete previous milestone first',
                                style: TextStyle(fontSize: 11, color: _text3, fontStyle: FontStyle.italic)),
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
                  ? _green
                  : Colors.grey[300],
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isCompleted = steps[stepIndex]['status'] as bool;
        
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? _green : Colors.grey[300],
          ),
          child: Icon(isCompleted ? Icons.check : Icons.circle,
              size: isCompleted ? 14 : 10, color: Colors.white),
        );
      }),
    );
  }

  Widget _buildActionButton(EmployerProject project, Milestone milestone, bool isCurrent, EmployerProjectsController controller) {
    switch (milestone.status) {
      case 'SUBMITTED':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => EmployerViewWorkScreen(milestone: milestone, project: project)),
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('View Work', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  onPressed: () => Get.to(() => MilestonePaymentScreen(project: project, milestone: milestone)),
                  icon: const Icon(Icons.payment, size: 16),
                  label: Text('Pay \$${milestone.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMilestoneDetails(milestone),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Details', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.blue, size: 14),
              SizedBox(width: 8),
              Text('Waiting for previous milestone', style: TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
        );

      case 'FUNDED':
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: Colors.blue, size: 14),
              SizedBox(width: 8),
              Text('Waiting for freelancer to submit work', style: TextStyle(color: Colors.blue, fontSize: 12)),
            ],
          ),
        );

      case 'APPROVED':
      case 'RELEASED':
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: _green, size: 14),
              const SizedBox(width: 8),
              Text(milestone.status == 'RELEASED' ? 'Payment Released' : 'Approved - Payment Pending',
                  style: TextStyle(color: _green, fontSize: 12)),
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
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPaymentRow('Total Budget:', '\$${project.maxBudget}'),
              _buildPaymentRow('Paid:', '\$${project.totalPaidAmount}', color: _green),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPaymentRow('Remaining:', '\$${project.remainingAmount}', color: Colors.orange),
              _buildPaymentRow('Platform Fee:', '\$${(project.maxBudget * 0.1).toStringAsFixed(0)}', color: _text3),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: project.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(project.progressPercentage == 1.0 ? _green : primaryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: _text3)),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? _text1)),
      ],
    );
  }

  Widget _buildProjectDetailsCard(EmployerProject project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Project Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _text1)),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.description, 'Description', project.description),
          const Divider(height: 1),
          _buildDetailRow(Icons.category, 'Category', project.category),
          const Divider(height: 1),
          _buildDetailRow(Icons.timer, 'Duration', project.duration),
          const Divider(height: 1),
          _buildDetailRow(Icons.psychology, 'Experience', project.experienceLevel),
          const Divider(height: 1),
          const Text('Skills Required', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _text1)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(skill, style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w500)),
            )).toList(),
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
          Icon(icon, size: 16, color: primaryColor.withOpacity(0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: _text3)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _text1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getMilestoneStatusColor(Milestone milestone, bool isLocked) {
    if (isLocked) return _text3;
    if (milestone.isReleased) return _green;
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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(milestone.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(milestone.description, style: const TextStyle(fontSize: 13, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: _green),
                  const SizedBox(width: 8),
                  Text('Amount: \$${milestone.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
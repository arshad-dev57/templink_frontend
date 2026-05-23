// screens/employee/employee_project_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/Employee_Active_Project_Controller.dart';
import 'package:templink/Employee/Screens/Employee_Submit_Work_Screen.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:intl/intl.dart';

class EmployeeProjectDetailsScreen extends StatelessWidget {
  final EmployeeActiveProjectModel project;
  final controller = Get.find<EmployeeActiveProjectController>();
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  EmployeeProjectDetailsScreen({
    super.key,
    required this.project,
    this.onBackPressed,
    this.showSidebar = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProjectDetails(project.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isWeb = isDesktop || isTablet;

    // Agar parent se sidebar already show ho raha hai (EmployeeHomeScreen se)
    if (isWeb && !showSidebar) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            _buildWebTopBar(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final displayProject = controller.selectedProject.value ?? project;
                return _buildWebBody(context, displayProject);
              }),
            ),
          ],
        ),
      );
    }

    // Full web layout with sidebar for direct navigation
    if (isWeb) {
      return _buildFullWebLayout(context);
    }

    // Mobile layout
    return _buildMobileLayout(context);
  }

  // ==================== WEB TOP BAR ====================
  Widget _buildWebTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
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
          if (onBackPressed != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: onBackPressed,
            ),
          Expanded(
            child: Text(
              project.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => controller.fetchProjectDetails(project.id),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  // ==================== FULL WEB LAYOUT ====================
  Widget _buildFullWebLayout(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final sidebarW = isDesktop ? 280.0 : 240.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: sidebarW,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildWebSidebar(context),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildFullWebTopBar(context),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final displayProject = controller.selectedProject.value ?? project;
                    return _buildWebBody(context, displayProject);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSidebar(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.work_outline,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Templink',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSidebarInfoRow('Status', project.statusText),
                const SizedBox(height: 8),
                _buildSidebarInfoRow('Budget', 
                    currencyFormat.format(project.totalBudget)),
                const SizedBox(height: 8),
                _buildSidebarInfoRow('Category', project.category),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          child: Column(
            children: [
              _webNavItem(Icons.arrow_back, 'Back to Projects', () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Get.back();
                }
              }),
              const SizedBox(height: 8),
              _webNavItem(Icons.home_outlined, 'Dashboard', () {
                Get.back();
                Get.back();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
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
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWebTopBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              if (onBackPressed != null) {
                onBackPressed!();
              } else {
                Get.back();
              }
            },
          ),
          Expanded(
            child: Text(
              project.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => controller.fetchProjectDetails(project.id),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: primary.withOpacity(0.1),
            child: Icon(Icons.person, size: 20, color: primary),
          ),
        ],
      ),
    );
  }

  // ==================== WEB BODY ====================
  Widget _buildWebBody(BuildContext context, EmployeeActiveProjectModel displayProject) {
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Main content
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildEmployerCard(context, displayProject),
                    const SizedBox(height: 20),
                    _buildProgressCard(context, displayProject),
                    const SizedBox(height: 20),
                    _buildProjectDetailsCard(context, displayProject),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right column - Sidebar info
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildPaymentSummaryCard(context, displayProject),
                    const SizedBox(height: 20),
                    _buildContractCard(context, displayProject),
                    const SizedBox(height: 20),
                    _buildMilestonesSection(context, displayProject),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          project.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed,
              )
            : null,
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

        final displayProject = controller.selectedProject.value ?? project;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmployerCard(context, displayProject),
              const SizedBox(height: 20),
              _buildProgressCard(context, displayProject),
              const SizedBox(height: 20),
              _buildProjectDetailsCard(context, displayProject),
              const SizedBox(height: 20),
              _buildMilestonesSection(context, displayProject),
              const SizedBox(height: 20),
              _buildPaymentSummaryCard(context, displayProject),
              const SizedBox(height: 20),
              _buildContractCard(context, displayProject),
            ],
          ),
        );
      }),
    );
  }

  // ==================== MILESTONES SECTION ====================
  Widget _buildMilestonesSection(BuildContext context, EmployeeActiveProjectModel displayProject) {
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Milestones',
                style: TextStyle(
                  fontSize: isWeb ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        if (displayProject.milestones.isEmpty)
          _buildEmptyMilestones()
        else
          ...displayProject.milestones.map(
            (milestone) => _buildMilestoneCard(context, displayProject, milestone),
          ),
      ],
    );
  }

  // ==================== EMPLOYER CARD ====================
  Widget _buildEmployerCard(BuildContext context, EmployeeActiveProjectModel project) {
    final isDesktop = Responsive.isDesktop(context);
    final avatarSize = isDesktop ? 70.0 : 60.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
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
                      project.employerName.isNotEmpty
                          ? project.employerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  project.employerName,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${project.employerSnapshot['rating'] ?? '4.5'} • ${project.contractStatus}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: project.statusColor,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: primary),
              onPressed: () {},
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROGRESS CARD ====================
  Widget _buildProgressCard(BuildContext context, EmployeeActiveProjectModel project) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.8)],
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
          Text(
            'Overall Progress',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isDesktop ? 14 : 12,
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(project.progressPercentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==================== PROJECT DETAILS CARD ====================
  Widget _buildProjectDetailsCard(BuildContext context, EmployeeActiveProjectModel project) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = !Responsive.isDesktop(context) && !Responsive.isTablet(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Details',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.description,
            label: 'Description',
            value: project.description,
          ),
          const Divider(),
          if (!isMobile)
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
            )
          else
            Column(
              children: [
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Category',
                  value: project.category,
                ),
                _buildDetailRow(
                  icon: Icons.timer,
                  label: 'Duration',
                  value: project.duration,
                ),
              ],
            ),
          const Divider(),
          _buildDetailRow(
            icon: Icons.psychology,
            label: 'Experience Level',
            value: project.experienceLevel,
          ),
          const Divider(),
          const Text(
            'Skills Required',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  skill,
                  style: TextStyle(fontSize: 12, color: primary),
                ),
              );
            }).toList(),
          ),
          const Divider(),
          const Text(
            'Deliverables',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...project.deliverables.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle,
                      size: 16, color: primary.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY MILESTONES ====================
  Widget _buildEmptyMilestones() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.payment, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No milestones added yet',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==================== MILESTONE CARD ====================
  Widget _buildMilestoneCard(
    BuildContext context,
    EmployeeActiveProjectModel project,
    Milestone milestone,
  ) {
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
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
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
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                  ],
                ),
                if (milestone.dueDate != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey[600]),
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
                  ),
              ],
            ),
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
                        fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(milestone),
                  const SizedBox(height: 16),

                  // Submit Work
                  if (milestone.isFunded) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => EmployeeSubmitWorkScreen(
                            milestone: milestone,
                            project: project,
                            showSidebar: showSidebar,
                            onBackPressed: onBackPressed,
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

                  if (milestone.isSubmitted) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildStatusBanner(
                      icon: Icons.hourglass_top,
                      color: Colors.orange,
                      title: 'Work Submitted',
                      subtitle: 'Waiting for employer review',
                    ),
                  ],

                  if (milestone.isApproved) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildStatusBanner(
                      icon: Icons.thumb_up,
                      color: Colors.purple,
                      title: 'Approved',
                      subtitle: 'Payment will be released soon',
                    ),
                  ],

                  if (milestone.isReleased) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildStatusBanner(
                      icon: Icons.payment,
                      color: Colors.green,
                      title: 'Payment Released',
                      subtitle: 'Amount added to your wallet',
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

  Widget _buildStatusBanner({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
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

  // ==================== PAYMENT SUMMARY CARD ====================
  Widget _buildPaymentSummaryCard(BuildContext context, EmployeeActiveProjectModel project) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Total Budget',
              currencyFormat.format(project.totalBudget)),
          const SizedBox(height: 8),
          _buildPaymentRow('Paid Amount',
              currencyFormat.format(project.totalPaid),
              color: Colors.green),
          const SizedBox(height: 8),
          _buildPaymentRow('Pending',
              currencyFormat.format(project.remainingAmount),
              color: Colors.orange),
          const Divider(height: 24),
          _buildPaymentRow(
              'Your Earnings', currencyFormat.format(project.totalPaid),
              isBold: true, color: primary),
          if (project.lastPaymentAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last payment: ${DateFormat('MMM dd, yyyy').format(project.lastPaymentAt!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
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

  // ==================== CONTRACT CARD ====================
  Widget _buildContractCard(BuildContext context, EmployeeActiveProjectModel project) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contract Information',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed('/employee/contract',
                    arguments: project.contractId);
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
          ),
        ],
      ),
    );
  }

  Widget _buildContractRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ==================== HELPERS ====================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
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
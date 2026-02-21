// screens/employee/employee_projects_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/Employee_Active_Project_Controller.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects_Detail_Screen.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:intl/intl.dart';

class EmployeeActiveProjectsScreen extends StatelessWidget {
  final controller = Get.put(EmployeeActiveProjectController());
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
              color: Colors.white,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.refreshData(),
              color: Colors.white,
            ),
          ),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 12,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.projects.isEmpty) {
          return _buildLoadingState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildWelcomeHeader(),
              ),
              SliverToBoxAdapter(
                child: _buildStatisticsSection(),
              ),
              SliverToBoxAdapter(
                child: _buildProjectsHeader(),
              ),
              if (controller.projects.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = controller.projects[index];
                        return _buildProjectCard(project);
                      },
                      childCount: controller.projects.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ==================== WELCOME HEADER ====================
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back! 👋',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your active projects',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, color: primary, size: 16),
                const SizedBox(width: 4),
                Obx(() => Text(
                  '\$${controller.totalEarnings.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATISTICS SECTION ====================
  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                icon: Icons.play_circle_filled,
                label: 'Active',
                value: controller.activeProjects.value.toString(),
                color: Colors.blue,
                gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.check_circle,
                label: 'Completed',
                value: controller.completedProjects.value.toString(),
                color: Colors.green,
                gradientColors: [Colors.green.shade400, Colors.green.shade600],
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.folder,
                label: 'Total',
                value: controller.totalProjects.value.toString(),
                color: Colors.orange,
                gradientColors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
            ],
          ),
        
        ],
      ),
    );
  }
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROJECTS HEADER ====================
  Widget _buildProjectsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Active Projects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() => Text(
              '${controller.projects.length} total',
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )),
          ),
        ],
      ),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your projects...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_outline,
                size: 70,
                color: primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Active Projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You don\'t have any active projects right now.\nStart applying for jobs to get hired!',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.toNamed('/find-work'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Find Work',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROJECT CARD ====================
  Widget _buildProjectCard(EmployeeActiveProjectModel project) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(
            EmployeeProjectDetailsScreen(project: project),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    _buildEmployerLogo(project),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProjectHeader(project),
                    ),
                    _buildStatusBadge(project),
                  ],
                ),

                const SizedBox(height: 16),

                // Tags
                _buildProjectTags(project, currencyFormat),

                const SizedBox(height: 16),

                // Progress
                _buildProgressSection(project),

                const SizedBox(height: 16),

                // Next Milestone
                if (project.nextMilestone != null)
                  _buildNextMilestone(project, currencyFormat),

                const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(project),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== PROJECT CARD SUB-WIDGETS ====================
  Widget _buildEmployerLogo(EmployeeActiveProjectModel project) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProjectHeader(EmployeeActiveProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.business_center, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                project.employerName,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(EmployeeActiveProjectModel project) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: project.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: project.statusColor.withOpacity(0.3)),
      ),
      child: Text(
        project.statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: project.statusColor,
        ),
      ),
    );
  }

  Widget _buildProjectTags(
    EmployeeActiveProjectModel project,
    NumberFormat currencyFormat,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTag(Icons.category, project.category, Colors.blue),
        _buildTag(Icons.timer, project.duration, Colors.orange),
        _buildTag(
          Icons.attach_money,
          currencyFormat.format(project.maxBudget),
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(EmployeeActiveProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Milestone Progress',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${project.completedMilestones}/${project.totalMilestones}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: project.progressPercentage,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(
                  project.progressPercentage == 1.0 ? Colors.green : primary,
                ),
                minHeight: 8,
              ),
            ),
            if (project.progressPercentage < 1.0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                      ],
                      stops: const [0.8, 1.0],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextMilestone(
    EmployeeActiveProjectModel project,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: project.nextMilestone!.isReady
                  ? Colors.green
                  : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              project.nextMilestone!.isReady
                  ? Icons.play_arrow
                  : Icons.lock,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next: ${project.nextMilestone!.title}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(project.nextMilestone!.amount),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (project.nextMilestone!.isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Ready',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EmployeeActiveProjectModel project) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.to(
              EmployeeProjectDetailsScreen(project: project),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Details'),
          ),
        ),
        if (project.nextMilestone?.isReady == true) ...[
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.to(
                EmployeeProjectDetailsScreen(project: project),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text('Start Work'),
            ),
          ),
        ],
      ],
    );
  }

  // ==================== SEARCH DIALOG ====================
  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Search Projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by title or employer...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onSubmitted: (query) {
                Navigator.pop(context);
                controller.searchProjects(query);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.searchProjects(searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
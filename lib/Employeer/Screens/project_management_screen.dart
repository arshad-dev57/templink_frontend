// screens/employer_project_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employer_Project_Milestone_Screen.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';

class EmployerProjectManagementScreen extends StatelessWidget {
  final controller = Get.put(EmployerProjectsController());

  Color get primaryColor => primary; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'My Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchMyProjectsWithProposals(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Enhanced Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                onChanged: controller.updateSearch,
                decoration: InputDecoration(
                  hintText: 'Search by title, category or skills...',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: controller.clearFilters,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // 📊 Stats Cards - Redesigned
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatCard(
                  label: 'Total',
                  value: controller.totalProjects.toString(),
                  icon: Icons.folder_copy,
                  color: primaryColor,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  label: 'Active',
                  value: controller.projects.where((p) => p.Status == 'IN_PROGRESS').length.toString(),
                  icon: Icons.play_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  label: 'Open',
                  value: controller.projects.where((p) => p.Status == 'OPEN').length.toString(),
                  icon: Icons.lock_open,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  label: 'Completed',
                  value: controller.projects.where((p) => p.Status == 'COMPLETED').length.toString(),
                  icon: Icons.check_circle,
                  color: Colors.purple,
                ),
              ],
            ),
          )),

          const SizedBox(height: 4),

          // 📋 Projects List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Loading your projects...',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredProjects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.folder_open,
                          size: 48,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'No projects found'
                            : 'No matching projects',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'Create your first project to get started'
                            : 'Try adjusting your search',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (controller.searchQuery.value.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: controller.clearFilters,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Search'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = controller.filteredProjects[index];
                  return _buildProjectCard(project);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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

  // 🃏 Professional Project Card
  Widget _buildProjectCard(EmployerProject project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _toggleExpand(project.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 🎯 Card Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Project Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(project.Status).withOpacity(0.2),
                              _getStatusColor(project.Status).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(project.Status),
                          color: _getStatusColor(project.Status),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title and Basic Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    project.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(project.Status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    project.Status.replaceAll('_', ' '),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(project.Status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  project.displayBudget,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                                Icon(
                                  Icons.category,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  project.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Expand Icon
                      Obx(() => Icon(
                        controller.expandedProjectId.value == project.id
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: primaryColor,
                      )),
                    ],
                  ),
                ),

                // 📈 Quick Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        icon: Icons.person_outline,
                        value: project.proposalsCount.toString(),
                        label: 'Proposals',
                        color: primaryColor,
                      ),
                      _buildQuickStat(
                        icon: Icons.attach_money,
                        value: '\$${project.maxBudget}',
                        label: 'Budget',
                        color: Colors.green,
                      ),
                      _buildQuickStat(
                        icon: Icons.timer_outlined,
                        value: project.displayDate,
                        label: 'Posted',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                // 🔽 Expanded Details (when clicked)
                Obx(() {
                  if (controller.expandedProjectId.value != project.id) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          project.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Skills
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
                                color: primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // Deliverables
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
                                  color: primaryColor.withOpacity(0.6),
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

                        const SizedBox(height: 16),

                        // Duration & Experience
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.timer, size: 16, color: primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Duration: ${project.duration}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.psychology, size: 16, color: primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Exp: ${project.experienceLevel}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons for OPEN projects
                        if (project.Status == 'OPEN') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _editProject(project),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _viewProposals(project),
                                icon: const Icon(Icons.visibility, size: 18),
                                label: Text('View Proposals (${project.proposalsCount})'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (project.Status == 'IN_PROGRESS') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _viewProjectDetails(project),
                                icon: const Icon(Icons.arrow_forward, size: 18),
                                label: const Text('View Project Details'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📊 Quick Stat Widget
  Widget _buildQuickStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Methods
  void _toggleExpand(String projectId) {
    if (controller.expandedProjectId.value == projectId) {
      controller.expandedProjectId.value = '';
    } else {
      controller.expandedProjectId.value = projectId;
    }
  }

  void _showFilterOptions() {
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
                const Text(
                  'Filter Projects',
                  style: TextStyle(
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
            _buildFilterChip('All Projects', 'all'),
            _buildFilterChip('Open', 'OPEN'),
            _buildFilterChip('In Progress', 'IN_PROGRESS'),
            _buildFilterChip('Completed', 'COMPLETED'),
            _buildFilterChip('Cancelled', 'CANCELLED'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      // final isSelected = controller.filterStatus.value == value;
      return FilterChip(
        label: Text(label),
        // selected: isSelected,
        onSelected: (selected) {
          // controller.filterStatus.value = value;
          controller.filterProjects();
          Get.back();
        },
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
        labelStyle: TextStyle(
          // color: isSelected ? primaryColor : Colors.black,
        ),
      );
    });
  }

  void _editProject(EmployerProject project) {
    Get.toNamed('/edit-project', arguments: project);
  }

  void _viewProposals(EmployerProject project) {
    Get.toNamed('/project-proposals', arguments: project);
  }

  void _viewProjectDetails(EmployerProject project) {
  Get.to(() => EmployerProjectDetailsScreen(project: project));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.green;
      case 'AWAITING_FUNDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return primaryColor;
      case 'COMPLETED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OPEN':
        return Icons.lock_open;
      case 'AWAITING_FUNDING':
        return Icons.account_balance_wallet;
      case 'IN_PROGRESS':
        return Icons.work;
      case 'COMPLETED':
        return Icons.task_alt;
      case 'CANCELLED':
        return Icons.cancel_outlined;
      default:
        return Icons.folder;
    }
  }
}
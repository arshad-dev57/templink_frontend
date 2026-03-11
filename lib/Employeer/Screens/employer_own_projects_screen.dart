//aaa
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employeer_Project_proposal_screen.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';


class EmployerOwnProjectsScreen extends StatefulWidget {
  const EmployerOwnProjectsScreen({Key? key}) : super(key: key);

  @override
  State<EmployerOwnProjectsScreen> createState() => _EmployerOwnProjectsScreenState();
}

class _EmployerOwnProjectsScreenState extends State<EmployerOwnProjectsScreen> {
  final EmployerProjectsController controller = Get.put(EmployerProjectsController());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    controller.updateSearch(searchController.text);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Proposals Recieved',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _buildSearchField(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildStatsSummary(),
            ),
            Expanded(
              child: _buildProjectsList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Colors.grey, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search your projects...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: () {
                  searchController.clear();
                  controller.updateSearch('');
                },
              )
            : const SizedBox.shrink()
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Projects',
            controller.totalProjects.toString(),
            Icons.folder_copy,
            Colors.blue,
          ),
          _buildStatItem(
            'Total Proposals',
            controller.totalProposals.toString(),
            Icons.description,
            Colors.orange,
          ),
          _buildStatItem(
            'Pending',
            controller.totalPendingProposals.toString(),
            Icons.pending_actions,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsList() {
    if (controller.filteredProjects.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: controller.filteredProjects.length,
      itemBuilder: (context, index) {
        final project = controller.filteredProjects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(EmployerProject project) {
    // ✅ Withdrawn exclude karke counts nikalo
    final activeProposals = project.proposals
        .where((p) => p.status != 'WITHDRAWN')
        .toList();
    final activePending = activeProposals
        .where((p) => p.status == 'PENDING')
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      project.title.isNotEmpty ? project.title[0].toUpperCase() : 'P',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
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
                        project.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              project.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            project.displayBudget,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ Stats — withdrawn exclude
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildProjectStat(
                  'Posted',
                  project.displayDate,
                  Icons.calendar_today_outlined,
                  Colors.grey.shade600,
                ),
                const SizedBox(width: 16),
                _buildProjectStat(
                  'Proposals',
                  '${activeProposals.length}', // ✅ withdrawn exclude
                  Icons.description_outlined,
                  activeProposals.isNotEmpty ? Colors.blue : Colors.grey.shade400,
                ),
                const SizedBox(width: 16),
                _buildProjectStat(
                  'Pending',
                  '$activePending', // ✅ withdrawn exclude
                  Icons.pending_outlined,
                  activePending > 0 ? Colors.orange : Colors.grey.shade400,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ✅ Button text mein bhi withdrawn exclude
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => ProjectProposalsScreen(project: project));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'View Proposals (${activeProposals.length})', // ✅ withdrawn exclude
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = controller.searchQuery.value.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.folder_open_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'No projects found' : 'No projects yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch
                  ? 'Try searching with different keywords'
                  : 'Create your first project to start receiving proposals',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            if (!hasSearch)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Create Project'),
              ),
          ],
        ),
      ),
    );
  }
}
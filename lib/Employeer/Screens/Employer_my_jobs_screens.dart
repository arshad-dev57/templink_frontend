// lib/Employer/Screens/employer_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_profile_controller.dart';
import '../../Utils/colors.dart';
import '../../Utils/responsive.dart';

class EmployerJobsScreen extends StatelessWidget {
  const EmployerJobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    final controller = Get.put(EmployerProfileController());
    
    // Local state for UI
    final isCardView = true.obs;
    final selectedFilter = 'All'.obs;
    final searchQuery = ''.obs;
    final searchTextController = TextEditingController();
    
    // Pagination state
    final currentPage = 1.obs;
    final totalPages = 1.obs;
    final totalItems = 0.obs;
    final isLoadingMore = false.obs;
    final hasMore = true.obs;
    
    final webScrollController = ScrollController();
    final mobileScrollController = ScrollController();
    
    final List<DropdownMenuItem<String>> filterMenuItems = [
      const DropdownMenuItem(value: 'All', child: Row(children: [Icon(Icons.all_inclusive, size: 16), SizedBox(width: 6), Text('All')])),
      const DropdownMenuItem(value: 'Active', child: Row(children: [Icon(Icons.play_circle_outline, size: 16, color: Colors.green), SizedBox(width: 6), Text('Active')])),
      const DropdownMenuItem(value: 'Paused', child: Row(children: [Icon(Icons.pause_circle_outline, size: 16, color: Colors.orange), SizedBox(width: 6), Text('Paused')])),
      const DropdownMenuItem(value: 'Closed', child: Row(children: [Icon(Icons.cancel, size: 16, color: Colors.red), SizedBox(width: 6), Text('Closed')])),
      const DropdownMenuItem(value: 'Expired', child: Row(children: [Icon(Icons.timer, size: 16, color: Colors.grey), SizedBox(width: 6), Text('Expired')])),
    ];
    
    // Load jobs on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs(controller, currentPage, totalPages, totalItems, hasMore, isLoadingMore);
    });
    
    // Mobile scroll listener
    mobileScrollController.addListener(() {
      if (!isLoadingMore.value && hasMore.value && 
          mobileScrollController.position.pixels >= 
          mobileScrollController.position.maxScrollExtent - 200) {
        _loadMoreJobs(controller, currentPage, totalPages, totalItems, hasMore, isLoadingMore);
      }
    });
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Jobs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (isWeb)
            Obx(() => IconButton(
              icon: Icon(isCardView.value ? Icons.table_rows : Icons.grid_view, size: 22),
              onPressed: () => isCardView.toggle(),
              tooltip: isCardView.value ? 'Switch to Table View' : 'Switch to Card View',
            )),
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: () => _loadJobs(controller, currentPage, totalPages, totalItems, hasMore, isLoadingMore, reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(controller, searchTextController, searchQuery, selectedFilter, filterMenuItems),
          _buildStatsBar(controller, totalItems),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingJobs.value && controller.jobs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.jobs.isEmpty) {
                return _buildEmptyState();
              }

              return isWeb
                  ? _buildWebContent(context, controller, isCardView, searchQuery, selectedFilter, currentPage, totalPages, webScrollController)
                  : _buildMobileContent(context, controller, searchQuery, selectedFilter, mobileScrollController, hasMore, isLoadingMore);
            }),
          ),
        ],
      ),
    );
  }
  
  // ==================== LOAD FUNCTIONS ====================
  Future<void> _loadJobs(
    EmployerProfileController controller,
    RxInt currentPage,
    RxInt totalPages,
    RxInt totalItems,
    RxBool hasMore,
    RxBool isLoadingMore, {
    bool reset = true,
    int page = 1,
  }) async {
    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      isLoadingMore.value = false;
    }
    
    await controller.fetchMyJobsPaginated(
      page: page,
      limit: 10,
      resetList: reset,
    );
    
    currentPage.value = controller.jobsCurrentPage.value;
    totalPages.value = controller.jobsTotalPages.value;
    totalItems.value = controller.jobsTotalCount.value;
    hasMore.value = currentPage.value < totalPages.value;
    isLoadingMore.value = false;
  }
  
  Future<void> _loadMoreJobs(
    EmployerProfileController controller,
    RxInt currentPage,
    RxInt totalPages,
    RxInt totalItems,
    RxBool hasMore,
    RxBool isLoadingMore,
  ) async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    await _loadJobs(controller, currentPage, totalPages, totalItems, hasMore, isLoadingMore, 
        reset: false, page: currentPage.value + 1);
  }
  
  void _goToPage(
    int page,
    EmployerProfileController controller,
    RxInt currentPage,
    RxInt totalPages,
    RxInt totalItems,
    RxBool hasMore,
    RxBool isLoadingMore,
  ) {
    if (page >= 1 && page <= totalPages.value && page != currentPage.value) {
      _loadJobs(controller, currentPage, totalPages, totalItems, hasMore, isLoadingMore, 
          reset: true, page: page);
    }
  }
  
  void _applyFilter(String filter, RxString selectedFilter, EmployerProfileController controller) {
    selectedFilter.value = filter;
    switch (filter) {
      case 'All':
        controller.filteredJobs.value = controller.jobs;
        break;
      case 'Active':
        controller.filteredJobs.value = controller.jobs
            .where((job) => job['status'] == 'active' || job['status'] == null)
            .toList();
        break;
      case 'Paused':
        controller.filteredJobs.value = controller.jobs
            .where((job) => job['status'] == 'paused')
            .toList();
        break;
      case 'Closed':
        controller.filteredJobs.value = controller.jobs
            .where((job) => job['status'] == 'closed')
            .toList();
        break;
      case 'Expired':
        controller.filteredJobs.value = controller.jobs
            .where((job) => job['status'] == 'expired')
            .toList();
        break;
    }
  }
  
  List<Map<String, dynamic>> _getDisplayJobs(
    EmployerProfileController controller,
    RxString searchQuery,
    RxString selectedFilter,
  ) {
    var jobs = controller.filteredJobs.toList();
    
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      jobs = jobs.where((job) {
        final title = job['title']?.toString().toLowerCase() ?? '';
        final company = job['company']?.toString().toLowerCase() ?? '';
        final location = job['location']?.toString().toLowerCase() ?? '';
        return title.contains(query) || company.contains(query) || location.contains(query);
      }).toList();
    }
    
    return jobs;
  }

  // ==================== SEARCH AND FILTER BAR ====================
  Widget _buildSearchAndFilterBar(
    EmployerProfileController controller,
    TextEditingController searchTextController,
    RxString searchQuery,
    RxString selectedFilter,
    List<DropdownMenuItem<String>> filterMenuItems,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: searchTextController,
                onChanged: (value) {
                  searchQuery.value = value;
                  controller.filterJobs(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[500]),
                  suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 16, color: Colors.grey[500]),
                          onPressed: () {
                            searchTextController.clear();
                            searchQuery.value = '';
                            controller.filterJobs('');
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Obx(() => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter.value,
                icon: Icon(Icons.arrow_drop_down, color: primary, size: 20),
                style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
                onChanged: (value) => _applyFilter(value!, selectedFilter, controller),
                items: filterMenuItems,
              ),
            )),
          ),
        ],
      ),
    );
  }

  // ==================== STATS BAR ====================
  Widget _buildStatsBar(
    EmployerProfileController controller,
    RxInt totalItems,
  ) {
    return Obx(() {
      final activeCount = controller.jobs.where((j) => j['status'] == 'active' || j['status'] == null).length;
      final pausedCount = controller.jobs.where((j) => j['status'] == 'paused').length;
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.filteredJobs.length} of ${totalItems.value} jobs',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            Row(
              children: [
                _buildStatChip(controller.jobs.length.toString(), Colors.blue),
                const SizedBox(width: 6),
                _buildStatChip(activeCount.toString(), Colors.green),
                const SizedBox(width: 6),
                _buildStatChip(pausedCount.toString(), Colors.orange),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatChip(String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ==================== JOB DETAILS DIALOG ====================
  void _showJobDetailsDialog(BuildContext context, Map<String, dynamic> job, EmployerProfileController controller) {
    final status = job['status'] ?? 'active';
    final statusColor = controller.getJobStatusColor(status);
    final statusText = controller.getJobStatusText(status);
    final postedDate = job['postedDate'] ?? job['createdAt'] ?? DateTime.now().toString();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work_outline, color: primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? 'Untitled Job',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          job['company'] ?? 'Company Name',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              
              // Job Details
              _buildDetailRow(Icons.location_on_outlined, 'Location', job['location'] ?? 'Remote'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.work_outline, 'Job Type', job['type'] ?? 'Full-time'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.attach_money, 'Salary', controller.formatJobSalary(job)),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_today_outlined, 'Posted Date', controller.formatDate(postedDate)),
              const SizedBox(height: 12),
              if (job['deadline'] != null)
                _buildDetailRow(Icons.event, 'Deadline', controller.formatDate(job['deadline'])),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              // Description
              const Text(
                'Job Description',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                job['about'] ?? job['description'] ?? 'No description provided',
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
              ),
              
              // Skills
              if (job['skills'] != null && (job['skills'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Required Skills',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (job['skills'] as List).map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill.toString(),
                      style: TextStyle(fontSize: 12, color: primary),
                    ),
                  )).toList(),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // ==================== WEB CONTENT ====================
  Widget _buildWebContent(
    BuildContext context,
    EmployerProfileController controller,
    RxBool isCardView,
    RxString searchQuery,
    RxString selectedFilter,
    RxInt currentPage,
    RxInt totalPages,
    ScrollController scrollController,
  ) {
    final displayJobs = _getDisplayJobs(controller, searchQuery, selectedFilter);
    
    return Obx(() => Column(
      children: [
        Expanded(
          child: isCardView.value
              ? GridView.builder(
                  padding: const EdgeInsets.all(12),
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: displayJobs.length,
                  itemBuilder: (context, index) => _buildJobCard(context, displayJobs[index], controller),
                )
              : SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DataTable(
                        columnSpacing: 16,
                        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                        dataRowMaxHeight: 60,
                        columns: const [
                          DataColumn(label: Text('Job Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Salary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Posted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                        rows: displayJobs.map((job) => _buildDataRow(context, job, controller)).toList(),
                      ),
                    ),
                  ),
                ),
        ),
        _buildWebPagination(currentPage, totalPages, controller),
      ],
    ));
  }
  
  Widget _buildWebPagination(RxInt currentPage, RxInt totalPages, EmployerProfileController controller) {
    return Obx(() {
      if (totalPages.value <= 1) return const SizedBox.shrink();
      
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: currentPage.value > 1 
                  ? () => _goToPage(currentPage.value - 1, controller, currentPage, totalPages, 
                      RxInt(0), RxBool(true), RxBool(false))
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text('Page ${currentPage.value} of ${totalPages.value}', 
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: currentPage.value < totalPages.value
                  ? () => _goToPage(currentPage.value + 1, controller, currentPage, totalPages,
                      RxInt(0), RxBool(true), RxBool(false))
                  : null,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    });
  }

  // ==================== MOBILE CONTENT ====================
  Widget _buildMobileContent(
    BuildContext context,
    EmployerProfileController controller,
    RxString searchQuery,
    RxString selectedFilter,
    ScrollController scrollController,
    RxBool hasMore,
    RxBool isLoadingMore,
  ) {
    final displayJobs = _getDisplayJobs(controller, searchQuery, selectedFilter);
    
    return Obx(() => ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: displayJobs.length + (hasMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayJobs.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isLoadingMore.value
                  ? const SizedBox(height: 30, width: 30, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('No more jobs', style: TextStyle(fontSize: 12)),
            ),
          );
        }
        return _buildJobCard(context, displayJobs[index], controller);
      },
    ));
  }

  // ==================== JOB CARD ====================
  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job, EmployerProfileController controller) {
    final status = job['status'] ?? 'active';
    final statusColor = controller.getJobStatusColor(status);
    final statusText = controller.getJobStatusText(status);
    final postedDate = job['postedDate'] ?? job['createdAt'] ?? DateTime.now().toString();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.work_outline, color: primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title'] ?? 'Untitled Job',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job['company'] ?? 'Company Name',
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildInfoChip(Icons.location_on_outlined, job['location'] ?? 'Remote'),
                    _buildInfoChip(Icons.work_outline, job['type'] ?? 'Full-time'),
                    _buildInfoChip(Icons.attach_money, controller.formatJobSalary(job)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job['about'] ?? job['description'] ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Posted ${controller.formatDate(postedDate)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  Icons.visibility_outlined, 'View', Colors.blue, 
                  () => _showJobDetailsDialog(context, job, controller)
                ),
                Container(width: 1, height: 20, color: Colors.grey[200]),
                if (status == 'active')
                  _buildActionButton(Icons.pause_circle_outline, 'Pause', Colors.orange, 
                      () => _showPauseConfirmDialog(job, controller))
                else if (status == 'paused')
                  _buildActionButton(Icons.play_circle_outline, 'Resume', Colors.green, 
                      () => _showResumeConfirmDialog(job, controller))
                else
                  _buildActionButton(Icons.refresh_outlined, 'Renew', Colors.blue, () {}),
                Container(width: 1, height: 20, color: Colors.grey[200]),
                _buildActionButton(Icons.delete_outline, 'Delete', Colors.red, 
                    () => _showDeleteConfirmDialog(job, controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.grey[600]),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DATA ROW FOR TABLE ====================
  DataRow _buildDataRow(BuildContext context, Map<String, dynamic> job, EmployerProfileController controller) {
    final status = job['status'] ?? 'active';
    final statusColor = controller.getJobStatusColor(status);
    final statusText = controller.getJobStatusText(status);
    final postedDate = job['postedDate'] ?? job['createdAt'] ?? DateTime.now().toString();

    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? 'Untitled Job',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  job['company'] ?? 'Company Name',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        DataCell(SizedBox(width: 80, child: Text(job['type'] ?? 'Full-time', style: const TextStyle(fontSize: 11)))),
        DataCell(SizedBox(width: 100, child: Text(job['location'] ?? 'Remote', style: const TextStyle(fontSize: 11)))),
        DataCell(SizedBox(width: 100, child: Text(controller.formatJobSalary(job), style: const TextStyle(fontSize: 11)))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w500)),
          ),
        ),
        DataCell(Text(controller.formatDate(postedDate), style: const TextStyle(fontSize: 11))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, size: 16, color: Colors.blue),
                onPressed: () => _showJobDetailsDialog(context, job, controller),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              if (status == 'active')
                IconButton(
                  icon: Icon(Icons.pause, size: 16, color: Colors.orange),
                  onPressed: () => _showPauseConfirmDialog(job, controller),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else if (status == 'paused')
                IconButton(
                  icon: Icon(Icons.play_arrow, size: 16, color: Colors.green),
                  onPressed: () => _showResumeConfirmDialog(job, controller),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete, size: 16, color: Colors.red),
                onPressed: () => _showDeleteConfirmDialog(job, controller),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
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
            child: Icon(Icons.work_outline, size: 40, color: primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          const Text('No Jobs Posted Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Create your first job posting', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Post a Job', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOGS ====================
  void _showDeleteConfirmDialog(Map<String, dynamic> job, EmployerProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Job Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this job post?', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.work_outline, color: primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(job['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('This action cannot be undone.', style: TextStyle(color: Colors.red[400], fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(fontSize: 13))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteJobPost(job['_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Delete', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showPauseConfirmDialog(Map<String, dynamic> job, EmployerProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pause Job Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This job will no longer be visible to applicants. You can resume it anytime.', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.work_outline, color: primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(job['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(fontSize: 13))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.pauseJobPost(job['_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Pause', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showResumeConfirmDialog(Map<String, dynamic> job, EmployerProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Resume Job Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This job will become visible to applicants again.', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.work_outline, color: primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(job['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(fontSize: 13))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.resumeJobPost(job['_id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Resume', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
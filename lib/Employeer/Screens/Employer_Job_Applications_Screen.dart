import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:templink/Employeer/Controller/employer_job_application_controller.dart';
import 'package:templink/Employeer/Screens/Employer_Application_detail.dart';
import 'package:templink/Employeer/model/employer_job_application.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

class EmployerJobApplicationsScreen extends StatelessWidget {
  final EmployerApplicationController controller = Get.put(EmployerApplicationController());

  EmployerJobApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isWeb = isDesktop || isTablet;

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // ==================== WEB LAYOUT ====================
  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildWebTopBar(),
          Expanded(
            child: _buildWebContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTopBar() {
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
          const Text(
            'Job Applications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Summary cards in top bar for web
          _buildWebSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildWebSummaryCards() {
    return Obx(() {
      if (controller.summary.value == null) {
        return const SizedBox();
      }

      final summary = controller.summary.value!;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildWebSummaryCard('Total', summary.total.toString(), Icons.apps, primary),
            const SizedBox(width: 16),
            _buildWebSummaryCard('Pending', summary.pending.toString(), Icons.pending, Colors.orange),
            const SizedBox(width: 16),
            _buildWebSummaryCard('Shortlisted', summary.shortlisted.toString(), Icons.star, Colors.green),
            const SizedBox(width: 16),
            _buildWebSummaryCard('Reviewed', summary.reviewed.toString(), Icons.visibility, Colors.blue),
            const SizedBox(width: 16),
            _buildWebSummaryCard('Rejected', summary.rejected.toString(), Icons.cancel, Colors.red),
            const SizedBox(width: 16),
            _buildWebSummaryCard('Hired', summary.hired.toString(), Icons.work, Colors.purple),
          ],
        ),
      );
    });
  }

  Widget _buildWebSummaryCard(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebContent() {
    return RefreshIndicator(
      onRefresh: controller.fetchEmployerApplications,
      color: primary,
      child: Obx(() {
        if (controller.isLoadingApplications.value && controller.applications.isEmpty) {
          return _buildLoadingShimmerWeb();
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorWidgetWeb();
        }

        if (controller.applications.isEmpty) {
          return _buildEmptyStateWeb();
        }

        return Row(
          children: [
            // Left sidebar - Filters
            Expanded(
              flex: 1,
              child: _buildWebFiltersSidebar(),
            ),
            // Right content - Applications list
            Expanded(
              flex: 2,
              child: _buildWebApplicationsContent(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWebFiltersSidebar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          const Text(
            'Search',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: controller.searchApplications,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          // Job Filter
          const Text(
            'Filter by Job',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedJobId.value,
            items: controller.jobsList.map<DropdownMenuItem<String>>((job) {
              return DropdownMenuItem<String>(
                value: job['id'] as String,
                child: Text(
                  job['title'] as String,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.filterByJob(value);
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              isDense: true,
            ),
          )),
          const SizedBox(height: 20),
          // Status Filter
          const Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusFilterChips(),
          const SizedBox(height: 20),
          // Clear Filters
          if (controller.selectedJobId.value != 'all' || controller.searchQuery.value.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  controller.filterByJob('all');
                  controller.searchQuery.value = '';
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Clear Filters',
                  style: TextStyle(color: primary, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChips() {
    final statuses = ['All', 'Pending', 'Reviewed', 'Shortlisted', 'Rejected', 'Hired'];
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = controller.selectedStatus.value == status.toLowerCase();
        return FilterChip(
          label: Text(
            status,
            style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey.shade700),
          ),
          selected: isSelected,
          onSelected: (_) {
            controller.filterByStatus(status.toLowerCase());
          },
          backgroundColor: Colors.grey.shade100,
          selectedColor: primary,
          checkmarkColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        );
      }).toList(),
    ));
  }

  Widget _buildWebApplicationsContent() {
    return Obx(() {
      if (controller.filteredApplications.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_alt_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No applications found',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.filteredApplications.length} applications found',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: controller.filteredApplications.length,
              itemBuilder: (context, index) {
                final application = controller.filteredApplications[index];
                return _buildApplicationCardWeb(application);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildApplicationCardWeb(EmployerJobApplication app) {
    final bool hasLeft = app.status == 'hired' && app.employmentStatus == 'left';
    if (hasLeft) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => ApplicationDetailScreen(application: app));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: app.employeeSnapshot.photoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(app.employeeSnapshot.photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: app.employeeSnapshot.photoUrl.isEmpty
                      ? Center(
                          child: Text(
                            '${app.employeeSnapshot.firstName[0]}${app.employeeSnapshot.lastName[0]}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${app.employeeSnapshot.firstName} ${app.employeeSnapshot.lastName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(app.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(app.status).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStatusIcon(app.status), size: 12, color: _getStatusColor(app.status)),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusText(app.status),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(app.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.employeeSnapshot.title,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      // Job info row
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: 12, color: primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              app.jobSnapshot.title,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Skills and badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadgeWeb(Icons.timeline, app.employeeSnapshot.experienceLevel, Colors.blue),
                          _buildBadgeWeb(Icons.attach_money, app.employeeSnapshot.hourlyRate, Colors.green),
                          _buildBadgeWeb(Icons.watch, '${_calculateMatchPercentage(app).toInt()}% Match', primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Skills list
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: app.employeeSnapshot.skills.take(4).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            'Applied ${_formatDate(app.appliedAt)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeWeb(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Job Applications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchEmployerApplications,
        color: primary,
        child: Obx(() {
          if (controller.isLoadingApplications.value && controller.applications.isEmpty) {
            return _buildLoadingShimmerMobile();
          }

          if (controller.errorMessage.isNotEmpty) {
            return _buildErrorWidgetMobile();
          }

          if (controller.applications.isEmpty) {
            return _buildEmptyStateMobile();
          }

          return Column(
            children: [
              _buildSummaryCardsMobile(),
              _buildSearchBarMobile(),
              _buildJobFilterMobile(),
              _buildApplicationsCountMobile(),
              Expanded(
                child: controller.filteredApplications.isEmpty
                    ? _buildNoApplicationsForFilterMobile()
                    : _buildApplicationsListMobile(),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Mobile Summary Cards
  Widget _buildSummaryCardsMobile() {
    return Obx(() {
      if (controller.summary.value == null) return const SizedBox();

      final summary = controller.summary.value!;

      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryCardMobile('Total', summary.total.toString(), Icons.apps, primary),
                const SizedBox(width: 12),
                _buildSummaryCardMobile('Pending', summary.pending.toString(), Icons.pending, Colors.orange),
                const SizedBox(width: 12),
                _buildSummaryCardMobile('Shortlisted', summary.shortlisted.toString(), Icons.star, Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryCardMobile('Reviewed', summary.reviewed.toString(), Icons.visibility, Colors.blue),
                const SizedBox(width: 12),
                _buildSummaryCardMobile('Rejected', summary.rejected.toString(), Icons.cancel, Colors.red),
                const SizedBox(width: 12),
                _buildSummaryCardMobile('Hired', summary.hired.toString(), Icons.work, Colors.purple),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCardMobile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarMobile() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: controller.searchApplications,
        decoration: InputDecoration(
          hintText: 'Search by name or job title...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildJobFilterMobile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: controller.selectedJobId.value,
              items: controller.jobsList.map<DropdownMenuItem<String>>((job) {
                return DropdownMenuItem<String>(
                  value: job['id'] as String,
                  child: Text(job['title'] as String, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.filterByJob(value);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsCountMobile() {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${controller.filteredApplications.length} applications found',
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          if (controller.selectedJobId.value != 'all' || controller.searchQuery.value.isNotEmpty)
            TextButton(
              onPressed: () {
                controller.filterByJob('all');
                controller.searchQuery.value = '';
              },
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    ));
  }

  Widget _buildApplicationsListMobile() {
    return Obx(() => ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: controller.filteredApplications.length,
      itemBuilder: (context, index) {
        final application = controller.filteredApplications[index];
        return _buildApplicationCardMobile(application);
      },
    ));
  }

  Widget _buildApplicationCardMobile(EmployerJobApplication app) {
    final bool hasLeft = app.status == 'hired' && app.employmentStatus == 'left';
    if (hasLeft) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => ApplicationDetailScreen(application: app)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        image: app.employeeSnapshot.photoUrl.isNotEmpty
                            ? DecorationImage(image: NetworkImage(app.employeeSnapshot.photoUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: app.employeeSnapshot.photoUrl.isEmpty
                          ? Center(
                              child: Text(
                                '${app.employeeSnapshot.firstName[0]}${app.employeeSnapshot.lastName[0]}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${app.employeeSnapshot.firstName} ${app.employeeSnapshot.lastName}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app.employeeSnapshot.title,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(app.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(app.status).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(app.status), size: 12, color: _getStatusColor(app.status)),
                          const SizedBox(width: 4),
                          Text(_getStatusText(app.status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getStatusColor(app.status))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: 14, color: primary),
                          const SizedBox(width: 6),
                          Expanded(child: Text(app.jobSnapshot.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(app.jobSnapshot.location, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          const SizedBox(width: 12),
                          Icon(Icons.business_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(app.jobSnapshot.workplace, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildBadgeMobile(Icons.timeline, app.employeeSnapshot.experienceLevel, Colors.blue),
                    const SizedBox(width: 8),
                    _buildBadgeMobile(Icons.attach_money, app.employeeSnapshot.hourlyRate, Colors.green),
                    const SizedBox(width: 8),
                    _buildBadgeMobile(Icons.watch, '${_calculateMatchPercentage(app).toInt()}% Match', primary),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: app.employeeSnapshot.skills.take(4).map((skill) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                        child: Text(skill, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text('Applied ${_formatDate(app.appliedAt)}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.description, size: 12, color: primary),
                          const SizedBox(width: 4),
                          Text(_getFileExtension(app.resumeFileName), style: TextStyle(fontSize: 10, color: primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeMobile(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  // ==================== LOADING, ERROR, EMPTY STATES ====================
  Widget _buildLoadingShimmerWeb() {
    return Center(child: const CircularProgressIndicator());
  }

  Widget _buildLoadingShimmerMobile() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(30))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 12, color: Colors.grey[300]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidgetWeb() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(controller.errorMessage.value, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: controller.fetchEmployerApplications, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildErrorWidgetMobile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle), child: const Icon(Icons.error_outline, size: 48, color: Colors.red)),
            const SizedBox(height: 24),
            Text('Oops! Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 12),
            Text(controller.errorMessage.value, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: controller.fetchEmployerApplications, icon: const Icon(Icons.refresh), label: const Text('Try Again'), style: ElevatedButton.styleFrom(backgroundColor: primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWeb() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No Applications Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Applications will appear here when candidates apply.', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildEmptyStateMobile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.work_off_outlined, size: 64, color: primary)),
            const SizedBox(height: 24),
            Text('No Applications Yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 12),
            Text('You haven\'t received any applications yet.\nApplications will appear here when candidates apply.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoApplicationsForFilterMobile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_alt_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No applications found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Try changing your filters', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ============== HELPER FUNCTIONS ==============
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'reviewed': return Colors.blue;
      case 'shortlisted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'hired': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.pending;
      case 'reviewed': return Icons.visibility;
      case 'shortlisted': return Icons.star;
      case 'rejected': return Icons.cancel;
      case 'hired': return Icons.work;
      default: return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'reviewed': return 'Reviewed';
      case 'shortlisted': return 'Shortlisted';
      case 'rejected': return 'Rejected';
      case 'hired': return 'Hired';
      default: return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getFileExtension(String fileName) {
    final extension = fileName.split('.').last;
    return extension.toUpperCase();
  }

  double _calculateMatchPercentage(EmployerJobApplication app) {
    final jobSkills = app.jobSnapshot.requirements.toLowerCase().split(' ').where((word) => word.length > 3).toList();
    final employeeSkills = app.employeeSnapshot.skills.map((s) => s.toLowerCase()).toList();
    if (jobSkills.isEmpty || employeeSkills.isEmpty) return 75.0;
    int matches = 0;
    for (var skill in employeeSkills) {
      if (jobSkills.any((word) => word.contains(skill))) matches++;
    }
    return (matches / jobSkills.length * 100).clamp(0, 100);
  }
}
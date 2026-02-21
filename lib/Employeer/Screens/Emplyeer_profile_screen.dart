import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_profile_controller.dart';
import 'package:templink/Employeer/Screens/Edit_Employeer_Profile.dart';
import 'package:templink/Employeer/widgets/bottom_sheet.dart';
import 'package:templink/Utils/colors.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  State<EmployerProfileScreen> createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EmployerProfileController controller = Get.put(EmployerProfileController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditEmployerProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: () {
              Get.to(() => const EditEmployerProfileScreen());
            },
          ),
        
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: primary,
                    unselectedLabelColor: Colors.black45,
                    indicatorColor: primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'My Jobs'),
                      Tab(text: 'My Projects'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(),
              _buildJobPostsTab(),
              _buildProjectsTab(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          // Profile Image / Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(56),
              child: controller.logoUrl.value.isNotEmpty
                  ? Image.network(
                      controller.logoUrl.value,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultLogo();
                      },
                    )
                  : _buildDefaultLogo(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.companyName.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              if (controller.isVerified.value)
                Icon(
                  Icons.verified,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.industry.value} • ${controller.fullCompanyLocation}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          if (controller.isVerified.value)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Employer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      side: BorderSide(
                        color: primary,
                        width: 1.5,
                      ),
                      foregroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Share functionality
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      elevation: 0,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(controller.activePosts.value, 'ACTIVE POSTS'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(controller.totalHired.value, 'TOTAL HIRED'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(controller.companySizeLabel.value, 'SIZE'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(controller.ratingDisplay.value, 'RATING'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A52),
        borderRadius: BorderRadius.circular(56),
      ),
      child: Center(
        child: Text(
          controller.companyInitials,
          style: const TextStyle(
            color: Colors.teal,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          title: 'About Company',
          hasEdit: true,
          onEdit: () {
            Get.to(() => const EditEmployerProfileScreen());
          },
          child: Text(
            controller.about.value,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Company Culture',
          hasEdit: true,
          onEdit: () {
            Get.to(() => const EditEmployerProfileScreen());
          },
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.cultureTags.map((tag) {
              return _buildChip(tag, Icons.favorite_border);
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          title: 'Team Members',
          hasEdit: true,
          onEdit: () {
            // Edit team functionality
          },
          child: Column(
            children: [
              // Show empty state if no team members
              if (controller.teamMembers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      'No team members yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ...controller.teamMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  
                  // Safe access with null checks
                  final memberName = member['name']?.toString() ?? '';
                  final memberRole = member['role']?.toString() ?? '';
                  final memberColor = member['avatarColor']?.toString() ?? '#14A800';
                  
                  return Column(
                    children: [
                      _buildTeamMember(
                        memberName,
                        memberRole,
                        _getColorFromString(memberColor),
                        hasRemove: true,
                        onRemove: () => controller.removeTeamMember(index),
                      ),
                      if (index < controller.teamMembers.length - 1)
                        const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
        
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobPostsTab() {
    return Obx(() {
      if (controller.isLoadingJobs.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (controller.filteredJobs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_outline,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No job posts yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
            
            
            ],
          ),
        );
      }
      
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stats Row
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildJobStat(
                    controller.totalJobs.value.toString(),
                    'Total Jobs',
                    Icons.work,
                    Colors.blue,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildJobStat(
                    controller.activeJobs.value.toString(),
                    'Active',
                    Icons.play_circle_outline,
                    Colors.green,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildJobStat(
                    controller.jobTypes.length.toString(),
                    'Categories',
                    Icons.category,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (_) => controller.filterJobsByType('All'),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: primary.withOpacity(0.2),
                  checkmarkColor: primary,
                ),
                const SizedBox(width: 8),
                ...controller.jobTypes.take(5).map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: false,
                      onSelected: (_) => controller.filterJobsByType(type),
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: primary.withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          // Jobs List
          ...controller.filteredJobs.map((job) {
            return _buildDynamicJobCard(job);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildJobStat(String value, String label, IconData icon, Color color) {
    return Column(
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
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget  _buildDynamicJobCard(Map<String, dynamic> job) {
    final company = job['company'] ?? controller.companyName.value;
    final type = job['type'] ?? 'Full-time';
    final workplace = job['workplace'] ?? 'Onsite';
    final location = job['location'] ?? controller.fullCompanyLocation;
    final salary = controller.formatJobSalary(job);
    final date = controller.formatDate(job['postedDate'] ?? job['createdAt'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
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
       Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Text(
        job['title'] ?? 'Untitled Job',
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ),
    // ✅ FIXED: Dynamic status chip
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: controller.getJobStatusColor(job['status'] ?? 'active').withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        controller.getJobStatusText(job['status'] ?? 'active'),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: controller.getJobStatusColor(job['status'] ?? 'active'),
        ),
      ),
    ),
  ],
),
          const SizedBox(height: 8),
          Text(
            '$company • $type • $workplace',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // About section
          if (job['about'] != null && job['about'].toString().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                job['about'],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Requirements
          if (job['requirements'] != null && job['requirements'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Requirements: ${job['requirements']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          
          // Qualifications
          if (job['qualifications'] != null && job['qualifications'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.school_outlined, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Qualifications: ${job['qualifications']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          
          // Salary and Date
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                salary,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Posted $date',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Images/Gallery
          if (job['images'] != null && (job['images'] as List).isNotEmpty)
            Container(
              height: 60,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (job['images'] as List).length,
                itemBuilder: (context, index) {
                  final image = (job['images'] as List)[index];
                  return Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      image: image['url'] != null
                          ? DecorationImage(
                              image: NetworkImage(image['url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: image['url'] == null
                        ? const Icon(Icons.image, color: Colors.grey)
                        : null,
                  );
                },
              ),
            ),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View applicants
                  },
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('View Applicants'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: primary, width: 1.5),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
// Replace the existing IconButton with this:
PopupMenuButton(
  icon: const Icon(Icons.more_vert),
  color: Colors.white,
  itemBuilder: (context) {
    final isPaused = job['status'] == 'paused';
    final isActive = job['status'] == 'active' || job['status'] == null;
    
    return [
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, size: 18, color: Colors.blue),
            SizedBox(width: 8),
            Text('Edit Job'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'duplicate',
        child: Row(
          children: [
            Icon(Icons.content_copy, size: 18, color: Colors.purple),
            SizedBox(width: 8),
            Text('Duplicate'),
          ],
        ),
      ),
      // Show Pause or Resume based on status
      if (isActive)
        const PopupMenuItem(
          value: 'pause',
          child: Row(
            children: [
              Icon(Icons.pause_circle_outline, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text('Pause Job'),
            ],
          ),
        ),
      if (isPaused)
        const PopupMenuItem(
          value: 'resume',
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, size: 18, color: Colors.green),
              SizedBox(width: 8),
              Text('Resume Job'),
            ],
          ),
        ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Job'),
          ],
        ),
      ),
    ];
  },
  onSelected: (value) async {
    final jobId = job['_id'];
    final jobTitle = job['title'] ?? 'this job';
    
    if (value == 'delete') {
      _showDeleteConfirmation(context, jobId, jobTitle,);
    } else if (value == 'edit') {
      Get.snackbar('Info', 'Edit feature coming soon');
    } else if (value == 'duplicate') {
      Get.snackbar('Info', 'Duplicate feature coming soon');
    } else if (value == 'pause') {
      _showPauseConfirmation(context, jobId, jobTitle);
    } else if (value == 'resume') {
      _showResumeConfirmation(context, jobId, jobTitle);
    }
  },
)            ],
          ),
        ],
      ),
    );
  }

void _showPauseConfirmation(BuildContext context, String jobId, String jobTitle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Pause Job Post',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to pause "$jobTitle"?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Paused jobs will not be visible to applicants. You can resume them anytime.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            
            Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
            
            final success = await controller.pauseJobPost(jobId);
            
            if (Get.isDialogOpen ?? false) Get.back();
            
            if (success) {
              controller.update();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Pause'),
        ),
      ],
    ),
  );
}

void _showResumeConfirmation(BuildContext context, String jobId, String jobTitle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Resume Job Post',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text('Are you sure you want to resume "$jobTitle"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            
            Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
            
            final success = await controller.resumeJobPost(jobId);
            
            if (Get.isDialogOpen ?? false) Get.back();
            
            if (success) {
              controller.update();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Resume'),
        ),
      ],
    ),
  );
}
  Widget _buildProjectsTab() {
    return Obx(() {
      if (controller.isLoadingProjects.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      if (controller.filteredProjects.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No projects yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
            
            
            ],
          ),
        );
      }
      
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stats Row
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildProjectStat(
                    controller.activeProjects.value.toString(),
                    'Active',
                    Icons.play_circle_outline,
                    Colors.green,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildProjectStat(
                    controller.completedProjects.value.toString(),
                    'Completed',
                    Icons.check_circle_outline,
                    Colors.blue,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildProjectStat(
                    controller.totalProposals.value.toString(),
                    'Proposals',
                    Icons.people_outline,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          
          // Projects List
          ...controller.filteredProjects.map((project) {
            return _buildDynamicProjectCard(project);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildProjectStat(String value, String label, IconData icon, Color color) {
    return Column(
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
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicProjectCard(Map<String, dynamic> project) {
    final status = project['status'] ?? 'OPEN';
    final statusColor = controller.getStatusColor(status);
    final statusText = controller.getStatusText(status);
    final budget = controller.formatBudget(
      project['minBudget']?.toDouble() ?? 0,
      project['maxBudget']?.toDouble() ?? 0,
      project['budgetType'] ?? 'FIXED',
    );
    final date = controller.formatDate(project['createdAt'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'OPEN' ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project['title'] ?? 'Untitled Project',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${project['category'] ?? 'Category'} • ${project['duration'] ?? 'Duration'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                budget,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.people_outline, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${project['proposalsCount'] ?? 0} proposals',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (project['skills'] as List? ?? []).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  skill.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Posted $date',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View project details
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: primary, width: 1.5),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
          // Inside _buildDynamicProjectCard, find the IconButton at the bottom
// Replace the existing IconButton with this:

PopupMenuButton(
  icon: const Icon(Icons.more_vert),
  color: Colors.white,
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit, size: 18, color: Colors.blue),
          SizedBox(width: 8),
          Text('Edit Project'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'view_proposals',
      child: Row(
        children: [
          Icon(Icons.people, size: 18, color: Colors.purple),
          SizedBox(width: 8),
          Text('View Proposals'),
        ],
      ),
    ),
    if (status == 'OPEN')
      const PopupMenuItem(
        value: 'pause',
        child: Row(
          children: [
            Icon(Icons.pause_circle_outline, size: 18, color: Colors.orange),
            SizedBox(width: 8),
            Text('Pause Project'),
          ],
        ),
      ),
    const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete_outline, size: 18, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete Project'),
        ],
      ),
    ),
  ],
  onSelected: (value) async {
    if (value == 'delete') {
      _showProjectDeleteConfirmation(context, project['_id'], project['title'] ?? 'this project');
    } else if (value == 'edit') {
      // Navigate to edit screen
      Get.snackbar('Info', 'Edit feature coming soon');
    } else if (value == 'view_proposals') {
      // Navigate to proposals screen
      Get.snackbar('Info', 'View proposals feature coming soon');
    } else if (value == 'pause') {
      // Pause project
      Get.snackbar('Info', 'Pause feature coming soon');
    }
  },
)
            ],
          ),
        ],
      ),
    );
  }
  void _showProjectDeleteConfirmation(BuildContext context, String projectId, String projectTitle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Delete Project',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "$projectTitle"?',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action cannot be undone. All proposals and data related to this project will be permanently removed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          child: const Text('Cancel'),
        ),
        Obx(() {
          final isLoading = controller.isLoadingProjects.value;
          return ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    Navigator.pop(context); // Close dialog
                    
                    // Show loading
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      barrierDismissible: false,
                    );
                    
                    // Delete project
                    final success = await controller.deleteProject(projectId);
                    
                    // Close loading
                    if (Get.isDialogOpen ?? false) Get.back();
                    
                    if (success) {
                      // Success message already shown in controller
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Delete'),
          );
        }),
      ],
    ),
  );
}
// Around line 1360 - Delete confirmation
void _showDeleteConfirmation(BuildContext context, String jobId, String jobTitle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Delete Job Post',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete "$jobTitle"?',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This action cannot be undone. All applications and data related to this job will be permanently removed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          child: const Text('Cancel'),
        ),
        Obx(() {
          final isLoading = controller.isLoadingJobs.value;
          return ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    Navigator.pop(context); // Close dialog
                    
                    // Show loading
                    Get.dialog(
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      barrierDismissible: false,
                    );
                    
                    // Delete job
                    final success = await controller.deleteJobPost(jobId);
                    
                    // Close loading
                    if (Get.isDialogOpen ?? false) Get.back();
                    
                    if (success) {
                      // Success message already shown in controller
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Delete'),
          );
        }),
      ],
    ),
  );
}
  Widget _buildSectionCard({
    required String title,
    required Widget child,
    bool hasEdit = false,
    VoidCallback? onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
           
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black38),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(
    String name,
    String role,
    Color color, {
    bool hasRemove = false,
    VoidCallback? onRemove,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        if (hasRemove)
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
          ),
      ],
    );
  }


  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case '#1E88E5': return Colors.blue.shade700;
      case '#8E44AD': return Colors.purple.shade400;
      case '#00897B': return Colors.teal.shade600;
      case '#14A800': return primary;
      default: return primary;
    }
  }

  void _showJobOptionsBottomSheet(String jobTitle, String status) {
    // Implement bottom sheet
  }

  void _showProjectOptionsBottomSheet(String projectTitle, String status) {
    // Implement bottom sheet
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
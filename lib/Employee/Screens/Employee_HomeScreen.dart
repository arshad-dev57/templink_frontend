import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects.dart';
import 'package:templink/Employee/Screens/Employee_Job_Detail_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Stats_Screen.dart';
import 'package:templink/Employee/Screens/Employee_proposals_Screen.dart';
import 'package:templink/Employee/models/Employee_jobs_model.dart';
import 'package:templink/Employee/models/project_model.dart';
import 'package:templink/Employeer/Screens/project_detail_screen.dart';
import 'package:templink/Global_Screens/Chat_Users_List_Screen.dart';
import 'package:templink/Global_Screens/Notification_Screen.dart';
import 'package:templink/Global_Screens/Search_Screen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int selectedFeedTab = 0; 
  
  int selectedJobFilterIndex = 0;
  int selectedProjectFilterIndex = 0;

  final EmployeeHomeController homeController = Get.put(EmployeeHomeController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> jobFilters = [
    {'label': 'All', 'icon': Icons.all_inclusive},
    {'label': 'Remote Only', 'icon': Icons.home_work},
    {'label': 'Full-time', 'icon': Icons.access_time},
    {'label': 'Contract', 'icon': Icons.description},
    {'label': 'Urgent', 'icon': Icons.priority_high},
  ];

  // ✅ Project Filters - Using available fields from ProjectFeedModel
  final List<Map<String, dynamic>> projectFilters = [
    {'label': 'All', 'icon': Icons.all_inclusive},
    {'label': 'Featured', 'icon': Icons.star},
    {'label': 'Fixed Budget', 'icon': Icons.attach_money},
    {'label': 'Hourly', 'icon': Icons.timer},
    {'label': 'New', 'icon': Icons.fiber_new},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      drawer: _buildDrawer(),
      bottomNavigationBar: _customBottomNavBar(),
      body: SafeArea(
        child: _getCurrentScreen(),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ChatUsersListScreen();
      case 2:
        return const MyProposalsScreen();
      case 3:
        return const Center(child: SearchScreen());
      case 4:
        return const EmployeeProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: homeController.imageUrl.value.isNotEmpty
                        ? NetworkImage(homeController.imageUrl.value)
                        : const NetworkImage('https://i.pravatar.cc/300?img=11'),
                  ),
                )),
                const SizedBox(height: 16),
                Obx(() => Text(
                  homeController.fullName.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Free Account',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _drawerItem(Icons.person_outline, 'Profile', () {
                  Get.to(() => const EmployeeProfileScreen());
                }),
                _drawerItem(Icons.bar_chart_outlined, 'My stats', () {
                  Get.to(MyStatsScreen());
                }),
                _drawerItem(Icons.assignment_outlined, 'Reports', () {}),
                _drawerItem(Icons.dashboard, "Dashboard", (){
                  Get.to(EmployeeActiveProjectsScreen());
                }),
                
                _drawerItem(Icons.request_page_outlined, 'My Requests', () {}),
                _drawerItem(Icons.settings_outlined, 'Settings', () {}),
                _drawerItem(Icons.help_outline, 'Help & Support', () {}),
                _buildThemeItem(),
                _buildLogoutItem(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildThemeItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.palette_outlined, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 12),
          const Text(
            'Theme: Auto',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Auto',
              style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove('auth_token');
            prefs.remove('auth_user');
            prefs.remove('auth_role');
            print("User logged out. Token, user data, and role cleared from SharedPreferences.");
            Get.offAll(() => const LoginScreen());
          });
        },
        child: Row(
          children: [
            Icon(Icons.logout_outlined, color: Colors.red.shade400, size: 22),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(height: 40, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                'Version 2.1.0 (1768)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              Text(
                '© 2024 Templink. All rights reserved.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navIcon('assets/home.png', 0),
            _navIcon('assets/chat.png', 1),
            _navIcon('assets/proposals.png', 2),
            _navIcon('assets/search.png', 3),
            _navIcon('assets/user.png', 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(String image, int index) {
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Image.asset(
        image,
        color: selected ? Colors.white : Colors.white54,
        height: 24,
      ),
    );
  }

  // ==================== MAIN HOME CONTENT ====================
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () => homeController.fetchAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            const SizedBox(height: 8),
            _buildFeedTabs(),
            const SizedBox(height: 20),
            
            // ✅ Dynamic filter chips based on selected tab
            if (selectedFeedTab == 0) _buildJobFilterChips(),
            if (selectedFeedTab == 1) _buildProjectFilterChips(),
            
            const SizedBox(height: 20),
            _buildFeedContent(),
            const SizedBox(height: 30),
            _buildSkillsMatchCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Row(
              children: [
                Obx(() => CircleAvatar(
                  radius: 22,
                  backgroundImage: homeController.imageUrl.value.isNotEmpty
                      ? NetworkImage(homeController.imageUrl.value)
                      : const NetworkImage('https://i.pravatar.cc/300?img=11'),
                )),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                      homeController.fullName.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 26),
                onPressed: () => Get.to(() => const NotificationScreen()),
              ),
              Positioned(
                right: 8,
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
    );
  }

  Widget _buildFeedTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTabButton('Jobs', 0),
            _buildTabButton('Projects', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedFeedTab = index;
          // Reset filters when switching tabs
          if (index == 0) selectedJobFilterIndex = 0;
          if (index == 1) selectedProjectFilterIndex = 0;
        }),
        child: Container(
          decoration: BoxDecoration(
            color: selectedFeedTab == index ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selectedFeedTab == index
                ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selectedFeedTab == index ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ JOB FILTER CHIPS - Using available JobPostModel fields
  Widget _buildJobFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: jobFilters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            return Row(
              children: [
                _jobFilterChip(filter['label'], filter['icon'], index),
                if (index < jobFilters.length - 1) const SizedBox(width: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _jobFilterChip(String label, IconData icon, int index) {
    final selected = selectedJobFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedJobFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primary : Colors.grey.shade300, width: 1),
          boxShadow: selected
              ? [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ PROJECT FILTER CHIPS - Using available ProjectFeedModel fields
  Widget _buildProjectFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: projectFilters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            return Row(
              children: [
                _projectFilterChip(filter['label'], filter['icon'], index),
                if (index < projectFilters.length - 1) const SizedBox(width: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _projectFilterChip(String label, IconData icon, int index) {
    final selected = selectedProjectFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedProjectFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primary : Colors.grey.shade300, width: 1),
          boxShadow: selected
              ? [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent() {
    return selectedFeedTab == 0 ? _buildJobsSection() : _buildProjectsSection();
  }

  // ==================== JOBS SECTION WITH FILTERS ====================
  Widget _buildJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getJobSectionTitle(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(foregroundColor: primary),
              //   child: const Text('See All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() {
            if (homeController.isLoadingJobs.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (homeController.jobsError.value != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      homeController.jobsError.value!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => homeController.fetchJobs(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (homeController.jobs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No jobs found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }

            // ✅ Apply job filters
            List<JobPostModel> filteredJobs = homeController.jobs;
            
            switch (selectedJobFilterIndex) {
              case 1: // Remote Only
                filteredJobs = filteredJobs.where((j) => 
                  j.workplace.toLowerCase() == 'remote'
                ).toList();
                break;
              case 2: // Full-time
                filteredJobs = filteredJobs.where((j) => 
                  j.type.toLowerCase().contains('full')
                ).toList();
                break;
              case 3: // Contract
                filteredJobs = filteredJobs.where((j) => 
                  j.type.toLowerCase().contains('contract')
                ).toList();
                break;
              case 4: // Urgent
                filteredJobs = filteredJobs.where((j) => 
                  j.urgency == true
                ).toList();
                break;
            }

            if (filteredJobs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.work_off, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No jobs match this filter',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: filteredJobs.map((job) => _buildJobCard(job)).toList(),
            );
          }),
        ),
      ],
    );
  }

  String _getJobSectionTitle() {
    switch (selectedJobFilterIndex) {
      case 0: return 'All Jobs';
      case 1: return 'Remote Jobs';
      case 2: return 'Full-time Jobs';
      case 3: return 'Contract Jobs';
      case 4: return 'Urgent Jobs';
      default: return 'Featured Jobs';
    }
  }

  // ✅ UPDATED: Job Card with all fields
  Widget _buildJobCard(JobPostModel job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: job.logoUrl != null && job.logoUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                job.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      job.companyInitials,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                job.companyInitials,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (job.isVerified) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.displayCompanyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (job.urgency)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Text(
                    'URGENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Location
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.employerLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.displayTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    color: primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Match Score (static for now)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Score',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42, // 70% of 60
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green, Colors.lightGreen],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '70%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.bookmark_border, color: Colors.grey.shade600, size: 20),
                    onPressed: () {
                      // Bookmark functionality
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => JobDetailScreen(job: job));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== PROJECTS SECTION WITH FILTERS ====================
  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getProjectSectionTitle(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(foregroundColor: primary),
              //   child: const Text('See All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() {
            if (homeController.isLoadingProjects.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (homeController.projectsError.value != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      homeController.projectsError.value!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => homeController.fetchProjects(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (homeController.projects.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No projects found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            }

            // ✅ Apply project filters
            List<ProjectFeedModel> filteredProjects = homeController.projects;
            
            switch (selectedProjectFilterIndex) {
              case 1: // Featured
                filteredProjects = filteredProjects.where((p) => p.featured).toList();
                break;
              case 2: // Fixed Budget
                filteredProjects = filteredProjects.where((p) => 
                  p.budgetType == 'FIXED'
                ).toList();
                break;
              case 3: // Hourly
                filteredProjects = filteredProjects.where((p) => 
                  p.budgetType == 'HOURLY'
                ).toList();
                break;
              case 4: // New
                filteredProjects = filteredProjects.where((p) {
                  if (p.createdAt == null) return false;
                  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
                  return p.createdAt!.isAfter(sevenDaysAgo);
                }).toList();
                break;
            }

            if (filteredProjects.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.folder_off, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No projects match this filter',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: filteredProjects.map((project) => _buildProjectCard(project)).toList(),
            );
          }),
        ),
      ],
    );
  }

  String _getProjectSectionTitle() {
    switch (selectedProjectFilterIndex) {
      case 0: return 'All Projects';
      case 1: return 'Featured Projects';
      case 2: return 'Fixed Budget Projects';
      case 3: return 'Hourly Projects';
      case 4: return 'New Projects';
      default: return 'Recommended Projects';
    }
  }

  // ✅ UPDATED: Project Card with all fields
  Widget _buildProjectCard(ProjectFeedModel project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Client: ${project.displayClientName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (project.isVerified) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (project.featured)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      // Bookmark functionality
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _projectDetail(Icons.attach_money, project.displayBudget),
              const SizedBox(width: 16),
              _projectDetail(Icons.schedule, project.duration),
              const SizedBox(width: 16),
              _projectDetail(Icons.work_outline, project.experienceLevel),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: project.skills.take(4).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    '${project.proposalsCount} proposals',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    project.displayPostedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => ProjectDetailScreen(project: project));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'Submit Proposal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _projectDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsMatchCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  'Skills Match',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '98% Match',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your skills are highly sought after! Increase your visibility:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _skillChip('Flutter'),
                _skillChip('Dart'),
                _skillChip('UI/UX Design'),
                _skillChip('Firebase'),
                _skillChip('REST APIs'),
                _skillChip('Figma'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Boost Profile Visibility',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: TextStyle(
              fontSize: 13,
              color: primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.check_circle,
            size: 14,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}
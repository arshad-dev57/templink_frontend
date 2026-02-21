import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employee/models/project_model.dart';
import 'package:templink/Employeer/Screens/Employeer_Projects_Discovery_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_Talent_Discovery_Screen.dart';
import 'package:templink/Employeer/Screens/Emplyeer_profile_screen.dart';
import 'package:templink/Employeer/Screens/employer_own_projects_screen.dart';
import 'package:templink/Employeer/Screens/project_detail_screen.dart';
import 'package:templink/Employeer/Screens/project_management_screen.dart';
import 'package:templink/Employeer/Screens/select_post_type_screen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Global_Screens/Chat_Users_List_Screen.dart';
import 'package:templink/Global_Screens/Notification_Screen.dart';
import 'package:templink/Global_Screens/Settings_Screen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';

class EmployeerHomeScreen extends StatefulWidget {
  const EmployeerHomeScreen({super.key});

  @override
  State<EmployeerHomeScreen> createState() => _EmployeerHomeScreenState();
}

class _EmployeerHomeScreenState extends State<EmployeerHomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int selectedCategoryIndex = 0;
  int selectedProjectTab = 0;

  // ✅ Controller
  final EmployeeHomeController homeController = Get.put(EmployeeHomeController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ✅ Filter states
  var selectedTalentFilter = 'All'.obs;
  var selectedProjectFilter = 'All'.obs;
  
  final List<String> talentFilters = ['All', 'Top Rated', 'Available'];
  final List<String> projectFilters = ['All', 'Featured'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      bottomNavigationBar: _customBottomNavBar(),
      drawer: _buildDrawer(homeController),
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
        return const EmployerOwnProjectsScreen();
      case 2:
        return const Center(child: EmployerOwnProjectsScreen());
      case 3:
        return const Center(child: SettingsScreen());
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildDrawer(EmployeeHomeController controller) {
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
                Obx(
                  ()=> ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      controller.imageUrl.value.isNotEmpty 
                          ? controller.imageUrl.value 
                          : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 44,
                        height: 44,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    controller.fullName.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
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
                  Get.to(() => const EmployerProfileScreen());
                }),
              _drawerItem(Icons.work_outline, 'My Projects', () {
                Get.to(EmployerProjectManagementScreen());
              }),

                _drawerItem(Icons.bar_chart_outlined, 'My stats', () {}),

                _drawerItem(Icons.assignment_outlined, 'Reports', () {}),
                _drawerItem(Icons.settings_outlined, 'Settings', () {
                  Get.to(() => const SettingsScreen());
                }),
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
          const Text('Theme: Auto', style: TextStyle(fontSize: 14, color: Colors.black87)),
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
        onTap: () {
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove('auth_token');
            prefs.remove('auth_user');
            prefs.remove('auth_role');
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
            _navIcon(Icons.home_outlined, 0),
            _navIcon(Icons.message_outlined, 1),
            GestureDetector(
              onTap: () {
                Get.to(() => SelectPostTypeScreen());
              },
              child: Container(
                height: 54,
                width: 54,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 24,
                    color: primary,
                  ),
                ),
              ),
            ),
            _navIcon(Icons.description, 2),
            _navIcon(Icons.settings, 3),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final selected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: Icon(
        icon,
        color: selected ? Colors.white : Colors.white54,
        size: 24,
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () => Future.wait([
        homeController.fetchProjects(),
        homeController.fetchTalents(),
      ]),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _topBar(homeController),
            const SizedBox(height: 20),
            _projectsTabBar(),
            const SizedBox(height: 20),
            if (selectedProjectTab == 0) ...[
              _recommendedSection(),
            ] else ...[
              _currentProjectsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _topBar(EmployeeHomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Obx(
                ()=> ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    controller.imageUrl.value.isNotEmpty 
                        ? controller.imageUrl.value 
                        : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 44,
                      height: 44,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.fullName.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.black87,
                size: 26,
              ),
              onPressed: () {
                Get.to(() => const NotificationScreen());
              },
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _projectsTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabButton("Top Talent", 0),
          _tabButton("Projects", 1),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedProjectTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: selectedProjectTab == index ? primary : Colors.transparent,
            boxShadow: selectedProjectTab == index
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: selectedProjectTab == index ? Colors.white : primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== TALENT SECTION WITH FILTERS ====================
  Widget _recommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recommended for You",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            InkWell(
              onTap: () => Get.to(() => const TalentDiscoveryScreen()),
              child: Text(
                "See all",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // ✅ Talent Filter Chips - Using only available fields
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(talentFilters.length, (index) {
              final filter = talentFilters[index];
              return Obx(() => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: selectedTalentFilter.value == filter,
                  onSelected: (selected) {
                    selectedTalentFilter.value = filter;
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: primary.withOpacity(0.2),
                  checkmarkColor: primary,
                  labelStyle: TextStyle(
                    color: selectedTalentFilter.value == filter ? primary : Colors.black87,
                    fontWeight: selectedTalentFilter.value == filter ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ));
            }),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // ✅ Dynamic Talents with Filtering using available fields
        Obx(() {
          if (homeController.isLoadingTalents.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (homeController.talentsError.value != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    homeController.talentsError.value!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => homeController.fetchTalents(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ✅ Apply filters using available fields
          List<TalentModel> filteredTalents = homeController.recommendedTalents;
          
          if (selectedTalentFilter.value != 'All') {
            filteredTalents = filteredTalents.where((t) {
              switch (selectedTalentFilter.value) {
                case 'Top Rated':
                  // Check rating from employeeProfile
                  final rating = t.employeeProfile['rating'];
                  return rating != null && rating >= 4.5;
                case 'Available':
                  // Check availability from employeeProfile
                  final availability = t.employeeProfile['availability'];
                  return availability == 'AVAILABLE_NOW';
                default:
                  return true;
              }
            }).toList();
          }

          if (filteredTalents.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No talents match this filter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTalents.length > 3 ? 3 : filteredTalents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final talent = filteredTalents[index];
              return _talentCard(talent);
            },
          );
        }),
      ],
    );
  }

  // ✅ Talent Card (using your existing model)
  Widget _talentCard(TalentModel talent) {
    final displaySkills = talent.skills.length > 3 
        ? talent.skills.sublist(0, 3) 
        : talent.skills;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: talent.bgColor,
                  child: Stack(
                    children: [
                      Image.network(
                        talent.projectImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: talent.bgColor,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: talent.photoUrl.isNotEmpty
                                ? NetworkImage(talent.photoUrl)
                                : null,
                            child: talent.photoUrl.isEmpty
                                ? Text(
                                    talent.fullName.isNotEmpty 
                                        ? talent.fullName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (talent.badge.isNotEmpty)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: talent.badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      talent.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        talent.rating,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            talent.title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            talent.fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: displaySkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (talent.skills.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              '+${talent.skills.length - 3} more',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "HOURLY RATE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    talent.hourlyRate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => TalentProfileScreen(talent: talent));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View Profile",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== PROJECTS SECTION WITH FILTERS ====================
  Widget _currentProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recommended for you",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.menu,
              color: Colors.black87,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Based on your industry • ${_getIndustryText()}",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        
        // ✅ Category Tabs (Static)
        _categoryTabs(),
        const SizedBox(height: 16),
        
        // ✅ Project Filter Chips - Using only available fields
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(projectFilters.length, (index) {
              final filter = projectFilters[index];
              return Obx(() => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: selectedProjectFilter.value == filter,
                  onSelected: (selected) {
                    selectedProjectFilter.value = filter;
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: primary.withOpacity(0.2),
                  checkmarkColor: primary,
                  labelStyle: TextStyle(
                    color: selectedProjectFilter.value == filter ? primary : Colors.black87,
                    fontWeight: selectedProjectFilter.value == filter ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ));
            }),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Featured & Urgent Section
        Obx(() {
          if (homeController.isLoadingProjects.value) {
            return const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ));
          }

          if (homeController.projectsError.value != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
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

          // ✅ Apply filters using available fields
          List<ProjectFeedModel> filteredProjects = homeController.projects;
          
          // Apply featured filter
          if (selectedProjectFilter.value == 'Featured') {
            filteredProjects = filteredProjects.where((p) => p.featured).toList();
          }
          
          // Note: 'Urgent' and 'New' filters require fields that might not exist in your model
          // So we'll only use 'Featured' filter

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedProjectFilter.value == 'Featured' ? "Featured Projects" : "Recommended Projects",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.to(() => const ProjectsDiscoveryScreen()),
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (filteredProjects.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No projects match this filter',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final project = filteredProjects[index];
                    return _projectCard(project);
                  },
                ),
            ],
          );
        }),
      ],
    );
  }

  String _getIndustryText() {
    // This would come from user's employer profile
    return "Technology & Design";
  }

  Widget _categoryTabs() {
    final tabs = ["Top Matches", "Urgent", "New", "Remote"];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.black87 : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.black87 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Project Card (using your existing model)
  Widget _projectCard(ProjectFeedModel project) {
    // Get badges based on available fields
    List<String> badges = [];
    List<Color> badgeColors = [];
    
    if (project.featured) {
      badges.add('FEATURED');
      badgeColors.add(const Color(0xFF00BCD4));
    }

    final displaySkills = project.skills.length > 5 
        ? project.skills.sublist(0, 5) 
        : project.skills;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 0; i < badges.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: badgeColors[i],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badges[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Icon(
                  Icons.bookmark_border,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (project.isVerified) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.verified,
                    color: Colors.blue.shade700,
                    size: 18,
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 6),
            
            Text(
              _getSubtitle(project),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUDGET',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.displayBudget,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIMELINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          project.duration,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REQUIRED SKILLS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: displaySkills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (project.skills.length > 5) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${project.skills.length - 5} more',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => ProjectDetailScreen(project: project));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle(ProjectFeedModel project) {
    if (project.description.isEmpty) {
      return 'No description provided';
    }
    if (project.description.length <= 60) {
      return project.description;
    }
    return '${project.description.substring(0, 60)}...';
  }
}
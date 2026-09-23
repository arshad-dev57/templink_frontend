import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Controllers/call_controller.dart';
import 'package:templink/Controllers/chat_socket_controller.dart';
import 'package:templink/Controllers/video_call_controller.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects_Detail_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Stats_Screen.dart';
import 'package:templink/Employee/Screens/Employee_proposals_Screen.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart';
import 'package:templink/Employee/models/Employee_jobs_model.dart';
import 'package:templink/Employee/models/project_model.dart';
import 'package:templink/Employeer/Screens/Edit_Employeer_Profile.dart';
import 'package:templink/Employeer/Screens/Employeer_Projects_Discovery_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_Talent_Discovery_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_Job_Applications_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_Project_Milestone_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_my_jobs_screens.dart';
import 'package:templink/Employeer/Screens/Emplyeer_profile_screen.dart';
import 'package:templink/Employeer/Screens/employer_hub_dashboard_Screen.dart';
import 'package:templink/Employeer/Screens/employer_interested_screen.dart';
import 'package:templink/Employeer/Screens/employer_own_projects_screen.dart';
import 'package:templink/Employeer/Screens/project_detail_screen.dart';
import 'package:templink/Employeer/Screens/project_management_screen.dart';
import 'package:templink/Employeer/Screens/select_post_type_screen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Global_Screens/Chat_Users_List_Screen.dart';
import 'package:templink/Global_Screens/Notification_Screen.dart';
import 'package:templink/Global_Screens/Settings_Screen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Services/Notificaton_Service.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/config/api_config.dart';

// ==================== SAFE NAME HELPER ====================
String _safeFirstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'there';
  return trimmed.split(RegExp(r'\s+')).first;
}

// ==================== NAVIGATION CONTROLLER ====================
class EmployerNavigationController extends GetxController {
  final currentIndex = 0.obs;
  final selectedProjectTab = 0.obs;
  final sidebarExpanded = true.obs;
  final showTalentDiscovery = false.obs;
  final showProjectsDiscovery = false.obs;

  final selectedEmployerProject = Rxn<EmployerProject>();
  final selectedTalent = Rxn<TalentModel>();
  final selectedEmployeeProject = Rxn<EmployeeActiveProjectModel>();
  final selectedProjectFeed = Rxn<ProjectFeedModel>();

  void closeProjectsDiscovery() => showProjectsDiscovery.value = false;

  void goToDashboard() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 0;
  }

  void goToProjectsDiscovery() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = true;
    currentIndex.value = 16;
  }

  void goToMessages() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 1;
  }

  void goToProposalsReceived() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 2;
  }

  void goToMyStats() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 3;
  }

  void goToProjectDetailScreen(ProjectFeedModel project) {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    selectedProjectFeed.value = project;
    currentIndex.value = 17;
  }

  void goToProfile() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 5;
  }

  void goToHubDashboard() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 6;
  }

  void goToJobApplications() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 7;
  }

  void goToHiredCandidates() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 8;
  }

  void goToMyProjects() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 9;
  }

  void goToMyJobs() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 10;
  }

  void goToLiveProjects() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 11;
  }

  void goToSettings() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 4;
  }

  void goToEditProfile() {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    currentIndex.value = 15;
  }

  void goToTalentDiscovery() => showTalentDiscovery.value = true;
  void closeTalentDiscovery() => showTalentDiscovery.value = false;

  void goToProjectDetail(EmployerProject project) {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    selectedEmployerProject.value = project;
    currentIndex.value = 12;
  }

  void goToEmployeeProjectDetail(EmployeeActiveProjectModel project) {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    selectedEmployeeProject.value = project;
    currentIndex.value = 13;
  }

  void goToTalentProfile(TalentModel talent) {
    showTalentDiscovery.value = false;
    showProjectsDiscovery.value = false;
    selectedTalent.value = talent;
    currentIndex.value = 14;
  }

  void goBack() {
    if (showTalentDiscovery.value) {
      showTalentDiscovery.value = false;
    } else if (showProjectsDiscovery.value) {
      showProjectsDiscovery.value = false;
      currentIndex.value = 0;
    } else if (currentIndex.value == 12) {
      selectedEmployerProject.value = null;
      currentIndex.value = 9;
    } else if (currentIndex.value == 13) {
      selectedEmployeeProject.value = null;
      currentIndex.value = 11;
    } else if (currentIndex.value == 14 && selectedTalent.value != null) {
      selectedTalent.value = null;
      currentIndex.value = 0;
    } else if (currentIndex.value == 15) {
      currentIndex.value = 5;
    } else if (currentIndex.value == 16) {
      showProjectsDiscovery.value = false;
      currentIndex.value = 0;
    } else if (currentIndex.value == 17) {
      selectedProjectFeed.value = null;
      currentIndex.value = 0;
    } else {
      currentIndex.value = 0;
    }
  }

  String getPageTitle() {
    if (showTalentDiscovery.value) return 'Find Talent';
    if (showProjectsDiscovery.value) return 'Discover Projects';
    switch (currentIndex.value) {
      case 0: return 'Dashboard';
      case 1: return 'Messages';
      case 2: return 'Proposals Received';
      case 3: return 'My Stats';
      case 4: return 'Settings';
      case 5: return 'Profile';
      case 6: return 'Office Management';
      case 7: return 'Job Applications';
      case 8: return 'Hired Candidates';
      case 9: return 'My Projects';
      case 10: return 'My Jobs';
      case 11: return 'Live Projects';
      case 12: return 'Project Details';
      case 13: return 'Live Project Details';
      case 14: return 'Talent Profile';
      case 15: return 'Edit Profile';
      case 16: return 'Discover Projects';
      case 17: return 'Project Details';
      default: return 'Dashboard';
    }
  }

  Widget getCurrentScreen() {
    if (showTalentDiscovery.value) {
      return const TalentDiscoveryScreen(showSidebar: true);
    }
    if (showProjectsDiscovery.value) {
      return const ProjectsDiscoveryScreen(showSidebar: true);
    }
    switch (currentIndex.value) {
      case 0: return const HomeContentWeb();
      case 1: return const ChatUsersListScreen();
      case 2: return const EmployerOwnProjectsScreen();
      case 3: return const MyStatsScreen();
      case 4: return const SettingsScreen();
      case 5: return const EmployerProfileScreen(showSidebar: true);
      case 6: return const EmployerHubDashboardScreen();
      case 7: return EmployerJobApplicationsScreen();
      case 8: return const EmployerInterestedScreen();
      case 9:
        return EmployerProjectManagementScreen(
          showSidebar: true,
          onBackPressed: goBack,
          onProjectTap: (project) => goToProjectDetail(project),
        );
      case 10: return const EmployerJobsScreen();
      case 11:
        return EmployeeActiveProjectsScreen(
          showSidebar: true,
          onBackPressed: goBack,
          onProjectTap: (projectId, project) => goToEmployeeProjectDetail(project),
        );
      case 12:
        if (selectedEmployerProject.value != null) {
          return EmployerProjectDetailsScreen(
            project: selectedEmployerProject.value!,
            showSidebar: true,
            onBackPressed: goBack,
          );
        }
        return const HomeContentWeb();
      case 13:
        if (selectedEmployeeProject.value != null) {
          return EmployeeProjectDetailsScreen(
            project: selectedEmployeeProject.value!,
            showSidebar: true,
            onBackPressed: goBack,
          );
        }
        return const HomeContentWeb();
      case 14:
        if (selectedTalent.value != null) {
          return TalentProfileScreen(
            talent: selectedTalent.value!,
            showSidebar: true,
            onBackPressed: goBack,
          );
        }
        return const HomeContentWeb();
      case 15: return const EditEmployerProfileScreen(showSidebar: true);
      case 16: return const ProjectsDiscoveryScreen(showSidebar: true);
      case 17:
        if (selectedProjectFeed.value != null) {
          return ProjectDetailScreen(
            project: selectedProjectFeed.value!,
            showSidebar: true,
            onBackPressed: goBack,
          );
        }
        return const HomeContentWeb();
      default: return const HomeContentWeb();
    }
  }
}

// ==================== EMPLOYER HOME SCREEN ====================
class EmployeerHomeScreen extends StatelessWidget {
  const EmployeerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (!Get.isRegistered<EmployerNavigationController>()) {
      Get.put(EmployerNavigationController(), permanent: true);
    }
    if (!Get.isRegistered<EmployeeHomeController>()) {
      Get.put(EmployeeHomeController(), permanent: true);
    }

    return isWeb ? const EmployerHomeScreenWeb() : const EmployerHomeScreenMobile();
  }
}

// ==================== WEB LAYOUT ====================
class EmployerHomeScreenWeb extends StatelessWidget {
  const EmployerHomeScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<EmployerNavigationController>();
    final homeController = Get.find<EmployeeHomeController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      if (screenWidth < 900 && navController.sidebarExpanded.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navController.sidebarExpanded.value = false;
        });
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: navController.sidebarExpanded.value ? 240.0 : 64.0,
              child: _WebSidebar(
                expanded: navController.sidebarExpanded.value,
                onToggle: () => navController.sidebarExpanded.toggle(),
                navController: navController,
                homeController: homeController,
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF4F6F9),
                child: Column(
                  children: [
                    _WebTopBar(navController: navController, homeController: homeController),
                    Expanded(child: navController.getCurrentScreen()),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ==================== WEB SIDEBAR ====================
class _WebSidebar extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final EmployerNavigationController navController;
  final EmployeeHomeController homeController;

  const _WebSidebar({
    required this.expanded,
    required this.onToggle,
    required this.navController,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
          _LogoSection(expanded: expanded, onToggle: onToggle),
          if (expanded) _ProfileCard(homeController: homeController),
          if (!expanded) const SizedBox(height: 8),
          Expanded(child: _NavItems(expanded: expanded, navController: navController)),
          _BottomSection(expanded: expanded, navController: navController),
        ],
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _LogoSection({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1))),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(7)),
            child: const Icon(Icons.work_outline, color: Colors.white, size: 16),
          ),
          if (expanded) ...[
            const SizedBox(width: 8),
            const Text('Templink', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Spacer(),
            GestureDetector(onTap: onToggle, child: Icon(Icons.menu, size: 18, color: Colors.grey.shade500)),
          ] else ...[
            const Spacer(),
            GestureDetector(onTap: onToggle, child: Icon(Icons.menu, size: 18, color: Colors.grey.shade500)),
          ],
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final EmployeeHomeController homeController;

  const _ProfileCard({required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.network(
                homeController.imageUrl.value.isNotEmpty
                    ? homeController.imageUrl.value
                    : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                width: 32, height: 32, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 32, height: 32, color: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(homeController.fullName.value,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Free Account', style: TextStyle(fontSize: 9, color: Colors.black54)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItems extends StatelessWidget {
  final bool expanded;
  final EmployerNavigationController navController;

  const _NavItems({required this.expanded, required this.navController});

  final List<Map<String, dynamic>> mainNavItems = const [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Dashboard', 'index': 0},
    {'icon': Icons.message_outlined, 'activeIcon': Icons.message, 'label': 'Messages', 'index': 1},
    {'icon': Icons.folder_outlined, 'activeIcon': Icons.folder, 'label': 'Proposals Received', 'index': 2},
    {'icon': Icons.bar_chart_outlined, 'activeIcon': Icons.bar_chart, 'label': 'My Stats', 'index': 3},
  ];

  final List<Map<String, dynamic>> extraNavItems = const [
    {'icon': Icons.person_outline, 'label': 'Profile', 'index': 5},
    {'icon': Icons.build_outlined, 'label': 'Office Management', 'index': 6},
    {'icon': Icons.assignment_outlined, 'label': 'Job Applications', 'index': 7},
    {'icon': Icons.people_outline, 'label': 'Hired Candidates', 'index': 8},
    {'icon': Icons.folder_special_outlined, 'label': 'My Projects', 'index': 9},
    {'icon': Icons.work_outline, 'label': 'My Jobs', 'index': 10},
    {'icon': Icons.live_tv_outlined, 'label': 'Live Projects', 'index': 11},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        ...mainNavItems.map((item) => _NavItemTile(item: item, expanded: expanded, navController: navController)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8, vertical: 6),
          child: Divider(height: 1, color: Colors.grey.shade100),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8, vertical: 6),
          child: Divider(height: 1, color: Colors.grey.shade100),
        ),
        ...extraNavItems.map((item) => _ExtraNavItemTile(item: item, expanded: expanded, navController: navController)),
      ],
    );
  }
}

class _NavItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool expanded;
  final EmployerNavigationController navController;

  const _NavItemTile({required this.item, required this.expanded, required this.navController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = !navController.showTalentDiscovery.value &&
          !navController.showProjectsDiscovery.value &&
          navController.currentIndex.value == item['index'];
      return GestureDetector(
        onTap: () {
          navController.showTalentDiscovery.value = false;
          navController.showProjectsDiscovery.value = false;
          navController.currentIndex.value = item['index'];
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: EdgeInsets.symmetric(horizontal: expanded ? 10 : 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(selected ? item['activeIcon'] : item['icon'],
                color: selected ? primary : Colors.grey.shade500, size: 18),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item['label'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? primary : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
                if (selected)
                  Container(width: 4, height: 4,
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _ExtraNavItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool expanded;
  final EmployerNavigationController navController;

  const _ExtraNavItemTile({required this.item, required this.expanded, required this.navController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = !navController.showTalentDiscovery.value &&
          !navController.showProjectsDiscovery.value &&
          navController.currentIndex.value == item['index'];
      return GestureDetector(
        onTap: () {
          switch (item['index']) {
            case 5: navController.goToProfile(); break;
            case 6: navController.goToHubDashboard(); break;
            case 7: navController.goToJobApplications(); break;
            case 8: navController.goToHiredCandidates(); break;
            case 9: navController.goToMyProjects(); break;
            case 10: navController.goToMyJobs(); break;
            case 11: navController.goToLiveProjects(); break;
            default:
              navController.showTalentDiscovery.value = false;
              navController.showProjectsDiscovery.value = false;
              navController.currentIndex.value = item['index'];
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: EdgeInsets.symmetric(horizontal: expanded ? 10 : 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(item['icon'], color: isSelected ? primary : Colors.grey.shade500, size: 18),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item['label'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? primary : Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
                if (isSelected)
                  Container(width: 4, height: 4,
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle)),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _BottomSection extends StatelessWidget {
  final bool expanded;
  final EmployerNavigationController navController;

  const _BottomSection({required this.expanded, required this.navController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => SelectPostTypeScreen()),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Post a Job', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: IconButton(
                icon: Icon(Icons.add_circle, color: primary, size: 24),
                onPressed: () => Get.to(() => SelectPostTypeScreen()),
                tooltip: 'Post a Job',
              ),
            ),
          _LogoutTile(expanded: expanded),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final bool expanded;

  const _LogoutTile({required this.expanded});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        padding: EdgeInsets.symmetric(horizontal: expanded ? 10 : 14, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.logout_outlined, color: Colors.red, size: 18),
            if (expanded) ...[
              const SizedBox(width: 10),
              const Text('Log Out',
                style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      if (!kIsWeb) await NotificationService.instance.logout();
      if (Get.isRegistered<ChatSocketController>()) {
        Get.find<ChatSocketController>().disconnect();
        Get.delete<ChatSocketController>(force: true);
      }
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().resetForLogout();
        Get.delete<CallController>(force: true);
      }
      if (Get.isRegistered<VideoCallController>()) {
        Get.find<VideoCallController>().resetForLogout();
        Get.delete<VideoCallController>(force: true);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_user');
      await prefs.remove('auth_role');
      await prefs.remove('auth_user_id');
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Logout failed: ${e.toString()}',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

class _WebTopBar extends StatelessWidget {
  final EmployerNavigationController navController;
  final EmployeeHomeController homeController;

  const _WebTopBar({required this.navController, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 1))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (navController.showTalentDiscovery.value ||
                navController.showProjectsDiscovery.value ||
                navController.currentIndex.value != 0)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                onPressed: () => navController.goBack(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(navController.getPageTitle(),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
            const Spacer(),
            SizedBox(
              width: 40, height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 22),
                    onPressed: () => Get.to(() => const NotificationScreen()),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  const Positioned(right: 8, top: 8,
                    child: CircleAvatar(radius: 3.5, backgroundColor: Colors.red)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40, height: 40,
              child: GestureDetector(
                onTap: () => navController.goToProfile(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    homeController.imageUrl.value.isNotEmpty
                        ? homeController.imageUrl.value
                        : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    width: 34, height: 34, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 34, height: 34, color: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MOBILE LAYOUT (FIXED — NO WHITE SPACE) ====================
class EmployerHomeScreenMobile extends StatelessWidget {
  const EmployerHomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<EmployerNavigationController>();
    final homeController = Get.find<EmployeeHomeController>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87, size: 22),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Obx(() => Text(navController.getPageTitle(),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          overflow: TextOverflow.ellipsis, maxLines: 1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 22),
            onPressed: () => Get.to(() => const NotificationScreen()),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => navController.goToProfile(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                homeController.imageUrl.value.isNotEmpty
                    ? homeController.imageUrl.value
                    : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                width: 36, height: 36, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 36, height: 36, color: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: _MobileDrawer(navController: navController, homeController: homeController),
      // ✅ Bottom nav is a floating pill on the body — no separate bg strip
      bottomNavigationBar: _CustomBottomNavBar(navController: navController),
      // ✅ NO extra bottom padding → no white gap
      body: Obx(() => navController.getCurrentScreen()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        mini: true,
        elevation: 3,
        child: const Icon(Icons.add, color: Colors.white, size: 22),
        onPressed: () => Get.to(() => SelectPostTypeScreen()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ==================== CUSTOM BOTTOM NAV (FLOATING PILL) ====================
class _CustomBottomNavBar extends StatelessWidget {
  final EmployerNavigationController navController;

  const _CustomBottomNavBar({required this.navController});

  @override
  Widget build(BuildContext context) {
    // ✅ Transparent root — so only the pill is visible, no white strip
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavIconMobile(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    index: 0,
                    navController: navController,
                    label: 'Home'),
                _NavIconMobile(
                    icon: Icons.message_outlined,
                    activeIcon: Icons.message,
                    index: 1,
                    navController: navController,
                    label: 'Chats'),
                _NavIconMobile(
                    icon: Icons.folder_outlined,
                    activeIcon: Icons.folder,
                    index: 2,
                    navController: navController,
                    label: 'Proposals'),
                _NavIconMobile(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart,
                    index: 3,
                    navController: navController,
                    label: 'Stats'),
                _NavIconMobile(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    index: 4,
                    navController: navController,
                    label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconMobile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final EmployerNavigationController navController;
  final String label;

  const _NavIconMobile({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.navController,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = navController.currentIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => navController.currentIndex.value = index,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? activeIcon : icon,
                color: selected ? primary : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? primary : Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ==================== MOBILE DRAWER ====================
class _MobileDrawer extends StatelessWidget {
  final EmployerNavigationController navController;
  final EmployeeHomeController homeController;

  const _MobileDrawer({required this.navController, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      homeController.imageUrl.value.isNotEmpty
                          ? homeController.imageUrl.value
                          : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                      width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 60, height: 60, color: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.white, size: 34),
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                  Obx(() => Text(homeController.fullName.value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Free Account',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(Icons.dashboard_outlined, 'Dashboard', () { navController.goToDashboard(); Navigator.pop(context); }),
                  _drawerItem(Icons.manage_search, 'Find Talent', () { navController.goToTalentDiscovery(); Navigator.pop(context); }),
                  _drawerItem(Icons.explore_outlined, 'Discover Projects', () { navController.goToProjectsDiscovery(); Navigator.pop(context); }),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _drawerItem(Icons.message_outlined, 'Messages', () { navController.goToMessages(); Navigator.pop(context); }),
                  _drawerItem(Icons.folder_outlined, 'Proposals Received', () { navController.goToProposalsReceived(); Navigator.pop(context); }),
                  _drawerItem(Icons.folder_special_outlined, 'My Projects', () { navController.goToMyProjects(); Navigator.pop(context); }),
                  _drawerItem(Icons.work_outline, 'My Jobs', () { navController.goToMyJobs(); Navigator.pop(context); }),
                  _drawerItem(Icons.live_tv_outlined, 'Live Projects', () { navController.goToLiveProjects(); Navigator.pop(context); }),
                  _drawerItem(Icons.people_outline, 'Hired Candidates', () { navController.goToHiredCandidates(); Navigator.pop(context); }),
                  _drawerItem(Icons.assignment_outlined, 'Job Applications', () { navController.goToJobApplications(); Navigator.pop(context); }),
                  _drawerItem(Icons.bar_chart_outlined, 'My Stats', () { navController.goToMyStats(); Navigator.pop(context); }),
                  _drawerItem(Icons.person_outline, 'Profile', () { navController.goToProfile(); Navigator.pop(context); }),
                  _drawerItem(Icons.build_outlined, 'Office Management', () { navController.goToHubDashboard(); Navigator.pop(context); }),
                  _drawerItem(Icons.settings_outlined, 'Settings', () { navController.goToSettings(); Navigator.pop(context); }),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _drawerItem(Icons.logout_outlined, 'Log Out', _handleLogout, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('© 2024 Templink · v2.1.0',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(icon, color: color ?? Colors.grey.shade600, size: 20),
      title: Text(title, style: TextStyle(fontSize: 13, color: color ?? Colors.black87)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout() async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      if (!kIsWeb) await NotificationService.instance.logout();
      if (Get.isRegistered<ChatSocketController>()) {
        Get.find<ChatSocketController>().disconnect();
        Get.delete<ChatSocketController>(force: true);
      }
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().resetForLogout();
        Get.delete<CallController>(force: true);
      }
      if (Get.isRegistered<VideoCallController>()) {
        Get.find<VideoCallController>().resetForLogout();
        Get.delete<VideoCallController>(force: true);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_user');
      await prefs.remove('auth_role');
      await prefs.remove('auth_user_id');
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Logout failed: ${e.toString()}',
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

// ==================== HOME CONTENT ====================
class HomeContentWeb extends StatelessWidget {
  const HomeContentWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<EmployeeHomeController>();
    final navController = Get.find<EmployerNavigationController>();

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        homeController.refreshProjects(),
        homeController.fetchTalentsPaginated(page: 1, resetList: true),
      ]),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
          final isDesktop = constraints.maxWidth >= 1000;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _WebWelcomeBanner(
                  homeController: homeController,
                  navController: navController,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 18),
                _ProjectsTabBar(navController: navController),
                const SizedBox(height: 14),
                Obx(() => navController.selectedProjectTab.value == 0
                    ? const _TalentFilterSection()
                    : const _ProjectFilterSection()),
                const SizedBox(height: 14),
                Obx(() => navController.selectedProjectTab.value == 0
                    ? _TalentsGridSection(
                        isMobile: isMobile,
                        isTablet: isTablet,
                        isWeb: isDesktop,
                      )
                    : _ProjectsGridSection(
                        isMobile: isMobile,
                        isTablet: isTablet,
                        isWeb: isDesktop,
                        navController: navController,
                      )),
                // ✅ Bottom spacer for FAB clearance
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== WELCOME BANNER ====================
class _WebWelcomeBanner extends StatelessWidget {
  final EmployeeHomeController homeController;
  final EmployerNavigationController navController;
  final bool isMobile;

  const _WebWelcomeBanner({
    required this.homeController,
    required this.navController,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(isMobile ? 14 : 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.78)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: isMobile ? _mobileBanner() : _desktopBanner(),
      ),
    );
  }

  Widget _mobileBanner() {
    final firstName = _safeFirstName(homeController.fullName.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $firstName! 👋',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Find talent & manage your projects.',
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.82)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final veryNarrow = constraints.maxWidth < 300;
            if (veryNarrow) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _bannerButton(
                      label: 'Post a Job',
                      icon: Icons.add,
                      filled: true,
                      onTap: () => Get.to(() => SelectPostTypeScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _bannerButton(
                      label: 'Find Talent',
                      icon: Icons.search,
                      filled: false,
                      onTap: () => navController.goToTalentDiscovery(),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _bannerButton(
                    label: 'Post a Job',
                    icon: Icons.add,
                    filled: true,
                    onTap: () => Get.to(() => SelectPostTypeScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _bannerButton(
                    label: 'Find Talent',
                    icon: Icons.search,
                    filled: false,
                    onTap: () => navController.goToTalentDiscovery(),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _desktopBanner() {
    final firstName = _safeFirstName(homeController.fullName.value);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back, $firstName! 👋',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Find top talent and manage your projects efficiently.',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.84)),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Row(
                children: [
                  _bannerButton(label: 'Post a Job', icon: Icons.add, filled: true,
                    onTap: () => Get.to(() => SelectPostTypeScreen())),
                  const SizedBox(width: 10),
                  _bannerButton(label: 'Find Talent', icon: Icons.search, filled: false,
                    onTap: () => navController.goToTalentDiscovery()),
                ],
              ),
            ],
          ),
        ),
        Icon(Icons.dashboard_outlined, size: 64, color: Colors.white.withOpacity(0.15)),
      ],
    );
  }

  Widget _bannerButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: filled ? primary : Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: filled ? primary : Colors.white,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TAB BAR ====================
class _ProjectsTabBar extends StatelessWidget {
  final EmployerNavigationController navController;

  const _ProjectsTabBar({required this.navController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tabButton('Top Talent', 0),
          _tabButton('Temp Projects', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    return Expanded(
      child: Obx(() {
        final selected = navController.selectedProjectTab.value == index;
        return GestureDetector(
          onTap: () => navController.selectedProjectTab.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ==================== FILTER SECTIONS ====================
class _TalentFilterSection extends StatelessWidget {
  const _TalentFilterSection();

  @override
  Widget build(BuildContext context) {
    final timeFilters = ['All Time', 'Today', 'Yesterday', 'This Week', 'This Month', 'Last Month'];
    final selectedTimeFilter = 'All Time'.obs;

    return Row(
      children: [
        Flexible(
          child: _FilterDropdown(filters: timeFilters, selected: selectedTimeFilter),
        ),
      ],
    );
  }
}

class _ProjectFilterSection extends StatelessWidget {
  const _ProjectFilterSection();

  @override
  Widget build(BuildContext context) {
    final timeFilters = ['All Time', 'Today', 'Yesterday', 'This Week', 'This Month', 'Last Month'];
    final selectedTimeFilter = 'All Time'.obs;
    final selectedFilter = 'All'.obs;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Row(
      children: [
        Flexible(
          child: _FilterDropdown(filters: timeFilters, selected: selectedTimeFilter),
        ),
        const SizedBox(width: 8),
        if (isSmallScreen)
          Flexible(
            child: _FilterDropdown(filters: ['All', 'Featured'], selected: selectedFilter),
          )
        else
          Flexible(
            child: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: ['All', 'Featured'].map((f) {
                final isSelected = selectedFilter.value == f;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: GestureDetector(
                    onTap: () => selectedFilter.value = f,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? primary.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primary.withOpacity(0.3) : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? primary : Colors.black54,
                        )),
                    ),
                  ),
                );
              }).toList(),
            )),
          ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final List<String> filters;
  final RxString selected;

  const _FilterDropdown({required this.filters, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected.value,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 16),
            style: const TextStyle(color: Colors.black87, fontSize: 12),
            isExpanded: true,
            onChanged: (val) => selected.value = val!,
            items: filters.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          ),
        ),
      ),
    );
  }
}

// ==================== TALENTS GRID ====================
class _TalentsGridSection extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isWeb;

  const _TalentsGridSection({
    this.isMobile = false,
    this.isTablet = false,
    this.isWeb = false,
  });

  @override
  State<_TalentsGridSection> createState() => _TalentsGridSectionState();
}

class _TalentsGridSectionState extends State<_TalentsGridSection> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final homeController = Get.find<EmployeeHomeController>();
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!homeController.isLoadingMoreTalents.value && homeController.hasMoreTalentsPages) {
        homeController.fetchTalentsPaginated(
          page: homeController.talentsCurrentPage.value + 1,
          resetList: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<EmployeeHomeController>();
    final navController = Get.find<EmployerNavigationController>();

    return Obx(() {
      if (homeController.isLoadingTalents.value && homeController.talents.isEmpty) {
        return const Center(
          child: Padding(padding: EdgeInsets.symmetric(vertical: 30), child: CircularProgressIndicator()),
        );
      }

      final talents = homeController.talents;
      if (talents.isEmpty && !homeController.isLoadingTalents.value) {
        return const _EmptyState(icon: Icons.people_outline, text: 'No talents found');
      }

      final double aspectRatio;
      if (widget.isMobile) {
        aspectRatio = 2.3;
      } else if (widget.isTablet) {
        aspectRatio = 1.9;
      } else {
        aspectRatio = 1.8;
      }

      final crossAxisCount = widget.isMobile ? 1 : (widget.isTablet ? 2 : 3);

      return Column(
        children: [
          _SectionHeader(
            title: '${homeController.talentsTotalCount.value} Talents Found',
            onSeeAll: () => navController.goToTalentDiscovery(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            controller: widget.isWeb ? null : _scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: talents.length + (homeController.hasMoreTalentsPages && !widget.isWeb ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == talents.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _TalentCard(talent: talents[index], navController: navController);
            },
          ),
          if (widget.isWeb && homeController.talentsTotalPages.value > 1)
            _PaginationControls(
              currentPage: homeController.talentsCurrentPage.value,
              totalPages: homeController.talentsTotalPages.value,
              onPageChanged: (page) => homeController.goToTalentsPage(page),
              onNext: () => homeController.nextTalentsPage(),
              onPrev: () => homeController.prevTalentsPage(),
            ),
        ],
      );
    });
  }
}

// ==================== PROJECTS GRID ====================
class _ProjectsGridSection extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;
  final bool isWeb;
  final EmployerNavigationController navController;

  const _ProjectsGridSection({
    this.isMobile = false,
    this.isTablet = false,
    this.isWeb = false,
    required this.navController,
  });

  @override
  State<_ProjectsGridSection> createState() => _ProjectsGridSectionState();
}

class _ProjectsGridSectionState extends State<_ProjectsGridSection> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final homeController = Get.find<EmployeeHomeController>();
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!homeController.isLoadingMoreProjects.value && homeController.hasMoreProjectsPages) {
        homeController.fetchProjects(
          page: homeController.projectsCurrentPage.value + 1,
          resetList: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<EmployeeHomeController>();

    return Obx(() {
      if (homeController.isLoadingProjects.value && homeController.projects.isEmpty) {
        return const Center(
          child: Padding(padding: EdgeInsets.symmetric(vertical: 30), child: CircularProgressIndicator()),
        );
      }

      final projects = homeController.projects;
      if (projects.isEmpty && !homeController.isLoadingProjects.value) {
        return const _EmptyState(icon: Icons.folder_open, text: 'No projects found');
      }

      final double aspectRatio;
      if (widget.isMobile) {
        aspectRatio = 1.05;
      } else if (widget.isTablet) {
        aspectRatio = 1.15;
      } else {
        aspectRatio = 1.2;
      }

      final crossAxisCount = widget.isMobile ? 1 : (widget.isTablet ? 2 : 3);

      return Column(
        children: [
          _SectionHeader(
            title: '${homeController.projectsTotalCount.value} Projects Found',
            onSeeAll: () => widget.navController.goToProjectsDiscovery(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            controller: widget.isWeb ? null : _scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
            ),
            itemCount: projects.length + (homeController.hasMoreProjectsPages && !widget.isWeb ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == projects.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _ProjectCard(project: projects[index]);
            },
          ),
          if (widget.isWeb && homeController.projectsTotalPages.value > 1)
            _PaginationControls(
              currentPage: homeController.projectsCurrentPage.value,
              totalPages: homeController.projectsTotalPages.value,
              onPageChanged: (page) => homeController.goToProjectsPage(page),
              onNext: () => homeController.nextProjectsPage(),
              onPrev: () => homeController.prevProjectsPage(),
            ),
        ],
      );
    });
  }
}

// ==================== PAGINATION CONTROLS ====================
class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 8,
        children: [
          GestureDetector(
            onTap: currentPage > 1 ? onPrev : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: currentPage > 1 ? primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_left, size: 18, color: currentPage > 1 ? Colors.white : Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('Previous',
                    style: TextStyle(
                      fontSize: 13,
                      color: currentPage > 1 ? Colors.white : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ..._getPageNumbers().map((page) {
            if (page == -1) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('...', style: TextStyle(color: Colors.grey.shade500)),
              );
            }
            final isActive = page == currentPage;
            return GestureDetector(
              onTap: () => onPageChanged(page),
              child: Container(
                width: 36, height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isActive ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? primary : Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(page.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.white : Colors.black87,
                    )),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: currentPage < totalPages ? onNext : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: currentPage < totalPages ? primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next',
                    style: TextStyle(
                      fontSize: 13,
                      color: currentPage < totalPages ? Colors.white : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    )),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: currentPage < totalPages ? Colors.white : Colors.grey.shade500),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getPageNumbers() {
    List<int> pages = [];
    if (totalPages <= 7) {
      for (int i = 1; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      if (currentPage <= 4) {
        pages = [1, 2, 3, 4, 5, -1, totalPages];
      } else if (currentPage >= totalPages - 3) {
        pages = [1, -1, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
      } else {
        pages = [1, -1, currentPage - 1, currentPage, currentPage + 1, -1, totalPages];
      }
    }
    return pages;
  }
}

// ==================== TALENT CARD ====================
class _TalentCard extends StatelessWidget {
  final TalentModel talent;
  final EmployerNavigationController navController;

  const _TalentCard({required this.talent, required this.navController});

  @override
  Widget build(BuildContext context) {
    final displaySkills = talent.skills.length > 3 ? talent.skills.sublist(0, 3) : talent.skills;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: talent.bgColor,
            backgroundImage: talent.photoUrl.isNotEmpty ? NetworkImage(talent.photoUrl) : null,
            child: talent.photoUrl.isEmpty
                ? Text(
                    talent.fullName.isNotEmpty ? talent.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(talent.fullName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(talent.ratingDisplay, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(talent.title,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      talent.hourlyRateDisplay.isEmpty ? 'Rate TBD' : talent.hourlyRateDisplay,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: displaySkills.map((skill) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(skill, style: const TextStyle(fontSize: 9, color: Colors.black54)),
                        )).toList(),
                      ),
                    ),
                    if (talent.skills.length > 3) ...[
                      const SizedBox(width: 4),
                      Text('+${talent.skills.length - 3}', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => navController.goToTalentProfile(talent),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(7)),
              child: const Text('View',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PROJECT CARD (CLEAN MOBILE DESIGN) ====================
class _ProjectCard extends StatelessWidget {
  final ProjectFeedModel project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final displaySkills = project.skills.length > 3
        ? project.skills.sublist(0, 3)
        : project.skills;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top row: badges + bookmark ──
          Row(
            children: [
              if (project.featured) ...[
                _Badge(label: 'FEATURED', color: const Color(0xFF00BCD4)),
                const SizedBox(width: 6),
              ],
              if (project.isVerified)
                Icon(Icons.verified, color: Colors.blue.shade600, size: 15),
              const Spacer(),
              Icon(Icons.bookmark_border,
                  color: Colors.grey.shade300, size: 18),
            ],
          ),
          const SizedBox(height: 10),

          // ── Title ──
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // ── Description ──
          Text(
            project.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // ── Budget + Timeline info row ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                // Budget
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('BUDGET',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 3),
                      Text(
                        project.displayBudget,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(width: 10),
                // Timeline
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('DURATION',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              project.duration,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),

          // ── Skills chips ──
          if (displaySkills.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...displaySkills.map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: primary.withOpacity(0.15)),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: primary,
                        ),
                      ),
                    )),
                if (project.skills.length > 3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${project.skills.length - 3}',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),

          // ── View Details button ──
          GestureDetector(
            onTap: () {
              final isWeb = Responsive.isDesktop(Get.context!) ||
                  Responsive.isTablet(Get.context!);
              if (isWeb) {
                final navController = Get.find<EmployerNavigationController>();
                navController.goToProjectDetailScreen(project);
              } else {
                Get.to(() => ProjectDetailScreen(project: project));
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'View Details',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SECTION HEADER ====================
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('See All',
                style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_ios, size: 10, color: primary),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== BADGE ====================
class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(label,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
    );
  }
}

// ==================== EMPTY STATE ====================
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 44, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
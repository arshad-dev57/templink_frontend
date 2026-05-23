// lib/Employeer/Screens/Employeer_homescreen.dart
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

// ==================== NAVIGATION CONTROLLER (WEB ONLY) ====================
class EmployerNavigationController extends GetxController {
  final currentIndex = 0.obs;
  final selectedProjectTab = 0.obs;
  final sidebarExpanded = true.obs;
  final showTalentDiscovery = false.obs;

  final selectedEmployerProject = Rxn<EmployerProject>();
  final selectedTalent = Rxn<TalentModel>();
  final selectedEmployeeProject = Rxn<EmployeeActiveProjectModel>();
final showProjectsDiscovery = false.obs;


void closeProjectsDiscovery() {
  showProjectsDiscovery.value = false;
}
  void goToDashboard() {
    showTalentDiscovery.value = false;
    currentIndex.value = 0;
  }
void goToProjectsDiscovery() {
  showTalentDiscovery.value = false;
  showProjectsDiscovery.value = true;
  currentIndex.value = 16; // Naya index
}
  void goToMessages() {
    showTalentDiscovery.value = false;
    currentIndex.value = 1;
  }

  void goToProposalsReceived() {
    showTalentDiscovery.value = false;
    currentIndex.value = 2;
  }

  void goToMyStats() {
    showTalentDiscovery.value = false;
    currentIndex.value = 3;
  }

  void goToProfile() {
    showTalentDiscovery.value = false;
    currentIndex.value = 5;
  }

  void goToHubDashboard() {
    showTalentDiscovery.value = false;
    currentIndex.value = 6;
  }

  void goToJobApplications() {
    showTalentDiscovery.value = false;
    currentIndex.value = 7;
  }

  void goToHiredCandidates() {
    showTalentDiscovery.value = false;
    currentIndex.value = 8;
  }

  void goToMyProjects() {
    showTalentDiscovery.value = false;
    currentIndex.value = 9;
  }

  void goToMyJobs() {
    showTalentDiscovery.value = false;
    currentIndex.value = 10;
  }

  void goToLiveProjects() {
    showTalentDiscovery.value = false;
    currentIndex.value = 11;
  }

  void goToSettings() {
    showTalentDiscovery.value = false;
    currentIndex.value = 4;
  }

  void goToEditProfile() {
    showTalentDiscovery.value = false;
    currentIndex.value = 15;
  }

  void goToTalentDiscovery() => showTalentDiscovery.value = true;
  void closeTalentDiscovery() => showTalentDiscovery.value = false;

  void goToProjectDetail(EmployerProject project) {
    showTalentDiscovery.value = false;
    selectedEmployerProject.value = project;
    currentIndex.value = 12;
  }

  void goToEmployeeProjectDetail(EmployeeActiveProjectModel project) {
    showTalentDiscovery.value = false;
    selectedEmployeeProject.value = project;
    currentIndex.value = 13;
  }

  void goToTalentProfile(TalentModel talent) {
    showTalentDiscovery.value = false;
    selectedTalent.value = talent;
    currentIndex.value = 14;
  }

  void goBack() {
    if (showTalentDiscovery.value) {
      showTalentDiscovery.value = false;
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
    }
    else if (currentIndex.value == 16) {
  showProjectsDiscovery.value = false;
  currentIndex.value = 0;
}
     else {
      currentIndex.value = 0;
    }
  }

  String getPageTitle() {
    if (showTalentDiscovery.value) return 'Find Talent';
    switch (currentIndex.value) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Messages';
      case 2:
        return 'Proposals Received';
      case 3:
        return 'My Stats';
      case 4:
        return 'Settings';
      case 5:
        return 'Profile';
      case 6:
        return 'Hub Dashboard';
      case 7:
        return 'Job Applications';
      case 8:
        return 'Hired Candidates';
      case 9:
        return 'My Projects';
      case 10:
        return 'My Jobs';
      case 11:
        return 'Live Projects';
      case 12:
        return 'Project Details';
      case 13:
        return 'Live Project Details';
      case 14:
        return 'Talent Profile';
      case 15:
        return 'Edit Profile';
        case 16:
  return 'Discover Projects';
      default:
        return 'Dashboard';
    }
  }

  Widget getCurrentScreen() {
    if (showTalentDiscovery.value) {
      return const TalentDiscoveryScreen(showSidebar: true);
    }
    switch (currentIndex.value) {
      case 0:
        return const HomeContentWeb();
      case 1:
        return const ChatUsersListScreen();
      case 2:
        return const EmployerOwnProjectsScreen();
      case 3:
        return const MyStatsScreen();
      case 4:
        return const SettingsScreen();
      case 5:
        return const EmployerProfileScreen(showSidebar: true);
      case 6:
        return const EmployerHubDashboardScreen();
      case 7:
        return EmployerJobApplicationsScreen();
      case 8:
        return const EmployerInterestedScreen();
      case 9:
        return EmployerProjectManagementScreen(
          showSidebar: true,
          onBackPressed: goBack,
          onProjectTap: (project) => goToProjectDetail(project),
        );
      case 10:
        return const EmployerJobsScreen();
      case 11:
        return EmployeeActiveProjectsScreen(
          showSidebar: true,
          onBackPressed: goBack,
          onProjectTap: (projectId, project) =>
              goToEmployeeProjectDetail(project),
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
      case 15:
        return const EditEmployerProfileScreen(showSidebar: true);
        case 16:
  return const ProjectsDiscoveryScreen(showSidebar: true);
      default:
        return const HomeContentWeb();
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

    if (isWeb) {
      return const EmployerHomeScreenWeb();
    } else {
      return const EmployerHomeScreenMobile();
    }
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
              child: Column(
                children: [
                  _WebTopBar(
                    navController: navController,
                    homeController: homeController,
                  ),
                  Expanded(
                    child: navController.getCurrentScreen(),
                  ),
                ],
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
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(2, 0),
          ),
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.work_outline, color: Colors.white, size: 16),
          ),
          if (expanded) ...[
            const SizedBox(width: 8),
            const Text(
              'Templink',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onToggle,
              child: Icon(Icons.menu, size: 18, color: Colors.grey.shade500),
            ),
          ] else ...[
            const Spacer(),
            GestureDetector(
              onTap: onToggle,
              child: Icon(Icons.menu, size: 18, color: Colors.grey.shade500),
            ),
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
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 32,
                  height: 32,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homeController.fullName.value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Free Account',
                      style: TextStyle(fontSize: 9, color: Colors.black54),
                    ),
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
    {'icon': Icons.settings_outlined, 'activeIcon': Icons.settings, 'label': 'Settings', 'index': 4},
  ];

  final List<Map<String, dynamic>> extraNavItems = const [
    {'icon': Icons.person_outline, 'label': 'Profile', 'index': 5},
    {'icon': Icons.build_outlined, 'label': 'Hub Dashboard', 'index': 6},
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
        ...mainNavItems.map(
          (item) => _NavItemTile(item: item, expanded: expanded, navController: navController),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8, vertical: 6),
          child: Divider(height: 1, color: Colors.grey.shade100),
        ),
        _FindTalentTile(expanded: expanded, navController: navController),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8, vertical: 6),
          child: Divider(height: 1, color: Colors.grey.shade100),
        ),
        ...extraNavItems.map(
          (item) => _ExtraNavItemTile(item: item, expanded: expanded, navController: navController),
        ),
      ],
    );
  }
}

class _FindTalentTile extends StatelessWidget {
  final bool expanded;
  final EmployerNavigationController navController;

  const _FindTalentTile({required this.expanded, required this.navController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = navController.showTalentDiscovery.value;
      return GestureDetector(
        onTap: () => navController.goToTalentDiscovery(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 10 : 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.manage_search, color: isSelected ? primary : Colors.grey.shade500, size: 18),
              if (expanded) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Talent',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primary : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'Browse professionals',
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    });
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
          navController.currentIndex.value == item['index'];
      return GestureDetector(
        onTap: () {
          navController.showTalentDiscovery.value = false;
          navController.currentIndex.value = item['index'];
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 10 : 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                selected ? item['activeIcon'] : item['icon'],
                color: selected ? primary : Colors.grey.shade500,
                size: 18,
              ),
              if (expanded) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? primary : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                  ),
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
              navController.currentIndex.value = item['index'];
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 10 : 14,
            vertical: 8,
          ),
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
                  child: Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? primary : Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                  ),
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
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
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
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
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
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 10 : 14,
          vertical: 8,
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_outlined, color: Colors.red, size: 18),
            if (expanded) ...[
              const SizedBox(width: 10),
              const Text(
                'Log Out',
                style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w500),
              ),
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
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}

// ==================== WEB TOP BAR ====================
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            if (navController.showTalentDiscovery.value ||
                navController.currentIndex.value != 0)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                onPressed: () => navController.goBack(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            Flexible(
              child: Text(
                navController.getPageTitle(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 22),
                  onPressed: () => Get.to(() => const NotificationScreen()),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => navController.goToProfile(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  homeController.imageUrl.value.isNotEmpty
                      ? homeController.imageUrl.value
                      : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 34,
                    height: 34,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white, size: 18),
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

// ==================== MOBILE LAYOUT ====================
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
        toolbarHeight: 52,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87, size: 20),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: Obx(
          () => Text(
            navController.getPageTitle(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                homeController.imageUrl.value.isNotEmpty
                    ? homeController.imageUrl.value
                    : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 30,
                  height: 30,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: _MobileDrawer(navController: navController, homeController: homeController),
      bottomNavigationBar: _CustomBottomNavBar(navController: navController),
      body: Obx(() => navController.getCurrentScreen()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        mini: true,
        child: const Icon(Icons.add, color: Colors.white, size: 20),
        onPressed: () => Get.to(() => SelectPostTypeScreen()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final EmployerNavigationController navController;

  const _CustomBottomNavBar({required this.navController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIconMobile(icon: Icons.home_outlined, activeIcon: Icons.home, index: 0, navController: navController),
          _NavIconMobile(icon: Icons.message_outlined, activeIcon: Icons.message, index: 1, navController: navController),
          _NavIconMobile(icon: Icons.folder_outlined, activeIcon: Icons.folder, index: 2, navController: navController),
          _NavIconMobile(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, index: 3, navController: navController),
          _NavIconMobile(icon: Icons.settings_outlined, activeIcon: Icons.settings, index: 4, navController: navController),
        ],
      ),
    );
  }
}

class _NavIconMobile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final int index;
  final EmployerNavigationController navController;

  const _NavIconMobile({
    required this.icon,
    required this.activeIcon,
    required this.index,
    required this.navController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = navController.currentIndex.value == index;
      return GestureDetector(
        onTap: () => navController.currentIndex.value = index,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            selected ? activeIcon : icon,
            color: selected ? primary : Colors.grey.shade400,
            size: 22,
          ),
        ),
      );
    });
  }
}

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
            // Header
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
                  Obx(
                    () => ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        homeController.imageUrl.value.isNotEmpty
                            ? homeController.imageUrl.value
                            : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.white, size: 34),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      homeController.fullName.value,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Free Account',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
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
                  _drawerItem(Icons.build_outlined, 'Hub Dashboard', () { navController.goToHubDashboard(); Navigator.pop(context); }),
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

// ==================== HOME CONTENT WEB ====================
class HomeContentWeb extends StatelessWidget {
  const HomeContentWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<EmployeeHomeController>();
    final navController = Get.find<EmployerNavigationController>();

    return RefreshIndicator(
      onRefresh: () => Future.wait([
        homeController.fetchProjects(page: 1, resetList: true),
        homeController.fetchTalents(),
      ]),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WebWelcomeBanner(
                  homeController: homeController,
                  navController: navController,
                  isMobile: isMobile,
                ),
                SizedBox(height: isMobile ? 14 : 18),
                _ProjectsTabBar(navController: navController),
                const SizedBox(height: 14),
                Obx(
                  () => navController.selectedProjectTab.value == 0
                      ? const _TalentFilterSection()
                      : const _ProjectFilterSection(),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => navController.selectedProjectTab.value == 0
                      ? _TalentsGridSection(isMobile: isMobile, isTablet: isTablet)
                      : _ProjectsGridSection(isMobile: isMobile, isTablet: isTablet, navController: navController),
                ),
                const SizedBox(height: 20),
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
        child: isMobile
            ? _mobileBanner()
            : _desktopBanner(),
      ),
    );
  }

  Widget _mobileBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${homeController.fullName.value.split(' ').first}! 👋',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          'Find talent & manage your projects.',
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.82)),
        ),
        const SizedBox(height: 12),
        Row(
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
        ),
      ],
    );
  }

  Widget _desktopBanner() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${homeController.fullName.value.split(' ').first}! 👋',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Find top talent and manage your projects efficiently.',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.84)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _bannerButton(
                    label: 'Post a Job',
                    icon: Icons.add,
                    filled: true,
                    onTap: () => Get.to(() => SelectPostTypeScreen()),
                  ),
                  const SizedBox(width: 10),
                  _bannerButton(
                    label: 'Find Talent',
                    icon: Icons.search,
                    filled: false,
                    onTap: () => navController.goToTalentDiscovery(),
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: filled ? primary : Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: filled ? primary : Colors.white,
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
      height: 40,
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
        _FilterDropdown(filters: timeFilters, selected: selectedTimeFilter),
        const Spacer(),
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

    return Row(
      children: [
        _FilterDropdown(filters: timeFilters, selected: selectedTimeFilter),
        const Spacer(),
        Obx(() => Row(
          children: ['All', 'Featured'].map((f) {
            final selected = selectedFilter.value == f;
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                onTap: () => selectedFilter.value = f,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected ? primary.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? primary.withOpacity(0.3) : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected ? primary : Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
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
      height: 34,
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
            onChanged: (val) => selected.value = val!,
            items: filters
                .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ==================== TALENTS GRID ====================
class _TalentsGridSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;

  const _TalentsGridSection({this.isMobile = false, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<EmployeeHomeController>();
    final navController = Get.find<EmployerNavigationController>();

    return Obx(() {
      if (homeController.isLoadingTalents.value) {
        return const Center(
          child: Padding(padding: EdgeInsets.symmetric(vertical: 30), child: CircularProgressIndicator()),
        );
      }

      final talents = homeController.recommendedTalents;
      if (talents.isEmpty) {
        return _EmptyState(icon: Icons.people_outline, text: 'No talents found');
      }

      final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
      final displayCount = talents.length > 6 ? 6 : talents.length;

      return Column(
        children: [
          _SectionHeader(
            title: '${talents.length} Talents Found',
            onSeeAll: () => navController.goToTalentDiscovery(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 2.8 : (isTablet ? 2.2 : 2.0),
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) =>
                _TalentCard(talent: talents[index], navController: navController),
          ),
        ],
      );
    });
  }
}

// ==================== COMPACT TALENT CARD ====================
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
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
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        talent.fullName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(talent.ratingDisplay, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  talent.title,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      talent.hourlyRateDisplay.isEmpty ? 'Rate TBD' : talent.hourlyRateDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 4,
                      children: displaySkills
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(skill, style: const TextStyle(fontSize: 9, color: Colors.black54)),
                            ),
                          )
                          .toList(),
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
          // View button
          GestureDetector(
            onTap: () => navController.goToTalentProfile(talent),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'View',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PROJECTS GRID ====================
class _ProjectsGridSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final EmployerNavigationController navController;

  const _ProjectsGridSection({this.isMobile = false, this.isTablet = false, required this.navController});

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
      if (projects.isEmpty) {
        return _EmptyState(icon: Icons.folder_open, text: 'No projects found');
      }

      final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
      final displayCount = projects.length > 6 ? 6 : projects.length;

      return Column(
        children: [
        _SectionHeader(
  title: '${projects.length} Projects Found',
  onSeeAll: () {
    // Yeh line change karo
    navController.goToProjectsDiscovery(); // Direct navigation controller use karo
  },
),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.9 : (isTablet ? 1.6 : 1.5),
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) => _ProjectCard(project: projects[index]),
          ),
          if (homeController.isLoadingMoreProjects.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }
}

// ==================== COMPACT PROJECT CARD ====================
class _ProjectCard extends StatelessWidget {
  final ProjectFeedModel project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final displaySkills = project.skills.length > 3 ? project.skills.sublist(0, 3) : project.skills;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: badges
          Row(
            children: [
              if (project.featured)
                _Badge(label: 'FEATURED', color: const Color(0xFF00BCD4)),
              if (project.featured) const SizedBox(width: 6),
              if (project.isVerified)
                Icon(Icons.verified, color: Colors.blue.shade600, size: 14),
              const Spacer(),
              Icon(Icons.bookmark_border, color: Colors.grey.shade300, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            project.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          // Description
          Text(
            project.description.length > 60
                ? '${project.description.substring(0, 60)}...'
                : project.description,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),
          // Budget & Timeline
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BUDGET', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text(project.displayBudget, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TIMELINE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.grey.shade400, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(project.duration, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Skills
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              ...displaySkills.map(
                (skill) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: primary.withOpacity(0.12)),
                  ),
                  child: Text(skill, style: TextStyle(fontSize: 10, color: primary)),
                ),
              ),
              if (project.skills.length > 3)
                Text('+${project.skills.length - 3}', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
            ],
          ),
          const Spacer(),
          // View button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Get.to(() => ProjectDetailScreen(project: project)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'View Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPERS ====================
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text('See All', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_ios, size: 10, color: primary),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.3),
      ),
    );
  }
}

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
// lib/Employee/Screens/Employee_Home_Screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects_Detail_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Place_Bid_Screen.dart';
import 'package:templink/Employee/Screens/mployee_Applied_Jobs_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_Projects_Discovery_Screen.dart';
import 'package:templink/Employeer/Screens/Employer_my_jobs_screens.dart';
import 'package:templink/Employeer/Screens/project_detail_screen.dart';
import 'package:templink/Employee/Screens/employee_application_detail.dart';
import 'package:templink/Employee/models/job_application_model.dart';
import 'package:templink/Global_Screens/All_companies_list_screen.dart';
import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Global_Screens/Coins_purchase_screen.dart';
import 'package:templink/Resume_Builder/Screens/Resume_Dashboard_Screen.dart';
import 'package:templink/controllers/video_call_controller.dart';
import 'package:templink/Employee/Controllers/Employee_home_controller.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects.dart';
import 'package:templink/Employee/Screens/Employee_Job_Detail_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Stats_Screen.dart';
import 'package:templink/Employee/Screens/Employee_proposals_Screen.dart';
import 'package:templink/Employee/Screens/employee_requests_screen.dart';
import 'package:templink/Employee/models/Employee_jobs_model.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart';
import 'package:templink/Employee/models/project_model.dart';
import 'package:templink/Global_Screens/Chat_Users_List_Screen.dart';
import 'package:templink/Global_Screens/Notification_Screen.dart';
import 'package:templink/Global_Screens/Search_Screen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Global_Screens/Settings_Screen.dart';
import 'package:templink/Global_Screens/Reports_Screen.dart';
import 'package:templink/Global_Screens/Help_Support_Screen.dart';
import 'package:templink/Services/Notificaton_Service.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/config/api_config.dart';
import 'package:templink/Controllers/call_controller.dart';
import 'package:templink/Controllers/chat_socket_controller.dart';

// ==================== SAFE NAME HELPER ====================
String _getFirstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'there';
  return trimmed.split(RegExp(r'\s+')).first;
}

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isWeb = isDesktop || isTablet;

    if (!Get.isRegistered<EmployeeHomeController>()) {
      Get.put(EmployeeHomeController(), permanent: true);
    }
    if (!Get.isRegistered<EmployeeNavigationController>()) {
      Get.put(EmployeeNavigationController(), permanent: true);
    }

    return isWeb
        ? const EmployeeHomeScreenWeb()
        : const EmployeeHomeScreenMobile();
  }
}

// ==================== NAVIGATION CONTROLLER ====================
class EmployeeNavigationController extends GetxController {
  final currentIndex = 0.obs;
  final selectedFeedTab = 0.obs;
  final selectedJobFilterIndex = 0.obs;
  final selectedProjectFilterIndex = 0.obs;

  final selectedProjectId = ''.obs;
  final selectedActiveProject = Rxn<EmployeeActiveProjectModel>();
  final selectedApplication = Rxn<EmployeeApplication>();
  final selectedJobForDetail = Rxn<JobPostModel>();
  final selectedProjectForProposal = Rxn<ProjectFeedModel>();
  final selectedProject = Rxn<ProjectFeedModel>();
  final selectedChatUser = Rxn<Map<String, dynamic>>();

  void goToHome() => currentIndex.value = 0;
  void goToMessages() => currentIndex.value = 1;
  void goToProposals() => currentIndex.value = 2;
  void goToSearch() => currentIndex.value = 3;
  void goToProfile() => currentIndex.value = 4;
  void goToActiveProjects() => currentIndex.value = 5;
  void goToStats() => currentIndex.value = 7;
  void goToResumeBuilder() => currentIndex.value = 8;
  void goToHireRequests() => currentIndex.value = 9;
  void goToAppliedJobs() => currentIndex.value = 10;
  void goToCoinsPurchase() => currentIndex.value = 11;
  void goToMyJobs() => currentIndex.value = 16;
  void goToLiveProjects() => currentIndex.value = 17;
  void goToDiscoverProjects() => currentIndex.value = 18;
  void goToSettings() => currentIndex.value = 19;
  void goToReports() => currentIndex.value = 20;
  void goToHelpSupport() => currentIndex.value = 21;

  void goToProjectDetail(ProjectFeedModel project) {
    selectedProject.value = project;
    currentIndex.value = 6;
  }

  void goToActiveProjectDetail(EmployeeActiveProjectModel project) {
    selectedActiveProject.value = project;
    currentIndex.value = 6;
  }

  void goToJobDetail(JobPostModel job) {
    selectedJobForDetail.value = job;
    currentIndex.value = 13;
  }

  void goToSubmitProposal(ProjectFeedModel project) {
    selectedProjectForProposal.value = project;
    currentIndex.value = 14;
  }

  void goToChat(Map<String, dynamic> user) {
    selectedChatUser.value = user;
    currentIndex.value = 15;
  }

  void goBack() {
    if (currentIndex.value == 6) {
      if (selectedActiveProject.value != null) {
        selectedActiveProject.value = null;
        currentIndex.value = 5;
      } else if (selectedProject.value != null) {
        selectedProject.value = null;
        currentIndex.value = 0;
      }
    } else if (currentIndex.value == 7) {
      currentIndex.value = 0;
    } else if (currentIndex.value == 12) {
      selectedApplication.value = null;
      currentIndex.value = 10;
    } else if (currentIndex.value == 13) {
      selectedJobForDetail.value = null;
      currentIndex.value = 0;
    } else if (currentIndex.value == 14) {
      selectedProjectForProposal.value = null;
      currentIndex.value = 6;
    } else if (currentIndex.value == 15) {
      selectedChatUser.value = null;
      currentIndex.value = 1;
    } else if (currentIndex.value == 16 ||
        currentIndex.value == 17 ||
        currentIndex.value == 18 ||
        currentIndex.value == 19 ||
        currentIndex.value == 20 ||
        currentIndex.value == 21) {
      currentIndex.value = 0;
    } else {
      currentIndex.value = 0;
    }
  }

  String getPageTitle() {
    switch (currentIndex.value) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Messages';
      case 2:
        return 'My Proposals';
      case 3:
        return 'Search';
      case 4:
        return 'Profile';
      case 5:
        return 'Active Projects';
      case 6:
        return 'Project Details';
      case 7:
        return 'My Stats';
      case 8:
        return 'Resume Builder';
      case 9:
        return 'Hire Requests';
      case 10:
        return 'Applied Jobs';
      case 11:
        return 'Coins Purchase';
      case 13:
        return 'Job Details';
      case 14:
        return 'Submit Proposal';
      case 15:
        return 'Chat';
      case 16:
        return 'My Jobs';
      case 17:
        return 'Live Projects';
      case 18:
        return 'Discover Projects';
      case 19:
        return 'Settings';
      case 20:
        return 'Reports';
      case 21:
        return 'Help & Support';
      default:
        return 'Dashboard';
    }
  }

  Widget getCurrentScreen() {
    switch (currentIndex.value) {
      case 0:
        return const HomeContentWeb();
      case 1:
        return const ChatUsersListScreen();
      case 2:
        return const MyProposalsScreen();
      case 3:
        return const Center(child: SearchScreen());
      case 4:
        return const Center(child: EmployeeProfileScreen());
      case 5:
        return EmployeeActiveProjectsScreen(
          onProjectTap: (projectId, project) {
            selectedProjectId.value = projectId;
            selectedActiveProject.value = project;
            currentIndex.value = 6;
          },
          onBackPressed: goBack,
          showSidebar: false,
        );
      case 6:
        if (selectedActiveProject.value != null) {
          return EmployeeProjectDetailsScreen(
            project: selectedActiveProject.value!,
            onBackPressed: goBack,
          );
        } else if (selectedProject.value != null) {
          return ProjectDetailScreen(
            project: selectedProject.value!,
            showSidebar: true,
            onBackPressed: goBack,
          );
        }
        return const Center(child: Text('Project not found'));
      case 7:
        return MyStatsScreen(
          onNavigateToCoins: goToCoinsPurchase,
          onBackPressed: goBack,
          showSidebar: false,
        );
      case 8:
        return ResumeDashboardScreen(
          onBackPressed: goBack,
          showSidebar: true,
        );
      case 9:
        return const EmployeeRequestsScreen();
      case 10:
        return EmployeeAppliedJobsScreen(
          onApplicationTap: (application) {
            selectedApplication.value = application;
            currentIndex.value = 12;
          },
          onBackPressed: goBack,
          showSidebar: false,
        );
      case 11:
        return CoinsPurchaseScreen(
          onBackPressed: goBack,
          showSidebar: false,
        );
      case 12:
        if (selectedApplication.value != null) {
          return EmployeeApplicationDetailScreen(
            application: selectedApplication.value!,
            onBackPressed: goBack,
            showSidebar: false,
          );
        }
        return const Center(child: Text('Application not found'));
      case 13:
        if (selectedJobForDetail.value != null) {
          return JobDetailScreen(
            job: selectedJobForDetail.value!,
            onBackPressed: goBack,
            showSidebar: false,
          );
        }
        return const Center(child: Text('Job not found'));
      case 14:
        if (selectedProjectForProposal.value != null) {
          return SubmitProposalScreen(
            project: selectedProjectForProposal.value!,
            onBackPressed: goBack,
            showSidebar: true,
          );
        }
        return const Center(child: Text('Project not found'));
      case 15:
        if (selectedChatUser.value != null) {
          return ChatScreen(
            userName: selectedChatUser.value!['name'] ?? 'User',
            userOnline: selectedChatUser.value!['online'] ?? false,
            toUserId: selectedChatUser.value!['userId'] ?? '',
            baseUrl: ApiConfig.baseUrl,
            myToken: '',
            myUserId: '',
            initialConversationId:
                selectedChatUser.value!['conversationId']?.toString(),
            initialMessages: null,
            onBackPressed: goBack,
            showSidebar: false,
          );
        }
        return const Center(child: Text('Chat not available'));
      case 16:
        return const EmployerJobsScreen();
      case 17:
        return EmployeeActiveProjectsScreen(
          onProjectTap: (projectId, project) {
            selectedProjectId.value = projectId;
            selectedActiveProject.value = project;
            currentIndex.value = 6;
          },
          onBackPressed: goBack,
          showSidebar: false,
        );
      case 18:
        return const ProjectsDiscoveryScreen(showSidebar: true);
      case 19:
        return SettingsScreen(
          onBackPressed: goBack,
          showSidebar: false,
        );
      case 20:
        return ReportsScreen(
          onBackPressed: goBack,
          showSidebar: false,
        );
      case 21:
        return HelpSupportScreen(
          onBackPressed: goBack,
          showSidebar: false,
        );
      default:
        return const HomeContentWeb();
    }
  }
}

// ==================== WEB LAYOUT ====================
class EmployeeHomeScreenWeb extends StatefulWidget {
  const EmployeeHomeScreenWeb({super.key});

  @override
  State<EmployeeHomeScreenWeb> createState() => _EmployeeHomeScreenWebState();
}

class _EmployeeHomeScreenWebState extends State<EmployeeHomeScreenWeb> {
  final EmployeeHomeController homeController =
      Get.find<EmployeeHomeController>();
  final EmployeeNavigationController navController =
      Get.find<EmployeeNavigationController>();

  bool _sidebarExpanded = true;

  final List<_NavItem> _navItems = [
    _NavItem(Icons.home_outlined, Icons.home, 'Home'),
    _NavItem(Icons.message_outlined, Icons.message, 'Messages'),
    _NavItem(Icons.description_outlined, Icons.description, 'My Proposals'),
    _NavItem(Icons.search_outlined, Icons.search, 'Search'),
    _NavItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _initCallServices();
  }

  Future<void> _initCallServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final userId = prefs.getString('auth_user_id') ?? '';
      if (token.isEmpty || userId.isEmpty) return;

      if (!Get.isRegistered<ChatSocketController>()) {
        Get.put(
          ChatSocketController(
            socketBaseUrl: ApiConfig.baseUrl,
            token: token,
            myUserId: userId,
          ),
          permanent: true,
        );
      }
      if (!Get.isRegistered<CallController>()) {
        final callCtrl = Get.put(CallController(), permanent: true);
        callCtrl.init(userId);
      }
      if (!Get.isRegistered<VideoCallController>()) {
        final videoCtrl = Get.put(VideoCallController(), permanent: true);
        await videoCtrl.init(userId);
      }
    } catch (e) {
      debugPrint('❌ _initCallServices error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final sidebarW = _sidebarExpanded ? (isDesktop ? 260.0 : 220.0) : 72.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: sidebarW,
            child: _buildWebSidebar(sidebarW),
          ),
          Expanded(
            child: Column(
              children: [
                _buildWebTopBar(),
                Expanded(child: Obx(() => navController.getCurrentScreen())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSidebar(double width) {
    final expanded = _sidebarExpanded;

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
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.work_outline,
                      color: Colors.white, size: 18),
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  const Text(
                    'Templink',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _sidebarExpanded = !_sidebarExpanded),
                    child: Icon(Icons.menu,
                        size: 20, color: Colors.grey.shade600),
                  ),
                ] else ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _sidebarExpanded = !_sidebarExpanded),
                    child: Icon(Icons.menu,
                        size: 20, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          if (expanded)
            Obx(() => Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          homeController.imageUrl.value.isNotEmpty
                              ? homeController.imageUrl.value
                              : 'https://i.pravatar.cc/300?img=11',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 36,
                            height: 36,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 20),
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
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Free Account',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          if (!expanded) const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                ..._navItems.asMap().entries.map((e) {
                  final i = e.key;
                  final item = e.value;
                  return _webNavItem(item, i, expanded);
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1),
                ),
                _webExtraNavItem(
                    Icons.dashboard, 'Active Projects', expanded, () {
                  navController.goToActiveProjects();
                }),
                _webExtraNavItem(
                    Icons.live_tv_outlined, 'Live Projects', expanded, () {
                  navController.goToLiveProjects();
                }),
                _webExtraNavItem(
                    Icons.bar_chart_outlined, 'My Stats', expanded, () {
                  navController.goToStats();
                }),
                _webExtraNavItem(
                    Icons.description_outlined, 'Resume Builder', expanded, () {
                  navController.goToResumeBuilder();
                }),
                _webExtraNavItem(
                    Icons.person_add, 'Hire Requests', expanded, () {
                  navController.goToHireRequests();
                }),
                _webExtraNavItem(
                    Icons.wordpress, 'Applied Jobs', expanded, () {
                  navController.goToAppliedJobs();
                }),
                _webExtraNavItem(
                    Icons.currency_bitcoin, 'Buy Coins', expanded, () {
                  navController.goToCoinsPurchase();
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1),
                ),
                _webExtraNavItem(
                    Icons.settings_outlined, 'Settings', expanded, () {
                  debugPrint('Settings tapped');
                  navController.goToSettings();
                }),
                _webExtraNavItem(
                    Icons.assessment_outlined, 'Reports', expanded, () {
                  debugPrint('Reports tapped');
                  navController.goToReports();
                }),
                _webExtraNavItem(
                    Icons.help_outline, 'Help & Support', expanded, () {
                  debugPrint('Help & Support tapped');
                  navController.goToHelpSupport();
                }),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade100, width: 1)),
            ),
            child: _webLogoutTile(expanded),
          ),
        ],
      ),
    );
  }

  Widget _webNavItem(_NavItem item, int index, bool expanded) {
    return Obx(() {
      final selected = navController.currentIndex.value == index;
      return GestureDetector(
        onTap: () => navController.currentIndex.value = index,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 12 : 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                color: selected ? primary : Colors.grey.shade600,
                size: 20,
              ),
              if (expanded) ...[
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? primary : Colors.black87,
                  ),
                ),
                if (selected) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _webExtraNavItem(
      IconData icon, String label, bool expanded, VoidCallback onTap) {
    return Obx(() {
      bool isSelected = false;
      if (label == 'Active Projects' &&
          navController.currentIndex.value == 5) isSelected = true;
      if (label == 'Discover Projects' &&
          navController.currentIndex.value == 18) isSelected = true;
      if (label == 'My Jobs' &&
          navController.currentIndex.value == 16) isSelected = true;
      if (label == 'Live Projects' &&
          navController.currentIndex.value == 17) isSelected = true;
      if (label == 'My Stats' &&
          navController.currentIndex.value == 7) isSelected = true;
      if (label == 'Resume Builder' &&
          navController.currentIndex.value == 8) isSelected = true;
      if (label == 'Hire Requests' &&
          navController.currentIndex.value == 9) isSelected = true;
      if (label == 'Applied Jobs' &&
          navController.currentIndex.value == 10) isSelected = true;
      if (label == 'Buy Coins' &&
          navController.currentIndex.value == 11) isSelected = true;
      if (label == 'Settings' &&
          navController.currentIndex.value == 19) isSelected = true;
      if (label == 'Reports' &&
          navController.currentIndex.value == 20) isSelected = true;
      if (label == 'Help & Support' &&
          navController.currentIndex.value == 21) isSelected = true;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: expanded ? 12 : 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? primary : Colors.grey.shade500,
                size: 20,
              ),
              if (expanded) ...[
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? primary : Colors.grey.shade700,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _webLogoutTile(bool expanded) {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 12 : 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_outlined, color: Colors.red, size: 20),
            if (expanded) ...[
              const SizedBox(width: 12),
              const Text('Log Out',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWebTopBar() {
    return Obx(() => Container(
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
              Text(
                navController.getPageTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.black87, size: 24),
                    onPressed: () => Get.to(() => const NotificationScreen()),
                    tooltip: 'Notifications',
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
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
              const SizedBox(width: 4),
              Obx(() => GestureDetector(
                    onTap: () => navController.goToProfile(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        homeController.imageUrl.value.isNotEmpty
                            ? homeController.imageUrl.value
                            : 'https://i.pravatar.cc/300?img=11',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 38,
                          height: 38,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ));
  }

  Future<void> _handleLogout() async {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
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

// ==================== HOME CONTENT (SHARED) ====================
class HomeContentWeb extends StatelessWidget {
  const HomeContentWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return RefreshIndicator(
      onRefresh: () => homeController.fetchAll(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 14 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WebWelcomeBanner(isMobile: isMobile),
                SizedBox(height: isMobile ? 16 : 24),
                _FeedTabs(isMobile: isMobile),
                SizedBox(height: isMobile ? 14 : 20),
                Obx(() => navController.selectedFeedTab.value == 0
                    ? const _CategoriesSectionWeb()
                    : const SizedBox.shrink()),
                SizedBox(height: isMobile ? 14 : 20),
                Obx(() => navController.selectedFeedTab.value == 0
                    ? const _JobFilterChipsWeb()
                    : const _ProjectFilterChipsWeb()),
                SizedBox(height: isMobile ? 14 : 20),
                Obx(() => navController.selectedFeedTab.value == 0
                    ? const _JobsSectionWeb()
                    : const _ProjectsSectionWeb()),
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
  final bool isMobile;
  const _WebWelcomeBanner({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return Obx(() {
      final firstName = _getFirstName(homeController.fullName.value);

      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $firstName! 👋',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find your dream job and grow your career.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (ctx, c) {
                      final veryNarrow = c.maxWidth < 320;
                      if (veryNarrow) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: _bannerBtn(
                                icon: Icons.search,
                                label: 'Find Jobs',
                                filled: true,
                                onTap: () => navController.goToSearch(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: _bannerBtn(
                                icon: Icons.person_add,
                                label: 'Complete Profile',
                                filled: false,
                                onTap: () => navController.goToProfile(),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _bannerBtn(
                              icon: Icons.search,
                              label: 'Find Jobs',
                              filled: true,
                              onTap: () => navController.goToSearch(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _bannerBtn(
                              icon: Icons.person_add,
                              label: 'Complete Profile',
                              filled: false,
                              onTap: () => navController.goToProfile(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, $firstName! 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Find your dream job and grow your career.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _bannerBtn(
                              icon: Icons.search,
                              label: 'Find Jobs',
                              filled: true,
                              onTap: () => navController.goToSearch(),
                            ),
                            const SizedBox(width: 12),
                            _bannerBtn(
                              icon: Icons.person_add,
                              label: 'Complete Profile',
                              filled: false,
                              onTap: () => navController.goToProfile(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(Icons.work_outline,
                      size: 80, color: Colors.white.withOpacity(0.2)),
                ],
              ),
      );
    });
  }

  Widget _bannerBtn({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: filled ? null : Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: filled ? primary : Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
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

// ==================== FEED TABS ====================
class _FeedTabs extends StatelessWidget {
  final bool isMobile;
  const _FeedTabs({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();
    final EmployeeHomeController homeController = Get.find();

    return Container(
      height: isMobile ? 44 : 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton('Jobs', 0, navController, homeController),
          _buildTabButton('Projects', 1, navController, homeController),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index,
      EmployeeNavigationController navController,
      EmployeeHomeController homeController) {
    return Expanded(
      child: Obx(() {
        final selected = navController.selectedFeedTab.value == index;
        return GestureDetector(
          onTap: () {
            navController.selectedFeedTab.value = index;
            if (index == 0) navController.selectedJobFilterIndex.value = 0;
            if (index == 1) {
              navController.selectedProjectFilterIndex.value = 0;
              homeController.resetToFirstCategory();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: selected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : null,
            ),
            child: Center(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        );
      }),
    );
  }
}

// ==================== CATEGORIES SECTION ====================
class _CategoriesSectionWeb extends StatelessWidget {
  const _CategoriesSectionWeb();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Browse Jobs by Category',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isMobile ? 40 : 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: homeController.categoryList.length,
            itemBuilder: (context, index) {
              final name =
                  homeController.categoryList[index]['name'] as String;
              return Obx(() {
                final isSelected =
                    homeController.selectedParentCategory.value == name;
                return GestureDetector(
                  onTap: () => homeController.setParentCategory(name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primary : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: primary.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        Obx(() => SizedBox(
              height: isMobile ? 34 : 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeController.currentSubcategories.length,
                itemBuilder: (context, index) {
                  final sub = homeController.currentSubcategories[index];
                  return Obx(() {
                    final isSelected =
                        homeController.selectedSubcategory.value == sub;
                    return GestureDetector(
                      onTap: () => homeController.setSelectedSubcategory(sub),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primary.withOpacity(0.12)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            sub,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected ? primary : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            )),
      ],
    );
  }
}

// ==================== JOB FILTER CHIPS ====================
class _JobFilterChipsWeb extends StatelessWidget {
  const _JobFilterChipsWeb();

  final List<Map<String, dynamic>> jobFilters = const [
    {'label': 'All', 'icon': Icons.all_inclusive},
    {'label': 'Remote Only', 'icon': Icons.home_work},
    {'label': 'Full-time', 'icon': Icons.access_time},
    {'label': 'Contract', 'icon': Icons.description},
    {'label': 'Urgent', 'icon': Icons.priority_high},
  ];

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
            children: jobFilters.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _JobFilterChip(
                  label: filter['label'] as String,
                  icon: filter['icon'] as IconData,
                  index: index,
                  isSelected:
                      navController.selectedJobFilterIndex.value == index,
                  onTap: () =>
                      navController.selectedJobFilterIndex.value = index,
                ),
              );
            }).toList(),
          )),
    );
  }
}

class _JobFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _JobFilterChip({
    required this.label,
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ==================== PROJECT FILTER CHIPS ====================
class _ProjectFilterChipsWeb extends StatelessWidget {
  const _ProjectFilterChipsWeb();

  final List<Map<String, dynamic>> projectFilters = const [
    {'label': 'All', 'icon': Icons.all_inclusive},
    {'label': 'Featured', 'icon': Icons.star},
    {'label': 'Fixed Budget', 'icon': Icons.attach_money},
    {'label': 'Hourly', 'icon': Icons.timer},
    {'label': 'New', 'icon': Icons.fiber_new},
  ];

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
            children: projectFilters.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ProjectFilterChip(
                  label: filter['label'] as String,
                  icon: filter['icon'] as IconData,
                  index: index,
                  isSelected:
                      navController.selectedProjectFilterIndex.value == index,
                  onTap: () =>
                      navController.selectedProjectFilterIndex.value = index,
                ),
              );
            }).toList(),
          )),
    );
  }
}

class _ProjectFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProjectFilterChip({
    required this.label,
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ==================== JOBS SECTION ====================
class _JobsSectionWeb extends StatelessWidget {
  const _JobsSectionWeb();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              homeController.selectedSubcategory.value.isNotEmpty
                  ? '${homeController.selectedSubcategory.value} Jobs'
                  : 'Jobs',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        const SizedBox(height: 12),
        Obx(() {
          if (homeController.isLoadingJobs.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (homeController.jobsError.value != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(homeController.jobsError.value!,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        homeController.fetchJobs(page: 1, resetList: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<JobPostModel> displayJobs =
              List.from(homeController.filteredJobsByCategory);

          switch (navController.selectedJobFilterIndex.value) {
            case 1:
              displayJobs = displayJobs
                  .where((j) => j.workplace.toLowerCase() == 'remote')
                  .toList();
              break;
            case 2:
              displayJobs = displayJobs
                  .where((j) => j.type.toLowerCase().contains('full'))
                  .toList();
              break;
            case 3:
              displayJobs = displayJobs
                  .where((j) => j.type.toLowerCase().contains('contract'))
                  .toList();
              break;
            case 4:
              displayJobs =
                  displayJobs.where((j) => j.urgency == true).toList();
              break;
          }

          if (displayJobs.isEmpty) {
            return const _EmptyState(
                icon: Icons.work_off, text: 'No jobs found');
          }

          return Column(
            children: [
              _BuildWebGrid(
                itemCount: displayJobs.length,
                itemBuilder: (i) => _JobCardWeb(job: displayJobs[i]),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Showing ${homeController.jobs.length} of ${homeController.jobsTotalCount.value} jobs',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
              if (homeController.hasMoreJobs) ...[
                const SizedBox(height: 8),
                homeController.isLoadingMoreJobs.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => homeController.loadNextJobsPage(),
                          icon: const Icon(Icons.expand_more),
                          label: Text(
                            'Load More (Page ${homeController.jobsCurrentPage.value + 1}/${homeController.jobsTotalPages.value})',
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
              ],
            ],
          );
        }),
      ],
    );
  }
}

// ==================== PROJECTS SECTION ====================
class _ProjectsSectionWeb extends StatelessWidget {
  const _ProjectsSectionWeb();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() => Text(
                    _getProjectSectionTitle(
                        navController.selectedProjectFilterIndex.value),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
            TextButton(
              onPressed: () {
                navController.goToDiscoverProjects();
              },
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (homeController.isLoadingProjects.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (homeController.projectsError.value != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(homeController.projectsError.value!,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () =>
                        homeController.fetchProjects(page: 1, resetList: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<ProjectFeedModel> filteredProjects =
              homeController.projects.toList();
          switch (navController.selectedProjectFilterIndex.value) {
            case 1:
              filteredProjects =
                  filteredProjects.where((p) => p.featured).toList();
              break;
            case 2:
              filteredProjects = filteredProjects
                  .where((p) => p.budgetType == 'FIXED')
                  .toList();
              break;
            case 3:
              filteredProjects = filteredProjects
                  .where((p) => p.budgetType == 'HOURLY')
                  .toList();
              break;
            case 4:
              filteredProjects = filteredProjects.where((p) {
                if (p.createdAt == null) return false;
                return p.createdAt!
                    .isAfter(DateTime.now().subtract(const Duration(days: 7)));
              }).toList();
              break;
          }

          if (filteredProjects.isEmpty) {
            return const _EmptyState(
                icon: Icons.folder_off, text: 'No projects found');
          }

          return Column(
            children: [
              _BuildWebGrid(
                itemCount: filteredProjects.length,
                itemBuilder: (i) =>
                    _ProjectCardWeb(project: filteredProjects[i]),
              ),
              const SizedBox(height: 20),
              const _WebPagination(),
            ],
          );
        }),
      ],
    );
  }

  String _getProjectSectionTitle(int filterIndex) {
    switch (filterIndex) {
      case 0:
        return 'All Projects';
      case 1:
        return 'Featured Projects';
      case 2:
        return 'Fixed Budget Projects';
      case 3:
        return 'Hourly Projects';
      case 4:
        return 'New Projects';
      default:
        return 'Recommended Projects';
    }
  }
}

// ==================== WEB PAGINATION ====================
class _WebPagination extends StatelessWidget {
  const _WebPagination();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();

    return Obx(() {
      final currentPage = homeController.projectsCurrentPage.value;
      final totalPages = homeController.projectsTotalPages.value;

      if (totalPages <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 8,
          children: [
            GestureDetector(
              onTap: homeController.hasPrevProjectsPage
                  ? () => homeController.prevProjectsPage()
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: homeController.hasPrevProjectsPage
                      ? primary
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: homeController.hasPrevProjectsPage
                      ? Colors.white
                      : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
            ..._buildPageNumbers(currentPage, totalPages, homeController),
            GestureDetector(
              onTap: homeController.hasNextProjectsPage
                  ? () => homeController.nextProjectsPage()
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: homeController.hasNextProjectsPage
                      ? primary
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: homeController.hasNextProjectsPage
                      ? Colors.white
                      : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPageNumbers(int currentPage, int totalPages,
      EmployeeHomeController homeController) {
    List<int> pagesToShow = [];
    if (totalPages <= 7) {
      pagesToShow = List.generate(totalPages, (i) => i + 1);
    } else {
      if (currentPage <= 4) {
        pagesToShow = [1, 2, 3, 4, 5, -1, totalPages];
      } else if (currentPage >= totalPages - 3) {
        pagesToShow = [
          1,
          -1,
          totalPages - 4,
          totalPages - 3,
          totalPages - 2,
          totalPages - 1,
          totalPages
        ];
      } else {
        pagesToShow = [
          1,
          -1,
          currentPage - 1,
          currentPage,
          currentPage + 1,
          -1,
          totalPages
        ];
      }
    }

    return pagesToShow.map((page) {
      if (page == -1) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(color: Colors.grey.shade600)),
        );
      }
      final isSelected = page == currentPage;
      return GestureDetector(
        onTap: () => homeController.goToProjectsPage(page),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ==================== WEB GRID BUILDER ====================
class _BuildWebGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(int) itemBuilder;

  const _BuildWebGrid({
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width < 600 ? 1 : 2;

    if (cols == 1) {
      return Column(
        children: List.generate(
          itemCount,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i == itemCount - 1 ? 0 : 12),
            child: itemBuilder(i),
          ),
        ),
      );
    }

    List<Widget> rows = [];
    for (int i = 0; i < itemCount; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: itemBuilder(i)),
            const SizedBox(width: 16),
            i + 1 < itemCount
                ? Expanded(child: itemBuilder(i + 1))
                : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < itemCount) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

// ==================== JOB CARD ====================
class _JobCardWeb extends StatelessWidget {
  final JobPostModel job;

  const _JobCardWeb({required this.job});

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 42 : 48,
                height: isMobile ? 42 : 48,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.withOpacity(0.1)),
                child: job.logoUrl != null && job.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(job.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                    child: Text(job.companyInitials,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)))))
                    : Center(
                        child: Text(job.companyInitials,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(job.displayCompanyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (job.urgency)
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.3))),
                    child: Text('URGENT',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(job.employerLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: job.displayTags
                  .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(tag,
                          style: TextStyle(
                              fontSize: 11,
                              color: primary,
                              fontWeight: FontWeight.w500))))
                  .toList()),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Match Score',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                              width: 60,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Row(
                                children: [
                                  Container(
                                      width: 42,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [
                                                Colors.green,
                                                Colors.lightGreen
                                              ]),
                                          borderRadius:
                                              BorderRadius.circular(4)))
                                ],
                              )),
                          const SizedBox(width: 8),
                          const Text('70%',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => navController.goToJobDetail(job),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 14 : 20, vertical: 10)),
                    child: const Text('Apply Now',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PROJECT CARD ====================
class _ProjectCardWeb extends StatelessWidget {
  final ProjectFeedModel project;

  const _ProjectCardWeb({required this.project});

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(project.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text('Client: ${project.displayClientName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600)),
                        ),
                        if (project.isVerified) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.verified,
                              size: 14, color: Colors.blue.shade700)
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (project.featured)
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.blue.withOpacity(0.3))),
                    child: Text('FEATURED',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700))),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _ProjectDetailWeb(
                  icon: Icons.attach_money, text: project.displayBudget),
              _ProjectDetailWeb(icon: Icons.schedule, text: project.duration),
              _ProjectDetailWeb(
                  icon: Icons.work_outline, text: project.experienceLevel),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.skills
                  .take(4)
                  .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(skill,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black87))))
                  .toList()),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (ctx, c) {
              final veryNarrow = c.maxWidth < 340;
              final infoRow = Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('${project.proposalsCount} proposals',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(project.displayPostedDate,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              );

              final button = ElevatedButton(
                onPressed: () => navController.goToProjectDetail(project),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 20, vertical: 10)),
                child: const Text('View Details',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              );

              if (veryNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoRow,
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: button),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: infoRow),
                  const SizedBox(width: 8),
                  button,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectDetailWeb extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProjectDetailWeb({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ==================== MOBILE LAYOUT ====================
class EmployeeHomeScreenMobile extends StatelessWidget {
  const EmployeeHomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();
    final EmployeeHomeController homeController = Get.find();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const _MobileDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          title: Obx(() => Text(
                navController.getPageTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: Colors.black87, size: 24),
              onPressed: () => Get.to(() => const NotificationScreen()),
            ),
            const SizedBox(width: 4),
            Obx(() => GestureDetector(
                  onTap: () => navController.goToProfile(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        homeController.imageUrl.value.isNotEmpty
                            ? homeController.imageUrl.value
                            : 'https://i.pravatar.cc/300?img=11',
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 34,
                          height: 34,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
      // ✅ Bottom nav now shown
      bottomNavigationBar: const _CustomBottomNavBar(),
      body: Obx(() => navController.getCurrentScreen()),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blue,
      //   mini: true,
      //   child: const Icon(Icons.admin_panel_settings,
      //       color: Colors.white, size: 20),
      //   onPressed: () => Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const CompaniesListScreen()),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ==================== MOBILE BOTTOM NAVIGATION ====================
class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        height: 64,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _NavIconMobile(
                icon: Icons.home_outlined, index: 0, label: 'Home'),
            _NavIconMobile(
                icon: Icons.message_outlined, index: 1, label: 'Chats'),
            _NavIconMobile(
                icon: Icons.description_outlined,
                index: 2,
                label: 'Proposals'),
            _NavIconMobile(
                icon: Icons.search_outlined, index: 3, label: 'Search'),
            _NavIconMobile(
                icon: Icons.person_outline, index: 4, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _NavIconMobile extends StatelessWidget {
  final IconData icon;
  final int index;
  final String label;

  const _NavIconMobile({
    required this.icon,
    required this.index,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();

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
                icon,
                color: selected ? Colors.white : Colors.white70,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.white : Colors.white70,
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
  const _MobileDrawer();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.82,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 24,
              24,
              32,
            ),
            decoration: BoxDecoration(color: primary.withOpacity(0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage:
                            homeController.imageUrl.value.isNotEmpty
                                ? NetworkImage(homeController.imageUrl.value)
                                : const NetworkImage(
                                    'https://i.pravatar.cc/300?img=11'),
                      ),
                    )),
                const SizedBox(height: 16),
                Obx(() => Text(
                      homeController.fullName.value,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text('Free Account',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      navController.goToProfile();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.dashboard,
                    title: 'Active Projects',
                    onTap: () {
                      navController.goToActiveProjects();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.work_outline,
                    title: 'My Jobs',
                    onTap: () {
                      navController.goToMyJobs();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.live_tv_outlined,
                    title: 'Live Projects',
                    onTap: () {
                      navController.goToLiveProjects();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'My Stats',
                    onTap: () {
                      navController.goToStats();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.description_outlined,
                    title: 'Resume Builder',
                    onTap: () {
                      navController.goToResumeBuilder();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.person_add,
                    title: 'Hire Requests',
                    onTap: () {
                      navController.goToHireRequests();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.wordpress,
                    title: 'Applied Jobs',
                    onTap: () {
                      navController.goToAppliedJobs();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.currency_bitcoin,
                    title: 'Buy Coins',
                    onTap: () {
                      navController.goToCoinsPurchase();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.assignment_outlined,
                    title: 'Reports',
                    onTap: () {
                      navController.goToReports();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      navController.goToSettings();
                      Navigator.pop(context);
                    }),
                _DrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      navController.goToHelpSupport();
                      Navigator.pop(context);
                    }),
                const _LogoutItem(),
                const _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      leading: Icon(icon, color: Colors.grey.shade600, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 14, color: Colors.black87)),
      trailing:
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }
}

class _LogoutItem extends StatelessWidget {
  const _LogoutItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: GestureDetector(
        onTap: _handleLogout,
        child: const Row(
          children: [
            Icon(Icons.logout_outlined, color: Colors.red, size: 22),
            SizedBox(width: 12),
            Text('Log Out',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);
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

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 40, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text('Version 2.1.0 (1768)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              Text('© 2024 Templink. All rights reserved.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
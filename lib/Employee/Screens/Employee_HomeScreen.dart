import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects_Detail_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Place_Bid_Screen.dart';
import 'package:templink/Employee/Screens/mployee_Applied_Jobs_Screen.dart';
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
import 'package:templink/Services/Notificaton_Service.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/config/api_config.dart';
import 'package:templink/Controllers/call_controller.dart';
import 'package:templink/Controllers/chat_socket_controller.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isWeb = isDesktop || isTablet;

    // Initialize controllers if not already registered
    if (!Get.isRegistered<EmployeeHomeController>()) {
      Get.put(EmployeeHomeController(), permanent: true);
    }
    if (!Get.isRegistered<EmployeeNavigationController>()) {
      Get.put(EmployeeNavigationController(), permanent: true);
    }

    if (isWeb) {
      return const EmployeeHomeScreenWeb();
    } else {
      return const EmployeeHomeScreenMobile();
    }
  }
}

// ==================== NAVIGATION CONTROLLER ====================
class EmployeeNavigationController extends GetxController {
  final currentIndex = 0.obs;
  final selectedFeedTab = 0.obs;
  final selectedJobFilterIndex = 0.obs;
  final selectedProjectFilterIndex = 0.obs;
  
  // Selected items for detail screens
  final selectedProjectId = ''.obs;
  final selectedActiveProject = Rxn<EmployeeActiveProjectModel>();
  final selectedApplication = Rxn<EmployeeApplication>();
  final selectedJobForDetail = Rxn<JobPostModel>();
  final selectedProjectForProposal = Rxn<ProjectFeedModel>();
  final selectedProject = Rxn<ProjectFeedModel>();
  final selectedChatUser = Rxn<Map<String, dynamic>>();

  // Navigation methods
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
  void goToMyJobs() => currentIndex.value = 16;  // ✅ My Jobs
  void goToLiveProjects() => currentIndex.value = 17;  // ✅ Live Projects
  
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
    } else if (currentIndex.value == 16) {  // ✅ Back from My Jobs
      currentIndex.value = 0;
    } else if (currentIndex.value == 17) {  // ✅ Back from Live Projects
      currentIndex.value = 0;
    } else {
      currentIndex.value = 0;
    }
  }

  String getPageTitle() {
    switch (currentIndex.value) {
      case 0: return 'Dashboard';
      case 1: return 'Messages';
      case 2: return 'My Proposals';
      case 3: return 'Search';
      case 4: return 'Profile';
      case 5: return 'Active Projects';
      case 6: return 'Project Details';
      case 7: return 'My Stats';
      case 8: return 'Resume Builder';
      case 9: return 'Hire Requests';
      case 10: return 'Applied Jobs';
      case 11: return 'Coins Purchase';
      case 13: return 'Job Details';
      case 14: return 'Submit Proposal';
      case 15: return 'Chat';
      case 16: return 'My Jobs';  // ✅ My Jobs Title
      case 17: return 'Live Projects';  // ✅ Live Projects Title
      default: return 'Dashboard';
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
            initialConversationId: selectedChatUser.value!['conversationId']?.toString(),
            initialMessages: null,
            onBackPressed: goBack,
            showSidebar: false,
          );
        }
        return const Center(child: Text('Chat not available'));
      case 16:  // ✅ My Jobs Screen
        return const EmployerJobsScreen();
      case 17:  // ✅ Live Projects Screen
        return EmployeeActiveProjectsScreen(
          onProjectTap: (projectId, project) {
            selectedProjectId.value = projectId;
            selectedActiveProject.value = project;
            currentIndex.value = 6;
          },
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
  final EmployeeHomeController homeController = Get.find<EmployeeHomeController>();
  final EmployeeNavigationController navController = Get.find<EmployeeNavigationController>();

  bool _sidebarExpanded = true;

  final List<Map<String, dynamic>> jobFilters = [
    {'label': 'All', 'icon': Icons.all_inclusive},
    {'label': 'Remote Only', 'icon': Icons.home_work},
    {'label': 'Full-time', 'icon': Icons.access_time},
    {'label': 'Contract', 'icon': Icons.description},
    {'label': 'Urgent', 'icon': Icons.priority_high},
  ];

  final List<Map<String, dynamic>> projectFilters = [
    {'label': 'All', 'icon': Icons.all_inclusive},
    {'label': 'Featured', 'icon': Icons.star},
    {'label': 'Fixed Budget', 'icon': Icons.attach_money},
    {'label': 'Hourly', 'icon': Icons.timer},
    {'label': 'New', 'icon': Icons.fiber_new},
  ];

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
      print('❌ _initCallServices error: $e');
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
                Expanded(
                  child: Obx(() => navController.getCurrentScreen()),
                ),
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
                    onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
                    child: Icon(Icons.menu,
                        size: 20, color: Colors.grey.shade600),
                  ),
                ] else ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
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
                    Icons.work_outline, 'My Jobs', expanded, () {
                  navController.goToMyJobs();
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
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
      if (label == 'Active Projects' && navController.currentIndex.value == 5) isSelected = true;
      if (label == 'My Jobs' && navController.currentIndex.value == 16) isSelected = true;
      if (label == 'Live Projects' && navController.currentIndex.value == 17) isSelected = true;
      if (label == 'My Stats' && navController.currentIndex.value == 7) isSelected = true;
      if (label == 'Resume Builder' && navController.currentIndex.value == 8) isSelected = true;
      if (label == 'Hire Requests' && navController.currentIndex.value == 9) isSelected = true;
      if (label == 'Applied Jobs' && navController.currentIndex.value == 10) isSelected = true;
      if (label == 'Buy Coins' && navController.currentIndex.value == 11) isSelected = true;
      
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
      if (!kIsWeb) {
        await NotificationService.instance.logout();
      }

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

// ==================== HOME CONTENT WEB ====================
class HomeContentWeb extends StatelessWidget {
  const HomeContentWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return RefreshIndicator(
      onRefresh: () => homeController.fetchAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WebWelcomeBanner(),
            const SizedBox(height: 24),
            _FeedTabs(),
            const SizedBox(height: 20),
            Obx(() => navController.selectedFeedTab.value == 0
                ? const _CategoriesSectionWeb()
                : const SizedBox.shrink()),
            const SizedBox(height: 20),
            Obx(() => navController.selectedFeedTab.value == 0
                ? const _JobFilterChipsWeb()
                : const _ProjectFilterChipsWeb()),
            const SizedBox(height: 20),
            Obx(() => navController.selectedFeedTab.value == 0
                ? const _JobsSectionWeb()
                : const _ProjectsSectionWeb()),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ==================== WEB WELCOME BANNER ====================
class _WebWelcomeBanner extends StatelessWidget {
  const _WebWelcomeBanner();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return Obx(() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${homeController.fullName.value.split(' ').first}! 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                    ElevatedButton.icon(
                      onPressed: () => navController.goToSearch(),
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text('Find Jobs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => navController.goToProfile(),
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Complete Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Colors.white, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
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
    ));
  }
}

// ==================== FEED TABS ====================
class _FeedTabs extends StatelessWidget {
  const _FeedTabs();

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();
    final EmployeeHomeController homeController = Get.find();

    return Container(
      height: 48,
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

  Widget _buildTabButton(String title, int index, EmployeeNavigationController navController, EmployeeHomeController homeController) {
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
                      color: selected ? Colors.white : Colors.black87)),
            ),
          ),
        );
      }),
    );
  }
}

// ==================== CATEGORIES SECTION WEB ====================
class _CategoriesSectionWeb extends StatelessWidget {
  const _CategoriesSectionWeb();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();

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
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: homeController.categoryList.length,
            itemBuilder: (context, index) {
              final name = homeController.categoryList[index]['name'] as String;
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
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
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
              height: 36,
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
                        child: Text(
                          sub,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? primary : Colors.black54,
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

// ==================== JOB FILTER CHIPS WEB ====================
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
                  isSelected: navController.selectedJobFilterIndex.value == index,
                  onTap: () => navController.selectedJobFilterIndex.value = index,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ==================== PROJECT FILTER CHIPS WEB ====================
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
                  isSelected: navController.selectedProjectFilterIndex.value == index,
                  onTap: () => navController.selectedProjectFilterIndex.value = index,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ==================== JOBS SECTION WEB ====================
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
            return _EmptyState(icon: Icons.work_off, text: 'No jobs found');
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

// ==================== PROJECTS SECTION WEB ====================
class _ProjectsSectionWeb extends StatelessWidget {
  const _ProjectsSectionWeb();

  @override
  Widget build(BuildContext context) {
    final EmployeeHomeController homeController = Get.find();
    final EmployeeNavigationController navController = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              _getProjectSectionTitle(navController.selectedProjectFilterIndex.value),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            )),
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
                    onPressed: () => homeController.fetchProjects(page: 1, resetList: true),
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
                return p.createdAt!.isAfter(
                    DateTime.now().subtract(const Duration(days: 7)));
              }).toList();
              break;
          }

          if (filteredProjects.isEmpty) {
            return _EmptyState(icon: Icons.folder_off, text: 'No projects found');
          }

          return Column(
            children: [
              _BuildWebGrid(
                itemCount: filteredProjects.length,
                itemBuilder: (i) => _ProjectCardWeb(project: filteredProjects[i]),
              ),
              const SizedBox(height: 20),
              _WebPagination(),
            ],
          );
        }),
      ],
    );
  }

  String _getProjectSectionTitle(int filterIndex) {
    switch (filterIndex) {
      case 0: return 'All Projects';
      case 1: return 'Featured Projects';
      case 2: return 'Fixed Budget Projects';
      case 3: return 'Hourly Projects';
      case 4: return 'New Projects';
      default: return 'Recommended Projects';
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: homeController.hasPrevProjectsPage
                  ? () => homeController.prevProjectsPage()
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(right: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(left: 8),
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

  List<Widget> _buildPageNumbers(int currentPage, int totalPages, EmployeeHomeController homeController) {
    List<int> pagesToShow = [];
    
    if (totalPages <= 7) {
      pagesToShow = List.generate(totalPages, (i) => i + 1);
    } else {
      if (currentPage <= 4) {
        pagesToShow = [1, 2, 3, 4, 5, -1, totalPages];
      } else if (currentPage >= totalPages - 3) {
        pagesToShow = [1, -1, totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages];
      } else {
        pagesToShow = [1, -1, currentPage - 1, currentPage, currentPage + 1, -1, totalPages];
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

// ==================== JOB CARD WEB ====================
class _JobCardWeb extends StatelessWidget {
  final JobPostModel job;

  const _JobCardWeb({required this.job});

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();

    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.withOpacity(0.1)),
                child: job.logoUrl != null && job.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(job.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(job.companyInitials,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)))))
                    : Center(
                        child: Text(job.companyInitials,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Match Score',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
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
                                      gradient: const LinearGradient(colors: [
                                        Colors.green,
                                        Colors.lightGreen
                                      ]),
                                      borderRadius: BorderRadius.circular(4)))
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
              ElevatedButton(
                onPressed: () => navController.goToJobDetail(job),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10)),
                child: const Text('Apply Now',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== PROJECT CARD WEB ====================
class _ProjectCardWeb extends StatelessWidget {
  final ProjectFeedModel project;

  const _ProjectCardWeb({required this.project});

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();

    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('Client: ${project.displayClientName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600)),
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
          Row(
            children: [
              _ProjectDetailWeb(icon: Icons.attach_money, text: project.displayBudget),
              const SizedBox(width: 16),
              _ProjectDetailWeb(icon: Icons.schedule, text: project.duration),
              const SizedBox(width: 16),
              _ProjectDetailWeb(icon: Icons.work_outline, text: project.experienceLevel),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('${project.proposalsCount} proposals',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(project.displayPostedDate,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
              ElevatedButton(
                onPressed: () => navController.goToProjectDetail(project),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10)),
                child: const Text('View Details',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600))),
            ],
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
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500)),
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
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.grey[50],
      drawer: _MobileDrawer(),
      bottomNavigationBar: _CustomBottomNavBar(),
      body: SafeArea(
        child: Obx(() => navController.getCurrentScreen()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompaniesListScreen()),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ==================== MOBILE BOTTOM NAVIGATION ====================
class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar();

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();

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
                offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavIconMobile(icon: Icons.home_outlined, index: 0),
            _NavIconMobile(icon: Icons.message_outlined, index: 1),
            _NavIconMobile(icon: Icons.description_outlined, index: 2),
            _NavIconMobile(icon: Icons.search_outlined, index: 3),
            _NavIconMobile(icon: Icons.person_outline, index: 4),
          ],
        ),
      ),
    );
  }
}

class _NavIconMobile extends StatelessWidget {
  final IconData icon;
  final int index;

  const _NavIconMobile({required this.icon, required this.index});

  @override
  Widget build(BuildContext context) {
    final EmployeeNavigationController navController = Get.find();

    return Obx(() {
      final selected = navController.currentIndex.value == index;
      return GestureDetector(
        onTap: () => navController.currentIndex.value = index,
        child: Icon(
          icon,
          color: selected ? Colors.white : Colors.white54,
          size: 24,
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    )),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                _DrawerItem(icon: Icons.person_outline, title: 'Profile', onTap: () {
                  navController.goToProfile();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.dashboard, title: 'Active Projects', onTap: () {
                  navController.goToActiveProjects();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.work_outline, title: 'My Jobs', onTap: () {
                  navController.goToMyJobs();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.live_tv_outlined, title: 'Live Projects', onTap: () {
                  navController.goToLiveProjects();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.bar_chart_outlined, title: 'My Stats', onTap: () {
                  navController.goToStats();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.description_outlined, title: 'Resume Builder', onTap: () {
                  navController.goToResumeBuilder();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.person_add, title: 'Hire Requests', onTap: () {
                  navController.goToHireRequests();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.wordpress, title: 'Applied Jobs', onTap: () {
                  navController.goToAppliedJobs();
                  Navigator.pop(context);
                }),
                _DrawerItem(icon: Icons.assignment_outlined, title: 'Reports', onTap: () {}),
                _DrawerItem(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
                _DrawerItem(icon: Icons.help_outline, title: 'Help & Support', onTap: () {}),
                _LogoutItem(),
                _Footer(),
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
      leading: Icon(icon, color: Colors.grey.shade600, size: 22),
      title: Text(title,
          style: const TextStyle(fontSize: 14, color: Colors.black87)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
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
      if (!kIsWeb) {
        await NotificationService.instance.logout();
      }

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
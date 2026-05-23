// lib/Employer/Screens/employer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_profile_controller.dart';
import 'package:templink/Employeer/Screens/Edit_Employeer_Profile.dart';
import 'package:templink/Employeer/Screens/Employeer_homescreen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

class EmployerProfileScreen extends StatefulWidget {
  final bool showSidebar;
  final VoidCallback? onBackPressed;

  const EmployerProfileScreen({
    super.key,
    this.showSidebar = true,
    this.onBackPressed,
  });

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
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  // ==================== WEB LAYOUT (FIXED) ====================
  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: widget.showSidebar
          ? Column(
              children: [
                _buildWebTopBar(),
                Expanded(child: _buildWebContent()),
              ],
            )
          : Column(
              children: [
                _buildWebTopBar(),
                Expanded(child: _buildWebContent()),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
          ),
          const Text(
            'Company Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
final navController = Get.find<EmployerNavigationController>();
    navController.goToEditProfile();            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar - Profile Info
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildProfileCardWeb(),
            ),
          ),
          // Right Content - Tabs
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: primary,
                    unselectedLabelColor: Colors.black45,
                    indicatorColor: primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Team'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTabWeb(),
                      _buildTeamTabWeb(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ==================== PROFILE CARD (WEB) ====================
  Widget _buildProfileCardWeb() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          // Profile Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Colors.white, width: 4),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  controller.companyName.value.isEmpty ? 'Company Name' : controller.companyName.value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.isVerified.value) ...[
                const SizedBox(width: 4),
                Icon(Icons.verified, color: Colors.blue.shade600, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.industry.value.isEmpty ? 'Industry' : '${controller.industry.value} • ${controller.fullCompanyLocation}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (controller.isVerified.value)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.blue.shade700, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Employer',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // Stats
          _buildStatRow([
            _buildStatCardWeb(controller.activePosts.value, 'ACTIVE POSTS'),
            _buildStatCardWeb(controller.totalHired.value, 'TOTAL HIRED'),
          ]),
          const SizedBox(height: 12),
          _buildStatRow([
            _buildStatCardWeb(controller.companySizeLabel.value, 'SIZE'),
            _buildStatCardWeb(controller.ratingDisplay.value, 'RATING'),
          ]),
          const SizedBox(height: 20),
          // Contact Info
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          if (controller.phone.value.isNotEmpty && controller.phone.value != 'null')
            _buildContactRow(Icons.phone, controller.phone.value),
          if (controller.companyEmail.value.isNotEmpty && controller.companyEmail.value != 'null')
            _buildContactRow(Icons.email, controller.companyEmail.value),
          if (controller.website.value.isNotEmpty && controller.website.value != 'null')
            _buildContactRow(Icons.language, controller.website.value),
          if (controller.workModel.value.isNotEmpty && controller.workModel.value != 'null')
            _buildContactRow(Icons.business_center, controller.workModel.value),
          if (controller.linkedin.value.isNotEmpty && controller.linkedin.value != 'null')
            _buildContactRow(Icons.link, controller.linkedin.value),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(List<Widget> children) {
    return Row(
      children: children,
    );
  }

  Widget _buildStatCardWeb(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value.isEmpty ? '0' : value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ABOUT TAB (WEB) ====================
  Widget _buildAboutTabWeb() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSectionCardWeb(
            title: 'About Company',
            child: Text(
              controller.about.value.isEmpty ? 'No description provided.' : controller.about.value,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          if (controller.mission.value.isNotEmpty && controller.mission.value != 'null')
            _buildSectionCardWeb(
              title: 'Our Mission',
              child: Text(
                controller.mission.value,
                style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
              ),
            ),
          const SizedBox(height: 16),
          if (controller.cultureTags.isNotEmpty && controller.cultureTags.isNotEmpty)
            _buildSectionCardWeb(
              title: 'Company Culture',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.cultureTags.map((tag) {
                  return _buildChipWeb(tag, Icons.favorite_border);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== TEAM TAB (WEB) ====================
  Widget _buildTeamTabWeb() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _buildTeamSectionWeb(),
    );
  }

  Widget _buildSectionCardWeb({required String title, required Widget child}) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildChipWeb(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSectionWeb() {
    return Obx(() {
      if (controller.teamMembers.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('No team members yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      }

      final activeMembers = controller.teamMembers.where((m) => m['status'] == 'active').toList();
      
      return Column(
        children: [
          // Stats row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTeamStatWeb('${controller.teamMembers.length}', 'Total', Icons.people, primary)),
                Expanded(child: _buildTeamStatWeb('${activeMembers.length}', 'Active', Icons.circle, Colors.green)),
                Expanded(child: _buildTeamStatWeb('${controller.teamMembers.length - activeMembers.length}', 'Past', Icons.history, Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...activeMembers.map((member) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTeamMemberCardWeb(member, isActive: true),
          )),
        ],
      );
    });
  }

  Widget _buildTeamStatWeb(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildTeamMemberCardWeb(Map<String, dynamic> member, {required bool isActive}) {
    final employee = member['employee'] ?? {};
    final name = employee['name'] ?? 'Unknown';
    final photoUrl = employee['photoUrl'] ?? '';
    final title = employee['title'] ?? 'Team Member';
    final hiredAt = member['hiredAt'] != null ? DateTime.parse(member['hiredAt'].toString()) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primary.withOpacity(0.1),
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty ? Text(name[0].toUpperCase(), style: TextStyle(color: primary, fontSize: 18)) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                if (hiredAt != null)
                  Text('Joined ${_formatDate(hiredAt)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text('Active', style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
        ),
        title: const Text(
          'Company Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
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
              SliverToBoxAdapter(child: _buildProfileHeaderMobile()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: primary,
                    unselectedLabelColor: Colors.black45,
                    indicatorColor: primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Team'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTabMobile(),
              _buildTeamTabMobile(),
            ],
          ),
        );
      }),
    );
  }

  // Mobile Profile Header
  Widget _buildProfileHeaderMobile() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: controller.logoUrl.value.isNotEmpty ? Image.network(controller.logoUrl.value, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildDefaultLogo()) : _buildDefaultLogo(),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
              child: Text(
                controller.companyName.value.isEmpty ? 'Company Name' : controller.companyName.value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (controller.isVerified.value) ...[const SizedBox(width: 6), Icon(Icons.verified, color: Colors.blue.shade600, size: 22)],
          ]),
          const SizedBox(height: 4),
          Text('${controller.industry.value.isEmpty ? 'Industry' : controller.industry.value} • ${controller.fullCompanyLocation}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => Get.to(() => const EditEmployerProfileScreen()), icon: const Icon(Icons.edit, size: 18), label: const Text('Edit Profile'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: primary), foregroundColor: primary))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.share, size: 18), label: const Text('Share'), style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0))),
            ]),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: _buildStatCardMobile(controller.activePosts.value, 'ACTIVE POSTS')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCardMobile(controller.totalHired.value, 'TOTAL HIRED')),
            ]),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: _buildStatCardMobile(controller.companySizeLabel.value, 'SIZE')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCardMobile(controller.ratingDisplay.value, 'RATING')),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardMobile(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(children: [
        Text(value.isEmpty ? '0' : value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade600, letterSpacing: 0.5)),
      ]),
    );
  }

  // Mobile About Tab
  Widget _buildAboutTabMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCardMobile(title: 'About Company', child: Text(controller.about.value.isEmpty ? 'No description provided.' : controller.about.value, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87))),
          const SizedBox(height: 12),
          if (controller.mission.value.isNotEmpty && controller.mission.value != 'null')
            _buildSectionCardMobile(title: 'Our Mission', child: Text(controller.mission.value, style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87))),
          const SizedBox(height: 12),
          if (controller.cultureTags.isNotEmpty)
            _buildSectionCardMobile(title: 'Company Culture', child: Wrap(spacing: 8, runSpacing: 8, children: controller.cultureTags.map((tag) => _buildChipMobile(tag, Icons.favorite_border)).toList())),
          const SizedBox(height: 12),
          _buildSectionCardMobile(
            title: 'Contact Info',
            child: Column(
              children: [
                if (controller.phone.value.isNotEmpty && controller.phone.value != 'null') _buildContactRowMobile(Icons.phone, controller.phone.value),
                if (controller.companyEmail.value.isNotEmpty && controller.companyEmail.value != 'null') _buildContactRowMobile(Icons.email, controller.companyEmail.value),
                if (controller.website.value.isNotEmpty && controller.website.value != 'null') _buildContactRowMobile(Icons.language, controller.website.value),
                if (controller.linkedin.value.isNotEmpty && controller.linkedin.value != 'null') _buildContactRowMobile(Icons.link, controller.linkedin.value),
                if (controller.workModel.value.isNotEmpty && controller.workModel.value != 'null') _buildContactRowMobile(Icons.business_center, controller.workModel.value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRowMobile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildSectionCardMobile({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildChipMobile(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(label, style:  TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // Mobile Team Tab
  Widget _buildTeamTabMobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildTeamSectionWeb(),
    );
  }

  // ==================== SHARED UTILITIES ====================
  Widget _buildDefaultLogo() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1A3A52), borderRadius: BorderRadius.circular(56)),
      child: Center(child: Text(controller.companyInitials, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))),
    );
  }

  void _showTeamManagementBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Team Members', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final activeCount = controller.teamMembers.where((m) => m['status'] == 'active').length;
              final pastCount = controller.teamMembers.length - activeCount;
              return Row(
                children: [
                  Expanded(child: _buildStatChip('Active: $activeCount', Icons.circle, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatChip('Past: $pastCount', Icons.history, Colors.grey)),
                ],
              );
            }),
            const SizedBox(height: 16),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:  TabBar(
                      tabs: [
                        Tab(text: 'Active Members'),
                        Tab(text: 'Past Members'),
                      ],
                      labelColor: primary,
                      unselectedLabelColor: Colors.grey,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Obx(() {
                      final activeMembers = controller.teamMembers.where((m) => m['status'] == 'active').toList();
                      final pastMembers = controller.teamMembers.where((m) => m['status'] == 'left' || m['status'] == 'terminated').toList();
                      return TabBarView(
                        children: [
                          _buildMembersListView(activeMembers, isActive: true),
                          _buildMembersListView(pastMembers, isActive: false),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMembersListView(List<Map<String, dynamic>> members, {required bool isActive}) {
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.people_outline : Icons.history, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(isActive ? 'No active members' : 'No past members', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final employee = member['employee'] ?? {};
        final name = employee['name'] ?? 'Unknown';
        final photoUrl = employee['photoUrl'] ?? '';
        final title = employee['title'] ?? 'Team Member';
        final hiredAt = member['hiredAt'] != null ? DateTime.parse(member['hiredAt'].toString()) : null;
        final leftAt = member['leftAt'] != null ? DateTime.parse(member['leftAt'].toString()) : null;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primary.withOpacity(0.1),
                backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty ? Text(name[0], style: TextStyle(color: primary)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    if (hiredAt != null) Text('Hired ${_formatDate(hiredAt)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    if (leftAt != null) Text('Left ${_formatDate(leftAt)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    if (difference < 365) return '${(difference / 30).round()} months ago';
    return '${(difference / 365).round()} years ago';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverAppBarDelegate(this.tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: tabBar);
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
import 'package:flutter/material.dart';
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

  void _showSettingsBottomSheet() {
    CustomBottomSheets.showSettingsBottomSheet(
      context: context,
      onEditProfile: _showEditProfileDialog,
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
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: _showSettingsBottomSheet,
          ),
        ],
      ),
      body: NestedScrollView(
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          // Profile Image
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
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A52),
                  borderRadius: BorderRadius.circular(56),
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.teal,
                  size: 50,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Creative Tech Agency',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.verified,
                color: Colors.blue.shade600,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enterprise Software • San Francisco, CA',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
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
                  child: _buildStatCard('24', 'ACTIVE POSTS'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('1.2k', 'TOTAL HIRED'),
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
                  child: _buildStatCard('250+', 'SIZE'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('4.8★', 'RATING'),
                ),
              ],
            ),
          ),
        ],
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
            // Edit about functionality
          },
          child: const Text(
            'Creative Tech Agency is a leading enterprise software company specializing in innovative solutions for modern businesses. We pride ourselves on creating cutting-edge technology that drives growth and efficiency.',
            style: TextStyle(
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
            // Edit culture functionality
          },
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip('Remote-First', Icons.home_work_outlined),
              _buildChip('Flexible Hours', Icons.access_time),
              _buildChip('Health Benefits', Icons.favorite_border),
              _buildChip('Learning Budget', Icons.school_outlined),
              _buildChip('Team Events', Icons.celebration_outlined),
            ],
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
              _buildTeamMember(
                'Alex Rivera',
                'CTO',
                Colors.blue.shade700,
                hasRemove: true,
              ),
              const SizedBox(height: 12),
              _buildTeamMember(
                'Sarah Chen',
                'Design Director',
                Colors.purple.shade400,
                hasRemove: true,
              ),
              const SizedBox(height: 12),
              _buildTeamMember(
                'James Wilson',
                'Lead Engineer',
                Colors.teal.shade600,
                hasRemove: true,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Add team member
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Team Member'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobPostsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildJobCard(
          title: 'Senior UI/UX Designer',
          department: 'Product Team',
          type: 'Full-time',
          salary: '\$140k - \$180k',
          applicants: '42 applicants',
          isHot: true,
          status: 'Active',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          title: 'Staff Software Engineer',
          department: 'Platform Engineering',
          type: 'Remote',
          salary: '\$180k - \$240k',
          applicants: '18 applicants',
          isHot: false,
          status: 'Active',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          title: 'Technical Product Manager',
          department: 'Fintech Solutions',
          type: 'Hybrid',
          salary: '\$160k - \$200k',
          applicants: '112 applicants',
          isHot: false,
          status: 'Paused',
        ),
      ],
    );
  }

  Widget _buildProjectsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildProjectCard(
          title: 'Mobile App Redesign',
          budget: '\$25k - \$35k',
          duration: '3-4 months',
          skills: ['Flutter', 'UI/UX', 'Figma'],
          proposals: '8 proposals',
          status: 'Active',
        ),
        const SizedBox(height: 12),
        _buildProjectCard(
          title: 'E-commerce Platform Development',
          budget: '\$50k - \$75k',
          duration: '6 months',
          skills: ['React', 'Node.js', 'AWS'],
          proposals: '15 proposals',
          status: 'Active',
        ),
        const SizedBox(height: 12),
        _buildProjectCard(
          title: 'AI Chatbot Integration',
          budget: '\$15k - \$20k',
          duration: '2 months',
          skills: ['Python', 'NLP', 'API'],
          proposals: '23 proposals',
          status: 'In Progress',
        ),
      ],
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
              if (hasEdit)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, size: 20, color: primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            name[0],
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
            onPressed: () {
              // Remove team member
            },
            icon: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
          ),
      ],
    );
  }

  Widget _buildJobCard({
    required String title,
    required String department,
    required String type,
    required String salary,
    required String applicants,
    required bool isHot,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: status == 'Paused'
            ? Border.all(color: Colors.orange.shade200, width: 1)
            : null,
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
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  if (isHot)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'HOT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  _buildStatusChip(status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$department • $type',
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
                salary,
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
                applicants,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
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
              IconButton(
                onPressed: () {
                  _showJobOptionsBottomSheet(title, status);
                },
                icon: const Icon(Icons.more_vert),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String title,
    required String budget,
    required String duration,
    required List<String> skills,
    required String proposals,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: status == 'In Progress'
            ? Border.all(color: Colors.green.shade200, width: 1)
            : null,
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
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: Colors.grey.shade600),
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
              Icon(Icons.schedule, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                duration,
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
            children: skills.map((skill) {
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
                  skill,
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
              Icon(Icons.description_outlined,
                  size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                proposals,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
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
                    // View proposals
                  },
                  icon: const Icon(Icons.description, size: 18),
                  label: const Text('View Proposals'),
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
              IconButton(
                onPressed: () {
                  _showProjectOptionsBottomSheet(title, status);
                },
                icon: const Icon(Icons.more_vert),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Active':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'Paused':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'In Progress':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'Closed':
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showJobOptionsBottomSheet(String jobTitle, String status) {
    CustomBottomSheets.showJobOptionsBottomSheet(
      context: context,
      jobTitle: jobTitle,
      status: status,
    );
  }

  void _showProjectOptionsBottomSheet(String projectTitle, String status) {
    CustomBottomSheets.showProjectOptionsBottomSheet(
      context: context,
      projectTitle: projectTitle,
      status: status,
    );
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
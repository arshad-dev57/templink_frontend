import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:templink/Employeer/Screens/Employeer_Projects_Discovery_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_Talent_Discovery_Screen.dart';
import 'package:templink/Employeer/Screens/Emplyeer_profile_screen.dart';
import 'package:templink/Global_Screens/Chat_Users_List_Screen.dart';
import 'package:templink/Global_Screens/Notification_Screen.dart';
import 'package:templink/Global_Screens/Search_Screen.dart';
import 'package:templink/Employeer/Screens/select_post_type_screen.dart';
import 'package:templink/Employeer/Screens/project_detail_screen.dart';
import 'package:templink/Employeer/Screens/talent_profile.dart';
import 'package:templink/Utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late TabController tabController;
  int selectedCategoryIndex = 0;
  int selectedProjectTab = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget get currentScreen {
    switch (currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return ChatUsersListScreen();
      case 2:
        return const Center(child: SearchScreen());
      case 3:
        return const Center(child: EmployerProfileScreen());
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _customBottomNavBar(),
      body: SafeArea(
        child: currentScreen,
      ),
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
                  child: Image.asset(
                    'assets/plus.png',
                    height: 24,
                    color: primary,
                  ),
                ),
              ),
            ),
            _navIcon('assets/search.png', 2),
            _navIcon('assets/user.png', 3),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(String image, int index) {
    final selected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => currentIndex = index);
      },
      child: Image.asset(
        image,
        color: selected ? Colors.white : Colors.white54,
        height: 24,

      ),
    );
  }

  Widget _buildHomeContent() {
    return HomeContent(
      selectedProjectTab: selectedProjectTab,
      selectedCategoryIndex: selectedCategoryIndex,
      onProjectTabChanged: (newTab) {
        setState(() {
          selectedProjectTab = newTab;
        });
      },
      onCategoryTabChanged: (newIndex) {
        setState(() {
          selectedCategoryIndex = newIndex;
        });
      },
    );
  }
}

// HomeContent StatefulWidget
class HomeContent extends StatefulWidget {
  final int selectedProjectTab;
  final int selectedCategoryIndex;
  final Function(int) onProjectTabChanged;
  final Function(int) onCategoryTabChanged;

  const HomeContent({
    Key? key,
    required this.selectedProjectTab,
    required this.selectedCategoryIndex,
    required this.onProjectTabChanged,
    required this.onCategoryTabChanged,
  }) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _topBar(),
          const SizedBox(height: 20),
          _projectsTabBar(),
          const SizedBox(height: 20),
          if (widget.selectedProjectTab == 0) ...[
            _recommendedSection(),
          ] else ...[
            _currentProjectsSection(),
          ],
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://i.ibb.co/7CQVJNm/templink-logo.png',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
Get.to(() => NotificationScreen());
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
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onProjectTabChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: widget.selectedProjectTab == 0
                      ? primary
                      : Colors.transparent,
                  boxShadow: widget.selectedProjectTab == 0
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
                    "Top Talent",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: widget.selectedProjectTab == 0
                          ? Colors.white
                          : primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onProjectTabChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: widget.selectedProjectTab == 1
                      ? primary
                      : Colors.transparent,
                  boxShadow: widget.selectedProjectTab == 1
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
                    "Projects",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: widget.selectedProjectTab == 1
                          ? Colors.white
                          : primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



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
              onTap: () => {
                Get.to(() => TalentDiscoveryScreen()),
              },
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
        const SizedBox(height: 16),
        _talentCardsList(),
      ],
    );
  }

  Widget _talentCardsList() {
    final talents = [
      {
        "name": "Alex Rivera",
        "role": "FULL STACK DEVELOPER",
        "tags": ["React", "Node.js", "UI Architecture"],
        "rate": "\$85/hr",
        "rating": "5.0",
        "image": "https://randomuser.me/api/portraits/men/32.jpg",
        "bgColor": const Color(0xFFFFD6A5),
        "badge": "AVAILABLE NOW",
        "projectimage":
            "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
      },
      {
        "name": "Elena Chen",
        "role": "SENIOR PRODUCT DESIGNER",
        "tags": ["Figma", "Design Systems"],
        "rate": "\$110/hr",
        "rating": "5.0",
        "image": "https://randomuser.me/api/portraits/women/44.jpg",
        "bgColor": const Color(0xFFE5B299),
        "badge": null,
        "projectimage":
            "https://images.unsplash.com/photo-1498050108023-c5249f4df085?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MH",
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: talents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final talent = talents[index];
        return _talentCard(talent);
      },
    );
  }

  Widget _talentCard(Map<String, dynamic> talent) {
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
                  color: talent["bgColor"],
                  child: Stack(
                    children: [
                      Image.network(
                        talent["projectimage"],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(talent["image"]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (talent["badge"] != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      talent["badge"],
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
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      talent["rating"],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            talent["role"],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            talent["name"],
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
            children: (talent["tags"] as List<String>)
                .map((tag) => Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ))
                .toList(),
          ),
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
                    talent["rate"],
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
                  Get.to(() => TalentProfileScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          "Based on your skills • Sales & Product Design",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        _categoryTabs(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Featured & Urgent",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            InkWell(
              onTap: () => {
                Get.to(() => ProjectsDiscoveryScreen()),
              },
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
        _projectsList(),
      ],
    );
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
          final selected = index == widget.selectedCategoryIndex;
          return GestureDetector(
            onTap: () => widget.onCategoryTabChanged(index),
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

  Widget _projectsList() {
    final projects = [
      {
        "title": "FinTech App Redesign",
        "subtitle": "UI Design • UI Engineering Project",
        "tags": ["Figma", "React Native", "UI/UX"],
        "budget": "\$8,000 - \$12,000",
        "budgetTime": "1-3 months • Intermediate",
        "badges": ["FEATURED", "EXPIRES"],
        "badgeColors": [Colors.red, Colors.blue],
        "image":
            "https://images.unsplash.com/photo-1563986768609-322da13575f3?w-400",
        "verified": true,
        "bookmark": true,
      },
      {
        "title": "AI Content Dashboard",
        "subtitle": "Wix • Dashboard/Admin Panel",
        "tags": ["React.js", "TensorFlow", "OpenAI API"],
        "budget": "\$45 - \$75/hr",
        "budgetTime": "Less than 30 hrs/week",
        "badges": ["FEATURED"],
        "badgeColors": [
          const Color(0xFF00BCD4)
        ],
        "image":
            "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w-400",
        "verified": false,
        "bookmark": true,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final project = projects[index];
        return _projectCard(project);
      },
    );
  }

  Widget _projectCard(Map<String, dynamic> project) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  project["image"],
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    for (int i = 0; i < (project["badges"] as List).length; i++)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (project["badgeColors"] as List)[i],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (project["badges"] as List)[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (project["bookmark"] == true)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      color: Colors.black87,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project["title"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      project["subtitle"],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (project["verified"] == true) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project["budget"],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project["budgetTime"],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (project["tags"] as List<String>)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => ProjectDetailsScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
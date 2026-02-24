import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/config/api_config.dart';

class TalentProfileScreen extends StatefulWidget {
  final TalentModel talent;

  const TalentProfileScreen({
    Key? key, 
    required this.talent
  }) : super(key: key);

  @override
  State<TalentProfileScreen> createState() => _TalentProfileScreenState();
}

class _TalentProfileScreenState extends State<TalentProfileScreen> {
  bool _isBookmarked = false;

  TalentModel get talent => widget.talent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _isBookmarked ? primary : Colors.black87,
                  ),
                  onPressed: () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
          ];
        },
        body: ListView(
          children: [
            // Rate Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HOURLY RATE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        talent.hourlyRate,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (talent.badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: talent.badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: talent.badgeColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            talent.badge,
                            style: TextStyle(
                              fontSize: 12,
                              color: talent.badgeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // About Section
            if (talent.employeeProfile['bio'] != null && 
                talent.employeeProfile['bio'].toString().isNotEmpty)
              _buildSectionCard(
                title: 'About',
                icon: Icons.info_outline,
                child: Text(
                  talent.employeeProfile['bio'].toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),

            // Skills Section
            if (talent.skills.isNotEmpty)
              _buildSectionCard(
                title: 'Skills & Expertise',
                icon: Icons.stars_outlined,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: talent.skills.map((skill) {
                    return _buildSkillChip(skill);
                  }).toList(),
                ),
              ),

            // Work Experience
            if (talent.employeeProfile['workExperiences'] != null &&
                (talent.employeeProfile['workExperiences'] as List).isNotEmpty)
              _buildSectionCard(
                title: 'Work Experience',
                icon: Icons.work_outline,
                child: Column(
                  children: _buildWorkExperiences(),
                ),
              ),

            // Education
            if (talent.employeeProfile['educations'] != null &&
                (talent.employeeProfile['educations'] as List).isNotEmpty)
              _buildSectionCard(
                title: 'Education',
                icon: Icons.school_outlined,
                child: Column(
                  children: _buildEducations(),
                ),
              ),

            // Featured Projects - Static
            _buildSectionCard(
              title: 'Featured Projects',
              icon: Icons.folder_outlined,
              child: Column(
                children: _buildPortfolioItems(),
              ),
            ),

            // Reviews - Static
            _buildSectionCard(
              title: 'Client Reviews',
              icon: Icons.star_outline,
              child: Column(
                children: [
                  _buildReviewItem(
                    'Sarah Johnson',
                    'CEO at TechStart',
                    '5.0',
                    'Outstanding work! ${talent.firstName} delivered beyond expectations.',
                    'https://i.pravatar.cc/150?img=45',
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    'Michael Chen',
                    'Product Manager at InnovateCo',
                    '5.0',
                    'Great attention to detail and always meets deadlines. Highly recommended!',
                    'https://i.pravatar.cc/150?img=33',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      // Bottom Navigation Bar with Action Buttons - ✅ FIXED with working chat
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Hire Now - Future implementation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Hire Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _openChat, 
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: primary, width: 1.5),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FIXED: Working chat function
  void _openChat() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final myUserId = prefs.getString('auth_user_id') ?? '';
      final myToken = prefs.getString('auth_token') ?? '';
      final userJson = prefs.getString('auth_user');
      
      String myName = 'You';
      if (userJson != null) {
        try {
          final userData = jsonDecode(userJson);
          myName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          if (myName.isEmpty) myName = 'You';
        } catch (e) {
          myName = 'You';
        }
      }

      // Dismiss loading
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Validation
      if (myUserId.isEmpty) {
        Get.snackbar(
          'Error',
          'You are not logged in. Please login first.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (myToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Authentication failed. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (talent.id.isEmpty) {
        Get.snackbar(
          'Error',
          'Talent information is incomplete.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Navigate to Chat Screen
      print('✅ Opening chat with talent: ${talent.fullName} (ID: ${talent.id})');
      
      Get.to(() => ChatScreen(
        userName: talent.fullName,
        userOnline: false, // Will be updated by socket
        toUserId: talent.id,
        baseUrl: ApiConfig.baseUrl,
        myToken: myToken,
        myUserId: myUserId,
      ))?.then((result) {
        // Optional: Handle when returning from chat
        print('📤 Returned from chat screen');
      });

    } catch (e) {
      // Dismiss loading if showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      print('❌ Error opening chat: $e');
      Get.snackbar(
        'Error',
        'Failed to open chat: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ✅ DYNAMIC: Profile Header
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
              child: talent.photoUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(talent.photoUrl),
                    )
                  : CircleAvatar(
                      radius: 56,
                      backgroundColor: talent.bgColor,
                      child: Text(
                        talent.fullName.isNotEmpty 
                            ? talent.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Name and Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                talent.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified,
                  color: Colors.blue.shade700,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Title
          Text(
            talent.title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                talent.location,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('${talent.rating}★', 'Rating'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    talent.completedProjects.toString(), 
                    'Projects'
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('98%', 'Success'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Build Work Experiences
  List<Widget> _buildWorkExperiences() {
    final experiences = talent.employeeProfile['workExperiences'] as List? ?? [];
    final List<Widget> items = [];
    
    for (var i = 0; i < experiences.length; i++) {
      final exp = experiences[i];
      items.add(
        _buildExperienceItem(
          exp['title'] ?? 'Position',
          exp['company'] ?? 'Company',
          exp['currentlyWorking'] == true ? 'Present' : (exp['endYear'] ?? ''),
          _formatDuration(exp),
          'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
          Colors.blue.shade700,
        ),
      );
      if (i < experiences.length - 1) {
        items.add(const SizedBox(height: 20));
      }
    }
    
    return items;
  }

  // ✅ Build Education
  List<Widget> _buildEducations() {
    final educations = talent.employeeProfile['educations'] as List? ?? [];
    final List<Widget> items = [];
    
    for (var i = 0; i < educations.length; i++) {
      final edu = educations[i];
      items.add(
        _buildEducationItem(
          edu['degree'] ?? 'Degree',
          edu['school'] ?? 'School',
          edu['field'] ?? '',
          _formatEducationDuration(edu),
        ),
      );
      if (i < educations.length - 1) {
        items.add(const SizedBox(height: 20));
      }
    }
    
    return items;
  }

  // ✅ Format work experience duration
  String _formatDuration(Map<String, dynamic> exp) {
    final startYear = exp['startYear'] ?? '';
    final endYear = exp['currentlyWorking'] == true 
        ? 'Present' 
        : (exp['endYear'] ?? '');
    
    if (startYear.isEmpty) return '';
    if (endYear.isEmpty) return '$startYear';
    return '$startYear - $endYear';
  }

  // ✅ Format education duration
  String _formatEducationDuration(Map<String, dynamic> edu) {
    final startYear = edu['startYear'] ?? '';
    final endYear = edu['currentlyAttending'] == true 
        ? 'Present' 
        : (edu['endYear'] ?? '');
    
    if (startYear.isEmpty) return '';
    if (endYear.isEmpty) return '$startYear';
    return '$startYear - $endYear';
  }

  // ✅ Build Portfolio Items (Static)
  List<Widget> _buildPortfolioItems() {
    return [
      _buildPortfolioItem(
        'FinTech Mobile App',
        'Complete redesign of banking experience',
        'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=400',
      ),
      const SizedBox(height: 12),
      _buildPortfolioItem(
        'E-commerce Dashboard',
        'Admin panel with analytics integration',
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
      ),
      const SizedBox(height: 12),
      _buildPortfolioItem(
        'Health & Fitness App',
        'iOS & Android native design system',
        'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400',
      ),
    ];
  }

  // ============ STATIC/REUSABLE WIDGETS ============

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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(icon, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
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

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildExperienceItem(
    String title,
    String company,
    String type,
    String duration,
    String logoUrl,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.network(
              logoUrl,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.business, color: accentColor);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
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
    );
  }

  Widget _buildEducationItem(
    String degree,
    String school,
    String field,
    String duration,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.school, color: primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  degree,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  school,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (field.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    field,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  duration,
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
    );
  }

  Widget _buildPortfolioItem(String title, String description, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
    );
  }

  Widget _buildReviewItem(
    String name,
    String position,
    String rating,
    String review,
    String avatarUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
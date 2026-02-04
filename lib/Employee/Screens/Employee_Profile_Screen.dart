import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Screens/Employee_Edit_Profile_Screen.dart';
import 'package:templink/Utils/colors.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // Sample data that would come from user's profile
  Map<String, dynamic> userProfile = {
    'name': 'Alex Rivera',
    'title': 'SENIOR PRODUCT DESIGNER',
    'location': 'San Francisco, California',
    'hourlyRate': 85,
    'isAvailable': true,
    'about': 'Passionate Senior Product Designer with 8+ years of experience in creating scalable design systems and user-centric mobile applications. Expert in Flutter, Figma, and Agile methodologies. I love bringing ideas to life through beautiful, functional designs.',
    'skills': [
      'User Experience (UX)',
      'Flutter',
      'Dart',
      'Mobile Design',
      'System Architecture',
      'Figma',
      'Design Systems',
      'Prototyping',
    ],
  };

  // Resume data
  bool _hasResume = true;
  String _resumeName = "Alex_Rivera_Resume.pdf";
  String _resumeUploadDate = "Uploaded on Jan 15, 2024";
  double _resumeFileSize = 2.5; // MB

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
                  icon: const Icon(Icons.edit_outlined, color: Colors.black87),
                  onPressed: () {
                    Get.to(() => const EditProfileScreen());
                  },
                  tooltip: 'Edit Profile',
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                  onPressed: () {
                    // Navigate to settings
                  },
                  tooltip: 'Settings',
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
            // Hourly Rate & Availability Card
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
                        "\$${userProfile['hourlyRate']}/hr",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: userProfile['isAvailable']
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          userProfile['isAvailable']
                              ? Icons.check_circle
                              : Icons.do_not_disturb,
                          color: userProfile['isAvailable']
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          userProfile['isAvailable']
                              ? 'Available Now'
                              : 'Not Available',
                          style: TextStyle(
                            fontSize: 12,
                            color: userProfile['isAvailable']
                                ? Colors.green.shade700
                                : Colors.red.shade700,
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
            _buildSectionCard(
              title: 'About',
              icon: Icons.info_outline,
              child: Text(
                userProfile['about'],
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),

            // Skills & Expertise Section
            _buildSectionCard(
              title: 'Skills & Expertise',
              icon: Icons.stars_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var skill in userProfile['skills'])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Resume Section
            _buildSectionCard(
              title: 'Resume',
              icon: Icons.description_outlined,
              child: Column(
                children: [
                  if (_hasResume)
                    _buildResumeItem()
                  else
                    _buildNoResumePlaceholder(),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _viewResume();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('View Resume'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => const EditProfileScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                          label: const Text('Update'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Work Experience Section
            _buildSectionCard(
              title: 'Work Experience',
              icon: Icons.work_outline,
              child: Column(
                children: [
                  _buildExperienceItem(
                    'Senior Product Designer',
                    'Google',
                    'Full-time',
                    'Jan 2021 - Present • 3 yrs',
                    'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                    Colors.blue.shade700,
                  ),
                  const SizedBox(height: 20),
                  _buildExperienceItem(
                    'UI/UX Designer',
                    'Airbnb',
                    'Contract',
                    'Jun 2018 - Dec 2020 • 2 yrs 6 mos',
                    'https://cdn-icons-png.flaticon.com/512/2111/2111307.png',
                    Colors.pink.shade400,
                  ),
                ],
              ),
            ),

            // Featured Projects Section
            _buildSectionCard(
              title: 'Featured Projects',
              icon: Icons.folder_outlined,
              child: Column(
                children: [
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
                ],
              ),
            ),

            // Reviews Section
            _buildSectionCard(
              title: 'Client Reviews',
              icon: Icons.star_outline,
              child: Column(
                children: [
                  _buildReviewItem(
                    'Sarah Johnson',
                    'CEO at TechStart',
                    '5.0',
                    'Outstanding work! Alex delivered beyond expectations. The design was pixel-perfect and the communication was excellent throughout.',
                    'https://i.pravatar.cc/150?img=45',
                  ),
                ],
              ),
            ),

            // Profile Analytics Section
            _buildSectionCard(
              title: 'Profile Analytics',
              icon: Icons.analytics_outlined,
              child: Column(
                children: [
                  // First row of stats
                  Row(
                    children: [
                      Expanded(child: _buildStatItem(
                        icon: Icons.remove_red_eye,
                        value: '1,247',
                        label: 'Profile Views',
                        color: Colors.blue.shade600,
                      )),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(child: _buildStatItem(
                        icon: Icons.work_outline,
                        value: '24',
                        label: 'Hire Requests',
                        color: Colors.green.shade600,
                      )),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(child: _buildStatItem(
                        icon: Icons.message_outlined,
                        value: '156',
                        label: 'Messages',
                        color: Colors.orange.shade600,
                      )),
                    ],
                  ),
                  
                  // Divider
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  
                  // Second row of stats
                  Row(
                    children: [
                      Expanded(child: _buildStatItem(
                        icon: Icons.check_circle_outline,
                        value: '42',
                        label: 'Completed Jobs',
                        color: Colors.purple.shade600,
                      )),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(child: _buildStatItem(
                        icon: Icons.timer_outlined,
                        value: '98%',
                        label: 'Response Rate',
                        color: Colors.teal.shade600,
                      )),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(child: _buildStatItem(
                        icon: Icons.star_outline,
                        value: '4.9',
                        suffix: '★',
                        label: 'Avg. Rating',
                        color: Colors.amber.shade700,
                      )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        children: [
          // Profile Image with Edit Button
          Stack(
            children: [
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
                  child: const CircleAvatar(
                    radius: 56,
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300?img=11'),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _changeProfilePicture(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Name and Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userProfile['name'],
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
          
          // Professional Title
          Text(
            userProfile['title'],
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
                userProfile['location'],
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
                  child: _buildStatCard('4.9★', 'Rating'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('42', 'Jobs'),
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

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String suffix = '',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Icon with background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          
          // Value with optional suffix
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // PDF Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resumeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _resumeUploadDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_resumeFileSize} MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Download Icon
          IconButton(
            onPressed: () {
              _downloadResume();
            },
            icon: const Icon(
              Icons.download_outlined,
              color: primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResumePlaceholder() {
    return Container(
      padding:  EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No resume uploaded',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your resume to increase hire chances',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
                  '$company • $type',
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

  // Action Methods
  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black87),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement camera functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement gallery picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement remove photo
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _viewResume() {
    // Implement PDF viewing logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View Resume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'This would open a PDF viewer for:',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _resumeName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open PDF viewer
              _showSnackbar('Opening resume...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _downloadResume() {
    // Implement download logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Downloading resume...'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProfile() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile link copied to clipboard'),
      ),
    );
  }
}
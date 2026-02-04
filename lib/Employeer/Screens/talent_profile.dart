import 'package:flutter/material.dart';
import 'package:templink/Utils/colors.dart';

class TalentProfileScreen extends StatefulWidget {
  const TalentProfileScreen({Key? key}) : super(key: key);

  @override
  State<TalentProfileScreen> createState() => _TalentProfileScreenState();
}

class _TalentProfileScreenState extends State<TalentProfileScreen> {
  bool _isBookmarked = false;

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
                      const Text(
                        "\$85/hr",
                        style: TextStyle(
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
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Available Now',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
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
              child: const Text(
                "Passionate Senior Product Designer with 8+ years of experience in creating scalable design systems and user-centric mobile applications. Expert in Flutter, Figma, and Agile methodologies. I love bringing ideas to life through beautiful, functional designs.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),

            _buildSectionCard(
              title: 'Skills & Expertise',
              icon: Icons.stars_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSkillChip('User Experience (UX)'),
                  _buildSkillChip('Flutter'),
                  _buildSkillChip('Dart'),
                  _buildSkillChip('Mobile Design'),
                  _buildSkillChip('System Architecture'),
                  _buildSkillChip('Figma'),
                  _buildSkillChip('Design Systems'),
                  _buildSkillChip('Prototyping'),
                ],
              ),
            ),

            // Experience Section
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
                  const SizedBox(height: 20),
                  _buildExperienceItem(
                    'Product Designer',
                    'Spotify',
                    'Full-time',
                    'Jan 2016 - May 2018 • 2 yrs 4 mos',
                    'https://cdn-icons-png.flaticon.com/512/174/174872.png',
                    Colors.green.shade600,
                  ),
                ],
              ),
            ),

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
                  const SizedBox(height: 12),
                  _buildPortfolioItem(
                    'Health & Fitness App',
                    'iOS & Android native design system',
                    'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400',
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
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    'Michael Chen',
                    'Product Manager at InnovateCo',
                    '5.0',
                    'Alex is a true professional. Great attention to detail and always meets deadlines. Highly recommended!',
                    'https://i.pravatar.cc/150?img=33',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      // Bottom Navigation Bar with Action Buttons
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
                  onPressed: () {},
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
                  onPressed: () {},
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

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          // Profile Image with Shadow
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
          const SizedBox(height: 20),
          // Name and Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Alex Rivera",
                style: TextStyle(
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
            "SENIOR PRODUCT DESIGNER",
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
                "San Francisco, California",
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
                  child: _buildStatCard('127', 'Projects'),
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
}
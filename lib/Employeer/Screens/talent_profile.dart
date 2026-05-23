import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Employeer/widgets/hire_request_form.dart';
import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/config/api_config.dart';

// Design Tokens
const _bg = Color(0xFFF5F7FA);
const _surface = Colors.white;
const _border = Color(0xFFE5E7EB);
const _text1 = Color(0xFF111827);
const _text2 = Color(0xFF6B7280);
const _text3 = Color(0xFF9CA3AF);
const _green = Color(0xFF16A34A);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFDC2626);
const _blue = Color(0xFF3B82F6);
const _r = 12.0;

class TalentProfileScreen extends StatefulWidget {
  final TalentModel talent;
  final bool showSidebar;
  final VoidCallback? onBackPressed;

  const TalentProfileScreen({
    Key? key, 
    required this.talent,
    this.showSidebar = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<TalentProfileScreen> createState() => _TalentProfileScreenState();
}

class _TalentProfileScreenState extends State<TalentProfileScreen> {
  bool _isBookmarked = false;
  bool _isSendingRequest = false;
  final showProjectsDiscovery = false.obs;


  TalentModel get talent => widget.talent;

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

  // ==================== WEB LAYOUT ====================
  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: widget.showSidebar ? null : null,
      body: Column(
        children: [
          if (!widget.showSidebar) _buildWebAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column - Profile Info
                  Expanded(
                    flex: 1,
                    child: _buildLeftColumn(),
                  ),
                  const SizedBox(width: 24),
                  // Right Column - Details
                  Expanded(
                    flex: 2,
                    child: _buildRightColumn(),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(isWeb: true),
        ],
      ),
    );
  }

  Widget _buildWebAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: _surface,
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
          InkWell(
            onTap: widget.onBackPressed ?? () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, size: 18, color: _text2),
                  const SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontSize: 13, color: _text2)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            talent.fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _text1,
            ),
          ),
          const Spacer(),
          _buildActionButton(
            icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              _toggleBookmark();
            },
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            onPressed: _shareProfile,
          ),
          _buildActionButton(
            icon: Icons.more_vert,
            onPressed: _showMoreOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: _text2, size: 20),
      onPressed: onPressed,
    );
  }

  // ==================== LEFT COLUMN ====================
  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildProfileCard(),
        const SizedBox(height: 20),
        _buildRateCard(),
        const SizedBox(height: 20),
        if (talent.bio.isNotEmpty) _buildAboutCard(),
        const SizedBox(height: 20),
        if (talent.skills.isNotEmpty) _buildSkillsCard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _border, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: talent.photoUrl.isNotEmpty
                  ? Image.network(
                      talent.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  talent.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _text1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified, color: _blue, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            talent.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 12, color: _text3),
              const SizedBox(width: 4),
              Text(
                talent.location,
                style: TextStyle(fontSize: 11, color: _text2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Stats Row
          Row(
            children: [
              _buildStatItem(talent.ratingDisplay, 'Rating', _amber),
              _buildStatItem(talent.completedProjects.toString(), 'Projects', _blue),
              _buildStatItem('98%', 'Success', _green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(
              value.isEmpty ? '0' : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: _text3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: primary.withOpacity(0.1),
      child: Center(
        child: Text(
          talent.fullName.isNotEmpty ? talent.fullName[0].toUpperCase() : '?',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
        ),
      ),
    );
  }

  Widget _buildRateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _text3),
              ),
              const SizedBox(height: 4),
              Text(
                talent.hourlyRateDisplay.isEmpty ? 'Rate not set' : talent.hourlyRateDisplay,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _text1),
              ),
            ],
          ),
          if (talent.availabilityBadge.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: talent.availabilityBadgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: talent.availabilityBadgeColor, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    talent.availabilityBadge,
                    style: TextStyle(
                      fontSize: 10,
                      color: talent.availabilityBadgeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
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
              Icon(Icons.info_outline, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text(
                'About',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            talent.bio,
            style: TextStyle(fontSize: 13, color: _text2, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
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
              Icon(Icons.stars_outlined, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text(
                'Skills & Expertise',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: talent.skills.map((skill) => _buildSkillChip(skill)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w500),
      ),
    );
  }

  // ==================== RIGHT COLUMN ====================
  Widget _buildRightColumn() {
    return Column(
      children: [
        if (talent.workExperiences.isNotEmpty) _buildWorkExperienceCard(),
        if (talent.workExperiences.isNotEmpty) const SizedBox(height: 20),
        if (talent.educations.isNotEmpty) _buildEducationCard(),
        if (talent.educations.isNotEmpty) const SizedBox(height: 20),
        if (talent.portfolioProjects.isNotEmpty) _buildPortfolioCard(),
        if (talent.portfolioProjects.isNotEmpty) const SizedBox(height: 20),
        _buildReviewsCard(),
      ],
    );
  }

  Widget _buildWorkExperienceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
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
              Icon(Icons.work_outline, size: 18, color: primary),
              const SizedBox(width: 10),
              const Text(
                'Work Experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...talent.workExperiences.map((exp) => _buildExperienceItem(exp)),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(WorkExperience exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1),
                ),
                const SizedBox(height: 2),
                Text(
                  exp.company,
                  style: TextStyle(fontSize: 12, color: _text2),
                ),
                const SizedBox(height: 2),
                Text(
                  exp.duration,
                  style: TextStyle(fontSize: 11, color: _text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
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
              Icon(Icons.school_outlined, size: 18, color: primary),
              const SizedBox(width: 10),
              const Text(
                'Education',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...talent.educations.map((edu) => _buildEducationItem(edu)),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Education edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.degree,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1),
                ),
                const SizedBox(height: 2),
                Text(
                  edu.school,
                  style: TextStyle(fontSize: 12, color: _text2),
                ),
                if (edu.field.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    edu.field,
                    style: TextStyle(fontSize: 11, color: _text2),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  edu.duration,
                  style: TextStyle(fontSize: 11, color: _text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
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
              Icon(Icons.folder_outlined, size: 18, color: primary),
              const SizedBox(width: 10),
              const Text(
                'Portfolio Projects',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...talent.portfolioProjects.map((project) => _buildPortfolioItem(project)),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(PortfolioProject project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: project.imageUrl.isNotEmpty
                ? Image.network(
                    project.imageUrl,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: _text3),
                      ),
                    ),
                  )
                : Container(
                    height: 140,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: _text3),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1),
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: TextStyle(fontSize: 12, color: _text2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
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
              Icon(Icons.star_outline, size: 18, color: primary),
              const SizedBox(width: 10),
              const Text(
                'Client Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            'Sarah Johnson',
            'CEO at TechStart',
            'Outstanding work! ${talent.firstName} delivered beyond expectations.',
            'https://i.pravatar.cc/150?img=45',
          ),
          const SizedBox(height: 16),
          _buildReviewItem(
            'Michael Chen',
            'Product Manager at InnovateCo',
            'Great attention to detail and always meets deadlines. Highly recommended!',
            'https://i.pravatar.cc/150?img=33',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String position, String review, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _text1),
                    ),
                    Text(
                      position,
                      style: TextStyle(fontSize: 11, color: _text2),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: _amber, size: 10),
                    const SizedBox(width: 3),
                    Text(
                      talent.ratingDisplay.isEmpty ? '5.0' : talent.ratingDisplay,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _amber),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: TextStyle(fontSize: 12, color: _text2, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM BAR ====================
  Widget _buildBottomBar({required bool isWeb}) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isWeb ? 14 : 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
    );

    final outlineStyle = OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: isWeb ? 14 : 16, horizontal: 24),
      side: BorderSide(color: primary, width: 1.5),
      foregroundColor: primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    if (isWeb) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isSendingRequest ? null : _showHireRequestForm,
                style: buttonStyle,
                child: _isSendingRequest
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Hire Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: _openChat,
                style: outlineStyle,
                child: const Text('Message', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSendingRequest ? null : _showHireRequestForm,
                  style: buttonStyle,
                  child: _isSendingRequest
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Hire Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _openChat,
                  style: outlineStyle,
                  child: const Text('Message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _text1),
          onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
        ),
        title: Text(
          talent.fullName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text1),
        ),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _text2),
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              _toggleBookmark();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: _text2),
            onPressed: _shareProfile,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: _text2),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMobileProfileHeader(),
            const SizedBox(height: 16),
            _buildMobileRateCard(),
            const SizedBox(height: 16),
            if (talent.bio.isNotEmpty) _buildMobileAboutCard(),
            if (talent.bio.isNotEmpty) const SizedBox(height: 16),
            if (talent.skills.isNotEmpty) _buildMobileSkillsCard(),
            if (talent.skills.isNotEmpty) const SizedBox(height: 16),
            if (talent.workExperiences.isNotEmpty) _buildMobileWorkCard(),
            if (talent.workExperiences.isNotEmpty) const SizedBox(height: 16),
            if (talent.educations.isNotEmpty) _buildMobileEducationCard(),
            if (talent.educations.isNotEmpty) const SizedBox(height: 16),
            if (talent.portfolioProjects.isNotEmpty) _buildMobilePortfolioCard(),
            if (talent.portfolioProjects.isNotEmpty) const SizedBox(height: 16),
            _buildMobileReviewsCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isWeb: false),
    );
  }

  Widget _buildMobileProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _border, width: 2),
            ),
            child: ClipOval(
              child: talent.photoUrl.isNotEmpty
                  ? Image.network(talent.photoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildMobileDefaultAvatar())
                  : _buildMobileDefaultAvatar(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(talent.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
              const SizedBox(width: 4),
              Icon(Icons.verified, color: _blue, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(talent.title, style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 12, color: _text3),
              const SizedBox(width: 4),
              Text(talent.location, style: TextStyle(fontSize: 11, color: _text2)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMobileStatItem(talent.ratingDisplay, 'Rating', _amber),
              _buildMobileStatItem(talent.completedProjects.toString(), 'Projects', _blue),
              _buildMobileStatItem('98%', 'Success', _green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDefaultAvatar() {
    return Container(
      color: primary.withOpacity(0.1),
      child: Center(
        child: Text(
          talent.fullName.isNotEmpty ? talent.fullName[0].toUpperCase() : '?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
        ),
      ),
    );
  }

  Widget _buildMobileStatItem(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value.isEmpty ? '0' : value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: _text3)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileRateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("HOURLY RATE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _text3)),
              Text(talent.hourlyRateDisplay.isEmpty ? 'Rate not set' : talent.hourlyRateDisplay,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
          if (talent.availabilityBadge.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: talent.availabilityBadgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: talent.availabilityBadgeColor, size: 12),
                  const SizedBox(width: 4),
                  Text(talent.availabilityBadge, style: TextStyle(fontSize: 10, color: talent.availabilityBadgeColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text('About', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(talent.bio, style: TextStyle(fontSize: 12, color: _text2, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildMobileSkillsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_outlined, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text('Skills & Expertise', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: talent.skills.map((skill) => _buildMobileSkillChip(skill)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildMobileWorkCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text('Work Experience', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
          const SizedBox(height: 12),
          ...talent.workExperiences.map((exp) => _buildMobileExperienceItem(exp)),
        ],
      ),
    );
  }

  Widget _buildMobileExperienceItem(WorkExperience exp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _text1)),
                Text(exp.company, style: TextStyle(fontSize: 11, color: _text2)),
                Text(exp.duration, style: TextStyle(fontSize: 10, color: _text3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileEducationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text('Education', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
          const SizedBox(height: 12),
          ...talent.educations.map((edu) => _buildMobileEducationItem(edu)),
        ],
      ),
    );
  }

  Widget _buildMobileEducationItem(Education edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school, color: primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.degree, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _text1)),
                Text(edu.school, style: TextStyle(fontSize: 11, color: _text2)),
                Text(edu.duration, style: TextStyle(fontSize: 10, color: _text3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePortfolioCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text('Portfolio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
          const SizedBox(height: 12),
          ...talent.portfolioProjects.map((project) => _buildMobilePortfolioItem(project)),
        ],
      ),
    );
  }

  Widget _buildMobilePortfolioItem(PortfolioProject project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: project.imageUrl.isNotEmpty
                ? Image.network(project.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image, size: 30, color: _text3))))
                : Container(height: 120, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image, size: 30, color: _text3))),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _text1)),
                const SizedBox(height: 2),
                Text(project.description, style: TextStyle(fontSize: 11, color: _text2), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileReviewsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, size: 16, color: primary),
              const SizedBox(width: 8),
              const Text('Client Reviews', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
          const SizedBox(height: 12),
          _buildMobileReviewItem('Sarah Johnson', 'CEO at TechStart', 'Outstanding work! ${talent.firstName} delivered beyond expectations.', 'https://i.pravatar.cc/150?img=45'),
          const SizedBox(height: 12),
          _buildMobileReviewItem('Michael Chen', 'Product Manager at InnovateCo', 'Great attention to detail and always meets deadlines!', 'https://i.pravatar.cc/150?img=33'),
        ],
      ),
    );
  }

  Widget _buildMobileReviewItem(String name, String position, String review, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _text1)),
                    Text(position, style: TextStyle(fontSize: 10, color: _text2)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: _amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.star, color: _amber, size: 8),
                    const SizedBox(width: 2),
                    Text(talent.ratingDisplay.isEmpty ? '5.0' : talent.ratingDisplay, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _amber)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(review, style: TextStyle(fontSize: 11, color: _text2, height: 1.4)),
        ],
      ),
    );
  }

  // ==================== ACTION METHODS ====================
  void _showHireRequestForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => HireRequestForm(talent: talent, onSubmit: _sendHireRequest),
    );
  }

  Future<void> _sendHireRequest(Map<String, dynamic> requestData) async {
    setState(() => _isSendingRequest = true);
    try {
      Navigator.pop(context);
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/interest/send'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      if (Get.isDialogOpen ?? false) Get.back();
      if (response.statusCode == 201) {
        Get.snackbar('✅ Success!', 'Interest request sent to ${talent.firstName}',
            backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send request');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('❌ Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isSendingRequest = false);
    }
  }

  Future<void> _toggleBookmark() async => print('Bookmark toggled: $_isBookmarked');
  void _shareProfile() => print('Sharing profile');
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.flag_outlined), title: const Text('Report Talent'), onTap: () { Navigator.pop(context); _showReportDialog(); }),
            ListTile(leading: const Icon(Icons.block_outlined), title: const Text('Block Talent'), onTap: () { Navigator.pop(context); _showBlockConfirmation(); }),
          ],
        ),
      ),
    );
  }
  void _showReportDialog() => Get.snackbar('Report', 'Report feature coming soon', backgroundColor: Colors.orange, colorText: Colors.white);
  void _showBlockConfirmation() {
    Get.dialog(AlertDialog(
      title: const Text('Block Talent'),
      content: Text('Are you sure you want to block ${talent.fullName}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(context); Get.snackbar('Blocked', '${talent.fullName} has been blocked', backgroundColor: Colors.red, colorText: Colors.white); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Block')),
      ],
    ));
  }

  void _openChat() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
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
        } catch (e) { myName = 'You'; }
      }
      if (Get.isDialogOpen ?? false) Get.back();
      if (myUserId.isEmpty) { Get.snackbar('Error', 'You are not logged in. Please login first.', backgroundColor: Colors.red, colorText: Colors.white); return; }
      if (myToken.isEmpty) { Get.snackbar('Error', 'Authentication failed. Please login again.', backgroundColor: Colors.red, colorText: Colors.white); return; }
      if (talent.id.isEmpty) { Get.snackbar('Error', 'Talent information is incomplete.', backgroundColor: Colors.red, colorText: Colors.white); return; }
      Get.to(() => ChatScreen(userName: talent.fullName, userOnline: false, toUserId: talent.id, baseUrl: ApiConfig.baseUrl, myToken: myToken, myUserId: myUserId));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Failed to open chat: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
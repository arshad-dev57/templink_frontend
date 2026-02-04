import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:templink/Utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  
  // Form controllers for work experience
  final TextEditingController _expCompanyController = TextEditingController();
  final TextEditingController _expRoleController = TextEditingController();
  final TextEditingController _expStartController = TextEditingController();
  final TextEditingController _expEndController = TextEditingController();
  final TextEditingController _expDescController = TextEditingController();
  
  // Skills list
  List<String> _skills = [
    'User Experience (UX)',
    'Flutter',
    'Dart',
    'Mobile Design',
    'System Architecture',
    'Figma',
    'Design Systems',
    'Prototyping',
  ];
  
  // Resume data
  bool _hasResume = false;
  String _resumeName = "";
  String _resumeUploadDate = "";
  double _resumeFileSize = 0.0;
  File? _selectedResumeFile;
  String? _resumeFilePath;
  bool _isUploading = false;
  
  bool _isAvailable = true;
  bool _showInSearch = true;
  bool _availableFreelance = true;
  bool _availableFullTime = false;
  
  @override
  void initState() {
    super.initState();
    _nameController.text = "Alex Rivera";
    _titleController.text = "SENIOR PRODUCT DESIGNER";
    _locationController.text = "San Francisco, California";
    _hourlyRateController.text = "85";
    _aboutController.text = "Passionate Senior Product Designer with 8+ years of experience in creating scalable design systems and user-centric mobile applications. Expert in Flutter, Figma, and Agile methodologies. I love bringing ideas to life through beautiful, functional designs.";
    _expCompanyController.text = "Google";
    _expRoleController.text = "Senior Product Designer";
    _expStartController.text = "Jan 2021";
    _expEndController.text = "Present";
    _websiteController.text = "https://alexrivera.design";
    _linkedinController.text = "https://linkedin.com/in/alexrivera";
    
    // Load existing resume if any (from local storage or backend)
    _loadExistingResume();
  }
  
  void _loadExistingResume() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final resumeFile = File('${directory.path}/resume.pdf');
      
      if (await resumeFile.exists()) {
        final stats = await resumeFile.stat();
        setState(() {
          _hasResume = true;
          _resumeName = "My_Resume.pdf";
          _resumeFilePath = resumeFile.path;
          _resumeUploadDate = "Uploaded on ${_formatDate(stats.modified)}";
          _resumeFileSize = stats.size / (1024 * 1024); // Convert to MB
          _selectedResumeFile = resumeFile;
        });
      }
    } catch (e) {
      print('Error loading resume: $e');
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _hourlyRateController.dispose();
    _aboutController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _expCompanyController.dispose();
    _expRoleController.dispose();
    _expStartController.dispose();
    _expEndController.dispose();
    _expDescController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            style: TextButton.styleFrom(
              foregroundColor: primary,
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  // Profile Image with Edit Button
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(46),
                          child: const CircleAvatar(
                            radius: 46,
                            backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/300?img=11'),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _changeProfilePicture,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Title Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primary,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'PROFESSIONAL TITLE',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Location Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _locationController,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Location',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Hourly Rate Section
            _buildSection(
              title: 'Hourly Rate & Availability',
              icon: Icons.attach_money_outlined,
              child: Column(
                children: [
                  // Hourly Rate
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Hourly Rate',
                        prefixText: '\$',
                        suffixText: '/hr',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      _buildAvailabilityChip('Available', _isAvailable, Colors.green),
                      const SizedBox(width: 8),
                      _buildAvailabilityChip('Not Available', !_isAvailable, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            
            _buildSection(
              title: 'About',
              icon: Icons.info_outline,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _aboutController,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                    hintText: 'Tell us about yourself...',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
            
            _buildSection(
              title: 'Skills & Expertise',
              icon: Icons.stars_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skills Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _skills.remove(skill);
                          });
                        },
                        backgroundColor: primary.withOpacity(0.1),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: primary,
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                                    Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(16),
                              border: InputBorder.none,
                              hintText: 'Add new skill...',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                            ),
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty && !_skills.contains(value)) {
                                setState(() {
                                  _skills.add(value);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Add skill logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _buildSection(
              title: 'Resume',
              icon: Icons.description_outlined,
              child: Column(
                children: [
                  _buildCurrentResumeInfo(),
                  
                  const SizedBox(height: 20),
                  
                  // Upload Button
                  if (_isUploading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _uploadResume,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text(
                          'Upload Resume (PDF)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Upload a PDF file (max 5MB) for best compatibility',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Work Experience Section
            _buildSection(
              title: 'Work Experience',
              icon: Icons.work_outline,
              child: Column(
                children: [
                  // Company
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _expCompanyController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Company',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Role
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _expRoleController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Role/Position',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _expStartController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                              hintText: 'Start Date',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _expEndController,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                              hintText: 'End Date (or Present)',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _expDescController,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Description',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Add Another Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Add another experience
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add Another Experience',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Portfolio Section
            _buildSection(
              title: 'Portfolio Projects',
              icon: Icons.folder_outlined,
              child: Column(
                children: [
                  _buildPortfolioItem(
                    title: 'FinTech Mobile App',
                    description: 'Complete redesign of banking experience',
                  ),
                  const SizedBox(height: 12),
                  _buildPortfolioItem(
                    title: 'E-commerce Dashboard',
                    description: 'Admin panel with analytics integration',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Add project
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add Project',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Additional Info Section
            _buildSection(
              title: 'Additional Information',
              icon: Icons.more_horiz,
              child: Column(
                children: [
                  // Toggles
                  _buildToggleItem(
                    title: 'Show in search results',
                    subtitle: 'Make your profile visible to employers',
                    value: _showInSearch,
                    onChanged: (value) {
                      setState(() {
                        _showInSearch = value!;
                      });
                    },
                  ),
                  _buildToggleItem(
                    title: 'Available for freelance work',
                    value: _availableFreelance,
                    onChanged: (value) {
                      setState(() {
                        _availableFreelance = value!;
                      });
                    },
                  ),
                  _buildToggleItem(
                    title: 'Available for full-time positions',
                    value: _availableFullTime,
                    onChanged: (value) {
                      setState(() {
                        _availableFullTime = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Website
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _websiteController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'Website/Portfolio URL',
                        prefixIcon: Icon(Icons.link, size: 20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // LinkedIn
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _linkedinController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none,
                        hintText: 'LinkedIn Profile',
                        prefixIcon: Icon(Icons.link, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      
      // Save Button at Bottom
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Changes',
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
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
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
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Section Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Section Content
          child,
        ],
      ),
    );
  }

  Widget _buildCurrentResumeInfo() {
    if (!_hasResume) {
      return Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 12),
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
                Text(
                  '$_resumeUploadDate • ${_resumeFileSize.toStringAsFixed(2)} MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            onSelected: (value) {
              if (value == 'view') {
                _viewResume();
              } else if (value == 'download') {
                _downloadResume();
              } else if (value == 'remove') {
                _removeResume();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('View'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Remove', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Resume Methods with Real Logic
  void _uploadResume() async {
    // Check storage permission
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        _showErrorSnackbar('Storage permission is required to upload resume');
        return;
      }
    }
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        
        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _showErrorSnackbar('File size must be less than 5MB');
          return;
        }
        
        // Show loading
        setState(() {
          _isUploading = true;
        });
        
        // Save file locally
        final directory = await getApplicationDocumentsDirectory();
        final savedFile = File('${directory.path}/${file.name}');
        
        if (file.bytes != null) {
          await savedFile.writeAsBytes(file.bytes!);
        } else if (file.path != null) {
          File localFile = File(file.path!);
          await localFile.copy(savedFile.path);
        }
        
        // Update state
        setState(() {
          _hasResume = true;
          _resumeName = file.name;
          _resumeFilePath = savedFile.path;
          _resumeUploadDate = "Uploaded on ${_formatDate(DateTime.now())}";
          _resumeFileSize = file.size / (1024 * 1024);
          _selectedResumeFile = savedFile;
          _isUploading = false;
        });
        
        _showSuccessSnackbar('Resume uploaded successfully!');
        
        // TODO: Upload to your backend API here
        // await _uploadToBackend(savedFile, file.name);
        
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackbar('Error uploading resume: ${e.toString()}');
    }
  }

  void _viewResume() {
    if (_resumeFilePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            filePath: _resumeFilePath!,
            fileName: _resumeName,
          ),
        ),
      );
    } else {
      _showErrorSnackbar('Resume file not found');
    }
  }

  void _downloadResume() async {
    if (_selectedResumeFile == null || !await _selectedResumeFile!.exists()) {
      _showErrorSnackbar('Resume file not found');
      return;
    }
    
    final result = await OpenFile.open(_selectedResumeFile!.path);
    
    // if (result.type == OpenResultType.success) {
    //   _showSuccessSnackbar('Resume opened successfully');
    // } else {
    //   _showErrorSnackbar('Failed to open resume: ${result.message}');
    // }
  }

  void _removeResume() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Resume'),
        content: const Text('Are you sure you want to remove your resume?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                if (_selectedResumeFile != null && await _selectedResumeFile!.exists()) {
                  await _selectedResumeFile!.delete();
                }
                
                setState(() {
                  _hasResume = false;
                  _resumeName = "";
                  _resumeUploadDate = "";
                  _resumeFileSize = 0.0;
                  _selectedResumeFile = null;
                  _resumeFilePath = null;
                });
                
                _showSuccessSnackbar('Resume removed successfully');
              } catch (e) {
                _showErrorSnackbar('Error removing resume: ${e.toString()}');
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Rest of your existing methods...
  Widget _buildPortfolioItem({
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.photo_library, color: Colors.grey, size: 28),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Project Title',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  TextFormField(
                    initialValue: description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Project Description',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Delete project
            },
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: primary,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAvailabilityChip(String label, bool selected, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAvailable = label == 'Available';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : Colors.grey.shade400,
                  width: 1,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.black87),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() {
    _showSuccessSnackbar('Profile saved successfully!');
    Navigator.pop(context);
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PdfViewerScreen({
    Key? key,
    required this.filePath,
    required this.fileName,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final result = await OpenFile.open(widget.filePath);
              // if (result.type != OpenResultType.success) {
              //   Get.snackbar(
              //     'Error',
              //     'Could not open file',
              //     backgroundColor: Colors.red,
              //     colorText: Colors.white,
              //   );
              // }
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage ?? 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading PDF',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData && pages != null && pages! > 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Page ${(currentPage ?? 0) + 1} of $pages',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'next',
                  child: const Icon(Icons.chevron_right),
                  onPressed: () {
                    if (currentPage! < pages! - 1) {
                      snapshot.data!.setPage(currentPage! + 1);
                    }
                  },
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'prev',
                  child: const Icon(Icons.chevron_left),
                  onPressed: () {
                    if (currentPage! > 0) {
                      snapshot.data!.setPage(currentPage! - 1);
                    }
                  },
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
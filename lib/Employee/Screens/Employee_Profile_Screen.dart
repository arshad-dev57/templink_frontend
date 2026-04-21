import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:templink/Employee/Controllers/Employee_Profile_Controller.dart';
import 'package:templink/Employee/Screens/Employee_Edit_Profile_Screen.dart';
import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
import 'package:templink/Utils/colors.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final EmployeeProfileController controller = Get.put(EmployeeProfileController());
  final ResumeController resumeController = Get.put(ResumeController());

  // Portfolio Add/Edit State
  bool _isPortfolioDialogOpen = false;
  final TextEditingController _portfolioTitleController = TextEditingController();
  final TextEditingController _portfolioDescriptionController = TextEditingController();
  final List<File> _selectedPortfolioImages = [];
  final List<Map<String, dynamic>> _existingPortfolioImages = [];
  String? _editingPortfolioId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resumeController.fetchUserResumes();
    });
  }

  @override
  void dispose() {
    _portfolioTitleController.dispose();
    _portfolioDescriptionController.dispose();
    super.dispose();
  }

  // ==================== PORTFOLIO METHODS ====================
  void _openAddPortfolioDialog() {
    _portfolioTitleController.clear();
    _portfolioDescriptionController.clear();
    _selectedPortfolioImages.clear();
    _existingPortfolioImages.clear();
    _editingPortfolioId = null;
    _isPortfolioDialogOpen = true;
    _showPortfolioDialog();
  }

  void _openEditPortfolioDialog(Map<String, dynamic> project) {
    _portfolioTitleController.text = project['title'] ?? '';
    _portfolioDescriptionController.text = project['description'] ?? '';
    _selectedPortfolioImages.clear();
    _existingPortfolioImages.clear();
    _editingPortfolioId = project['_id'];
    
    // Load existing images
    if (project['images'] != null && project['images'] is List) {
      for (var img in project['images']) {
        _existingPortfolioImages.add({
          'url': img['url'],
          'fileName': img['fileName'],
          'publicId': img['publicId'],
        });
      }
    } else if (project['imageUrl'] != null && project['imageUrl'].isNotEmpty) {
      // Backward compatibility
      _existingPortfolioImages.add({
        'url': project['imageUrl'],
        'fileName': '',
        'publicId': '',
      });
    }
    
    _isPortfolioDialogOpen = true;
    _showPortfolioDialog();
  }

  Future<void> _pickPortfolioImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    
    if (result != null) {
      setState(() {
        _selectedPortfolioImages.addAll(result.files.map((f) => File(f.path!)));
      });
    }
  }

  void _removeSelectedPortfolioImage(int index) {
    setState(() {
      _selectedPortfolioImages.removeAt(index);
    });
  }

  void _removeExistingPortfolioImage(int index) {
    setState(() {
      _existingPortfolioImages.removeAt(index);
    });
  }

  Future<void> _savePortfolio() async {
    if (_portfolioTitleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter project title');
      return;
    }

    bool success;
    
    if (_editingPortfolioId != null) {
      // Update existing project
      success = await controller.updatePortfolioProject(
        projectId: _editingPortfolioId!,
        title: _portfolioTitleController.text,
        description: _portfolioDescriptionController.text,
        newImagePaths: _selectedPortfolioImages.map((f) => f.path).toList(),
        existingImages: _existingPortfolioImages,
      );
    } else {
      // Add new project
      success = await controller.addPortfolioProject(
        title: _portfolioTitleController.text,
        description: _portfolioDescriptionController.text,
        imagePaths: _selectedPortfolioImages.map((f) => f.path).toList(),
      );
    }

    if (success) {
      Navigator.pop(context); // Close dialog
      await controller.fetchProfile(); // Refresh data
    }
  }

  void _showDeletePortfolioDialog(String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Portfolio Project'),
        content: const Text('Are you sure you want to delete this portfolio project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deletePortfolioProject(projectId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPortfolioDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(_editingPortfolioId != null ? 'Edit Portfolio Project' : 'Add Portfolio Project'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextField(
                      controller: _portfolioTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Project Title *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description Field
                    TextField(
                      controller: _portfolioDescriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Existing Images Section
                    if (_existingPortfolioImages.isNotEmpty) ...[
                      const Text(
                        'Existing Images',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingPortfolioImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(_existingPortfolioImages[index]['url']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        _removeExistingPortfolioImage(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // New Images Section
                    const Text(
                      'Add Images',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Selected Images Preview
                    if (_selectedPortfolioImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPortfolioImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedPortfolioImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        _removeSelectedPortfolioImage(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Pick Images Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _pickPortfolioImages();
                        setDialogState(() {});
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(_selectedPortfolioImages.isEmpty ? 'Select Images' : 'Add More Images'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _isPortfolioDialogOpen = false;
                },
                child: const Text('Cancel'),
              ),
              Obx(
                () => ElevatedButton(
                  onPressed: _savePortfolio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                  ),
                  child: controller.isAddingPortfolio.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      _isPortfolioDialogOpen = false;
    });
  }

  // ==================== BUILD METHODS ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.white,
                pinned: true,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.black87),
                    onPressed: () {
                      Get.to(() => const EditProfileScreen());
                    },
                    tooltip: 'Edit Profile',
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
              // Resume Section
              _buildSectionCard(
                title: 'Resume',
                icon: Icons.description_outlined,
                showAddButton: false,
                child: Obx(() {
                  if (resumeController.isLoading.value && resumeController.savedResumes.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (resumeController.selectedResume.value != null) {
                    return _buildSelectedResumeItem(resumeController.selectedResume.value!);
                  }
                  
                  return _buildEmptyState(
                    icon: Icons.upload_file,
                    message: 'No resume selected',
                    subMessage: 'Select a resume to display on your profile',
                    buttonText: 'Select Resume',
                    onPressed: () => _showResumeSelectionBottomSheet(),
                  );
                }),
              ),

              // Hourly Rate Card
              _buildHourlyRateCard(),

              // About Section
              _buildSectionCard(
                title: 'About',
                icon: Icons.info_outline,
                showAddButton: controller.bio.value.isEmpty,
                onAddPressed: () => Get.to(() => const EditProfileScreen()),
                child: controller.bio.value.isNotEmpty
                    ? Text(
                        controller.bio.value,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      )
                    : _buildEmptyState(
                        icon: Icons.info_outline,
                        message: 'No about added',
                        subMessage: 'Tell employers about yourself',
                        buttonText: 'Add About',
                        onPressed: () => Get.to(() => const EditProfileScreen()),
                      ),
              ),

              // Skills Section
              _buildSectionCard(
                title: 'Skills & Expertise',
                icon: Icons.stars_outlined,
                showAddButton: controller.skills.isEmpty,
                onAddPressed: () => Get.to(() => const EditProfileScreen()),
                child: controller.skills.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.skills.map((skill) {
                          return Container(
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
                          );
                        }).toList(),
                      )
                    : _buildEmptyState(
                        icon: Icons.stars_outlined,
                        message: 'No skills added',
                        subMessage: 'Add your skills to get better matches',
                        buttonText: 'Add Skills',
                        onPressed: () => Get.to(() => const EditProfileScreen()),
                      ),
              ),

              // Work Experience Section
              _buildSectionCard(
                title: 'Work Experience',
                icon: Icons.work_outline,
                showAddButton: controller.workExperiences.isEmpty,
                onAddPressed: () => _showAddExperienceDialog(),
                child: controller.workExperiences.isNotEmpty
                    ? Column(
                        children: controller.workExperiences.asMap().entries.map((entry) {
                          final index = entry.key;
                          final exp = entry.value;
                          return Column(
                            children: [
                              _buildExperienceItem(exp),
                              if (index < controller.workExperiences.length - 1)
                                const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      )
                    : _buildEmptyState(
                        icon: Icons.work_outline,
                        message: 'No work experience',
                        subMessage: 'Add your work history',
                        buttonText: 'Add Experience',
                        onPressed: () => _showAddExperienceDialog(),
                      ),
              ),

              // Education Section
              _buildSectionCard(
                title: 'Education',
                icon: Icons.school_outlined,
                showAddButton: controller.educations.isEmpty,
                onAddPressed: () => _showAddEducationDialog(),
                child: controller.educations.isNotEmpty
                    ? Column(
                        children: controller.educations.map((edu) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildEducationItem(edu),
                          );
                        }).toList(),
                      )
                    : _buildEmptyState(
                        icon: Icons.school_outlined,
                        message: 'No education added',
                        subMessage: 'Add your educational background',
                        buttonText: 'Add Education',
                        onPressed: () => _showAddEducationDialog(),
                      ),
              ),

              // Portfolio Section
              _buildSectionCard(
                title: 'Portfolio Projects',
                icon: Icons.folder_outlined,
                showAddButton: controller.portfolioProjects.isEmpty,
                onAddPressed: _openAddPortfolioDialog,
                child: controller.portfolioProjects.isNotEmpty
                    ? Column(
                        children: controller.portfolioProjects.map((project) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPortfolioItem(project),
                          );
                        }).toList(),
                      )
                    : _buildEmptyState(
                        icon: Icons.folder_outlined,
                        message: 'No portfolio projects',
                        subMessage: 'Showcase your work',
                        buttonText: 'Add Project',
                        onPressed: _openAddPortfolioDialog,
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== RESUME METHODS (Existing) ====================
  Widget _buildSelectedResumeItem(ResumesModel resume) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.fileName,
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
                          resumeController.formatDate(resume.uploadDate),
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
                          resumeController.formatFileSize(resume.fileSize),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (resume.isDefault) ...[
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showResumeSelectionBottomSheet(),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Change Resume'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewResume(resume),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResumeSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Resume',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a resume to display on your profile',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _uploadNewResume();
                      },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload New Resume'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Your Resumes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (resumeController.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (resumeController.savedResumes.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No resumes found',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload your first resume',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: resumeController.savedResumes.length,
                      itemBuilder: (context, index) {
                        final resume = resumeController.savedResumes[index];
                        final isSelected = resumeController.selectedResume.value?.id == resume.id;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? primary.withOpacity(0.05)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? primary 
                                  : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              resume.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              resumeController.formatFileSize(resume.fileSize),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            trailing: isSelected
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 14,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Selected',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                            onTap: () async {
                              setSheetState(() {});
                              bool success = await resumeController.selectResume(resume.id);
                              if (success) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _uploadNewResume() async {
    Get.snackbar(
      'Info',
      'File picker will be implemented. Please add file_picker package.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _viewResume(ResumesModel resume) {
    Get.snackbar(
      'View Resume',
      'Opening: ${resume.fileName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ==================== ADD EXPERIENCE/EDUCATION DIALOGS ====================
  void _showAddExperienceDialog() {
    // You can implement this similar to portfolio dialog
    Get.snackbar('Info', 'Add experience dialog - Implement as needed');
  }

  void _showAddEducationDialog() {
    Get.snackbar('Info', 'Add education dialog - Implement as needed');
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        children: [
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
                  child: controller.photoUrl.value.isNotEmpty
                      ? Image.network(
                          controller.photoUrl.value,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.fullName,
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
          Text(
            controller.title.value.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                controller.country.value.isNotEmpty
                    ? controller.country.value
                    : 'Location not set',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          controller.initials,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyRateCard() {
    return Container(
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
              controller.hourlyRate.value.isNotEmpty
                  ? Text(
                      "\$${controller.hourlyRate.value}/hr",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => Get.to(() => const EditProfileScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              'Set Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color: primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                  'Available',
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
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool showAddButton = false,
    VoidCallback? onAddPressed,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (showAddButton)
                GestureDetector(
                  onTap: onAddPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16, color: primary),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subMessage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(Icons.add, size: 18),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
// ==================== PORTFOLIO ITEM ====================
Widget _buildPortfolioItem(Map<String, dynamic> project) {
  // Get all images from project
  List<String> allImages = [];
  
  if (project['images'] != null && project['images'] is List) {
    for (var img in project['images']) {
      if (img['url'] != null && img['url'].toString().isNotEmpty) {
        allImages.add(img['url']);
      }
    }
  } else if (project['imageUrl'] != null && project['imageUrl'].toString().isNotEmpty) {
    allImages.add(project['imageUrl']);
  }
  
  // If no images, use placeholder
  if (allImages.isEmpty) {
    allImages.add('');
  }
  
  final projectId = project['_id'] ?? '';
  final firstImage = allImages.first;
  
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Make image clickable - Open fullscreen viewer
        GestureDetector(
          onTap: () => _showFullscreenImages(allImages, project['title'] ?? 'Project Images'),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: firstImage.isNotEmpty
                ? Image.network(
                    firstImage,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['title'] ?? 'Untitled',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (allImages.length > 1) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.image, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${allImages.length} images',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Edit'),
                    onTap: () => _openEditPortfolioDialog(project),
                  ),
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () => _showDeletePortfolioDialog(projectId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ==================== FULLSCREEN IMAGE VIEWER ====================
void _showFullscreenImages(List<String> imageUrls, String title) {
  // Filter out empty URLs
  final validImages = imageUrls.where((url) => url.isNotEmpty).toList();
  
  if (validImages.isEmpty) {
    Get.snackbar('Error', 'No images to display');
    return;
  }
  
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.95),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  // ✅ Image viewer with page view for swiping
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: PageView.builder(
                          itemCount: validImages.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image.network(
                                validImages[index],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / 
                                            loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // ✅ Close button
                  Positioned(
                    top: 40,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  
                  // ✅ Image counter
                  if (validImages.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child:
                            
                             Text(
                              '${validImages.length} images • Tap to close',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          
                        ),
                      ),
                    ),
                  
                  // ✅ Title at top
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
  Widget _buildExperienceItem(Map<String, dynamic> exp) {
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
            child: Icon(Icons.business, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exp['company'] ?? 'No Company'} • ${exp['currentlyWorking'] == true ? 'Present' : 'Past'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(exp),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () => _editExperience(exp),
              ),
              PopupMenuItem(
                child: const Text('Delete'),
                onTap: () => _showDeleteDialog('experience'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> edu) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.school, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu['degree'] ?? 'Degree',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  edu['school'] ?? 'School',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${edu['startYear'] ?? ''} - ${edu['endYear'] ?? 'Present'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Edit'),
                onTap: () => _editEducation(edu),
              ),
              PopupMenuItem(
                child: const Text('Delete'),
                onTap: () => _showDeleteDialog('education'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  String _formatDuration(Map<String, dynamic> exp) {
    if (exp['currentlyWorking'] == true) {
      return '${exp['startYear'] ?? ''} - Present';
    } else {
      return '${exp['startYear'] ?? ''} - ${exp['endYear'] ?? ''}';
    }
  }

  void _editExperience(Map<String, dynamic> exp) {}
  void _editEducation(Map<String, dynamic> edu) {}
  
  void _showDeleteDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type'),
        content: Text('Are you sure you want to delete this $type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar('$type deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
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
}
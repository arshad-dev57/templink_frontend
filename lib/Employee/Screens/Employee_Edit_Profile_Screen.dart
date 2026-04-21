import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:templink/Employee/Controllers/Employee_Profile_Controller.dart';
import 'package:templink/Utils/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EmployeeProfileController controller = Get.find();
  
  // Controllers for basic info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  
  // Skills
  final TextEditingController _newSkillController = TextEditingController();
  List<String> _skills = [];
  
  // Work Experiences - Dynamic list
  List<Map<String, dynamic>> _workExperiences = [];
  int _editingExpIndex = -1;
  
  // Portfolio Projects - Dynamic list
  List<Map<String, dynamic>> _portfolioProjects = [];
  int _editingPortfolioIndex = -1;
  
  bool _isAvailable = true;
  
  // Experience form controllers (for add/edit dialog)
  final TextEditingController _expCompanyController = TextEditingController();
  final TextEditingController _expRoleController = TextEditingController();
  final TextEditingController _expStartController = TextEditingController();
  final TextEditingController _expEndController = TextEditingController();
  final TextEditingController _expDescController = TextEditingController();
  bool _expCurrentlyWorking = false;
  
  // Portfolio form controllers
  final TextEditingController _portfolioTitleController = TextEditingController();
  final TextEditingController _portfolioDescriptionController = TextEditingController();
  List<File> _selectedPortfolioImages = [];
  List<Map<String, dynamic>> _existingPortfolioImages = [];
  String? _editingPortfolioId;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  void _loadProfileData() {
    // Load basic info
    _nameController.text = controller.fullName;
    _titleController.text = controller.title.value;
    _locationController.text = controller.country.value;
    _hourlyRateController.text = controller.hourlyRate.value;
    _aboutController.text = controller.bio.value;
    
    // Load skills
    _skills = List.from(controller.skills);
    
    // Load work experiences
    _workExperiences = List.from(controller.workExperiences);
    
    // Load portfolio projects
    _portfolioProjects = List.from(controller.portfolioProjects);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _hourlyRateController.dispose();
    _aboutController.dispose();
    _newSkillController.dispose();
    _expCompanyController.dispose();
    _expRoleController.dispose();
    _expStartController.dispose();
    _expEndController.dispose();
    _expDescController.dispose();
    _portfolioTitleController.dispose();
    _portfolioDescriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _saveProfile() async {
    final profileData = {
      'title': _titleController.text,
      'bio': _aboutController.text,
      'hourlyRate': _hourlyRateController.text,
      'skills': _skills,
      'workExperiences': _workExperiences,
      'portfolioProjects': _portfolioProjects.map((p) {
        // Remove local temp data before sending
        final cleanProject = Map<String, dynamic>.from(p);
        cleanProject.remove('isTemp');
        cleanProject.remove('tempImages');
        return cleanProject;
      }).toList(),
    };
    
    final success = await controller.updateProfile(profileData);
    if (success) {
      Navigator.pop(context);
    }
  }
  
  // ==================== SKILLS METHODS ====================
  void _addSkill() {
    if (_newSkillController.text.isNotEmpty && !_skills.contains(_newSkillController.text)) {
      setState(() {
        _skills.add(_newSkillController.text);
        _newSkillController.clear();
      });
    }
  }
  
  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }
  
  // ==================== WORK EXPERIENCE METHODS ====================
  void _showAddEditExperienceDialog({Map<String, dynamic>? experience, int? index}) {
    if (experience != null && index != null) {
      // Edit mode
      _editingExpIndex = index;
      _expCompanyController.text = experience['company'] ?? '';
      _expRoleController.text = experience['title'] ?? '';
      _expStartController.text = experience['startYear'] ?? '';
      _expEndController.text = experience['endYear'] ?? '';
      _expDescController.text = experience['description'] ?? '';
      _expCurrentlyWorking = experience['currentlyWorking'] ?? false;
    } else {
      // Add mode
      _editingExpIndex = -1;
      _expCompanyController.clear();
      _expRoleController.clear();
      _expStartController.clear();
      _expEndController.clear();
      _expDescController.clear();
      _expCurrentlyWorking = false;
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(_editingExpIndex != -1 ? 'Edit Experience' : 'Add Experience'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _expCompanyController,
                      decoration: const InputDecoration(labelText: 'Company *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _expRoleController,
                      decoration: const InputDecoration(labelText: 'Role/Position *'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expStartController,
                            decoration: const InputDecoration(labelText: 'Start Year'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _expEndController,
                            enabled: !_expCurrentlyWorking,
                            decoration: InputDecoration(
                              labelText: _expCurrentlyWorking ? 'Present' : 'End Year',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _expCurrentlyWorking,
                          onChanged: (val) {
                            setDialogState(() {
                              _expCurrentlyWorking = val ?? false;
                              if (_expCurrentlyWorking) {
                                _expEndController.clear();
                              }
                            });
                          },
                        ),
                        const Text('Currently working here'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _expDescController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_expCompanyController.text.isEmpty || _expRoleController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill required fields');
                    return;
                  }
                  
                  final experience = {
                    'company': _expCompanyController.text,
                    'title': _expRoleController.text,
                    'startYear': _expStartController.text,
                    'endYear': _expCurrentlyWorking ? '' : _expEndController.text,
                    'currentlyWorking': _expCurrentlyWorking,
                    'description': _expDescController.text,
                  };
                  
                  setState(() {
                    if (_editingExpIndex != -1) {
                      _workExperiences[_editingExpIndex] = experience;
                    } else {
                      _workExperiences.add(experience);
                    }
                  });
                  
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _deleteExperience(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Experience'),
        content: const Text('Are you sure you want to delete this work experience?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _workExperiences.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  // ==================== PORTFOLIO METHODS ====================
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
  
  void _removeSelectedImage(int index) {
    setState(() {
      _selectedPortfolioImages.removeAt(index);
    });
  }
  
  void _removeExistingImage(int index) {
    setState(() {
      _existingPortfolioImages.removeAt(index);
    });
  }
  
  void _showAddEditPortfolioDialog({Map<String, dynamic>? project, int? index}) {
    if (project != null && index != null) {
      // Edit mode
      _editingPortfolioIndex = index;
      _portfolioTitleController.text = project['title'] ?? '';
      _portfolioDescriptionController.text = project['description'] ?? '';
      _editingPortfolioId = project['_id'];
      
      // Load existing images
      _existingPortfolioImages.clear();
      if (project['images'] != null && project['images'] is List) {
        for (var img in project['images']) {
          _existingPortfolioImages.add({
            'url': img['url'],
            'fileName': img['fileName'],
            'publicId': img['publicId'],
          });
        }
      }
    } else {
      // Add mode
      _editingPortfolioIndex = -1;
      _portfolioTitleController.clear();
      _portfolioDescriptionController.clear();
      _editingPortfolioId = null;
      _existingPortfolioImages.clear();
    }
    _selectedPortfolioImages.clear();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(_editingPortfolioIndex != -1 ? 'Edit Portfolio' : 'Add Portfolio'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _portfolioTitleController,
                      decoration: const InputDecoration(labelText: 'Project Title *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _portfolioDescriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    
                    // Existing Images
                    if (_existingPortfolioImages.isNotEmpty) ...[
                      const Text('Existing Images', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingPortfolioImages.length,
                          itemBuilder: (context, i) {
                            return Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(_existingPortfolioImages[i]['url']),
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
                                        _removeExistingImage(i);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // New Images
                    const Text('New Images', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_selectedPortfolioImages.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPortfolioImages.length,
                          itemBuilder: (context, i) {
                            return Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedPortfolioImages[i]),
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
                                        _removeSelectedImage(i);
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _pickPortfolioImages();
                        setDialogState(() {});
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(_selectedPortfolioImages.isEmpty ? 'Select Images' : 'Add More'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              Obx(() => ElevatedButton(
                onPressed: controller.isSavingPortfolio.value ? null : () async {
                  if (_portfolioTitleController.text.isEmpty) {
                    Get.snackbar('Error', 'Please enter project title');
                    return;
                  }
                  
                  bool success;
                  
                  if (_editingPortfolioId != null) {
                    success = await controller.updatePortfolioProject(
                      projectId: _editingPortfolioId!,
                      title: _portfolioTitleController.text,
                      description: _portfolioDescriptionController.text,
                      newImagePaths: _selectedPortfolioImages.map((f) => f.path).toList(),
                      existingImages: _existingPortfolioImages,
                    );
                  } else {
                    success = await controller.addPortfolioProject(
                      title: _portfolioTitleController.text,
                      description: _portfolioDescriptionController.text,
                      imagePaths: _selectedPortfolioImages.map((f) => f.path).toList(),
                    );
                  }
                  
                  if (success) {
                    Navigator.pop(context);
                  }
                },
                child: controller.isSavingPortfolio.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              )),
            ],
          );
        },
      ),
    ).then((_) {
      // Refresh local portfolio list after dialog closes
      _portfolioProjects = List.from(controller.portfolioProjects);
      setState(() {});
    });
  }
  
  void _deletePortfolio(int index) {
    final project = _portfolioProjects[index];
    final projectId = project['_id'];
    
    if (projectId != null) {
      controller.deletePortfolioProject(projectId);
    }
    setState(() {
      _portfolioProjects.removeAt(index);
    });
  }
  
  // ==================== BUILD UI ====================
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            style: TextButton.styleFrom(foregroundColor: primary),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildHourlyRateSection(),
            _buildAboutSection(),
            _buildSkillsSection(),
            _buildWorkExperienceSection(),
            _buildPortfolioSection(),
          ],
        ),
      ),
      bottomSheet: _buildBottomButtons(),
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(46),
                  child: Obx(() => CircleAvatar(
                    radius: 46,
                    backgroundImage: controller.photoUrl.value.isNotEmpty
                        ? NetworkImage(controller.photoUrl.value)
                        : const NetworkImage('https://i.pravatar.cc/300?img=11'),
                  )),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _changeProfilePicture(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(_nameController, 'Full Name', Icons.person_outline, fontSize: 18, fontWeight: FontWeight.w600),
          const SizedBox(height: 12),
          _buildTextField(_titleController, 'Professional Title', Icons.work_outline),
          const SizedBox(height: 12),
          _buildTextField(_locationController, 'Location', Icons.location_on_outlined),
        ],
      ),
    );
  }
  
  Widget _buildHourlyRateSection() {
    return _buildSection(
      title: 'Hourly Rate & Availability',
      icon: Icons.attach_money_outlined,
      child: Column(
        children: [
          _buildTextField(_hourlyRateController, 'Hourly Rate', Icons.attach_money, prefixText: '\$', suffixText: '/hr', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Availability', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const Spacer(),
              _buildAvailabilityChip('Available', _isAvailable, Colors.green),
              const SizedBox(width: 8),
              _buildAvailabilityChip('Not Available', !_isAvailable, Colors.red),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info_outline,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: TextFormField(
          controller: _aboutController,
          maxLines: 5,
          style: const TextStyle(fontSize: 14, height: 1.6),
          decoration: const InputDecoration(contentPadding: EdgeInsets.all(16), border: InputBorder.none, hintText: 'Tell us about yourself...'),
        ),
      ),
    );
  }
  
  Widget _buildSkillsSection() {
    return _buildSection(
      title: 'Skills & Expertise',
      icon: Icons.stars_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) => Chip(
              label: Text(skill),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _removeSkill(skill),
              backgroundColor: primary.withOpacity(0.1),
              labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: primary),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                  child: TextFormField(
                    controller: _newSkillController,
                    decoration: InputDecoration(contentPadding: const EdgeInsets.all(16), border: InputBorder.none, hintText: 'Add new skill...'),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addSkill,
                style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                child: const Icon(Icons.add, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkExperienceSection() {
    return _buildSection(
      title: 'Work Experience',
      icon: Icons.work_outline,
      child: Column(
        children: [
          ..._workExperiences.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(width: 50, height: 50, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.business, color: Colors.blue.shade700)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exp['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(exp['company'] ?? ''),
                        Text('${exp['startYear'] ?? ''} - ${exp['currentlyWorking'] == true ? 'Present' : exp['endYear'] ?? ''}'),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => _showAddEditExperienceDialog(experience: exp, index: index), icon: const Icon(Icons.edit, size: 20)),
                  IconButton(onPressed: () => _deleteExperience(index), icon: const Icon(Icons.delete, size: 20), color: Colors.red),
                ],
              ),
            );
          }),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddEditExperienceDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Experience'),
              style: OutlinedButton.styleFrom(foregroundColor: primary, side: BorderSide(color: primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPortfolioSection() {
    return _buildSection(
      title: 'Portfolio Projects',
      icon: Icons.folder_outlined,
      child: Column(
        children: [
          ..._portfolioProjects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            String firstImage = '';
            if (project['images'] != null && project['images'].isNotEmpty) {
              firstImage = project['images'][0]['url'] ?? '';
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: firstImage.isNotEmpty ? DecorationImage(image: NetworkImage(firstImage), fit: BoxFit.cover) : null),
                    child: firstImage.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(project['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => _showAddEditPortfolioDialog(project: project, index: index), icon: const Icon(Icons.edit, size: 20)),
                  IconButton(onPressed: () => _deletePortfolio(index), icon: const Icon(Icons.delete, size: 20), color: Colors.red),
                ],
              ),
            );
          }),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddEditPortfolioDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Project'),
              style: OutlinedButton.styleFrom(foregroundColor: primary, side: BorderSide(color: primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: primary)),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
  
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {String? prefixText, String? suffixText, TextInputType? keyboardType, double fontSize = 14, FontWeight? fontWeight}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: Colors.black87),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
          prefixText: prefixText,
          suffixText: suffixText,
        ),
      ),
    );
  }
  
  Widget _buildAvailabilityChip(String label, bool selected, Color color) {
    return GestureDetector(
      onTap: () => setState(() => _isAvailable = label == 'Available'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: selected ? color : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: selected ? color : Colors.grey.shade400))),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? color : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700, side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
  
  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.all(20), child: Text('Change Profile Picture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take Photo'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from Gallery'), onTap: () => Navigator.pop(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
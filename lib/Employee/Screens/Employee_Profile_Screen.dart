import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:templink/Employee/Controllers/Employee_Profile_Controller.dart';
import 'package:templink/Employee/Screens/Employee_Edit_Profile_Screen.dart';
import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
import 'package:templink/Utils/colors.dart';

// ─── Design tokens (same as EmployeeApplicationDetailScreen) ──────────────────
const _bg      = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border  = Color(0xFFE5E7EB);
const _text1   = Color(0xFF111827);
const _text2   = Color(0xFF6B7280);
const _text3   = Color(0xFF9CA3AF);
const _red     = Color(0xFFDC2626);
const _green   = Color(0xFF16A34A);
const _amber   = Color(0xFFD97706);
const _r       = 10.0;

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final EmployeeProfileController controller =
      Get.put(EmployeeProfileController());
  final ResumeController resumeController = Get.put(ResumeController());

  // Portfolio state
  final TextEditingController _portfolioTitleController =
      TextEditingController();
  final TextEditingController _portfolioDescriptionController =
      TextEditingController();
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

  // ─── Portfolio methods (logic unchanged) ──────────────────────────────────
  void _openAddPortfolioDialog() {
    _portfolioTitleController.clear();
    _portfolioDescriptionController.clear();
    _selectedPortfolioImages.clear();
    _existingPortfolioImages.clear();
    _editingPortfolioId = null;
    _showPortfolioDialog();
  }

  void _openEditPortfolioDialog(Map<String, dynamic> project) {
    _portfolioTitleController.text = project['title'] ?? '';
    _portfolioDescriptionController.text = project['description'] ?? '';
    _selectedPortfolioImages.clear();
    _existingPortfolioImages.clear();
    _editingPortfolioId = project['_id'];
    if (project['images'] != null && project['images'] is List) {
      for (var img in project['images']) {
        _existingPortfolioImages.add({
          'url': img['url'],
          'fileName': img['fileName'],
          'publicId': img['publicId'],
        });
      }
    } else if (project['imageUrl'] != null &&
        project['imageUrl'].toString().isNotEmpty) {
      _existingPortfolioImages
          .add({'url': project['imageUrl'], 'fileName': '', 'publicId': ''});
    }
    _showPortfolioDialog();
  }

  Future<void> _pickPortfolioImages() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedPortfolioImages
            .addAll(result.files.map((f) => File(f.path!)));
      });
    }
  }

  void _removeSelectedPortfolioImage(int index) =>
      setState(() => _selectedPortfolioImages.removeAt(index));

  void _removeExistingPortfolioImage(int index) =>
      setState(() => _existingPortfolioImages.removeAt(index));

  Future<void> _savePortfolio() async {
    if (_portfolioTitleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter project title',
          backgroundColor: _red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: _r);
      return;
    }
    bool success;
    if (_editingPortfolioId != null) {
      success = await controller.updatePortfolioProject(
        projectId: _editingPortfolioId!,
        title: _portfolioTitleController.text,
        description: _portfolioDescriptionController.text,
        newImagePaths:
            _selectedPortfolioImages.map((f) => f.path).toList(),
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
      await controller.fetchProfile();
    }
  }

  void _showDeletePortfolioDialog(String projectId) {
    Get.dialog(
      Dialog(
        backgroundColor: _surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8)),
                    child:
                        const Icon(Icons.delete_outline, size: 18, color: _red),
                  ),
                  const SizedBox(width: 12),
                  const Text('Delete project?',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _text1)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'This will permanently remove this portfolio project.',
                style: TextStyle(fontSize: 13, color: _text2, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _DialogBtn(
                      label: 'Cancel',
                      onTap: () => Get.back(),
                      variant: _DialogBtnVariant.ghost,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogBtn(
                      label: 'Delete',
                      onTap: () async {
                        Get.back();
                        await controller.deletePortfolioProject(projectId);
                      },
                      variant: _DialogBtnVariant.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPortfolioDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.folder_outlined,
                                size: 18, color: primary),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _editingPortfolioId != null
                                ? 'Edit Project'
                                : 'Add Project',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _text1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title
                      _FieldLabel('Project Title *'),
                      const SizedBox(height: 6),
                      _StyledField(
                          controller: _portfolioTitleController,
                          hint: 'e.g. E-commerce App'),
                      const SizedBox(height: 14),

                      // Description
                      _FieldLabel('Description'),
                      const SizedBox(height: 6),
                      _StyledField(
                          controller: _portfolioDescriptionController,
                          hint: 'Brief description of your project...',
                          maxLines: 3),
                      const SizedBox(height: 16),

                      // Existing images
                      if (_existingPortfolioImages.isNotEmpty) ...[
                        _FieldLabel('Existing Images'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _existingPortfolioImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 82,
                                    height: 82,
                                    margin:
                                        const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border:
                                          Border.all(color: _border),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            _existingPortfolioImages[index]
                                                ['url']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() =>
                                          _removeExistingPortfolioImage(
                                              index)),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 12,
                                            color: Colors.white),
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

                      // New images
                      _FieldLabel('Add Images'),
                      const SizedBox(height: 8),
                      if (_selectedPortfolioImages.isNotEmpty) ...[
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedPortfolioImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 82,
                                    height: 82,
                                    margin:
                                        const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border:
                                          Border.all(color: _border),
                                      image: DecorationImage(
                                        image: FileImage(
                                            _selectedPortfolioImages[
                                                index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => setDialogState(() =>
                                          _removeSelectedPortfolioImage(
                                              index)),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 12,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      GestureDetector(
                        onTap: () async {
                          await _pickPortfolioImages();
                          setDialogState(() {});
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: _border),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 17, color: primary),
                              const SizedBox(width: 8),
                              Text(
                                _selectedPortfolioImages.isEmpty
                                    ? 'Select Images'
                                    : 'Add More Images',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: primary,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: _DialogBtn(
                              label: 'Cancel',
                              onTap: () => Navigator.pop(context),
                              variant: _DialogBtnVariant.ghost,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Obx(
                              () => _DialogBtn(
                                label: controller.isAddingPortfolio.value
                                    ? ''
                                    : 'Save',
                                loading:
                                    controller.isAddingPortfolio.value,
                                onTap: _savePortfolio,
                                variant: _DialogBtnVariant.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: primary));
        }
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: _surface,
                pinned: true,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                expandedHeight: 0,
                titleSpacing: 0,
                title: Text('My Profile',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _text1)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 19, color: _text2),
                    onPressed: () =>
                        Get.to(() => const EditProfileScreen()),
                    tooltip: 'Edit Profile',
                  ),
                  const SizedBox(width: 4),
                ],
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(height: 1, color: _border),
                ),
              ),
            ];
          },
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // ── Profile Header ───────────────────────────────────────
              _buildProfileHeader(),

              const SizedBox(height: 4),

              // ── Stats row ────────────────────────────────────────────
              _buildStatsRow(),

              const SizedBox(height: 16),

              // ── Hourly Rate ─────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHourlyRateCard(),
              ),

              const SizedBox(height: 12),

              // ── Resume ──────────────────────────────────────────────
              _SectionCard(
                icon: Icons.description_outlined,
                title: 'Resume',
                child: Obx(() {
                  if (resumeController.isLoading.value &&
                      resumeController.savedResumes.isEmpty) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: primary)));
                  }
                  if (resumeController.selectedResume.value != null) {
                    return _buildSelectedResumeItem(
                        resumeController.selectedResume.value!);
                  }
                  return _EmptyState(
                    icon: Icons.upload_file_outlined,
                    message: 'No resume selected',
                    subMessage:
                        'Select a resume to display on your profile',
                    buttonText: 'Select Resume',
                    onPressed: _showResumeSelectionBottomSheet,
                  );
                }),
              ),

              // ── About ────────────────────────────────────────────────
              _SectionCard(
                icon: Icons.info_outline_rounded,
                title: 'About',
                trailingAction: controller.bio.value.isEmpty
                    ? _AddChip(
                        onTap: () =>
                            Get.to(() => const EditProfileScreen()))
                    : null,
                child: Obx(() => controller.bio.value.isNotEmpty
                    ? Text(controller.bio.value,
                        style: const TextStyle(
                            fontSize: 13,
                            color: _text2,
                            height: 1.7))
                    : _EmptyState(
                        icon: Icons.info_outline_rounded,
                        message: 'No about added',
                        subMessage: 'Tell employers about yourself',
                        buttonText: 'Add About',
                        onPressed: () =>
                            Get.to(() => const EditProfileScreen()),
                      )),
              ),

              // ── Skills ───────────────────────────────────────────────
              _SectionCard(
                icon: Icons.stars_outlined,
                title: 'Skills & Expertise',
                trailingAction: controller.skills.isEmpty
                    ? _AddChip(
                        onTap: () =>
                            Get.to(() => const EditProfileScreen()))
                    : null,
                child: Obx(() => controller.skills.isNotEmpty
                    ? Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: controller.skills
                            .map((s) => _SkillPill(skill: s))
                            .toList(),
                      )
                    : _EmptyState(
                        icon: Icons.stars_outlined,
                        message: 'No skills added',
                        subMessage:
                            'Add your skills to get better matches',
                        buttonText: 'Add Skills',
                        onPressed: () =>
                            Get.to(() => const EditProfileScreen()),
                      )),
              ),

              // ── Work Experience ───────────────────────────────────────
              _SectionCard(
                icon: Icons.work_outline_rounded,
                title: 'Work Experience',
                trailingAction: _AddChip(
                    onTap: () => _showAddExperienceDialog()),
                child: Obx(() => controller.workExperiences.isNotEmpty
                    ? Column(
                        children: controller.workExperiences
                            .asMap()
                            .entries
                            .map((e) => Column(
                                  children: [
                                    _buildExperienceItem(e.value),
                                    if (e.key <
                                        controller.workExperiences
                                                .length -
                                            1)
                                      const SizedBox(height: 10),
                                  ],
                                ))
                            .toList(),
                      )
                    : _EmptyState(
                        icon: Icons.work_outline_rounded,
                        message: 'No work experience',
                        subMessage: 'Add your work history',
                        buttonText: 'Add Experience',
                        onPressed: () => _showAddExperienceDialog(),
                      )),
              ),

              // ── Education ─────────────────────────────────────────────
              _SectionCard(
                icon: Icons.school_outlined,
                title: 'Education',
                trailingAction: _AddChip(
                    onTap: () => _showAddEducationDialog()),
                child: Obx(() => controller.educations.isNotEmpty
                    ? Column(
                        children: controller.educations
                            .map((edu) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: _buildEducationItem(edu),
                                ))
                            .toList(),
                      )
                    : _EmptyState(
                        icon: Icons.school_outlined,
                        message: 'No education added',
                        subMessage:
                            'Add your educational background',
                        buttonText: 'Add Education',
                        onPressed: () => _showAddEducationDialog(),
                      )),
              ),

              // ── Portfolio ─────────────────────────────────────────────
              _SectionCard(
                icon: Icons.folder_outlined,
                title: 'Portfolio Projects',
                trailingAction:
                    _AddChip(onTap: _openAddPortfolioDialog),
                child: Obx(() => controller.portfolioProjects.isNotEmpty
                    ? Column(
                        children: controller.portfolioProjects
                            .map((p) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: _buildPortfolioItem(p),
                                ))
                            .toList(),
                      )
                    : _EmptyState(
                        icon: Icons.folder_outlined,
                        message: 'No portfolio projects',
                        subMessage: 'Showcase your work',
                        buttonText: 'Add Project',
                        onPressed: _openAddPortfolioDialog,
                      )),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── Profile Header ────────────────────────────────────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _border, width: 3),
                  color: primary.withOpacity(0.08),
                ),
                clipBehavior: Clip.antiAlias,
                child: controller.photoUrl.value.isNotEmpty
                    ? Image.network(controller.photoUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultAvatar())
                    : _buildDefaultAvatar(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.to(() => const EditProfileScreen()),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: _surface, width: 2),
                    ),
                    child: const Icon(Icons.edit,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name + verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  controller.fullName,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _text1),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified,
                    size: 13, color: Color(0xFF3B82F6)),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Title
          if (controller.title.value.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                controller.title.value.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    letterSpacing: 0.6),
              ),
            ),
          const SizedBox(height: 8),

          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: _text3),
              const SizedBox(width: 4),
              Text(
                controller.country.value.isNotEmpty
                    ? controller.country.value
                    : 'Location not set',
                style: const TextStyle(fontSize: 13, color: _text2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final ch = controller.initials.isNotEmpty
        ? controller.initials[0].toUpperCase()
        : 'U';
    return Container(
      color: primary.withOpacity(0.08),
      child: Center(
        child: Text(ch,
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: primary)),
      ),
    );
  }

  // ─── Stats row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          _StatTile(value: '4.9★', label: 'Rating'),
          _Divider(),
          _StatTile(value: '42', label: 'Jobs Done'),
          _Divider(),
          _StatTile(value: '98%', label: 'Success'),
        ],
      ),
    );
  }

  // ─── Hourly Rate ──────────────────────────────────────────────────────────
  Widget _buildHourlyRateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r + 2),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.monetization_on_outlined,
                size: 20, color: _green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hourly Rate',
                    style: TextStyle(fontSize: 11, color: _text2)),
                const SizedBox(height: 2),
                Obx(() => controller.hourlyRate.value.isNotEmpty
                    ? Text(
                        '\$${controller.hourlyRate.value}/hr',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _text1),
                      )
                    : GestureDetector(
                        onTap: () =>
                            Get.to(() => const EditProfileScreen()),
                        child: Text('Set your rate',
                            style: TextStyle(
                                fontSize: 13,
                                color: primary,
                                fontWeight: FontWeight.w500)),
                      )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: _green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text('Available',
                    style: TextStyle(
                        fontSize: 11,
                        color: _green,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Resume ───────────────────────────────────────────────────────────────
  Widget _buildSelectedResumeItem(ResumesModel resume) {
    final sizeStr =
        resumeController.formatFileSize(resume.fileSize);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf_outlined,
                    size: 20, color: _red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(resume.fileName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _text1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                            resumeController
                                .formatDate(resume.uploadDate),
                            style: const TextStyle(
                                fontSize: 11, color: _text2)),
                        if (sizeStr.isNotEmpty) ...[
                          const Text(' · ',
                              style:
                                  TextStyle(fontSize: 11, color: _text3)),
                          Text(sizeStr,
                              style: const TextStyle(
                                  fontSize: 11, color: _text2)),
                        ],
                        if (resume.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Default',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: _green,
                                    fontWeight: FontWeight.w600)),
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
                child: _OutlineBtn(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Change',
                  onTap: _showResumeSelectionBottomSheet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilledBtn(
                  icon: Icons.visibility_outlined,
                  label: 'View',
                  onTap: () => _viewResume(resume),
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
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Resume',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _text1)),
                          SizedBox(height: 2),
                          Text('Choose resume to display on profile',
                              style: TextStyle(
                                  fontSize: 12, color: _text2)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: _text2),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 14),

                // Upload button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _uploadNewResume();
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 17, color: primary),
                        const SizedBox(width: 8),
                        Text('Upload New Resume',
                            style: TextStyle(
                                fontSize: 13,
                                color: primary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Saved resumes label
                Row(
                  children: [
                    const Expanded(child: Divider(color: _border)),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      child: const Text('Saved Resumes',
                          style: TextStyle(fontSize: 11, color: _text3)),
                    ),
                    const Expanded(child: Divider(color: _border)),
                  ],
                ),
                const SizedBox(height: 12),

                Obx(() {
                  if (resumeController.isLoading.value) {
                    return const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: primary));
                  }
                  if (resumeController.savedResumes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 40, color: _text3),
                          const SizedBox(height: 8),
                          const Text('No resumes found',
                              style: TextStyle(
                                  fontSize: 13, color: _text2)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: resumeController.savedResumes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final resume =
                          resumeController.savedResumes[index];
                      final isSelected =
                          resumeController.selectedResume.value?.id ==
                              resume.id;
                      return GestureDetector(
                        onTap: () async {
                          bool success =
                              await resumeController
                                  .selectResume(resume.id);
                          if (success) Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withOpacity(0.05)
                                : _bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? primary.withOpacity(0.4)
                                  : _border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 18,
                                    color: _red),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(resume.fileName,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: _text1),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        resumeController.formatFileSize(
                                            resume.fileSize),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: _text2)),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _green.withOpacity(0.08),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          size: 13, color: _green),
                                      const SizedBox(width: 4),
                                      const Text('Selected',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: _green,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  void _uploadNewResume() {
    Get.snackbar('Info', 'Upload resume feature coming soon.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: _r);
  }

  void _viewResume(ResumesModel resume) {
    Get.snackbar('Opening', resume.fileName,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: _r);
  }

  // ─── Experience / Education dialogs (stubs, logic unchanged) ─────────────
  void _showAddExperienceDialog() =>
      Get.snackbar('Info', 'Add experience dialog',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));

  void _showAddEducationDialog() =>
      Get.snackbar('Info', 'Add education dialog',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));

  // ─── Experience item ──────────────────────────────────────────────────────
  Widget _buildExperienceItem(Map<String, dynamic> exp) {
    final period = exp['currentlyWorking'] == true
        ? '${exp['startYear'] ?? ''} – Present'
        : '${exp['startYear'] ?? ''} – ${exp['endYear'] ?? ''}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.business_outlined,
                size: 20, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp['title'] ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _text1)),
                const SizedBox(height: 2),
                Text(
                  '${exp['company'] ?? 'No Company'}'
                  '${exp['currentlyWorking'] == true ? ' · Current' : ''}',
                  style: const TextStyle(fontSize: 12, color: _text2),
                ),
                const SizedBox(height: 2),
                Text(period,
                    style:
                        const TextStyle(fontSize: 11, color: _text3)),
              ],
            ),
          ),
          _MoreMenu(items: [
            _MenuItem('Edit', () => _editExperience(exp)),
            _MenuItem('Delete',
                () => _showDeleteDialog('experience'), isDestructive: true),
          ]),
        ],
      ),
    );
  }

  // ─── Education item ───────────────────────────────────────────────────────
  Widget _buildEducationItem(Map<String, dynamic> edu) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school_outlined, size: 20, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu['degree'] ?? 'Degree',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _text1)),
                const SizedBox(height: 2),
                Text(edu['school'] ?? 'School',
                    style:
                        const TextStyle(fontSize: 12, color: _text2)),
                const SizedBox(height: 2),
                Text(
                    '${edu['startYear'] ?? ''} – ${edu['endYear'] ?? 'Present'}',
                    style:
                        const TextStyle(fontSize: 11, color: _text3)),
              ],
            ),
          ),
          _MoreMenu(items: [
            _MenuItem('Edit', () => _editEducation(edu)),
            _MenuItem('Delete',
                () => _showDeleteDialog('education'), isDestructive: true),
          ]),
        ],
      ),
    );
  }

  // ─── Portfolio item ───────────────────────────────────────────────────────
  Widget _buildPortfolioItem(Map<String, dynamic> project) {
    List<String> allImages = [];
    if (project['images'] != null && project['images'] is List) {
      for (var img in project['images']) {
        if (img['url'] != null && img['url'].toString().isNotEmpty) {
          allImages.add(img['url']);
        }
      }
    } else if (project['imageUrl'] != null &&
        project['imageUrl'].toString().isNotEmpty) {
      allImages.add(project['imageUrl']);
    }
    if (allImages.isEmpty) allImages.add('');

    final firstImage = allImages.first;
    final projectId = project['_id'] ?? '';

    return Container(
      decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          GestureDetector(
            onTap: () => _showFullscreenImages(
                allImages, project['title'] ?? 'Project'),
            child: Stack(
              children: [
                firstImage.isNotEmpty
                    ? Image.network(firstImage,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholderImage())
                    : _buildPlaceholderImage(),
                // Image count badge
                if (allImages.length > 1)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.image_outlined,
                              size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('${allImages.length}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project['title'] ?? 'Untitled',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _text1)),
                      if ((project['description'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(project['description'],
                            style: const TextStyle(
                                fontSize: 12, color: _text2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                _MoreMenu(items: [
                  _MenuItem(
                      'Edit', () => _openEditPortfolioDialog(project)),
                  _MenuItem('Delete',
                      () => _showDeletePortfolioDialog(projectId),
                      isDestructive: true),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      color: const Color(0xFFF3F4F6),
      child: const Center(
          child: Icon(Icons.image_outlined, size: 36, color: _text3)),
    );
  }

  // ─── Fullscreen image viewer (logic unchanged) ────────────────────────────
  void _showFullscreenImages(List<String> imageUrls, String title) {
    final validImages =
        imageUrls.where((url) => url.isNotEmpty).toList();
    if (validImages.isEmpty) {
      Get.snackbar('Error', 'No images to display',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16));
      return;
    }
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
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
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image,
                                  size: 48, color: _text3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 48,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Positioned(
                top: 48,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
              if (validImages.length > 1)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          '${validImages.length} images · Tap to close',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _editExperience(Map<String, dynamic> exp) {}
  void _editEducation(Map<String, dynamic> edu) {}

  void _showDeleteDialog(String type) {
    Get.dialog(
      Dialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_outline,
                        size: 18, color: _red),
                  ),
                  const SizedBox(width: 12),
                  Text('Delete $type?',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _text1)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Are you sure you want to delete this $type?',
                  style: const TextStyle(
                      fontSize: 13, color: _text2, height: 1.5)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _DialogBtn(
                        label: 'Cancel',
                        onTap: () => Get.back(),
                        variant: _DialogBtnVariant.ghost),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogBtn(
                        label: 'Delete',
                        onTap: () => Get.back(),
                        variant: _DialogBtnVariant.danger),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailingAction;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r + 2),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _text1,
                        letterSpacing: 0.1)),
              ),
              if (trailingAction != null) trailingAction!,
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Stat tile + divider ───────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _text1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: _text2)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 32, color: _border,
        margin: const EdgeInsets.symmetric(horizontal: 4));
  }
}

// ─── Add chip ──────────────────────────────────────────────────────────────────
class _AddChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 13, color: primary),
            const SizedBox(width: 4),
            Text('Add',
                style: TextStyle(
                    fontSize: 11,
                    color: primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Skill pill ────────────────────────────────────────────────────────────────
class _SkillPill extends StatelessWidget {
  final String skill;
  const _SkillPill({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Text(skill,
          style: TextStyle(
              fontSize: 12,
              color: primary,
              fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;
  final String buttonText;
  final VoidCallback onPressed;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subMessage,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: _text3),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _text2)),
          const SizedBox(height: 3),
          Text(subMessage,
              style: const TextStyle(fontSize: 12, color: _text3),
              textAlign: TextAlign.center),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(buttonText,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Outline / Filled buttons ──────────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: primary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: primary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FilledBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── More menu ─────────────────────────────────────────────────────────────────
class _MenuItem {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuItem(this.label, this.onTap, {this.isDestructive = false});
}

class _MoreMenu extends StatelessWidget {
  final List<_MenuItem> items;
  const _MoreMenu({required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert, size: 18, color: _text3),
      padding: EdgeInsets.zero,
      color: _surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _border)),
      itemBuilder: (_) => items.asMap().entries.map((e) {
        final item = e.value;
        return PopupMenuItem<int>(
          value: e.key,
          onTap: item.onTap,
          child: Text(item.label,
              style: TextStyle(
                  fontSize: 13,
                  color: item.isDestructive ? _red : _text1)),
        );
      }).toList(),
    );
  }
}

// ─── Dialog button ─────────────────────────────────────────────────────────────
enum _DialogBtnVariant { ghost, danger, primary }

class _DialogBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _DialogBtnVariant variant;
  final bool loading;

  const _DialogBtn({
    required this.label,
    required this.onTap,
    required this.variant,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDanger = variant == _DialogBtnVariant.danger;
    final isPrimary = variant == _DialogBtnVariant.primary;
    final bg = isDanger
        ? _red
        : isPrimary
            ? primary
            : Colors.transparent;
    final fg = (isDanger || isPrimary) ? Colors.white : _text2;
    final bd = (isDanger || isPrimary)
        ? Border.all(color: Colors.transparent)
        : Border.all(color: _border);

    return SizedBox(
      height: 38,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), border: bd),
            alignment: Alignment.center,
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: fg))
                : Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: fg)),
          ),
        ),
      ),
    );
  }
}

// ─── Styled field helpers ──────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _text2));
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _StyledField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: _text1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: _text3),
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primary, width: 1.5)),
      ),
    );
  }
}
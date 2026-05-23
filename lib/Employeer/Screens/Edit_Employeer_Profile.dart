// lib/Employer/Screens/Edit_Employeer_Profile.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:templink/Employeer/Controller/employer_profile_controller.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditEmployerProfileScreen extends StatefulWidget {
  final bool showSidebar;
  final VoidCallback? onBackPressed;

  const EditEmployerProfileScreen({
    Key? key,
    this.showSidebar = true,  // Accept but don't use - parent handles sidebar
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<EditEmployerProfileScreen> createState() =>
      _EditEmployerProfileScreenState();
}

class _EditEmployerProfileScreenState extends State<EditEmployerProfileScreen> {
  final EmployerProfileController controller = Get.find<EmployerProfileController>();
  
  late TextEditingController _companyNameController;
  late TextEditingController _industryController;
  late TextEditingController _locationController;
  late TextEditingController _companySizeController;
  late TextEditingController _websiteController;
  late TextEditingController _aboutController;
  late TextEditingController _missionController;
  late TextEditingController _phoneController;
  late TextEditingController _companyEmailController;
  late TextEditingController _linkedinController;
  late TextEditingController _workModelController;

  bool _isLoading = false;
  File? _selectedLogoImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _companyNameController = TextEditingController(text: controller.companyName.value);
    _industryController = TextEditingController(text: controller.industry.value);
    
    String location = controller.city.value;
    if (controller.country.value.isNotEmpty && controller.country.value != 'Location not set') {
      location = '${controller.city.value}, ${controller.country.value}';
    }
    _locationController = TextEditingController(text: location);
    _companySizeController = TextEditingController(text: controller.companySize.value);
    _websiteController = TextEditingController(text: controller.website.value);
    _aboutController = TextEditingController(text: controller.about.value);
    _missionController = TextEditingController(text: controller.mission.value);
    _phoneController = TextEditingController(text: controller.phone.value);
    _companyEmailController = TextEditingController(text: controller.companyEmail.value);
    _linkedinController = TextEditingController(text: controller.linkedin.value);
    _workModelController = TextEditingController(text: controller.workModel.value);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _companySizeController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
    _missionController.dispose();
    _phoneController.dispose();
    _companyEmailController.dispose();
    _linkedinController.dispose();
    _workModelController.dispose();
    super.dispose();
  }

  Future<void> _pickLogoImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedLogoImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    final success = await controller.updateProfileFromEdit(
      companyName: _companyNameController.text.trim(),
      industry: _industryController.text.trim(),
      location: _locationController.text.trim(),
      companySize: _companySizeController.text.trim(),
      website: _websiteController.text.trim(),
      about: _aboutController.text.trim(),
      logoImage: _selectedLogoImage,
      mission: _missionController.text.trim(),
      phone: _phoneController.text.trim(),
      companyEmail: _companyEmailController.text.trim(),
      linkedin: _linkedinController.text.trim(),
      workModel: _workModelController.text.trim(),
    );
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

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

  // ==================== WEB LAYOUT - ONLY CONTENT, NO SIDEBAR ====================
  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildWebAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 900.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildFormContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 24.w),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.edit_note, color: primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Company Profile',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Update your company information',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Profile Image Section
          Center(child: _buildProfileImageSection(true)),
          SizedBox(height: 32.h),

          // Form Fields - 2 column layout
          _buildTwoColumnForm(),
          SizedBox(height: 24.h),

          const Divider(height: 1),
          SizedBox(height: 24.h),

          // About Section
          _buildAboutSection(),
          SizedBox(height: 24.h),

          const Divider(height: 1),
          SizedBox(height: 24.h),

          // Mission Section
          _buildMissionSection(),
          SizedBox(height: 24.h),

          const Divider(height: 1),
          SizedBox(height: 24.h),

          // Contact Information Section
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection(bool isDesktop) {
    return Stack(
      children: [
        Container(
          width: isDesktop ? 120.w : 110.w,
          height: isDesktop ? 120.h : 110.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A52),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            image: _selectedLogoImage != null
                ? DecorationImage(
                    image: FileImage(_selectedLogoImage!),
                    fit: BoxFit.cover,
                  )
                : (controller.logoUrl.value.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(controller.logoUrl.value),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      )
                    : null),
          ),
          child: (_selectedLogoImage == null && controller.logoUrl.value.isEmpty)
              ? Icon(
                  Icons.business,
                  color: Colors.white,
                  size: isDesktop ? 54.sp : 54.sp,
                )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickLogoImage,
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 8.w : 8.w),
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: isDesktop ? 18.sp : 18.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTwoColumnForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _companyNameController,
                      label: 'Company Name',
                      icon: Icons.business_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _industryController,
                      label: 'Industry',
                      icon: Icons.category_outlined,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location (City, Country)',
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _companySizeController,
                      label: 'Company Size',
                      icon: Icons.people_outline,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _workModelController,
                      label: 'Work Model',
                      icon: Icons.business_center,
                      hint: 'Remote, Hybrid, Onsite',
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildTextField(
                controller: _companyNameController,
                label: 'Company Name',
                icon: Icons.business_outlined,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _industryController,
                label: 'Industry',
                icon: Icons.category_outlined,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _locationController,
                label: 'Location (City, Country)',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _companySizeController,
                label: 'Company Size',
                icon: Icons.people_outline,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _websiteController,
                label: 'Website',
                icon: Icons.language,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _workModelController,
                label: 'Work Model',
                icon: Icons.business_center,
                hint: 'Remote, Hybrid, Onsite',
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined, color: primary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'About Company',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _aboutController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Tell us about your company...',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag_outlined, color: primary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Company Mission',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _missionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'What is your company\'s mission?',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.contact_phone_outlined, color: primary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                controller: _companyEmailController,
                label: 'Company Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _linkedinController,
          label: 'LinkedIn URL',
          icon: Icons.link,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Center(child: _buildProfileImageSection(false)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _companyNameController,
                    label: 'Company Name',
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _industryController,
                    label: 'Industry',
                    icon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location (City, Country)',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _companySizeController,
                    label: 'Company Size',
                    icon: Icons.people_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _websiteController,
                    label: 'Website',
                    icon: Icons.language,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _workModelController,
                    label: 'Work Model',
                    icon: Icons.business_center,
                    hint: 'Remote, Hybrid, Onsite',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Company',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aboutController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Tell us about your company...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Company Mission',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _missionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'What is your company\'s mission?',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _companyEmailController,
                    label: 'Company Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _linkedinController,
                    label: 'LinkedIn URL',
                    icon: Icons.link,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SHARED WIDGETS ====================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
  }) {
    final isDesktop = Responsive.isDesktop(context);
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(fontSize: isDesktop ? 12.sp : 13.sp, color: Colors.grey.shade500),
        labelStyle: TextStyle(fontSize: isDesktop ? 13.sp : 14.sp),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: isDesktop ? 20.sp : 22.sp),
        filled: true,
        fillColor: isDesktop ? Colors.grey.shade50 : Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 14.w : 16.w,
          vertical: isDesktop ? 12.h : 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 10.r : 12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 10.r : 12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 10.r : 12.r),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 10.r : 12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_profile_controller.dart';
import 'package:templink/Utils/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditEmployerProfileScreen extends StatefulWidget {
  const EditEmployerProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditEmployerProfileScreen> createState() =>
      _EditEmployerProfileScreenState();
}

class _EditEmployerProfileScreenState extends State<EditEmployerProfileScreen> {
  final EmployerProfileController controller = Get.find<EmployerProfileController>();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _companyNameController;
  late TextEditingController _industryController;
  late TextEditingController _locationController;
  late TextEditingController _companySizeController;
  late TextEditingController _websiteController;
  late TextEditingController _aboutController;

  bool _isLoading = false;
  File? _selectedLogoImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _companySizeController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
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
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final success = await controller.updateProfileFromEdit(
        companyName: _companyNameController.text.trim(),
        industry: _industryController.text.trim(),
        location: _locationController.text.trim(),
        companySize: _companySizeController.text.trim(),
        website: _websiteController.text.trim(),
        about: _aboutController.text.trim(),
        logoImage: _selectedLogoImage,
      );
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
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
                            ? const Icon(
                                Icons.business,
                                color: Colors.teal,
                                size: 54,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickLogoImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _companyNameController,
                      label: 'Company Name',
                      icon: Icons.business_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _industryController,
                      label: 'Industry',
                      icon: Icons.category_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter industry';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _locationController,
                      label: 'Location (City, Country)',
                      icon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _companySizeController,
                      label: 'Company Size',
                      icon: Icons.people_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company size';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _websiteController,
                      label: 'Website',
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'About Company',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter company description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Additional Settings
                    _buildSectionCard(
                      title: 'Profile Settings',
                      children: [
                        _buildSwitchTile(
                          title: 'Show on Featured Employers',
                          subtitle: 'Display your profile in featured section',
                          value: true,
                          onChanged: (value) {},
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          title: 'Allow Direct Messages',
                          subtitle: 'Let candidates message you directly',
                          value: true,
                          onChanged: (value) {},
                        ),
                        const Divider(height: 1),
                        _buildSwitchTile(
                          title: 'Show Team Members',
                          subtitle: 'Display team members on profile',
                          value: true,
                          onChanged: (value) {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Save Button
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      value: value,
      activeColor: primary,
      onChanged: onChanged,
    );
  }
}
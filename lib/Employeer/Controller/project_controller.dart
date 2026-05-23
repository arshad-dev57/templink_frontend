import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform, File, SocketException;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/project_model.dart';
import 'package:templink/config/api_config.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

class ProjectController extends GetxController {
  // Loading States
  var isLoading = false.obs;
  var isUploading = false.obs;

  // Form Fields
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var selectedCategory = Rxn<String>();
  var selectedDuration = '3-6 months'.obs;
  var selectedExperience = 'Expert'.obs;
  var budgetType = 'FIXED'.obs;
  var minBudgetController = TextEditingController();
  var maxBudgetController = TextEditingController();
  var skillController = TextEditingController();
  var deliverableController = TextEditingController();
  
  // ============= SEARCHABLE CATEGORY FIELDS =============
  final categorySearchController = TextEditingController();
  var filteredCategories = <String>[].obs;
  var showCategoryList = false.obs;
  
  // All Categories List (100+ main fields)
  final List<String> allCategories = [
    // ========== TECHNOLOGY ==========
    'Web Development',
    'Mobile App Development',
    'Software Development',
    'Desktop Application Development',
    'Game Development',
    'Data Science & Analytics',
    'Machine Learning & AI',
    'DevOps & Cloud Computing',
    'Cybersecurity',
    'Database Administration',
    'IT Support & Helpdesk',
    'Network Administration',
    'System Administration',
    'Blockchain & Crypto',
    'IoT Development',
    'AR/VR Development',
    'Embedded Systems',
    'Salesforce Development',
    'SAP Development',
    'WordPress Development',
    'Shopify Development',
    'E-commerce Development',
    'CMS Development',
    
    // ========== DESIGN ==========
    'UI/UX Design',
    'Graphic Design',
    'Logo Design',
    'Brand Identity Design',
    'Motion Graphics',
    'Animation',
    'Video Editing',
    '3D Modeling & Rendering',
    'Architectural Design',
    'Interior Design',
    'Fashion Design',
    'Product Design',
    'Illustration',
    'Photo Editing',
    'Print Design',
    
    // ========== HEALTHCARE ==========
    'Nursing',
    'Doctor / Physician',
    'Dentistry',
    'Pharmacy',
    'Medical Lab Technology',
    'Radiology',
    'Physical Therapy',
    'Occupational Therapy',
    'Veterinary',
    'Caregiving',
    'Medical Billing & Coding',
    'Healthcare Administration',
    'Public Health',
    'Nutrition & Dietetics',
    'Psychology',
    'Mental Health Counseling',
    
    // ========== MARKETING & SALES ==========
    'Digital Marketing',
    'Social Media Marketing',
    'SEO/SEM',
    'Content Marketing',
    'Email Marketing',
    'Affiliate Marketing',
    'Influencer Marketing',
    'Brand Management',
    'Public Relations',
    'Sales Representative',
    'Business Development',
    'Account Management',
    
    // ========== EDUCATION ==========
    'Teaching (School)',
    'University Professor',
    'Online Tutoring',
    'Corporate Training',
    'Language Instruction',
    'Special Education',
    'Early Childhood Education',
    'Curriculum Development',
    'Instructional Design',
    
    // ========== FINANCE & LEGAL ==========
    'Accounting',
    'Bookkeeping',
    'Financial Analysis',
    'Investment Banking',
    'Tax Preparation',
    'Auditing',
    'Payroll Management',
    'Legal Advising',
    'Paralegal',
    'Compliance Officer',
    
    // ========== CONSTRUCTION & LABOR ==========
    'Construction Management',
    'Civil Engineering',
    'Architecture',
    'Electrical Work',
    'Plumbing',
    'Carpentry',
    'Welding',
    'Painting',
    'HVAC Technician',
    'General Labor',
    
    // ========== TRANSPORT & LOGISTICS ==========
    'Truck Driving',
    'Delivery Driver',
    'Logistics Coordinator',
    'Warehouse Management',
    'Supply Chain Management',
    
    // ========== HOSPITALITY & FOOD ==========
    'Chef / Cook',
    'Restaurant Management',
    'Food Service Worker',
    'Bartending',
    'Hotel Management',
    'Housekeeping',
    'Event Planning',
    
    // ========== CUSTOMER SERVICE ==========
    'Customer Support',
    'Call Center Representative',
    'Receptionist',
    'Virtual Assistant',
    'Chat Support',
    
    // ========== ADMINISTRATIVE ==========
    'Administrative Assistant',
    'Data Entry',
    'Office Management',
    'Executive Assistant',
    'Document Controller',
    
    // ========== MEDIA & ENTERTAINMENT ==========
    'Photography',
    'Videography',
    'Content Creation',
    'Voice Acting',
    'Music Production',
    'Journalism',
    'Copy Editing',
    'Translation',
    'Transcription',
    
    // ========== ENGINEERING ==========
    'Mechanical Engineering',
    'Electrical Engineering',
    'Chemical Engineering',
    'Industrial Engineering',
    'Biomedical Engineering',
    
    // ========== REAL ESTATE ==========
    'Real Estate Agent',
    'Property Manager',
    'Real Estate Investor',
    
    // ========== HR & RECRUITMENT ==========
    'HR Generalist',
    'Recruiter',
    'Talent Acquisition',
    'Training & Development',
    
    // ========== WRITING & CONTENT ==========
    'Content Writing',
    'Copywriting',
    'Technical Writing',
    'Creative Writing',
    'Blog Writing',
    'Script Writing',
    
    // ========== OTHER ==========
    'Fitness Training',
    'Personal Coaching',
    'Beauty & Makeup',
    'Cleaning Services',
    'Security Guard',
    'Pet Care',
    'Child Care',
    'Handyman Services',
    'Appliance Repair',
    'Automotive Repair',
  ];
  
  // Milestone related
  var milestonesList = <Map<String, dynamic>>[].obs;
  var showMilestoneForm = false.obs;
  final milestoneTitleController = TextEditingController();
  final milestoneDescController = TextEditingController();
  final milestoneAmountController = TextEditingController();
  var selectedMilestoneDueDate = Rx<DateTime?>(null);
  
  // Lists
  var skills = <String>[].obs;
  var deliverables = <String>[].obs;
  var mediaFiles = <MediaFile>[].obs;
  
  // Web-compatible file storage
  var selectedWebFiles = <WebFileData>[].obs;
  var selectedFiles = <dynamic>[].obs;
  
  var currentStep = 0.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    skills.clear();
    deliverables.clear();
    // Initialize filtered categories with all categories
    filteredCategories.value = allCategories;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    minBudgetController.dispose();
    maxBudgetController.dispose();
    skillController.dispose();
    deliverableController.dispose();
    milestoneTitleController.dispose();
    milestoneDescController.dispose();
    milestoneAmountController.dispose();
    categorySearchController.dispose();
    super.onClose();
  }
  
  // ============= SEARCHABLE CATEGORY METHODS =============
  void filterCategories(String query) {
    if (query.isEmpty) {
      filteredCategories.value = allCategories;
      showCategoryList.value = false;
    } else {
      // Case-insensitive search - capital/small doesn't matter
      filteredCategories.value = allCategories
          .where((category) => 
              category.toLowerCase().contains(query.toLowerCase()))
          .toList();
      showCategoryList.value = filteredCategories.isNotEmpty;
    }
  }
  
  void selectCategory(String category) {
    selectedCategory.value = category;
    categorySearchController.text = category;
    showCategoryList.value = false;
  }

  void nextStep() {
    if (currentStep.value < 2) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  bool validateMilestonesWithBudget() {
    if (budgetType.value == 'FIXED' && milestonesList.isNotEmpty) {
      final minBudget = double.tryParse(minBudgetController.text) ?? 0;
      final maxBudget = double.tryParse(maxBudgetController.text) ?? 0;
      
      final totalMilestones = milestonesList.fold<double>(
        0, (sum, m) => sum + (m['amount'] as double)
      );
      
      if (totalMilestones < minBudget || totalMilestones > maxBudget) {
        Get.snackbar(
          '❌ Budget Mismatch',
          'Total milestone amount (${totalMilestones.toStringAsFixed(0)}) must be between \$${minBudget.toStringAsFixed(0)} and \$${maxBudget.toStringAsFixed(0)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    }
    return true;
  }

  void addSkill(String skill) {
    final s = skill.trim();
    if (s.isNotEmpty && !skills.contains(s)) {
      skills.add(s);
      skillController.clear();
    }
  }

  void removeSkill(String skill) {
    skills.remove(skill);
  }

  void addDeliverable(String deliverable) {
    final d = deliverable.trim();
    if (d.isNotEmpty) {
      deliverables.add(d);
      deliverableController.clear();
    }
  }

  void removeDeliverable(int index) {
    deliverables.removeAt(index);
  }

  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        for (final file in result.files) {
          final already = selectedWebFiles.any((x) => x.name == file.name);
          if (already) continue;

          final webFileData = WebFileData(
            name: file.name,
            size: file.size,
            bytes: file.bytes,
            extension: file.extension ?? '',
            file: file,
          );
          
          selectedWebFiles.add(webFileData);
          
          mediaFiles.add(
            MediaFile(
              fileName: file.name,
              fileUrl: file.name,
              fileType: _getFileType(file.extension ?? ''),
              publicId: null,
            ),
          );
          
          selectedFiles.add(file);
        }

        Get.snackbar(
          '✅ Success',
          '${result.files.length} file(s) selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to pick files: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  void removeFile(int index) {
    mediaFiles.removeAt(index);
    selectedFiles.removeAt(index);
    selectedWebFiles.removeAt(index);
  }

  bool validateStep1() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('❌ Error', 'Project title is required',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (selectedCategory.value == null || selectedCategory.value!.isEmpty) {
      Get.snackbar('❌ Error', 'Please select a category',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (descriptionController.text.trim().length < 10) {
      Get.snackbar('❌ Error', 'Description must be at least 10 characters',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    return true;
  }

  bool validateStep2() {
    if (minBudgetController.text.trim().isEmpty || maxBudgetController.text.trim().isEmpty) {
      Get.snackbar('❌ Error', 'Please enter budget range',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    double min = double.tryParse(minBudgetController.text.trim()) ?? 0;
    double max = double.tryParse(maxBudgetController.text.trim()) ?? 0;

    if (min <= 0 || max <= 0 || min > max) {
      Get.snackbar('❌ Error', 'Please enter valid budget range',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (deliverables.isEmpty) {
      Get.snackbar('❌ Error', 'Add at least one deliverable',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (!validateMilestonesWithBudget()) {
      return false;
    }

    return true;
  }

  bool validateStep3() {
    if (skills.isEmpty) {
      Get.snackbar('❌ Error', 'Add at least one required skill',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (selectedWebFiles.isEmpty) {
      Get.snackbar(
        '❌ Error',
        'Please upload at least one file (PDF, DOC, or Image)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    return true;
  }

  Future<void> addFilesToRequest(http.MultipartRequest request) async {
    for (final webFile in selectedWebFiles) {
      if (webFile.bytes != null) {
        final mimeType = lookupMimeType(webFile.name) ?? 'application/octet-stream';
        final mediaType = MediaType.parse(mimeType);
        
        final multipartFile = http.MultipartFile.fromBytes(
          'media',
          webFile.bytes!,
          filename: webFile.name,
          contentType: mediaType,
        );
        
        request.files.add(multipartFile);
      } else if (webFile.file?.path != null && (Platform.isAndroid || Platform.isIOS)) {
        final filePath = webFile.file!.path;
        if (filePath != null) {
          final exists = await File(filePath).exists();
          if (exists) {
            final mediaType = _mediaTypeFromPath(filePath);
            request.files.add(
              await http.MultipartFile.fromPath(
                'media',
                filePath,
                filename: webFile.name,
                contentType: mediaType,
              ),
            );
          }
        }
      }
    }
  }

  MediaType _mediaTypeFromPath(String filePath) {
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
    final parts = mimeType.split('/');
    if (parts.length == 2) return MediaType(parts[0], parts[1]);
    return MediaType('application', 'octet-stream');
  }

  Future<void> createProject() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      isLoading.value = true;
      isUploading.value = true;

      if (!validateStep1() || !validateStep2() || !validateStep3()) {
        isLoading.value = false;
        isUploading.value = false;
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/projects/create'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descriptionController.text.trim();
      request.fields['category'] = selectedCategory.value!;
      request.fields['duration'] = selectedDuration.value;
      request.fields['experienceLevel'] = selectedExperience.value;
      request.fields['budgetType'] = budgetType.value;
      request.fields['minBudget'] = minBudgetController.text.trim();
      request.fields['maxBudget'] = maxBudgetController.text.trim();

      request.fields['skills'] = jsonEncode(skills.toList());
      request.fields['deliverables'] = jsonEncode(deliverables.toList());

      if (milestonesList.isNotEmpty) {
        List<Map<String, dynamic>> milestonesJson = [];
        
        for (var i = 0; i < milestonesList.length; i++) {
          var milestone = milestonesList[i];
          
          String title = milestone['title']?.toString() ?? '';
          String description = milestone['description']?.toString() ?? '';
          
          double amount = 0;
          if (milestone['amount'] != null) {
            if (milestone['amount'] is int) {
              amount = (milestone['amount'] as int).toDouble();
            } else if (milestone['amount'] is double) {
              amount = milestone['amount'];
            } else if (milestone['amount'] is String) {
              amount = double.tryParse(milestone['amount']) ?? 0;
            }
          }
          
          Map<String, dynamic> milestoneMap = {
            'title': title,
            'description': description,
            'amount': amount,
          };
          
          if (milestone.containsKey('dueDate') && milestone['dueDate'] != null) {
            if (milestone['dueDate'] is DateTime) {
              milestoneMap['dueDate'] = (milestone['dueDate'] as DateTime).toIso8601String();
            } else if (milestone['dueDate'] is String) {
              try {
                DateTime parsedDate = DateTime.parse(milestone['dueDate']);
                milestoneMap['dueDate'] = parsedDate.toIso8601String();
              } catch (e) {
                milestoneMap['dueDate'] = milestone['dueDate'];
              }
            }
          }
          
          milestonesJson.add(milestoneMap);
        }
        
        String milestonesJsonString = jsonEncode(milestonesJson);
        request.fields['milestones'] = milestonesJsonString;
      }

      await addFilesToRequest(request);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Connection timeout. Please check your internet connection.'),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          Get.snackbar(
            '✅ Success',
            responseData['message'] ?? 'Project created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          clearForm();

          Future.delayed(const Duration(seconds: 1), () {
            Get.back(result: responseData['project']);
          });
        } else {
          throw Exception(responseData['message'] ?? 'Failed to create project');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Server error: ${response.statusCode}');
        } catch (_) {
          throw Exception('Server error (${response.statusCode}). Please try again.');
        }
      }
    } on SocketException {
      Get.snackbar(
        '🔌 Connection Error',
        'Could not connect to server. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
      isUploading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    selectedCategory.value = null;
    selectedDuration.value = '3-6 months';
    selectedExperience.value = 'Expert';
    budgetType.value = 'FIXED';
    minBudgetController.clear();
    maxBudgetController.clear();
    skills.clear();
    deliverables.clear();
    mediaFiles.clear();
    selectedFiles.clear();
    selectedWebFiles.clear();
    milestonesList.clear();
    currentStep.value = 0;
    categorySearchController.clear();
    filteredCategories.value = allCategories;
    showCategoryList.value = false;
  }

  IconData getFileIcon(String fileName) {
    String extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color getFileColor(String fileName) {
    String extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Colors.red;
      case '.doc':
      case '.docx':
        return Colors.blue;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes / 1024).floor().bitLength;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Web Development':
        return Icons.web;
      case 'Mobile App Development':
        return Icons.phone_android;
      case 'UI/UX Design':
        return Icons.design_services;
      case 'Graphic Design':
        return Icons.brush;
      case 'Digital Marketing':
        return Icons.campaign;
      case 'Content Writing':
        return Icons.edit;
      default:
        return Icons.work;
    }
  }
}

class WebFileData {
  final String name;
  final int size;
  final Uint8List? bytes;
  final String extension;
  final PlatformFile? file;
  
  WebFileData({
    required this.name,
    required this.size,
    this.bytes,
    required this.extension,
    this.file,
  });
}
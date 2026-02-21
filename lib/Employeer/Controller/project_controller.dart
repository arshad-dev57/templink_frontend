import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/project_model.dart';
import 'package:templink/config/api_config.dart';

// ✅ NEW
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
  var selectedFiles = <PlatformFile>[].obs;
  var currentStep = 0.obs;

  // API Config
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    skills.clear();
    deliverables.clear();
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
    super.onClose();
  }

  void nextStep() {
    if (currentStep.value < 2) currentStep.value++;
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ============= MILESTONE VALIDATION WITH BUDGET =============
  bool validateMilestonesWithBudget() {
    if (budgetType.value == 'FIXED' && milestonesList.isNotEmpty) {
      final minBudget = double.tryParse(minBudgetController.text) ?? 0;
      final maxBudget = double.tryParse(maxBudgetController.text) ?? 0;
      
      final totalMilestones = milestonesList.fold<double>(
        0, (sum, m) => sum + (m['amount'] as double)
      );
      
      // Check if total milestones is within budget range
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

  // ============= SKILLS MANAGEMENT =============
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

  // ============= DELIVERABLES MANAGEMENT =============
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

  // ============= FILE PICK =============
  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: false,
      );

      if (result != null) {
        // ✅ Avoid duplicates by path/name
        for (final f in result.files) {
          final already =
              selectedFiles.any((x) => (x.path != null && x.path == f.path) || x.name == f.name);
          if (already) continue;

          selectedFiles.add(f);

          mediaFiles.add(
            MediaFile(
              fileName: f.name,
              fileUrl: f.path ?? '',
              fileType: _getFileType(f.extension ?? ''),
              publicId: null,
            ),
          );
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
  }

  // ============= FORM VALIDATION =============
  bool validateStep1() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('❌ Error', 'Project title is required',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (selectedCategory.value == null) {
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

    // Validate milestones against budget
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

    // ✅ REQUIRED: At least one file must be selected
    if (selectedFiles.isEmpty) {
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

      // Basic project fields
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

      // ==================== MILESTONES HANDLING ====================
      if (milestonesList.isNotEmpty) {
        List<Map<String, dynamic>> milestonesJson = [];
        
        for (var i = 0; i < milestonesList.length; i++) {
          var milestone = milestonesList[i];
          
          // Safely extract and convert values
          String title = milestone['title']?.toString() ?? '';
          String description = milestone['description']?.toString() ?? '';
          
          // Handle amount properly (convert to double)
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
          
          // Handle dueDate properly
          if (milestone.containsKey('dueDate') && milestone['dueDate'] != null) {
            if (milestone['dueDate'] is DateTime) {
              milestoneMap['dueDate'] = (milestone['dueDate'] as DateTime).toIso8601String();
            } else if (milestone['dueDate'] is String) {
              // If it's already a string, try to parse to ensure valid format
              try {
                DateTime parsedDate = DateTime.parse(milestone['dueDate']);
                milestoneMap['dueDate'] = parsedDate.toIso8601String();
              } catch (e) {
                // If parsing fails, use as is
                milestoneMap['dueDate'] = milestone['dueDate'];
              }
            }
          }
          
          milestonesJson.add(milestoneMap);
        }
        
        // Convert to JSON string
        String milestonesJsonString = jsonEncode(milestonesJson);
        request.fields['milestones'] = milestonesJsonString;
      }

      // ✅ ADD FILES WITH PROPER MIME TYPE
      for (final file in selectedFiles) {
        final filePath = file.path;
        if (filePath == null) continue;

        final exists = await File(filePath).exists();
        if (!exists) continue;

        final mediaType = _mediaTypeFromPath(filePath);

        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            filePath,
            filename: file.name,
            contentType: mediaType,
          ),
        );
      }

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

  // ============= CLEAR FORM =============
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
    milestonesList.clear();
    currentStep.value = 0;
  }

  // ============= UI HELPER METHODS =============
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
      case 'Mobile Development':
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
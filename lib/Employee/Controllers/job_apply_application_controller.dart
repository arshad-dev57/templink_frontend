import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/models/Employee_jobs_model.dart';
import 'package:templink/Employee/models/job_application_model.dart';
import 'package:templink/config/api_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class JobApplicationController extends GetxController {
  // Loading states
  var isApplying = false.obs;
  var applicationSuccess = false.obs;
  var errorMessage = ''.obs;

  // 👇 New: For fetching applications
  var isLoadingApplications = false.obs;
  var myApplications = <EmployeeApplication>[].obs;
  var applicationsSummary = Rxn<ApplicationSummary>();
  
  // Filter by status
  var selectedStatus = 'all'.obs;

  // Form fields
  final coverLetterController = TextEditingController();
  
  // 📁 File upload fields
  var selectedFile = Rxn<FilePickerResult>();
  var fileName = ''.obs;
  var fileSize = ''.obs;
  var isFileSelected = false.obs;

  final String baseUrl = ApiConfig.baseUrl;
  
  @override
  void onInit() {
    super.onInit();
    // Auto-fetch applications when controller initializes
    fetchMyApplications();
  }
  
  @override
  void onClose() {
    coverLetterController.dispose();
    super.onClose();
  }
  List<EmployeeApplication> get filteredApplications {
    if (selectedStatus.value == 'all') {
      return myApplications;
    }
    return myApplications.where((app) => app.status == selectedStatus.value).toList();
  }
  Future<void> fetchMyApplications() async {
    try {
      isLoadingApplications.value = true;
      errorMessage.value = '';
      String? token = await _getToken();
      if (token == null) {
        errorMessage.value = 'No authentication token found';
        return;
      }
      final response = await http.get(
        Uri.parse('$baseUrl/api/jobapplication/my'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Fetch Applications Response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          if (jsonResponse['summary'] != null) {
            applicationsSummary.value = ApplicationSummary.fromJson(jsonResponse['summary']);
          }
                    final List<dynamic> appsData = jsonResponse['data'] ?? [];
          myApplications.value = appsData
              .map((app) => EmployeeApplication.fromJson(app))
              .toList();
          
          print('✅ Loaded ${myApplications.length} applications');
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Failed to load applications';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      print('❌ Fetch applications error: $e');
    } finally {
      isLoadingApplications.value = false;
    }
  }

  Future<void> refreshApplications() async {
    await fetchMyApplications();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
  }

  EmployeeApplication? getApplicationById(String applicationId) {
    try {
      return myApplications.firstWhere((app) => app.id == applicationId);
    } catch (e) {
      return null;
    }
  }
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'shortlisted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
     
      default:
        return Colors.grey;
    }
  }
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'reviewed':
        return Icons.visibility;
      case 'shortlisted':
        return Icons.star;
      case 'rejected':
        return Icons.cancel;
     
      default:
        return Icons.help;
    }
  }
  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'reviewed':
        return 'Reviewed';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Not Selected';
    
      default:
        return status;
    }
  }
// ============== MARK JOB AS LEFT ==============
Future<void> markJobAsLeft(String applicationId, String reason) async {
  try {
    isLoadingApplications.value = true;

    String? token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/applications/$applicationId/left'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      // ✅ Force refresh from backend
      await fetchMyApplications();
      
      Get.snackbar(
        'Success',
        'Job marked as left',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      throw Exception('Failed to update');
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      e.toString(),
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoadingApplications.value = false;
  }
}  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String getFileExtension(String filename) {
    return filename.split('.').last.toUpperCase();
  }
  Future<void> pickResumeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null) {
        selectedFile.value = result;
        fileName.value = result.files.single.name;
                int bytes = result.files.single.size;
        if (bytes < 1024) {
          fileSize.value = '$bytes B';
        } else if (bytes < 1024 * 1024) {
          fileSize.value = '${(bytes / 1024).toStringAsFixed(1)} KB';
        } else {
          fileSize.value = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
        
        isFileSelected.value = true;
        
        Get.snackbar(
          '✅ File Selected',
          '${fileName.value} (${fileSize.value})',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('File pick error: $e');
      showError('Failed to pick file');
    }
  }

  // Clear selected file
  void clearFile() {
    selectedFile.value = null;
    fileName.value = '';
    fileSize.value = '';
    isFileSelected.value = false;
  }

  // Clear form for next use
  void clearForm() {
    coverLetterController.clear();
    clearFile();
    errorMessage.value = '';
    applicationSuccess.value = false;
  }

  // ============== APPLY FOR JOB WITH FILE UPLOAD ==============
  Future<void> applyForJob(String jobId) async {
    // Validate file selected
    if (!isFileSelected.value || selectedFile.value == null) {
      errorMessage.value = 'Please select your resume file';
      Get.snackbar(
        '📄 Resume Required',
        errorMessage.value,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      isApplying.value = true;
      errorMessage.value = '';

      // Get token
      String? token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/jobapplication/apply/$jobId'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add file
      FilePickerResult fileResult = selectedFile.value!;
      PlatformFile platformFile = fileResult.files.first;
      
      // Get file bytes
      Uint8List fileBytes;
      if (platformFile.bytes != null) {
        fileBytes = platformFile.bytes!;
      } else {
        // Read from path for web/desktop
        File file = File(platformFile.path!);
        fileBytes = await file.readAsBytes();
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'resume',  // Field name should match backend
          fileBytes,
          filename: platformFile.name,
        ),
      );

      // Add cover letter if present
      if (coverLetterController.text.trim().isNotEmpty) {
        request.fields['coverLetter'] = coverLetterController.text.trim();
      }

      print('📤 Sending application for job: $jobId');
      print('📤 File: ${platformFile.name} (${platformFile.size} bytes)');

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Response: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      if (response.statusCode == 201) {
        applicationSuccess.value = true;
        clearForm();
        
        // Refresh applications list after successful application
        fetchMyApplications();

        Get.snackbar(
          '✅ Success!',
          'Application submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );
      } else {
        var responseData = jsonDecode(response.body);
        errorMessage.value = responseData['message'] ?? 'Failed to apply';
        
        Get.snackbar(
          '❌ Application Failed',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      
      Get.snackbar(
        '❌ Error',
        'Something went wrong: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isApplying.value = false;
    }
  }

  // Token get karne ka function
  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Success dialog
  void showSuccessDialog(BuildContext context, JobPostModel job) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your application has been successfully submitted.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                job.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to previous screen
            },
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Error snackbar
  void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
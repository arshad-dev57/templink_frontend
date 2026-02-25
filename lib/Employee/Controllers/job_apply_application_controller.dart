import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/models/Employee_jobs_model.dart';
import 'package:templink/config/api_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class JobApplicationController extends GetxController {
  // Loading states
  var isApplying = false.obs;
  var applicationSuccess = false.obs;
  var errorMessage = ''.obs;

  // Form fields
  final coverLetterController = TextEditingController();
  
  // 📁 File upload fields
  var selectedFile = Rxn<FilePickerResult>();
  var fileName = ''.obs;
  var fileSize = ''.obs;
  var isFileSelected = false.obs;

  final String baseUrl = ApiConfig.baseUrl;
  
  @override
  void onClose() {
    coverLetterController.dispose();
    super.onClose();
  }

  // ============== FILE PICKER ==============
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
        
        // Format file size
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

      // Create multipart request
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
        
        // Clear form after success
        clearForm();

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
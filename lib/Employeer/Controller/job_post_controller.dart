// lib/Controllers/job_post_controller.dart

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:flutter/material.dart';

class JobPostController extends GetxController {
  var isLoading = false.obs;
  var isPublishing = false.obs;
  var errorMessage = ''.obs;
  
  // Form fields
  var jobTitle = ''.obs;
  var company = ''.obs;
  var selectedWorkplace = 'Remote'.obs;
  var jobLocation = ''.obs;
  var selectedJobType = 'Full Time'.obs;
  var aboutJob = ''.obs;
  var keyRequirements = ''.obs;
  var qualifications = ''.obs;
  
  // Salary fields
  var minSalary = ''.obs;
  var maxSalary = ''.obs;
  var salaryType = ''.obs;
  var currency = ''.obs;
  
  // Success message
  var successMessage = ''.obs;
  
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    clearForm();
  }

  Future<void> postJob() async {
    try {
      isPublishing.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      
      print("\n🟡 ===== POSTING JOB STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'No auth token found. Please login again.';
        Get.snackbar(
          'Authentication Error',
          'Please login again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Prepare job data according to backend schema
      final jobData = {
        'title': jobTitle.value,
        'company': company.value,
        'workplace': selectedWorkplace.value,
        'location': jobLocation.value,
        'type': selectedJobType.value,
        'about': aboutJob.value,
        'requirements': keyRequirements.value,
        'qualifications': qualifications.value,
        // Salary fields are optional, only include if provided
        if (minSalary.value.isNotEmpty) 'minSalary': minSalary.value,
        if (maxSalary.value.isNotEmpty) 'maxSalary': maxSalary.value,
        if (salaryType.value.isNotEmpty) 'salaryType': salaryType.value,
        if (currency.value.isNotEmpty) 'currency': currency.value,
        // Images array - empty as per requirement
        'images': [],
      };

      print("📤 Sending job data: ${json.encode(jobData)}");

      final response = await http.post(
        Uri.parse('$baseUrl/api/jobposts/job'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(jobData),
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        successMessage.value = responseData['message'] ?? 'Job posted successfully!';
        
        Get.snackbar(
          'Success',
          successMessage.value,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        
        print("✅ Job posted successfully");
        
      } else {
        final responseData = jsonDecode(response.body);
        errorMessage.value = responseData['message'] ?? 'Failed to post job';
        
        Get.snackbar(
          'Error',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        print("❌ Error: ${errorMessage.value}");
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("❌ Exception: $e");
      
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isPublishing.value = false;
      print("🟢 ===== POSTING JOB ENDED =====");
    }
  }

  void clearForm() {
    jobTitle.value = '';
    company.value = '';
    selectedWorkplace.value = 'Remote';
    jobLocation.value = '';
    selectedJobType.value = 'Full Time';
    aboutJob.value = '';
    keyRequirements.value = '';
    qualifications.value = '';
    minSalary.value = '';
    maxSalary.value = '';
    salaryType.value = '';
    currency.value = '';
    errorMessage.value = '';
    successMessage.value = '';
  }

  bool validateForm() {
    if (jobTitle.value.isEmpty) {
      errorMessage.value = 'Job title is required';
      return false;
    }
    if (aboutJob.value.isEmpty) {
      errorMessage.value = 'About the job description is required';
      return false;
    }
    return true;
  }
}
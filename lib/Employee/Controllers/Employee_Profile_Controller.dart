import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:flutter/material.dart';

class EmployeeProfileController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var isUploading = false.obs;
  var profile = Rx<Map<String, dynamic>>({});
  var errorMessage = ''.obs;
  
  // Profile data - FIXED: Saare RxString theek karo
  var firstName = ''.obs;
  var lastName = ''.obs;
  var email = ''.obs;
  var country = ''.obs;
  var title = ''.obs;
  var bio = ''.obs;
  var hourlyRate = ''.obs;
  var skills = <String>[].obs;
  var experienceLevel = ''.obs;
  var category = ''.obs;
  var photoUrl = ''.obs;
  var pointsBalance = 0.obs;
  
  // Work experiences
  var workExperiences = <Map<String, dynamic>>[].obs;
  var educations = <Map<String, dynamic>>[].obs;
  var portfolioProjects = <Map<String, dynamic>>[].obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // ==================== FETCH PROFILE ====================
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== FETCH EMPLOYEE PROFILE STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      print("🔑 Token exists: ${token != null}");
      print("🌐 URL: $baseUrl/api/employee-profile/profile");

      final response = await http.get(
        Uri.parse('$baseUrl/api/employee-profile/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Profile fetched successfully");
        
        if (jsonResponse['success'] == true) {
          final profileData = jsonResponse['profile'];
          profile.value = profileData;
          
          // Update observables - FIXED: .value use karo
          firstName.value = profileData['firstName'] ?? '';
          lastName.value = profileData['lastName'] ?? '';
          email.value = profileData['email'] ?? '';
          country.value = profileData['country'] ?? '';
          pointsBalance.value = profileData['pointsBalance'] ?? 0;
          
          // Employee profile data
          final empProfile = profileData['employeeProfile'] ?? {};
          title.value = empProfile['title'] ?? '';
          bio.value = empProfile['bio'] ?? '';
          hourlyRate.value = empProfile['hourlyRate']?.toString() ?? '';
          experienceLevel.value = empProfile['experienceLevel'] ?? '';
          category.value = empProfile['category'] ?? '';
          photoUrl.value = empProfile['photoUrl'] ?? '';
          
          // Arrays
          skills.value = List<String>.from(empProfile['skills'] ?? []);
          workExperiences.value = List<Map<String, dynamic>>.from(empProfile['workExperiences'] ?? []);
          educations.value = List<Map<String, dynamic>>.from(empProfile['educations'] ?? []);
          portfolioProjects.value = List<Map<String, dynamic>>.from(empProfile['portfolioProjects'] ?? []);
          
          print("📊 Profile loaded: ${firstName.value} ${lastName.value}");
          print("📊 Skills count: ${skills.length}");
          print("📊 Work experiences: ${workExperiences.length}");
        }
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Failed to load profile';
        print("❌ Error: ${errorMessage.value}");
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
      print("🟢 ===== FETCH PROFILE ENDED =====");
    }
  }

  // ==================== UPDATE PROFILE ====================
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== UPDATE PROFILE STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.put(
        Uri.parse('$baseUrl/api/employee/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          print("✅ Profile updated successfully");
          await fetchProfile(); // Refresh profile
          
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print("❌ Error updating profile: $e");
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== UPLOAD PROFILE PICTURE ====================
  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      isUploading.value = true;
      
      print("\n🟡 ===== UPLOAD PROFILE PICTURE STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/employee/profile/picture'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        String newPhotoUrl = jsonResponse['photoUrl'];
        photoUrl.value = newPhotoUrl;  // ✅ FIXED: .value use karo
        
        print("✅ Profile picture uploaded: $newPhotoUrl");
        
        Get.snackbar(
          'Success',
          'Profile picture updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return newPhotoUrl;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print("❌ Error uploading picture: $e");
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  // ==================== ADD WORK EXPERIENCE ====================
  Future<bool> addWorkExperience(Map<String, dynamic> experience) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.post(
        Uri.parse('$baseUrl/api/employee/work-experience'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(experience),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          await fetchProfile();
          Get.snackbar('Success', 'Work experience added');
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error adding work experience: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== DELETE WORK EXPERIENCE ====================
  Future<bool> deleteWorkExperience(String experienceId) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.delete(
        Uri.parse('$baseUrl/api/employee/work-experience/$experienceId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Work experience deleted');
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting work experience: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Helper getters - FIXED: .value use karo
  String get fullName => '${firstName.value} ${lastName.value}'.trim();
  
  String get displayName => fullName.isNotEmpty ? fullName : 'Employee';
  
  String get initials {
    if (firstName.value.isNotEmpty && lastName.value.isNotEmpty) {
      return '${firstName.value[0]}${lastName.value[0]}'.toUpperCase();
    } else if (firstName.value.isNotEmpty) {
      return firstName.value[0].toUpperCase();
    } else if (email.value.isNotEmpty) {
      return email.value[0].toUpperCase();
    }
    return 'E';
  }

  double get parsedHourlyRate {
    try {
      return double.parse(hourlyRate.value);
    } catch (e) {
      return 0.0;
    }
  }
}
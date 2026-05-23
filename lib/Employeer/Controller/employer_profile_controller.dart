// lib/Employeer/Controller/employer_profile_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:flutter/material.dart';

class EmployerProfileController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var isLoadingProjects = false.obs;
  var isLoadingJobs = false.obs;
  var isUploading = false.obs;
  var profile = Rx<Map<String, dynamic>>({});
  var errorMessage = ''.obs;
  
  // Profile data
  var companyName = ''.obs;
  var industry = ''.obs;
  var city = ''.obs;
  var country = ''.obs;
  var companySize = ''.obs;
  var workModel = ''.obs;
  var logoUrl = ''.obs;
  var phone = ''.obs;
  var companyEmail = ''.obs;
  var website = ''.obs;
  var linkedin = ''.obs;
  var about = ''.obs;
  var mission = ''.obs;
  var isVerified = false.obs;
  var rating = 0.0.obs;
  var pointsBalance = 0.obs;
  
  // Arrays
  var cultureTags = <String>[].obs;
  var teamMembers = <Map<String, dynamic>>[].obs;
  
  // Stats
  var activePosts = '0'.obs;
  var totalHired = '0'.obs;
  var companySizeLabel = '1-10'.obs;
  var ratingDisplay = '0★'.obs;

  // Projects
  var projects = <Map<String, dynamic>>[].obs;
  var filteredProjects = <Map<String, dynamic>>[].obs;
  var totalProjects = 0.obs;
  var activeProjects = 0.obs;
  var completedProjects = 0.obs;
  var totalProposals = 0.obs;

  // Jobs
  var jobs = <Map<String, dynamic>>[].obs;
  var filteredJobs = <Map<String, dynamic>>[].obs;
  var totalJobs = 0.obs;
  var activeJobs = 0.obs;
  var jobTypes = <String>[].obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // ==================== FETCH PROFILE (FIXED) ====================
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== FETCH EMPLOYER PROFILE STARTED =====");
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        isLoading.value = false;
        return;
      }
      
      print("🌐 URL: $baseUrl/api/employer/profile");

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Profile fetched successfully");
        
        if (jsonResponse['success'] == true) {
          final profileData = jsonResponse['profile'];
          profile.value = profileData;
          
          // ✅ FIX: Safe access with null checks
          final empProfile = profileData['employerProfile'] ?? {};
          
          print("📊 employerProfile exists: ${empProfile.isNotEmpty}");
          print("📊 companyName: ${empProfile['companyName']}");
          
          // Update all observables with null safety
          companyName.value = empProfile['companyName']?.toString() ?? '';
          industry.value = empProfile['industry']?.toString() ?? '';
          city.value = empProfile['city']?.toString() ?? '';
          country.value = empProfile['country']?.toString() ?? '';
          companySize.value = empProfile['companySize']?.toString() ?? '';
          workModel.value = empProfile['workModel']?.toString() ?? '';
          logoUrl.value = empProfile['logoUrl']?.toString() ?? '';
          phone.value = empProfile['phone']?.toString() ?? '';
          companyEmail.value = empProfile['companyEmail']?.toString() ?? '';
          website.value = empProfile['website']?.toString() ?? '';
          linkedin.value = empProfile['linkedin']?.toString() ?? '';
          about.value = empProfile['about']?.toString() ?? '';
          mission.value = empProfile['mission']?.toString() ?? '';
          isVerified.value = empProfile['isVerifiedEmployer'] ?? false;
          rating.value = (empProfile['rating'] ?? 0).toDouble();
          pointsBalance.value = profileData['pointsBalance'] ?? 0;
          
          // Handle culture tags
          final cultureList = empProfile['cultureTags'];
          if (cultureList != null && cultureList is List) {
            cultureTags.value = List<String>.from(cultureList);
          } else {
            cultureTags.value = [];
          }
          
          // Handle team members
          final teamList = empProfile['teamMembers'];
          if (teamList != null && teamList is List) {
            teamMembers.value = List<Map<String, dynamic>>.from(teamList);
          } else {
            teamMembers.value = [];
          }
          
          // Handle stats
          final stats = profileData['stats'] ?? {};
          activePosts.value = stats['activeProjects']?.toString() ?? '0';
          totalHired.value = stats['totalHired']?.toString() ?? '0';
          companySizeLabel.value = empProfile['companySize']?.toString() ?? '1-10';
          ratingDisplay.value = rating.value > 0 ? '${rating.value.toStringAsFixed(1)}★' : '0★';
          
          print("📊 Profile loaded: ${companyName.value}");
          print("📊 Team members: ${teamMembers.length}");
          print("📊 About length: ${about.value.length}");
        } else {
          print("❌ API returned success false: ${jsonResponse['message']}");
          errorMessage.value = jsonResponse['message'] ?? 'Failed to load profile';
        }
      } else {
        final errorText = response.body;
        print("❌ Error response: $errorText");
        try {
          final error = jsonDecode(errorText);
          errorMessage.value = error['message'] ?? 'Failed to load profile';
        } catch (e) {
          errorMessage.value = 'Failed to load profile. Status: ${response.statusCode}';
        }
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

  // ==================== UPDATE PROFILE FROM EDIT SCREEN (FIXED) ====================
  Future<bool> updateProfileFromEdit({
    required String companyName,
    required String industry,
    required String location,
    required String companySize,
    required String website,
    required String about,
    File? logoImage,
    String? mission,
    String? phone,
    String? companyEmail,
    String? linkedin,
    String? workModel,
  }) async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== UPDATE PROFILE FROM EDIT STARTED =====");
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        isLoading.value = false;
        return false;
      }

      // Split location into city and country
      String city = location;
      String countryValue = this.country.value;
      
      if (location.contains(',')) {
        final parts = location.split(',').map((e) => e.trim()).toList();
        city = parts[0];
        if (parts.length > 1) {
          countryValue = parts[1];
        }
      }

      // Upload logo if selected
      String? uploadedLogoUrl;
      if (logoImage != null) {
        uploadedLogoUrl = await uploadCompanyLogo(logoImage.path);
        if (uploadedLogoUrl == null) {
          print("⚠️ Logo upload failed but continuing with profile update");
        }
      }

      // Prepare profile data for API
      final Map<String, dynamic> profileData = {
        'companyName': companyName,
        'industry': industry,
        'city': city,
        'country': countryValue,
        'companySize': companySize,
        'website': website,
        'about': about,
      };
      
      // Add optional fields if they have values
      if (uploadedLogoUrl != null && uploadedLogoUrl.isNotEmpty) {
        profileData['logoUrl'] = uploadedLogoUrl;
      }
      if (mission != null && mission.isNotEmpty) {
        profileData['mission'] = mission;
      }
      if (phone != null && phone.isNotEmpty) {
        profileData['phone'] = phone;
      }
      if (companyEmail != null && companyEmail.isNotEmpty) {
        profileData['companyEmail'] = companyEmail;
      }
      if (linkedin != null && linkedin.isNotEmpty) {
        profileData['linkedin'] = linkedin;
      }
      if (workModel != null && workModel.isNotEmpty) {
        profileData['workModel'] = workModel;
      }

      print("📦 Profile Data being sent: $profileData");

      // Update profile via API
      final response = await http.put(
        Uri.parse('$baseUrl/api/employer/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          print("✅ Profile updated successfully");
          
          // Refresh profile data
          await fetchProfile();
          
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          
          return true;
        } else {
          print("❌ API returned success false: ${jsonResponse['message']}");
          Get.snackbar(
            'Error',
            jsonResponse['message'] ?? 'Failed to update profile',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else {
        final errorText = response.body;
        print("❌ Failed to update profile: ${response.statusCode}");
        print("❌ Error body: $errorText");
        
        String errorMessage = 'Failed to update profile. Please try again.';
        try {
          final errorJson = jsonDecode(errorText);
          if (errorJson['message'] != null) {
            errorMessage = errorJson['message'];
          }
        } catch (e) {
          // Ignore JSON parse error
        }
        
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print("❌ Exception updating profile: $e");
      Get.snackbar(
        'Error', 
        'Network error: $e', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
      print("🟢 ===== UPDATE PROFILE ENDED =====");
    }
  }

  // ==================== UPLOAD COMPANY LOGO ====================
  Future<String?> uploadCompanyLogo(String imagePath) async {
    try {
      isUploading.value = true;
      
      print("\n🟡 ===== UPLOAD COMPANY LOGO STARTED =====");
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return null;
      }

      final file = File(imagePath);
      if (!await file.exists()) {
        print("❌ File does not exist: $imagePath");
        return null;
      }

      final ext = imagePath.split('.').last.toLowerCase();
      MediaType mediaType;
      
      if (ext == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mediaType = MediaType('image', 'jpeg');
      } else if (ext == 'gif') {
        mediaType = MediaType('image', 'gif');
      } else if (ext == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else {
        mediaType = MediaType('image', 'jpeg');
      }

      final url = '$baseUrl/api/employer/profile/logo';
      print("🌐 URL: $url");

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'logo',
          imagePath,
          contentType: mediaType,
        ),
      );

      print("📤 Sending request...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("📡 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          String newLogoUrl = jsonResponse['logoUrl'] ?? jsonResponse['url'] ?? '';
          if (newLogoUrl.isNotEmpty) {
            logoUrl.value = newLogoUrl;
            print("✅ Logo uploaded successfully: $newLogoUrl");
            return newLogoUrl;
          }
        }
      }
      
      print("❌ Logo upload failed");
      return null;
    } catch (e) {
      print("❌ Exception uploading logo: $e");
      return null;
    } finally {
      isUploading.value = false;
      print("🟢 ===== UPLOAD COMPANY LOGO ENDED =====");
    }
  }

  // ==================== FETCH MY PROJECTS ====================
  Future<void> fetchMyProjects() async {
    try {
      isLoadingProjects.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/my-projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['projects'] != null) {
          projects.value = List<Map<String, dynamic>>.from(jsonResponse['projects']);
          filteredProjects.value = projects;
          totalProjects.value = jsonResponse['total'] ?? projects.length;
          _calculateProjectStats();
        }
      }
    } catch (e) {
      print("❌ Exception fetching projects: $e");
    } finally {
      isLoadingProjects.value = false;
    }
  }

  // ==================== FETCH MY JOBS ====================
  Future<void> fetchMyJobs() async {
    try {
      isLoadingJobs.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/jobposts/my-jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['jobs'] != null) {
          jobs.value = List<Map<String, dynamic>>.from(jsonResponse['jobs']);
          filteredJobs.value = jobs;
          totalJobs.value = jsonResponse['count'] ?? jobs.length;
          
          activeJobs.value = jobs.where((j) => 
            j['status'] == 'active' || j['status'] == null
          ).length;
          
          final types = jobs.map((j) => j['type']?.toString() ?? '').toSet().toList();
          jobTypes.value = types.where((t) => t.isNotEmpty).toList();
        }
      }
    } catch (e) {
      print("❌ Exception fetching jobs: $e");
    } finally {
      isLoadingJobs.value = false;
    }
  }

  // ==================== FETCH MY JOBS PAGINATED ====================
  var jobsCurrentPage = 1.obs;
  var jobsTotalPages = 1.obs;
  var jobsTotalCount = 0.obs;
  var jobsLimit = 10.obs;
  var isLoadingMoreJobs = false.obs;

  Future<void> fetchMyJobsPaginated({
    int page = 1,
    int limit = 10,
    bool resetList = true,
  }) async {
    try {
      if (resetList) {
        isLoadingJobs.value = true;
      } else {
        isLoadingMoreJobs.value = true;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/jobposts/my-jobs?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['jobs'] != null) {
          final newJobs = List<Map<String, dynamic>>.from(jsonResponse['jobs']);
          
          if (resetList) {
            jobs.value = newJobs;
          } else {
            jobs.addAll(newJobs);
          }
          
          filteredJobs.value = jobs;
          
          if (jsonResponse['pagination'] != null) {
            jobsCurrentPage.value = jsonResponse['pagination']['currentPage'] ?? page;
            jobsTotalPages.value = jsonResponse['pagination']['totalPages'] ?? 1;
            jobsTotalCount.value = jsonResponse['pagination']['totalItems'] ?? jobs.length;
          } else {
            jobsTotalCount.value = jsonResponse['count'] ?? jobs.length;
            jobsTotalPages.value = (jobsTotalCount.value / limit).ceil();
          }
          
          activeJobs.value = jobs.where((j) => 
            j['status'] == 'active' || j['status'] == null
          ).length;
        }
      }
    } catch (e) {
      print("❌ Exception fetching jobs: $e");
    } finally {
      isLoadingJobs.value = false;
      isLoadingMoreJobs.value = false;
    }
  }

  void _calculateProjectStats() {
    activeProjects.value = projects.where((p) => 
      p['status'] == 'OPEN' || p['status'] == 'IN_PROGRESS' || p['status'] == 'AWAITING_FUNDING'
    ).length;
    
    completedProjects.value = projects.where((p) => 
      p['status'] == 'COMPLETED'
    ).length;
    
    totalProposals.value = projects.fold(0, (sum, p) => 
      sum + (p['proposalsCount'] as int? ?? 0)
    );
  }

  // ==================== HELPER METHODS ====================
  void filterJobs(String query) {
    if (query.isEmpty) {
      filteredJobs.value = jobs;
    } else {
      final searchTerm = query.toLowerCase();
      filteredJobs.value = jobs.where((j) {
        final title = j['title']?.toString().toLowerCase() ?? '';
        final company = j['company']?.toString().toLowerCase() ?? '';
        return title.contains(searchTerm) || company.contains(searchTerm);
      }).toList();
    }
  }

  void filterJobsByType(String type) {
    if (type == 'All') {
      filteredJobs.value = jobs;
    } else {
      filteredJobs.value = jobs.where((j) => j['type'] == type).toList();
    }
  }

  Color getJobStatusColor(String status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'paused': return Colors.orange;
      case 'closed': return Colors.red;
      case 'expired': return Colors.grey;
      default: return Colors.blue;
    }
  }

  String getJobStatusText(String status) {
    switch (status) {
      case 'active': return 'Active';
      case 'paused': return 'Paused';
      case 'closed': return 'Closed';
      case 'expired': return 'Expired';
      default: return status;
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '$difference days ago';
      if (difference < 30) return '${(difference / 7).round()} weeks ago';
      if (difference < 365) return '${(difference / 30).round()} months ago';
      return '${(difference / 365).round()} years ago';
    } catch (e) {
      return 'Unknown';
    }
  }

  String formatJobSalary(Map<String, dynamic> job) {
    final salary = job['salary'];
    if (salary == null) return 'Not specified';
    
    if (salary is Map) {
      final min = salary['min'];
      final max = salary['max'];
      if (min != null && max != null) {
        return '\$${min} - \$${max}';
      }
    }
    return salary.toString();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'OPEN': return Colors.green;
      case 'IN_PROGRESS': return Colors.blue;
      case 'COMPLETED': return Colors.teal;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'OPEN': return 'Open';
      case 'IN_PROGRESS': return 'In Progress';
      case 'COMPLETED': return 'Completed';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }

  String formatBudget(num min, num max, String type) {
    if (type == 'FIXED') {
      return '\$${min.round()} - \$${max.round()}';
    } else {
      return '\$${min.round()}/hr - \$${max.round()}/hr';
    }
  }

  String get fullCompanyLocation {
    final cityVal = city.value.trim();
    final countryVal = country.value.trim();
    if (cityVal.isNotEmpty && countryVal.isNotEmpty) {
      return '$cityVal, $countryVal';
    } else if (cityVal.isNotEmpty) {
      return cityVal;
    } else if (countryVal.isNotEmpty) {
      return countryVal;
    }
    return 'Location not set';
  }
  
  String get companyInitials {
    if (companyName.value.isNotEmpty) {
      final words = companyName.value.trim().split(' ');
      if (words.length > 1) {
        final firstInitial = words[0].isNotEmpty ? words[0][0] : '';
        final secondInitial = words[1].isNotEmpty ? words[1][0] : '';
        if (firstInitial.isNotEmpty && secondInitial.isNotEmpty) {
          return '$firstInitial$secondInitial'.toUpperCase();
        }
      }
      if (words.isNotEmpty && words[0].isNotEmpty) {
        return words[0][0].toUpperCase();
      }
    }
    return 'C';
  }

  Future<bool> deleteJobPost(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return false;
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/jobposts/job/$jobId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        jobs.removeWhere((job) => job['_id'] == jobId);
        filteredJobs.removeWhere((job) => job['_id'] == jobId);
        totalJobs.value = jobs.length;
        activeJobs.value = jobs.where((j) => 
          j['status'] == 'active' || j['status'] == null
        ).length;
        
        Get.snackbar('Success', 'Job deleted successfully', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Exception deleting job: $e");
      return false;
    }
  }

  Future<bool> pauseJobPost(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return false;
      
      final response = await http.patch(
        Uri.parse('$baseUrl/api/jobposts/job/$jobId/pause'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jobIndex = jobs.indexWhere((job) => job['_id'] == jobId);
        if (jobIndex != -1) {
          jobs[jobIndex]['status'] = 'paused';
          jobs.refresh();
        }
        activeJobs.value = jobs.where((j) => 
          j['status'] == 'active' || j['status'] == null
        ).length;
        
        Get.snackbar('Success', 'Job paused successfully', backgroundColor: Colors.orange, colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Exception pausing job: $e");
      return false;
    }
  }

  Future<bool> resumeJobPost(String jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return false;
      
      final response = await http.patch(
        Uri.parse('$baseUrl/api/jobposts/job/$jobId/resume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jobIndex = jobs.indexWhere((job) => job['_id'] == jobId);
        if (jobIndex != -1) {
          jobs[jobIndex]['status'] = 'active';
          jobs.refresh();
        }
        activeJobs.value = jobs.where((j) => 
          j['status'] == 'active' || j['status'] == null
        ).length;
        
        Get.snackbar('Success', 'Job resumed successfully', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Exception resuming job: $e");
      return false;
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return false;
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/projects/$projectId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        projects.removeWhere((project) => project['_id'] == projectId);
        filteredProjects.removeWhere((project) => project['_id'] == projectId);
        totalProjects.value = projects.length;
        _calculateProjectStats();
        
        Get.snackbar('Success', 'Project deleted successfully', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Exception deleting project: $e");
      return false;
    }
  }
}
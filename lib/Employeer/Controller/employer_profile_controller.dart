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
  
  // Arrays - Initialize with empty lists
  var cultureTags = <String>[].obs;
  var teamMembers = <Map<String, dynamic>>[].obs;
  
  // Stats
  var activePosts = '24'.obs;
  var totalHired = '1.2k'.obs;
  var companySizeLabel = '250+'.obs;
  var ratingDisplay = '4.8★'.obs;

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
    fetchMyProjects();
    fetchMyJobs();
  }

  // ==================== FETCH PROFILE ====================
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== FETCH EMPLOYER PROFILE STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      print("🔑 Token exists: ${token != null}");
      print("🌐 URL: $baseUrl/api/employer/profile");

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer/profile'),
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
          
          // Safely extract employer profile with null checks
          final empProfile = profileData['employerProfile'] ?? {};
          
          // Update observables with safe fallbacks
          companyName.value = empProfile['companyName']?.toString() ?? 'Company Name';
          industry.value = empProfile['industry']?.toString() ?? 'Industry';
          city.value = empProfile['city']?.toString() ?? 'City';
          country.value = empProfile['country']?.toString() ?? profileData['country'] ?? 'Country';
          companySize.value = empProfile['companySize']?.toString() ?? '1-10';
          workModel.value = empProfile['workModel']?.toString() ?? 'Remote';
          logoUrl.value = empProfile['logoUrl']?.toString() ?? '';
          phone.value = empProfile['phone']?.toString() ?? '';
          companyEmail.value = empProfile['companyEmail']?.toString() ?? '';
          website.value = empProfile['website']?.toString() ?? '';
          linkedin.value = empProfile['linkedin']?.toString() ?? '';
          about.value = empProfile['about']?.toString() ?? 
              'Company description not provided.';
          mission.value = empProfile['mission']?.toString() ?? '';
          isVerified.value = empProfile['isVerifiedEmployer'] ?? false;
          rating.value = (empProfile['rating'] ?? 4.8).toDouble();
          pointsBalance.value = profileData['pointsBalance'] ?? 0;
          
          // Safely handle arrays with empty list fallback
          final cultureList = empProfile['cultureTags'];
          if (cultureList != null && cultureList is List) {
            cultureTags.value = List<String>.from(cultureList);
          } else {
            cultureTags.value = []; // Empty list if null
          }
          
          final teamList = empProfile['teamMembers'];
          if (teamList != null && teamList is List) {
            teamMembers.value = List<Map<String, dynamic>>.from(teamList);
          } else {
            teamMembers.value = []; // Empty list if null
          }
          
          // Stats from API or use defaults
          final stats = profileData['stats'] ?? {};
          activePosts.value = stats['activeProjects']?.toString() ?? '24';
          totalHired.value = stats['totalHired']?.toString() ?? '1.2k';
          companySizeLabel.value = empProfile['companySize']?.toString() ?? '250+';
          ratingDisplay.value = '${rating.value.toStringAsFixed(1)}★';
          
          print("📊 Profile loaded: $companyName");
          print("📊 Team members: ${teamMembers.length}");
          print("📊 Culture tags: ${cultureTags.length}");
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

  // ==================== FETCH MY PROJECTS ====================
  Future<void> fetchMyProjects() async {
    try {
      isLoadingProjects.value = true;
      
      print("\n🟡 ===== FETCH EMPLOYER PROJECTS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      print("🌐 URL: $baseUrl/api/projects/my-projects");

      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/my-projects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Projects fetched successfully");
        
        if (jsonResponse['projects'] != null) {
          projects.value = List<Map<String, dynamic>>.from(jsonResponse['projects']);
          filteredProjects.value = projects;
          totalProjects.value = jsonResponse['total'] ?? projects.length;
          
          // Calculate stats
          _calculateProjectStats();
          
          print("📊 Total projects: ${projects.length}");
        }
      } else {
        final error = jsonDecode(response.body);
        print("❌ Error: ${error['message'] ?? 'Failed to load projects'}");
      }
    } catch (e) {
      print("❌ Exception fetching projects: $e");
    } finally {
      isLoadingProjects.value = false;
      print("🟢 ===== FETCH PROJECTS ENDED =====");
    }
  }

  // ==================== FETCH MY JOBS ====================
  Future<void> fetchMyJobs() async {
    try {
      isLoadingJobs.value = true;
      
      print("\n🟡 ===== FETCH MY JOBS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      print("🌐 URL: $baseUrl/api/jobposts/my-jobs");

      final response = await http.get(
        Uri.parse('$baseUrl/api/jobposts/my-jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ My jobs fetched successfully");
        
        if (jsonResponse['jobs'] != null) {
          jobs.value = List<Map<String, dynamic>>.from(jsonResponse['jobs']);
          filteredJobs.value = jobs;
          totalJobs.value = jsonResponse['count'] ?? jobs.length;
          
          // Calculate active jobs
          activeJobs.value = jobs.where((j) => 
            j['status'] == 'active' || j['status'] == null
          ).length;
          
          // Extract unique job types
          final types = jobs.map((j) => j['type']?.toString() ?? '').toSet().toList();
          jobTypes.value = types.where((t) => t.isNotEmpty).toList();
          
          print("📊 Total my jobs: ${jobs.length}");
        }
      } else {
        print("❌ Failed to load my jobs: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception fetching my jobs: $e");
    } finally {
      isLoadingJobs.value = false;
      print("🟢 ===== FETCH MY JOBS ENDED =====");
    }
  }

  // ==================== CALCULATE PROJECT STATS ====================
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

  // ==================== FILTER PROJECTS ====================
  void filterProjects(String query) {
    if (query.isEmpty) {
      filteredProjects.value = projects;
    } else {
      final searchTerm = query.toLowerCase();
      filteredProjects.value = projects.where((p) {
        final title = p['title']?.toString().toLowerCase() ?? '';
        final category = p['category']?.toString().toLowerCase() ?? '';
        final skills = p['skills'] as List? ?? [];
        final skillsMatch = skills.any((s) => 
          s.toString().toLowerCase().contains(searchTerm)
        );
        
        return title.contains(searchTerm) || 
               category.contains(searchTerm) || 
               skillsMatch;
      }).toList();
    }
  }

  // ==================== FILTER PROJECTS BY STATUS ====================
  void filterProjectsByStatus(String status) {
    if (status == 'All') {
      filteredProjects.value = projects;
    } else {
      filteredProjects.value = projects.where((p) => 
        p['status'] == status
      ).toList();
    }
  }

  // ==================== FILTER JOBS ====================
  void filterJobs(String query) {
    if (query.isEmpty) {
      filteredJobs.value = jobs;
    } else {
      final searchTerm = query.toLowerCase();
      filteredJobs.value = jobs.where((j) {
        final title = j['title']?.toString().toLowerCase() ?? '';
        final company = j['company']?.toString().toLowerCase() ?? '';
        final location = j['location']?.toString().toLowerCase() ?? '';
        final type = j['type']?.toString().toLowerCase() ?? '';
        
        return title.contains(searchTerm) || 
               company.contains(searchTerm) || 
               location.contains(searchTerm) ||
               type.contains(searchTerm);
      }).toList();
    }
  }

  // ==================== FILTER JOBS BY TYPE ====================
  void filterJobsByType(String type) {
    if (type == 'All') {
      filteredJobs.value = jobs;
    } else {
      filteredJobs.value = jobs.where((j) => 
        j['type'] == type
      ).toList();
    }
  }

  // ==================== FILTER JOBS BY WORKPLACE ====================
  void filterJobsByWorkplace(String workplace) {
    if (workplace == 'All') {
      filteredJobs.value = jobs;
    } else {
      filteredJobs.value = jobs.where((j) => 
        j['workplace'] == workplace
      ).toList();
    }
  }

  // ==================== GET STATUS COLOR ====================
  Color getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.green;
      case 'AWAITING_FUNDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ==================== GET STATUS TEXT ====================
  String getStatusText(String status) {
    switch (status) {
      case 'OPEN':
        return 'Open';
      case 'AWAITING_FUNDING':
        return 'Awaiting Funding';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // ==================== GET JOB STATUS COLOR ====================
  Color getJobStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // ==================== GET JOB STATUS TEXT ====================
  String getJobStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'closed':
        return 'Closed';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  // ==================== FORMAT BUDGET ====================
  String formatBudget(num min, num max, String type) {
    if (type == 'FIXED') {
      return '\$${min.round()} - \$${max.round()}';
    } else {
      return '\$${min.round()}/hr - \$${max.round()}/hr';
    }
  }

  // ==================== FORMAT DATE ====================
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

  // ==================== FORMAT JOB SALARY ====================
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

  // ==================== UPDATE PROFILE ====================
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== UPDATE PROFILE STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.put(
        Uri.parse('$baseUrl/api/employer/profile'),
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

  // ==================== UPLOAD COMPANY LOGO ====================
  Future<String?> uploadCompanyLogo(String imagePath) async {
    try {
      isUploading.value = true;
      
      print("\n🟡 ===== UPLOAD COMPANY LOGO STARTED =====");
      print("📸 Image Path: $imagePath");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return null;
      }

      // Check if file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        print("❌ File does not exist: $imagePath");
        return null;
      }

      // Get file extension for content type
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
        mediaType = MediaType('image', 'jpeg'); // default
      }

      final String url = '$baseUrl/api/employer/profile/logo';
      print("🌐 URL: $url");
      print("📁 File extension: $ext");
      print("📄 Content type: $mediaType");

      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add file with proper field name 'logo' (as per backend)
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
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          String newLogoUrl = jsonResponse['logoUrl'] ?? jsonResponse['url'] ?? '';
          if (newLogoUrl.isNotEmpty) {
            logoUrl.value = newLogoUrl;
            print("✅ Logo uploaded successfully: $newLogoUrl");
            return newLogoUrl;
          } else {
            print("❌ No logo URL in response");
            return null;
          }
        } else {
          print("❌ Upload failed: ${jsonResponse['message']}");
          return null;
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        if (response.statusCode == 404) {
          Get.snackbar(
            'Error',
            'Logo upload endpoint not found. Please check backend.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            'Failed to upload logo. Status: ${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return null;
      }
      
    } catch (e) {
      print("❌ Exception uploading logo: $e");
      Get.snackbar(
        'Error',
        'Network error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isUploading.value = false;
      print("🟢 ===== UPLOAD COMPANY LOGO ENDED =====");
    }
  }

  // ==================== UPDATE PROFILE FROM EDIT SCREEN ====================
  Future<bool> updateProfileFromEdit({
    required String companyName,
    required String industry,
    required String location,
    required String companySize,
    required String website,
    required String about,
    File? logoImage,
  }) async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== UPDATE PROFILE FROM EDIT STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        Get.snackbar('Error', 'Authentication failed', backgroundColor: Colors.red);
        return false;
      }

      // Split location into city and country
      String city = location;
      String country = this.country.value;
      
      if (location.contains(',')) {
        final parts = location.split(',').map((e) => e.trim()).toList();
        city = parts[0];
        if (parts.length > 1) {
          country = parts[1];
        }
      }

      // If logo image is selected, upload it first
      String? logoUrl;
      if (logoImage != null) {
        logoUrl = await uploadCompanyLogo(logoImage.path);
        if (logoUrl == null) {
          Get.snackbar(
            'Warning',
            'Profile updated but logo upload failed',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }

      // Prepare profile data
      final profileData = {
        'companyName': companyName,
        'industry': industry,
        'city': city,
        'country': country,
        'companySize': companySize,
        'website': website,
        'about': about,
      };

      // Add logoUrl if upload succeeded
      if (logoUrl != null) {
        profileData['logoUrl'] = logoUrl;
      }

      print("📦 Profile Data: $profileData");

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
          );
          
          return true;
        }
      }
      
      print("❌ Failed to update profile");
      Get.snackbar('Error', 'Failed to update profile', backgroundColor: Colors.red);
      return false;
      
    } catch (e) {
      print("❌ Exception updating profile: $e");
      Get.snackbar('Error', 'Network error: $e', backgroundColor: Colors.red);
      return false;
    } finally {
      isLoading.value = false;
      print("🟢 ===== UPDATE PROFILE ENDED =====");
    }
  }

  // ==================== ADD TEAM MEMBER ====================
  Future<bool> addTeamMember(Map<String, dynamic> member) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.post(
        Uri.parse('$baseUrl/api/employer/team-member'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(member),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          await fetchProfile();
          Get.snackbar('Success', 'Team member added');
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error adding team member: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== REMOVE TEAM MEMBER ====================
  Future<bool> removeTeamMember(int index) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.delete(
        Uri.parse('$baseUrl/api/employer/team-member/$index'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchProfile();
        Get.snackbar('Success', 'Team member removed');
        return true;
      }
      return false;
    } catch (e) {
      print("Error removing team member: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== DELETE JOB POST ====================
  Future<bool> deleteJobPost(String jobId) async {
    try {
      print("\n🟡 ===== DELETE JOB POST STARTED =====");
      print("📝 Job ID: $jobId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        Get.snackbar(
          'Error',
          'Authentication failed. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      final String url = '$baseUrl/api/jobposts/job/$jobId';
      print("🌐 URL: $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Job deleted successfully: ${jsonResponse['message']}");
        
        // Remove from local list first for instant UI update
        jobs.removeWhere((job) => job['_id'] == jobId);
        filteredJobs.removeWhere((job) => job['_id'] == jobId);
        
        // Update counts
        totalJobs.value = jobs.length;
        activeJobs.value = jobs.where((j) => 
          j['status'] == 'active' || j['status'] == null
        ).length;
        
        // Update job types
        final types = jobs.map((j) => j['type']?.toString() ?? '').toSet().toList();
        jobTypes.value = types.where((t) => t.isNotEmpty).toList();
        
        // Then refresh from backend in background
        fetchMyJobs();
        
        Get.snackbar(
          'Success',
          'Job post deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        
        print("🟢 ===== DELETE JOB POST ENDED SUCCESSFULLY =====");
        return true;
        
      } else {
        String errorMessage = 'Failed to delete job';
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (_) {}
        
        print("❌ Failed to delete job: $errorMessage");
        
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
      print("❌ Exception deleting job: $e");
      
      Get.snackbar(
        'Error',
        'Network error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  // ==================== DELETE PROJECT ====================
  Future<bool> deleteProject(String projectId) async {
    try {
      print("\n🟡 ===== DELETE PROJECT STARTED =====");
      print("📝 Project ID: $projectId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        Get.snackbar(
          'Error',
          'Authentication failed. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
      
      final String url = '$baseUrl/api/projects/$projectId';
      print("🌐 URL: $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Project deleted successfully: ${jsonResponse['message']}");
        
        // Remove from local list first for instant UI update
        projects.removeWhere((project) => project['_id'] == projectId);
        filteredProjects.removeWhere((project) => project['_id'] == projectId);
        
        // Update stats
        totalProjects.value = projects.length;
        _calculateProjectStats();
        
        // Then refresh from backend in background
        fetchMyProjects();
        
        Get.snackbar(
          'Success',
          'Project deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        
        print("🟢 ===== DELETE PROJECT ENDED SUCCESSFULLY =====");
        return true;
        
      } else {
        String errorMessage = 'Failed to delete project';
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (_) {}
        
        print("❌ Failed to delete project: $errorMessage");
        
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
      print("❌ Exception deleting project: $e");
      
      Get.snackbar(
        'Error',
        'Network error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      return false;
    }
  }

  // ==================== PAUSE JOB POST ====================
  Future<bool> pauseJobPost(String jobId) async {
    try {
      print("\n🟡 ===== PAUSE JOB POST STARTED =====");
      print("📝 Job ID: $jobId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return false;
      }
      
      final String url = '$baseUrl/api/jobposts/job/$jobId/pause';
      print("🌐 URL: $url");

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Job paused successfully: ${jsonResponse['message']}");
        
        // Update local job status
        final jobIndex = jobs.indexWhere((job) => job['_id'] == jobId);
        if (jobIndex != -1) {
          jobs[jobIndex]['status'] = 'paused';
          jobs.refresh();
        }
        
        // Update filtered jobs
        final filteredIndex = filteredJobs.indexWhere((job) => job['_id'] == jobId);
        if (filteredIndex != -1) {
          filteredJobs[filteredIndex]['status'] = 'paused';
          filteredJobs.refresh();
        }
        
        // Update active jobs count
        activeJobs.value = jobs.where((j) => 
          j['status'] == 'active' || j['status'] == null
        ).length;
        
        Get.snackbar(
          'Success',
          'Job post paused successfully',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
        
      } else {
        String errorMessage = 'Failed to pause job';
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (_) {}
        
        print("❌ Failed to pause job: $errorMessage");
        
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        
        return false;
      }
    } catch (e) {
      print("❌ Exception pausing job: $e");
      Get.snackbar('Error', 'Network error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  // ==================== RESUME JOB POST ====================
  Future<bool> resumeJobPost(String jobId) async {
    try {
      print("\n🟡 ===== RESUME JOB POST STARTED =====");
      print("📝 Job ID: $jobId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return false;
      }
      
      final String url = '$baseUrl/api/jobposts/job/$jobId/resume';
      print("🌐 URL: $url");

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Job resumed successfully: ${jsonResponse['message']}");
        
        // Update local job status
        final jobIndex = jobs.indexWhere((job) => job['_id'] == jobId);
        if (jobIndex != -1) {
          jobs[jobIndex]['status'] = 'active';
          jobs.refresh();
        }
        
        // Update filtered jobs
        final filteredIndex = filteredJobs.indexWhere((job) => job['_id'] == jobId);
        if (filteredIndex != -1) {
          filteredJobs[filteredIndex]['status'] = 'active';
          filteredJobs.refresh();
        }
        
        // Update active jobs count
        activeJobs.value = jobs.where((j) => 
          j['status'] == 'active' || j['status'] == null
        ).length;
        
        Get.snackbar(
          'Success',
          'Job post resumed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        return true;
        
      } else {
        String errorMessage = 'Failed to resume job';
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (_) {}
        
        print("❌ Failed to resume job: $errorMessage");
        
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        
        return false;
      }
    } catch (e) {
      print("❌ Exception resuming job: $e");
      Get.snackbar('Error', 'Network error: $e', backgroundColor: Colors.red);
      return false;
    }
  }

  // ==================== HELPER GETTERS ====================
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
  
  String get companyDisplayName => companyName.value.isNotEmpty 
      ? companyName.value 
      : 'Company Name';
  
  String get companyInitials {
    if (companyName.value.isNotEmpty) {
      final words = companyName.value.trim().split(' ');
      if (words.length > 1) {
        // Get first character of first two words
        final firstInitial = words[0].isNotEmpty ? words[0][0] : '';
        final secondInitial = words[1].isNotEmpty ? words[1][0] : '';
        if (firstInitial.isNotEmpty && secondInitial.isNotEmpty) {
          return '$firstInitial$secondInitial'.toUpperCase();
        }
      }
      // Get first character of first word
      if (words.isNotEmpty && words[0].isNotEmpty) {
        return words[0][0].toUpperCase();
      }
    }
    return 'C'; // Default fallback
  }
  
  // Safe team member access
  Map<String, dynamic> getTeamMember(int index) {
    if (teamMembers.isNotEmpty && index < teamMembers.length) {
      return teamMembers[index];
    }
    return {}; // Return empty map if index invalid
  }

  // ==================== REFRESH ALL DATA ====================
  Future<void> refreshAllData() async {
    print("\n🟡 ===== REFRESHING ALL DATA =====");
    await Future.wait([
      fetchProfile(),
      fetchMyProjects(),
      fetchMyJobs(),
    ]);
    print("🟢 ===== ALL DATA REFRESHED =====");
  }
}
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/models/Employee_jobs_model.dart';
import 'package:templink/Employee/models/project_model.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/config/api_config.dart';

class EmployeeHomeController extends GetxController {
  final String baseUrl = ApiConfig.baseUrl;
  
  var firstName = ''.obs;
  var lastName = ''.obs;
  var fullName = ''.obs;
  var imageUrl = ''.obs;
  var userRole = ''.obs;
  var isLoading = false.obs;

  // ==================== CATEGORIES ====================
  final isLoadingCategories = false.obs;
  final categories = <String>[].obs;
  final categoriesError = RxnString();
  final String categoriesPath = '/api/jobposts/job-categories';
  
  // Selected category
  var selectedCategory = 'All'.obs;
  
  // Jobs filtered by category
  final filteredJobsByCategory = <JobPostModel>[].obs;

  // Jobs
  final isLoadingJobs = false.obs;
  final jobs = <JobPostModel>[].obs;
  final jobsError = RxnString();
  final String jobsPath = '/api/jobposts/jobs';

  // Projects
  final isLoadingProjects = false.obs;
  final projects = <ProjectFeedModel>[].obs;
  final projectsError = RxnString();
  final String projectsPath = '/api/projects/all';
  
  // Talents
  final isLoadingTalents = false.obs;
  final talents = <TalentModel>[].obs;
  final recommendedTalents = <TalentModel>[].obs;
  final talentsError = RxnString();
  final String talentsPath = '/api/toptalent/all';
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchAll();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      
      firstName.value = prefs.getString('auth_first_name') ?? '';
      lastName.value = prefs.getString('auth_last_name') ?? '';
      imageUrl.value = prefs.getString('auth_image_url') ?? '';
      userRole.value = prefs.getString('auth_role') ?? '';
      
      // Set full name
      if (firstName.value.isNotEmpty && lastName.value.isNotEmpty) {
        fullName.value = '${firstName.value} ${lastName.value}';
      } else if (firstName.value.isNotEmpty) {
        fullName.value = firstName.value;
      } else {
        fullName.value = 'User';
      }
      
      print("✅ User data loaded:");
      print("  - Name: $fullName");
      print("  - Image: ${imageUrl.value.isNotEmpty ? 'Yes' : 'No'}");
      print("  - Role: $userRole");
      
    } catch (e) {
      print("❌ Error loading user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadUserData();
  }

  String getInitials() {
    if (firstName.value.isNotEmpty && lastName.value.isNotEmpty) {
      return '${firstName.value[0]}${lastName.value[0]}'.toUpperCase();
    } else if (firstName.value.isNotEmpty) {
      return firstName.value[0].toUpperCase();
    } else {
      return 'U';
    }
  }

  void clearData() {
    firstName.value = '';
    lastName.value = '';
    fullName.value = '';
    imageUrl.value = '';
    userRole.value = '';
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchCategories(),
      fetchJobs(), 
      fetchProjects(),
      fetchTalents() 
    ]);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ✅ FETCH CATEGORIES FROM API
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      categoriesError.value = null;

      final headers = await _buildHeaders();
      final uri = Uri.parse('$baseUrl$categoriesPath');
      
      print("📡 Fetching categories from: $uri");
      
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 25));
      
      print("📡 Categories response status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        
        // Clear existing categories
        categories.clear();
        
        // Add "All" option first
        categories.add('All');
        
        // Add categories from API
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          final List<dynamic> categoryList = decoded['categories'] ?? [];
          categories.addAll(categoryList.map((e) => e.toString()));
          print("✅ Loaded ${categories.length - 1} categories from API");
        } else if (decoded is List) {
          categories.addAll(decoded.map((e) => e.toString()));
          print("✅ Loaded ${categories.length - 1} categories from API");
        }
        
        print("📊 Categories: ${categories}");
        
        // Default selected category
        selectedCategory.value = 'All';
        
      } else {
        categoriesError.value = 'Failed to load categories (${res.statusCode})';
        print("❌ Categories error: ${res.statusCode}");
      }
    } catch (e) {
      categoriesError.value = e.toString();
      print("❌ Categories exception: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ✅ FILTER JOBS BY SELECTED CATEGORY
  void filterJobsByCategory() {
    if (selectedCategory.value == 'All') {
      filteredJobsByCategory.assignAll(jobs);
    } else {
      // Filter jobs based on category - assuming jobs mein category field hai
      // Agar jobs mein category field nahi hai to ye filter kuch aur logic use karega
      filteredJobsByCategory.assignAll(
        jobs.where((job) {
          // Check if job's category matches selected category
          // Aap job model mein category field add kar sakte hain ya kisi aur field se match kar sakte hain
          // For now, we'll use job title or type to match category
          return job.title.toLowerCase().contains(selectedCategory.value.toLowerCase()) ||
                 job.type.toLowerCase().contains(selectedCategory.value.toLowerCase()) ||
                 (job.requirements?.toLowerCase().contains(selectedCategory.value.toLowerCase()) ?? false);
        }).toList()
      );
    }
    print("✅ Filtered jobs for category '${selectedCategory.value}': ${filteredJobsByCategory.length}");
  }

  // ✅ SET SELECTED CATEGORY AND FILTER JOBS
  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    filterJobsByCategory();
  }

  // ✅ JOBS FETCH
  Future<void> fetchJobs() async {
    try {
      isLoadingJobs.value = true;
      jobsError.value = null;

      final headers = await _buildHeaders();
      final uri = Uri.parse('$baseUrl$jobsPath');
      
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 25));
      
      print("📡 Jobs response status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        
        List<dynamic> jobsList = [];
        
        if (decoded is Map<String, dynamic>) {
          if (decoded['success'] == true && decoded['jobs'] != null) {
            jobsList = decoded['jobs'] as List;
            print("✅ Found ${jobsList.length} jobs from response");
          } else if (decoded['data'] != null) {
            jobsList = decoded['data'] as List;
          }
        } else if (decoded is List) {
          jobsList = decoded;
        }

        jobs.clear();
        
        if (jobsList.isNotEmpty) {
          jobs.assignAll(
            jobsList.map((e) => JobPostModel.fromJson(Map<String, dynamic>.from(e))).toList()
          );
          print("✅ Loaded ${jobs.length} jobs successfully");
          
          // Filter jobs based on selected category
          filterJobsByCategory();
        } else {
          print("ℹ️ No jobs found in response");
        }
      } else {
        jobsError.value = 'Failed to load jobs (${res.statusCode})';
        print("❌ Jobs error: ${res.statusCode}");
      }
    } catch (e) {
      jobsError.value = e.toString();
      print("❌ Jobs exception: $e");
    } finally {
      isLoadingJobs.value = false;
    }
  }

  // ✅ PROJECTS FETCH
  Future<void> fetchProjects() async {
    try {
      isLoadingProjects.value = true;
      projectsError.value = null;

      final headers = await _buildHeaders();
      final uri = Uri.parse('$baseUrl$projectsPath');
      
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        
        final List list = (decoded is Map && decoded['projects'] is List)
            ? decoded['projects']
            : (decoded is List ? decoded : <dynamic>[]);

        projects.assignAll(
          list.map((e) => ProjectFeedModel.fromJson(Map<String, dynamic>.from(e))).toList()
        );
      } else {
        projectsError.value = 'Failed to load projects (${res.statusCode})';
      }
    } catch (e) {
      projectsError.value = e.toString();
    } finally {
      isLoadingProjects.value = false;
    }
  }

  // ✅ TALENTS FETCH
  Future<void> fetchTalents() async {
    try {
      isLoadingTalents.value = true;
      talentsError.value = null;

      final headers = await _buildHeaders();
      final uri = Uri.parse('$baseUrl$talentsPath');
      
      print('📡 Fetching talents from: $uri');

      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        
        final List list = (decoded is Map && decoded['talents'] is List)
            ? decoded['talents']
            : (decoded is List ? decoded : <dynamic>[]);

        final allTalents = list
            .map((e) => TalentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        talents.assignAll(allTalents);
        recommendedTalents.assignAll(allTalents.take(2).toList());

        print('✅ Loaded ${talents.length} talents');
      } else {
        talentsError.value = 'Failed to load talents (${res.statusCode})';
        print('❌ Talents error: ${res.statusCode}');
      }
    } catch (e) {
      talentsError.value = e.toString();
      print('❌ Talents exception: $e');
    } finally {
      isLoadingTalents.value = false;
    }
  }

  // ✅ Refresh all data
  Future<void> refreshAll() async {
    await fetchAll();
  }
}
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

  // ==================== STATIC CATEGORIES ====================
  final List<Map<String, dynamic>> categoryList = [
    {
      'name': 'IT & Networking',
      'subcategories': ['Database Management', 'ERP/CRM', 'Network Security', 'Cloud Computing', 'System Admin', 'DevOps', 'AI/ML Engineering']
    },
    {
      'name': 'Design & Creative',
      'subcategories': ['UI/UX Design', 'Graphic Design', 'Web Design', 'Logo Design', 'Animation', 'Product Design', 'Industrial Design']
    },
    {
      'name': 'Writing & Translation',
      'subcategories': ['Content Writing', 'Technical Writing', 'Copywriting', 'Translation', 'Proofreading', 'Grant Writing', 'Editing']
    },
    {
      'name': 'Digital Marketing',
      'subcategories': ['SEO', 'Social Media', 'Email Marketing', 'PPC Ads', 'Content Marketing', 'Affiliate Marketing', 'Marketing Analytics']
    },
    {
      'name': 'Business & Finance',
      'subcategories': ['Accounting', 'Financial Analysis', 'Business Planning', 'Market Research', 'Consulting', 'Investment Banking', 'Auditing', 'Risk Management']
    },
    {
      'name': 'Engineering & Architecture',
      'subcategories': ['Civil Engineering', 'Mechanical Eng', 'Electrical Eng', 'Architecture', 'CAD Design', 'Structural Engineering', 'Project Management']
    },
    {
      'name': 'Healthcare & Medical',
      'subcategories': ['Nursing', 'Physician', 'Pharmacy', 'Medical Lab Technology', 'Public Health', 'Medical Research', 'Physiotherapy']
    },
    {
      'name': 'Education & Training',
      'subcategories': ['Teaching', 'Corporate Training', 'Curriculum Development', 'E-learning', 'Tutoring', 'Instructional Design']
    },
    {
      'name': 'Legal & Compliance',
      'subcategories': ['Corporate Law', 'Legal Research', 'Contract Management', 'Intellectual Property', 'Compliance Officer', 'Paralegal']
    },
    {
      'name': 'Human Resources',
      'subcategories': ['Recruitment', 'Employee Relations', 'HR Analytics', 'Payroll Management', 'Training & Development']
    },
    {
      'name': 'Project Management',
      'subcategories': ['Agile Project Management', 'Scrum Master', 'PMO Management', 'Risk Management', 'Operations Management']
    },
    {
      'name': 'Sales & Business Development',
      'subcategories': ['B2B Sales', 'Account Management', 'Lead Generation', 'CRM Management', 'Retail Sales', 'Strategic Partnerships']
    },
    {
      'name': 'Science & Research',
      'subcategories': ['Data Analysis', 'Laboratory Research', 'Scientific Writing', 'Biotech', 'Chemistry', 'Physics Research']
    },
    {
      'name': 'Finance & Investment',
      'subcategories': ['Portfolio Management', 'Financial Planning', 'Equity Research', 'Accounting', 'Investment Analysis', 'Tax Consulting']
    },
  ];

  var selectedParentCategory = ''.obs;
  var selectedSubcategory = ''.obs;
  final currentSubcategories = <String>[].obs;

  // ==================== JOBS ====================
  final isLoadingJobs = false.obs;
  final jobs = <JobPostModel>[].obs;
  final jobsError = RxnString();
  final String jobsPath = '/api/jobposts/jobs';

  // Jobs Pagination
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalCount = 0.obs;
  final int limit = 10;
  final isLoadingMore = false.obs;

  final filteredJobsByCategory = <JobPostModel>[].obs;

  // ==================== PROJECTS ====================
  final isLoadingProjects = false.obs;
  final projects = <ProjectFeedModel>[].obs;
  final projectsError = RxnString();
  final String projectsPath = '/api/projects/all';
  
  // ✅ PROJECTS PAGINATION - SIRF YEH ADD KIYA HAI
  final projectsCurrentPage = 1.obs;
  final projectsTotalPages = 1.obs;
  final projectsTotalCount = 0.obs;
  final int projectsLimit = 6;
  final isLoadingMoreProjects = false.obs;

  // ==================== TALENTS ====================
  final isLoadingTalents = false.obs;
  final talents = <TalentModel>[].obs;
  final recommendedTalents = <TalentModel>[].obs;
  final talentsError = RxnString();
  final String talentsPath = '/api/toptalent/all';

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    _initCategories();
    fetchAll();
  }

  void _initCategories() {
    if (categoryList.isNotEmpty) {
      final first = categoryList.first;
      selectedParentCategory.value = first['name'];
      final subs = List<String>.from(first['subcategories']);
      currentSubcategories.assignAll(subs);
      if (subs.isNotEmpty) {
        selectedSubcategory.value = subs.first;
      }
    }
  }

  void setParentCategory(String parentName) {
    if (selectedParentCategory.value == parentName) return;

    selectedParentCategory.value = parentName;

    final found = categoryList.firstWhere(
      (c) => c['name'] == parentName,
      orElse: () => {},
    );
    if (found.isNotEmpty) {
      final subs = List<String>.from(found['subcategories']);
      currentSubcategories.assignAll(subs);

      if (subs.isNotEmpty) {
        selectedSubcategory.value = subs.first;
        currentPage.value = 1;
        fetchJobs(page: 1, resetList: true);
      }
    }
  }

  Future<void> setSelectedSubcategory(String subcategory) async {
    selectedSubcategory.value = subcategory;
    currentPage.value = 1;
    await fetchJobs(page: 1, resetList: true);
  }

  void resetToFirstCategory() {
    _initCategories();
    fetchJobs(page: 1, resetList: true);
  }

  // ─────────────────────────────────────────────
  // USER DATA
  // ─────────────────────────────────────────────
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      firstName.value = prefs.getString('auth_first_name') ?? '';
      lastName.value = prefs.getString('auth_last_name') ?? '';
      imageUrl.value = prefs.getString('auth_image_url') ?? '';
      userRole.value = prefs.getString('auth_role') ?? '';
      if (firstName.value.isNotEmpty && lastName.value.isNotEmpty) {
        fullName.value = '${firstName.value} ${lastName.value}';
      } else if (firstName.value.isNotEmpty) {
        fullName.value = firstName.value;
      } else {
        fullName.value = 'User';
      }
      print("✅ User data loaded: $fullName | Role: $userRole");
    } catch (e) {
      print("❌ Error loading user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async => await loadUserData();

  String getInitials() {
    if (firstName.value.isNotEmpty && lastName.value.isNotEmpty) {
      return '${firstName.value[0]}${lastName.value[0]}'.toUpperCase();
    } else if (firstName.value.isNotEmpty) {
      return firstName.value[0].toUpperCase();
    }
    return 'U';
  }

  void clearData() {
    firstName.value = '';
    lastName.value = '';
    fullName.value = '';
    imageUrl.value = '';
    userRole.value = '';
  }

  // ─────────────────────────────────────────────
  // FETCH ALL
  // ─────────────────────────────────────────────
  Future<void> fetchAll() async {
    await Future.wait([
      fetchJobs(page: 1, resetList: true),
      fetchProjects(page: 1, resetList: true),
      fetchTalents(),
    ]);
  }

  Future<Map<String, String>> _buildHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // FETCH JOBS with pagination
  // ─────────────────────────────────────────────
  Future<void> fetchJobs({int page = 1, bool resetList = true}) async {
    try {
      if (page == 1) {
        isLoadingJobs.value = true;
      } else {
        isLoadingMore.value = true;
      }
      jobsError.value = null;

      final headers = await _buildHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (selectedSubcategory.value.isNotEmpty) {
        queryParams['subcategories'] = selectedSubcategory.value;
      }

      final uri = Uri.parse('$baseUrl$jobsPath')
          .replace(queryParameters: queryParams);

      print("📡 Fetching jobs: $uri");

      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));

      print("📡 Jobs response: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> jobsList = [];

        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          jobsList = decoded['jobs'] ?? [];
          final pagination = decoded['pagination'];
          if (pagination != null) {
            currentPage.value = pagination['currentPage'] ?? page;
            totalPages.value = pagination['totalPages'] ?? 1;
            totalCount.value = pagination['totalCount'] ?? 0;
          }
        } else if (decoded is List) {
          jobsList = decoded;
        }

        final newJobs = jobsList
            .map((e) => JobPostModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (resetList || page == 1) {
          jobs.assignAll(newJobs);
        } else {
          jobs.addAll(newJobs);
        }

        filteredJobsByCategory.assignAll(jobs);

        print("✅ Loaded ${newJobs.length} jobs | Page $page/${totalPages.value} | Total: ${totalCount.value}");
      } else {
        jobsError.value = 'Failed to load jobs (${res.statusCode})';
        print("❌ Jobs error: ${res.statusCode} | ${res.body}");
      }
    } catch (e) {
      jobsError.value = e.toString();
      print("❌ Jobs exception: $e");
    } finally {
      isLoadingJobs.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadNextPage() async {
    if (currentPage.value >= totalPages.value) return;
    await fetchJobs(page: currentPage.value + 1, resetList: false);
  }

  bool get hasMorePages => currentPage.value < totalPages.value;

  // ─────────────────────────────────────────────
  // PROJECTS WITH PAGINATION - SIRF YEH CHANGE KIYA HAI
  // ─────────────────────────────────────────────
  Future<void> fetchProjects({int page = 1, bool resetList = true}) async {
    try {
      if (page == 1) {
        isLoadingProjects.value = true;
      } else {
        isLoadingMoreProjects.value = true;
      }
      projectsError.value = null;
      
      final headers = await _buildHeaders();
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': projectsLimit.toString(),
      };
      
      final uri = Uri.parse('$baseUrl$projectsPath')
          .replace(queryParameters: queryParams);
      
      print("📡 Fetching projects: $uri");
      
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));
      
      print("📡 Projects response: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> projectsList = [];
        
        if (decoded is Map<String, dynamic>) {
          if (decoded['success'] == true) {
            projectsList = decoded['projects'] ?? [];
            
            final pagination = decoded['pagination'];
            if (pagination != null) {
              projectsCurrentPage.value = pagination['currentPage'] ?? page;
              projectsTotalPages.value = pagination['totalPages'] ?? 1;
              projectsTotalCount.value = pagination['totalItems'] ?? 0;
              print("📊 Projects pagination: Page ${projectsCurrentPage.value}/${projectsTotalPages.value}, Total: ${projectsTotalCount.value}");
            }
          } else if (decoded['projects'] is List) {
            projectsList = decoded['projects'];
          }
        } else if (decoded is List) {
          projectsList = decoded;
        }
        
        final newProjects = projectsList
            .map((e) => ProjectFeedModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        
        if (resetList || page == 1) {
          projects.assignAll(newProjects);
        } else {
          projects.addAll(newProjects);
        }
        
        print("✅ Loaded ${newProjects.length} projects | Total: ${projects.length}");
      } else {
        projectsError.value = 'Failed to load projects (${res.statusCode})';
        print("❌ Projects error: ${res.statusCode} | ${res.body}");
      }
    } catch (e) {
      projectsError.value = e.toString();
      print("❌ Projects exception: $e");
    } finally {
      isLoadingProjects.value = false;
      isLoadingMoreProjects.value = false;
    }
  }
  
  // ✅ Load next page for projects
  Future<void> loadNextProjectsPage() async {
    if (projectsCurrentPage.value >= projectsTotalPages.value) return;
    if (isLoadingMoreProjects.value) return;
    await fetchProjects(page: projectsCurrentPage.value + 1, resetList: false);
  }
  
  // ✅ Check more pages
  bool get hasMoreProjectsPages => projectsCurrentPage.value < projectsTotalPages.value;
  
  // ✅ Refresh projects
  Future<void> refreshProjects() async {
    await fetchProjects(page: 1, resetList: true);
  }

  // ─────────────────────────────────────────────
  // TALENTS
  // ─────────────────────────────────────────────
  Future<void> fetchTalents() async {
    try {
      isLoadingTalents.value = true;
      talentsError.value = null;
      final headers = await _buildHeaders();
      final uri = Uri.parse('$baseUrl$talentsPath');
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));
          print("talent response ${res.body}");
      if (res.statusCode == 200) {

        final decoded = jsonDecode(res.body);
        final List list = (decoded is Map && decoded['talents'] is List)
            ? decoded['talents']
            : (decoded is List ? decoded : <dynamic>[]);
        final allTalents = list
            .map((e) => TalentModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        talents.assignAll(allTalents);
        recommendedTalents.assignAll(allTalents);
        print('✅ Loaded ${talents.length} talents');
      } else {
        talentsError.value = 'Failed to load talents (${res.statusCode})';
      }
    } catch (e) {
      talentsError.value = e.toString();
      print('❌ Talents exception: $e');
    } finally {
      isLoadingTalents.value = false;
    }
  }

  Future<void> refreshAll() async => await fetchAll();
}
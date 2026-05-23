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

  // ==================== JOBS (LAZY LOAD / INFINITE SCROLL) ====================
  final isLoadingJobs = false.obs;
  final jobs = <JobPostModel>[].obs;
  final jobsError = RxnString();
  final String jobsPath = '/api/jobposts/jobs';

  // Jobs Pagination
  final jobsCurrentPage = 1.obs;
  final jobsTotalPages = 1.obs;
  final jobsTotalCount = 0.obs;
  final int jobsLimit = 10;
  final isLoadingMoreJobs = false.obs;
  
  bool get hasMoreJobs => jobsCurrentPage.value < jobsTotalPages.value;

  final filteredJobsByCategory = <JobPostModel>[].obs;

  // ==================== PROJECTS (WEB PAGINATION WITH PAGES) ====================
  final isLoadingProjects = false.obs;
  final projects = <ProjectFeedModel>[].obs;
  final projectsError = RxnString();
  final String projectsPath = '/api/projects/all';
  
  final projectsCurrentPage = 1.obs;
  final projectsTotalPages = 1.obs;
  final projectsTotalCount = 0.obs;
  final int projectsLimit = 6;
  final isLoadingMoreProjects = false.obs;
  
  bool get hasMoreProjectsPages => projectsCurrentPage.value < projectsTotalPages.value;
  bool get hasPrevProjectsPage => projectsCurrentPage.value > 1;
  bool get hasNextProjectsPage => projectsCurrentPage.value < projectsTotalPages.value;

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
        jobsCurrentPage.value = 1;
        fetchJobs(page: 1, resetList: true);
      }
    }
  }

  Future<void> setSelectedSubcategory(String subcategory) async {
    selectedSubcategory.value = subcategory;
    jobsCurrentPage.value = 1;
    await fetchJobs(page: 1, resetList: true);
  }

  void resetToFirstCategory() {
    _initCategories();
    fetchJobs(page: 1, resetList: true);
  }

  // ─────────────────────────────────────────────────────────
  // USER DATA
  // ─────────────────────────────────────────────────────────
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
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────────────
  // FETCH JOBS - LAZY LOAD (INFINITE SCROLL)
  // ─────────────────────────────────────────────────────────
  Future<void> fetchJobs({int page = 1, bool resetList = true}) async {
    try {
      if (page == 1) {
        isLoadingJobs.value = true;
      } else {
        isLoadingMoreJobs.value = true;
      }
      jobsError.value = null;

      final headers = await _buildHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': jobsLimit.toString(),
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

      print("📡 Jobs response status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> jobsList = [];

        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          jobsList = decoded['jobs'] ?? [];
          final pagination = decoded['pagination'];
          if (pagination != null) {
            jobsCurrentPage.value = pagination['currentPage'] ?? page;
            jobsTotalPages.value = pagination['totalPages'] ?? 1;
            jobsTotalCount.value = pagination['totalItems'] ?? 0;
          }
        } else if (decoded is List) {
          jobsList = decoded;
          jobsTotalCount.value = jobsList.length;
          jobsTotalPages.value = (jobsList.length / jobsLimit).ceil();
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

        print("✅ Loaded ${newJobs.length} jobs | Page $page/${jobsTotalPages.value} | Total: ${jobsTotalCount.value}");
      } else {
        jobsError.value = 'Failed to load jobs (${res.statusCode})';
        print("❌ Jobs error: ${res.statusCode} | ${res.body}");
      }
    } catch (e) {
      jobsError.value = e.toString();
      print("❌ Jobs exception: $e");
    } finally {
      isLoadingJobs.value = false;
      isLoadingMoreJobs.value = false;
    }
  }

  // ✅ CORRECTED METHOD NAME
  Future<void> loadNextJobsPage() async {
    if (!hasMoreJobs) return;
    if (isLoadingMoreJobs.value) return;
    await fetchJobs(page: jobsCurrentPage.value + 1, resetList: false);
  }

  // ─────────────────────────────────────────────────────────
  // FETCH PROJECTS - WEB PAGINATION (PAGE NUMBERS)
  // ─────────────────────────────────────────────────────────
  Future<void> fetchProjects({int page = 1, bool resetList = true}) async {
    try {
      if (resetList) {
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
      
      print("📡 Projects response status: ${res.statusCode}");
      
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
          projectsTotalCount.value = projectsList.length;
          projectsTotalPages.value = (projectsList.length / projectsLimit).ceil();
        }
        
        final newProjects = projectsList
            .map((e) => ProjectFeedModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        
        if (resetList) {
          projects.assignAll(newProjects);
        } else {
          projects.addAll(newProjects);
        }
        
        print("✅ Loaded ${newProjects.length} projects | Page $page/${projectsTotalPages.value}");
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
  
  // ✅ CORRECTED METHOD NAMES
  Future<void> loadNextProjectsPage() async {
    if (!hasMoreProjectsPages) return;
    if (isLoadingMoreProjects.value) return;
    await fetchProjects(page: projectsCurrentPage.value + 1, resetList: true);
  }
  
  Future<void> goToProjectsPage(int page) async {
    if (page < 1 || page > projectsTotalPages.value) return;
    if (isLoadingProjects.value) return;
    await fetchProjects(page: page, resetList: true);
  }
  
  Future<void> nextProjectsPage() async {
    if (hasNextProjectsPage) {
      await goToProjectsPage(projectsCurrentPage.value + 1);
    }
  }
  
  Future<void> prevProjectsPage() async {
    if (hasPrevProjectsPage) {
      await goToProjectsPage(projectsCurrentPage.value - 1);
    }
  }
  
  // Refresh projects
  Future<void> refreshProjects() async {
    await fetchProjects(page: 1, resetList: true);
  }

// Add these observables
var talentsCurrentPage = 1.obs;
var talentsTotalPages = 1.obs;
var talentsTotalCount = 0.obs;
var talentsLimit = 6.obs;

// Add paginated fetch method
Future<void> fetchTalentsPaginated({int page = 1, int limit = 6, bool resetList = true}) async {
  try {
    if (resetList) {
      isLoadingTalents.value = true;
    }
    talentsError.value = null;
    
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/api/toptalent/all?page=$page&limit=$limit');
    
    final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 25));
    
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      
      if (decoded['success'] == true) {
        final List talentsList = decoded['talents'] ?? [];
        final newTalents = talentsList.map((e) => TalentModel.fromJson(Map<String, dynamic>.from(e))).toList();
        
        if (resetList) {
          talents.assignAll(newTalents);
        } else {
          talents.addAll(newTalents);
        }
        
        recommendedTalents.assignAll(talents);
        
        // Update pagination info
        if (decoded['pagination'] != null) {
          talentsCurrentPage.value = decoded['pagination']['currentPage'] ?? page;
          talentsTotalPages.value = decoded['pagination']['totalPages'] ?? 1;
          talentsTotalCount.value = decoded['pagination']['totalItems'] ?? talents.length;
        } else {
          talentsTotalCount.value = talents.length;
          talentsTotalPages.value = (talentsTotalCount.value / limit).ceil();
        }
        
        print("✅ Loaded ${newTalents.length} talents | Page $page/${talentsTotalPages.value}");
      }
    } else {
      talentsError.value = 'Failed to load talents (${res.statusCode})';
    }
  } catch (e) {
    talentsError.value = e.toString();
    print("❌ Exception fetching talents: $e");
  } finally {
    isLoadingTalents.value = false;
  }
}

  Future<void> fetchTalents() async {
    try {
      isLoadingTalents.value = true;
      talentsError.value = null;
      final headers = await _buildHeaders();
      final uri = Uri.parse('$baseUrl$talentsPath');
      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 25));
      
      print("📡 TALENT API RESPONSE STATUS: ${res.statusCode}");
      
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
        print('✅ Loaded ${talents.length} talents successfully');
      } else {
        talentsError.value = 'Failed to load talents (${res.statusCode})';
        print("❌ Talents error: ${res.statusCode}");
      }
    } catch (e) {
      talentsError.value = e.toString();
      print("❌ Exception in fetchTalents: $e");
    } finally {
      isLoadingTalents.value = false;
    }
  }
  
  // Refresh all data
  Future<void> refreshAll() async {
    await fetchAll();
  }
  
  // Reset jobs pagination for category change
  void resetJobsPagination() {
    jobsCurrentPage.value = 1;
    jobsTotalPages.value = 1;
    jobsTotalCount.value = 0;
    jobs.clear();
    filteredJobsByCategory.clear();
  }
  
  // Reset projects pagination
  void resetProjectsPagination() {
    projectsCurrentPage.value = 1;
    projectsTotalPages.value = 1;
    projectsTotalCount.value = 0;
    projects.clear();
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/employer_job_application.dart';
import 'package:templink/config/api_config.dart';

class EmployerApplicationController extends GetxController {
  // Loading states
  var isLoadingApplications = false.obs;
  var isUpdatingStatus = false.obs;
  var applications = <EmployerJobApplication>[].obs;
  var filteredApplications = <EmployerJobApplication>[].obs;
  var summary = Rxn<ApplicationSummary>();
  var errorMessage = ''.obs;
  
  // Filters
  var selectedStatus = 'all'.obs;
  var selectedJobId = 'all'.obs;
  var searchQuery = ''.obs;
  
  // Jobs list for filter dropdown
  var jobsList = <Map<String, dynamic>>[].obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchEmployerApplications();
  }

  // ============== FETCH EMPLOYER APPLICATIONS ==============
  Future<void> fetchEmployerApplications() async {
    try {
      isLoadingApplications.value = true;
      errorMessage.value = '';

      String? token = await _getToken();
      if (token == null) {
        errorMessage.value = 'No authentication token found';
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/jobapplication/employer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Employer Apps Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          if (jsonResponse['summary'] != null) {
            summary.value = ApplicationSummary.fromJson(jsonResponse['summary']);
          }
                    final List<dynamic> appsData = jsonResponse['data'] ?? [];
          applications.value = appsData
              .map((app) => EmployerJobApplication.fromJson(app))
              .toList();
                    _extractJobsList();
          
          // Apply filters
          _applyFilters();
          
          print('✅ Loaded ${applications.length} employer applications');
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Failed to load applications';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      print('❌ Fetch employer applications error: $e');
    } finally {
      isLoadingApplications.value = false;
    }
  }

  // ============== UPDATE APPLICATION STATUS ==============
  Future<void> updateApplicationStatus(String applicationId, String newStatus) async {
    try {
      isUpdatingStatus.value = true;

      String? token = await _getToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Authentication failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/api/jobapplication/status/$applicationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        // Update local list
        final index = applications.indexWhere((app) => app.id == applicationId);
        if (index != -1) {
          final updatedApp = applications[index];
          // Create new instance with updated status (you'll need to refresh from API or update manually)
          fetchEmployerApplications(); // Refresh list
        }

        Get.snackbar(
          'Success',
          'Application status updated to $newStatus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to update status',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Update status error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  // ============== ADD EMPLOYER NOTE ==============
  Future<void> addEmployerNote(String applicationId, String note) async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final response = await http.patch(
        Uri.parse('$baseUrl/api/jobapplication/note/$applicationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'employerNotes': note}),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Note added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchEmployerApplications(); // Refresh
      }
    } catch (e) {
      print('Add note error: $e');
    }
  }

  // ============== FILTERS ==============
  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void filterByJob(String jobId) {
    selectedJobId.value = jobId;
    _applyFilters();
  }

  void searchApplications(String query) {
    searchQuery.value = query.toLowerCase();
    _applyFilters();
  }

  void _applyFilters() {
    List<EmployerJobApplication> filtered = applications;

    // Filter by status
    if (selectedStatus.value != 'all') {
      filtered = filtered.where((app) => app.status == selectedStatus.value).toList();
    }

    // Filter by job
    if (selectedJobId.value != 'all') {
      filtered = filtered.where((app) => app.jobId == selectedJobId.value).toList();
    }

    // Filter by search query (employee name or job title)
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((app) {
        final fullName = '${app.employeeSnapshot.firstName} ${app.employeeSnapshot.lastName}'.toLowerCase();
        final jobTitle = app.jobSnapshot.title.toLowerCase();
        return fullName.contains(searchQuery.value) || 
               jobTitle.contains(searchQuery.value);
      }).toList();
    }

    filteredApplications.value = filtered;
  }

  // ============== EXTRACT JOBS LIST FOR FILTER ==============
  void _extractJobsList() {
    final Map<String, String> uniqueJobs = {};
    
    for (var app in applications) {
      if (!uniqueJobs.containsKey(app.jobId)) {
        uniqueJobs[app.jobId] = app.jobSnapshot.title;
      }
    }

    jobsList.value = [
      {'id': 'all', 'title': 'All Jobs'},
      ...uniqueJobs.entries.map((e) => {'id': e.key, 'title': e.value}).toList()
        ..sort((a, b) => a['title']!.compareTo(b['title']!)),
    ];
  }

  // ============== GET APPLICATIONS FOR JOB ==============
  List<EmployerJobApplication> getApplicationsForJob(String jobId) {
    return applications.where((app) => app.jobId == jobId).toList();
  }

  // ============== GET STATUS COUNT ==============
  int getStatusCount(String status) {
    if (status == 'all') return applications.length;
    return applications.where((app) => app.status == status).toList().length;
  }

  // ============== UTILITY FUNCTIONS ==============
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
      case 'hired':
        return Colors.purple;
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
      case 'hired':
        return Icons.work;
      default:
        return Icons.help;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Reviewed';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Rejected';
      case 'hired':
        return 'Hired';
      default:
        return status;
    }
  }

  String formatDate(DateTime date) {
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

  double calculateMatchPercentage(EmployerJobApplication app) {
    return 60 + (app.id.hashCode % 40);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
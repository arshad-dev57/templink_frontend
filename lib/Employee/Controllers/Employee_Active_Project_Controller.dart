// lib/Employee/controllers/Employee_Active_Project_Controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart';
import 'dart:convert';
import 'package:templink/config/api_config.dart';
import 'package:flutter/material.dart';

class EmployeeActiveProjectController extends GetxController {
  var isLoading = true.obs;
  var projects = <EmployeeActiveProjectModel>[].obs;
  var selectedProject = Rx<EmployeeActiveProjectModel?>(null);
  
  var totalProjects = 0.obs;
  var activeProjects = 0.obs;
  var completedProjects = 0.obs;
  var totalEarnings = 0.0.obs;
  var pendingAmount = 0.0.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    print('🟢 EmployeeActiveProjectController initialized');
    fetchMyProjects();
  }

  // ==================== FETCH ALL PROJECTS ====================
  Future<void> fetchMyProjects() async {
    print('\n🟡 ===== FETCH MY PROJECTS STARTED =====');
    try {
      isLoading.value = true;
      print('📡 Loading started...');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('🔑 Token exists: ${token != null}');

      if (token == null) {
        print('❌ No token found, redirecting to login');
        Get.offAllNamed('/login');
        return;
      }

      final url = '$baseUrl/api/employee/projects';
      print('🌐 Calling URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Response parsed successfully');
        print('📊 Response keys: ${jsonResponse.keys.toList()}');
        
        final List<dynamic> projectsList = jsonResponse['projects'] ?? [];
        print('📊 Projects count: ${projectsList.length}');
        
        if (projectsList.isNotEmpty) {
          print('📦 First project raw data:');
          print('${projectsList.first}');
        }

        projects.value = projectsList
            .map((json) {
              try {
                final project = EmployeeActiveProjectModel.fromJson(json);
                print('✅ Parsed project: ${project.title}');
                print('   - Milestones: ${project.milestones.length}');
                print('   - Total Paid: ${project.totalPaid}');
                return project;
              } catch (e) {
                print('❌ Error parsing project: $e');
                print('📦 Problem JSON: $json');
                return null;
              }
            })
            .whereType<EmployeeActiveProjectModel>()
            .toList();
            
        print('✅ Total projects after parsing: ${projects.length}');
        _calculateStatistics();
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - token expired');
        Get.offAllNamed('/login');
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('📦 Error response: ${response.body}');
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      print('❌ Error fetching projects: $e');
      print('📌 Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Failed to load projects. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      print('🟢 Loading completed');
      print('🟡 ===== FETCH MY PROJECTS ENDED =====\n');
    }
  }

  // ==================== FETCH SINGLE PROJECT DETAILS ====================
  Future<void> fetchProjectDetails(String projectId) async {
    print('\n🟡 ===== FETCH PROJECT DETAILS STARTED =====');
    print('📦 Project ID: $projectId');
    
    try {
      isLoading.value = true;
      print('📡 Loading started...');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print('🔑 Token exists: ${token != null}');

      final url = '$baseUrl/api/employee/projects/$projectId';
      print('🌐 Calling URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Response parsed successfully');
        print('📊 Response keys: ${jsonResponse.keys.toList()}');
        
        if (jsonResponse.containsKey('project')) {
          print('📦 Project data found');
          final projectData = jsonResponse['project'];
          
          print('🔍 Project Details:');
          print('  - Title: ${projectData['title']}');
          print('  - Description: ${projectData['description']}');
          print('  - Category: ${projectData['category']}');
          print('  - Status: ${projectData['status']}');
          print('  - Total Budget: ${projectData['totalBudget']}');
          print('  - Total Paid: ${projectData['totalPaid']}');
          print('  - Milestones: ${projectData['milestones']?.length ?? 0}');
          
          if (projectData['milestones'] != null) {
            print('\n📊 Milestone Details:');
            for (var i = 0; i < projectData['milestones'].length; i++) {
              final m = projectData['milestones'][i];
              print('  Milestone ${i + 1}:');
              print('    - ID: ${m['_id']}');
              print('    - Title: ${m['title']}');
              print('    - Amount: ${m['amount']}');
              print('    - Status: ${m['status']}');
              print('    - Funded: ${m['isFunded']}');
              print('    - Submitted: ${m['isSubmitted']}');
            }
          }

          try {
            selectedProject.value = EmployeeActiveProjectModel.fromJson(projectData);
            print('✅ Project model parsed successfully');
            print('📊 Model milestones count: ${selectedProject.value?.milestones.length}');
          } catch (e) {
            print('❌ Error parsing project model: $e');
            print('📦 Problem data: $projectData');
          }
        } else {
          print('❌ No "project" key in response');
        }
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('📦 Error response: ${response.body}');
        throw Exception('Failed to load project details');
      }
    } catch (e) {
      print('❌ Error fetching project details: $e');
      print('📌 Stack trace: ${StackTrace.current}');
      Get.snackbar(
        'Error',
        'Failed to load project details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      print('🟢 Loading completed');
      print('🟡 ===== FETCH PROJECT DETAILS ENDED =====\n');
    }
  }
  
  // ==================== FETCH STATISTICS ====================
  Future<void> fetchStatistics() async {
    print('\n🟡 ===== FETCH STATISTICS STARTED =====');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '$baseUrl/api/active-projects/statistics';
      print('🌐 Calling URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final stats = jsonResponse['statistics'] ?? {};
        
        totalProjects.value = stats['totalProjects'] ?? 0;
        activeProjects.value = stats['activeProjects'] ?? 0;
        completedProjects.value = stats['completedProjects'] ?? 0;
        totalEarnings.value = (stats['totalEarnings'] ?? 0).toDouble();
        pendingAmount.value = (stats['pendingAmount'] ?? 0).toDouble();
        
        print('✅ Statistics updated:');
        print('  - Total Projects: ${totalProjects.value}');
        print('  - Active: ${activeProjects.value}');
        print('  - Completed: ${completedProjects.value}');
        print('  - Earnings: ${totalEarnings.value}');
      }
    } catch (e) {
      print('❌ Error fetching statistics: $e');
    }
    print('🟡 ===== FETCH STATISTICS ENDED =====\n');
  }

  // ==================== SEARCH PROJECTS ====================
  Future<void> searchProjects(String query) async {
    print('\n🟡 ===== SEARCH PROJECTS STARTED =====');
    print('🔍 Query: "$query"');
    
    if (query.isEmpty) {
      print('📝 Empty query, fetching all projects');
      fetchMyProjects();
      return;
    }

    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '$baseUrl/api/active-projects/search?query=$query';
      print('🌐 Calling URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> projectsList = jsonResponse['projects'] ?? [];
        print('📊 Found ${projectsList.length} projects');
        
        projects.value = projectsList
            .map((json) => EmployeeActiveProjectModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('❌ Error searching projects: $e');
    } finally {
      isLoading.value = false;
    }
    print('🟡 ===== SEARCH PROJECTS ENDED =====\n');
  }

  // ==================== UPDATE MILESTONE STATUS ====================
  Future<bool> updateMilestoneStatus(
    String activeProjectId,
    String milestoneId,
    String status, {
    DateTime? submittedAt,
    String? description,
    List<Map<String, dynamic>>? attachments,
  }) async {
    print('\n🟡 ===== UPDATE MILESTONE STATUS STARTED =====');
    print('📦 Project ID: $activeProjectId');
    print('📦 Milestone ID: $milestoneId');
    print('📦 New Status: $status');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '$baseUrl/api/active-projects/$activeProjectId/milestone/$milestoneId';
      print('🌐 Calling URL: $url');

      final body = {
        'status': status,
        'submittedAt': submittedAt?.toIso8601String(),
        'description': description,
        'attachments': attachments,
      };
      print('📦 Request body: $body');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        await fetchMyProjects();
        print('✅ Milestone status updated successfully');
        Get.snackbar(
          'Success',
          'Milestone status updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        throw Exception('Failed to update milestone');
      }
    } catch (e) {
      print('❌ Error updating milestone: $e');
      Get.snackbar(
        'Error',
        'Failed to update milestone',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      print('🟡 ===== UPDATE MILESTONE STATUS ENDED =====\n');
    }
  }

  // ==================== CALCULATE STATISTICS ====================
  void _calculateStatistics() {
    print('\n🟡 ===== CALCULATING STATISTICS =====');
    
    totalProjects.value = projects.length;
    activeProjects.value = projects.where((p) => p.isActive).length;
    completedProjects.value = projects.where((p) => p.isCompleted).length;
    
    totalEarnings.value = projects.fold(
      0, (sum, project) => sum + project.totalPaid
    );
    
    pendingAmount.value = projects.fold(
      0, (sum, project) => sum + project.remainingAmount
    );

    print('📊 Statistics:');
    print('  - Total Projects: ${totalProjects.value}');
    print('  - Active: ${activeProjects.value}');
    print('  - Completed: ${completedProjects.value}');
    print('  - Total Earnings: ${totalEarnings.value}');
    print('  - Pending Amount: ${pendingAmount.value}');
    print('🟡 ===== STATISTICS CALCULATED =====\n');
  }

  // ==================== GET PROJECT BY ID ====================
  EmployeeActiveProjectModel? getProjectById(String id) {
    print('🔍 Getting project by ID: $id');
    try {
      final project = projects.firstWhere((p) => p.id == id);
      print('✅ Found project: ${project.title}');
      return project;
    } catch (e) {
      print('❌ Project not found with ID: $id');
      return null;
    }
  }

  // ==================== GET READY MILESTONES ====================
  List<Milestone> getReadyMilestones(String projectId) {
    print('🔍 Getting ready milestones for project: $projectId');
    final project = getProjectById(projectId);
    if (project == null) return [];
    
    final ready = project.milestones.where((m) => m.isFunded).toList();
    print('✅ Found ${ready.length} ready milestones');
    return ready;
  }

  // ==================== GET COMPLETED MILESTONES ====================
  List<Milestone> getCompletedMilestones(String projectId) {
    print('🔍 Getting completed milestones for project: $projectId');
    final project = getProjectById(projectId);
    if (project == null) return [];
    
    final completed = project.milestones.where((m) => m.isCompleted).toList();
    print('✅ Found ${completed.length} completed milestones');
    return completed;
  }

 
  Future<void> refreshData() async {
    print('\n🔄 ===== REFRESHING DATA =====');
    await Future.wait([
      fetchMyProjects(),
      fetchStatistics(),
    ]);
    print('🔄 ===== DATA REFRESHED =====\n');
  }
  // In EmployeeActiveProjectController

Future<bool> submitWork({
  required String projectId,
  required String milestoneId,
  required String description,
  String? notes,
  List<File>? attachments,
}) async {
  print('\n🟡 ===== SUBMIT WORK STARTED =====');
  
  try {
    isLoading.value = true;
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/submissions/submit'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add text fields
    request.fields['projectId'] = projectId;
    request.fields['milestoneId'] = milestoneId;
    request.fields['description'] = description;
    if (notes != null) request.fields['notes'] = notes;
    
    // Add files
    if (attachments != null) {
      for (var file in attachments) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'attachments',
            file.path,
          ),
        );
      }
    }
    
    print('📡 Sending request to: $baseUrl/api/submissions/submit');
    print('📦 Project ID: $projectId');
    print('📦 Milestone ID: $milestoneId');
    print('📦 Files: ${attachments?.length ?? 0}');
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);
    
    print('📡 Response status: ${response.statusCode}');
    print('📦 Response: $jsonResponse');
    
    if (response.statusCode == 201) {
      print('✅ Work submitted successfully');
      
      // Refresh project details
      await fetchProjectDetails(projectId);
      
      return true;
    } else {
      print('❌ Submission failed: ${jsonResponse['message']}');
      Get.snackbar(
        'Error',
        jsonResponse['message'] ?? 'Failed to submit work',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
  } catch (e) {
    print('❌ Error submitting work: $e');
    Get.snackbar(
      'Error',
      'Network error. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return false;
  } finally {
    isLoading.value = false;
    print('🟡 ===== SUBMIT WORK ENDED =====\n');
  }
}
}
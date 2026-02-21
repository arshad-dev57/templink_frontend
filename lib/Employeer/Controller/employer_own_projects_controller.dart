// lib/Employeer/Controller/employer_own_projects_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/Screens/Employer_Contract_Screen.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/config/api_config.dart';
import 'dart:convert';

class EmployerProjectsController extends GetxController {
  var isLoading = true.obs;
  var isAccepting = false.obs;
  var isRejecting = false.obs;

  var projects = <EmployerProject>[].obs;
  var filteredProjects = <EmployerProject>[].obs;
  var searchQuery = ''.obs;

  var selectedProject = Rx<EmployerProject?>(null);
  var expandedProjectId = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchMyProjectsWithProposals();
  }

  // ==================== FETCH PROJECTS ====================
  Future<void> fetchMyProjectsWithProposals() async {
    try {
      isLoading.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (token == null) throw Exception("Authentication token not found");

      final response = await http.get(
        Uri.parse('$baseUrl/api/projects/my-with-proposals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final projectsResponse = EmployerProjectsResponse.fromJson(jsonResponse);
        projects.value = projectsResponse.projects;
        filterProjects();
      } else {
        throw Exception("Failed to load projects (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void filterProjects() {
    if (searchQuery.value.isEmpty) {
      filteredProjects.value = projects;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredProjects.value = projects.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.skills.any((s) => s.toLowerCase().contains(query));
      }).toList();
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    filterProjects();
  }

  void clearFilters() {
    searchQuery.value = '';
    filterProjects();
  }

  // ==================== ACCEPT PROPOSAL ====================
  Future<void> acceptProposal(String proposalId) async {
    try {
      print("🟡 ===== ACCEPT PROPOSAL STARTED =====");
      print("📝 Proposal ID: $proposalId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      print("🔑 Token exists: ${token != null}");
      
      if (token == null) throw Exception("Authentication token missing");

      isAccepting.value = true;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      print("🌐 Making API call to: $baseUrl/api/proposals/accept/$proposalId");
      
      final response = await http.patch(
        Uri.parse('$baseUrl/api/proposals/accept/$proposalId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status Code: ${response.statusCode}");
      
      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode == 200) {
        print("✅ API call successful");
        print("📦 Raw Response Body: ${response.body}");
        
        final jsonResponse = jsonDecode(response.body);
        print("🔍 Parsed JSON Response: $jsonResponse");
        print("🔍 Response keys: ${jsonResponse.keys.toList()}");
        
        // Extract contract ID with detailed checking
        String? contractId;
        print("🔍 Checking data.contract structure...");
        
        if (jsonResponse.containsKey('data')) {
          print("✅ 'data' key exists");
          print("📁 data type: ${jsonResponse['data'].runtimeType}");
          
          if (jsonResponse['data'] != null) {
            print("📁 data content: ${jsonResponse['data']}");
            
            if (jsonResponse['data'].containsKey('contract')) {
              print("✅ 'contract' key exists inside data");
              print("📄 contract content: ${jsonResponse['data']['contract']}");
              
              if (jsonResponse['data']['contract'] != null) {
                contractId = jsonResponse['data']['contract']['id'];
                print("✅ Contract ID extracted: $contractId");
              } else {
                print("❌ contract is null");
              }
            } else {
              print("❌ 'contract' key NOT found in data");
              print("📁 Available keys in data: ${jsonResponse['data'].keys.toList()}");
            }
          } else {
            print("❌ data is null");
          }
        } else {
          print("❌ 'data' key NOT found in response");
          print("📁 Available top-level keys: ${jsonResponse.keys.toList()}");
        }
        
        print("🔍 Final Contract ID: $contractId");
       
        // Find accepted proposal in local list
        print("🔍 Searching for proposal in local list...");
        print("📊 Total projects: ${projects.length}");
        
        ProjectProposal? acceptedProposal;
        for (var project in projects) {
          print("📁 Project: ${project.title}, Proposals: ${project.proposals.length}");
          for (var proposal in project.proposals) {
            print("   - Proposal ID: ${proposal.id}, Status: ${proposal.status}");
            if (proposal.id == proposalId) {
              acceptedProposal = proposal;
              print("✅ Found matching proposal!");
              print("   Employee: ${proposal.employee.displayName}");
              print("   Status: ${proposal.status}");
              break;
            }
          }
          if (acceptedProposal != null) break;
        }
        
        if (acceptedProposal == null) {
          print("❌ No matching proposal found in local list!");
        }

        Get.snackbar(
          "Success",
          jsonResponse["message"] ?? "Proposal accepted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        if (contractId != null) {
          print("🔄 Navigating to ContractScreen...");
          print("   Project ID: ${projects.firstWhere(
            (p) => p.proposals.any((pr) => pr.id == proposalId)
          ).id}");
          print("   Contract ID: $contractId");
          
          Get.to(() => EmployerContractScreen(
            projectId: projects.firstWhere(
              (p) => p.proposals.any((pr) => pr.id == proposalId)
            ).id,
            contractId: contractId,
          ));
          print("✅ Navigation complete");
        } else {
          print("❌ contractId is null - not navigating");
        }

        print("🔄 Refreshing projects list...");
        await fetchMyProjectsWithProposals();
        print("✅ Projects refreshed");
        
      } else {
        print("❌ API call failed with status: ${response.statusCode}");
        final error = jsonDecode(response.body);
        print("❌ Error response: $error");
        throw Exception(error["message"] ?? "Accept failed");
      }
    } catch (e) {
      print("❌ Exception caught: $e");
      print("❌ Stack trace: ${StackTrace.current}");
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, 
          colorText: Colors.white,
          duration: const Duration(seconds: 5),);
    } finally {
      print("🟢 ===== ACCEPT PROPOSAL ENDED =====");
      isAccepting.value = false;
    }
  }

  // ==================== REJECT PROPOSAL ====================
  Future<void> rejectProposal(String proposalId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      if (token == null) throw Exception("Authentication token missing");

      isRejecting.value = true;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/api/proposals/reject/$proposalId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode == 200) {
        ProjectProposal? rejectedProposal;
        for (var project in projects) {
          for (var proposal in project.proposals) {
            if (proposal.id == proposalId) {
              rejectedProposal = proposal;
              break;
            }
          }
        }

        Get.snackbar(
          "Success",
          "Proposal rejected",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        await fetchMyProjectsWithProposals();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "Reject failed");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isRejecting.value = false;
    }
  }

  // ==================== RATING METHODS ====================
  Future<bool> checkIfRated(String projectId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      final response = await http.get(
        Uri.parse('$baseUrl/api/ratings/project/$projectId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['rated'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking rating: $e');
      return false;
    }
  }
Future<void> submitRating({
  required String projectId,
  required String employeeId,
  required int rating,
  String? review,
}) async {
  try {
    print('🚀 ===== SUBMIT RATING STARTED =====');
    print('📦 Project ID: $projectId');
    print('📦 Employee ID: $employeeId');
    print('📦 Rating: $rating');
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    print('🔑 Token exists: ${token != null}');
    
    if (token == null) {
      print('❌ No token found');
      Get.offAllNamed('/login');
      return;
    }

    final url = '$baseUrl/api/ratings/submit';
    print('🌐 Calling URL: $url');
    
    final body = {
      'projectId': projectId,
      'employeeId': employeeId,
      'rating': rating,
      'review': review ?? '',
    };
    print('📦 Request body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    print('📡 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    if (response.statusCode == 201) {
      print('✅ Rating submitted successfully');
      Get.snackbar(
        'Success',
        'Thank you for your feedback!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      print('❌ Failed with status: ${response.statusCode}');
      final errorData = jsonDecode(response.body);
      print('❌ Error message: ${errorData['message']}');
      throw Exception(errorData['message'] ?? 'Failed to submit rating');
    }
  } catch (e) {
    print('❌ Exception caught: $e');
    print('❌ Stack trace: ${StackTrace.current}');
    Get.snackbar(
      'Error',
      'Failed to submit rating',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    print('🏁 ===== SUBMIT RATING ENDED =====');
  }
}
  // ==================== NOTIFICATION METHOD ====================
  static Future<void> sendSuccessNotification({
    required String userId,
    String title = "Project Update",
    String message = "",
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/api/notifications/send");

    try {
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "title": title,
          "message": message,
          "data": {"type": "project", "screen": "home"},
        }),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        Map<String, dynamic> data = {};
        try {
          data = jsonDecode(res.body);
        } catch (_) {}
        throw Exception(data["msg"]?.toString() ?? "Push failed (${res.statusCode})");
      }
    } catch (e) {
      debugPrint("Notification error: $e");
    }
  }

  // ==================== GETTERS ====================
  int get totalProjects => projects.length;
  int get totalProposals => projects.fold(0, (sum, p) => sum + p.proposals.length);
  int get totalPendingProposals =>
      projects.fold(0, (sum, p) => sum + p.pendingProposals);
  int get totalAcceptedProposals =>
      projects.fold(0, (sum, p) => sum + p.acceptedProposals);
}
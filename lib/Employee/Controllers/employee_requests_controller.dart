// lib/Employee/controllers/employee_requests_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/models/interest_request_model.dart';
import 'package:templink/config/api_config.dart';

class EmployeeRequestsController extends GetxController {
  final String baseUrl = ApiConfig.baseUrl;

  // Observables
  final pendingRequests = <InterestRequestModel>[].obs;
  final interestedRequests = <InterestRequestModel>[].obs;
  final isLoading = false.obs;
  final isProcessing = false.obs;
  final errorMessage = RxnString();
  final pendingCount = 0.obs;

  // Selected tab
  final selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  // ============== FETCH ALL REQUESTS ==============
  Future<void> fetchRequests() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        errorMessage.value = 'Not authenticated';
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/interest/employee-list'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Requests response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> requestsData = jsonResponse['data'] ?? [];
          
          final allRequests = requestsData
              .map((e) => InterestRequestModel.fromJson(e))
              .toList();

          // Split into pending and interested
          pendingRequests.value = allRequests
              .where((r) => r.status == 'pending' && !r.isExpired)
              .toList();

          interestedRequests.value = allRequests
              .where((r) => r.status == 'interested')
              .toList();

          // Update count for badge
          final counts = jsonResponse['counts'] as Map?;
          pendingCount.value = counts?['pending'] ?? pendingRequests.length;

          print('✅ Loaded ${pendingRequests.length} pending, ${interestedRequests.length} interested');
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Failed to load requests';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error fetching requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============== RESPOND TO REQUEST ==============
  Future<bool> respondToRequest(String requestId, String status) async {
    try {
      isProcessing.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/interest/respond/$requestId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          // Refresh the list
          await fetchRequests();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error responding to request: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ============== GET FORMATTED SALARY ==============
  String getFormattedSalary(double amount, String period) {
    String symbol = '/mo';
    switch (period) {
      case 'hourly':
        symbol = '/hr';
        break;
      case 'monthly':
        symbol = '/mo';
        break;
      case 'yearly':
        symbol = '/yr';
        break;
    }
    return '\$${amount.toStringAsFixed(0)}$symbol';
  }

  // ============== REFRESH DATA ==============
  Future<void> refreshData() async {
    await fetchRequests();
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:templink/Utils/colors.dart';
import '../../config/api_config.dart';

class EmployerLeaveController extends GetxController {
  static EmployerLeaveController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var isProcessing = false.obs;
  
  // Leave Requests
  var allRequests = <Map<String, dynamic>>[].obs;
  var pendingRequests = <Map<String, dynamic>>[].obs;
  var approvedRequests = <Map<String, dynamic>>[].obs;
  var rejectedRequests = <Map<String, dynamic>>[].obs;
  
  // Selected request
  var selectedRequest = Rx<Map<String, dynamic>?>(null);
  
  // Statistics
  var totalRequests = 0.obs;
  var totalPending = 0.obs;
  var totalApproved = 0.obs;
  var totalRejected = 0.obs;
  var totalDaysApproved = 0.obs;
  var leaveByType = {}.obs;
  
  // Error/Success messages
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  // ==================== REFRESH ALL DATA ====================
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchAllLeaveRequests(),
      fetchLeaveStatistics(),
    ]);
  }

  // ==================== FETCH ALL LEAVE REQUESTS ====================
  Future<void> fetchAllLeaveRequests() async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== FETCH ALL LEAVE REQUESTS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer-leave/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          allRequests.value = List<Map<String, dynamic>>.from(
            data['all'] ?? []
          );
          pendingRequests.value = List<Map<String, dynamic>>.from(
            data['pending'] ?? []
          );
          approvedRequests.value = List<Map<String, dynamic>>.from(
            data['approved'] ?? []
          );
          rejectedRequests.value = List<Map<String, dynamic>>.from(
            data['rejected'] ?? []
          );
          
          final counts = data['counts'];
          totalRequests.value = counts['total'] ?? 0;
          totalPending.value = counts['pending'] ?? 0;
          totalApproved.value = counts['approved'] ?? 0;
          totalRejected.value = counts['rejected'] ?? 0;
          
          print("✅ Leave requests fetched successfully");
          print("📊 Pending: $totalPending, Approved: $totalApproved, Rejected: $totalRejected");
        }
      } else {
        print("❌ Failed to fetch: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
      print("🟢 ===== FETCH ALL LEAVE REQUESTS ENDED =====");
    }
  }

  // ==================== FETCH LEAVE STATISTICS ====================
  Future<void> fetchLeaveStatistics() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer-leave/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final stats = jsonResponse['stats'];
          
          totalRequests.value = stats['total'] ?? 0;
          totalPending.value = stats['pending'] ?? 0;
          totalApproved.value = stats['approved'] ?? 0;
          totalRejected.value = stats['rejected'] ?? 0;
          totalDaysApproved.value = stats['totalDays'] ?? 0;
          leaveByType.value = stats['byType'] ?? {};
        }
      }
    } catch (e) {
      print("❌ Error fetching stats: $e");
    }
  }

  // ==================== APPROVE LEAVE ====================
  Future<bool> approveLeave(String leaveId) async {
    try {
      isProcessing.value = true;
      
      print("\n🟡 ===== APPROVE LEAVE STARTED =====");
      print("📝 Leave ID: $leaveId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/employer-leave/$leaveId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          successMessage.value = jsonResponse['message'];
          await refreshAllData();
          print("✅ Leave approved successfully");
          return true;
        } else {
          errorMessage.value = jsonResponse['message'];
          return false;
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      errorMessage.value = e.toString();
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ==================== REJECT LEAVE ====================
  Future<bool> rejectLeave(String leaveId, String reason) async {
    try {
      isProcessing.value = true;
      
      print("\n🟡 ===== REJECT LEAVE STARTED =====");
      print("📝 Leave ID: $leaveId");
      print("📝 Reason: $reason");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        return false;
      }

      final body = {
        'reason': reason
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/employer-leave/$leaveId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          successMessage.value = jsonResponse['message'];
          await refreshAllData();
          print("✅ Leave rejected successfully");
          return true;
        } else {
          errorMessage.value = jsonResponse['message'];
          return false;
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      errorMessage.value = e.toString();
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ==================== FETCH LEAVE DETAILS ====================
  Future<void> fetchLeaveDetails(String leaveId) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer-leave/$leaveId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          selectedRequest.value = jsonResponse['leave'];
        }
      }
    } catch (e) {
      print("❌ Error fetching leave details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FORMATTING METHODS ====================
  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String formatDateRange(String? from, String? to) {
    if (from == null || to == null) return '';
    return '${formatDate(from)} - ${formatDate(to)}';
  }

  String getTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getLeaveTypeColor(String type) {
    switch (type) {
      case 'Annual Leave':
        return Colors.blue;
      case 'Sick Leave':
        return Colors.green;
      case 'Casual Leave':
        return Colors.orange;
      case 'Unpaid Leave':
        return Colors.grey;
      default:
        return primary;
    }
  }

  // Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';

class EmployeeLeaveController extends GetxController {
  static EmployeeLeaveController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  
  // Leave Balance
  var annualTotal = 0.obs;
  var annualUsed = 0.obs;
  var annualRemaining = 0.obs;
  
  var sickTotal = 0.obs;
  var sickUsed = 0.obs;
  var sickRemaining = 0.obs;
  
  var casualTotal = 0.obs;
  var casualUsed = 0.obs;
  var casualRemaining = 0.obs;
  
  var unpaidTotal = 0.obs;
  var unpaidUsed = 0.obs;
  var unpaidRemaining = 0.obs;
  
  // Leave Requests
  var leaveRequests = <Map<String, dynamic>>[].obs;
  var filteredRequests = <Map<String, dynamic>>[].obs;
  
  // Stats
  var totalRequests = 0.obs;
  var pendingRequests = 0.obs;
  var approvedRequests = 0.obs;
  var rejectedRequests = 0.obs;
  var totalDaysTaken = 0.obs;
  
  // Selected leave details
  var selectedLeave = Rx<Map<String, dynamic>?>(null);
  
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
      fetchLeaveBalance(),
      fetchMyLeaves(),
      fetchLeaveStats(),
    ]);
  }

  // ==================== FETCH LEAVE BALANCE ====================
  Future<void> fetchLeaveBalance() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/employee-leave/balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final balance = jsonResponse['balance'];
          
          // Annual Leave
          annualTotal.value = balance['annual']['total'] ?? 0;
          annualUsed.value = balance['annual']['used'] ?? 0;
          annualRemaining.value = balance['annual']['remaining'] ?? 0;
          
          // Sick Leave
          sickTotal.value = balance['sick']['total'] ?? 0;
          sickUsed.value = balance['sick']['used'] ?? 0;
          sickRemaining.value = balance['sick']['remaining'] ?? 0;
          
          // Casual Leave
          casualTotal.value = balance['casual']['total'] ?? 0;
          casualUsed.value = balance['casual']['used'] ?? 0;
          casualRemaining.value = balance['casual']['remaining'] ?? 0;
          
          // Unpaid Leave
          unpaidTotal.value = balance['unpaid']['total'] ?? 0;
          unpaidUsed.value = balance['unpaid']['used'] ?? 0;
          unpaidRemaining.value = balance['unpaid']['remaining'] ?? 0;
        }
      }
    } catch (e) {
      print("❌ Error fetching leave balance: $e");
    }
  }

  // ==================== FETCH MY LEAVES ====================
  Future<void> fetchMyLeaves({String? status}) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      String url = '$baseUrl/api/employee-leave/my-leaves';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          leaveRequests.value = List<Map<String, dynamic>>.from(
            jsonResponse['leaves'] ?? []
          );
          filteredRequests.value = leaveRequests;
        }
      }
    } catch (e) {
      print("❌ Error fetching leaves: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FETCH LEAVE STATS ====================
  Future<void> fetchLeaveStats() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/employee-leave/stats'),
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
          pendingRequests.value = stats['pending'] ?? 0;
          approvedRequests.value = stats['approved'] ?? 0;
          rejectedRequests.value = stats['rejected'] ?? 0;
          totalDaysTaken.value = stats['totalDays'] ?? 0;
        }
      }
    } catch (e) {
      print("❌ Error fetching leave stats: $e");
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
        Uri.parse('$baseUrl/api/employee-leave/$leaveId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          selectedLeave.value = jsonResponse['leave'];
        }
      }
    } catch (e) {
      print("❌ Error fetching leave details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== APPLY FOR LEAVE ====================
  Future<bool> applyLeave({
    required String type,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== APPLY LEAVE STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        return false;
      }

      final body = {
        'type': type,
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
        'reason': reason,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/employee-leave/apply'),
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
          
          // Refresh data
          await Future.wait([
            fetchLeaveBalance(),
            fetchMyLeaves(),
            fetchLeaveStats(),
          ]);
          
          print("✅ Leave applied successfully");
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
      isSubmitting.value = false;
    }
  }
// lib/Employee/Controllers/employee_leave_controller.dart mein ye getter add karo

// ==================== GET TODAY'S PENDING LEAVES ====================
List<Map<String, dynamic>> get todayPendingLeaves {
  final today = DateTime.now();
  
  return leaveRequests.where((leave) {
    // Sirf pending leaves
    if (leave['status'] != 'pending') return false;
    
    // Check if today falls within leave range
    try {
      final fromDate = DateTime.parse(leave['fromDate']);
      final toDate = DateTime.parse(leave['toDate']);
      
      // Normalize dates to compare only date (ignore time)
      final todayDate = DateTime(today.year, today.month, today.day);
      final fromDateOnly = DateTime(fromDate.year, fromDate.month, fromDate.day);
      final toDateOnly = DateTime(toDate.year, toDate.month, toDate.day);
      
      // Today between fromDate and toDate (inclusive)
      return todayDate.isAfter(fromDateOnly.subtract(const Duration(days: 1))) && 
             todayDate.isBefore(toDateOnly.add(const Duration(days: 1)));
    } catch (e) {
      print("❌ Error parsing date: $e");
      return false;
    }
  }).toList();
}
  // ==================== CANCEL LEAVE REQUEST ====================
  Future<bool> cancelLeave(String leaveId) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/employee-leave/$leaveId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          await refreshAllData();
          return true;
        }
      }
      return false;
    } catch (e) {
      print("❌ Error cancelling leave: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FILTER LEAVES BY STATUS ====================
  void filterLeaves(String status) {
    if (status == 'All') {
      filteredRequests.value = leaveRequests;
    } else {
      filteredRequests.value = leaveRequests
          .where((l) => l['status'] == status.toLowerCase())
          .toList();
    }
  }

  // ==================== FORMATTING METHODS ====================
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatDateFromString(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return '✅';
      case 'pending':
        return '⏳';
      case 'rejected':
        return '❌';
      case 'cancelled':
        return '🚫';
      default:
        return '📝';
    }
  }

  // Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

}
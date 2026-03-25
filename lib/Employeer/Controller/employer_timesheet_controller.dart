import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';

class EmployerTimesheetController extends GetxController {
  static EmployerTimesheetController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var isProcessing = false.obs;
  
  // Timesheet Data
  var pendingTimesheets = <Map<String, dynamic>>[].obs;
  var approvedTimesheets = <Map<String, dynamic>>[].obs;
  var rejectedTimesheets = <Map<String, dynamic>>[].obs;
  var allTimesheets = <Map<String, dynamic>>[].obs;
  
  // Selected timesheet
  var selectedTimesheet = Rx<Map<String, dynamic>?>(null);
  
  // Statistics
  var totalPending = 0.obs;
  var totalApproved = 0.obs;
  var totalRejected = 0.obs;
  var totalHoursPending = 0.0.obs;
  
  // Filter
  var selectedFilter = 'pending'.obs;
  var searchQuery = ''.obs;
  
  // Error/Success messages
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchAllTimesheets();
  }

  // ==================== FETCH ALL TIMESHEETS ====================
  Future<void> fetchAllTimesheets() async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== FETCH EMPLOYER TIMESHEETS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer-timesheet/all'),
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
          
          allTimesheets.value = List<Map<String, dynamic>>.from(
            data['all'] ?? []
          );
          pendingTimesheets.value = List<Map<String, dynamic>>.from(
            data['pending'] ?? []
          );
          approvedTimesheets.value = List<Map<String, dynamic>>.from(
            data['approved'] ?? []
          );
          rejectedTimesheets.value = List<Map<String, dynamic>>.from(
            data['rejected'] ?? []
          );
          
          totalPending.value = data['counts']['pending'] ?? 0;
          totalApproved.value = data['counts']['approved'] ?? 0;
          totalRejected.value = data['counts']['rejected'] ?? 0;
          totalHoursPending.value = data['counts']['totalHoursPending']?.toDouble() ?? 0.0;
          
          print("✅ Timesheets fetched successfully");
          print("📊 Pending: $totalPending, Approved: $totalApproved, Rejected: $totalRejected");
        }
      } else {
        print("❌ Failed to fetch: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== APPROVE TIMESHEET ====================
  Future<bool> approveTimesheet(String timesheetId) async {
    try {
      isProcessing.value = true;
      
      print("\n🟡 ===== APPROVE TIMESHEET STARTED =====");
      print("📝 Timesheet ID: $timesheetId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/employer-timesheet/$timesheetId/approve'),
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
          await fetchAllTimesheets();
          print("✅ Timesheet approved successfully");
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

  // ==================== REJECT TIMESHEET ====================
  Future<bool> rejectTimesheet(String timesheetId, String reason) async {
    try {
      isProcessing.value = true;
      
      print("\n🟡 ===== REJECT TIMESHEET STARTED =====");
      print("📝 Timesheet ID: $timesheetId");
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
        Uri.parse('$baseUrl/api/employer-timesheet/$timesheetId/reject'),
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
          await fetchAllTimesheets();
          print("✅ Timesheet rejected successfully");
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

  // ==================== FETCH TIMESHEET DETAILS ====================
  Future<void> fetchTimesheetDetails(String timesheetId) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer-timesheet/$timesheetId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          selectedTimesheet.value = jsonResponse['timesheet'];
        }
      }
    } catch (e) {
      print("❌ Error fetching details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FILTER TIMESHEETS ====================
  List<Map<String, dynamic>> get filteredTimesheets {
    var list = <Map<String, dynamic>>[];
    
    switch (selectedFilter.value) {
      case 'pending':
        list = pendingTimesheets;
        break;
      case 'approved':
        list = approvedTimesheets;
        break;
      case 'rejected':
        list = rejectedTimesheets;
        break;
      default:
        list = allTimesheets;
    }
    
    if (searchQuery.value.isEmpty) return list;
    
    return list.where((ts) {
      final employeeName = ts['employeeName']?.toString().toLowerCase() ?? '';
      return employeeName.contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // ==================== SET FILTER ====================
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // ==================== SEARCH ====================
  void search(String query) {
    searchQuery.value = query;
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

  String formatDateRange(String? weekStart, String? weekEnd) {
    if (weekStart == null || weekEnd == null) return '';
    return '${formatDate(weekStart)} - ${formatDate(weekEnd)}';
  }

  String getWeekNumber(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final firstDayOfYear = DateTime(date.year, 1, 1);
      final days = date.difference(firstDayOfYear).inDays;
      return 'Week ${((days + firstDayOfYear.weekday - 1) / 7).ceil()}';
    } catch (e) {
      return '';
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

  // Clear messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';

class EmployeeTimesheetController extends GetxController {
  static EmployeeTimesheetController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  
  // Weekly Data
  var weeklyData = <Map<String, dynamic>>[].obs;
  var weekStart = Rx<DateTime?>(null);
  var weekEnd = Rx<DateTime?>(null);
  var weekNumber = 0.obs;
  
  // Summary
  var totalHours = 0.0.obs;
  var billableHours = 0.0.obs;
  var overtime = 0.0.obs;
  var targetHours = 40.obs;
  var percentage = 0.0.obs;
  
  // History
  var historyEntries = <Map<String, dynamic>>[].obs;
var historyStats = <String, dynamic>{}.obs;

  
  // Projects Breakdown
  var projects = <Map<String, dynamic>>[].obs;
  var projectTotalHours = 0.0.obs;
  
  // Error/Success messages
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchTimesheetHistory();
    fetchWeeklyTimesheet();
  }

  // ==================== FETCH WEEKLY TIMESHEET ====================
  Future<void> fetchWeeklyTimesheet({DateTime? weekStartDate}) async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== FETCH WEEKLY TIMESHEET STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      String url = '$baseUrl/api/employee-timesheet/weekly';
      if (weekStartDate != null) {
        url += '?weekStart=${weekStartDate.toIso8601String()}';
      }

      final response = await http.get(
        Uri.parse(url),
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
          
          weekStart.value = DateTime.parse(data['weekStart']);
          weekEnd.value = DateTime.parse(data['weekEnd']);
          weekNumber.value = data['weekNumber'];
          
          weeklyData.value = List<Map<String, dynamic>>.from(
            data['weeklyData'] ?? []
          );
          
          final summary = data['summary'];
          totalHours.value = (summary['totalHours'] ?? 0).toDouble();
          billableHours.value = (summary['billableHours'] ?? 0).toDouble();
          overtime.value = (summary['overtime'] ?? 0).toDouble();
          percentage.value = (summary['percentage'] ?? 0).toDouble();
          
          print("✅ Weekly timesheet fetched successfully");
          print("📊 Total Hours: $totalHours");
        }
      } else {
        print("❌ Failed to fetch: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FETCH TIMESHEET HISTORY ====================
  Future<void> fetchTimesheetHistory({int? month, int? year}) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      String url = '$baseUrl/api/employee-timesheet/history';
      if (month != null && year != null) {
        url += '?month=$month&year=$year';
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
          final data = jsonResponse['data'];
          
          historyEntries.value = List<Map<String, dynamic>>.from(
            data['entries'] ?? []
          );
          historyStats.value = Map<String, dynamic>.from(data['stats'] ?? {});
        }
      }
    } catch (e) {
      print("❌ Error fetching history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== FETCH PROJECT BREAKDOWN ====================
  Future<void> fetchProjectBreakdown({DateTime? start, DateTime? end}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      String url = '$baseUrl/api/employee-timesheet/projects';
      if (start != null && end != null) {
        url += '?startDate=${start.toIso8601String()}&endDate=${end.toIso8601String()}';
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
          final data = jsonResponse['data'];
          
          projects.value = List<Map<String, dynamic>>.from(
            data['projects'] ?? []
          );
          projectTotalHours.value = (data['totalHours'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      print("❌ Error fetching projects: $e");
    }
  }

  // ==================== ADD TIME ENTRY ====================
  Future<bool> addTimeEntry({
    required String project,
    required String task,
    required DateTime date,
    required double hours,
    String? description,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== ADD TIME ENTRY STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        return false;
      }

      final body = {
        'project': project,
        'task': task,
        'date': date.toIso8601String(),
        'hours': hours,
        if (description != null) 'description': description,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/employee-timesheet/add'),
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
            fetchWeeklyTimesheet(),
            fetchTimesheetHistory(),
          ]);
          
          print("✅ Time entry added successfully");
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

  // ==================== DELETE TIME ENTRY ====================
  Future<bool> deleteTimeEntry(String entryId) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/api/employee-timesheet/$entryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          await Future.wait([
            fetchWeeklyTimesheet(),
            fetchTimesheetHistory(),
          ]);
          return true;
        }
      }
      return false;
    } catch (e) {
      print("❌ Error deleting entry: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== NAVIGATE WEEK ====================
  void previousWeek() {
    if (weekStart.value != null) {
      final newStart = weekStart.value!.subtract(const Duration(days: 7));
      fetchWeeklyTimesheet(weekStartDate: newStart);
    }
  }

  void nextWeek() {
    if (weekStart.value != null) {
      final newStart = weekStart.value!.add(const Duration(days: 7));
      fetchWeeklyTimesheet(weekStartDate: newStart);
    }
  }

  // ==================== FORMATTING METHODS ====================
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatDateRange() {
    if (weekStart.value == null || weekEnd.value == null) return '';
    return '${DateFormat('MMM dd').format(weekStart.value!)} - ${DateFormat('MMM dd, yyyy').format(weekEnd.value!)}';
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat('h:mm a').format(dateTime);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
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
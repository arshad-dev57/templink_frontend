// lib/Employer/Controllers/employer_attendance_history_controller.dart

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class EmployerAttendanceHistoryController extends GetxController {
  static EmployerAttendanceHistoryController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var isLoadingDetails = false.obs;
  var isLoadingToday = false.obs;
  
  // Today's Attendance Stats
  var todayTotalTeam = 0.obs;
  var todayPresentCount = 0.obs;
  var todayLateCount = 0.obs;
  var todayAbsentCount = 0.obs;
  var todayLeaveCount = 0.obs;
  var todayAttendanceRate = 0.0.obs;
  var todayPresentPercentage = 0.obs;
  var todayAttendanceList = <Map<String, dynamic>>[].obs;
  
  // History Data
  var employees = <Map<String, dynamic>>[].obs;
  var trendData = <Map<String, dynamic>>[].obs;
  var summary = {}.obs;
  
  // Selected employee details
  var selectedEmployee = Rx<Map<String, dynamic>?>(null);
  var employeeRecords = <Map<String, dynamic>>[].obs;
  
  // Date selection
  var selectedView = 'monthly'.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var customStartDate = Rx<DateTime?>(null);
  var customEndDate = Rx<DateTime?>(null);
  var selectedPeriod = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    updateSelectedPeriod();
    fetchTodayAttendance(); // 👈 New: Fetch today's stats
    fetchAttendanceHistory();
  }

  // ==================== FETCH TODAY'S ATTENDANCE ====================
  Future<void> fetchTodayAttendance() async {
    try {
      isLoadingToday.value = true;
      
      print("\n🟡 ===== FETCH TODAY'S ATTENDANCE STATS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/employer-attendance-history/today-stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data']['today'];
          
          todayTotalTeam.value = data['totalTeam'] ?? 0;
          todayPresentCount.value = data['presentCount'] ?? 0;
          todayLateCount.value = data['lateCount'] ?? 0;
          todayAbsentCount.value = data['absentCount'] ?? 0;
          todayLeaveCount.value = data['leaveCount'] ?? 0;
          todayAttendanceRate.value = (data['attendanceRate'] ?? 0).toDouble();
          todayPresentPercentage.value = data['presentPercentage'] ?? 0;
          todayAttendanceList.value = List<Map<String, dynamic>>.from(
            data['attendanceList'] ?? []
          );
          
          print("✅ Today's attendance fetched successfully");
          print("📊 Present: $todayPresentCount, Late: $todayLateCount, Absent: $todayAbsentCount, Leave: $todayLeaveCount");
        }
      } else {
        print("❌ Failed to fetch: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      isLoadingToday.value = false;
      print("🟢 ===== FETCH TODAY'S ATTENDANCE STATS ENDED =====");
    }
  }

  // ==================== UPDATE SELECTED PERIOD ====================
  void updateSelectedPeriod() {
    if (selectedView.value == 'monthly') {
      selectedPeriod.value = '${_getMonthName(selectedMonth.value)} ${selectedYear.value}';
    } else if (selectedView.value == 'yearly') {
      selectedPeriod.value = '${selectedYear.value}';
    } else if (selectedView.value == 'custom') {
      if (customStartDate.value != null && customEndDate.value != null) {
        selectedPeriod.value = '${customStartDate.value!.day} ${_getMonthName(customStartDate.value!.month)} - '
            '${customEndDate.value!.day} ${_getMonthName(customEndDate.value!.month)} ${customEndDate.value!.year}';
      } else {
        selectedPeriod.value = 'Select Range';
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // ==================== FETCH ATTENDANCE HISTORY ====================
  Future<void> fetchAttendanceHistory() async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== FETCH ATTENDANCE HISTORY STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      // Build URL with query parameters
      String url = '$baseUrl/api/employer-attendance-history/history?';
      url += 'view=${selectedView.value}';
      
      if (selectedView.value == 'monthly') {
        url += '&month=${selectedMonth.value}&year=${selectedYear.value}';
      } else if (selectedView.value == 'yearly') {
        url += '&year=${selectedYear.value}';
      } else if (selectedView.value == 'custom') {
        if (customStartDate.value != null && customEndDate.value != null) {
          url += '&startDate=${customStartDate.value!.toIso8601String()}';
          url += '&endDate=${customEndDate.value!.toIso8601String()}';
        }
      }

      print("🌐 URL: $url");

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
          
          employees.value = List<Map<String, dynamic>>.from(
            data['employees'] ?? []
          );
          
          trendData.value = List<Map<String, dynamic>>.from(
            data['trend'] ?? []
          );
          
          summary.value = data['summary'] ?? {};
          
          print("✅ Attendance history fetched successfully");
          print("📊 Employees: ${employees.length}");
          print("📊 Trend data: ${trendData.length}");
        }
      } else {
        print("❌ Failed to fetch: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
      print("🟢 ===== FETCH ATTENDANCE HISTORY ENDED =====");
    }
  }

  // ==================== FETCH EMPLOYEE DETAILS ====================
  Future<void> fetchEmployeeDetails(String employeeId) async {
    try {
      isLoadingDetails.value = true;
      
      print("\n🟡 ===== FETCH EMPLOYEE DETAILS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      String url = '$baseUrl/api/employer-attendance-history/employee/$employeeId';
      url += '?month=${selectedMonth.value}&year=${selectedYear.value}';

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
          
          selectedEmployee.value = data['employee'];
          employeeRecords.value = List<Map<String, dynamic>>.from(
            data['records'] ?? []
          );
          
          print("✅ Employee details fetched");
          print("📊 Records: ${employeeRecords.length}");
        }
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      isLoadingDetails.value = false;
    }
  }

  // ==================== SET VIEW ====================
  void setView(String view) {
    selectedView.value = view;
    updateSelectedPeriod();
    fetchAttendanceHistory();
  }

  // ==================== SET MONTH ====================
  void setMonth(int month) {
    selectedMonth.value = month;
    updateSelectedPeriod();
    fetchAttendanceHistory();
  }

  // ==================== SET YEAR ====================
  void setYear(int year) {
    selectedYear.value = year;
    updateSelectedPeriod();
    fetchAttendanceHistory();
  }

  // ==================== SET CUSTOM RANGE ====================
  void setCustomRange(DateTime start, DateTime end) {
    customStartDate.value = start;
    customEndDate.value = end;
    updateSelectedPeriod();
    fetchAttendanceHistory();
  }

  // ==================== REFRESH ALL ====================
  Future<void> refreshAll() async {
    await Future.wait([
      fetchTodayAttendance(),
      fetchAttendanceHistory(),
    ]);
  }

  // ==================== CLEAR SELECTED EMPLOYEE ====================
  void clearSelectedEmployee() {
    selectedEmployee.value = null;
    employeeRecords.clear();
  }

  // ==================== GETTERS ====================
  String getStatusColor(String status) {
    switch (status) {
      case 'present':
        return '0xFF4CAF50'; // Green
      case 'late':
        return '0xFFFF9800'; // Orange
      case 'absent':
        return '0xFFF44336'; // Red
      case 'leave':
        return '0xFF2196F3'; // Blue
      case 'half_day':
        return '0xFF9C27B0'; // Purple
      default:
        return '0xFF9E9E9E'; // Grey
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      case 'leave':
        return 'Leave';
      case 'half_day':
        return 'Half Day';
      default:
        return status;
    }
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
  
  // Today's Stats Getters
  String get todayPresentString => todayPresentCount.value.toString();
  String get todayLateString => todayLateCount.value.toString();
  String get todayAbsentString => todayAbsentCount.value.toString();
  String get todayLeaveString => todayLeaveCount.value.toString();
  double get todayAttendanceBarValue => todayTotalTeam.value > 0 
      ? (todayPresentCount.value + todayLateCount.value) / todayTotalTeam.value 
      : 0;
}
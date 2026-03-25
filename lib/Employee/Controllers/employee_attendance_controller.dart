// lib/Employee/Controllers/employee_attendance_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';

class EmployeeAttendanceController extends GetxController {
  static EmployeeAttendanceController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var isCheckingIn = false.obs;
  var isCheckingOut = false.obs;
  
  // Today's attendance
  var isCheckedIn = false.obs;
  var isCheckedOut = false.obs;
  var checkInTime = Rx<DateTime?>(null);
  var checkOutTime = Rx<DateTime?>(null);
  var attendanceStatus = ''.obs;
  var isLate = false.obs;
  var lateMinutes = 0.obs;
  var totalHours = 0.0.obs;
  var officeStartTime = '09:00'.obs;
  var officeEndTime = '18:00'.obs;
  var gracePeriod = 10.obs;
  var pointsBalance = 0.obs;
  
  // History
  var attendanceHistory = <Map<String, dynamic>>[].obs;
  var historyStats = {}.obs;
  
  // Error/Success messages
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    getTodayAttendance();
    
    ever(isCheckedIn, (_) {});
    ever(isCheckedOut, (_) {});
    
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(minutes: 1), (timer) {
        if (Get.isRegistered<EmployeeAttendanceController>()) {
          checkInTime.refresh();
          checkOutTime.refresh();
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ==================== GET TODAY'S ATTENDANCE ====================
  Future<void> getTodayAttendance() async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/api/employee-dashboard/today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print("today attendance ${response.statusCode}");
      print("today response ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          isCheckedIn.value = data['isCheckedIn'] ?? false;
          isCheckedOut.value = data['isCheckedOut'] ?? false;
          
          if (data['checkIn'] != null) {
            checkInTime.value = DateTime.parse(data['checkIn']).toLocal();
          }
          
          if (data['checkOut'] != null) {
            checkOutTime.value = DateTime.parse(data['checkOut']).toLocal();
          }
          
          attendanceStatus.value = data['status'] ?? '';
          isLate.value = data['isLate'] ?? false;
          lateMinutes.value = data['lateMinutes'] ?? 0;
          totalHours.value = (data['totalHours'] ?? 0).toDouble();
          officeStartTime.value = data['officeStartTime'] ?? '09:00';
          officeEndTime.value = data['officeEndTime'] ?? '18:00';
          gracePeriod.value = data['gracePeriod'] ?? 10;
          pointsBalance.value = data['pointsBalance'] ?? 0;
        }
      }
    } catch (e) {
      print("❌ Error fetching today's attendance: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== CHECK IN ====================
  Future<bool> checkIn({double? latitude, double? longitude, String? locationName}) async {
    try {
      isCheckingIn.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== CHECK IN STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        return false;
      }

      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName ?? 'Unknown Location',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/employee-dashboard/check-in'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print(response.body);
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          isCheckedIn.value = true;
          checkInTime.value = DateTime.parse(data['checkIn']).toLocal();
          attendanceStatus.value = data['status'];
          isLate.value = data['isLate'];
          lateMinutes.value = data['lateMinutes'];
          
          successMessage.value = jsonResponse['message'];
          print("✅ Check-in successful: ${checkInTime.value}");
          print("📍 Local time: ${formatTime(checkInTime.value)}");
          
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
      isCheckingIn.value = false;
    }
  }

  // ==================== CHECK OUT ====================
  Future<bool> checkOut({double? latitude, double? longitude, String? locationName}) async {
    try {
      isCheckingOut.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== CHECK OUT STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        return false;
      }

      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName ?? 'Unknown Location',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/employee-dashboard/check-out'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          
          isCheckedOut.value = true;
          checkOutTime.value = DateTime.parse(data['checkOut']).toLocal();
          totalHours.value = data['totalHours'].toDouble();
          
          successMessage.value = jsonResponse['message'];
          print("✅ Check-out successful: ${checkOutTime.value}");
          print("📍 Local time: ${formatTime(checkOutTime.value)}");
          print("📊 Total hours: $totalHours");
          
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
      isCheckingOut.value = false;
    }
  }

  // ==================== GET ATTENDANCE HISTORY ====================
  Future<void> getAttendanceHistory({int? month, int? year}) async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      String url = '$baseUrl/api/employee-attendance/history';
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
          final records = jsonResponse['data']['records'] as List;
          attendanceHistory.value = records.map((record) {
            if (record['checkIn'] != null) {
              record['checkIn'] = DateTime.parse(record['checkIn']).toLocal().toIso8601String();
            }
            if (record['checkOut'] != null) {
              record['checkOut'] = DateTime.parse(record['checkOut']).toLocal().toIso8601String();
            }
            return Map<String, dynamic>.from(record);
          }).toList();
          
          historyStats.value = jsonResponse['data']['stats'];
        }
      }
    } catch (e) {
      print("❌ Error fetching history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== OFFICE HOURS HELPERS ====================
  
  DateTime getOfficeStartDateTime() {
    try {
      final now = DateTime.now();
      final parts = officeStartTime.value.split(':');
      if (parts.length == 2) {
        return DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing office start time: $e');
    }
    return DateTime.now();
  }

  DateTime getOfficeEndDateTime() {
    try {
      final now = DateTime.now();
      final parts = officeEndTime.value.split(':');
      if (parts.length == 2) {
        return DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing office end time: $e');
    }
    return DateTime.now();
  }

  // 30 minutes before office start
  DateTime getCheckInStartTime() {
    final officeStart = getOfficeStartDateTime();
    return officeStart.subtract(const Duration(minutes: 30));
  }

  // Check-in deadline (office start + grace period)
  DateTime getCheckInDeadline() {
    try {
      final now = DateTime.now();
      final parts = officeStartTime.value.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        minute += gracePeriod.value;
        hour += minute ~/ 60;
        minute %= 60;
        
        return DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
      }
    } catch (e) {
      print('Error calculating deadline: $e');
    }
    return DateTime.now();
  }

  // Check-out end time based on CHECK-IN DATE (office end + 2 hours)
  DateTime getCheckOutEndTime() {
    // Agar checkInTime available hai toh us date se calculate karo
    if (checkInTime.value != null) {
      final checkInDate = checkInTime.value!;
      final parts = officeEndTime.value.split(':');
      if (parts.length == 2) {
        final officeEndOnCheckInDay = DateTime(
          checkInDate.year,
          checkInDate.month,
          checkInDate.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        return officeEndOnCheckInDay.add(const Duration(hours: 2));
      }
    }
    // Fallback: aaj ki date se calculate karo
    final officeEnd = getOfficeEndDateTime();
    return officeEnd.add(const Duration(hours: 2));
  }

  bool canCheckIn() {
    final now = DateTime.now();
    final checkInStart = getCheckInStartTime();
    final checkInDeadline = getCheckInDeadline();
    
    return !isCheckedIn.value && 
           !isCheckedOut.value &&
           now.isAfter(checkInStart) && 
           now.isBefore(checkInDeadline);
  }

  // ✅ FIXED: Check-in date ke basis pe checkout window calculate karo
  bool canCheckOut() {
    if (!isCheckedIn.value || isCheckedOut.value) return false;
    if (checkInTime.value == null) return false;

    final now = DateTime.now();

    // Check-in ki DATE use karo office end calculate karne ke liye
    final checkInDate = checkInTime.value!;
    final parts = officeEndTime.value.split(':');
    if (parts.length != 2) return false;

    final officeEndOnCheckInDay = DateTime(
      checkInDate.year,
      checkInDate.month,
      checkInDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // Checkout window = office end + 2 hours (check-in wali date ke basis pe)
    final checkOutDeadline = officeEndOnCheckInDay.add(const Duration(hours: 2));

    return now.isBefore(checkOutDeadline);
  }

  bool isAbsentToday() {
    if (isCheckedIn.value || isCheckedOut.value) return false;
    
    final now = DateTime.now();
    final checkInDeadline = getCheckInDeadline();
    final officeEnd = getOfficeEndDateTime();
    
    return now.isAfter(checkInDeadline) && now.isBefore(officeEnd);
  }

  // ==================== FORMATTING METHODS ====================
  
  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('h:mm a').format(time);
  }

  String formatTime24(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('HH:mm').format(time);
  }

  String formatDateTime(DateTime? time) {
    if (time == null) return '--:--';
    return DateFormat('MMM dd, yyyy h:mm a').format(time);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatUTCTime(String? utcTimeString) {
    if (utcTimeString == null) return '--:--';
    try {
      final utcTime = DateTime.parse(utcTimeString);
      final localTime = utcTime.toLocal();
      return DateFormat('h:mm a').format(localTime);
    } catch (e) {
      return '--:--';
    }
  }

  String formatUTCDate(String? utcTimeString) {
    if (utcTimeString == null) return '';
    try {
      final utcTime = DateTime.parse(utcTimeString);
      final localTime = utcTime.toLocal();
      return DateFormat('MMM dd, yyyy').format(localTime);
    } catch (e) {
      return '';
    }
  }

  // Formatted getters
  String get formattedOfficeStart {
    try {
      final parts = officeStartTime.value.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (e) {}
    return officeStartTime.value;
  }

  String get formattedOfficeEnd {
    try {
      final parts = officeEndTime.value.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (e) {}
    return officeEndTime.value;
  }

  String get formattedCheckInStart {
    final time = getCheckInStartTime();
    return DateFormat('h:mm a').format(time);
  }

  String get formattedCheckOutEnd {
    final time = getCheckOutEndTime();
    return DateFormat('h:mm a').format(time);
  }

  String get checkInTimeFormatted => formatTime(checkInTime.value);
  String get checkOutTimeFormatted => formatTime(checkOutTime.value);
  
  String get statusText {
    if (!isCheckedIn.value) return 'Not Checked In';
    if (isCheckedOut.value) return 'Checked Out';
    if (isLate.value) return 'Late (${lateMinutes} min)';
    return 'On Time';
  }

  Color get statusColor {
    if (!isCheckedIn.value) return Colors.red;
    if (isCheckedOut.value) return Colors.grey;
    if (isLate.value) return Colors.orange;
    return Colors.green;
  }
          
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}
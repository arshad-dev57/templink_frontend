// lib/Employer/Controllers/employer_dashboard_controller.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class EmployerAttendanceDashboardController extends GetxController {

  // Observables
  var isLoading = false.obs;
  var isLoadingTeam = false.obs;
  var isLoadingJobs = false.obs;
  var isUpdatingOfficeHours = false.obs;
  
  // Dashboard stats
  var totalTeam = 0.obs;
  var activeTeam = 0.obs;
  var leftTeam = 0.obs;
  var totalTeamAll = 0.obs;
  
  var totalJobs = 0.obs;
  var activeJobs = 0.obs;
  var pausedJobs = 0.obs;
  var openJobs = 0.obs;
  
  var totalApplications = 0.obs;
  var pendingApplications = 0.obs;
  var hiredCount = 0.obs;
  var shortlistedCount = 0.obs;
  var rejectedCount = 0.obs;
  var hiringRequests = 0.obs;
  
  // For UI display
  var myJobs = 0.obs;
  var jobApplications = 0.obs;
  
  // Office Hours
  var checkInTime = '09:00'.obs;
  var checkOutTime = '18:00'.obs;
  var gracePeriod = 10.obs;
  var lateThreshold = '09:10'.obs;
  
  // ==================== NEW: TODAY'S ATTENDANCE STATS ====================
  var attendanceLoading = false.obs;
  var presentCount = 0.obs;
  var lateCount = 0.obs;
  var absentCount = 0.obs;
  var leaveCount = 0.obs;
  var attendanceRate = 0.0.obs;
  var presentPercentage = '0'.obs;
  var attendanceList = <Map<String, dynamic>>[].obs;
  
  // Success/Error messages
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    print("🚀 ===== CONTROLLER INITIALIZED =====");
    print("📊 Initial values - CheckIn: $checkInTime, CheckOut: $checkOutTime, Grace: $gracePeriod");
    
    // Load from SharedPreferences first for instant display
    loadFromPreferences();
    
    // Then fetch from API
    fetchDashboardStats();
    fetchOfficeHours();
    fetchTodayAttendance(); // 👈 NEW: Fetch today's attendance
  }

  // ==================== LOAD FROM SHARED PREFERENCES ====================
  Future<void> loadFromPreferences() async {
    try {
      print("\n🟡 ===== LOADING FROM SHARED PREFERENCES =====");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final savedCheckIn = prefs.getString('office_checkIn');
      final savedCheckOut = prefs.getString('office_checkOut');
      final savedGracePeriod = prefs.getInt('office_gracePeriod');
      
      print("📦 Raw from SharedPreferences:");
      print("   - savedCheckIn: $savedCheckIn");
      print("   - savedCheckOut: $savedCheckOut");
      print("   - savedGracePeriod: $savedGracePeriod");
      
      if (savedCheckIn != null && savedCheckIn.isNotEmpty) {
        print("✅ Loading checkIn from prefs: $savedCheckIn");
        checkInTime.value = savedCheckIn;
      } else {
        print("⚠️ No saved checkIn found, keeping default: ${checkInTime.value}");
      }
      
      if (savedCheckOut != null && savedCheckOut.isNotEmpty) {
        print("✅ Loading checkOut from prefs: $savedCheckOut");
        checkOutTime.value = savedCheckOut;
      } else {
        print("⚠️ No saved checkOut found, keeping default: ${checkOutTime.value}");
      }
      
      if (savedGracePeriod != null) {
        print("✅ Loading gracePeriod from prefs: $savedGracePeriod");
        gracePeriod.value = savedGracePeriod;
      } else {
        print("⚠️ No saved gracePeriod found, keeping default: ${gracePeriod.value}");
      }
      
      // Update late threshold based on loaded values
      _updateLateThreshold();
      
      print("📊 Final values after loading:");
      print("   - checkInTime: ${checkInTime.value}");
      print("   - checkOutTime: ${checkOutTime.value}");
      print("   - gracePeriod: ${gracePeriod.value}");
      print("   - lateThreshold: ${lateThreshold.value}");
      
    } catch (e) {
      print("❌ Error loading from preferences: $e");
    }
  }

  // ==================== FETCH ALL DASHBOARD STATS ====================
  Future<void> fetchDashboardStats() async {
    try {
      isLoading.value = true;
      
      print("\n🟡 ===== FETCH DASHBOARD STATS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final url = '$baseUrl/api/attendance-dashboard/dashboard-stats';
      print("🌐 URL: $url");
      print("🔑 Token: ${token.substring(0, min(20, token.length))}...");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final stats = jsonResponse['stats'];
          print("📊 Stats received from API: $stats");
          
          // Team stats
          totalTeam.value = stats['totalTeam'] ?? 0;
          activeTeam.value = stats['activeTeam'] ?? 0;
          leftTeam.value = stats['leftTeam'] ?? 0;
          totalTeamAll.value = stats['totalTeamAll'] ?? 0;
          
          // Jobs stats
          totalJobs.value = stats['totalJobs'] ?? 0;
          activeJobs.value = stats['activeJobs'] ?? 0;
          pausedJobs.value = stats['pausedJobs'] ?? 0;
          openJobs.value = stats['openJobs'] ?? 0;
          
          // Applications stats
          totalApplications.value = stats['totalApplications'] ?? 0;
          pendingApplications.value = stats['pendingApplications'] ?? 0;
          hiredCount.value = stats['hiredCount'] ?? 0;
          shortlistedCount.value = stats['shortlistedCount'] ?? 0;
          rejectedCount.value = stats['rejectedCount'] ?? 0;
          hiringRequests.value = stats['hiringRequests'] ?? 0;
          
          // UI stats
          myJobs.value = stats['myJobs'] ?? 0;
          jobApplications.value = stats['jobApplications'] ?? 0;
          
          // Office Hours (if included in response)
          if (stats['officeHours'] != null) {
            print("🏢 Office hours found in dashboard stats: ${stats['officeHours']}");
            
            final apiCheckIn = stats['officeHours']['checkIn'] ?? '09:00';
            final apiCheckOut = stats['officeHours']['checkOut'] ?? '18:00';
            final apiGracePeriod = stats['officeHours']['gracePeriod'] ?? 10;
            
            print("📊 API Values - CheckIn: $apiCheckIn, CheckOut: $apiCheckOut, Grace: $apiGracePeriod");
            print("📊 Current Values - CheckIn: ${checkInTime.value}, CheckOut: ${checkOutTime.value}, Grace: ${gracePeriod.value}");
            
            // Update only if different
            if (checkInTime.value != apiCheckIn) {
              print("🔄 Updating checkIn from API: ${checkInTime.value} -> $apiCheckIn");
              checkInTime.value = apiCheckIn;
            }
            if (checkOutTime.value != apiCheckOut) {
              print("🔄 Updating checkOut from API: ${checkOutTime.value} -> $apiCheckOut");
              checkOutTime.value = apiCheckOut;
            }
            if (gracePeriod.value != apiGracePeriod) {
              print("🔄 Updating gracePeriod from API: ${gracePeriod.value} -> $apiGracePeriod");
              gracePeriod.value = apiGracePeriod;
            }
            
            // Save to SharedPreferences for persistence
            await prefs.setString('office_checkIn', checkInTime.value);
            await prefs.setString('office_checkOut', checkOutTime.value);
            await prefs.setInt('office_gracePeriod', gracePeriod.value);
            print("💾 Saved to SharedPreferences");
          }
          
          print("✅ Dashboard stats fetched successfully");
          print("📊 Final values after dashboard fetch:");
          print("   - checkInTime: ${checkInTime.value}");
          print("   - checkOutTime: ${checkOutTime.value}");
          print("   - gracePeriod: ${gracePeriod.value}");
        } else {
          print("❌ API returned success=false: ${jsonResponse['message']}");
        }
      } else {
        print("❌ Failed to fetch dashboard stats: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception fetching dashboard stats: $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print("🟢 ===== FETCH DASHBOARD STATS ENDED =====");
    }
  }

  // ==================== NEW: FETCH TODAY'S ATTENDANCE ====================
  Future<void> fetchTodayAttendance() async {
    try {
      attendanceLoading.value = true;
      
      print("\n🟡 ===== FETCH TODAY'S ATTENDANCE STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final url = '$baseUrl/api/employer-attendance/today-stats';
      print("🌐 URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          final summary = data['summary'];
          
          // Update attendance stats
          presentCount.value = summary['presentCount'] ?? 0;
          lateCount.value = summary['lateCount'] ?? 0;
          absentCount.value = summary['absentCount'] ?? 0;
          leaveCount.value = summary['leaveCount'] ?? 0;
          attendanceRate.value = (summary['attendanceRate'] ?? 0).toDouble();
          presentPercentage.value = summary['presentPercentage']?.toString() ?? '0';
          
          // Update attendance list
          attendanceList.value = List<Map<String, dynamic>>.from(
            data['attendanceList'] ?? []
          );
          
          print("✅ Today's attendance fetched successfully");
          print("📊 Present: $presentCount, Late: $lateCount, Absent: $absentCount, Leave: $leaveCount");
          print("📊 Attendance List Length: ${attendanceList.length}");
        } else {
          print("❌ API returned success: false");
        }
      } else {
        print("❌ Failed to fetch: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    } finally {
      attendanceLoading.value = false;
      print("🟢 ===== FETCH TODAY'S ATTENDANCE ENDED =====");
    }
  }

  // ==================== FETCH OFFICE HOURS ====================
  Future<void> fetchOfficeHours() async {
    try {
      print("\n🟡 ===== FETCH OFFICE HOURS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final url = '$baseUrl/api/attendance-dashboard/office-hours';
      print("🌐 URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final officeHours = jsonResponse['officeHours'];
          print("🏢 Office hours from API: $officeHours");
          
          final apiCheckIn = officeHours['checkIn'] ?? '09:00';
          final apiCheckOut = officeHours['checkOut'] ?? '18:00';
          final apiGracePeriod = officeHours['gracePeriod'] ?? 10;
          
          print("📊 API Values - CheckIn: $apiCheckIn, CheckOut: $apiCheckOut, Grace: $apiGracePeriod");
          print("📊 Current Values - CheckIn: ${checkInTime.value}, CheckOut: ${checkOutTime.value}, Grace: ${gracePeriod.value}");
          
          // Update only if different
          if (checkInTime.value != apiCheckIn) {
            print("🔄 Updating checkIn from API: ${checkInTime.value} -> $apiCheckIn");
            checkInTime.value = apiCheckIn;
          }
          if (checkOutTime.value != apiCheckOut) {
            print("🔄 Updating checkOut from API: ${checkOutTime.value} -> $apiCheckOut");
            checkOutTime.value = apiCheckOut;
          }
          if (gracePeriod.value != apiGracePeriod) {
            print("🔄 Updating gracePeriod from API: ${gracePeriod.value} -> $apiGracePeriod");
            gracePeriod.value = apiGracePeriod;
          }
          
          // Update late threshold
          _updateLateThreshold();
          
          // Save to SharedPreferences
          await prefs.setString('office_checkIn', checkInTime.value);
          await prefs.setString('office_checkOut', checkOutTime.value);
          await prefs.setInt('office_gracePeriod', gracePeriod.value);
          print("💾 Saved updated values to SharedPreferences");
          
          print("✅ Office hours fetched successfully");
          print("📊 Final values after fetch:");
          print("   - checkInTime: ${checkInTime.value}");
          print("   - checkOutTime: ${checkOutTime.value}");
          print("   - gracePeriod: ${gracePeriod.value}");
          print("   - lateThreshold: ${lateThreshold.value}");
        } else {
          print("❌ API returned success=false: ${jsonResponse['message']}");
        }
      } else {
        print("❌ Failed to fetch office hours: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception fetching office hours: $e");
    } finally {
      print("🟢 ===== FETCH OFFICE HOURS ENDED =====");
    }
  }

  // ==================== UPDATE OFFICE HOURS ====================
  Future<bool> updateOfficeHours({
    required String checkIn,
    required String checkOut,
    int? gracePeriod,
  }) async {
    try {
      isUpdatingOfficeHours.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      
      print("\n🟡 ===== UPDATE OFFICE HOURS STARTED =====");
      print("📝 Request Data:");
      print("   - checkIn: $checkIn");
      print("   - checkOut: $checkOut");
      print("   - gracePeriod: $gracePeriod");
      print("📊 Current values before update:");
      print("   - checkInTime: ${checkInTime.value}");
      print("   - checkOutTime: ${checkOutTime.value}");
      print("   - gracePeriod: ${this.gracePeriod.value}");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'Authentication failed';
        print("❌ No auth token found");
        return false;
      }

      final body = {
        'checkIn': checkIn,
        'checkOut': checkOut,
        if (gracePeriod != null) 'gracePeriod': gracePeriod,
      };

      final url = '$baseUrl/api/attendance-dashboard/office-hours';
      print("🌐 URL: $url");
      print("📦 Request Body: $body");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final officeHours = jsonResponse['officeHours'];
          print("🏢 Office hours from response: $officeHours");
          
          // Update values
          checkInTime.value = officeHours['checkIn'];
          checkOutTime.value = officeHours['checkOut'];
          this.gracePeriod.value = officeHours['gracePeriod'] ?? 10;
          
          print("✅ Values updated in controller:");
          print("   - checkInTime: ${checkInTime.value}");
          print("   - checkOutTime: ${checkOutTime.value}");
          print("   - gracePeriod: ${this.gracePeriod.value}");
          
          // Update late threshold
          _updateLateThreshold();
          print("   - lateThreshold: ${lateThreshold.value}");
          
          // Save to SharedPreferences
          await prefs.setString('office_checkIn', checkInTime.value);
          await prefs.setString('office_checkOut', checkOutTime.value);
          await prefs.setInt('office_gracePeriod', this.gracePeriod.value);
          print("💾 Saved to SharedPreferences");
          
          // Verify by fetching again
          print("🔄 Verifying by fetching office hours again...");
          await fetchOfficeHours();
          
          successMessage.value = jsonResponse['message'] ?? 'Office hours updated successfully';
          
          print("✅ Office hours updated successfully");
          return true;
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Failed to update office hours';
          print("❌ API error: ${errorMessage.value}");
          return false;
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
        print("❌ HTTP error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Exception updating office hours: $e");
      errorMessage.value = e.toString();
      return false;
    } finally {
      isUpdatingOfficeHours.value = false;
      print("🟢 ===== UPDATE OFFICE HOURS ENDED =====");
    }
  }

  // ==================== UPDATE LATE THRESHOLD ====================
  void _updateLateThreshold() {
    try {
      print("\n🟡 ===== UPDATING LATE THRESHOLD =====");
      print("📊 Input - checkIn: ${checkInTime.value}, grace: ${gracePeriod.value}");
      
      final parts = checkInTime.value.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        print("⏰ Before calculation - hour: $hour, minute: $minute");
        
        // Add grace period
        minute += gracePeriod.value;
        hour += minute ~/ 60;
        minute %= 60;
        hour %= 24;
        
        lateThreshold.value = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        
        print("⏰ After calculation - hour: $hour, minute: $minute");
        print("✅ Late threshold updated to: ${lateThreshold.value}");
      } else {
        print("❌ Invalid time format: ${checkInTime.value}");
      }
    } catch (e) {
      print("❌ Error updating late threshold: $e");
    }
  }

  // ==================== FETCH ATTENDANCE SETTINGS ====================
  Future<void> fetchAttendanceSettings() async {
    try {
      print("\n🟡 ===== FETCH ATTENDANCE SETTINGS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        print("❌ No auth token found");
        return;
      }

      final url = '$baseUrl/api/attendance-dashboard/attendance-settings';
      print("🌐 URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          final settings = jsonResponse['settings'];
          print("⚙️ Settings from API: $settings");
          
          // Update office hours
          final officeHours = settings['officeHours'];
          checkInTime.value = officeHours['checkIn'] ?? '09:00';
          checkOutTime.value = officeHours['checkOut'] ?? '18:00';
          gracePeriod.value = officeHours['gracePeriod'] ?? 10;
          
          // Update late threshold
          lateThreshold.value = settings['lateThreshold'] ?? '09:10';
          
          print("✅ Attendance settings fetched");
          print("📊 Values after fetch:");
          print("   - checkInTime: ${checkInTime.value}");
          print("   - checkOutTime: ${checkOutTime.value}");
          print("   - gracePeriod: ${gracePeriod.value}");
          print("   - lateThreshold: ${lateThreshold.value}");
        } else {
          print("❌ API returned success=false: ${jsonResponse['message']}");
        }
      } else {
        print("❌ Failed to fetch settings: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception fetching attendance settings: $e");
    } finally {
      print("🟢 ===== FETCH ATTENDANCE SETTINGS ENDED =====");
    }
  }

  // ==================== FETCH TEAM STATS ONLY ====================
  Future<void> fetchTeamStats() async {
    try {
      isLoadingTeam.value = true;
      print("\n🟡 ===== FETCH TEAM STATS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final url = '$baseUrl/api/attendance-dashboard/team-stats';
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
          final stats = jsonResponse['stats'];
          print("👥 Team stats: $stats");
          
          totalTeam.value = stats['totalTeam'] ?? 0;
          activeTeam.value = stats['activeTeam'] ?? 0;
          leftTeam.value = stats['leftTeam'] ?? 0;
          totalTeamAll.value = stats['totalTeamAll'] ?? 0;
          
          print("✅ Team stats updated:");
          print("   - totalTeam: $totalTeam");
          print("   - activeTeam: $activeTeam");
        }
      }
    } catch (e) {
      print("❌ Exception fetching team stats: $e");
    } finally {
      isLoadingTeam.value = false;
      print("🟢 ===== FETCH TEAM STATS ENDED =====");
    }
  }

  // ==================== FETCH JOBS STATS ONLY ====================
  Future<void> fetchJobsStats() async {
    try {
      isLoadingJobs.value = true;
      print("\n🟡 ===== FETCH JOBS STATS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;

      final url = '$baseUrl/api/attendance-dashboard/jobs-stats';
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
          final stats = jsonResponse['stats'];
          print("💼 Jobs stats: $stats");
          
          totalJobs.value = stats['totalJobs'] ?? 0;
          activeJobs.value = stats['activeJobs'] ?? 0;
          pausedJobs.value = stats['pausedJobs'] ?? 0;
          
          // Update UI stats
          myJobs.value = totalJobs.value;
          openJobs.value = activeJobs.value;
          
          print("✅ Jobs stats updated:");
          print("   - totalJobs: $totalJobs");
          print("   - activeJobs: $activeJobs");
        }
      }
    } catch (e) {
      print("❌ Exception fetching jobs stats: $e");
    } finally {
      isLoadingJobs.value = false;
      print("🟢 ===== FETCH JOBS STATS ENDED =====");
    }
  }

  // ==================== REFRESH ALL STATS ====================
  Future<void> refreshAllStats() async {
    print("\n🔄 ===== REFRESHING ALL STATS =====");
    await Future.wait([
      fetchDashboardStats(),
      fetchOfficeHours(),
      fetchTodayAttendance(), // 👈 NEW: Refresh today's attendance too
    ]);
    print("✅ ===== ALL STATS REFRESHED =====");
  }

  // ==================== GETTERS FOR UI ====================
  String get totalTeamString => totalTeam.value.toString();
  String get activeJobsString => activeJobs.value.toString();
  String get jobApplicationsString => jobApplications.value.toString();
  String get hiringRequestsString => hiringRequests.value.toString();
  
  // Attendance getters
  String get presentCountString => presentCount.value.toString();
  String get lateCountString => lateCount.value.toString();
  String get absentCountString => absentCount.value.toString();
  String get leaveCountString => leaveCount.value.toString();
  
  double get presentBarValue => totalTeam.value > 0 
      ? (presentCount.value + lateCount.value) / totalTeam.value 
      : 0;
  
  int get absentTotal => totalTeam.value - (presentCount.value + lateCount.value);
  
  String get attendancePercentageString => 
      ((presentCount.value + lateCount.value) / (totalTeam.value > 0 ? totalTeam.value : 1) * 100).toStringAsFixed(0);
  
  // Format time for display
  String formatTimeForDisplay(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return time;
      
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      return '$displayHour:$minute $period';
    } catch (e) {
      print("❌ Error formatting time '$time': $e");
      return time;
    }
  }
  
  String get formattedCheckIn => formatTimeForDisplay(checkInTime.value);
  String get formattedCheckOut => formatTimeForDisplay(checkOutTime.value);
  String get formattedLateThreshold => formatTimeForDisplay(lateThreshold.value);
  
  // Format DateTime
  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  // Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'leave':
        return Colors.blue;
      default:
        return Colors.grey;
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
      default:
        return status;
    }
  }
  
  // Clear messages
  void clearMessages() {
    successMessage.value = '';
    errorMessage.value = '';
  }
}
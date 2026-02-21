import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:flutter/material.dart';

class EmployeeStatsController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var isLoadingEarnings = false.obs;
  var isLoadingActivity = false.obs;
  var errorMessage = ''.obs;
  
  // Stats data
  var stats = Rx<Map<String, dynamic>>({});
  
  // Profile stats
  var profileTitle = ''.obs;
  var hourlyRate = 0.0.obs;
  var pointsBalance = 0.obs;
  var rating = 0.0.obs;
  var totalReviews = 0.obs;
  
  // Proposal stats
  var totalProposals = 0.obs;
  var acceptedProposals = 0.obs;
  var pendingProposals = 0.obs;
  var rejectedProposals = 0.obs;
  var successRate = 0.obs;
  
  // Contract stats
  var totalContracts = 0.obs;
  var activeContracts = 0.obs;
  var completedContracts = 0.obs;
  
  // Project stats
  var workingProjects = 0.obs;
  var completedProjects = 0.obs;
  
  // Earnings stats
  var totalEarnings = 0.0.obs;
  var pendingEarnings = 0.0.obs;
  var averagePerProject = 0.0.obs;
  
  // Performance stats
  var averageRating = 0.0.obs;
  var totalRatings = 0.obs;
  var responseRate = 0.obs;
  
  // Timeline
  var memberSince = ''.obs;
  var totalDays = 0.obs;
  
  // Earnings history
  var earningsLabels = <String>[].obs;
  var earningsData = <double>[].obs;
  var selectedPeriod = 'month'.obs;
  
  // Recent activity
  var recentActivities = <Map<String, dynamic>>[].obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchAllStats();
  }

  Future<void> fetchAllStats() async {
    await Future.wait([
      fetchStats(),
      fetchEarningsHistory(),
      fetchRecentActivity(),
    ]);
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== FETCH EMPLOYEE STATS STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'No auth token found';
        return;
      }
      
      print("🌐 URL: $baseUrl/api/employee/stats");

      final response = await http.get(
        Uri.parse('$baseUrl/api/employee/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("✅ Stats fetched successfully");
        
        if (jsonResponse['success'] == true) {
          final statsData = jsonResponse['stats'];
          stats.value = statsData;
          
          // ✅ Profile stats - Points balance yahan se
          pointsBalance.value = statsData['profile']?['pointsBalance'] ?? 0;
          profileTitle.value = statsData['profile']?['title'] ?? 'Not set';
          hourlyRate.value = (statsData['profile']?['hourlyRate'] ?? 0).toDouble();
          rating.value = (statsData['profile']?['rating'] ?? 0).toDouble();
          totalReviews.value = statsData['profile']?['totalReviews'] ?? 0;
          
          // ✅ Proposal stats - Agar 0 hai to bhi show hoga
          totalProposals.value = statsData['proposals']?['total'] ?? 0;
          acceptedProposals.value = statsData['proposals']?['accepted'] ?? 0;
          pendingProposals.value = statsData['proposals']?['pending'] ?? 0;
          rejectedProposals.value = statsData['proposals']?['rejected'] ?? 0;
          successRate.value = statsData['proposals']?['successRate'] ?? 0;
          
          // ✅ Contract stats
          totalContracts.value = statsData['contracts']?['total'] ?? 0;
          activeContracts.value = statsData['contracts']?['active'] ?? 0;
          completedContracts.value = statsData['contracts']?['completed'] ?? 0;
          
          // ✅ Project stats
          workingProjects.value = statsData['projects']?['working'] ?? 0;
          completedProjects.value = statsData['projects']?['completed'] ?? 0;
          
          // ✅ Earnings stats - Total earnings yahan se
          totalEarnings.value = (statsData['earnings']?['total'] ?? 0).toDouble();
          pendingEarnings.value = (statsData['earnings']?['pending'] ?? 0).toDouble();
          averagePerProject.value = (statsData['earnings']?['averagePerProject'] ?? 0).toDouble();
          
          // ✅ Performance stats
          averageRating.value = double.tryParse(statsData['performance']?['averageRating']?.toString() ?? '0') ?? 0;
          totalRatings.value = statsData['performance']?['totalRatings'] ?? 0;
          responseRate.value = statsData['performance']?['responseRate'] ?? 0;
          
          // ✅ Timeline
          memberSince.value = _formatDate(statsData['timeline']?['memberSince']);
          totalDays.value = statsData['timeline']?['totalDays'] ?? 0;
          
          print("📊 Stats loaded successfully");
          print("   Points Balance: ${pointsBalance.value}");
          print("   Total Earnings: ${totalEarnings.value}");
          print("   Total Proposals: ${totalProposals.value}");
        }
      } else {
        errorMessage.value = 'Failed to load stats: ${response.statusCode}';
        print("❌ Error: ${errorMessage.value}");
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
      print("🟢 ===== FETCH STATS ENDED =====");
    }
  }

  Future<void> fetchEarningsHistory({String period = 'month'}) async {
    try {
      isLoadingEarnings.value = true;
      selectedPeriod.value = period;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/employee/stats/earnings?period=$period'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          earningsLabels.value = List<String>.from(jsonResponse['labels'] ?? []);
          earningsData.value = List<double>.from((jsonResponse['earnings'] ?? []).map((e) => e.toDouble()));
        }
      }
    } catch (e) {
      print("❌ Error fetching earnings history: $e");
    } finally {
      isLoadingEarnings.value = false;
    }
  }

  Future<void> fetchRecentActivity() async {
    try {
      isLoadingActivity.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/employee/stats/activity'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          recentActivities.value = List<Map<String, dynamic>>.from(jsonResponse['activities'] ?? []);
        }
      }
    } catch (e) {
      print("❌ Error fetching recent activity: $e");
    } finally {
      isLoadingActivity.value = false;
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day} ${_getMonth(date.month)} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String getActivityIcon(String type) {
    switch(type) {
      case 'proposal': return '📝';
      case 'contract': return '📄';
      default: return '📌';
    }
  }

  Color getActivityColor(String status) {
    switch(status) {
      case 'ACCEPTED':
      case 'ACTIVE':
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getActivityStatusText(String status) {
    switch(status) {
      case 'ACCEPTED': return 'Accepted';
      case 'REJECTED': return 'Rejected';
      case 'PENDING': return 'Pending';
      case 'ACTIVE': return 'Active';
      case 'COMPLETED': return 'Completed';
      default: return status;
    }
  }

  String formatCurrency(double amount) {
    if (amount == 0) return '\$0';
    return '\$${amount.toStringAsFixed(0)}';
  }
}
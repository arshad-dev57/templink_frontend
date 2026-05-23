// lib/Employer/controllers/employer_interest_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/employer_interest_model.dart';
import 'package:templink/config/api_config.dart';

class EmployerInterestController extends GetxController {
  final String baseUrl = ApiConfig.baseUrl;
  final allCandidates = <EmployerInterestModel>[].obs;
  final isLoading = false.obs;
  final isHiring = false.obs;
  final errorMessage = RxnString();
  final walletBalance = 0.0.obs;

  // ✅ Status counts (matching backend)
  int get pendingCount => allCandidates.where((c) => c.status == 'pending').length;
  int get interestedCount => allCandidates.where((c) => c.status == 'interested').length;
  int get declinedCount => allCandidates.where((c) => c.status == 'declined').length;
  int get hiredCount => allCandidates.where((c) => c.status == 'hired').length;
  int get cancelledCount => allCandidates.where((c) => c.status == 'cancelled').length;
  int get totalCount => allCandidates.length;

  @override
  void onInit() {
    super.onInit();
    fetchAllCandidates();
    fetchWalletBalance();
  }

  Future<void> fetchAllCandidates() async {
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
        Uri.parse('$baseUrl/api/interest/employer-list'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 All candidates response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> candidatesData = jsonResponse['data'] ?? [];
          
          allCandidates.value = candidatesData
              .map((e) => EmployerInterestModel.fromJson(e))
              .toList();

          print('✅ Loaded ${allCandidates.length} total candidates');
          print('   - Pending: $pendingCount');
          print('   - Interested: $interestedCount');
          print('   - Declined: $declinedCount');
          print('   - Hired: $hiredCount');
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Failed to load candidates';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error fetching candidates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWalletBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/balance/mybalance'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        walletBalance.value = (jsonResponse['balance'] ?? 0).toDouble();
      }
    } catch (e) {
      print('Error fetching wallet balance: $e');
    }
  }

  // ✅ Hire candidate - status changes from 'interested' to 'hired'
  Future<bool> hireCandidate(String requestId, double commissionAmount) async {
    try {
      isHiring.value = true;

      if (walletBalance.value < commissionAmount) {
        Get.snackbar(
          'Insufficient Balance',
          'Please add funds to your wallet',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/interest/hire/$requestId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Hire response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          // Update status in the list
          final index = allCandidates.indexWhere((c) => c.id == requestId);
          if (index != -1) {
            final updated = EmployerInterestModel(
              id: allCandidates[index].id,
              employeeId: allCandidates[index].employeeId,
              employeeName: allCandidates[index].employeeName,
              employeePhoto: allCandidates[index].employeePhoto,
              employeeTitle: allCandidates[index].employeeTitle,
              jobTitle: allCandidates[index].jobTitle,
              salaryAmount: allCandidates[index].salaryAmount,
              salaryPeriod: allCandidates[index].salaryPeriod,
              message: allCandidates[index].message,
              status: 'hired',
              createdAt: allCandidates[index].createdAt,
              respondedAt: DateTime.now(),
              commissionAmount: allCandidates[index].commissionAmount,
            );
            allCandidates[index] = updated;
            allCandidates.refresh();
          }
          
          walletBalance.value = jsonResponse['newBalance']?.toDouble() ?? 
                               walletBalance.value - commissionAmount;
          
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error hiring candidate: $e');
      return false;
    } finally {
      isHiring.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      fetchAllCandidates(),
      fetchWalletBalance(),
    ]);
  }
}
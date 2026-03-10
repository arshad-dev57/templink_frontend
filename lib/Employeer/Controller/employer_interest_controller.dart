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
  final interestedCandidates = <EmployerInterestModel>[].obs;
  final isLoading = false.obs;
  final isHiring = false.obs;
  final errorMessage = RxnString();
  final interestedCount = 0.obs;
  final walletBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInterestedCandidates();
    fetchWalletBalance();
  }

  Future<void> fetchInterestedCandidates() async {
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

      print('📡 Interested candidates response: ${response.statusCode}');
print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final List<dynamic> candidatesData = jsonResponse['data'] ?? [];
          
          interestedCandidates.value = candidatesData
              .map((e) => EmployerInterestModel.fromJson(e))
              .where((c) => c.status == 'interested')
              .toList();

          interestedCount.value = jsonResponse['counts']?['interested'] ?? 
                                  interestedCandidates.length;

          print('✅ Loaded ${interestedCandidates.length} interested candidates');
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Failed to load candidates';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      print('❌ Error fetching interested candidates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============== FETCH WALLET BALANCE ==============
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

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          // Remove from list
          interestedCandidates.removeWhere((c) => c.id == requestId);
          interestedCount.value = interestedCandidates.length;
          
          // Update wallet balance
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
      fetchInterestedCandidates(),
      fetchWalletBalance(),
    ]);
  }
}
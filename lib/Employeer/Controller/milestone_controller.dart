import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';

class MilestoneController extends GetxController {
  var isProcessing = false.obs;
  var paymentStatus = ''.obs;
  var errorMessage = ''.obs;

  final String baseUrl = ApiConfig.baseUrl; 

  // ==================== UPDATE MILESTONE STATUS ====================
  Future<bool> updateMilestoneStatus({
    required String projectId,
    required String milestoneId,
    required String status,
  }) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.put(
        Uri.parse('$baseUrl/api/milestones/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'milestoneId': milestoneId,
          'status': status,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Connection timeout. Please try again.',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("status updated of milestone");
        Get.snackbar(
          '✅ Success',
          responseData['message'] ?? 'Milestone status updated to $status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Failed to update milestone';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ==================== PROCESS PAYMENT ====================
  Future<bool> processPayment({
    required String projectId,
    required String milestoneId,
    required String paymentMethod,
  }) async {
    try {
      isProcessing.value = true;
      paymentStatus.value = 'PROCESSING';
      errorMessage.value = '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/milestones/process-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'milestoneId': milestoneId,
          'paymentMethod': paymentMethod,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Payment timeout. Please try again.',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        paymentStatus.value = 'SUCCESS';
        
        Get.snackbar(
          '✅ Payment Successful',
          responseData['message'] ?? 'Milestone payment completed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        paymentStatus.value = 'FAILED';
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Payment failed';
      }
    } catch (e) {
      paymentStatus.value = 'FAILED';
      errorMessage.value = e.toString();
      Get.snackbar(
        '❌ Payment Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ==================== FUND NEXT MILESTONE ====================
  Future<bool> fundNextMilestone(String projectId) async {
    try {
      isProcessing.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/milestones/fund-next'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Connection timeout',
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error funding next milestone: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ==================== GET PAYMENT METHODS ====================
  List<Map<String, dynamic>> getPaymentMethods() {
    return [
      {
        'id': 'wallet',
        'title': 'Templink Wallet',
        'subtitle': 'Balance: \$2,500',
        'icon': Icons.account_balance_wallet,
        'color': Colors.purple,
      },
      {
        'id': 'card',
        'title': 'Credit / Debit Card',
        'subtitle': 'Visa •••• 4242',
        'icon': Icons.credit_card,
        'color': Colors.blue,
      },
      {
        'id': 'bank',
        'title': 'Bank Transfer',
        'subtitle': '1-2 business days',
        'icon': Icons.account_balance,
        'color': Colors.green,
      },
    ];
  }
}
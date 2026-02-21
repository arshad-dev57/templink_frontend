// lib/Employeer/controllers/employer_invoice_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/Invoice_model.dart';
import 'package:templink/config/api_config.dart';
import 'dart:convert';

class EmployerInvoiceController extends GetxController {
  var isLoading = true.obs;
  var invoice = Rx<Invoice?>(null);
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    // ✅ Get projectId from arguments or directly
    if (Get.arguments != null) {
      // If using Get.arguments
      fetchInvoiceByProjectId(Get.arguments['projectId']);
    }
  }

  // ✅ New method to fetch invoice with direct projectId
  Future<void> fetchInvoiceByProjectId(String projectId) async {
    try {
      isLoading.value = true;
      print('📡 Fetching invoice for project: $projectId');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('❌ No token found');
        Get.offAllNamed('/login');
        return;
      }

      final url = '$baseUrl/api/invoices/project/$projectId';
      print('🌐 Calling URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          invoice.value = Invoice.fromJson(jsonResponse['invoice']);
          print('✅ Invoice loaded: ${invoice.value?.invoiceNumber}');
        } else {
          print('❌ API returned success false');
          invoice.value = null;
        }
      } else if (response.statusCode == 404) {
        print('❌ Invoice not found (404)');
        invoice.value = null;
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        invoice.value = null;
      }
    } catch (e) {
      print('❌ Error fetching invoice: $e');
      invoice.value = null;
    } finally {
      isLoading.value = false;
      print('🏁 fetchInvoice completed, isLoading: ${isLoading.value}');
    }
  }

  Future<void> downloadInvoice(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/invoices/project/$projectId/download'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Invoice downloaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download invoice',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
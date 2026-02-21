import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:flutter/material.dart';

class EmployeeContractController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var isProcessing = false.obs;
  var contract = Rx<Map<String, dynamic>>({});
  var contracts = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var signatureBase64 = ''.obs;
  
  // Signature pad state
  var hasSignature = false.obs;

  final String baseUrl = ApiConfig.baseUrl;

  // ==================== GET CONTRACT BY PROJECT ====================
  Future<void> getContractByProject(String projectId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/contracts/project/$projectId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        contract.value = responseData['contract'];
        
        // Check if already signed
        if (contract.value['signatures']['employee']['signed'] == true) {
          hasSignature.value = true;
          signatureBase64.value = contract.value['signatures']['employee']['signature'] ?? '';
        }
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Failed to load contract';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GET SINGLE CONTRACT ====================
  Future<void> getContract(String contractId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/contracts/$contractId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        contract.value = responseData['contract'];
        
        // Check if already signed
        if (contract.value['signatures']['employee']['signed'] == true) {
          hasSignature.value = true;
          signatureBase64.value = contract.value['signatures']['employee']['signature'] ?? '';
        }
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Failed to load contract';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GET MY CONTRACTS ====================
  Future<void> getMyContracts() async {
    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/contracts/my-contracts?role=employee'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        contracts.value = List.from(responseData['contracts']);
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          error['message'] ?? 'Failed to load contracts',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== EMPLOYEE SIGN CONTRACT ====================
  Future<bool> employeeSignContract({
    required String contractId,
    required String signature,
  }) async {
    try {
      isProcessing.value = true;
      errorMessage.value = '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/contracts/$contractId/employee-sign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'signature': signature,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        contract.value = responseData['contract'];
        hasSignature.value = true;
        signatureBase64.value = signature;
        
        Get.snackbar(
          '✅ Success',
          responseData['message'] ?? 'Contract signed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        final error = jsonDecode(response.body);
        errorMessage.value = error['message'] ?? 'Failed to sign contract';
        Get.snackbar(
          '❌ Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
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

  // ==================== DOWNLOAD CONTRACT PDF ====================
  Future<void> downloadContractPDF(String contractId) async {
    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/contracts/$contractId/download'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          '✅ Success',
          'Contract PDF downloaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          '❌ Error',
          error['message'] ?? 'Failed to download PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SIGNATURE GETTERS (NEW) ====================
  String? getEmployerSignature() {
    if (contract.value.isEmpty) return null;
    try {
      return contract.value['signatures']['employer']['signature']?.toString();
    } catch (e) {
      return null;
    }
  }

  String? getEmployeeSignature() {
    if (contract.value.isEmpty) return null;
    try {
      return contract.value['signatures']['employee']['signature']?.toString();
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? getEmployerSignatureDetails() {
    if (contract.value.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(
        contract.value['signatures']['employer'] ?? {}
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? getEmployeeSignatureDetails() {
    if (contract.value.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(
        contract.value['signatures']['employee'] ?? {}
      );
    } catch (e) {
      return null;
    }
  }

  String getEmployerSignedAt() {
    if (!isEmployerSigned) return 'Not signed';
    try {
      return contract.value['signatures']['employer']['signedAt']?.toString() ?? 'Not signed';
    } catch (e) {
      return 'Not signed';
    }
  }

  String getEmployeeSignedAt() {
    if (!isEmployeeSigned) return 'Not signed';
    try {
      return contract.value['signatures']['employee']['signedAt']?.toString() ?? 'Not signed';
    } catch (e) {
      return 'Not signed';
    }
  }

  // ==================== HELPER METHODS ====================
  String getStatusText(String status) {
    switch (status) {
      case 'DRAFT':
        return 'Draft - Ready to Sign';
      case 'PENDING_EMPLOYER_SIGN':
        return 'Awaiting Employer Signature';
      case 'PENDING_EMPLOYEE_SIGN':
        return 'Awaiting Your Signature';
      case 'ACTIVE':
        return 'Active';
      case 'COMPLETED':
        return 'Completed';
      case 'TERMINATED':
        return 'Terminated';
      case 'DISPUTED':
        return 'Disputed';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.orange;
      case 'PENDING_EMPLOYER_SIGN':
        return Colors.blue;
      case 'PENDING_EMPLOYEE_SIGN':
        return Colors.purple;
      case 'ACTIVE':
        return Colors.green;
      case 'COMPLETED':
        return Colors.teal;
      case 'TERMINATED':
        return Colors.red;
      case 'DISPUTED':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'Not signed';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  bool get isEmployerSigned {
    return contract.value.isNotEmpty && 
           contract.value['signatures']['employer']['signed'] == true;
  }

  bool get isEmployeeSigned {
    return contract.value.isNotEmpty && 
           contract.value['signatures']['employee']['signed'] == true;
  }

  bool get isContractActive {
    return contract.value.isNotEmpty && contract.value['status'] == 'ACTIVE';
  }

  double get totalAmount {
    if (contract.value.isEmpty) return 0;
    return contract.value['financialSummary']['totalAmount']?.toDouble() ?? 0;
  }

  int get milestoneCount {
    if (contract.value.isEmpty) return 0;
    return contract.value['milestones']?.length ?? 0;
  }
}
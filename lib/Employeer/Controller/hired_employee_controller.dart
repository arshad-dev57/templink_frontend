// controllers/hired_employee_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/hired_employee_model.dart';
import 'package:templink/config/api_config.dart';

class HiredEmployeeController extends GetxController {
  static HiredEmployeeController get to => Get.find();

  // Observable variables
  final isLoading = false.obs;
  final isLoadMore = false.obs;
  final hiredEmployees = <HiredEmployee>[].obs; // Model use kiya
  final summary = Rxn<Summary>(); // Model use kiya
  final pagination = Rxn<Pagination>(); // Model use kiya
  
  // Filter and pagination
  final selectedStatus = 'all'.obs;
  final currentPage = 1.obs;
  final limit = 5.obs;

  final String baseUrl = ApiConfig.baseUrl; // Apna URL yahan daalein

  @override
  void onInit() {
    super.onInit();
    fetchHiredEmployees();
  }

  // Fetch hired employees
  Future<void> fetchHiredEmployees({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
      }

      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadMore.value = true;
      }

      // Token yahan se lein (apne auth system ke according)
final SharedPreferences prefs = await SharedPreferences.getInstance();
var token = prefs.getString("auth_token");
      // API call
      var url = Uri.parse('$baseUrl/api/jobapplication/employer/hired').replace(
        queryParameters: {
          'page': currentPage.value.toString(),
          'limit': limit.value.toString(),
          if (selectedStatus.value != 'all') 'status': selectedStatus.value,
        },
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Model mein convert karo
        final responseModel = HiredEmployeeResponse.fromJson(jsonData);
        
        summary.value = responseModel.summary;
        pagination.value = responseModel.pagination;

        if (refresh || currentPage.value == 1) {
          hiredEmployees.value = responseModel.data;
        } else {
          hiredEmployees.addAll(responseModel.data);
        }
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load hired employees: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }


  // Load next page
  void loadNextPage() {
    if (pagination.value?.hasNextPage == true && !isLoadMore.value) {
      currentPage.value++;
      fetchHiredEmployees();
    }
  }

  // Refresh list
  Future<void> refreshList() async {
    currentPage.value = 1;
    await fetchHiredEmployees(refresh: true);
  }

  // Change status filter
  void changeStatus(String status) {
    selectedStatus.value = status;
    refreshList();
  }

  // Get color for status badge
  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'left':
        return Colors.orange;
      case 'terminated':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get status text
  String getStatusText(String status) {
    switch (status) {
      case 'active':
        return '🟢 Active';
      case 'left':
        return '🟡 Left';
      case 'terminated':
        return '🔴 Terminated';
      default:
        return status;
    }
  }

  // Helper: Format date
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
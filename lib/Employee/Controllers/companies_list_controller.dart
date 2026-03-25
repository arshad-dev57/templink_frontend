// lib/Employee/Controllers/employee_hired_companies_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class EmployeeHiredCompaniesController extends GetxController {
  static EmployeeHiredCompaniesController get to => Get.find();

  // Observables
  var isLoading = false.obs;
  var companies = <Map<String, dynamic>>[].obs;
  var activeCompanies = <Map<String, dynamic>>[].obs;
  var pastCompanies = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    fetchHiredCompanies();
  }

  // ==================== FETCH HIRED COMPANIES ====================
  Future<void> fetchHiredCompanies() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print("\n🟡 ===== FETCH HIRED COMPANIES STARTED =====");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      
      if (token == null) {
        errorMessage.value = 'No auth token found';
        print("❌ No auth token found");
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/employee-dashboard/companies'), // ✅ Sirf companies wali API
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
          // ✅ Sirf companies array fetch kar rahe hain
          companies.value = List<Map<String, dynamic>>.from(jsonResponse['companies'] ?? []);
          
          // ✅ Active companies filter (jahan current job hai)
          activeCompanies.value = companies.where((c) => c['currentJob'] != null).toList();
          
          // ✅ Past companies filter (jahan current job nahi hai)
          pastCompanies.value = companies.where((c) => c['currentJob'] == null).toList();
          
          print("✅ Fetched ${companies.length} companies");
          print("📊 Active: ${activeCompanies.length}, Past: ${pastCompanies.length}");
        } else {
          errorMessage.value = jsonResponse['message'] ?? 'Failed to load companies';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print("❌ Exception: $e");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      print("🟢 ===== FETCH HIRED COMPANIES ENDED =====");
    }
  }

  // ==================== REFRESH COMPANIES ====================
  Future<void> refreshCompanies() async {
    await fetchHiredCompanies();
  }

  // ==================== GET COMPANY BY ID ====================
  Map<String, dynamic>? getCompanyById(String companyId) {
    try {
      return companies.firstWhere((c) => c['companyId'] == companyId);
    } catch (e) {
      return null;
    }
  }

  // ==================== SEARCH COMPANIES ====================
  List<Map<String, dynamic>> searchCompanies(String query) {
    if (query.isEmpty) return companies;
    
    final searchTerm = query.toLowerCase();
    return companies.where((company) {
      final name = company['companyName']?.toString().toLowerCase() ?? '';
      final industry = company['industry']?.toString().toLowerCase() ?? '';
      final location = '${company['location']?['city']} ${company['location']?['country']}'.toLowerCase();
      
      return name.contains(searchTerm) || 
             industry.contains(searchTerm) || 
             location.contains(searchTerm);
    }).toList();
  }

  // ==================== FILTER BY INDUSTRY ====================
  List<Map<String, dynamic>> filterByIndustry(String industry) {
    if (industry == 'All') return companies;
    
    return companies.where((company) => 
      company['industry'] == industry
    ).toList();
  }

  // ==================== GET UNIQUE INDUSTRIES ====================
  List<String> get uniqueIndustries {
    final industries = companies.map((c) => c['industry']?.toString() ?? '').toSet();
    return ['All', ...industries.where((i) => i.isNotEmpty)];
  }

  // ==================== FORMAT COMPANY DATA FOR UI ====================
  String getCompanyInitials(String companyName) {
    if (companyName.isEmpty) return 'C';
    final words = companyName.split(' ');
    if (words.length > 1) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return companyName[0].toUpperCase();
  }

  String getFullLocation(Map<String, dynamic>? location) {
    if (location == null) return 'Location not specified';
    final city = location['city'] ?? '';
    final country = location['country'] ?? '';
    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    } else if (city.isNotEmpty) {
      return city;
    } else if (country.isNotEmpty) {
      return country;
    }
    return 'Location not specified';
  }

  String formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '$difference days ago';
      if (difference < 30) return '${(difference / 7).round()} weeks ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
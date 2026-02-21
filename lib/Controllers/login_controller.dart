import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Services/auth_api_service.dart';
import 'package:templink/Services/notification_api_service.dart';

import '../Services/Notificaton_Service.dart';
import '../Employeer/Screens/Employeer_homescreen.dart';
import '../Employee/Screens/Employee_homescreen.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;

  // Observable for user data (optional)
  var userData = Rx<Map<String, dynamic>>({});

  Future<void> loginuser({
    required String email,
    required String pass,
  }) async {
    if (pass.isEmpty) {
      Get.snackbar("Error", "Please enter your password");
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final data = await AuthApi.login(email: email, password: pass);

      final token = (data["token"] ?? "").toString().trim();
      final user =
          (data["user"] is Map) ? Map<String, dynamic>.from(data["user"]) : {};
      final role = (user["role"] ?? data["role"] ?? "").toString().trim().toLowerCase();
      final userId = user["_id"]?.toString() ?? user["id"]?.toString() ?? "";
      
      // ✅ Extract firstName, lastName, and imageUrl
      final firstName = user["firstName"]?.toString() ?? "";
      final lastName = user["lastName"]?.toString() ?? "";
      final imageUrl = user["imageUrl"]?.toString() ?? "";
      
      // For employer, if imageUrl is empty, try logoUrl
      String finalImageUrl = imageUrl;
      if (finalImageUrl.isEmpty && role == "employer") {
        finalImageUrl = user["employerProfile"]?["logoUrl"]?.toString() ?? "";
      }
      // For employee, if imageUrl is empty, try photoUrl
      if (finalImageUrl.isEmpty && role == "employee") {
        finalImageUrl = user["employeeProfile"]?["photoUrl"]?.toString() ?? "";
      }

      print("✅ User Data:");
      print("  - First Name: $firstName");
      print("  - Last Name: $lastName");
      print("  - Image URL: $finalImageUrl");
      print("  - Role: $role");

      /// ✅ SAVE TOKEN & ROLE (DIRECT SHARED PREFS)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_role', role);
      await prefs.setString('auth_user_id', userId);
      
      // ✅ Save firstName, lastName, and imageUrl
      await prefs.setString('auth_first_name', firstName);
      await prefs.setString('auth_last_name', lastName);
      await prefs.setString('auth_image_url', finalImageUrl);

      // optional: user bhi store karna ho
      if (user.isNotEmpty) {
        await prefs.setString('auth_user', jsonEncode(user));
      }

      print("✅ Saved token: $token");
      print("✅ Saved role: $role");
      print("✅ Saved first name: $firstName");
      print("✅ Saved last name: $lastName");
      print("✅ Saved image URL: $finalImageUrl");

      /// 🔔 NOTIFICATION LOGIN (commented as per your code)
      // await NotificationService.instance.login(userId);
      // await NotificationService.instance.debugPrintState(from: "after_login");
      // await Future.delayed(const Duration(milliseconds: 700));
      // await NotificationApi.sendLoginSuccessPush(userId: userId);

     
      if (role == "employee") {
        Get.offAll(() => const EmployeeHomeScreen());
      } else if (role == "employer") {
        Get.offAll(() => const EmployeerHomeScreen());
      } else {
        Get.snackbar("Error", "Invalid user role");
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString().replaceAll("Exception:", "").trim(),
      );
      print("Login failed $e");
    } finally {
      isLoading.value = false; 
    }
  }

  // ==================== HELPER METHODS TO GET STORED DATA ====================
  
  static Future<String> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_first_name') ?? '';
  }

  static Future<String> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_last_name') ?? '';
  }

  static Future<String> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('auth_first_name') ?? '';
    final lastName = prefs.getString('auth_last_name') ?? '';
    return '$firstName $lastName'.trim();
  }

  static Future<String> getImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_image_url') ?? '';
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_role') ?? '';
  }

  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_user_id') ?? '';
  }

  // ==================== LOGOUT METHOD ====================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_role');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_first_name');
    await prefs.remove('auth_last_name');
    await prefs.remove('auth_image_url');
    await prefs.remove('auth_user');
  }
}
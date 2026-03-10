
import 'dart:convert';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Services/auth_api_service.dart';
import 'package:templink/Services/notification_api_service.dart';
import '../Services/Notificaton_Service.dart';
import '../Employeer/Screens/Employeer_homescreen.dart';
import '../Employee/Screens/Employee_homescreen.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
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

      print("🟡 Attempting login for email: $email");
      final data = await AuthApi.login(email: email, password: pass);
      print("🟢 Login API response received");

      final token = (data["token"] ?? "").toString().trim();
      final user =
          (data["user"] is Map) ? Map<String, dynamic>.from(data["user"]) : {};
      final role = (user["role"] ?? data["role"] ?? "").toString().trim().toLowerCase();
      final userId = user["_id"]?.toString() ?? user["id"]?.toString() ?? "";

      final firstName = user["firstName"]?.toString() ?? "";
      final lastName = user["lastName"]?.toString() ?? "";
      final imageUrl = user["imageUrl"]?.toString() ?? "";

      String finalImageUrl = imageUrl;
      if (finalImageUrl.isEmpty && role == "employer") {
        finalImageUrl = user["employerProfile"]?["logoUrl"]?.toString() ?? "";
      }
      if (finalImageUrl.isEmpty && role == "employee") {
        finalImageUrl = user["employeeProfile"]?["photoUrl"]?.toString() ?? "";
      }

      print("✅ User Data:");
      print("  - User ID: $userId");
      print("  - First Name: $firstName");
      print("  - Last Name: $lastName");
      print("  - Image URL: $finalImageUrl");
      print("  - Role: $role");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_role', role);
      await prefs.setString('auth_user_id', userId);
      await prefs.setString('auth_first_name', firstName);
      await prefs.setString('auth_last_name', lastName);
      await prefs.setString('auth_image_url', finalImageUrl);

      if (user.isNotEmpty) {
        await prefs.setString('auth_user', jsonEncode(user));
      }

      print("✅ Saved to SharedPreferences");

      // ✅ OneSignal login
      print("🟡 Initializing OneSignal for user: $userId");
      await NotificationService.instance.login(userId);

      // ✅ Stabilize hone do
      print("🟡 Waiting for OneSignal to stabilize (4 seconds)...");
      await Future.delayed(const Duration(seconds: 4));

      await NotificationService.instance.verifyDeviceRegistration();
      await NotificationService.instance.debugPrintState(from: "after_login");

      // ✅ Subscription ID lo — raw userId pass karo (without dev:)
      final subId = OneSignal.User.pushSubscription.id;
      print("🔔 Using subscription ID: $subId");

      final Map<String, dynamic> result = await NotificationApi.sendLoginSuccessPush(
        userId: userId,           // raw mongo ID — backend dev: lagayega
        subscriptionId: subId,   // ye foran kaam karta hai
      );

      if (result.containsKey('status')) {
        final String status = result['status'].toString();

        if (status == 'subscription_pending') {
          print("🟡 Subscription still activating, retrying in 10 seconds");
          Future.delayed(const Duration(seconds: 12), () async {
            print("🟡 Sending delayed follow-up notification");
            await NotificationApi.sendLoginSuccessPush(
              userId: userId,
              subscriptionId: subId,
              title: "Welcome to Templink",
              message: "You're all set up to receive notifications",
            );
          });
        } else if (status == 'sent') {
          print("✅ Notification sent successfully");
        } else {
          print("⚠️ Notification status: $status");
        }
      }

      // Navigate based on role
      if (role == "employee") {
        Get.offAll(() => const EmployeeHomeScreen());
      } else if (role == "employer") {
        Get.offAll(() => const EmployeerHomeScreen());
      } else {
        Get.snackbar("Error", "Invalid user role");
      }

    } catch (e) {
      print("❌ Login failed: $e");
      Get.snackbar(
        "Login Failed",
        e.toString().replaceAll("Exception:", "").trim(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== HELPER METHODS ====================

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

  // ==================== LOGOUT ====================

  static Future<void> logout() async {
    await NotificationService.instance.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_role');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_first_name');
    await prefs.remove('auth_last_name');
    await prefs.remove('auth_image_url');
    await prefs.remove('auth_user');

    print("✅ User logged out successfully");
  }
}
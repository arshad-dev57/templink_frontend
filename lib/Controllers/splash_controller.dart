import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Screens/Employee_HomeScreen.dart';
import 'package:templink/Employeer/Screens/Employeer_homescreen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Global_Screens/usertype_screen.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {

  late AnimationController animationController;
  late Animation<Alignment> alignmentAnimation;
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('auth_token') ?? '';
      final role = prefs.getString('auth_role') ?? '';

      debugPrint('🔍 Token: $token');
      debugPrint('🔍 Role: $role');

      if (token.isNotEmpty && role.isNotEmpty) {
        if (role.toLowerCase() == 'employee') {
          Get.offAll(() => const EmployeeHomeScreen());
        } else if (role.toLowerCase() == 'employer') {
          Get.offAll(() => const EmployeerHomeScreen());
        } else {
          Get.offAll(() => const RegisterChoiceScreen());
        }
      } else {
        Get.offAll(() => const RegisterChoiceScreen());
      }
    } catch (e) {
      debugPrint('❌ Splash Error: $e');
      Get.offAll(() => const LoginScreen());
    }
  }

 
}
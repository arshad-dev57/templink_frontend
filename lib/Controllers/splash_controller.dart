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
  //   animationController = AnimationController(
  //     vsync: this, // ✅ Fixed (TickerProvider available)
  //     duration: const Duration(seconds: 2),
  //   );

  //   alignmentAnimation = Tween<Alignment>(
  //     begin: Alignment.center,
  //     end: Alignment.topCenter,
  //   ).animate(
  //     CurvedAnimation(
  //       parent: animationController,
  //       curve: Curves.easeInOut,
  //     ),
  //   );

  //   scaleAnimation = Tween<double>(
  //     begin: 1.0,
  //     end: 0.5,
  //   ).animate(
  //     CurvedAnimation(
  //       parent: animationController,
  //       curve: Curves.easeInOut,
  //     ),
  //   );

  //   animationController.forward();
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
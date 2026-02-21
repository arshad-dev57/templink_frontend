import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:templink/Global_Screens/login_screen.dart';
import 'dart:convert';

import 'package:templink/config/api_config.dart';

class ForgotPasswordController extends GetxController {
  // Step management
  final currentStep = 0.obs;
  final stepTitles = [
    "Forgot Password",
    "Verify Code",
    "Create New Password",
  ];

  // Controllers
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // UI States
  final isLoading = false.obs;
  final isResending = false.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;
  final otpError = ''.obs;

  // Timer for resend
  final resendTimer = 30.obs;
  Timer? _timer;

  // Reset token received after OTP verification
  var resetToken = ''.obs;

  // Base URL - change according to your backend
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    ever(currentStep, (step) {
      if (step == 1) {
        startResendTimer();
      } else {
        stopResendTimer();
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    stopResendTimer();
    super.onClose();
  }

  void goBack() {
    if (currentStep.value > 0) {
      currentStep.value--;
      if (currentStep.value == 0) {
        clearOtpData();
      }
    } else {
      Get.back();
    }
  }

  void clearOtpData() {
    otpController.clear();
    otpError.value = '';
    stopResendTimer();
    resendTimer.value = 30;
  }

  void startResendTimer() {
    stopResendTimer();
    resendTimer.value = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        stopResendTimer();
      }
    });
  }

  void stopResendTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // STEP 0: Send OTP API
  Future<void> sendCode() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentStep.value = 1;
        Get.snackbar(
          'Success',
          data['msg'] ?? 'Verification code sent to your email',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          data['msg'] ?? 'Failed to send OTP',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // STEP 1: Verify OTP API
  Future<void> verifyCode() async {
    final otp = otpController.text.trim();
    final email = emailController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      otpError.value = 'Please enter complete 6-digit code';
      return;
    }

    try {
      isLoading.value = true;
      otpError.value = '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        resetToken.value = data['resetToken'] ?? '';
        currentStep.value = 2;
        stopResendTimer();
        
        Get.snackbar(
          'Success',
          data['msg'] ?? 'OTP verified successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        otpError.value = data['msg'] ?? 'Invalid OTP';
      }
    } catch (e) {
      otpError.value = 'Network error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // STEP 1: Resend OTP API
  Future<void> resendCode() async {
    if (resendTimer.value > 0) return;

    final email = emailController.text.trim();

    try {
      isResending.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        startResendTimer();
        otpController.clear();
        otpError.value = '';
        
        Get.snackbar(
          'Success',
          data['msg'] ?? 'New verification code sent',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          data['msg'] ?? 'Failed to resend code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }

  // STEP 2: Reset Password API
  Future<void> resetPassword() async {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPass.length < 8) {
      Get.snackbar(
        'Error',
        'Password must be at least 8 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!_isPasswordStrong(newPass)) {
      Get.snackbar(
        'Error',
        'Password must contain at least 1 uppercase, 1 number, and 1 special character',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot-password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'resetToken': resetToken.value,
          'newPassword': newPass,
          'confirmPassword': confirmPass,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          data['msg'] ?? 'Password reset successfully! Please login with your new password.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(LoginScreen());
      } else {
        Get.snackbar(
          'Error',
          data['msg'] ?? 'Failed to reset password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _isPasswordStrong(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasUppercase && hasDigits && hasSpecial;
  }
}
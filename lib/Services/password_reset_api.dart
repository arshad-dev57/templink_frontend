import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class PasswordResetApi {
  static Future<Map<String, dynamic>> requestOtp(String email) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/api/auth/forgot-password/request");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email.trim()}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception((data["msg"] ?? "Request OTP failed").toString());
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/api/auth/forgot-password/verify");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "otp": otp.trim(),
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception((data["msg"] ?? "OTP verify failed").toString());
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/api/auth/forgot-password/reset");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "resetToken": resetToken.trim(),
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      }),
    );
print("Reset Password Response: ${res.body}");
    final data = jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception((data["msg"] ?? "Reset password failed").toString());
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/api/users/login");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.trim(),
        "password": password,
      }),
    );

    // ✅ Always print raw body + status (debug)
    print("LOGIN status: ${res.statusCode}");
    print("LOGIN body: ${res.body}");

    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {
      print("Login API: Response is not JSON.");
    }

    // ✅ SUCCESS
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final token = (data["token"] ?? "").toString();
      final role = (data["user"]?["role"] ?? data["role"] ?? "").toString();

      print("✅ LOGIN SUCCESS");
      print("Token: $token");
      print("Role: $role");

      return Map<String, dynamic>.from(data);
    }

    // ❌ ERROR
    final serverMsg = (data["message"] ?? data["msg"] ?? "Unknown error").toString();
    print("❌ Login API Error: $serverMsg (Status: ${res.statusCode})");

    throw Exception("$serverMsg (${res.statusCode})");
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NotificationApi {
  static Future<void> sendLoginSuccessPush({
    required String userId,
    String title = "Login Successful",
    String message = "Welcome back to Templink ✅",
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/api/notifications/send");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "title": title,
        "message": message,
        "data": {
          "type": "auth",
          "screen": "home",
        }
      }),
    );

    // backend ok false ho to throw
    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (res.statusCode >= 200 && res.statusCode < 300 && data["ok"] != false) {
      return;
    }

    final msg = data["msg"]?.toString() ?? "Push failed (${res.statusCode})";
    throw Exception(msg);
  }
}

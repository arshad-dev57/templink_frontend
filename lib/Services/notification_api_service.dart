import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class NotificationApi {
  static Future<Map<String, dynamic>> sendLoginSuccessPush({
    required String userId,
    String? subscriptionId,
    String title = "Login Successful",
    String message = "Welcome back to Templink ✅",
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/api/notifications/send");

    print("🔔 ---------------- PUSH DEBUG ----------------");
    print("🔔 Sending Login Push");
    print("🔔 URL: $uri");
    print("🔔 UserId: $userId");
    print("🔔 SubscriptionId: $subscriptionId");

    final body = {
      "userId": userId,
      "subscriptionId": subscriptionId,
      "title": title,
      "message": message,
      "data": {
        "type": "auth",
        "screen": "home",
      }
    };

    print("🔔 Request Body: ${jsonEncode(body)}");

    try {
      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      print("🔔 Response Status: ${res.statusCode}");
      print("🔔 Response Body: ${res.body}");

      Map<String, dynamic> responseData = {};
      try {
        if (res.body.isNotEmpty) {
          responseData = jsonDecode(res.body);
        }
      } catch (e) {
        print("❌ Response parsing error: $e");
        return {
          'success': false,
          'error': 'Failed to parse response',
          'status': 'error'
        };
      }

      if (responseData['result'] != null &&
          responseData['result']['errors'] != null &&
          responseData['result']['errors'].toString().contains("not subscribed")) {
        print("⚠️ User not subscribed yet");
        return {
          'success': true,
          'status': 'subscription_pending',
          'message': 'Notification queued, subscription activating'
        };
      } else if (res.statusCode >= 200 && res.statusCode < 300) {
        if (responseData['success'] == true || responseData['ok'] == true) {
          print("✅ Push notification sent successfully");
          return {'success': true, 'status': 'sent'};
        }
      }

      print("⚠️ Push notification response: $responseData");
      return {
        'success': false,
        'error': responseData,
        'status': 'failed'
      };

    } catch (e) {
      print("❌ Exception sending push: $e");
      return {
        'success': false,
        'error': e.toString(),
        'status': 'error'
      };
    } finally {
      print("🔔 --------------------------------------------");
    }
  }

  static Future<void> sendDelayedNotification({
    required String userId,
    String? subscriptionId,
    int delaySeconds = 10,
  }) async {
    await Future.delayed(Duration(seconds: delaySeconds));

    print("🟡 Sending delayed notification after $delaySeconds seconds");
    await sendLoginSuccessPush(
      userId: userId,
      subscriptionId: subscriptionId,
      title: "Welcome to Templink",
      message: "Your device is now ready to receive notifications",
    );
  }
}


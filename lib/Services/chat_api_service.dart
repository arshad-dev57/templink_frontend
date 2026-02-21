import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApi {
  static Map<String, String> _headers(String token) => {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

  static Future<String> getOrCreateConversation({
    required String baseUrl,
    required String token,
    required String otherUserId,
  }) async {
    final uri = Uri.parse("$baseUrl/api/chat/conversations/with/$otherUserId");
    final res = await http.post(uri, headers: _headers(token));
    if (res.statusCode >= 400) {
      throw Exception("getOrCreateConversation failed: ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data["conversationId"] ?? "").toString();
  }

  static Future<List<Map<String, dynamic>>> getMessages({
    required String baseUrl,
    required String token,
    required String conversationId,
    int page = 1,
    int limit = 30,
  }) async {
    final uri = Uri.parse(
        "$baseUrl/api/chat/conversations/$conversationId/messages?page=$page&limit=$limit");
    final res = await http.get(uri, headers: _headers(token));
    if (res.statusCode >= 400) {
      throw Exception("getMessages failed: ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["messages"] as List).cast<dynamic>();
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<List<Map<String, dynamic>>> getMyConversations({
    required String baseUrl,
    required String token,
  }) async {
    final uri = Uri.parse("$baseUrl/api/chat/conversations");
    final res = await http.get(uri, headers: _headers(token));
    if (res.statusCode >= 400) {
      throw Exception("getMyConversations failed: ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data["conversations"] as List).cast<dynamic>();
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatApi {
  static Future<String> getOrCreateConversation({
    required String baseUrl,
    required String token,
    required String otherUserId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/conversations/with/$otherUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['conversationId']?.toString() ?? '';
      }
      throw Exception('Failed to get/create conversation');
    } catch (e) {
      throw Exception('Chat API error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages({
    required String baseUrl,
    required String token,
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/conversations/$conversationId/messages?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }
}
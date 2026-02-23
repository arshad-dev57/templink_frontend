import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatListController extends GetxController {
  // ==================== OBSERVABLES ====================
  var conversations = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var lastRefresh = DateTime.now().obs;

  final String baseUrl;
  final String token;

  ChatListController({
    required this.baseUrl,
    required this.token,
  });

  // ==================== INIT ====================
  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  // ==================== LOAD CONVERSATIONS ====================
  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Connection timeout',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Format conversations with proper data
        final List<dynamic> rawConversations = data['conversations'] ?? [];
        
        conversations.value = rawConversations.map((c) {
          return {
            'conversationId': c['conversationId']?.toString() ?? '',
            'userId': c['userId']?.toString() ?? '',
            'name': c['name']?.toString() ?? 'Unknown User',
            'image': c['image']?.toString() ?? '',
            'lastMessage': c['lastMessage']?.toString() ?? 'No messages yet',
            'time': _formatTime(c['time']),
            'unread': (c['unread'] ?? 0) as int,
            'online': c['online'] ?? false,
          };
        }).toList();

        lastRefresh.value = DateTime.now();
      } else {
        errorMessage.value = 'Failed to load conversations';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== UPDATE CONVERSATION (from socket) ====================
  void updateConversation(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString();
    final otherUserId = data['otherUserId']?.toString();
    final lastMessage = data['lastMessage']?.toString();
    final unreadInc = (data['unreadInc'] ?? 0) as int;

    if (conversationId == null || otherUserId == null) return;

    final index = conversations.indexWhere(
      (c) => c['conversationId'] == conversationId
    );

    if (index != -1) {
      // Update existing conversation
      final updated = Map<String, dynamic>.from(conversations[index]);
      updated['lastMessage'] = lastMessage ?? updated['lastMessage'];
      updated['time'] = _formatTime(DateTime.now().toIso8601String());
      
      if (unreadInc > 0) {
        updated['unread'] = (updated['unread'] as int) + unreadInc;
      }

      conversations[index] = updated;
    } else {
      // New conversation - will be loaded on next refresh
      loadConversations();
    }
  }

  // ==================== RESET UNREAD COUNT ====================
  void resetUnread(String conversationId) {
    final index = conversations.indexWhere(
      (c) => c['conversationId'] == conversationId
    );

    if (index != -1) {
      conversations[index]['unread'] = 0;
      conversations.refresh();
    }
  }

  // ==================== UPDATE ONLINE STATUS ====================
  void updateUserOnlineStatus(String userId, bool online) {
    final index = conversations.indexWhere(
      (c) => c['userId'] == userId
    );

    if (index != -1) {
      conversations[index]['online'] = online;
      conversations.refresh();
    }
  }

  // ==================== MARK MESSAGE AS READ ====================
  Future<void> markAsRead(String conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/conversations/$conversationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        resetUnread(conversationId);
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // ==================== SEARCH CONVERSATIONS ====================
  List<Map<String, dynamic>> searchConversations(String query) {
    if (query.isEmpty) return conversations;
    
    return conversations.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      final lastMessage = (c['lastMessage'] ?? '').toString().toLowerCase();
      final searchLower = query.toLowerCase();
      
      return name.contains(searchLower) || lastMessage.contains(searchLower);
    }).toList();
  }

  // ==================== DELETE CONVERSATION ====================
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat/conversations/$conversationId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        conversations.removeWhere((c) => c['conversationId'] == conversationId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }

  // ==================== GET UNREAD COUNT ====================
  int get totalUnreadCount {
    return conversations.fold(0, (sum, c) => sum + (c['unread'] as int));
  }

  // ==================== HELPER METHODS ====================
  String _formatTime(dynamic timeData) {
    try {
      if (timeData == null) return '';
      
      final date = DateTime.parse(timeData.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      // Today: show time
      if (difference.inDays == 0) {
        return '${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
      }
      // Yesterday
      else if (difference.inDays == 1) {
        return 'Yesterday';
      }
      // This week
      else if (difference.inDays < 7) {
        return _getDayName(date.weekday);
      }
      // Older
      else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
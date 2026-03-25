import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatListController extends GetxController {
  var conversations = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var lastRefresh = DateTime.now().obs;

  final Map<String, List<Map<String, dynamic>>> _messagesCache = {};
  final Map<String, String> _conversationIdCache = {};

  final String baseUrl;
  final String token;

  ChatListController({required this.baseUrl, required this.token});

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

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
        final List<dynamic> rawConversations = data['conversations'] ?? [];

        conversations.value = rawConversations.map((c) {
          final convId = c['conversationId']?.toString() ?? '';
          final userId = c['userId']?.toString() ?? '';

          if (userId.isNotEmpty && convId.isNotEmpty) {
            _conversationIdCache[userId] = convId;
          }

          return {
            'conversationId': convId,
            'userId': userId,
            'name': c['name']?.toString() ?? 'Unknown User',
            'image': c['image']?.toString() ?? '',
            'lastMessage': c['lastMessage']?.toString() ?? 'No messages yet',
            'time': _formatTime(c['time']),
            'unread': (c['unread'] ?? 0) as int,
            'online': c['online'] ?? false,
          };
        }).toList();

        _prefetchAllMessages();
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

  Future<void> _prefetchAllMessages() async {
    for (var conv in conversations) {
      final convId = conv['conversationId']?.toString();
      if (convId != null && convId.isNotEmpty) {
        await _prefetchMessages(convId);
      }
    }
  }

  Future<void> _prefetchMessages(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/conversations/$conversationId/messages?limit=30'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawMessages = data['messages'] ?? [];

        // ✅ FIX: Saare fields preserve karo — especially file fields
        _messagesCache[conversationId] = rawMessages.map((m) {
          return _normalizeMessage(m);
        }).toList();

        print('✅ Prefetched ${_messagesCache[conversationId]?.length} messages for $conversationId');
      }
    } catch (e) {
      print('❌ Prefetch error for $conversationId: $e');
    }
  }

  // ✅ FIX: Ek helper jo saare fields properly map kare
  Map<String, dynamic> _normalizeMessage(dynamic m) {
    return {
      '_id':          m['_id']?.toString() ?? '',
      'conversationId': m['conversationId']?.toString() ?? '',
      'from':         m['from']?.toString() ?? '',
      'to':           m['to']?.toString() ?? '',
      'type':         m['type']?.toString() ?? 'text',
      'text':         m['text']?.toString() ?? '',
      // ✅ File fields — ye pehle missing the
      'mediaUrl':     m['mediaUrl']?.toString() ?? '',
      'originalName': m['originalName']?.toString() ?? '',
      'fileSize':     (m['fileSize'] is int)
                        ? m['fileSize'] as int
                        : int.tryParse(m['fileSize']?.toString() ?? '0') ?? 0,
      'status':       m['status']?.toString() ?? 'delivered',
      'clientId':     m['clientId']?.toString() ?? '',
      'createdAt':    m['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      'deliveredAt':  m['deliveredAt']?.toString(),
      'readAt':       m['readAt']?.toString(),
    };
  }

  List<Map<String, dynamic>> getCachedMessages(String conversationId) {
    return _messagesCache[conversationId] ?? [];
  }

  String? getCachedConversationId(String userId) {
    return _conversationIdCache[userId];
  }

  void updateLastMessage({
    required String conversationId,
    required String userId,
    required String lastMessage,
    String? time,
  }) {
    final index = conversations.indexWhere(
      (c) => c['conversationId'] == conversationId || c['userId'] == userId,
    );

    if (index != -1) {
      conversations[index]['lastMessage'] = lastMessage;
      conversations[index]['time'] = time ?? _formatTime(DateTime.now().toIso8601String());
      if (index > 0) {
        final conv = conversations.removeAt(index);
        conversations.insert(0, conv);
      }
    } else {
      conversations.insert(0, {
        'conversationId': conversationId,
        'userId': userId,
        'name': 'User',
        'image': '',
        'lastMessage': lastMessage,
        'time': time ?? _formatTime(DateTime.now().toIso8601String()),
        'unread': 1,
        'online': false,
      });
    }
    _conversationIdCache[userId] = conversationId;
  }

  void updateConversation(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString();
    final otherUserId    = data['otherUserId']?.toString();
    final lastMessage    = data['lastMessage']?.toString();
    final unreadInc      = (data['unreadInc'] ?? 0) as int;

    if (conversationId == null || otherUserId == null) return;

    final index = conversations.indexWhere(
      (c) => c['conversationId'] == conversationId,
    );

    if (index != -1) {
      final updated = Map<String, dynamic>.from(conversations[index]);
      updated['lastMessage'] = lastMessage ?? updated['lastMessage'];
      updated['time'] = _formatTime(DateTime.now().toIso8601String());
      if (unreadInc > 0) {
        updated['unread'] = (updated['unread'] as int) + unreadInc;
      }
      // ✅ Move to top
      conversations.removeAt(index);
      conversations.insert(0, updated);
    } else {
      loadConversations();
    }
  }

  // ✅ Cache mein nayi message add karo (socket se aane par)
  void addMessageToCache(String conversationId, Map<String, dynamic> message) {
    if (!_messagesCache.containsKey(conversationId)) {
      _messagesCache[conversationId] = [];
    }
    final normalized = _normalizeMessage(message);
    final id = normalized['_id'];
    // Duplicate check
    final exists = _messagesCache[conversationId]!
        .any((m) => m['_id'] == id || (id == '' && m['clientId'] == normalized['clientId']));
    if (!exists) {
      _messagesCache[conversationId]!.add(normalized);
    }
  }

  void resetUnread(String conversationId) {
    final index = conversations.indexWhere(
      (c) => c['conversationId'] == conversationId,
    );
    if (index != -1) {
      conversations[index]['unread'] = 0;
      conversations.refresh();
    }
  }

  void updateUserOnlineStatus(String userId, bool online) {
    final index = conversations.indexWhere((c) => c['userId'] == userId);
    if (index != -1) {
      conversations[index]['online'] = online;
      conversations.refresh();
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/conversations/$conversationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) resetUnread(conversationId);
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  List<Map<String, dynamic>> searchConversations(String query) {
    if (query.isEmpty) return conversations;
    return conversations.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      final last = (c['lastMessage'] ?? '').toString().toLowerCase();
      final q    = query.toLowerCase();
      return name.contains(q) || last.contains(q);
    }).toList();
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat/conversations/$conversationId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        conversations.removeWhere((c) => c['conversationId'] == conversationId);
        _messagesCache.remove(conversationId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting conversation: $e');
      return false;
    }
  }

  int get totalUnreadCount =>
      conversations.fold(0, (sum, c) => sum + (c['unread'] as int));

  String _formatTime(dynamic timeData) {
    try {
      if (timeData == null) return '';
      final date = DateTime.parse(timeData.toString());
      final now  = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        return '${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return _getDayName(date.weekday);
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return '';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
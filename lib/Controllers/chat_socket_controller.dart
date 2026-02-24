import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:flutter/material.dart';

class ChatSocketController extends GetxController {
  // ==================== OBSERVABLES ====================
  var isConnected = false.obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isOtherTyping = false.obs;
  var activeConversationId = ''.obs;
  var errorMessage = ''.obs;

  // Socket instance - SINGLETON
  static IO.Socket? _socket;
  static bool _isInitialized = false;
  static String? _myUserId;
  static String? _token;
  static String? _baseUrl;
  
  // Message status tracking
  final Map<String, Map<String, dynamic>> _pendingMessages = {};

  // Callbacks
  Function(Map<String, dynamic>)? onNewMessage;
  Function(Map<String, dynamic>)? onMessageStatus;
  Function(Map<String, dynamic>)? onTyping;
  Function(Map<String, dynamic>)? onReadReceipt;
  Function(Map<String, dynamic>)? onConversationUpdated;
  Function(String, bool)? onUserPresence;

  // ==================== SINGLETON PATTERN ====================
  
  /// Get the singleton instance
  static ChatSocketController get instance {
    if (!Get.isRegistered<ChatSocketController>()) {
      throw Exception('ChatSocketController not initialized. Call initialize() first.');
    }
    return Get.find<ChatSocketController>();
  }

  /// Initialize the socket controller once at app startup
  static Future<void> initialize({
    required String baseUrl,
    required String token,
    required String myUserId,
  }) async {
    if (_isInitialized) {
      print('ℹ️ ChatSocketController already initialized');
      return;
    }
    
    print('🟡 Initializing ChatSocketController...');
    _isInitialized = true;
    _myUserId = myUserId;
    _token = token;
    _baseUrl = baseUrl;
    
    // Convert http to ws for socket connection
    String socketBaseUrl = baseUrl.replaceFirst('http', 'ws');
    
    // Create and register the controller permanently
    Get.put(
      ChatSocketController._internal(socketBaseUrl, token, myUserId),
      permanent: true,
    );
    
    print('✅ ChatSocketController initialized successfully');
  }

  // Private constructor
  ChatSocketController._internal(String socketBaseUrl, String token, String myUserId) {
    this.myUserId = myUserId;
    _initSocket(socketBaseUrl, token);
  }

  // Public constructor - prevent direct creation
  ChatSocketController._();

  // For backward compatibility (deprecated)
  ChatSocketController({
    required String socketBaseUrl,
    required String token,
    required String myUserId,
  }) {
    print('⚠️ Direct ChatSocketController creation is deprecated. Use ChatSocketController.initialize() instead.');
    this.myUserId = myUserId;
    _initSocket(socketBaseUrl, token);
  }

  late String myUserId;

  // ==================== INIT SOCKET ====================
  void _initSocket(String baseUrl, String token) {
    try {
      print('🟡 Initializing socket connection to: $baseUrl');
      
      // Use existing socket if available
      if (_socket != null && _socket!.connected) {
        print('✅ Using existing socket connection');
        isConnected.value = true;
        return;
      }

      // Clean URL - remove trailing slash
      String cleanUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
      
     final socket = IO.io(
        cleanUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .build(),
      );

      _socket = socket;

      // Connection events
      socket.on('connect', (_) {
        isConnected.value = true;
        print('✅ Socket connected: ${socket.id}');
        errorMessage.value = '';
        
        // Rejoin active conversation if any
        if (activeConversationId.value.isNotEmpty) {
          _joinConversation(activeConversationId.value);
        }
      });

      socket.on('disconnect', (_) {
        isConnected.value = false;
        print('❌ Socket disconnected');
      });

      socket.on('connect_error', (error) {
        errorMessage.value = 'Connection error: $error';
        print('Socket error: $error');
      });

      socket.on('reconnect', (attempt) {
        print('✅ Socket reconnected after $attempt attempts');
        isConnected.value = true;
        errorMessage.value = '';
        
        // Rejoin active conversation
        if (activeConversationId.value.isNotEmpty) {
          _joinConversation(activeConversationId.value);
        }
      });

      socket.on('reconnect_attempt', (attempt) {
        print('🔄 Reconnection attempt #$attempt');
      });

      socket.on('reconnect_error', (error) {
        print('❌ Reconnection error: $error');
      });

      // socket.on('reconnect_failed', () {
      //   print('❌ Reconnection failed after all attempts');
      //   errorMessage.value = 'Connection lost. Please restart app.';
      // });

      socket.on('connected', (data) {
        print('✅ Server confirmed connection: $data');
      });

      // =============== MESSAGE EVENTS ===============
      socket.on('new_message', (data) {
        _handleNewMessage(data);
      });

      socket.on('message_status', (data) {
        _handleMessageStatus(data);
        onMessageStatus?.call(data);
      });

      socket.on('read_receipt', (data) {
        _handleReadReceipt(data);
        onReadReceipt?.call(data);
      });

      // =============== TYPING EVENTS ===============
      socket.on('typing', (data) {
        _handleTyping(data);
        onTyping?.call(data);
      });

      // =============== CONVERSATION UPDATES ===============
      socket.on('conversation_updated', (data) {
        onConversationUpdated?.call(data);
      });

      socket.on('unread_reset', (data) {
        _handleUnreadReset(data);
      });

      // =============== PRESENCE ===============
      socket.on('presence', (data) {
        final userId = data['userId']?.toString();
        final online = data['online'] == true;
        if (userId != null && userId != myUserId) {
          onUserPresence?.call(userId, online);
        }
      });

    } catch (e) {
      errorMessage.value = 'Socket init error: $e';
      print('❌ Socket init error: $e');
    }
  }

  // Get socket instance
  IO.Socket get socket {
    if (_socket == null) {
      throw Exception('Socket not initialized');
    }
    return _socket!;
  }

  // ==================== MESSAGE HANDLERS ====================
  void _handleNewMessage(Map<String, dynamic> message) {
    final fromUserId = message['from']?.toString();
    final conversationId = message['conversationId']?.toString();

    // Add to messages list if it's for active conversation
    if (conversationId == activeConversationId.value) {
      messages.add(message);
      
      // Mark as read if it's from someone else
      if (fromUserId != myUserId) {
        markRead(conversationId: conversationId!);
      }
    }

    // Update pending message status
    final clientId = message['clientId']?.toString();
    if (clientId != null && _pendingMessages.containsKey(clientId)) {
      _pendingMessages[clientId] = message;
      _updateMessageStatus(clientId, 'sent');
    }

    onNewMessage?.call(message);
  }

  void _handleMessageStatus(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString();
    final status = data['status']?.toString();
    final at = data['at'];

    if (conversationId == activeConversationId.value) {
      // Update last message status
      if (messages.isNotEmpty) {
        final lastMsg = messages.last;
        if (lastMsg['from'] == myUserId) {
          lastMsg['status'] = status;
          lastMsg['deliveredAt'] = at;
          messages.refresh();
        }
      }
    }
  }

  void _handleReadReceipt(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString();
    final readerId = data['readerId']?.toString();
    final readAt = data['readAt'];

    if (conversationId == activeConversationId.value && readerId != myUserId) {
      // Mark all my messages as read
      for (var msg in messages) {
        if (msg['from'] == myUserId && msg['status'] != 'read') {
          msg['status'] = 'read';
          msg['readAt'] = readAt;
        }
      }
      messages.refresh();
    }
  }

  void _handleTyping(Map<String, dynamic> data) {
    final fromUserId = data['fromUserId']?.toString();
    final isTyping = data['isTyping'] == true;

    if (fromUserId != myUserId) {
      isOtherTyping.value = isTyping;
    }
  }

  void _handleUnreadReset(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString();
    if (conversationId == activeConversationId.value) {
      // Reset unread count logic handled by list controller
    }
  }

  void _updateMessageStatus(String clientId, String status) {
    final index = messages.indexWhere((m) => m['clientId'] == clientId);
    if (index != -1) {
      messages[index]['status'] = status;
      messages.refresh();
    }
  }

  // Private join method
  void _joinConversation(String conversationId) {
    if (!isConnected.value) return;
    
    socket.emit('join_conversation', {
      'conversationId': conversationId,
    });
    
    print('📤 Joined conversation: $conversationId');
  }

  // ==================== PUBLIC METHODS ====================
  
  /// Join a conversation room
  void joinConversation({required String conversationId}) {
    _joinConversation(conversationId);
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    if (!isConnected.value) return;
    
    socket.emit('leave_conversation', {
      'conversationId': conversationId,
    });
  }

  /// Set active conversation (leaves previous, joins new)
  void setActiveConversation(String conversationId) {
    if (activeConversationId.value.isNotEmpty) {
      leaveConversation(activeConversationId.value);
    }
    activeConversationId.value = conversationId;
    joinConversation(conversationId: conversationId);
    
    // Clear messages when switching conversations
    messages.clear();
  }

  /// Send a message
  void sendMessage({
    required String conversationId,
    required String toUserId,
    required String text,
    String type = 'text',
    String mediaUrl = '',
  }) {
    if (!isConnected.value || text.trim().isEmpty) return;

    final clientId = '${DateTime.now().millisecondsSinceEpoch}_${myUserId}_$toUserId';

    // Create temporary message
    final tempMessage = {
      '_id': 'temp_$clientId',
      'conversationId': conversationId,
      'from': myUserId,
      'to': toUserId,
      'type': type,
      'text': text,
      'mediaUrl': mediaUrl,
      'status': 'sending',
      'clientId': clientId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Add to UI immediately
    messages.add(tempMessage);
    _pendingMessages[clientId] = tempMessage;

    socket.emit('send_message', {
      'conversationId': conversationId,
      'toUserId': toUserId,
      'text': text,
      'type': type,
      'mediaUrl': mediaUrl,
      'clientId': clientId,
    });

    // Optimistically update status after delay
    Future.delayed(const Duration(seconds: 1), () {
      if (_pendingMessages.containsKey(clientId)) {
        _updateMessageStatus(clientId, 'sent');
        _pendingMessages.remove(clientId);
      }
    });

    // Mark as failed after timeout
    Future.delayed(const Duration(seconds: 5), () {
      if (_pendingMessages.containsKey(clientId)) {
        _updateMessageStatus(clientId, 'failed');
        _pendingMessages.remove(clientId);
        errorMessage.value = 'Message failed to send';
      }
    });
  }

  /// Send typing indicator
  void onTextChanged({
    required String conversationId,
    required String toUserId,
    required String text,
  }) {
    if (!isConnected.value) return;
    
    socket.emit('typing', {
      'conversationId': conversationId,
      'toUserId': toUserId,
      'isTyping': text.isNotEmpty,
    });
  }

  /// Mark conversation as read
  void markRead({required String conversationId}) {
    if (!isConnected.value) return;

    socket.emit('mark_read', {
      'conversationId': conversationId,
    });
  }

  // ==================== CALL FUNCTIONS ====================
  void sendCallInvite(String toUserId, String callType) {
    if (!isConnected.value) return;
    socket.emit('call_invite', {'toUserId': toUserId, 'callType': callType});
  }

  void acceptCall(String toUserId, String callType) {
    if (!isConnected.value) return;
    socket.emit('call_accept', {'toUserId': toUserId, 'callType': callType});
  }

  void rejectCall(String toUserId) {
    if (!isConnected.value) return;
    socket.emit('call_reject', {'toUserId': toUserId});
  }

  void endCall(String toUserId) {
    if (!isConnected.value) return;
    socket.emit('call_end', {'toUserId': toUserId});
  }

  // ==================== WEBRTC ====================
  void sendWebRtcOffer(String toUserId, dynamic sdp) {
    if (!isConnected.value) return;
    socket.emit('webrtc_offer', {'toUserId': toUserId, 'sdp': sdp});
  }

  void sendWebRtcAnswer(String toUserId, dynamic sdp) {
    if (!isConnected.value) return;
    socket.emit('webrtc_answer', {'toUserId': toUserId, 'sdp': sdp});
  }

  void sendIceCandidate(String toUserId, dynamic candidate) {
    if (!isConnected.value) return;
    socket.emit('webrtc_ice_candidate', {'toUserId': toUserId, 'candidate': candidate});
  }

  // ==================== UTILITY ====================
  void replaceMessages(String conversationId, List<Map<String, dynamic>> newMessages) {
    if (activeConversationId.value == conversationId) {
      messages.value = newMessages;
    }
  }

  void disconnect() {
    if (activeConversationId.value.isNotEmpty) {
      leaveConversation(activeConversationId.value);
    }
    if (_socket != null) {
      _socket!.disconnect();
    }
    isConnected.value = false;
  }

  void reconnect() {
    if (_socket != null) {
      _socket!.connect();
    }
  }

  @override
  void onClose() {
    // Don't disconnect on close - keep singleton alive
    print('ℹ️ ChatSocketController onClose called - keeping socket alive');
    super.onClose();
  }
}
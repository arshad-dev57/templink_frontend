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

  // Socket instance
  late IO.Socket socket;
  late String myUserId;

  // Message status tracking
  final Map<String, Map<String, dynamic>> _pendingMessages = {};

  // Callbacks
  Function(Map<String, dynamic>)? onNewMessage;
  Function(Map<String, dynamic>)? onMessageStatus;
  Function(Map<String, dynamic>)? onTyping;
  Function(Map<String, dynamic>)? onReadReceipt;
  Function(Map<String, dynamic>)? onConversationUpdated;
  Function(String, bool)? onUserPresence;

  ChatSocketController({
    required String socketBaseUrl,
    required String token,
    required String myUserId,
  }) {
    this.myUserId = myUserId;
    _initSocket(socketBaseUrl, token);
  }

  // ==================== INIT SOCKET ====================
  void _initSocket(String baseUrl, String token) {
    try {
      socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      // Connection events
      socket.on('connect', (_) {
        isConnected.value = true;
        print('✅ Socket connected: ${socket.id}');
      });

      socket.on('disconnect', (_) {
        isConnected.value = false;
        print('❌ Socket disconnected');
      });

      socket.on('connect_error', (error) {
        errorMessage.value = 'Connection error: $error';
        print('Socket error: $error');
      });

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
    }
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

  // ==================== FIXED: SOCKET ACTIONS (NO CALLBACKS) ====================
  
  /// Join a conversation room
  void joinConversation({required String conversationId}) {
    if (!isConnected.value) return;
    
    // ✅ FIXED: Only 2 arguments - event name and data
    socket.emit('join_conversation', {
      'conversationId': conversationId,
    });
    
    print('📤 Emitted join_conversation: $conversationId');
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    if (!isConnected.value) return;
    
    // ✅ FIXED: Only 2 arguments
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

    // ✅ FIXED: Send without callback
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
    
    // ✅ FIXED: Only 2 arguments
    socket.emit('typing', {
      'conversationId': conversationId,
      'toUserId': toUserId,
      'isTyping': text.isNotEmpty,
    });
  }

  /// Mark conversation as read
  void markRead({required String conversationId}) {
    if (!isConnected.value) return;

    // ✅ FIXED: Only 2 arguments
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
    socket.disconnect();
    isConnected.value = false;
  }

  void reconnect() {
    socket.connect();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
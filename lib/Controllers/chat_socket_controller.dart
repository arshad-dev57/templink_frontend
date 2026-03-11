  // F:\templink_flutter\lib\controllers\chat_socket_controller.dart

  import 'package:get/get.dart';
  import 'package:socket_io_client/socket_io_client.dart' as IO;

  class ChatSocketController extends GetxController {
    // ==================== OBSERVABLES ====================
    var isConnected = false.obs;
    var messages = <Map<String, dynamic>>[].obs;
    var isOtherTyping = false.obs;
    var activeConversationId = ''.obs;
    var errorMessage = ''.obs;

    // ✅ Static socket - poori app mein ek hi socket rahega
    static IO.Socket? _socket;

    // Pending messages: clientId -> tempMessage
    final Map<String, Map<String, dynamic>> _pendingMessages = {};

    // Callbacks for ChatListScreen
    Function(Map<String, dynamic>)? onConversationUpdated;
    Function(String, bool)? onUserPresence;

    // ==================== CALL CALLBACKS ====================
    Function(Map<String, dynamic>)? onCallIncoming;
    Function(Map<String, dynamic>)? onCallAccepted;
    Function(Map<String, dynamic>)? onCallRejected;
    Function(Map<String, dynamic>)? onCallEnded;
    Function(Map<String, dynamic>)? onWebRtcOffer;
    Function(Map<String, dynamic>)? onWebRtcAnswer;
    Function(Map<String, dynamic>)? onWebRtcIceCandidate;

    late String myUserId;
    late String _baseUrl;
    late String _token;

    // ==================== CONSTRUCTOR ====================
    ChatSocketController({
      required String socketBaseUrl,
      required String token,
      required String myUserId,
    }) {
      this.myUserId = myUserId;
      _baseUrl = socketBaseUrl;
      _token = token;
      _initSocket(socketBaseUrl, token);
    }

    // ==================== SOCKET INIT ====================
    void _initSocket(String baseUrl, String token) {
      // ✅ Socket already connected hai to reuse karo
      if (_socket != null && _socket!.connected) {
        print('✅ Reusing existing socket connection');
        isConnected.value = true;
        _registerEvents(_socket!);
        return;
      }

      // ✅ Clean URL - remove trailing slashes
      String socketUrl = baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://')
          .replaceAll(RegExp(r'/+$'), '');

      print('🔌 Connecting socket to: $socketUrl');

      try {
        final socket = IO.io(
          socketUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setAuth({'token': token})
              .enableReconnection()
              .setReconnectionAttempts(999)
              .setReconnectionDelay(2000)
              .setReconnectionDelayMax(10000)
              .build(),
        );

        _socket = socket;
        _registerEvents(socket);
      } catch (e) {
        print('❌ Socket init error: $e');
        errorMessage.value = 'Socket initialization failed';
      }
    }

    // ==================== REGISTER EVENTS ====================
    void _registerEvents(IO.Socket socket) {
      // ✅ Pehle off karo - double registration prevent
      _offAllEvents(socket);

      socket.on('connect', (_) {
        isConnected.value = true;
        errorMessage.value = '';
        print('✅ Socket connected: ${socket.id}');
        if (activeConversationId.value.isNotEmpty) {
          _emitJoin(activeConversationId.value);
        }
      });

      socket.on('disconnect', (reason) {
        isConnected.value = false;
        print('❌ Socket disconnected: $reason');
      });

      socket.on('connect_error', (error) {
        errorMessage.value = 'Connection failed';
        print('❌ Socket connect_error: $error');
      });

      socket.on('new_message', (data) {
        _handleNewMessage(Map<String, dynamic>.from(data));
      });

      socket.on('message_status', (data) {
        _handleMessageStatus(Map<String, dynamic>.from(data));
      });

      socket.on('read_receipt', (data) {
        _handleReadReceipt(Map<String, dynamic>.from(data));
      });

      socket.on('typing', (data) {
        _handleTyping(Map<String, dynamic>.from(data));
      });

      socket.on('conversation_updated', (data) {
        if (onConversationUpdated != null) {
          onConversationUpdated!(Map<String, dynamic>.from(data));
        }
      });

      socket.on('presence', (data) {
        _handlePresence(Map<String, dynamic>.from(data));
      });

      // ==================== CALL EVENTS ====================
      socket.on('call_incoming', (data) {
        print('📲 call_incoming received: $data');
        onCallIncoming?.call(Map<String, dynamic>.from(data));
      });

      socket.on('call_accepted', (data) {
        print('✅ call_accepted received: $data');
        onCallAccepted?.call(Map<String, dynamic>.from(data));
      });

      socket.on('call_rejected', (data) {
        print('❌ call_rejected received: $data');
        onCallRejected?.call(Map<String, dynamic>.from(data));
      });

      socket.on('call_ended', (data) {
        print('📵 call_ended received: $data');
        onCallEnded?.call(Map<String, dynamic>.from(data));
      });

      socket.on('webrtc_offer', (data) {
        print('📨 webrtc_offer received');
        onWebRtcOffer?.call(Map<String, dynamic>.from(data));
      });

      socket.on('webrtc_answer', (data) {
        print('📨 webrtc_answer received');
        onWebRtcAnswer?.call(Map<String, dynamic>.from(data));
      });

      socket.on('webrtc_ice_candidate', (data) {
        print('🧊 webrtc_ice_candidate received');
        onWebRtcIceCandidate?.call(Map<String, dynamic>.from(data));
      });
    }

    void _offAllEvents(IO.Socket socket) {
      socket.off('connect');
      socket.off('disconnect');
      socket.off('connect_error');
      socket.off('new_message');
      socket.off('message_status');
      socket.off('read_receipt');
      socket.off('typing');
      socket.off('conversation_updated');
      socket.off('presence');
      // call events
      socket.off('call_incoming');
      socket.off('call_accepted');
      socket.off('call_rejected');
      socket.off('call_ended');
      socket.off('webrtc_offer');
      socket.off('webrtc_answer');
      socket.off('webrtc_ice_candidate');
    }


// Add this method to ChatSocketController class
    // ==================== MESSAGE HANDLERS ====================
    void _handleNewMessage(Map<String, dynamic> message) {
      final conversationId = message['conversationId']?.toString();
      final fromUserId = message['from']?.toString();
      final clientId = message['clientId']?.toString();

      // ✅ Temp message replace karo
      if (clientId != null && _pendingMessages.containsKey(clientId)) {
        final index = messages.indexWhere((m) => m['clientId'] == clientId);
        if (index != -1) {
          messages[index] = message;
          messages.refresh();
          print('✅ Temp replaced with server message: $clientId');
        }
        _pendingMessages.remove(clientId);
      }
      // ✅ Incoming message - active conversation mein add karo
      else if (conversationId == activeConversationId.value) {
        final msgId = message['_id']?.toString();
        final alreadyExists = msgId != null &&
            messages.any((m) => m['_id']?.toString() == msgId);

        if (!alreadyExists) {
          messages.add(message);
          print('📩 Incoming message added');
        }
      }

      // Active conversation mein dusre ka message - auto read
      if (conversationId == activeConversationId.value &&
          fromUserId != myUserId) {
        markRead(conversationId: conversationId!);
      }
    }

    void _handleMessageStatus(Map<String, dynamic> data) {
      final convId = data['conversationId']?.toString();
      if (convId != activeConversationId.value) return;

      final messageId = data['messageId']?.toString();
      final status = data['status']?.toString();

      if (messageId != null && status != null) {
        for (var msg in messages) {
          if (msg['_id']?.toString() == messageId) {
            msg['status'] = status;
            msg['deliveredAt'] = data['at'];
            break;
          }
        }
        messages.refresh();
      }
    }

    void _handleReadReceipt(Map<String, dynamic> data) {
      final convId = data['conversationId']?.toString();
      if (convId != activeConversationId.value) return;

      final readerId = data['readerId']?.toString();
      if (readerId == myUserId) return;

      bool changed = false;
      for (var msg in messages) {
        if (msg['from']?.toString() == myUserId && msg['status'] != 'read') {
          msg['status'] = 'read';
          msg['readAt'] = data['readAt'];
          changed = true;
        }
      }
      if (changed) messages.refresh();
    }

    void _handleTyping(Map<String, dynamic> data) {
      final fromUserId = data['fromUserId']?.toString();
      final isTyping = data['isTyping'] == true;

      if (fromUserId != null && fromUserId != myUserId) {
        isOtherTyping.value = isTyping;
        print('✏️ Other user typing: $isTyping');
      }
    }

    void _handlePresence(Map<String, dynamic> data) {
      final userId = data['userId']?.toString();
      final online = data['online'] == true;

      if (userId != null && userId != myUserId && onUserPresence != null) {
        onUserPresence!(userId, online);
      }
    }

    // ==================== PUBLIC METHODS ====================

    /// ✅ Active conversation set karo
    void setActiveConversation(String conversationId) {
      print('🔵 Setting active conversation: $conversationId');

      if (activeConversationId.value.isNotEmpty &&
          activeConversationId.value != conversationId) {
        _emitLeave(activeConversationId.value);
      }

      activeConversationId.value = conversationId;
      messages.clear();
      isOtherTyping.value = false;
      _emitJoin(conversationId);
    }

    /// ✅ Chat screen se bahar jaate waqt call karo
    void clearActiveConversation() {
      print('🧹 Clearing active conversation');

      if (activeConversationId.value.isNotEmpty) {
        _emitLeave(activeConversationId.value);
      }

      activeConversationId.value = '';
      messages.clear();
      isOtherTyping.value = false;
    }

    /// ✅ Typing indicator bhejo
    void sendTyping({
      required String conversationId,
      required String toUserId,
      required bool isTyping,
    }) {
      print('📝 sendTyping called: isTyping=$isTyping');

      if (!isConnected.value) {
        print('❌ Cannot send typing - not connected');
        return;
      }

      if (conversationId.isEmpty || toUserId.isEmpty) {
        print('❌ Invalid parameters for sendTyping');
        return;
      }

      try {
        _socket?.emit('typing', {
          'conversationId': conversationId,
          'toUserId': toUserId,
          'isTyping': isTyping,
        });
      } catch (e) {
        print('❌ Error sending typing: $e');
      }
    }

    /// ✅ Backward compatibility method
    void onTextChanged({
      required String conversationId,
      required String toUserId,
      required String text,
    }) {
      sendTyping(
        conversationId: conversationId,
        toUserId: toUserId,
        isTyping: text.isNotEmpty,
      );
    }

    /// ✅ Message bhejo
    void sendMessage({
      required String conversationId,
      required String toUserId,
      required String text,
      String type = 'text',
      String mediaUrl = '',
    }) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) return;

      if (!isConnected.value) {
        errorMessage.value = 'Not connected. Please wait...';
        return;
      }

      final clientId =
          '${DateTime.now().millisecondsSinceEpoch}_${myUserId.hashCode.abs()}';

      final tempMessage = {
        '_id': 'temp_$clientId',
        'conversationId': conversationId,
        'from': myUserId,
        'to': toUserId,
        'type': type,
        'text': trimmed,
        'mediaUrl': mediaUrl,
        'status': 'sending',
        'clientId': clientId,
        'createdAt': DateTime.now().toIso8601String(),
      };

      messages.add(tempMessage);
      _pendingMessages[clientId] = tempMessage;

      _socket?.emit('send_message', {
        'conversationId': conversationId,
        'toUserId': toUserId,
        'text': trimmed,
        'type': type,
        'mediaUrl': mediaUrl,
        'clientId': clientId,
      });

      print('📤 Message sent: $trimmed');

      // 8 seconds timeout - failed mark karo
      Future.delayed(const Duration(seconds: 8), () {
        if (_pendingMessages.containsKey(clientId)) {
          _updateMsgStatus(clientId, 'failed');
          _pendingMessages.remove(clientId);
          errorMessage.value = 'Message failed to send';
        }
      });
    }

    /// ✅ Conversation join karo
    void joinConversation({required String conversationId}) {
      _emitJoin(conversationId);
    }

    /// ✅ Conversation leave karo
    void leaveConversation(String conversationId) {
      _emitLeave(conversationId);
    }

    /// ✅ Messages ko read mark karo
    void markRead({required String conversationId}) {
      if (!isConnected.value) return;
      _socket?.emit('mark_read', {'conversationId': conversationId});
    }

    /// ✅ Messages replace karo (history load karne ke baad)
    void replaceMessages(
        String conversationId, List<Map<String, dynamic>> newMessages) {
      if (activeConversationId.value == conversationId) {
        messages.value = List<Map<String, dynamic>>.from(newMessages);
      }
    }

    // ==================== CALL METHODS ====================

    /// Call invite bhejo — callerName bhi include karo
    void sendCallInvite(String toUserId, String callType,
        {String callerName = ''}) {
      _socket?.emit('call_invite', {
        'toUserId': toUserId,
        'callType': callType,
        'callerName': callerName,
      });
      print('📤 call_invite sent to $toUserId');
    }

    void acceptCall(String toUserId, String callType) {
      _socket?.emit('call_accept', {'toUserId': toUserId, 'callType': callType});
      print('✅ call_accept sent to $toUserId');
    }

    void rejectCall(String toUserId) {
      _socket?.emit('call_reject', {'toUserId': toUserId});
      print('❌ call_reject sent to $toUserId');
    }

    void endCall(String toUserId) {
      _socket?.emit('call_end', {'toUserId': toUserId});
      print('📵 call_end sent to $toUserId');
    }

    // ==================== WEBRTC METHODS ====================
    void sendWebRtcOffer(String toUserId, dynamic sdp) {
      _socket?.emit('webrtc_offer', {'toUserId': toUserId, 'sdp': sdp});
      print('📤 webrtc_offer sent');
    }

    void sendWebRtcAnswer(String toUserId, dynamic sdp) {
      _socket?.emit('webrtc_answer', {'toUserId': toUserId, 'sdp': sdp});
      print('📤 webrtc_answer sent');
    }

    void sendIceCandidate(String toUserId, dynamic candidate) {
      _socket?.emit('webrtc_ice_candidate', {
        'toUserId': toUserId,
        'candidate': candidate,
      });
    }

    // ==================== HELPERS ====================
    void _emitJoin(String conversationId) {
      if (conversationId.isEmpty) return;
      _socket?.emit('join_conversation', {'conversationId': conversationId});
      print('🏠 Joined room: $conversationId');
    }

    void _emitLeave(String conversationId) {
      if (conversationId.isEmpty) return;
      _socket?.emit('leave_conversation', {'conversationId': conversationId});
      print('🚪 Left room: $conversationId');
    }

    void _updateMsgStatus(String clientId, String status) {
      final idx = messages.indexWhere((m) => m['clientId'] == clientId);
      if (idx != -1) {
        messages[idx]['status'] = status;
        messages.refresh();
      }
    }

    // ==================== 🔥 NEW: DISCONNECT METHOD FOR LOGOUT ====================
    /// Logout ke time saari connections clean karo
    void disconnect() {
      print('🔌 Starting complete socket disconnect for logout...');
      
      try {
        // 1. Saare callbacks null karo
        onConversationUpdated = null;
        onUserPresence = null;
        
        // 2. Saare call callbacks null karo
        onCallIncoming = null;
        onCallAccepted = null;
        onCallRejected = null;
        onCallEnded = null;
        onWebRtcOffer = null;
        onWebRtcAnswer = null;
        onWebRtcIceCandidate = null;
        
        // 3. Active conversation leave karo
        if (activeConversationId.value.isNotEmpty) {
          _emitLeave(activeConversationId.value);
          activeConversationId.value = '';
        }
        
        // 4. Saari pending messages clear karo
        _pendingMessages.clear();
        
        // 5. Rx variables reset karo
        messages.clear();
        isOtherTyping.value = false;
        
        // 6. Socket disconnect karo
        if (_socket != null) {
          // Saare events off karo
          _offAllEvents(_socket!);
          
          // Disconnect and close
          if (_socket!.connected) {
            _socket!.disconnect();
            print('✅ Socket disconnected successfully');
          }
          
          _socket!.close();
          _socket = null;
          print('✅ Socket reference removed');
        }
        
        isConnected.value = false;
        errorMessage.value = '';
        
        print('✅ ChatSocketController disconnect complete');
      } catch (e) {
        print('❌ Error in disconnect: $e');
      }
    }

/// ✅ Add a message directly to the current conversation
void addMessage(String conversationId, Map<String, dynamic> message) {
  if (activeConversationId.value == conversationId) {
    // Check if message already exists
    final msgId = message['_id']?.toString();
    if (msgId != null) {
      final exists = messages.any((m) => m['_id']?.toString() == msgId);
      if (exists) return;
    }
    
    // Add message to the list
    messages.add(message);
    
    // If it's a file message, you might want to mark it as sent
    if (message['status'] == null) {
      message['status'] = 'sent';
    }
    
    print('✅ Message added to conversation: $conversationId');
    
    // Auto scroll will be handled by the ever listener in ChatScreen
  }
}

    /// ✅ Socket disconnect manually (app band karte waqt)
    static void disconnectSocket() {
      if (_socket != null && _socket!.connected) {
        _socket!.disconnect();
        _socket!.close();
        _socket = null;
        print('🔌 Socket manually disconnected');
      }
    }

    // ==================== LIFECYCLE ====================
    @override
    void onClose() {
      print('ℹ️ ChatSocketController onClose - keeping socket alive');
      // Socket ko close mat karo - reuse karna hai
      super.onClose();
    }
  }
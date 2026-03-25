import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketController extends GetxController {
  var isConnected = false.obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isOtherTyping = false.obs;
  var activeConversationId = ''.obs;
  var errorMessage = ''.obs;

  // ── Call Type Tracker (audio / video / '') ────────────────
  var activeCallType = ''.obs;

  // ✅ FIX 1: static hata diya — ab instance variable hai
  IO.Socket? _socket;
  final Map<String, Map<String, dynamic>> _pendingMessages = {};

  Function(Map<String, dynamic>)? onConversationUpdated;
  Function(String, bool)? onUserPresence;

  // ── Audio Call Callbacks ──────────────────────────────────
  Function(Map<String, dynamic>)? onCallIncoming;
  Function(Map<String, dynamic>)? onCallAccepted;
  Function(Map<String, dynamic>)? onCallRejected;
  Function(Map<String, dynamic>)? onCallEnded;
  Function(Map<String, dynamic>)? onWebRtcOffer;
  Function(Map<String, dynamic>)? onWebRtcAnswer;
  Function(Map<String, dynamic>)? onWebRtcIceCandidate;
  Function(Map<String, dynamic>)? onWebRtcReady;

  // ── Video Call Callbacks ──────────────────────────────────
  Function(Map<String, dynamic>)? onVideoCallIncoming;
  Function(Map<String, dynamic>)? onVideoCallAccepted;
  Function(Map<String, dynamic>)? onVideoCallRejected;
  Function(Map<String, dynamic>)? onVideoCallEnded;
  Function(Map<String, dynamic>)? onVideoWebRtcOffer;
  Function(Map<String, dynamic>)? onVideoWebRtcAnswer;
  Function(Map<String, dynamic>)? onVideoWebRtcIce;
  Function(Map<String, dynamic>)? onVideoWebRtcReady;
  Function(Map<String, dynamic>)? onVideoCameraToggle;

  late String myUserId;
  late String _token;

  ChatSocketController({
    required String socketBaseUrl,
    required String token,
    required String myUserId,
  }) {
    this.myUserId = myUserId;
    _token = token;
    _initSocket(socketBaseUrl, token);
  }

  void _initSocket(String baseUrl, String token) {
    // ✅ FIX 2: Ab instance _socket check hoga, static nahi
    if (_socket != null && _socket!.connected) {
      print('✅ Reusing existing socket');
      isConnected.value = true;
      _registerEvents(_socket!);
      return;
    }

    // Agar socket exist karta hai but connected nahi — pehle dispose karo
    if (_socket != null) {
      try {
        _offAllEvents(_socket!);
        _socket!.dispose();
        _socket = null;
      } catch (_) {}
    }

    String socketUrl = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://')
        .replaceAll(RegExp(r'/+$'), '');

    print('🔌 Connecting to: $socketUrl');

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
            .disableAutoConnect() // ✅ FIX 3: pehle events register, phir connect
            .build(),
      );
      _socket = socket;
      _registerEvents(socket);
      socket.connect(); // ✅ FIX 4: Explicit connect
    } catch (e) {
      print('❌ Socket init error: $e');
      errorMessage.value = 'Socket initialization failed';
    }
  }

  void _registerEvents(IO.Socket socket) {
    _offAllEvents(socket);

    socket.on('connect', (_) {
      isConnected.value = true;
      errorMessage.value = '';
      print('✅ Socket connected: ${socket.id}');
      if (activeConversationId.value.isNotEmpty) {
        _emitJoin(activeConversationId.value);
      }
    });

    socket.on('disconnect', (r) {
      isConnected.value = false;
      print('❌ Disconnected: $r');
    });

    socket.on('connect_error', (_) {
      errorMessage.value = 'Connection failed';
    });

    socket.on('new_message',          (d) => _handleNewMessage(Map<String, dynamic>.from(d)));
    socket.on('message_status',       (d) => _handleMessageStatus(Map<String, dynamic>.from(d)));
    socket.on('read_receipt',         (d) => _handleReadReceipt(Map<String, dynamic>.from(d)));
    socket.on('typing',               (d) => _handleTyping(Map<String, dynamic>.from(d)));
    socket.on('conversation_updated', (d) => onConversationUpdated?.call(Map<String, dynamic>.from(d)));
    socket.on('presence',             (d) => _handlePresence(Map<String, dynamic>.from(d)));

    // ── Audio Call Events ─────────────────────────────────
    socket.on('call_incoming', (d) {
      final data = Map<String, dynamic>.from(d);
      activeCallType.value = 'audio';
      print('📲 call_incoming (audio)');
      onCallIncoming?.call(data);
    });

    socket.on('call_accepted', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'audio') {
        print('✅ call_accepted (audio)');
        onCallAccepted?.call(data);
      } else {
        print('⚠️ call_accepted ignored — activeCallType is: ${activeCallType.value}');
      }
    });

    socket.on('call_rejected', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'audio') {
        print('❌ call_rejected (audio)');
        activeCallType.value = '';
        onCallRejected?.call(data);
      }
    });

    socket.on('call_ended', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'audio') {
        print('📵 call_ended (audio)');
        activeCallType.value = '';
        onCallEnded?.call(data);
      }
    });

    socket.on('webrtc_offer', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'audio') {
        print('📨 webrtc_offer (audio)');
        onWebRtcOffer?.call(data);
      }
    });

    socket.on('webrtc_answer', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'audio') {
        print('📨 webrtc_answer (audio)');
        onWebRtcAnswer?.call(data);
      }
    });

    socket.on('webrtc_ice_candidate', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'audio') {
        print('🧊 webrtc_ice (audio)');
        onWebRtcIceCandidate?.call(data);
      }
    });

    socket.on('webrtc_ready', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'audio') {
        print('🤝 webrtc_ready (audio)');
        onWebRtcReady?.call(data);
      }
    });

    // ── Video Call Events ─────────────────────────────────
    socket.on('video_call_incoming', (d) {
      final data = Map<String, dynamic>.from(d);
      activeCallType.value = 'video';
      print('📹 video_call_incoming (video)');
      onVideoCallIncoming?.call(data);
    });

    socket.on('video_call_accepted', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('✅ video_call_accepted (video)');
        onVideoCallAccepted?.call(data);
      } else {
        print('⚠️ video_call_accepted ignored — activeCallType is: ${activeCallType.value}');
      }
    });

    socket.on('video_call_rejected', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('❌ video_call_rejected (video)');
        activeCallType.value = '';
        onVideoCallRejected?.call(data);
      }
    });

    socket.on('video_call_ended', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('📵 video_call_ended (video)');
        activeCallType.value = '';
        onVideoCallEnded?.call(data);
      }
    });

    socket.on('video_webrtc_offer', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('📨 video_webrtc_offer (video)');
        onVideoWebRtcOffer?.call(data);
      }
    });

    socket.on('video_webrtc_answer', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('📨 video_webrtc_answer (video)');
        onVideoWebRtcAnswer?.call(data);
      }
    });

    socket.on('video_webrtc_ice', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('🧊 video_webrtc_ice (video)');
        onVideoWebRtcIce?.call(data);
      }
    });

    socket.on('video_webrtc_ready', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('🤝 video_webrtc_ready (video)');
        onVideoWebRtcReady?.call(data);
      }
    });

    socket.on('video_camera_toggle', (d) {
      final data = Map<String, dynamic>.from(d);
      if (activeCallType.value == 'video') {
        print('📹 video_camera_toggle');
        onVideoCameraToggle?.call(data);
      }
    });
  }

  void _offAllEvents(IO.Socket socket) {
    for (final e in [
      'connect', 'disconnect', 'connect_error',
      'new_message', 'message_status', 'read_receipt', 'typing',
      'conversation_updated', 'presence',
      'call_incoming', 'call_accepted', 'call_rejected', 'call_ended',
      'webrtc_offer', 'webrtc_answer', 'webrtc_ice_candidate', 'webrtc_ready',
      'video_call_incoming', 'video_call_accepted', 'video_call_rejected', 'video_call_ended',
      'video_webrtc_offer', 'video_webrtc_answer', 'video_webrtc_ice', 'video_webrtc_ready',
      'video_camera_toggle',
    ]) {
      socket.off(e);
    }
  }

  // ── Message Handlers ─────────────────────────────────────
  void _handleNewMessage(Map<String, dynamic> message) {
    final cid  = message['conversationId']?.toString();
    final from = message['from']?.toString();
    final cKey = message['clientId']?.toString();

    if (cKey != null && _pendingMessages.containsKey(cKey)) {
      final idx = messages.indexWhere((m) => m['clientId'] == cKey);
      if (idx != -1) {
        messages[idx] = message;
        messages.refresh();
      }
      _pendingMessages.remove(cKey);
    } else if (cid == activeConversationId.value) {
      final id = message['_id']?.toString();
      if (id == null || !messages.any((m) => m['_id']?.toString() == id)) {
        messages.add(message);
      }
    }
    if (cid == activeConversationId.value && from != myUserId) {
      markRead(conversationId: cid!);
    }
  }

  void _handleMessageStatus(Map<String, dynamic> data) {
    if (data['conversationId']?.toString() != activeConversationId.value) return;
    for (var msg in messages) {
      if (msg['_id']?.toString() == data['messageId']?.toString()) {
        msg['status'] = data['status'];
        msg['deliveredAt'] = data['at'];
        break;
      }
    }
    messages.refresh();
  }

  void _handleReadReceipt(Map<String, dynamic> data) {
    if (data['conversationId']?.toString() != activeConversationId.value) return;
    if (data['readerId']?.toString() == myUserId) return;
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
    final from = data['fromUserId']?.toString();
    if (from != null && from != myUserId) {
      isOtherTyping.value = data['isTyping'] == true;
    }
  }

  void _handlePresence(Map<String, dynamic> data) {
    final uid = data['userId']?.toString();
    if (uid != null && uid != myUserId) {
      onUserPresence?.call(uid, data['online'] == true);
    }
  }

  // ── Chat Public Methods ───────────────────────────────────
  void setActiveConversation(String conversationId) {
    if (activeConversationId.value.isNotEmpty &&
        activeConversationId.value != conversationId) {
      _emitLeave(activeConversationId.value);
    }
    activeConversationId.value = conversationId;
    messages.clear();
    isOtherTyping.value = false;
    _emitJoin(conversationId);
  }

  void clearActiveConversation() {
    if (activeConversationId.value.isNotEmpty) {
      _emitLeave(activeConversationId.value);
    }
    activeConversationId.value = '';
    messages.clear();
    isOtherTyping.value = false;
  }

  void sendTyping({
    required String conversationId,
    required String toUserId,
    required bool isTyping,
  }) {
    if (!isConnected.value || conversationId.isEmpty || toUserId.isEmpty) return;
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'toUserId': toUserId,
      'isTyping': isTyping,
    });
  }

  // ── Send text message ─────────────────────────────────────
  void sendMessage({
    required String conversationId,
    required String toUserId,
    required String text,
  }) {
    final t = text.trim();
    if (t.isEmpty) return;
    if (!isConnected.value) { errorMessage.value = 'Not connected'; return; }

    final cid = '${DateTime.now().millisecondsSinceEpoch}_${myUserId.hashCode.abs()}';
    final tmp = {
      '_id': 'temp_$cid',
      'conversationId': conversationId,
      'from': myUserId,
      'to': toUserId,
      'type': 'text',
      'text': t,
      'mediaUrl': '',
      'originalName': '',
      'fileSize': 0,
      'status': 'sending',
      'clientId': cid,
      'createdAt': DateTime.now().toIso8601String(),
    };
    messages.add(tmp);
    _pendingMessages[cid] = tmp;

    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'toUserId': toUserId,
      'text': t,
      'type': 'text',
      'clientId': cid,
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (_pendingMessages.containsKey(cid)) {
        _updateMsgStatus(cid, 'failed');
        _pendingMessages.remove(cid);
        errorMessage.value = 'Message failed to send';
      }
    });
  }

  // ── Send file message ─────────────────────────────────────
  void sendFileMessage({
    required String conversationId,
    required String toUserId,
    required String type,
    required String mediaUrl,
    required String originalName,
    required int fileSize,
  }) {
    if (!isConnected.value) { errorMessage.value = 'Not connected'; return; }
    if (mediaUrl.isEmpty) { errorMessage.value = 'Invalid file URL'; return; }

    final cid = '${DateTime.now().millisecondsSinceEpoch}_${myUserId.hashCode.abs()}';
    final tmp = {
      '_id': 'temp_$cid',
      'conversationId': conversationId,
      'from': myUserId,
      'to': toUserId,
      'type': type,
      'text': '',
      'mediaUrl': mediaUrl,
      'originalName': originalName,
      'fileSize': fileSize,
      'status': 'sending',
      'clientId': cid,
      'createdAt': DateTime.now().toIso8601String(),
    };
    messages.add(tmp);
    _pendingMessages[cid] = tmp;

    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'toUserId': toUserId,
      'text': '',
      'type': type,
      'mediaUrl': mediaUrl,
      'originalName': originalName,
      'fileSize': fileSize,
      'clientId': cid,
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (_pendingMessages.containsKey(cid)) {
        _updateMsgStatus(cid, 'failed');
        _pendingMessages.remove(cid);
        errorMessage.value = 'File message failed to send';
      }
    });
  }

  void joinConversation({required String conversationId}) => _emitJoin(conversationId);
  void leaveConversation(String c) => _emitLeave(c);

  void markRead({required String conversationId}) {
    if (isConnected.value) {
      _socket?.emit('mark_read', {'conversationId': conversationId});
    }
  }

  void replaceMessages(String cid, List<Map<String, dynamic>> msgs) {
    if (activeConversationId.value == cid) {
      messages.value = List.from(msgs);
    }
  }

  void addMessage(String cid, Map<String, dynamic> msg) {
    if (activeConversationId.value != cid) return;
    final id = msg['_id']?.toString();
    if (id != null && messages.any((m) => m['_id']?.toString() == id)) return;
    msg['status'] ??= 'sent';
    messages.add(msg);
  }

  // ── Audio Call Methods ────────────────────────────────────
  void sendCallInvite(String to, String type, {String callerName = ''}) {
    activeCallType.value = 'audio';
    _socket?.emit('call_invite', {
      'toUserId': to,
      'callType': type,
      'callerName': callerName,
    });
  }

  void acceptCall(String to, String type) {
    activeCallType.value = 'audio';
    _socket?.emit('call_accept', {'toUserId': to, 'callType': type});
  }

  void rejectCall(String to) {
    activeCallType.value = '';
    _socket?.emit('call_reject', {'toUserId': to});
  }

  void endCall(String to) {
    activeCallType.value = '';
    _socket?.emit('call_end', {'toUserId': to});
  }

  void sendWebRtcOffer(String to, dynamic sdp) =>
      _socket?.emit('webrtc_offer', {'toUserId': to, 'sdp': sdp});

  void sendWebRtcAnswer(String to, dynamic sdp) =>
      _socket?.emit('webrtc_answer', {'toUserId': to, 'sdp': sdp});

  void sendIceCandidate(String to, dynamic c) =>
      _socket?.emit('webrtc_ice_candidate', {'toUserId': to, 'candidate': c});

  void sendWebRtcReady(String to) =>
      _socket?.emit('webrtc_ready', {'toUserId': to});

  // ── Video Call Methods ────────────────────────────────────
  void sendVideoCallInvite(String to, {String callerName = ''}) {
    activeCallType.value = 'video';
    _socket?.emit('video_call_invite', {
      'toUserId': to,
      'callerName': callerName,
    });
  }

  void acceptVideoCall(String to) {
    activeCallType.value = 'video';
    _socket?.emit('video_call_accept', {'toUserId': to});
  }

  void rejectVideoCall(String to) {
    activeCallType.value = '';
    _socket?.emit('video_call_reject', {'toUserId': to});
  }

  void endVideoCall(String to) {
    activeCallType.value = '';
    _socket?.emit('video_call_end', {'toUserId': to});
  }

  void sendVideoWebRtcOffer(String to, dynamic sdp) =>
      _socket?.emit('video_webrtc_offer', {'toUserId': to, 'sdp': sdp});

  void sendVideoWebRtcAnswer(String to, dynamic sdp) =>
      _socket?.emit('video_webrtc_answer', {'toUserId': to, 'sdp': sdp});

  void sendVideoIceCandidate(String to, dynamic c) =>
      _socket?.emit('video_webrtc_ice', {'toUserId': to, 'candidate': c});

  void sendVideoWebRtcReady(String to) =>
      _socket?.emit('video_webrtc_ready', {'toUserId': to});

  void sendVideoCameraToggle(String to, {required bool cameraOff}) =>
      _socket?.emit('video_camera_toggle', {'toUserId': to, 'cameraOff': cameraOff});

  // ── Helpers ───────────────────────────────────────────────
  void _emitJoin(String cid) {
    if (cid.isNotEmpty) _socket?.emit('join_conversation', {'conversationId': cid});
  }

  void _emitLeave(String cid) {
    if (cid.isNotEmpty) _socket?.emit('leave_conversation', {'conversationId': cid});
  }

  void _updateMsgStatus(String clientId, String status) {
    final i = messages.indexWhere((m) => m['clientId'] == clientId);
    if (i != -1) {
      messages[i]['status'] = status;
      messages.refresh();
    }
  }

  // ── Disconnect ────────────────────────────────────────────
  void disconnect() {
    print('🔌 Disconnecting...');
    try {
      // Callbacks null karo
      onConversationUpdated = onUserPresence = null;
      onCallIncoming = onCallAccepted = onCallRejected = onCallEnded = null;
      onWebRtcOffer = onWebRtcAnswer = onWebRtcIceCandidate = onWebRtcReady = null;
      onVideoCallIncoming = onVideoCallAccepted = onVideoCallRejected = onVideoCallEnded = null;
      onVideoWebRtcOffer = onVideoWebRtcAnswer = onVideoWebRtcIce = onVideoWebRtcReady = null;
      onVideoCameraToggle = null;

      activeCallType.value = '';

      if (activeConversationId.value.isNotEmpty) {
        _emitLeave(activeConversationId.value);
        activeConversationId.value = '';
      }
      _pendingMessages.clear();
      messages.clear();
      isOtherTyping.value = false;

      if (_socket != null) {
        _offAllEvents(_socket!);
        if (_socket!.connected) _socket!.disconnect();
        _socket!.dispose(); // ✅ FIX 5: close() ki jagah dispose()
        _socket = null;
      }
      isConnected.value = false;
      errorMessage.value = '';
      print('✅ Disconnected and disposed');
    } catch (e) {
      print('❌ Disconnect error: $e');
    }
  }

  // ✅ FIX 6: Static disconnectSocket() remove kar diya — ab zarurat nahi
  // kyunki _socket ab static nahi hai

  @override
  void onClose() => super.onClose();
}
//aa
// F:\templink_flutter\lib\controllers\call_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:templink/Global_Screens/call_Screen.dart';

import 'chat_socket_controller.dart';

enum CallState { idle, calling, incoming, connected, ended }

class CallController extends GetxController {
  // ─── observables ───
  var callState = CallState.idle.obs;
  var isMuted = false.obs;
  var isSpeakerOn = false.obs;
  var callDuration = 0.obs;
  var callerName = ''.obs;
  var callerId = ''.obs;

  // ─── WebRTC ───
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // ─── Audio ───
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  final Map<String, dynamic> _offerConstraints = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': false},
    'optional': [],
  };

  late String _myUserId;
  String? _remoteUserId;
  String? _activeCallKitId;
  Timer? _durationTimer;
  Timer? _missedCallTimer;

  // ─── Guard flags ───
  bool _incomingHandled = false;
  bool _acceptedFromAppUI = false; // ✅ NEW: app ke andar se accept track karo

  late final dynamic _fgListener;
  late final dynamic _clickListener;
  StreamSubscription<CallEvent?>? _callKitSubscription;

  ChatSocketController get _socket => Get.find<ChatSocketController>();

  // ─────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────
  void init(String myUserId) {
    _myUserId = myUserId;
    _listenSocketEvents();
    _listenCallKitEvents();
    _listenOneSignalEvents();
    print('📞 CallController initialized for $_myUserId');
  }

  // ─────────────────────────────────────────────
  // OneSignal
  // ─────────────────────────────────────────────
  void _listenOneSignalEvents() {
    _fgListener = (event) {
      final data = event.notification.additionalData;
      if (data != null && data['type'] == 'incoming_call') {
        event.preventDefault();
        final fromId   = data['callerId']?.toString() ?? '';
        final name     = data['callerName']?.toString() ?? 'Unknown';
        final callType = data['callType']?.toString() ?? 'audio';
        if (fromId.isNotEmpty) {
          // ✅ Sirf CallKit dikhao, VoiceCallScreen mat kholo — app already foreground mein hai
          _showCallKitIncoming(fromUserId: fromId, name: name, callType: callType);
        }
      }
    };
    OneSignal.Notifications.addForegroundWillDisplayListener(_fgListener);

    _clickListener = (event) {
      final data = event.notification.additionalData;
      if (data != null && data['type'] == 'incoming_call') {
        final fromId = data['callerId']?.toString() ?? '';
        final name   = data['callerName']?.toString() ?? 'Unknown';
        if (fromId.isNotEmpty) {
          _setIncomingState(fromId: fromId, name: name);
        }
      }
    };
    OneSignal.Notifications.addClickListener(_clickListener);
  }

  // ─────────────────────────────────────────────
  // CallKit events
  // ─────────────────────────────────────────────
  void _listenCallKitEvents() {
    _callKitSubscription = FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;
      print('📲 CallKit event: ${event.event}');

      switch (event.event) {

        case Event.actionCallAccept:
          // ✅ Agar already app UI se accept ho chuka hai, CallKit event ignore karo
          if (_acceptedFromAppUI) {
            print('⚠️ CallKit accept ignored — already accepted from app UI');
            await _dismissCallKitNotification();
            break;
          }

          final extra  = event.body?['extra'] as Map?;
          final fromId = extra?['callerId']?.toString() ?? '';
          final name   = extra?['callerName']?.toString() ?? 'Unknown';

          if (fromId.isNotEmpty) {
            if (callState.value == CallState.idle) {
              _setIncomingState(fromId: fromId, name: name);
            }
            _missedCallTimer?.cancel();
            await _stopSound();
            await acceptCall();

            if (Get.currentRoute != '/VoiceCallScreen') {
              Get.to(
                () => VoiceCallScreen(
                  remoteUserId: fromId,
                  remoteName: name,
                  isOutgoing: false,
                ),
                transition: Transition.upToDown,
                fullscreenDialog: true,
              );
            }
          }
          break;

        case Event.actionCallDecline:
          // ✅ Agar already app UI se reject ho chuka hai, ignore karo
          if (_acceptedFromAppUI) {
            print('⚠️ CallKit decline ignored — call already handled from app UI');
            _acceptedFromAppUI = false;
            break;
          }

          final extra  = event.body?['extra'] as Map?;
          final fromId = extra?['callerId']?.toString() ?? _remoteUserId ?? '';

          _missedCallTimer?.cancel();

          if (fromId.isNotEmpty) {
            _socket.rejectCall(fromId);
          }
          await _stopSound();
          _activeCallKitId = null;
          _resetCall();
          break;

        case Event.actionCallTimeout:
          await _stopSound();
          _showMissedCallNotification();
          _activeCallKitId = null;
          _acceptedFromAppUI = false;
          _resetCall();
          break;

        case Event.actionCallEnded:
          await _stopSound();
          _activeCallKitId = null;
          _acceptedFromAppUI = false;
          _resetCall();
          break;

        default:
          break;
      }
    });
  }

  // ─────────────────────────────────────────────
  // Helper: incoming state
  // ─────────────────────────────────────────────
  void _setIncomingState({required String fromId, required String name}) {
    if (_remoteUserId == fromId && callState.value == CallState.incoming) return;
    _remoteUserId    = fromId;
    callerId.value   = fromId;
    callerName.value = name;
    callState.value  = CallState.incoming;
  }

  // ─────────────────────────────────────────────
  // Missed call notification (local)
  // ─────────────────────────────────────────────
  void _showMissedCallNotification() {
    final name = callerName.value.isNotEmpty ? callerName.value : 'Unknown';
    Get.snackbar(
      '📵 Missed call',
      name,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1A1A2E),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.call_missed_rounded, color: Color(0xFFFF3B30)),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  // ─────────────────────────────────────────────
  // Ringtone helpers
  // ─────────────────────────────────────────────
  Future<void> _playCallingSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/calling.mp3'));
    } catch (e) { print('❌ Calling sound: $e'); }
  }

  Future<void> _playRingtone() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/ringtone.mp3'));
    } catch (e) { print('❌ Ringtone: $e'); }
  }

  Future<void> _stopSound() async {
    try { await _audioPlayer.stop(); } catch (e) { print('❌ Stop: $e'); }
  }

  // ─────────────────────────────────────────────
  // CallKit incoming screen
  // ─────────────────────────────────────────────
  Future<void> _showCallKitIncoming({
    required String fromUserId,
    required String name,
    String callType = 'audio',
  }) async {
    try {
      _activeCallKitId = fromUserId;

      final params = CallKitParams(
        id: fromUserId,
        nameCaller: name,
        appName: 'TempLink',
        type: callType == 'video' ? 1 : 0,
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        extra: {
          'callerId': fromUserId,
          'callerName': name,
          'callType': callType,
        },
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0F172A',
          backgroundUrl: null,
          actionColor: '#4F46E5',
          textColor: '#ffffff',
          isShowCallID: false,
          isShowFullLockedScreen: true,
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(params);
      print('📲 CallKit shown: $name (id: $fromUserId)');
    } catch (e) {
      print('❌ CallKit error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // CallKit dismiss
  // ─────────────────────────────────────────────
  Future<void> _dismissCallKitNotification() async {
    try {
      final idToEnd = _activeCallKitId ?? _remoteUserId;
      if (idToEnd != null) {
        await FlutterCallkitIncoming.endCall(idToEnd);
        print('✅ CallKit dismissed: $idToEnd');
      }
      await FlutterCallkitIncoming.endAllCalls();
      _activeCallKitId = null;
    } catch (e) {
      print('❌ CallKit dismiss error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Socket events
  // ─────────────────────────────────────────────
  void _listenSocketEvents() {
    _socket.onCallIncoming = (data) {
      final from = data['fromUserId']?.toString() ?? '';
      final name = data['callerName']?.toString() ?? 'Unknown';
      _handleIncomingCall(fromUserId: from, name: name);
    };

    _socket.onCallAccepted = (data) {
      print('✅ Call accepted by remote');
      if (callState.value == CallState.calling) {
        _stopSound();
        _missedCallTimer?.cancel();
        _createOffer();
      }
    };

    _socket.onCallRejected = (data) {
      _stopSound();
      _dismissCallKitNotification();
      _missedCallTimer?.cancel();
      _acceptedFromAppUI = false;
      _resetCall();
      Get.snackbar(
        'Call', 'Call was declined',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    };

    _socket.onCallEnded = (data) async {
      print('📵 Remote ended the call');
      await _stopSound();
      await _dismissCallKitNotification();
      _missedCallTimer?.cancel();
      _acceptedFromAppUI = false;

      if (callState.value == CallState.incoming) {
        _showMissedCallNotification();
      }

      _resetCall();
      if (Get.currentRoute != '/') Get.back();
    };

    _socket.onWebRtcOffer = (data) async {
      final sdp = data['sdp'];
      if (sdp == null) return;
      await _handleOffer(sdp);
    };

    _socket.onWebRtcAnswer = (data) async {
      final sdp = data['sdp'];
      if (sdp == null) return;
      await _handleAnswer(sdp);
    };

    _socket.onWebRtcIceCandidate = (data) async {
      final candidate = data['candidate'];
      if (candidate == null) return;
      await _handleIceCandidate(candidate);
    };
  }

  // ─────────────────────────────────────────────
  // Incoming call handler (socket se)
  // ─────────────────────────────────────────────
  void _handleIncomingCall({
    required String fromUserId,
    required String name,
  }) {
    if (callState.value != CallState.idle) {
      _socket.rejectCall(fromUserId);
      return;
    }

    _setIncomingState(fromId: fromUserId, name: name);
    _playRingtone();

    // ✅ CallKit sirf dikhao — VoiceCallScreen yahan mat kholo
    // App foreground mein hai to socket event se screen already open hogi
    // Agar background mein hoga to CallKit handle karega
    _showCallKitIncoming(fromUserId: fromUserId, name: name);

    // ✅ VoiceCallScreen open karo (in-app UI)
    Get.to(
      () => VoiceCallScreen(
        remoteUserId: fromUserId,
        remoteName: name,
        isOutgoing: false,
      ),
      transition: Transition.upToDown,
      fullscreenDialog: true,
    );
  }

  // ─────────────────────────────────────────────
  // START CALL
  // ─────────────────────────────────────────────
  Future<void> startCall({
    required String toUserId,
    required String toUserName,
  }) async {
    if (callState.value != CallState.idle) return;

    _remoteUserId    = toUserId;
    callerName.value = toUserName;
    callState.value  = CallState.calling;

    await _getLocalStream();
    await _playCallingSound();

    _socket.sendCallInvite(toUserId, 'audio', callerName: toUserName);

    _missedCallTimer = Timer(const Duration(seconds: 60), () {
      if (callState.value == CallState.calling) {
        _socket.endCall(toUserId);
        _stopSound();
        _resetCall();
        if (Get.currentRoute != '/') Get.back();
      }
    });

    Get.to(
      () => VoiceCallScreen(
        remoteUserId: toUserId,
        remoteName: toUserName,
        isOutgoing: true,
      ),
      transition: Transition.upToDown,
    );
  }

  // ─────────────────────────────────────────────
  // ACCEPT (app UI se)
  // ─────────────────────────────────────────────
  Future<void> acceptCall() async {
    final remote = _remoteUserId;
    if (remote == null) return;
    if (callState.value == CallState.connected) return;

    // ✅ Flag set karo — CallKit ko batao ke app UI se accept ho gaya
    _acceptedFromAppUI = true;

    await _stopSound();
    _missedCallTimer?.cancel();

    // ✅ CallKit notification immediately dismiss karo
    await _dismissCallKitNotification();

    try { await FlutterCallkitIncoming.setCallConnected(remote); }
    catch (e) { print('⚠️ CallKit setConnected: $e'); }

    if (_localStream == null) await _getLocalStream();
    if (_peerConnection == null) await _createPeerConnection();

    _socket.acceptCall(remote, 'audio');
    callState.value = CallState.connected;
    _startDurationTimer();
  }

  // ─────────────────────────────────────────────
  // REJECT (app UI se)
  // ─────────────────────────────────────────────
  void rejectCall() {
    final remote = _remoteUserId;
    if (remote != null) {
      _socket.rejectCall(remote);
    }
    _stopSound();
    _missedCallTimer?.cancel();
    _acceptedFromAppUI = false;
    _dismissCallKitNotification();
    _resetCall();
    if (Get.currentRoute != '/') Get.back();
  }

  // ─────────────────────────────────────────────
  // END CALL
  // ─────────────────────────────────────────────
  void endCall() {
    final remote = _remoteUserId;
    if (remote != null) {
      _socket.endCall(remote);
    }
    _stopSound();
    _missedCallTimer?.cancel();
    _acceptedFromAppUI = false;
    _dismissCallKitNotification();
    _resetCall();
    if (Get.currentRoute != '/') Get.back();
  }

  // ─────────────────────────────────────────────
  // MUTE / SPEAKER
  // ─────────────────────────────────────────────
  void toggleMute() {
    isMuted.value = !isMuted.value;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    Helper.setSpeakerphoneOn(isSpeakerOn.value);
  }

  // ─────────────────────────────────────────────
  // WebRTC
  // ─────────────────────────────────────────────
  Future<void> _getLocalStream() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true, 'video': false,
    });
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection?.onIceCandidate = (RTCIceCandidate c) {
      if (_remoteUserId == null) return;
      _socket.sendIceCandidate(_remoteUserId!, c.toMap());
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('🔗 $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        callState.value = CallState.connected;
        _startDurationTimer();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        endCall();
      }
    };
  }

  Future<void> _createOffer() async {
    await _createPeerConnection();
    final offer = await _peerConnection!.createOffer(_offerConstraints);
    await _peerConnection!.setLocalDescription(offer);
    _socket.sendWebRtcOffer(_remoteUserId!, offer.toMap());
  }

  Future<void> _handleOffer(dynamic sdpMap) async {
    if (_peerConnection == null) await _createPeerConnection();
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(sdpMap['sdp'], sdpMap['type']),
    );
    final answer = await _peerConnection!.createAnswer(_offerConstraints);
    await _peerConnection!.setLocalDescription(answer);
    _socket.sendWebRtcAnswer(_remoteUserId!, answer.toMap());
  }

  Future<void> _handleAnswer(dynamic sdpMap) async {
    await _peerConnection?.setRemoteDescription(
      RTCSessionDescription(sdpMap['sdp'], sdpMap['type']),
    );
  }

  Future<void> _handleIceCandidate(dynamic c) async {
    try {
      await _peerConnection?.addCandidate(
        RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
      );
    } catch (e) { print('❌ ICE: $e'); }
  }

  // ─────────────────────────────────────────────
  // Timer
  // ─────────────────────────────────────────────
  void _startDurationTimer() {
    _durationTimer?.cancel();
    callDuration.value = 0;
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1), (_) => callDuration.value++,
    );
  }

  String get formattedDuration {
    final m = (callDuration.value ~/ 60).toString().padLeft(2, '0');
    final s = (callDuration.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────
  void _resetCall() {
    _durationTimer?.cancel();
    _missedCallTimer?.cancel();
    _peerConnection?.close();
    _peerConnection = null;
    _localStream?.dispose();
    _localStream = null;
    _remoteUserId = null;
    _activeCallKitId = null;
    _incomingHandled = false;
    _acceptedFromAppUI = false; // ✅ Reset flag
    callState.value = CallState.idle;
    callDuration.value = 0;
    isMuted.value = false;
    isSpeakerOn.value = false;
    callerName.value = '';
    callerId.value = '';
  }

  void resetForLogout() {
    print('📞 Resetting CallController for logout...');
    try {
      _stopSound();
      _dismissCallKitNotification();
      try { FlutterCallkitIncoming.endAllCalls(); } catch (_) {}

      _peerConnection?.close();
      _peerConnection = null;
      _localStream?.dispose();
      _localStream = null;
      _durationTimer?.cancel();
      _durationTimer = null;
      _missedCallTimer?.cancel();
      _missedCallTimer = null;

      try {
        OneSignal.Notifications.removeForegroundWillDisplayListener(_fgListener);
        OneSignal.Notifications.removeClickListener(_clickListener);
      } catch (_) {}

      try {
        _callKitSubscription?.cancel();
        _callKitSubscription = null;
      } catch (_) {}

      _resetCall();
      print('✅ CallController reset complete');
    } catch (e) {
      print('❌ Error in resetForLogout: $e');
    }
  }

  @override
  void onClose() {
    print('📞 CallController onClose');
    _stopSound();
    _dismissCallKitNotification();
    try { _audioPlayer.dispose(); } catch (_) {}
    try { _callKitSubscription?.cancel(); } catch (_) {}
    _missedCallTimer?.cancel();
    _resetCall();
    super.onClose();
  }
}
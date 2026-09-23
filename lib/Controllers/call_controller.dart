// call_controller.dart  (AUDIO)
//
// ⚠️  _listenCallKitEvents() has been REMOVED.
//     All CallKit events now come through CallKitRouter → acceptCallFromCallKit()
//     / rejectCallFromCallKit() / handleCallKitEnded() / handleCallKitTimeout().

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
  // ─── Observables ───────────────────────────────────────────
  var callState    = CallState.idle.obs;
  var isMuted      = false.obs;
  var isSpeakerOn  = false.obs;
  var callDuration = 0.obs;
  var callerName   = ''.obs;
  var callerId     = ''.obs;

  // ─── WebRTC ────────────────────────────────────────────────
  RTCPeerConnection? _peerConnection;
  MediaStream?       _localStream;

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

  // ─── Audio ─────────────────────────────────────────────────
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ─── Internal state ────────────────────────────────────────
  late String _myUserId;
  String? _remoteUserId;
  String? _activeCallKitId;
  Timer?  _durationTimer;
  Timer?  _missedCallTimer;

  // ─── Guard flags (exposed as getters for CallKitRouter) ────
  bool _navigationDone = false;
  bool _callAccepted   = false;   // acceptCall() ran exactly once
  bool _callDeclined   = false;   // reject/end ran
  bool _callEndedByUs  = false;   // we sent end/reject to remote
  bool _offerSent      = false;

  bool get callAccepted => _callAccepted;
  bool get callDeclined => _callDeclined;

  // ─── OneSignal listeners (kept for removal on logout) ──────
  late final dynamic _fgListener;
  late final dynamic _clickListener;

  ChatSocketController get _socket => Get.find<ChatSocketController>();

  // ════════════════════════════════════════════════════════════
  //  INIT
  // ════════════════════════════════════════════════════════════
  void init(String myUserId) {
    _myUserId = myUserId;
    _listenSocketEvents();
    _listenOneSignalEvents();
    // ⚠️  Do NOT call _listenCallKitEvents() here.
    //     CallKitRouter handles all CallKit events globally.
    print('📞 CallController initialized for $_myUserId');
  }

  // ════════════════════════════════════════════════════════════
  //  ONESIGNAL  (foreground push — audio calls only)
  // ════════════════════════════════════════════════════════════
  void _listenOneSignalEvents() {
    _fgListener = (event) {
      final data = event.notification.additionalData;
      if (data == null) return;
      if (data['type'] == 'incoming_call') {
        event.preventDefault();
        final fromId   = data['callerId']?.toString() ?? '';
        final name     = data['callerName']?.toString() ?? 'Unknown';
        final callType = data['callType']?.toString() ?? 'audio';
        if (fromId.isNotEmpty) {
          // Only show CallKit UI — socket event already handled navigation
          _showCallKitUI(fromUserId: fromId, name: name, callType: callType);
        }
      }
      // 'incoming_video_call' is intentionally ignored here
    };
    OneSignal.Notifications.addForegroundWillDisplayListener(_fgListener);

    _clickListener = (event) {
      final data = event.notification.additionalData;
      if (data == null) return;
      if (data['type'] == 'incoming_call') {
        final fromId = data['callerId']?.toString() ?? '';
        final name   = data['callerName']?.toString() ?? 'Unknown';
        if (fromId.isNotEmpty && callState.value == CallState.idle) {
          setIncomingStatePublic(fromId: fromId, name: name);
        }
      }
    };
    OneSignal.Notifications.addClickListener(_clickListener);
  }
  void _listenSocketEvents() {

    _socket.onCallIncoming = (data) {
      final from     = data['fromUserId']?.toString() ?? '';
      final name     = data['callerName']?.toString() ?? 'Unknown';
      final callType = data['callType']?.toString() ?? 'audio';
      print('📞 onCallIncoming (audio) from: $from');
      _handleIncomingCall(fromUserId: from, name: name, callType: callType);
    };

    _socket.onCallAccepted = (data) {
      print('✅ onCallAccepted (audio)');
      if (callState.value != CallState.calling) return;
      _stopSound();
      _missedCallTimer?.cancel();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!_offerSent && callState.value == CallState.calling) {
          _offerSent = true;
          callState.value = CallState.connected;
          _startDurationTimer();
          _createOffer();
        }
      });
    };

    _socket.onWebRtcReady = (data) {
      print('🤝 webrtc_ready (audio)');
      if (!_offerSent && callState.value == CallState.connected) {
        _offerSent = true;
        _createOffer();
      }
    };

    _socket.onCallRejected = (data) {
      print('❌ onCallRejected (audio)');
      if (_callEndedByUs) return;
      _stopSound();
      _dismissCallKitUI();
      _missedCallTimer?.cancel();
      _hardReset();
      Get.snackbar(
        'Call declined',
        '${callerName.value.isNotEmpty ? callerName.value : "User"} declined the call',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      if (Get.currentRoute != '/') Get.back();
    };

    _socket.onCallEnded = (data) async {
      print('📵 onCallEnded (audio)');
      if (_callEndedByUs) return;
      await _stopSound();
      await _dismissCallKitUI();
      _missedCallTimer?.cancel();
      if (callState.value == CallState.incoming) _showMissedCallSnackbar();
      _hardReset();
      if (Get.currentRoute != '/') Get.back();
    };

    _socket.onWebRtcOffer = (data) async {
      final sdp = data['sdp'];
      if (sdp == null) return;
      print('📨 webrtc_offer (audio)');
      await _handleOffer(sdp);
    };

    _socket.onWebRtcAnswer = (data) async {
      final sdp = data['sdp'];
      if (sdp == null) return;
      print('📨 webrtc_answer (audio)');
      await _handleAnswer(sdp);
    };

    _socket.onWebRtcIceCandidate = (data) async {
      final candidate = data['candidate'];
      if (candidate == null) return;
      await _handleIceCandidate(candidate);
    };
  }

  void _handleIncomingCall({
    required String fromUserId,
    required String name,
    String callType = 'audio',
  }) {
    if (callState.value != CallState.idle) {
      print('⚠️ Already in call — rejecting from $fromUserId');
      _socket.rejectCall(fromUserId);
      return;
    }

    setIncomingStatePublic(fromId: fromUserId, name: name);
    _playRingtone();
    _showCallKitUI(fromUserId: fromUserId, name: name, callType: callType);

    // Push VoiceCallScreen exactly once from socket event
    if (!_navigationDone) {
      _navigationDone = true;
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
  }
  Future<void> startCall({
    required String toUserId,
    required String toUserName,
  }) async {
    if (callState.value != CallState.idle) return;

    _remoteUserId    = toUserId;
    callerName.value = toUserName;
    callState.value  = CallState.calling;
    _offerSent       = false;
    _callEndedByUs   = false;
    _callDeclined    = false;
    _callAccepted    = false;
    _navigationDone  = true;

    await _getLocalStream();
    await _createPeerConnection();
    await _playCallingSound();
    _socket.sendCallInvite(toUserId, 'audio', callerName: toUserName);

    _missedCallTimer = Timer(const Duration(seconds: 60), () {
      if (callState.value == CallState.calling) {
        _callEndedByUs = true;
        _socket.endCall(toUserId);
        _stopSound();
        _hardReset();
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

  // ════════════════════════════════════════════════════════════
  //  PUBLIC: ACCEPT CALL  (from app UI button)
  // ════════════════════════════════════════════════════════════
  Future<void> acceptCall() async {
    final remote = _remoteUserId;
    if (remote == null) { print('⚠️ acceptCall: no remoteUserId'); return; }
    if (_callAccepted)  { print('⚠️ acceptCall: already accepted'); return; }

    _callAccepted  = true;
    _callDeclined  = true;
    _callEndedByUs = false;

    await _stopSound();
    _missedCallTimer?.cancel();

    try {
      await FlutterCallkitIncoming.setCallConnected(remote);
    } catch (e) { print('⚠️ setCallConnected: $e'); }

    await Future.delayed(const Duration(milliseconds: 200));
    await _dismissCallKitUI();

    if (_localStream == null)    await _getLocalStream();
    if (_peerConnection == null) await _createPeerConnection();

    _socket.acceptCall(remote, 'audio');
    callState.value = CallState.connected;
    _startDurationTimer();
    print('✅ Call accepted — waiting for WebRTC offer');
  }

  Future<void> acceptCallFromCallKit({
    required String fromId,
    required String name,
  }) async {
    await _stopSound();
    _missedCallTimer?.cancel();
    await acceptCall();

    // Push screen only if not already on it
    if (!_navigationDone) {
      _navigationDone = true;
      await Get.to(
        () => VoiceCallScreen(
          remoteUserId: fromId,
          remoteName: callerName.value.isNotEmpty ? callerName.value : name,
          isOutgoing: false,
        ),
        transition: Transition.upToDown,
        fullscreenDialog: true,
      );
    }
  }

  /// Called when user taps Decline on CallKit overlay.
  void rejectCallFromCallKit({required String fromId}) {
    _callEndedByUs = true;
    _callDeclined  = true;
    _missedCallTimer?.cancel();
    final remote = _remoteUserId ?? fromId;
    if (remote.isNotEmpty) _socket.rejectCall(remote);
    _stopSound();
    _activeCallKitId = null;
    _hardReset();
    print('❌ [Audio] Rejected from CallKit');
  }

  /// Called when CallKit fires actionCallEnded (e.g. after timeout, or
  /// when overlay auto-dismisses — but NOT after accept).
  void handleCallKitEnded() {
    _stopSound();
    _activeCallKitId = null;
    _hardReset();
  }

  /// Called when CallKit fires actionCallTimeout.
  void handleCallKitTimeout() {
    _stopSound();
    _showMissedCallSnackbar();
    _activeCallKitId = null;
    _hardReset();
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC: REJECT  (from app UI)
  // ════════════════════════════════════════════════════════════
  void rejectCall() {
    if (_callAccepted) { print('⚠️ rejectCall ignored — already accepted'); return; }
    final remote = _remoteUserId;
    _callEndedByUs = true;
    _callDeclined  = true;
    if (remote != null) _socket.rejectCall(remote);
    _stopSound();
    _missedCallTimer?.cancel();
    _dismissCallKitUI();
    _hardReset();
    if (Get.currentRoute != '/') Get.back();
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC: END CALL  (from app UI)
  // ════════════════════════════════════════════════════════════
  void endCall() {
    final remote = _remoteUserId;
    _callEndedByUs = true;
    if (remote != null) _socket.endCall(remote);
    _stopSound();
    _missedCallTimer?.cancel();
    _dismissCallKitUI();
    _hardReset();
    if (Get.currentRoute != '/') Get.back();
  }

  // ════════════════════════════════════════════════════════════
  //  MUTE / SPEAKER
  // ════════════════════════════════════════════════════════════
  void toggleMute() {
    isMuted.value = !isMuted.value;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    Helper.setSpeakerphoneOn(isSpeakerOn.value);
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC STATE SETTER  (used by CallKitRouter)
  // ════════════════════════════════════════════════════════════
  void setIncomingStatePublic({required String fromId, required String name}) {
    if (_remoteUserId == fromId && callState.value == CallState.incoming) return;
    _remoteUserId    = fromId;
    callerId.value   = fromId;
    callerName.value = name;
    callState.value  = CallState.incoming;
    _callAccepted    = false;
    _callDeclined    = false;
    _callEndedByUs   = false;
    _navigationDone  = false;
    _offerSent       = false;
  }

  // ════════════════════════════════════════════════════════════
  //  WEBRTC
  // ════════════════════════════════════════════════════════════
  Future<void> _getLocalStream() async {
    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': false});
    print('🎤 Local audio stream ready');
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _localStream?.getTracks().forEach((t) {
      _peerConnection?.addTrack(t, _localStream!);
    });

    _peerConnection?.onIceCandidate = (RTCIceCandidate c) {
      if (_remoteUserId != null) _socket.sendIceCandidate(_remoteUserId!, c.toMap());
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('🔗 PeerConnection: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        callState.value = CallState.connected;
        if (!(_durationTimer?.isActive ?? false)) _startDurationTimer();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        if (!_callEndedByUs) endCall();
      }
    };
    print('✅ Audio peer connection ready');
  }

  Future<void> _createOffer() async {
    if (_peerConnection == null) await _createPeerConnection();
    final offer = await _peerConnection!.createOffer(_offerConstraints);
    await _peerConnection!.setLocalDescription(offer);
    _socket.sendWebRtcOffer(_remoteUserId!, offer.toMap());
    print('📤 Audio offer sent');
  }

  Future<void> _handleOffer(dynamic sdpMap) async {
    if (_peerConnection == null) {
      if (_localStream == null) await _getLocalStream();
      await _createPeerConnection();
    }
    await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdpMap['sdp'], sdpMap['type']));
    final answer = await _peerConnection!.createAnswer(_offerConstraints);
    await _peerConnection!.setLocalDescription(answer);
    _socket.sendWebRtcAnswer(_remoteUserId!, answer.toMap());
    print('📤 Audio answer sent');
  }

  Future<void> _handleAnswer(dynamic sdpMap) async {
    await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(sdpMap['sdp'], sdpMap['type']));
    print('✅ Remote answer set');
  }

  Future<void> _handleIceCandidate(dynamic c) async {
    try {
      await _peerConnection?.addCandidate(
          RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
    } catch (e) { print('❌ ICE: $e'); }
  }

  // ════════════════════════════════════════════════════════════
  //  CALLKIT UI HELPERS
  // ════════════════════════════════════════════════════════════
  Future<void> _showCallKitUI({
    required String fromUserId,
    required String name,
    String callType = 'audio',
  }) async {
    try {
      _activeCallKitId = fromUserId;
      await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
        id: fromUserId,
        nameCaller: name,
        appName: 'TempLink',
        type: 0,  // 0 = audio
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        extra: {'callerId': fromUserId, 'callerName': name, 'callType': 'audio'},
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
      ));
      print('📲 Audio CallKit UI shown: $name');
    } catch (e) { print('❌ CallKit show: $e'); }
  }

  Future<void> _dismissCallKitUI() async {
    try {
      final id = _activeCallKitId ?? _remoteUserId;
      if (id != null) await FlutterCallkitIncoming.endCall(id);
      await FlutterCallkitIncoming.endAllCalls();
      _activeCallKitId = null;
    } catch (e) { print('❌ CallKit dismiss: $e'); }
  }

  // ════════════════════════════════════════════════════════════
  //  SOUND
  // ════════════════════════════════════════════════════════════
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
    try { await _audioPlayer.stop(); } catch (_) {}
  }

  // ════════════════════════════════════════════════════════════
  //  TIMER
  // ════════════════════════════════════════════════════════════
  void _startDurationTimer() {
    _durationTimer?.cancel();
    callDuration.value = 0;
    _durationTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => callDuration.value++);
  }

  String get formattedDuration {
    final m = (callDuration.value ~/ 60).toString().padLeft(2, '0');
    final s = (callDuration.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showMissedCallSnackbar() {
    Get.snackbar(
      '📵 Missed call',
      callerName.value.isNotEmpty ? callerName.value : 'Unknown',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1A1A2E),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.call_missed_rounded, color: Color(0xFFFF3B30)),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  // ════════════════════════════════════════════════════════════
  //  HARD RESET
  // ════════════════════════════════════════════════════════════
  void _hardReset() {
    _durationTimer?.cancel();
    _missedCallTimer?.cancel();
    _peerConnection?.close();
    _peerConnection  = null;
    _localStream?.dispose();
    _localStream     = null;
    _remoteUserId    = null;
    _activeCallKitId = null;
    _navigationDone  = false;
    _callAccepted    = false;
    _callEndedByUs   = false;
    _callDeclined    = false;
    _offerSent       = false;
    callState.value  = CallState.idle;
    callDuration.value = 0;
    isMuted.value    = false;
    isSpeakerOn.value = false;
    callerName.value  = '';
    callerId.value    = '';
  }

  void resetForLogout() {
    try {
      _stopSound();
      _dismissCallKitUI();
      try { FlutterCallkitIncoming.endAllCalls(); } catch (_) {}
      try {
        OneSignal.Notifications.removeForegroundWillDisplayListener(_fgListener);
        OneSignal.Notifications.removeClickListener(_clickListener);
      } catch (_) {}
      _hardReset();
    } catch (e) { print('❌ resetForLogout: $e'); }
  }

  @override
  void onClose() {
    _stopSound();
    _dismissCallKitUI();
    try { _audioPlayer.dispose(); } catch (_) {}
    _missedCallTimer?.cancel();
    _hardReset();
    super.onClose();
  }
}
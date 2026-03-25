// video_call_controller.dart
//
// ⚠️  _listenCallKitEvents() has been REMOVED.
//     All CallKit events now come through CallKitRouter → acceptCallFromCallKit()
//     / rejectCallFromCallKit() / handleCallKitEnded() / handleCallKitTimeout().

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide navigator;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:templink/Employee/Screens/video_call_screen.dart';

import 'chat_socket_controller.dart';

enum VideoCallState { idle, calling, incoming, connected, ended }

class VideoCallController extends GetxController {
  // ─── Observables ───────────────────────────────────────────
  var videoCallState    = VideoCallState.idle.obs;
  var isMuted           = false.obs;
  var isSpeakerOn       = false.obs;
  var isCameraOff       = false.obs;
  var isRemoteCameraOff = false.obs;
  var callDuration      = 0.obs;
  var callerName        = ''.obs;
  var callerId          = ''.obs;

  // ─── Renderers ─────────────────────────────────────────────
  var localRenderer  = Rx<RTCVideoRenderer?>(null);
  var remoteRenderer = Rx<RTCVideoRenderer?>(null);

  // ─── WebRTC ────────────────────────────────────────────────
  RTCPeerConnection? _peerConnection;
  MediaStream?       _localStream;
  String _currentFacingMode  = 'user';
  bool   _iceConnected       = false;
  bool   _remoteStreamAttached = false;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {'urls': 'stun:stun3.l.google.com:19302'},
      {'urls': 'stun:stun4.l.google.com:19302'},
    ],
    'iceCandidatePoolSize': 0,
  };

  final Map<String, dynamic> _offerConstraints = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
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
  bool _callEndedByUs  = false;
  bool _offerSent      = false;

  bool get callAccepted => _callAccepted;
  bool get callDeclined => _callDeclined;

  // ─── OneSignal listeners ───────────────────────────────────
  late final dynamic _fgListener;
  late final dynamic _clickListener;

  ChatSocketController get _socket => Get.find<ChatSocketController>();

  // ════════════════════════════════════════════════════════════
  //  INIT
  // ════════════════════════════════════════════════════════════
  Future<void> init(String myUserId) async {
    _myUserId = myUserId;

    final lr = RTCVideoRenderer();
    final rr = RTCVideoRenderer();
    await lr.initialize();
    await rr.initialize();
    localRenderer.value  = lr;
    remoteRenderer.value = rr;

    _listenSocketEvents();
    _listenOneSignalEvents();
    // ⚠️  Do NOT call _listenCallKitEvents() here.
    //     CallKitRouter handles all CallKit events globally.
    print('📹 VideoCallController initialized for $_myUserId');
  }

  // ════════════════════════════════════════════════════════════
  //  ONESIGNAL  (video calls only)
  // ════════════════════════════════════════════════════════════
  void _listenOneSignalEvents() {
    _fgListener = (event) {
      final data = event.notification.additionalData;
      if (data == null) return;
      if (data['type'] == 'incoming_video_call') {
        event.preventDefault();
        final fromId = data['callerId']?.toString() ?? '';
        final name   = data['callerName']?.toString() ?? 'Unknown';
        if (fromId.isNotEmpty) {
          _showCallKitUI(fromUserId: fromId, name: name);
        }
      }
      // 'incoming_call' (audio) is intentionally ignored here
    };
    OneSignal.Notifications.addForegroundWillDisplayListener(_fgListener);

    _clickListener = (event) {
      final data = event.notification.additionalData;
      if (data == null) return;
      if (data['type'] == 'incoming_video_call') {
        final fromId = data['callerId']?.toString() ?? '';
        final name   = data['callerName']?.toString() ?? 'Unknown';
        if (fromId.isNotEmpty && videoCallState.value == VideoCallState.idle) {
          setIncomingStatePublic(fromId: fromId, name: name);
        }
      }
    };
    OneSignal.Notifications.addClickListener(_clickListener);
  }

  // ════════════════════════════════════════════════════════════
  //  SOCKET EVENTS
  // ════════════════════════════════════════════════════════════
  void _listenSocketEvents() {
    _socket.onVideoCallIncoming = (data) {
      final from = data['fromUserId']?.toString() ?? '';
      final name = data['callerName']?.toString() ?? 'Unknown';
      print('📹 onVideoCallIncoming from: $from');
      _handleIncomingCall(fromUserId: from, name: name);
    };

    _socket.onVideoCallAccepted = (data) {
      print('✅ [Video] Remote accepted');
      if (videoCallState.value != VideoCallState.calling) return;
      _stopSound();
      _missedCallTimer?.cancel();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_offerSent && videoCallState.value == VideoCallState.calling) {
          _offerSent = true;
          videoCallState.value = VideoCallState.connected;
          _createOffer();
        }
      });
    };

    _socket.onVideoWebRtcReady = (data) {
      print('🤝 [Video] WebRTC ready');
      if (!_offerSent && videoCallState.value == VideoCallState.connected) {
        _offerSent = true;
        _createOffer();
      }
    };

    _socket.onVideoCallRejected = (_) {
      print('❌ [Video] Rejected');
      if (_callEndedByUs) return;
      _stopSound();
      _dismissCallKitUI();
      _missedCallTimer?.cancel();
      _hardReset();
      Get.snackbar('Video Call', 'Call was declined',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    };

    _socket.onVideoCallEnded = (data) async {
      print('📵 [Video] Remote ended');
      if (_callEndedByUs) return;
      await _stopSound();
      await _dismissCallKitUI();
      _missedCallTimer?.cancel();
      if (videoCallState.value == VideoCallState.incoming) _showMissedCallNotif();
      _hardReset();
      if (Get.currentRoute != '/') Get.back();
    };

    _socket.onVideoWebRtcOffer = (data) async {
      final sdp = data['sdp'];
      if (sdp != null) await _handleOffer(sdp);
    };

    _socket.onVideoWebRtcAnswer = (data) async {
      final sdp = data['sdp'];
      if (sdp != null) await _handleAnswer(sdp);
    };

    _socket.onVideoWebRtcIce = (data) async {
      final c = data['candidate'];
      if (c != null) await _handleIceCandidate(c);
    };

    _socket.onVideoCameraToggle = (data) {
      isRemoteCameraOff.value = data['cameraOff'] == true;
    };
  }

  // ════════════════════════════════════════════════════════════
  //  INCOMING CALL  (socket event only)
  // ════════════════════════════════════════════════════════════
  void _handleIncomingCall({required String fromUserId, required String name}) {
    if (videoCallState.value != VideoCallState.idle) {
      print('⚠️ [Video] Already in call — rejecting $fromUserId');
      _socket.rejectVideoCall(fromUserId);
      return;
    }

    setIncomingStatePublic(fromId: fromUserId, name: name);
    _playRingtone();
    _showCallKitUI(fromUserId: fromUserId, name: name);

    // Push VideoCallScreen exactly once
    if (!_navigationDone) {
      _navigationDone = true;
      Get.to(
        () => VideoCallScreen(
          remoteUserId: fromUserId,
          remoteName: name,
          isOutgoing: false,
        ),
        transition: Transition.upToDown,
        fullscreenDialog: true,
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC: START VIDEO CALL  (outgoing)
  // ════════════════════════════════════════════════════════════
  Future<void> startVideoCall({
    required String toUserId,
    required String toUserName,
  }) async {
    if (videoCallState.value != VideoCallState.idle) return;

    _remoteUserId        = toUserId;
    callerName.value     = toUserName;
    videoCallState.value = VideoCallState.calling;
    _offerSent           = false;
    _callEndedByUs       = false;
    _callDeclined        = false;
    _callAccepted        = false;
    _navigationDone      = true;
    _iceConnected        = false;
    _remoteStreamAttached = false;

    final streamOk = await _getLocalStream();
    if (!streamOk) { _hardReset(); return; }

    await _playCallingSound();
    _socket.sendVideoCallInvite(toUserId, callerName: toUserName);

    _missedCallTimer = Timer(const Duration(seconds: 60), () {
      if (videoCallState.value == VideoCallState.calling) {
        _callEndedByUs = true;
        _socket.endVideoCall(toUserId);
        _stopSound();
        _hardReset();
        if (Get.currentRoute != '/') Get.back();
      }
    });

    Get.to(
      () => VideoCallScreen(
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
    if (remote == null)  { print('⚠️ [Video] acceptCall: no remoteUserId'); return; }
    if (_callAccepted)   { print('⚠️ [Video] acceptCall: already accepted'); return; }

    _callAccepted  = true;
    _callDeclined  = true;
    _callEndedByUs = false;
    _iceConnected  = false;
    _remoteStreamAttached = false;

    await _stopSound();
    _missedCallTimer?.cancel();

    try { await FlutterCallkitIncoming.setCallConnected(remote); }
    catch (e) { print('⚠️ setCallConnected: $e'); }

    await Future.delayed(const Duration(milliseconds: 200));
    await _dismissCallKitUI();

    if (_localStream == null) {
      final ok = await _getLocalStream();
      if (!ok) { rejectCall(); return; }
    }
    if (_peerConnection == null) await _createPeerConnection();

    _socket.acceptVideoCall(remote);
    print('✅ [Video] Call accepted — waiting for offer');
  }

  // ════════════════════════════════════════════════════════════
  //  CALLKIT ROUTER CALLBACKS  (called by CallKitRouter only)
  // ════════════════════════════════════════════════════════════

  /// Called when user taps Accept on CallKit overlay.
  Future<void> acceptCallFromCallKit({
    required String fromId,
    required String name,
  }) async {
    await _stopSound();
    _missedCallTimer?.cancel();
    await acceptCall();

    if (!_navigationDone) {
      _navigationDone = true;
      await Get.to(
        () => VideoCallScreen(
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
    if (remote.isNotEmpty) _socket.rejectVideoCall(remote);
    _stopSound();
    _activeCallKitId = null;
    _hardReset();
    print('❌ [Video] Rejected from CallKit');
  }

  void handleCallKitEnded() {
    _stopSound();
    _activeCallKitId = null;
    _hardReset();
  }

  void handleCallKitTimeout() {
    _stopSound();
    _showMissedCallNotif();
    _activeCallKitId = null;
    _hardReset();
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC: REJECT / END  (from app UI)
  // ════════════════════════════════════════════════════════════
  void rejectCall() {
    if (_callAccepted) { print('⚠️ [Video] rejectCall ignored — already accepted'); return; }
    final remote = _remoteUserId;
    _callEndedByUs = true;
    _callDeclined  = true;
    if (remote != null) _socket.rejectVideoCall(remote);
    _stopSound();
    _missedCallTimer?.cancel();
    _dismissCallKitUI();
    _hardReset();
    if (Get.currentRoute != '/') Get.back();
  }

  void endCall() {
    final remote = _remoteUserId;
    _callEndedByUs = true;
    if (remote != null) _socket.endVideoCall(remote);
    _stopSound();
    _missedCallTimer?.cancel();
    _dismissCallKitUI();
    _hardReset();
    if (Get.currentRoute != '/') Get.back();
  }

  // ════════════════════════════════════════════════════════════
  //  CONTROLS
  // ════════════════════════════════════════════════════════════
  void toggleMute() {
    isMuted.value = !isMuted.value;
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !isMuted.value);
  }

  void toggleCamera() {
    isCameraOff.value = !isCameraOff.value;
    _localStream?.getVideoTracks().forEach((t) => t.enabled = !isCameraOff.value);
    if (_remoteUserId != null) {
      _socket.sendVideoCameraToggle(_remoteUserId!, cameraOff: isCameraOff.value);
    }
  }

  Future<void> flipCamera() async {
    final tracks = _localStream?.getVideoTracks();
    if (tracks == null || tracks.isEmpty) return;
    try {
      await Helper.switchCamera(tracks.first);
      _currentFacingMode = _currentFacingMode == 'user' ? 'environment' : 'user';
    } catch (e) { print('❌ Flip: $e'); }
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    Helper.setSpeakerphoneOn(isSpeakerOn.value);
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC STATE SETTER  (used by CallKitRouter)
  // ════════════════════════════════════════════════════════════
  void setIncomingStatePublic({required String fromId, required String name}) {
    if (_remoteUserId == fromId && videoCallState.value == VideoCallState.incoming) return;
    _remoteUserId        = fromId;
    callerId.value       = fromId;
    callerName.value     = name;
    videoCallState.value = VideoCallState.incoming;
    _callAccepted        = false;
    _callDeclined        = false;
    _callEndedByUs       = false;
    _navigationDone      = false;
    _offerSent           = false;
    _iceConnected        = false;
    _remoteStreamAttached = false;
  }

  // ════════════════════════════════════════════════════════════
  //  LOCAL STREAM
  // ════════════════════════════════════════════════════════════
  Future<bool> _getLocalStream() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': _currentFacingMode,
          'width':  {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        },
      });
      localRenderer.value?.srcObject = _localStream;
      print('✅ [Video] Local stream ready');
      return true;
    } catch (e) {
      print('❌ [Video] getUserMedia failed: $e');
      final msg = e.toString();
      if (msg.contains('NotAllowedError') || msg.contains('DOMException')) {
        Get.dialog(AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.videocam_off_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Camera Permission Denied'),
          ]),
          content: const Text(
            'Camera and microphone access was denied.\n\n'
            'Go to Settings → TempLink → Enable Camera and Microphone.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ), barrierDismissible: false);
      } else {
        Get.snackbar('Camera Error', msg,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.85),
            colorText: Colors.white);
      }
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  PEER CONNECTION
  // ════════════════════════════════════════════════════════════
  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    _localStream?.getTracks().forEach((t) {
      _peerConnection?.addTrack(t, _localStream!);
    });

    _peerConnection?.onTrack = (RTCTrackEvent e) {
      if (e.track.kind == 'video' && e.streams.isNotEmpty) {
        remoteRenderer.value?.srcObject = e.streams[0];
        _remoteStreamAttached = true;
        remoteRenderer.refresh();
        print('✅ [Video] Remote video attached');
      }
    };

    _peerConnection?.onIceCandidate = (RTCIceCandidate c) {
      print('🧊 ICE: ${c.candidate?.substring(0, min(50, c.candidate?.length ?? 0))}...');
      if (_remoteUserId != null) {
        _socket.sendVideoIceCandidate(_remoteUserId!, c.toMap());
      }
    };

    _peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('🧊 ICE state: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
        _iceConnected = true;
      }
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('🔗 [Video] PeerConnection: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        videoCallState.value = VideoCallState.connected;
        isSpeakerOn.value = true;
        Helper.setSpeakerphoneOn(true);
        _startDurationTimer();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        if (videoCallState.value == VideoCallState.connected && !_callEndedByUs) {
          endCall();
        }
      }
    };

    print('✅ [Video] Peer connection ready');
  }

  // ════════════════════════════════════════════════════════════
  //  SIGNALING
  // ════════════════════════════════════════════════════════════
  Future<void> _createOffer() async {
    if (_peerConnection == null) await _createPeerConnection();
    final offer = await _peerConnection!.createOffer(_offerConstraints);
    final hasVideo = offer.sdp?.contains('m=video') ?? false;
    if (!hasVideo) {
      final strict = await _peerConnection!.createOffer({
        'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
      });
      await _peerConnection!.setLocalDescription(strict);
      _socket.sendVideoWebRtcOffer(_remoteUserId!, strict.toMap());
    } else {
      await _peerConnection!.setLocalDescription(offer);
      _socket.sendVideoWebRtcOffer(_remoteUserId!, offer.toMap());
    }
    print('📤 [Video] Offer sent');
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
    _socket.sendVideoWebRtcAnswer(_remoteUserId!, answer.toMap());
    print('📤 [Video] Answer sent');
  }

  Future<void> _handleAnswer(dynamic sdpMap) async {
    await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(sdpMap['sdp'], sdpMap['type']));
    print('✅ [Video] Remote answer set');
  }

  Future<void> _handleIceCandidate(dynamic c) async {
    try {
      await _peerConnection?.addCandidate(
          RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
    } catch (e) { print('❌ [Video] ICE: $e'); }
  }

  // ════════════════════════════════════════════════════════════
  //  CALLKIT UI
  // ════════════════════════════════════════════════════════════
  Future<void> _showCallKitUI({
    required String fromUserId,
    required String name,
  }) async {
    try {
      _activeCallKitId = fromUserId;
      await FlutterCallkitIncoming.showCallkitIncoming(CallKitParams(
        id: fromUserId,
        nameCaller: name,
        appName: 'TempLink',
        type: 1,  // 1 = video
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        extra: {'callerId': fromUserId, 'callerName': name, 'callType': 'video'},
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0A0A1A',
          backgroundUrl: null,
          actionColor: '#4F46E5',
          textColor: '#ffffff',
          isShowCallID: false,
          isShowFullLockedScreen: true,
        ),
      ));
      print('📲 [Video] CallKit UI shown: $name');
    } catch (e) { print('❌ [Video] CallKit: $e'); }
  }

  Future<void> _dismissCallKitUI() async {
    try {
      final id = _activeCallKitId ?? _remoteUserId;
      if (id != null) await FlutterCallkitIncoming.endCall(id);
      await FlutterCallkitIncoming.endAllCalls();
      _activeCallKitId = null;
    } catch (e) { print('❌ [Video] CallKit dismiss: $e'); }
  }

  // ════════════════════════════════════════════════════════════
  //  SOUND
  // ════════════════════════════════════════════════════════════
  Future<void> _playCallingSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/calling.mp3'));
    } catch (e) { print('❌ [Video] Calling sound: $e'); }
  }

  Future<void> _playRingtone() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/ringtone.mp3'));
    } catch (e) { print('❌ [Video] Ringtone: $e'); }
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

  void _showMissedCallNotif() {
    Get.snackbar(
      '📵 Missed video call',
      callerName.value.isNotEmpty ? callerName.value : 'Unknown',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF1A1A2E),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.videocam_off_rounded, color: Color(0xFFFF3B30)),
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
    try { _peerConnection?.close(); } catch (_) {}
    _peerConnection = null;
    try {
      _localStream?.getTracks().forEach((t) => t.stop());
      _localStream?.dispose();
    } catch (_) {}
    _localStream = null;
    localRenderer.value?.srcObject  = null;
    remoteRenderer.value?.srcObject = null;
    localRenderer.refresh();
    remoteRenderer.refresh();

    _remoteUserId         = null;
    _activeCallKitId      = null;
    _navigationDone       = false;
    _callAccepted         = false;
    _callEndedByUs        = false;
    _callDeclined         = false;
    _offerSent            = false;
    _currentFacingMode    = 'user';
    _iceConnected         = false;
    _remoteStreamAttached = false;

    videoCallState.value    = VideoCallState.idle;
    callDuration.value      = 0;
    isMuted.value           = false;
    isSpeakerOn.value       = false;
    isCameraOff.value       = false;
    isRemoteCameraOff.value = false;
    callerName.value        = '';
    callerId.value          = '';
  }

  // ════════════════════════════════════════════════════════════
  //  LOGOUT
  // ════════════════════════════════════════════════════════════
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
    } catch (e) { print('❌ [Video] resetForLogout: $e'); }
  }

  @override
  void onClose() {
    _stopSound();
    _dismissCallKitUI();
    try { _audioPlayer.dispose(); } catch (_) {}
    localRenderer.value?.dispose();
    remoteRenderer.value?.dispose();
    _hardReset();
    super.onClose();
  }
}
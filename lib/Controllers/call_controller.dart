// // lib/controllers/call_controller.dart
// // ============================================================
// // WebRTC Voice Call Controller — Socket.io signaling
// // Depends on: flutter_webrtc, get, socket_io_client
// // ============================================================

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide navigator;
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:templink/Global_Screens/call_Screen.dart';

// import 'chat_socket_controller.dart'; // tumhara existing controller

// // ─────────────────────────────────────────────
// // Call state enum
// // ─────────────────────────────────────────────
// enum CallState { idle, calling, incoming, connected, ended }

// class CallController extends GetxController {
//   // ─── observables ───
//   var callState = CallState.idle.obs;
//   var isMuted = false.obs;
//   var isSpeakerOn = false.obs;
//   var callDuration = 0.obs; // seconds
//   var callerName = ''.obs;
//   var callerId = ''.obs; // who is calling me

//   // ─── WebRTC internals ───
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;

//   // STUN servers — free Google STUN (production mein TURN bhi add karo)
//   final Map<String, dynamic> _iceServers = {
//     'iceServers': [
//       {'urls': 'stun:stun.l.google.com:19302'},
//       {'urls': 'stun:stun1.l.google.com:19302'},
//     ]
//   };

//   final Map<String, dynamic> _offerConstraints = {
//     'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': false},
//     'optional': [],
//   };

//   late String _myUserId;
//   String? _remoteUserId; // current call peer
//   Timer? _durationTimer;

//   // ─── Socket ref ───
//   ChatSocketController get _socket => Get.find<ChatSocketController>();

//   // ─────────────────────────────────────────────
//   // Init
//   // ─────────────────────────────────────────────
//   void init(String myUserId) {
//     _myUserId = myUserId;
//     _listenSocketEvents();
//     print('📞 CallController initialized for $_myUserId');
//   }

//   // ─────────────────────────────────────────────
//   // Socket event listeners
//   // ─────────────────────────────────────────────
//   void _listenSocketEvents() {
//     // Incoming call invite
//     _socket.onCallIncoming = (data) {
//       final from = data['fromUserId']?.toString() ?? '';
//       final name = data['callerName']?.toString() ?? 'Unknown';
//       _handleIncomingCall(fromUserId: from, name: name);
//     };

//     // Other side accepted
//     _socket.onCallAccepted = (data) {
//       final from = data['fromUserId']?.toString() ?? '';
//       print('✅ Call accepted by $from');
//       if (callState.value == CallState.calling) {
//         _createOffer(); // now create WebRTC offer
//       }
//     };

//     // Other side rejected
//     _socket.onCallRejected = (data) {
//       print('❌ Call rejected');
//       _resetCall();
//       Get.snackbar('Call', 'Call was declined',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red.withOpacity(0.8),
//           colorText: Colors.white);
//     };

//     // Other side ended
//     _socket.onCallEnded = (data) {
//       print('📵 Call ended by remote');
//       _resetCall();
//       if (Get.isRegistered<CallController>()) {
//         Get.back(); // close call screen
//       }
//     };

//     // WebRTC signaling
//     _socket.onWebRtcOffer = (data) async {
//       final sdp = data['sdp'];
//       if (sdp == null) return;
//       print('📨 Received WebRTC offer');
//       await _handleOffer(sdp);
//     };

//     _socket.onWebRtcAnswer = (data) async {
//       final sdp = data['sdp'];
//       if (sdp == null) return;
//       print('📨 Received WebRTC answer');
//       await _handleAnswer(sdp);
//     };

//     _socket.onWebRtcIceCandidate = (data) async {
//       final candidate = data['candidate'];
//       if (candidate == null) return;
//       await _handleIceCandidate(candidate);
//     };
//   }

//   // ─────────────────────────────────────────────
//   // OUTGOING CALL — caller side
//   // ─────────────────────────────────────────────
//   Future<void> startCall({
//     required String toUserId,
//     required String toUserName,
//   }) async {
//     if (callState.value != CallState.idle) {
//       print('⚠️ Already in a call');
//       return;
//     }

//     _remoteUserId = toUserId;
//     callerName.value = toUserName;
//     callState.value = CallState.calling;

//     // Request mic permission + get local stream
//     await _getLocalStream();

//     // Send invite via socket
//     _socket.sendCallInvite(toUserId, 'audio');

//     print('📤 Call invite sent to $toUserId');

//     // Navigate to call screen
//     Get.to(
//       () => VoiceCallScreen(
//         remoteUserId: toUserId,
//         remoteName: toUserName,
//         isOutgoing: true,
//       ),
//       transition: Transition.upToDown,
//     );
//   }

//   // ─────────────────────────────────────────────
//   // INCOMING CALL — receiver side
//   // ─────────────────────────────────────────────
//   void _handleIncomingCall({
//     required String fromUserId,
//     required String name,
//   }) {
//     if (callState.value != CallState.idle) {
//       // Already in call — auto reject
//       _socket.rejectCall(fromUserId);
//       return;
//     }

//     _remoteUserId = fromUserId;
//     callerId.value = fromUserId;
//     callerName.value = name;
//     callState.value = CallState.incoming;

//     print('📲 Incoming call from $name ($fromUserId)');

//     // Show incoming call screen on top of everything
//     Get.to(
//       () => VoiceCallScreen(
//         remoteUserId: fromUserId,
//         remoteName: name,
//         isOutgoing: false,
//       ),
//       transition: Transition.upToDown,
//       fullscreenDialog: true,
//     );
//   }

//   // ─────────────────────────────────────────────
//   // ACCEPT CALL — receiver side
//   // ─────────────────────────────────────────────
//   Future<void> acceptCall() async {
//     final remote = _remoteUserId;
//     if (remote == null) return;

//     await _getLocalStream();
//     await _createPeerConnection();

//     _socket.acceptCall(remote, 'audio');
//     callState.value = CallState.connected;
//     _startDurationTimer();

//     print('✅ Call accepted, waiting for offer...');
//   }

//   // ─────────────────────────────────────────────
//   // REJECT CALL
//   // ─────────────────────────────────────────────
//   void rejectCall() {
//     final remote = _remoteUserId;
//     if (remote != null) {
//       _socket.rejectCall(remote);
//     }
//     _resetCall();
//     Get.back();
//   }

//   // ─────────────────────────────────────────────
//   // END CALL
//   // ─────────────────────────────────────────────
//   void endCall() {
//     final remote = _remoteUserId;
//     if (remote != null) {
//       _socket.endCall(remote);
//     }
//     _resetCall();
//     Get.back();
//   }

//   // ─────────────────────────────────────────────
//   // MUTE / SPEAKER
//   // ─────────────────────────────────────────────
//   void toggleMute() {
//     isMuted.value = !isMuted.value;
//     _localStream?.getAudioTracks().forEach((track) {
//       track.enabled = !isMuted.value;
//     });
//     print('🔇 Muted: ${isMuted.value}');
//   }

//   void toggleSpeaker() {
//     isSpeakerOn.value = !isSpeakerOn.value;
//     // flutter_webrtc Helper
//     Helper.setSpeakerphoneOn(isSpeakerOn.value);
//     print('🔊 Speaker: ${isSpeakerOn.value}');
//   }

//   // ─────────────────────────────────────────────
//   // WebRTC internals
//   // ─────────────────────────────────────────────

//   Future<void> _getLocalStream() async {
//     _localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': false,
//     });
//     print('🎤 Local audio stream obtained');
//   }

//   Future<void> _createPeerConnection() async {
//     _peerConnection = await createPeerConnection(_iceServers);

//     // Add local audio tracks
//     _localStream?.getTracks().forEach((track) {
//       _peerConnection?.addTrack(track, _localStream!);
//     });

//     // ICE candidates — send to remote via socket
//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       if (_remoteUserId == null) return;
//       print('🧊 Sending ICE candidate');
//       _socket.sendIceCandidate(_remoteUserId!, candidate.toMap());
//     };

//     _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
//       print('🔗 Connection state: $state');
//       if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
//         callState.value = CallState.connected;
//         _startDurationTimer();
//         print('🎉 WebRTC Connected!');
//       } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
//           state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
//         print('❌ Connection failed/disconnected');
//         endCall();
//       }
//     };

//     print('🔌 PeerConnection created');
//   }

//   // Caller: create offer after callee accepts
//   Future<void> _createOffer() async {
//     await _createPeerConnection();

//     final offer = await _peerConnection!.createOffer(_offerConstraints);
//     await _peerConnection!.setLocalDescription(offer);

//     _socket.sendWebRtcOffer(_remoteUserId!, offer.toMap());
//     print('📤 Offer sent');
//   }

//   // Callee: receive offer, create answer
//   Future<void> _handleOffer(dynamic sdpMap) async {
//     if (_peerConnection == null) await _createPeerConnection();

//     final desc = RTCSessionDescription(sdpMap['sdp'], sdpMap['type']);
//     await _peerConnection!.setRemoteDescription(desc);

//     final answer = await _peerConnection!.createAnswer(_offerConstraints);
//     await _peerConnection!.setLocalDescription(answer);

//     _socket.sendWebRtcAnswer(_remoteUserId!, answer.toMap());
//     print('📤 Answer sent');
//   }

//   // Caller: receive answer
//   Future<void> _handleAnswer(dynamic sdpMap) async {
//     final desc = RTCSessionDescription(sdpMap['sdp'], sdpMap['type']);
//     await _peerConnection?.setRemoteDescription(desc);
//     print('✅ Remote description set (answer)');
//   }

//   // Both: handle ICE candidates
//   Future<void> _handleIceCandidate(dynamic candidateMap) async {
//     try {
//       final candidate = RTCIceCandidate(
//         candidateMap['candidate'],
//         candidateMap['sdpMid'],
//         candidateMap['sdpMLineIndex'],
//       );
//       await _peerConnection?.addCandidate(candidate);
//       print('🧊 ICE candidate added');
//     } catch (e) {
//       print('❌ ICE candidate error: $e');
//     }
//   }

//   // ─────────────────────────────────────────────
//   // Timer
//   // ─────────────────────────────────────────────
//   void _startDurationTimer() {
//     _durationTimer?.cancel();
//     callDuration.value = 0;
//     _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       callDuration.value++;
//     });
//   }

//   String get formattedDuration {
//     final m = (callDuration.value ~/ 60).toString().padLeft(2, '0');
//     final s = (callDuration.value % 60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   // ─────────────────────────────────────────────
//   // Cleanup
//   // ─────────────────────────────────────────────
//   void _resetCall() {
//     _durationTimer?.cancel();
//     _peerConnection?.close();
//     _peerConnection = null;
//     _localStream?.dispose();
//     _localStream = null;
//     _remoteUserId = null;
//     callState.value = CallState.idle;
//     callDuration.value = 0;
//     isMuted.value = false;
//     isSpeakerOn.value = false;
//     callerName.value = '';
//     callerId.value = '';
//     print('🧹 Call reset');
//   }

//   @override
//   void onClose() {
//     _resetCall();
//     super.onClose();
//   }
// }
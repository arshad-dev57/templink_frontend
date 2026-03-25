// callkit_router.dart
//
// ════════════════════════════════════════════════════════════════════════
//  SINGLE CALLKIT ROUTER
// ════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:get/get.dart';

// ⚠️  IMPORTANT: These imports MUST match EXACTLY the same path used in
//     ChatUsersListScreen (and anywhere else you do Get.put()).
//     Your project uses uppercase "Controllers" folder — so use that here too.
import 'package:templink/Controllers/call_controller.dart';
import 'package:templink/controllers/video_call_controller.dart';

class CallKitRouter {
  static StreamSubscription<CallEvent?>? _sub;

  /// Call once after both controllers are registered with Get.put().
  static void init() {
    _sub?.cancel();
    _sub = FlutterCallkitIncoming.onEvent.listen(_onEvent);
    print('📲 CallKitRouter: listening');
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
    print('📲 CallKitRouter: disposed');
  }

  // ──────────────────────────────────────────────────────────
  static Future<void> _onEvent(CallEvent? event) async {
    if (event == null) return;

    final extra    = event.body?['extra'] as Map?;
    final callType = extra?['callType']?.toString() ?? 'audio';
    final fromId   = extra?['callerId']?.toString() ?? '';
    final name     = extra?['callerName']?.toString() ?? 'Unknown';

    print('📲 CallKitRouter → event: ${event.event} | callType: $callType');

    if (callType == 'video') {
      await _dispatchVideo(event, fromId, name);
    } else {
      await _dispatchAudio(event, fromId, name);
    }
  }

  // ══════════════════════════════════════════════════════════
  //  AUDIO  → CallController
  // ══════════════════════════════════════════════════════════
  static Future<void> _dispatchAudio(
      CallEvent event, String fromId, String name) async {
    final ctrl = _audio;
    if (ctrl == null) {
      print('⚠️ CallKitRouter: CallController not registered');
      return;
    }

    switch (event.event) {

      case Event.actionCallIncoming:
        if (fromId.isNotEmpty && ctrl.callState.value == CallState.idle) {
          ctrl.setIncomingStatePublic(fromId: fromId, name: name);
        }
        break;

      case Event.actionCallAccept:
        if (ctrl.callAccepted) {
          print('⚠️ [Audio] CallKit accept ignored — already accepted');
          break;
        }
        if (fromId.isNotEmpty) {
          if (ctrl.callState.value == CallState.idle) {
            ctrl.setIncomingStatePublic(fromId: fromId, name: name);
          }
          await ctrl.acceptCallFromCallKit(fromId: fromId, name: name);
        }
        break;

      case Event.actionCallDecline:
        if (ctrl.callAccepted || ctrl.callDeclined) {
          print('⚠️ [Audio] CallKit decline ignored');
          break;
        }
        if (ctrl.callState.value == CallState.connected ||
            ctrl.callState.value == CallState.calling) {
          print('⚠️ [Audio] CallKit decline ignored — active call');
          break;
        }
        ctrl.rejectCallFromCallKit(fromId: fromId);
        break;

      case Event.actionCallEnded:
        if (ctrl.callAccepted) {
          print('⚠️ [Audio] actionCallEnded ignored — call was accepted');
          break;
        }
        if (ctrl.callState.value == CallState.connected ||
            ctrl.callState.value == CallState.calling) {
          print('⚠️ [Audio] actionCallEnded ignored — active call');
          break;
        }
        ctrl.handleCallKitEnded();
        break;

      case Event.actionCallTimeout:
        if (ctrl.callAccepted) {
          print('⚠️ [Audio] actionCallTimeout ignored — already accepted');
          break;
        }
        ctrl.handleCallKitTimeout();
        break;

      default:
        break;
    }
  }

  // ══════════════════════════════════════════════════════════
  //  VIDEO  → VideoCallController
  // ══════════════════════════════════════════════════════════
  static Future<void> _dispatchVideo(
      CallEvent event, String fromId, String name) async {
    final ctrl = _video;
    if (ctrl == null) {
      print('⚠️ CallKitRouter: VideoCallController not registered');
      return;
    }

    switch (event.event) {

      case Event.actionCallIncoming:
        if (fromId.isNotEmpty &&
            ctrl.videoCallState.value == VideoCallState.idle) {
          ctrl.setIncomingStatePublic(fromId: fromId, name: name);
        }
        break;

      case Event.actionCallAccept:
        if (ctrl.callAccepted) {
          print('⚠️ [Video] CallKit accept ignored — already accepted');
          break;
        }
        if (fromId.isNotEmpty) {
          if (ctrl.videoCallState.value == VideoCallState.idle) {
            ctrl.setIncomingStatePublic(fromId: fromId, name: name);
          }
          await ctrl.acceptCallFromCallKit(fromId: fromId, name: name);
        }
        break;

      case Event.actionCallDecline:
        if (ctrl.callAccepted || ctrl.callDeclined) {
          print('⚠️ [Video] CallKit decline ignored');
          break;
        }
        if (ctrl.videoCallState.value == VideoCallState.connected ||
            ctrl.videoCallState.value == VideoCallState.calling) {
          print('⚠️ [Video] CallKit decline ignored — active call');
          break;
        }
        ctrl.rejectCallFromCallKit(fromId: fromId);
        break;

      case Event.actionCallEnded:
        if (ctrl.callAccepted) {
          print('⚠️ [Video] actionCallEnded ignored — call was accepted');
          break;
        }
        if (ctrl.videoCallState.value == VideoCallState.connected ||
            ctrl.videoCallState.value == VideoCallState.calling) {
          print('⚠️ [Video] actionCallEnded ignored — active call');
          break;
        }
        ctrl.handleCallKitEnded();
        break;

      case Event.actionCallTimeout:
        if (ctrl.callAccepted) {
          print('⚠️ [Video] actionCallTimeout ignored — already accepted');
          break;
        }
        ctrl.handleCallKitTimeout();
        break;

      default:
        break;
    }
  }

  static CallController?      get _audio => Get.isRegistered<CallController>()      ? Get.find<CallController>()      : null;
  static VideoCallController? get _video => Get.isRegistered<VideoCallController>() ? Get.find<VideoCallController>() : null;
}
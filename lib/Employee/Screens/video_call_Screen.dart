//aa
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../Controllers/video_call_controller.dart';

class VideoCallScreen extends StatefulWidget {
  final String remoteUserId;
  final String remoteName;
  final bool isOutgoing;

  const VideoCallScreen({
    Key? key,
    required this.remoteUserId,
    required this.remoteName,
    required this.isOutgoing,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  late VideoCallController _ctrl;

  bool _showControls = true;
  Timer? _hideTimer;

  double _pipX = 16;
  double _pipY = 100;

  late AnimationController _controlsAnim;
  late AnimationController _connectingAnim;
  late Animation<double> _controlsFade;
  late Animation<double> _connectingPulse;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _ctrl = Get.find<VideoCallController>();

    _controlsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    _controlsFade = CurvedAnimation(
      parent: _controlsAnim,
      curve: Curves.easeInOut,
    );

    _connectingAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _connectingPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _connectingAnim, curve: Curves.easeInOut),
    );

    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _ctrl.videoCallState.value == VideoCallState.connected) {
        _controlsAnim.reverse();
        setState(() => _showControls = false);
      }
    });
  }

  void _onTap() {
    setState(() => _showControls = true);
    _controlsAnim.forward();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controlsAnim.dispose();
    _connectingAnim.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          children: [
            _buildRemoteVideo(),
            _buildGradientOverlays(),
            _buildConnectingOverlay(),
            _buildDraggablePiP(size),
            _buildTopBar(),
            _buildBottomControls(), // ✅ FIX: Positioned bahar, Obx andar
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return Obx(() {
      final hasRemoteVideo = _ctrl.remoteRenderer.value != null &&
          _ctrl.videoCallState.value == VideoCallState.connected &&
          !_ctrl.isRemoteCameraOff.value;

      if (hasRemoteVideo) {
        return Positioned.fill(
          child: RTCVideoView(
            _ctrl.remoteRenderer.value!,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
        );
      }

      return Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1117), Color(0xFF161B22), Color(0xFF0D1117)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.remoteName.isNotEmpty
                          ? widget.remoteName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.remoteName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() => Text(
                      _ctrl.isRemoteCameraOff.value ? 'Camera off' : '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGradientOverlays() {
    return FadeTransition(
      opacity: _controlsFade,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xDD000000), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingOverlay() {
    return Obx(() {
      final state = _ctrl.videoCallState.value;
      if (state == VideoCallState.connected) return const SizedBox.shrink();

      final isOutgoing = state == VideoCallState.calling;
      final label = isOutgoing ? 'Calling...' : 'Incoming Video Call';
      final sub =
          isOutgoing ? 'Waiting for ${widget.remoteName}' : widget.remoteName;

      return Positioned.fill(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0A1A), Color(0xFF0D1117)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _connectingPulse,
                builder: (_, __) => Transform.scale(
                  scale: _connectingPulse.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(
                            0.3 + 0.3 * _connectingPulse.value,
                          ),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.remoteName.isNotEmpty
                            ? widget.remoteName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                sub,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 48),
              if (state == VideoCallState.incoming)
                _buildIncomingActions()
              else
                _buildCancelButton(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIncomingActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          icon: Icons.call_end_rounded,
          color: const Color(0xFFEF4444),
          size: 64,
          iconSize: 28,
          onTap: () => _ctrl.rejectCall(),
          label: 'Decline',
        ),
        const SizedBox(width: 56),
        _CircleButton(
          icon: Icons.videocam_rounded,
          color: const Color(0xFF22C55E),
          size: 64,
          iconSize: 28,
          onTap: () => _ctrl.acceptCall(),
          label: 'Accept',
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return _CircleButton(
      icon: Icons.call_end_rounded,
      color: const Color(0xFFEF4444),
      size: 64,
      iconSize: 28,
      onTap: () => _ctrl.endCall(),
      label: 'Cancel',
    );
  }

  Widget _buildDraggablePiP(Size size) {
    return Obx(() {
      if (_ctrl.videoCallState.value != VideoCallState.connected) {
        return const SizedBox.shrink();
      }

      return Positioned(
        left: _pipX,
        top: _pipY,
        child: GestureDetector(
          onPanUpdate: (d) {
            setState(() {
              _pipX = (_pipX + d.delta.dx).clamp(0, size.width - 100);
              _pipY = (_pipY + d.delta.dy).clamp(0, size.height - 150);
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 96,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _ctrl.isCameraOff.value
                  ? Center(
                      child: Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 28,
                      ),
                    )
                  : (_ctrl.localRenderer.value != null
                      ? RTCVideoView(
                          _ctrl.localRenderer.value!,
                          mirror: true,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : const SizedBox.shrink()),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Obx(() {
      if (_ctrl.videoCallState.value != VideoCallState.connected) {
        return const SizedBox.shrink();
      }

      return FadeTransition(
        opacity: _controlsFade,
        child: Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.remoteName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        _ctrl.formattedDuration,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontFeatures: [const FontFeature.tabularFigures()],
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 6),
                          ],
                        ),
                      )),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded,
                        color: Color(0xFF22C55E), size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Encrypted',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ✅ FIX: Positioned Stack ka direct child hai — Obx andar hai
  Widget _buildBottomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 32,
      left: 0,
      right: 0,
      child: Obx(() {
        if (_ctrl.videoCallState.value != VideoCallState.connected) {
          return const SizedBox.shrink();
        }

        return FadeTransition(
          opacity: _controlsFade,
          child: Column(
            children: [
              // Row 1: Flip + Speaker
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SmallButton(
                    icon: Icons.flip_camera_ios_rounded,
                    label: 'Flip',
                    onTap: () => _ctrl.flipCamera(),
                  ),
                  const SizedBox(width: 32),
                  Obx(() => _SmallButton(
                        icon: _ctrl.isSpeakerOn.value
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label:
                            _ctrl.isSpeakerOn.value ? 'Speaker' : 'Earpiece',
                        onTap: () => _ctrl.toggleSpeaker(),
                        active: _ctrl.isSpeakerOn.value,
                      )),
                ],
              ),
              const SizedBox(height: 20),
              // Row 2: Mute + End Call + Camera Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(() => _ControlButton(
                        icon: _ctrl.isMuted.value
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        label: _ctrl.isMuted.value ? 'Unmute' : 'Mute',
                        active: _ctrl.isMuted.value,
                        onTap: () => _ctrl.toggleMute(),
                      )),
                  _CircleButton(
                    icon: Icons.call_end_rounded,
                    color: const Color(0xFFEF4444),
                    size: 68,
                    iconSize: 30,
                    onTap: () => _ctrl.endCall(),
                    label: 'End',
                  ),
                  Obx(() => _ControlButton(
                        icon: _ctrl.isCameraOff.value
                            ? Icons.videocam_off_rounded
                            : Icons.videocam_rounded,
                        label:
                            _ctrl.isCameraOff.value ? 'Start Cam' : 'Stop Cam',
                        active: _ctrl.isCameraOff.value,
                        onTap: () => _ctrl.toggleCamera(),
                      )),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Reusable button widgets ────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback onTap;
  final String label;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: active
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _SmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(active ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(active ? 0.4 : 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
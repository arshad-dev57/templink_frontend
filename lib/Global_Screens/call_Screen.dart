

// lib/screens/voice_call_screen.dart
// ============================================================
// Beautiful Voice Call UI — Works for incoming & outgoing
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/call_controller.dart';

import '../Utils/colors.dart'; // tumhara existing colors file

class VoiceCallScreen extends StatefulWidget {
  final String remoteUserId;
  final String remoteName;
  final bool isOutgoing;

  const VoiceCallScreen({
    Key? key,
    required this.remoteUserId,
    required this.remoteName,
    required this.isOutgoing,
  }) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with TickerProviderStateMixin {
  late final CallController _callCtrl;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _callCtrl = Get.find<CallController>();

    // Pulse animation for avatar
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for connected state
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // ─── Avatar initials ───
  String get _initials {
    final parts = widget.remoteName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ─── Status text ───
  Widget _buildStatusText() {
    return Obx(() {
      final state = _callCtrl.callState.value;

      String text;
      Color color;

      switch (state) {
        case CallState.calling:
          text = 'Calling...';
          color = Colors.white70;
          break;
        case CallState.incoming:
          text = widget.isOutgoing ? 'Calling...' : 'Incoming call';
          color = Colors.white70;
          break;
        case CallState.connected:
          text = _callCtrl.formattedDuration;
          color = const Color(0xFF4ADE80); // green
          break;
        case CallState.ended:
          text = 'Call ended';
          color = Colors.white54;
          break;
        default:
          text = '';
          color = Colors.white70;
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          text,
          key: ValueKey(text),
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: state == CallState.connected
                ? FontWeight.w600
                : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      );
    });
  }

  // ─── Animated avatar ───
  Widget _buildAvatar() {
    return Obx(() {
      final connected = _callCtrl.callState.value == CallState.connected;

      return SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse rings (when calling/incoming)
            if (!connected) ...[
              _buildRing(80, 0.3),
              _buildRing(100, 0.15),
            ],

            // Sound waves (when connected)
            if (connected) ...[
              _buildWaveRing(75, 0),
              _buildWaveRing(90, 0.3),
              _buildWaveRing(105, 0.6),
            ],

            // Avatar circle
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) {
                final scale = connected ? 1.0 : _pulseAnimation.value;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primary,
                          primary.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRing(double size, double opacity) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) {
        return Container(
          width: size * _pulseAnimation.value,
          height: size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primary.withOpacity(opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveRing(double size, double phaseOffset) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (_, __) {
        final value = math.sin(
          (_waveController.value + phaseOffset) * 2 * math.pi,
        );
        final scale = 1.0 + (value * 0.08);
        final opacity = 0.15 + (value * 0.1).clamp(0.0, 0.3);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4ADE80).withOpacity(opacity),
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Call action button ───
  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color bgColor,
    Color iconColor = Colors.white,
    double size = 64,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: size * 0.42),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Controls row (during call) ───
  Widget _buildCallControls() {
    return Obx(() {
      final muted = _callCtrl.isMuted.value;
      final speaker = _callCtrl.isSpeakerOn.value;

      return Column(
        children: [
          // Top controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionBtn(
                icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                label: muted ? 'Unmute' : 'Mute',
                onTap: _callCtrl.toggleMute,
                bgColor: muted
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.12),
                size: 60,
              ),
              _buildActionBtn(
                icon: speaker
                    ? Icons.volume_up_rounded
                    : Icons.volume_down_rounded,
                label: speaker ? 'Speaker' : 'Earpiece',
                onTap: _callCtrl.toggleSpeaker,
                bgColor: speaker
                    ? primary.withOpacity(0.8)
                    : Colors.white.withOpacity(0.12),
                size: 60,
              ),
            ],
          ),
          const SizedBox(height: 36),
          // End call button
          _buildActionBtn(
            icon: Icons.call_end_rounded,
            label: 'End Call',
            onTap: _callCtrl.endCall,
            bgColor: const Color(0xFFEF4444),
            size: 72,
          ),
        ],
      );
    });
  }

  // ─── Incoming call actions ───
  Widget _buildIncomingActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Decline
        _buildActionBtn(
          icon: Icons.call_end_rounded,
          label: 'Decline',
          onTap: _callCtrl.rejectCall,
          bgColor: const Color(0xFFEF4444),
          size: 72,
        ),
        // Accept
        _buildActionBtn(
          icon: Icons.call_rounded,
          label: 'Accept',
          onTap: _callCtrl.acceptCall,
          bgColor: const Color(0xFF22C55E),
          size: 72,
        ),
      ],
    );
  }

  // ─── Outgoing (waiting) actions ───
  Widget _buildCallingActions() {
    return _buildActionBtn(
      icon: Icons.call_end_rounded,
      label: 'Cancel',
      onTap: _callCtrl.endCall,
      bgColor: const Color(0xFFEF4444),
      size: 72,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0F172A), // dark navy
              const Color(0xFF1E293B),
              Color.lerp(const Color(0xFF1E293B), primary, 0.15)!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Back / minimize
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Voice Call',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40), // balance
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ── Avatar
              _buildAvatar(),

              const SizedBox(height: 28),

              // ── Name
              Text(
                widget.remoteName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 8),

              // ── Status / timer
              _buildStatusText(),

              const Spacer(flex: 3),

              // ── Buttons (reactive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Obx(() {
                  final state = _callCtrl.callState.value;

                  if (state == CallState.incoming && !widget.isOutgoing) {
                    return _buildIncomingActions();
                  } else if (state == CallState.calling ||
                      (state == CallState.incoming && widget.isOutgoing)) {
                    return _buildCallingActions();
                  } else if (state == CallState.connected) {
                    return _buildCallControls();
                  }

                  return const SizedBox();
                }),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
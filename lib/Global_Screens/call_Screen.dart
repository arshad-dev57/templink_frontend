
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/call_controller.dart';

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

  final CallController _callCtrl = Get.put(CallController());

  late AnimationController _rippleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = widget.remoteName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ─── Background ───────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF075E54), // WhatsApp dark teal
            Color(0xFF128C7E), // WhatsApp teal
            Color(0xFF0A3D35),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // ─── Ripple rings (calling state) ─────────────────────────
  Widget _buildRippleRings() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final progress = (_rippleController.value + delay) % 1.0;
            final size = 130.0 + (progress * 120);
            final opacity = (1.0 - progress) * 0.25;

            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(opacity),
                  width: 1.5,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ─── Avatar ───────────────────────────────────────────────
  Widget _buildAvatar() {
    return Obx(() {
      final connected = _callCtrl.callState.value == CallState.connected;
      return SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple rings — only when not connected
            if (!connected) _buildRippleRings(),

            // Connected: soft glow
            if (connected)
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.4),
                      blurRadius: 32,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),

            // Avatar circle
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── Status text ──────────────────────────────────────────
  Widget _buildStatusText() {
    return Obx(() {
      final state = _callCtrl.callState.value;

      String text;
      Color color;
      FontWeight weight;

      switch (state) {
        case CallState.calling:
          text = widget.isOutgoing ? 'Calling...' : 'Incoming call';
          color = Colors.white.withOpacity(0.7);
          weight = FontWeight.w400;
          break;
        case CallState.incoming:
          text = widget.isOutgoing ? 'Calling...' : 'Incoming call';
          color = Colors.white.withOpacity(0.7);
          weight = FontWeight.w400;
          break;
        case CallState.connected:
          text = _callCtrl.formattedDuration;
          color = const Color(0xFF25D366);
          weight = FontWeight.w500;
          break;
        case CallState.ended:
          text = 'Call ended';
          color = Colors.white.withOpacity(0.5);
          weight = FontWeight.w400;
          break;
        default:
          text = '';
          color = Colors.white.withOpacity(0.7);
          weight = FontWeight.w400;
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: Text(
          text,
          key: ValueKey(text),
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: weight,
            letterSpacing: 0.3,
          ),
        ),
      );
    });
  }

  // ─── Single control button ─────────────────────────────────
  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDanger = false,
    bool isLarge = false,
  }) {
    final double size = isLarge ? 68.0 : 56.0;
    final Color bg = isDanger
        ? const Color(0xFFFF3B30)
        : isActive
            ? Colors.white.withOpacity(0.9)
            : Colors.white.withOpacity(0.15);
    final Color iconC = isDanger
        ? Colors.white
        : isActive
            ? const Color(0xFF075E54)
            : Colors.white;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              boxShadow: isDanger
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF3B30).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: iconC, size: size * 0.42),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Accept button (large green) ──────────────────────────
  Widget _buildAcceptBtn() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _callCtrl.acceptCall();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withOpacity(0.45),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.call, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 7),
          Text(
            'Accept',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  // ─── In-call controls ─────────────────────────────────────
  Widget _buildCallControls() {
    return Obx(() {
      final muted = _callCtrl.isMuted.value;
      final speaker = _callCtrl.isSpeakerOn.value;

      return Column(
        children: [
          // Top row: mute, speaker, (spacer)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlBtn(
                  icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: muted ? 'Unmute' : 'Mute',
                  onTap: _callCtrl.toggleMute,
                  isActive: muted,
                ),
                _buildControlBtn(
                  icon: speaker
                      ? Icons.volume_up_rounded
                      : Icons.phone_in_talk_rounded,
                  label: speaker ? 'Speaker' : 'Earpiece',
                  onTap: _callCtrl.toggleSpeaker,
                  isActive: speaker,
                ),
                _buildControlBtn(
                  icon: Icons.keyboard_rounded,
                  label: 'Keypad',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // End call
          _buildControlBtn(
            icon: Icons.call_end_rounded,
            label: 'End call',
            onTap: _callCtrl.endCall,
            isDanger: true,
            isLarge: true,
          ),
        ],
      );
    });
  }

  // ─── Incoming call actions ────────────────────────────────
  Widget _buildIncomingActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlBtn(
            icon: Icons.call_end_rounded,
            label: 'Decline',
            onTap: _callCtrl.rejectCall,
            isDanger: true,
            isLarge: true,
          ),
          _buildAcceptBtn(),
        ],
      ),
    );
  }

  // ─── Outgoing / cancel ────────────────────────────────────
  Widget _buildCallingActions() {
    return _buildControlBtn(
      icon: Icons.call_end_rounded,
      label: 'Cancel',
      onTap: _callCtrl.endCall,
      isDanger: true,
      isLarge: true,
    );
  }

  // ─── Bottom frosted panel ─────────────────────────────────
  Widget _buildBottomPanel() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
          child: Obx(() {
            final state = _callCtrl.callState.value;

            if (state == CallState.incoming && !widget.isOutgoing) {
              return _buildIncomingActions();
            }

            if (state == CallState.calling ||
                (state == CallState.incoming && widget.isOutgoing)) {
              return Center(child: _buildCallingActions());
            }

            if (state == CallState.connected) {
              return _buildCallControls();
            }

            return const SizedBox(height: 80);
          }),
        ),
      ),
    );
  }

  // ─── Main build ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF075E54),
        body: FadeTransition(
          opacity: _fadeIn,
          child: Stack(
            children: [
              // Background
              Positioned.fill(child: _buildBackground()),

              // Content
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Obx(() {
                            final connected =
                                _callCtrl.callState.value == CallState.connected;
                            if (!connected) return const SizedBox();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF25D366).withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF25D366),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Connected',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Avatar
                    _buildAvatar(),

                    const SizedBox(height: 24),

                    // Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        widget.remoteName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Status / timer
                    _buildStatusText(),

                    const Spacer(flex: 3),

                    // Bottom frosted panel
                    _buildBottomPanel(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
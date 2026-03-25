import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomingCallOverlay {
  static OverlayEntry? _entry;

  static void show({
    required String callerName,
    required String callerId,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    hide();

    _entry = OverlayEntry(
      builder: (_) => _IncomingCallOverlayWidget(
        callerName: callerName,
        callerId: callerId,
        onAccept: () {
          hide();
          onAccept();
        },
        onDecline: () {
          hide();
          onDecline();
        },
      ),
    );

    // Get.overlayContext se overlay insert karo
    final ctx = Get.overlayContext;
    if (ctx != null) {
      Overlay.of(ctx).insert(_entry!);
      print('✅ IncomingCallOverlay shown for: $callerName');
    } else {
      print('❌ overlayContext null — cannot show overlay');
    }
  }

  // ── Hide karo ──────────────────────────────────────────
  static void hide() {
    try {
      _entry?.remove();
    } catch (_) {}
    _entry = null;
    print('✅ IncomingCallOverlay hidden');
  }

  static bool get isShowing => _entry != null;
}

// ── Overlay Widget ─────────────────────────────────────
class _IncomingCallOverlayWidget extends StatefulWidget {
  final String callerName;
  final String callerId;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _IncomingCallOverlayWidget({
    required this.callerName,
    required this.callerId,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_IncomingCallOverlayWidget> createState() =>
      _IncomingCallOverlayWidgetState();
}

class _IncomingCallOverlayWidgetState
    extends State<_IncomingCallOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            alignment: Alignment.topCenter,
            child: _buildCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4F46E5).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.callerName.isNotEmpty
                      ? widget.callerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Name + label ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _PulsingDot(),
                      const SizedBox(width: 6),
                      const Text(
                        'Incoming voice call',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ── Decline button ──
            _CallButton(
              icon: Icons.call_end_rounded,
              color: const Color(0xFFEF4444),
              onTap: widget.onDecline,
              tooltip: 'Decline',
            ),

            const SizedBox(width: 10),

            // ── Accept button ──
            _CallButton(
              icon: Icons.call_rounded,
              color: const Color(0xFF22C55E),
              onTap: widget.onAccept,
              tooltip: 'Accept',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable call action button ────────────────────────
class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ── Pulsing green dot ──────────────────────────────────
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
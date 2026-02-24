import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
import 'package:templink/Resume_Builder/Screens/Resume_Form_Screen.dart';

class AppColors {
  static const primary = Color(0xffB1843D);
  static const bg = Color(0xFFF8F9FA);
  static const cardBg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF1F3F4);
  static const border = Color(0xFFE0E0E0);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textMuted = Color(0xFF9E9E9E);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

class TemplateInfo {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final List<String> tags;
  final Color accent;

  const TemplateInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tags,
    required this.accent,
  });
}

const List<TemplateInfo> kTemplates = [
  TemplateInfo(
    id: 'olivia',
    title: 'Classic Elegant',
    subtitle: 'Two-column · Light theme',
    description:
        'A timeless professional design with sidebar layout. Perfect for corporate and traditional roles.',
    tags: ['Corporate', 'Classic', 'Light'],
    accent: Color(0xFFF0B429),
  ),
  TemplateInfo(
    id: 'austin',
    title: 'Bold Modern',
    subtitle: 'Sidebar right · Dark theme',
    description:
        'High-impact dark design for sales, tech and creative professionals who want to stand out.',
    tags: ['Modern', 'Bold', 'Dark'],
    accent: Color(0xFF6C63FF),
  ),
  TemplateInfo(
    id: 'nova',
    title: 'Nova Minimal',
    subtitle: 'Single-column · Ultra clean',
    description:
        'Sleek white layout with teal accents. Ideal for designers, developers and minimalists.',
    tags: ['Minimal', 'Clean', 'Light'],
    accent: Color(0xFF00BFA6),
  ),
  TemplateInfo(
    id: 'ember',
    title: 'Ember Creative',
    subtitle: 'Accent header · Warm tones',
    description:
        'Bold warm gradient header with clean body. Great for creatives, marketers and artists.',
    tags: ['Creative', 'Warm', 'Gradient'],
    accent: Color(0xFFFF6B35),
  ),
  TemplateInfo(
    id: 'slate',
    title: 'Slate Executive',
    subtitle: 'Navy sidebar · Premium look',
    description:
        'Deep navy and white — a powerful executive layout that commands authority and trust.',
    tags: ['Executive', 'Navy', 'Premium'],
    accent: Color(0xFF2563EB),
  ),
  TemplateInfo(
    id: 'rose',
    title: 'Rose Elegant',
    subtitle: 'Soft pink · Modern feminine',
    description:
        'Elegant rose-gold accents with a soft white body. Perfect for fashion, beauty and lifestyle roles.',
    tags: ['Elegant', 'Soft', 'Feminine'],
    accent: Color(0xFFE91E8C),
  ),
  TemplateInfo(
    id: 'ats_classic',
    title: 'ATS Classic',
    subtitle: 'Single-column · ATS Optimized',
    description:
        'Clean black & white layout with zero graphics. Maximum ATS compatibility for job portals like LinkedIn, Indeed and Workday.',
    tags: ['ATS', 'Simple', 'Classic'],
    accent: Color(0xFF2D2D2D),
  ),
  TemplateInfo(
    id: 'ats_modern',
    title: 'ATS Modern',
    subtitle: 'Subtle accent · ATS Safe',
    description:
        'Minimalist layout with a single thin blue accent line. Fully parseable by all ATS systems while still looking polished.',
    tags: ['ATS', 'Modern', 'Blue'],
    accent: Color(0xFF1A56DB),
  ),
  TemplateInfo(
    id: 'ats_executive',
    title: 'ATS Executive',
    subtitle: 'Structured · ATS Friendly',
    description:
        'Professional executive format with clear section dividers. Ideal for senior roles at top-tier companies.',
    tags: ['ATS', 'Executive', 'Pro'],
    accent: Color(0xFF166534),
  ),
];

bool _isDark(Color c) => c.computeLuminance() < 0.4;

// ============================================
// MAIN RESUME TEMPLATE SCREEN
// ============================================
class ResumeTemplate extends StatefulWidget {
  const ResumeTemplate({super.key});

  @override
  State<ResumeTemplate> createState() => _ResumeTemplateState();
}

class _ResumeTemplateState extends State<ResumeTemplate>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _openPreview(String id) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
            opacity: anim, child: _PreviewPage(id: id)),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.description_rounded,
                    color: AppColors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Resume Builder',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ]),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.tune_rounded,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Templates',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('${kTemplates.length} designs',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...kTemplates.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _TemplateCard(
                              info: e.value,
                              index: e.key,
                              onPreview: () => _openPreview(e.value.id),
                            ),
                          )),
                      _buildTipsBanner(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.primary.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20)),
            child: Text('✦  CHOOSE YOUR TEMPLATE',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 14),
          Text('Build a Resume\nthat gets noticed',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2)),
          const SizedBox(height: 10),
          Text(
              '9 professional designs for modern job seekers. Tap any template to preview.',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5)),
          const SizedBox(height: 18),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _chip(Icons.verified_rounded, '9 Templates'),
            _chip(Icons.smart_toy_rounded, '3 ATS-Ready'),
            _chip(Icons.bolt_rounded, 'Free'),
          ]),
        ]),
      );

  Widget _chip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppColors.primary, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _buildTipsBanner() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.lightbulb_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Pro Tip',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                    'Customize each template with your own information for the best results.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4)),
              ])),
        ]),
      );
}

// ============================================
// TEMPLATE CARD
// ============================================
class _TemplateCard extends StatefulWidget {
  final TemplateInfo info;
  final int index;
  final VoidCallback onPreview;

  const _TemplateCard({
    required this.info,
    required this.index,
    required this.onPreview,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _pressed = false;

  void _showConfirmationDialog(BuildContext context) {
    final controller = Get.put(ResumeController());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: widget.info.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.description_rounded,
                color: widget.info.accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Confirm Template',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.info.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.info.accent.withOpacity(0.3)),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.info.title,
                            style: TextStyle(
                                color: widget.info.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(widget.info.subtitle,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                      ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Text('Use this template to build your resume?',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 14)),
            const SizedBox(height: 6),
            const Text(
                'You will fill in all sections with your personal information.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: widget.info.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.info.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(tag,
                            style: TextStyle(
                                color: widget.info.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.setSelectedTemplate(
                  widget.info.id, widget.info.accent);
              Navigator.pop(context);
              Get.to(() => ResumeFormScreen(),
                  transition: Transition.rightToLeft);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.info.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continue',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    switch (widget.info.id) {
      case 'olivia':
        return _MiniOliviaPreview(accent: widget.info.accent);
      case 'austin':
        return _MiniAustinPreview(accent: widget.info.accent);
      case 'nova':
        return _MiniNovaPreview(accent: widget.info.accent);
      case 'ember':
        return _MiniEmberPreview(accent: widget.info.accent);
      case 'slate':
        return _MiniSlatePreview(accent: widget.info.accent);
      case 'rose':
        return _MiniRosePreview(accent: widget.info.accent);
      case 'ats_classic':
        return _MiniAtsClassicPreview(accent: widget.info.accent);
      case 'ats_modern':
        return _MiniAtsModernPreview(accent: widget.info.accent);
      case 'ats_executive':
        return _MiniAtsExecutivePreview(accent: widget.info.accent);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.info.accent;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _showConfirmationDialog(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color:
                    _pressed ? accent.withOpacity(0.5) : AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini preview
              Container(
                width: double.infinity,
                height: 200,
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Center(child: _buildPreview()),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        ...widget.info.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(tag,
                                  style: TextStyle(
                                      color: accent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            )),
                        if (widget.info.tags.contains('ATS'))
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14532D)
                                  .withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: const Color(0xFF16A34A)
                                      .withOpacity(0.5)),
                            ),
                            child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Color(0xFF16A34A), size: 10),
                                  SizedBox(width: 4),
                                  Text('ATS Optimized',
                                      style: TextStyle(
                                          color: Color(0xFF16A34A),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700)),
                                ]),
                          ),
                      ]),
                      const SizedBox(height: 10),
                      Text(widget.info.title,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(widget.info.subtitle,
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(widget.info.description,
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              height: 1.45)),
                      const SizedBox(height: 16),
                      // Buttons row
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onPreview,
                            icon: const Icon(
                                Icons.visibility_outlined,
                                size: 16),
                            label: const Text('Preview'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: accent,
                              side: BorderSide(
                                  color: accent.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showConfirmationDialog(context),
                            icon: const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Use Template',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ]),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// HELPER WIDGETS FOR MINI PREVIEWS
// ============================================
Widget _bar(double w, double h, Color c) => Container(
    width: w,
    height: h,
    decoration:
        BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)));

// ============================================
// MINI PREVIEW WIDGETS — COMPLETE DESIGNS
// ============================================

// OLIVIA — Classic Elegant (Dark sidebar left)
class _MiniOliviaPreview extends StatelessWidget {
  final Color accent;
  const _MiniOliviaPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(children: [
        // Sidebar
        Container(
          width: 68,
          color: const Color(0xFF2C2C2C),
          padding: const EdgeInsets.all(8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.3),
                        border: Border.all(color: accent, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 5),
                Center(child: _bar(40, 4, Colors.white)),
                const SizedBox(height: 2),
                Center(child: _bar(28, 2.5, accent)),
                const SizedBox(height: 8),
                _bar(20, 2, accent),
                const SizedBox(height: 4),
                _bar(50, 1.5, Colors.white30),
                const SizedBox(height: 3),
                _bar(45, 1.5, Colors.white30),
                const SizedBox(height: 3),
                _bar(38, 1.5, Colors.white30),
                const SizedBox(height: 8),
                _bar(28, 2, accent),
                const SizedBox(height: 4),
                _sbar(0.9, accent),
                const SizedBox(height: 3),
                _sbar(0.75, accent),
                const SizedBox(height: 3),
                _sbar(0.85, accent),
                const SizedBox(height: 8),
                _bar(28, 2, accent),
                const SizedBox(height: 4),
                _bar(48, 1.5, Colors.white30),
                const SizedBox(height: 3),
                _bar(38, 1.5, Colors.white30),
              ]),
        ),
        // Main
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(55, 2, accent),
                  const SizedBox(height: 2),
                  _bar(70, 3, const Color(0xFF222222)),
                  const SizedBox(height: 6),
                  _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
                  const SizedBox(height: 2),
                  _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
                  const SizedBox(height: 2),
                  _bar(80, 1.5, const Color(0xFFDDDDDD)),
                  const SizedBox(height: 8),
                  _bar(55, 2, accent),
                  const SizedBox(height: 4),
                  _wItem('Senior Manager', 'Google Inc.', '2021–Now', accent),
                  const SizedBox(height: 6),
                  _wItem('Marketing Lead', 'HubSpot', '2018–2021', accent),
                  const SizedBox(height: 8),
                  _bar(55, 2, accent),
                  const SizedBox(height: 4),
                  _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
                  const SizedBox(height: 2),
                  _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _sbar(double v, Color accent) => SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1.5),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 2.5,
            backgroundColor: const Color(0xFF444444),
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
      );

  Widget _wItem(String title, String co, String dates, Color accent) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bar(55, 2.5, const Color(0xFF333333)),
              _bar(22, 1.5, const Color(0xFFAAAAAA)),
            ]),
        const SizedBox(height: 2),
        _bar(38, 1.5, accent),
        const SizedBox(height: 3),
        _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
        const SizedBox(height: 1.5),
        _bar(75, 1.5, const Color(0xFFDDDDDD)),
      ]);
}

// AUSTIN — Bold Modern (Dark main, right sidebar)
class _MiniAustinPreview extends StatelessWidget {
  final Color accent;
  const _MiniAustinPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(children: [
        // Main dark area
        Expanded(
          child: Container(
            color: const Color(0xFF1C1C1E),
            padding: const EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(65, 5, Colors.white),
                  const SizedBox(height: 3),
                  _bar(45, 2.5, accent),
                  const SizedBox(height: 8),
                  Row(children: [
                    _bar(30, 2, accent),
                    const SizedBox(width: 5),
                    Expanded(
                        child: Container(
                            height: 1,
                            color: const Color(0xFF333333))),
                  ]),
                  const SizedBox(height: 5),
                  _bar(double.infinity, 1.5, const Color(0xFF333333)),
                  const SizedBox(height: 2),
                  _bar(double.infinity, 1.5, const Color(0xFF333333)),
                  const SizedBox(height: 2),
                  _bar(70, 1.5, const Color(0xFF333333)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _bar(32, 2, accent),
                    const SizedBox(width: 5),
                    Expanded(
                        child: Container(
                            height: 1,
                            color: const Color(0xFF333333))),
                  ]),
                  const SizedBox(height: 5),
                  _expRow('Sales Director', 'Salesforce', accent),
                  const SizedBox(height: 5),
                  _expRow('Sr. Manager', 'Oracle', accent),
                  const SizedBox(height: 8),
                  // Skills chips
                  Wrap(spacing: 3, runSpacing: 3, children: [
                    _chip('Strategy', accent),
                    _chip('Sales', accent),
                    _chip('Leadership', accent),
                  ]),
                ]),
          ),
        ),
        // Right sidebar
        Container(
          width: 60,
          color: const Color(0xFF111111),
          child: Column(children: [
            Container(
              width: double.infinity,
              color: accent,
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.3),
                            border: Border.all(
                                color: Colors.white, width: 1.5))),
                    const SizedBox(height: 5),
                    _bar(35, 3, Colors.white),
                    const SizedBox(height: 2),
                    _bar(25, 2, Colors.white60),
                  ]),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(25, 2, accent),
                    const SizedBox(height: 4),
                    _bar(45, 1.5, const Color(0xFF333333)),
                    const SizedBox(height: 2),
                    _bar(38, 1.5, const Color(0xFF333333)),
                    const SizedBox(height: 2),
                    _bar(42, 1.5, const Color(0xFF333333)),
                    const SizedBox(height: 8),
                    _bar(28, 2, accent),
                    const SizedBox(height: 4),
                    _bar(45, 1.5, const Color(0xFF333333)),
                    const SizedBox(height: 2),
                    _bar(32, 1.5, const Color(0xFF333333)),
                    const SizedBox(height: 8),
                    _bar(25, 2, accent),
                    const SizedBox(height: 4),
                    _bar(40, 1.5, const Color(0xFF333333)),
                    const SizedBox(height: 2),
                    _bar(35, 1.5, const Color(0xFF333333)),
                  ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _expRow(String role, String co, Color accent) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _bar(55, 2.5, Colors.white),
        const SizedBox(height: 2),
        _bar(38, 2, accent),
        const SizedBox(height: 2),
        _bar(double.infinity, 1.5, const Color(0xFF333333)),
      ]);

  Widget _chip(String label, Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
            border: Border.all(color: accent.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(fontSize: 6, color: accent.withOpacity(0.9))),
      );
}

// NOVA — Minimal single column
class _MiniNovaPreview extends StatelessWidget {
  final Color accent;
  const _MiniNovaPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 1.5)),
                    ),
                    const SizedBox(width: 8),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bar(65, 5, const Color(0xFF222222)),
                          const SizedBox(height: 3),
                          _bar(45, 3, accent),
                          const SizedBox(height: 3),
                          Row(children: [
                            _bar(25, 2, const Color(0xFFBBBBBB)),
                            const SizedBox(width: 4),
                            _bar(25, 2, const Color(0xFFBBBBBB)),
                            const SizedBox(width: 4),
                            _bar(20, 2, const Color(0xFFBBBBBB)),
                          ]),
                        ]),
                  ]),
              const SizedBox(height: 8),
              Container(height: 1.5, color: accent.withOpacity(0.3)),
              const SizedBox(height: 6),
              // Two columns
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main
                    Expanded(
                      flex: 6,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHead('PROFILE', accent),
                            _bar(double.infinity, 1.5,
                                const Color(0xFFDDDDDD)),
                            const SizedBox(height: 1.5),
                            _bar(double.infinity, 1.5,
                                const Color(0xFFDDDDDD)),
                            const SizedBox(height: 1.5),
                            _bar(70, 1.5, const Color(0xFFDDDDDD)),
                            const SizedBox(height: 6),
                            _sectionHead('EXPERIENCE', accent),
                            _novaExpItem('Lead Designer', 'Figma', accent),
                            const SizedBox(height: 5),
                            _novaExpItem('UX Designer', 'Google', accent),
                          ]),
                    ),
                    const SizedBox(width: 8),
                    // Sidebar
                    Expanded(
                      flex: 4,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHead('SKILLS', accent),
                            _skillTag('Figma', accent),
                            _skillTag('Flutter', accent),
                            _skillTag('UI Design', accent),
                            const SizedBox(height: 5),
                            _sectionHead('EDUCATION', accent),
                            _bar(50, 2.5,
                                const Color(0xFF333333)),
                            const SizedBox(height: 2),
                            _bar(45, 1.5, const Color(0xFFAAAAAA)),
                            const SizedBox(height: 2),
                            _bar(30, 1.5, accent),
                          ]),
                    ),
                  ]),
            ]),
      ),
    );
  }

  Widget _sectionHead(String t, Color accent) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Text(t,
            style: TextStyle(
                fontSize: 7,
                letterSpacing: 1.5,
                color: accent,
                fontWeight: FontWeight.w800)),
        const SizedBox(width: 4),
        Expanded(
            child: Container(height: 1, color: accent.withOpacity(0.2))),
      ]));

  Widget _novaExpItem(String role, String co, Color accent) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 5,
              height: 5,
              decoration:
                  BoxDecoration(color: accent, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          _bar(45, 2.5, const Color(0xFF333333)),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(30, 2, accent),
                const SizedBox(height: 2),
                _bar(55, 1.5, const Color(0xFFCCCCCC)),
              ]),
        ),
      ]);

  Widget _skillTag(String label, Color accent) => Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: accent.withOpacity(0.25))),
      child: Text(label,
          style: TextStyle(fontSize: 7, color: accent)));
}

// EMBER — Creative warm gradient header
class _MiniEmberPreview extends StatelessWidget {
  final Color accent;
  const _MiniEmberPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.white,
        child: Column(children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)),
            child: Row(children: [
              Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 1.5))),
              const SizedBox(width: 8),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bar(55, 5, Colors.white),
                    const SizedBox(height: 3),
                    _bar(38, 2.5, Colors.white70),
                    const SizedBox(height: 3),
                    Row(children: [
                      _bar(22, 2, Colors.white54),
                      const SizedBox(width: 4),
                      _bar(22, 2, Colors.white54),
                      const SizedBox(width: 4),
                      _bar(18, 2, Colors.white54),
                    ]),
                  ]),
            ]),
          ),
          // Body — two column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left main
                    Expanded(
                      flex: 6,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: accent.withOpacity(0.05),
                                    borderRadius:
                                        BorderRadius.circular(5),
                                    border: Border.all(
                                        color:
                                            accent.withOpacity(0.15))),
                                child: Column(children: [
                                  _bar(double.infinity, 1.5,
                                      const Color(0xFFCCCCCC)),
                                  const SizedBox(height: 2),
                                  _bar(double.infinity, 1.5,
                                      const Color(0xFFCCCCCC)),
                                ])),
                            const SizedBox(height: 6),
                            _emberSec('EXPERIENCE', accent),
                            _emberExp('Creative Director', 'Agency', accent),
                            const SizedBox(height: 4),
                            _emberExp('Art Director', 'Studio', accent),
                          ]),
                    ),
                    const SizedBox(width: 8),
                    // Right sidebar
                    Expanded(
                      flex: 4,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _emberSec('SKILLS', accent),
                            _skillBar('Design', 0.9, accent),
                            _skillBar('Branding', 0.8, accent),
                            _skillBar('Motion', 0.75, accent),
                            const SizedBox(height: 5),
                            _emberSec('EDUCATION', accent),
                            _bar(50, 2.5, const Color(0xFF333333)),
                            const SizedBox(height: 2),
                            _bar(40, 1.5, const Color(0xFFAAAAAA)),
                            const SizedBox(height: 2),
                            _bar(30, 1.5, accent),
                          ]),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emberSec(String t, Color accent) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Container(
            width: 2.5,
            height: 10,
            decoration: BoxDecoration(
                color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(t,
            style: TextStyle(
                fontSize: 7,
                letterSpacing: 1,
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w800)),
        const SizedBox(width: 4),
        Expanded(
            child:
                Container(height: 1, color: const Color(0xFFEEEEEE))),
      ]));

  Widget _emberExp(String role, String co, Color accent) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _bar(50, 2.5, const Color(0xFF333333)),
            const SizedBox(height: 2),
            _bar(32, 2, accent),
            const SizedBox(height: 2),
            _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
          ]));

  Widget _skillBar(String label, double v, Color accent) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 7, color: Color(0xFF555555))),
            const SizedBox(height: 2),
            ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                    value: v,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFEEEEEE),
                    valueColor: AlwaysStoppedAnimation(accent))),
          ]));
}

// SLATE — Executive navy sidebar
class _MiniSlatePreview extends StatelessWidget {
  final Color accent;
  const _MiniSlatePreview({required this.accent});

  static const _navyDark = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(children: [
        // Navy sidebar
        Container(
          width: 62,
          color: _navyDark,
          padding: const EdgeInsets.all(7),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border:
                            Border.all(color: Colors.white, width: 1.5))),
                const SizedBox(height: 5),
                _bar(40, 3.5, Colors.white),
                const SizedBox(height: 2),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(3)),
                    child: Text('CEO',
                        style: const TextStyle(
                            fontSize: 6,
                            color: Colors.white,
                            fontWeight: FontWeight.w700))),
                const SizedBox(height: 8),
                _bar(30, 2, const Color(0xFF93B8F5)),
                const SizedBox(height: 4),
                _bar(45, 1.5, Colors.white30),
                const SizedBox(height: 2),
                _bar(38, 1.5, Colors.white30),
                const SizedBox(height: 2),
                _bar(42, 1.5, Colors.white30),
                const SizedBox(height: 7),
                _bar(30, 2, const Color(0xFF93B8F5)),
                const SizedBox(height: 4),
                _navalSkill(0.9),
                _navalSkill(0.8),
                _navalSkill(0.85),
                const SizedBox(height: 7),
                _bar(30, 2, const Color(0xFF93B8F5)),
                const SizedBox(height: 4),
                _bar(48, 2.5, Colors.white),
                const SizedBox(height: 2),
                _bar(38, 1.5, Colors.white54),
                const SizedBox(height: 2),
                _bar(30, 1.5, const Color(0xFF93B8F5)),
              ]),
        ),
        // Main content
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary box
                  Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: accent.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: accent.withOpacity(0.1))),
                      child: Column(children: [
                        _bar(double.infinity, 1.5,
                            const Color(0xFFCCCCCC)),
                        const SizedBox(height: 2),
                        _bar(double.infinity, 1.5,
                            const Color(0xFFCCCCCC)),
                        const SizedBox(height: 2),
                        _bar(70, 1.5, const Color(0xFFCCCCCC)),
                      ])),
                  const SizedBox(height: 8),
                  _slateSec('EXPERIENCE', accent),
                  _slateJob('Chief Executive Officer', 'TechCorp', accent),
                  const SizedBox(height: 5),
                  _slateJob('Vice President', 'MegaCorp', accent),
                  const SizedBox(height: 8),
                  _slateSec('ACHIEVEMENTS', accent),
                  _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
                  const SizedBox(height: 2),
                  _bar(80, 1.5, const Color(0xFFDDDDDD)),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _navalSkill(double v) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(1.5),
          child: LinearProgressIndicator(
              value: v,
              minHeight: 2.5,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFF93B8F5)))));

  Widget _slateSec(String t, Color accent) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Text(t,
            style: const TextStyle(
                fontSize: 7.5,
                letterSpacing: 1.5,
                color: Color(0xFF1E3A5F),
                fontWeight: FontWeight.w800)),
        const SizedBox(width: 5),
        Expanded(
            child: Container(height: 1.5, color: accent.withOpacity(0.2))),
      ]));

  Widget _slateJob(String role, String co, Color accent) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _bar(60, 2.5, const Color(0xFF333333)),
        const SizedBox(height: 2),
        _bar(38, 2, accent),
        const SizedBox(height: 2),
        _bar(double.infinity, 1.5, const Color(0xFFDDDDDD)),
        const SizedBox(height: 1.5),
        _bar(80, 1.5, const Color(0xFFDDDDDD)),
      ]);
}

// ROSE — Elegant feminine gradient header
class _MiniRosePreview extends StatelessWidget {
  final Color accent;
  const _MiniRosePreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: const Color(0xFFFFF8FA),
        child: Column(children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [accent, const Color(0xFFFF85C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                          border:
                              Border.all(color: Colors.white, width: 2))),
                  const SizedBox(height: 4),
                  _bar(55, 5, Colors.white),
                  const SizedBox(height: 2),
                  _bar(38, 2.5, Colors.white70),
                  const SizedBox(height: 3),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _bar(25, 2, Colors.white54),
                        const SizedBox(width: 5),
                        _bar(30, 2, Colors.white54),
                        const SizedBox(width: 5),
                        _bar(22, 2, Colors.white54),
                      ]),
                ]),
          ),
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main left
                    Expanded(
                      flex: 6,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _roseSec('ABOUT ME', accent),
                            _bar(double.infinity, 1.5,
                                const Color(0xFFEEEEEE)),
                            const SizedBox(height: 1.5),
                            _bar(double.infinity, 1.5,
                                const Color(0xFFEEEEEE)),
                            const SizedBox(height: 1.5),
                            _bar(65, 1.5, const Color(0xFFEEEEEE)),
                            const SizedBox(height: 6),
                            _roseSec('EXPERIENCE', accent),
                            _roseExp(
                                'Fashion Director', 'Vogue', accent),
                            const SizedBox(height: 5),
                            _roseExp('Art Director', 'Elle', accent),
                          ]),
                    ),
                    const SizedBox(width: 8),
                    // Right
                    Expanded(
                      flex: 4,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _roseSec('SKILLS', accent),
                            _roseSkill('Styling', 0.95, accent),
                            _roseSkill('Branding', 0.85, accent),
                            _roseSkill('Direction', 0.90, accent),
                            const SizedBox(height: 5),
                            _roseSec('EDUCATION', accent),
                            _bar(48, 2.5, const Color(0xFF444444)),
                            const SizedBox(height: 2),
                            _bar(38, 1.5, const Color(0xFFAAAAAA)),
                            const SizedBox(height: 2),
                            _bar(28, 1.5, accent),
                            const SizedBox(height: 5),
                            _roseSec('LANGUAGES', accent),
                            _bar(45, 1.5, const Color(0xFFCCCCCC)),
                            const SizedBox(height: 2),
                            _bar(38, 1.5, const Color(0xFFCCCCCC)),
                          ]),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _roseSec(String t, Color accent) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Container(
            width: 2.5,
            height: 10,
            decoration: BoxDecoration(
                color: accent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(t,
            style: const TextStyle(
                fontSize: 7,
                letterSpacing: 1,
                color: Color(0xFF444444),
                fontWeight: FontWeight.w800)),
        const SizedBox(width: 4),
        Expanded(
            child:
                Container(height: 1, color: const Color(0xFFE8E8E8))),
      ]));

  Widget _roseExp(String role, String co, Color accent) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _bar(50, 2.5, const Color(0xFF333333)),
            const SizedBox(height: 2),
            _bar(30, 2, accent),
            const SizedBox(height: 2),
            _bar(double.infinity, 1.5, const Color(0xFFEEEEEE)),
          ]));

  Widget _roseSkill(String label, double v, Color accent) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 7, color: Color(0xFF555555))),
            const SizedBox(height: 2),
            ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                    value: v,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFFFD6EC),
                    valueColor: AlwaysStoppedAnimation(accent))),
          ]));
}

// ATS CLASSIC — Clean B&W
class _MiniAtsClassicPreview extends StatelessWidget {
  final Color accent;
  const _MiniAtsClassicPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centered header
              Center(
                  child: Column(children: [
                _bar(85, 5, const Color(0xFF111111)),
                const SizedBox(height: 3),
                _bar(60, 3, const Color(0xFF555555)),
                const SizedBox(height: 3),
                _bar(100, 2, const Color(0xFFBBBBBB)),
              ])),
              const SizedBox(height: 8),
              Container(height: 1.5, color: const Color(0xFF111111)),
              const SizedBox(height: 6),
              _atsSec('PROFESSIONAL SUMMARY'),
              _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
              const SizedBox(height: 2),
              _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
              const SizedBox(height: 2),
              _bar(80, 1.5, const Color(0xFFCCCCCC)),
              const SizedBox(height: 7),
              _atsSec('WORK EXPERIENCE'),
              _atsJob('Senior Software Engineer', 'Meta', '2021–Present'),
              const SizedBox(height: 5),
              _atsJob('Software Engineer', 'Google', '2018–2021'),
              const SizedBox(height: 7),
              _atsSec('SKILLS'),
              _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
              const SizedBox(height: 7),
              _atsSec('EDUCATION'),
              _atsJob('M.Sc Computer Science', 'MIT', '2016–2018'),
            ]),
      ),
    );
  }

  Widget _atsSec(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111111),
                letterSpacing: 1)),
        Container(
            height: 1,
            color: const Color(0xFF444444),
            margin: const EdgeInsets.only(top: 2)),
      ]));

  Widget _atsJob(String title, String co, String dates) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bar(65, 2.5, const Color(0xFF111111)),
                  _bar(28, 2, const Color(0xFF777777)),
                ]),
            const SizedBox(height: 1.5),
            _bar(38, 2, const Color(0xFF555555)),
            const SizedBox(height: 2),
            _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
            const SizedBox(height: 1.5),
            _bar(80, 1.5, const Color(0xFFCCCCCC)),
          ]));
}

// ATS MODERN — Blue accent line
class _MiniAtsModernPreview extends StatelessWidget {
  final Color accent;
  const _MiniAtsModernPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: IntrinsicHeight(
        child: Row(children: [
          Container(width: 4, color: accent),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _bar(75, 5, const Color(0xFF111111)),
                                const SizedBox(height: 3),
                                _bar(50, 3, accent),
                              ]),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _bar(35, 2, const Color(0xFFAAAAAA)),
                                const SizedBox(height: 2),
                                _bar(40, 2, const Color(0xFFAAAAAA)),
                                const SizedBox(height: 2),
                                _bar(30, 2, const Color(0xFFAAAAAA)),
                              ]),
                        ]),
                    const SizedBox(height: 8),
                    Container(height: 1.5, color: accent.withOpacity(0.3)),
                    const SizedBox(height: 7),
                    _atsSec2('SUMMARY', accent),
                    _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
                    const SizedBox(height: 2),
                    _bar(80, 1.5, const Color(0xFFCCCCCC)),
                    const SizedBox(height: 7),
                    _atsSec2('EXPERIENCE', accent),
                    _modernJob(
                        'Product Manager', 'Notion', '2021–Present', accent),
                    const SizedBox(height: 5),
                    _modernJob('Analyst', 'McKinsey', '2018–2021', accent),
                    const SizedBox(height: 7),
                    _atsSec2('SKILLS', accent),
                    _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
                    const SizedBox(height: 7),
                    _atsSec2('EDUCATION', accent),
                    _modernJob('MBA', 'Stanford GSB', '2014–2016', accent),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _atsSec2(String t, Color accent) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Text(t,
            style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111111),
                letterSpacing: 1)),
        const SizedBox(width: 6),
        Expanded(
            child: Container(height: 1.5, color: accent.withOpacity(0.3))),
      ]));

  Widget _modernJob(
          String title, String co, String dates, Color accent) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bar(60, 2.5, const Color(0xFF111111)),
                  _bar(28, 2, const Color(0xFF777777)),
                ]),
            const SizedBox(height: 1.5),
            _bar(38, 2, accent),
            const SizedBox(height: 2),
            _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
          ]));
}

// ATS EXECUTIVE — Green accents, structured
class _MiniAtsExecutivePreview extends StatelessWidget {
  final Color accent;
  const _MiniAtsExecutivePreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bar(80, 5, const Color(0xFF111111)),
                        const SizedBox(height: 3),
                        _bar(55, 3, accent),
                      ]),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(38, 2, const Color(0xFFAAAAAA)),
                      const SizedBox(height: 2),
                      _bar(42, 2, const Color(0xFFAAAAAA)),
                      const SizedBox(height: 2),
                      _bar(32, 2, const Color(0xFFAAAAAA)),
                    ]),
              ]),
              const SizedBox(height: 7),
              Container(height: 2, color: accent),
              const SizedBox(height: 7),
              _execSec('EXECUTIVE PROFILE', accent),
              Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: accent.withOpacity(0.04),
                      border: Border.all(color: accent.withOpacity(0.15))),
                  child: Column(children: [
                    _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
                    const SizedBox(height: 2),
                    _bar(75, 1.5, const Color(0xFFCCCCCC)),
                  ])),
              const SizedBox(height: 7),
              _execSec('EXPERIENCE', accent),
              _execJob(
                  'Chief Financial Officer', 'Goldman Sachs', accent),
              const SizedBox(height: 5),
              _execJob('VP Finance', 'JPMorgan', accent),
              const SizedBox(height: 7),
              _execSec('EDUCATION', accent),
              _execJob('MBA Finance', 'Wharton', accent),
              const SizedBox(height: 7),
              _execSec('SKILLS', accent),
              _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
            ]),
      ),
    );
  }

  Widget _execSec(String t, Color accent) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                color: accent,
                letterSpacing: 1)),
        Container(
            height: 1,
            color: accent.withOpacity(0.4),
            margin: const EdgeInsets.only(top: 2)),
      ]));

  Widget _execJob(String title, String co, Color accent) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bar(60, 2.5, const Color(0xFF111111)),
                  _bar(28, 2, const Color(0xFF777777)),
                ]),
            const SizedBox(height: 1.5),
            _bar(38, 2, accent),
            const SizedBox(height: 2),
            _bar(double.infinity, 1.5, const Color(0xFFCCCCCC)),
            const SizedBox(height: 1.5),
            Row(children: [
              Text('◆ ',
                  style: TextStyle(fontSize: 6, color: accent)),
              _bar(60, 1.5, const Color(0xFFCCCCCC)),
            ]),
          ]));
}

// ============================================
// PREVIEW PAGE
// ============================================
class _PreviewPage extends StatelessWidget {
  final String id;
  const _PreviewPage({required this.id});

  String get _title => kTemplates.firstWhere((t) => t.id == id).title;

  Widget _buildResume() {
    switch (id) {
      case 'olivia':
        return const _OliviaResume();
      case 'austin':
        return const _AustinResume();
      case 'nova':
        return const _NovaResume();
      case 'ember':
        return const _EmberResume();
      case 'slate':
        return const _SlateResume();
      case 'rose':
        return const _RoseResume();
      case 'ats_classic':
        return const _AtsClassicResume();
      case 'ats_modern':
        return const _AtsModernResume();
      case 'ats_executive':
        return const _AtsExecutiveResume();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = kTemplates.firstWhere((t) => t.id == id);
    final accent = template.accent;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border)),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 16),
          ),
        ),
        title: Text(_title,
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                final ctrl = Get.put(ResumeController());
                ctrl.setSelectedTemplate(id, accent);
                Navigator.pop(context);
                Get.to(() => ResumeFormScreen(),
                    transition: Transition.rightToLeft);
              },
              icon: const Icon(Icons.edit_rounded,
                  size: 16, color: Colors.white),
              label: const Text('Use This',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border)),
          child: Row(children: [
            const Icon(Icons.zoom_in_rounded,
                color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            const Expanded(
                child: Text('Pinch to zoom · Scroll to see full resume',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12))),
            Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('Live',
                style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(
            child: InteractiveViewer(
          minScale: 0.3,
          maxScale: 4.0,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildResume()),
          ),
        )),
      ]),
    );
  }
}

// ============================================
// COMPLETE PREVIEW TEMPLATES — SAMPLE DATA
// ============================================

// Shared helper
Widget _rBullet(String text, {Color dotColor = const Color(0xFF666666)}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            margin: const EdgeInsets.only(top: 4, right: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
                color: dotColor, shape: BoxShape.circle)),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF555555),
                    height: 1.5))),
      ]),
    );

// ─────────────────────────────────────────────
// OLIVIA RESUME (Classic Elegant) — FULL
// ─────────────────────────────────────────────
class _OliviaResume extends StatelessWidget {
  const _OliviaResume();
  static const _gold = Color(0xFFF0B429);
  static const _dark = Color(0xFF2C2C2C);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Sidebar
          Container(
            width: 200,
            color: _dark,
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _gold.withOpacity(0.2),
                            border: Border.all(color: _gold, width: 2))),
                  ),
                  const SizedBox(height: 10),
                  const Text('OLIVIA WILSON',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2)),
                  const SizedBox(height: 4),
                  const Text('MARKETING MANAGER',
                      style: TextStyle(
                          fontSize: 7.5,
                          letterSpacing: 2,
                          color: Color(0xFFAAAAAA))),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFF3E3E3E)),
                  _sh('CONTACT'),
                  _ci('📞', '+1 234 567 8901'),
                  _ci('✉', 'olivia@email.com'),
                  _ci('🌐', 'linkedin.com/in/olivia'),
                  _ci('📍', 'New York, NY'),
                  _sh('EDUCATION'),
                  _edu('COLUMBIA UNIVERSITY', 'MBA Marketing', '2016–2018'),
                  _edu('NYU', 'BSc Business Admin', '2012–2016'),
                  _sh('SKILLS'),
                  _sb('Digital Marketing', 0.90),
                  _sb('Brand Strategy', 0.85),
                  _sb('Content Creation', 0.88),
                  _sb('Data Analytics', 0.80),
                  _sb('SEO / SEM', 0.82),
                  _sh('LANGUAGES'),
                  _li('English – Native'),
                  _li('Spanish – Fluent'),
                  _li('French – Conversational'),
                  _sh('CERTIFICATIONS'),
                  _li('Google Analytics Certified'),
                  _li('HubSpot Marketing Pro'),
                ]),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _st('PROFESSIONAL SUMMARY'),
                    const Text(
                        'Experienced Marketing Manager with 8+ years developing and executing comprehensive marketing strategies. Proven track record of growing brand awareness by 200%+, leading high-performing teams of 10+ and managing multi-million dollar budgets with measurable ROI across digital and traditional channels.',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF555555),
                            height: 1.65)),
                    _st('WORK EXPERIENCE'),
                    _wi('Senior Marketing Manager', 'Google Inc.', '2021–Present',
                        [
                          'Led a cross-functional team of 12 across brand, digital and content verticals',
                          'Grew organic traffic by 140% through integrated SEO and content campaigns',
                          'Managed \$4.2M annual marketing budget with 35% cost efficiency improvement',
                          'Launched 4 major product campaigns reaching 50M+ impressions globally',
                        ]),
                    _wi('Marketing Manager', 'HubSpot', '2018–2021', [
                      'Developed go-to-market strategy for 3 product launches achieving 120% of sales targets',
                      'Increased email open rates by 45% through A/B testing and personalization',
                      'Built and scaled social media presence from 20K to 250K followers',
                    ]),
                    _wi('Digital Marketing Lead', 'Startup Hub', '2016–2018', [
                      'Established the digital marketing department from scratch',
                      'Delivered 300% ROI on paid advertising campaigns',
                    ]),
                    _st('KEY ACHIEVEMENTS'),
                    _rBullet('Increased company revenue by \$12M through strategic marketing initiatives', dotColor: _gold),
                    _rBullet('Won "Marketing Campaign of the Year" at Digital Excellence Awards 2022', dotColor: _gold),
                    _rBullet('Speaker at MarTech Summit 2023 on AI-driven personalization strategies', dotColor: _gold),
                  ]),
            ),
          ),
        ]),
      );

  static Widget _sh(String t) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(t,
          style: const TextStyle(
              fontSize: 8,
              letterSpacing: 2,
              color: _gold,
              fontWeight: FontWeight.w700)));

  static Widget _ci(String icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 9)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 8, color: Color(0xFFBBBBBB)))),
      ]));

  static Widget _edu(String s, String d, String y) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s,
            style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(d,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFAAAAAA))),
        Text(y,
            style: const TextStyle(fontSize: 7, color: Color(0xFF888888))),
      ]));

  static Widget _sb(String label, double v) => Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 7.5, color: Color(0xFFCCCCCC)))),
          Text('${(v * 100).toInt()}%',
              style: const TextStyle(
                  fontSize: 7.5, color: Color(0xFFCCCCCC))),
        ]),
        const SizedBox(height: 3),
        ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
                value: v,
                minHeight: 3,
                backgroundColor: const Color(0xFF444444),
                valueColor: const AlwaysStoppedAnimation<Color>(_gold))),
      ]));

  static Widget _li(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Text('• ',
            style: TextStyle(fontSize: 8, color: _gold)),
        Expanded(
            child: Text(t,
                style: const TextStyle(
                    fontSize: 8, color: Color(0xFFCCCCCC)))),
      ]));

  static Widget _st(String t) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: const TextStyle(
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
                color: _dark)),
        Container(
            height: 2, color: _gold, margin: const EdgeInsets.only(top: 3)),
      ]));

  static Widget _wi(
          String title, String co, String period, List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: _dark))),
                      Text(period,
                          style: const TextStyle(
                              fontSize: 7.5, color: Color(0xFF999999))),
                    ]),
                Text(co,
                    style: const TextStyle(
                        fontSize: 8,
                        color: _gold,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                ...bullets.map((b) => _rBullet(b)),
              ]));
}

// ─────────────────────────────────────────────
// AUSTIN RESUME (Bold Modern) — FULL
// ─────────────────────────────────────────────
class _AustinResume extends StatelessWidget {
  const _AustinResume();
  static const _accent = Color(0xFF6C63FF);
  static const _mainBg = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Main Content
          Expanded(
            child: Container(
              color: _mainBg,
              padding: const EdgeInsets.all(22),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AUSTIN BRONSON',
                        style: TextStyle(
                            fontSize: 22,
                            letterSpacing: 2,
                            color: Colors.white,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    const Text('SALES DIRECTOR',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFAAAAAA),
                            letterSpacing: 3)),
                    const Divider(color: Color(0xFF333333), height: 24),
                    _st('SUMMARY'),
                    const Text(
                        'Results-oriented Sales Director with 10+ years driving revenue growth, building elite sales teams and creating scalable pipeline strategies for Fortune 500 technology companies. Expert in enterprise sales cycles, C-suite relationship building and cross-functional alignment.',
                        style: TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFFAAAAAA),
                            height: 1.65)),
                    _st('EXPERIENCE'),
                    _exp('Sales Director', 'Salesforce', 'San Francisco', '2021–Present', [
                      'Lead enterprise sales team of 25 professionals across 3 regions',
                      'Exceeded revenue targets by 42% for 3 consecutive years',
                      'Closed 4 landmark deals worth \$18M+ in ARR',
                      'Implemented new CRM workflow reducing sales cycle by 30%',
                    ]),
                    _exp('Senior Sales Manager', 'Oracle', 'New York', '2017–2021', [
                      'Grew territory revenue from \$4M to \$18M in 4 years',
                      'Built and mentored high-performing team of 12 AEs',
                      'Achieved President\'s Club recognition 3 years running',
                    ]),
                    _exp('Sales Manager', 'SAP', 'Chicago', '2014–2017', [
                      'Managed key accounts generating \$6M annual revenue',
                      'Developed partner channel generating \$2M incremental ARR',
                    ]),
                    _st('SKILLS'),
                    Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          'Enterprise Sales', 'Sales Strategy', 'Team Leadership',
                          'CRM Systems', 'Negotiation', 'Pipeline Management',
                          'Salesforce CRM', 'Revenue Operations'
                        ]
                            .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF333333)),
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                child: Text(s,
                                    style: const TextStyle(
                                        fontSize: 7.5,
                                        color: Color(0xFFCCCCCC)))))
                            .toList()),
                  ]),
            ),
          ),
          // Right Sidebar
          Container(
            width: 165,
            color: const Color(0xFF111111),
            child: Column(children: [
              Container(
                width: double.infinity,
                color: _accent,
                padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
                child: const Column(children: [
                  Text('AUSTIN\nBRONSON',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.1)),
                  SizedBox(height: 6),
                  Text('SALES DIRECTOR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 7,
                          color: Colors.white70,
                          letterSpacing: 1.5)),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ss('CONTACT'),
                        _sc('📞', '+1 456 789 0123'),
                        _sc('✉', 'austin@email.com'),
                        _sc('🌐', 'linkedin.com/austin'),
                        _sc('📍', 'San Francisco, CA'),
                        _ss('EDUCATION'),
                        _se('MBA', 'Stanford GSB', '2012–2014'),
                        _se('BS Business', 'UC Berkeley', '2008–2012'),
                        _ss('AWARDS'),
                        _si('President\'s Club 2021–23'),
                        _si('Top Performer Q1 2022'),
                        _si('Sales Excellence Award'),
                        _ss('LANGUAGES'),
                        _lang('English', 'Native'),
                        _lang('Spanish', 'Fluent'),
                        _ss('TOOLS'),
                        _si('Salesforce CRM'),
                        _si('HubSpot'),
                        _si('Tableau'),
                        _si('Gong.io'),
                      ]),
                ),
              ),
            ]),
          ),
        ]),
      );

  static Widget _st(String t) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(children: [
        Text(t,
            style: const TextStyle(
                fontSize: 8.5,
                letterSpacing: 3,
                color: _accent,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Expanded(
            child:
                Container(height: 1, color: const Color(0xFF333333))),
      ]));

  static Widget _exp(String role, String co, String loc, String dates,
          List<String> b) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dates,
                    style: const TextStyle(
                        fontSize: 7.5, color: Color(0xFF666666))),
                Text(role,
                    style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                Text('$co  ·  $loc',
                    style:
                        const TextStyle(fontSize: 8, color: _accent)),
                const SizedBox(height: 5),
                ...b.map((x) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('▸ ',
                              style:
                                  TextStyle(fontSize: 8, color: _accent)),
                          Expanded(
                              child: Text(x,
                                  style: const TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFF888888),
                                      height: 1.5))),
                        ]))),
              ]));

  static Widget _ss(String t) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: const TextStyle(
                fontSize: 7.5,
                letterSpacing: 2,
                color: _accent,
                fontWeight: FontWeight.w700)),
        Container(
            height: 1,
            color: const Color(0xFF222222),
            margin: const EdgeInsets.only(top: 3)),
      ]));

  static Widget _sc(String i, String t) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Text(i, style: const TextStyle(fontSize: 9, color: _accent)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(t,
                style: const TextStyle(
                    fontSize: 7.5, color: Color(0xFFAAAAAA)))),
      ]));

  static Widget _se(String d, String s, String y) => Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d,
            style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(s,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFAAAAAA))),
        Text(y,
            style: const TextStyle(
                fontSize: 7, color: Color(0xFF666666))),
      ]));

  static Widget _si(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(t,
          style: const TextStyle(
              fontSize: 7.5, color: Color(0xFFAAAAAA), height: 1.5)));

  static Widget _lang(String l, String p) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l,
            style: const TextStyle(fontSize: 7.5, color: Colors.white)),
        Text(p,
            style: const TextStyle(fontSize: 7, color: _accent)),
      ]));
}

// ─────────────────────────────────────────────
// NOVA RESUME (Minimal) — FULL
// ─────────────────────────────────────────────
class _NovaResume extends StatelessWidget {
  const _NovaResume();
  static const _teal = Color(0xFF00BFA6);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(28),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: _teal.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: _teal, width: 2))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SARAH CHEN',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111111))),
                        const SizedBox(height: 4),
                        const Text('UX/UI Designer',
                            style: TextStyle(
                                fontSize: 11,
                                color: _teal,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Wrap(spacing: 10, children: [
                          _tag('📞 +1 628 555 1234'),
                          _tag('✉ sarah@design.io'),
                          _tag('📍 San Francisco, CA'),
                          _tag('🌐 portfolio.sarah.io'),
                        ]),
                      ]),
                ),
              ]),
              const SizedBox(height: 18),
              Container(height: 1.5, color: _teal.withOpacity(0.25)),
              const SizedBox(height: 16),
              // Two-column layout
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Main column
                Expanded(
                  flex: 6,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('PROFILE'),
                        const Text(
                            'Creative UX/UI designer with 7+ years crafting intuitive digital experiences for global tech companies. Passionate about turning complex problems into elegant, user-centered solutions through research-driven design processes.',
                            style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF555555),
                                height: 1.7)),
                        const SizedBox(height: 16),
                        _section('EXPERIENCE'),
                        _novaExp(
                            'Lead Product Designer', 'Figma Inc.', '2022–Present', [
                          'Redesigned core editor tools, increasing daily active usage by 38%',
                          'Led design system initiative adopted by 200+ internal teams',
                          'Mentored a team of 6 junior designers across 3 product lines',
                        ]),
                        _novaExp('Senior UX Designer', 'Airbnb', '2019–2022', [
                          'Owned end-to-end design for host onboarding flow, reducing drop-off by 52%',
                          'Conducted 80+ user interviews informing core product decisions',
                        ]),
                        _novaExp('UX Designer', 'Google', '2017–2019', [
                          'Contributed to Google Maps redesign reaching 1.5B users',
                        ]),
                        _section('EDUCATION'),
                        _novaExp(
                            'MFA Interaction Design', 'RISD', '2015–2017', []),
                        _novaExp('BA Graphic Design',
                            'UC Berkeley', '2011–2015', []),
                      ]),
                ),
                const SizedBox(width: 22),
                // Side column
                Expanded(
                  flex: 4,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('SKILLS'),
                        Wrap(spacing: 5, runSpacing: 5, children: [
                          'Figma', 'Sketch', 'Adobe XD',
                          'Prototyping', 'Design Systems',
                          'User Research', 'Wireframing',
                          'Flutter', 'CSS / HTML',
                        ].map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: _teal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: _teal.withOpacity(0.25))),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 7.5,
                                      color: Color(0xFF333333),
                                      fontWeight: FontWeight.w500))))
                            .toList()),
                        const SizedBox(height: 16),
                        _section('TOOLS'),
                        const Text(
                            'Figma, Notion, Jira, Miro, InVision, Principle, Zeplin',
                            style: TextStyle(
                                fontSize: 8.5,
                                color: Color(0xFF555555),
                                height: 1.7)),
                        const SizedBox(height: 16),
                        _section('LANGUAGES'),
                        _langRow('English', 'Native'),
                        _langRow('Mandarin', 'Fluent'),
                        _langRow('Japanese', 'Basic'),
                        const SizedBox(height: 16),
                        _section('AWARDS'),
                        _awardRow('Awwwards Site of the Day', '2023'),
                        _awardRow('UX Design Excellence Award', '2022'),
                        _awardRow('Featured in UX Planet', '2021'),
                      ]),
                ),
              ]),
            ]),
      );

  static Widget _section(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text(t,
            style: const TextStyle(
                fontSize: 9,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w800,
                color: _teal)),
        const SizedBox(width: 8),
        Expanded(
            child:
                Container(height: 1, color: _teal.withOpacity(0.2))),
      ]));

  static Widget _tag(String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: _teal.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6)),
      child: Text(t,
          style: const TextStyle(
              fontSize: 7.5, color: Color(0xFF444444))));

  static Widget _novaExp(
          String role, String co, String dates, List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: _teal, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Expanded(
                  child: Text(role,
                      style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222)))),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 13),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('$co  ',
                          style: const TextStyle(
                              fontSize: 8,
                              color: _teal,
                              fontWeight: FontWeight.w600)),
                      Text(dates,
                          style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFFAAAAAA))),
                    ]),
                    if (bullets.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      ...bullets.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('– ',
                                    style: TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFFAAAAAA))),
                                Expanded(
                                    child: Text(b,
                                        style: const TextStyle(
                                            fontSize: 8,
                                            color: Color(0xFF555555),
                                            height: 1.5))),
                              ]))),
                    ],
                  ]),
            ),
          ]));

  static Widget _langRow(String l, String p) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(
            child: Text(l,
                style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w600))),
        Text(p,
            style: const TextStyle(
                fontSize: 8, color: _teal)),
      ]));

  static Widget _awardRow(String name, String year) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        const Text('★ ',
            style: TextStyle(fontSize: 8, color: _teal)),
        Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 8, color: Color(0xFF555555)))),
        Text(year,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFAAAAAA))),
      ]));
}

// ─────────────────────────────────────────────
// EMBER RESUME (Creative) — FULL
// ─────────────────────────────────────────────
class _EmberResume extends StatelessWidget {
  const _EmberResume();
  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        child: Column(children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [_orange, _orange.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)),
            child: Row(children: [
              Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      border: Border.all(color: Colors.white, width: 2))),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MAYA RODRIGUEZ',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      const Text('Creative Director',
                          style: TextStyle(
                              fontSize: 11, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 10, runSpacing: 4, children: [
                        _hTag('📞 +1 310 555 7890'),
                        _hTag('✉ maya@creative.co'),
                        _hTag('📍 Los Angeles, CA'),
                        _hTag('🌐 mayaportfolio.com'),
                      ]),
                    ]),
              ),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: _orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _orange.withOpacity(0.15))),
                      child: const Text(
                          'Award-winning Creative Director with 10+ years shaping iconic brand identities for Fortune 500 companies. Expertise in multi-channel campaigns, team leadership and translating business objectives into breakthrough creative concepts.',
                          style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF444444),
                              height: 1.7))),
                  const SizedBox(height: 20),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left main
                        Expanded(
                          flex: 6,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sec('EXPERIENCE'),
                                _exp(
                                    'Creative Director',
                                    'Ogilvy & Mather',
                                    '2021–Present', [
                                  'Led 30-person creative department across 5 global markets',
                                  'Won 12 Cannes Lions awards for brand campaigns',
                                  'Increased client retention rate from 70% to 92%',
                                  'Managed creative budgets exceeding \$25M annually',
                                ]),
                                _exp('Associate Creative Director', 'BBDO', '2017–2021', [
                                  'Conceptualized Nike\'s "Move Forward" campaign reaching 500M impressions',
                                  'Directed 40+ TV commercials and digital campaigns',
                                ]),
                                _exp('Senior Designer', 'Pentagram', '2014–2017', [
                                  'Designed brand identities for 15+ major corporations',
                                ]),
                                _sec('KEY AWARDS'),
                                _award('Cannes Lions Gold', 'Brand Campaign', '2023'),
                                _award('D&AD Pencil', 'Digital Innovation', '2022'),
                                _award('Clio Award', 'Integrated Campaign', '2021'),
                              ]),
                        ),
                        const SizedBox(width: 22),
                        // Right sidebar
                        Expanded(
                          flex: 4,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sec('SKILLS'),
                                ...[
                                  ['Creative Direction', 0.95],
                                  ['Brand Strategy', 0.90],
                                  ['Art Direction', 0.92],
                                  ['Copywriting', 0.80],
                                  ['Motion Design', 0.78],
                                  ['UX Design', 0.75],
                                ].map((s) => _sbar(
                                    s[0] as String,
                                    s[1] as double)),
                                const SizedBox(height: 16),
                                _sec('EDUCATION'),
                                _edu('BFA Graphic Design',
                                    'Parsons School of Design', '2010–2014'),
                                _edu('Certificate',
                                    'Brand Strategy — IDEO', '2018'),
                                const SizedBox(height: 16),
                                _sec('LANGUAGES'),
                                _lang('English', 'Native'),
                                _lang('Spanish', 'Fluent'),
                                _lang('Portuguese', 'Basic'),
                                const SizedBox(height: 16),
                                _sec('TOOLS'),
                                const Text(
                                    'Adobe CC, Figma, Cinema 4D, Final Cut Pro, Midjourney',
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        color: Color(0xFF555555),
                                        height: 1.6)),
                              ]),
                        ),
                      ]),
                ]),
          ),
        ]),
      );

  static Widget _hTag(String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6)),
      child: Text(t,
          style: const TextStyle(fontSize: 7.5, color: Colors.white)));

  static Widget _sec(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: _orange, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 7),
        Text(t,
            style: const TextStyle(
                fontSize: 9.5,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222))),
        const SizedBox(width: 7),
        Expanded(
            child: Container(height: 1, color: const Color(0xFFEEEEEE))),
      ]));

  static Widget _exp(String role, String co, String dates,
          List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(role,
                              style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF222222)))),
                      Text(dates,
                          style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFF999999))),
                    ]),
                Text(co,
                    style: const TextStyle(
                        fontSize: 8,
                        color: _orange,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                ...bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('› ',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFFF9A70))),
                          Expanded(
                              child: Text(b,
                                  style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Color(0xFF555555),
                                      height: 1.5))),
                        ]))),
              ]));

  static Widget _award(String name, String cat, String year) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: _orange.withOpacity(0.6), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
            child: Text('$name – $cat',
                style: const TextStyle(
                    fontSize: 8.5, color: Color(0xFF444444)))),
        Text(year,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFAAAAAA))),
      ]));

  static Widget _sbar(String label, double v) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF444444),
                      fontWeight: FontWeight.w500)),
              Text('${(v * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 7.5, color: _orange)),
            ]),
        const SizedBox(height: 3),
        ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
                value: v,
                minHeight: 4,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(_orange))),
      ]));

  static Widget _edu(String d, String s, String y) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d,
            style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333))),
        Text(s,
            style: const TextStyle(
                fontSize: 8, color: Color(0xFF888888))),
        Text(y, style: const TextStyle(fontSize: 7.5, color: _orange)),
      ]));

  static Widget _lang(String l, String p) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(
            child: Text(l,
                style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF444444),
                    fontWeight: FontWeight.w600))),
        Text(p,
            style: const TextStyle(fontSize: 8, color: _orange)),
      ]));
}

// ─────────────────────────────────────────────
// SLATE RESUME (Executive) — FULL
// ─────────────────────────────────────────────
class _SlateResume extends StatelessWidget {
  const _SlateResume();
  static const _navy = Color(0xFF2563EB);
  static const _navyDark = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Navy sidebar
          Container(
            width: 200,
            color: _navyDark,
            padding: const EdgeInsets.all(22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border:
                                Border.all(color: Colors.white, width: 2))),
                  ),
                  const SizedBox(height: 12),
                  const Text('JAMES HARRINGTON',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2)),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: _navy,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('CHIEF EXECUTIVE OFFICER',
                            style: TextStyle(
                                fontSize: 6.5,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600))),
                  ),
                  const SizedBox(height: 16),
                  _sh('CONTACT'),
                  _ci('📞', '+1 212 555 9900'),
                  _ci('✉', 'james@corp.com'),
                  _ci('🌐', 'linkedin.com/james'),
                  _ci('📍', 'New York, NY'),
                  _sh('CORE EXPERTISE'),
                  _sbar('Strategic Leadership', 0.95),
                  _sbar('P&L Management', 0.92),
                  _sbar('M&A Strategy', 0.88),
                  _sbar('Global Operations', 0.90),
                  _sbar('Stakeholder Relations', 0.93),
                  _sh('EDUCATION'),
                  _edu('MBA, Strategy & Leadership', 'Harvard Business School', '2000–2002'),
                  _edu('BS Economics', 'University of Pennsylvania', '1994–1998'),
                  _sh('BOARD MEMBERSHIPS'),
                  _li('TechVenture Capital Advisory Board'),
                  _li('Stanford GSB Alumni Council'),
                  _li('World Economic Forum – Tech Panel'),
                  _sh('DESIGNATIONS'),
                  _li('Certified Director (ICD.D)'),
                  _li('CPA – Chartered Professional Accountant'),
                ]),
          ),
          // Main content
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(26),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Executive summary box
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: _navy.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _navy.withOpacity(0.12))),
                        child: const Text(
                            'Visionary CEO with 25+ years leading global enterprises across technology, finance and consumer goods sectors. Proven ability to drive transformational growth, build world-class executive teams and deliver sustained shareholder value. Managed organizations with revenues exceeding \$5B and 30,000+ employees.',
                            style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF444444),
                                height: 1.7))),
                    const SizedBox(height: 16),
                    _st('EXECUTIVE EXPERIENCE'),
                    _wi('Chief Executive Officer', 'TechCorp International', 'New York', '2018–Present', [
                      'Increased annual revenue from \$1.8B to \$4.2B through organic growth and acquisitions',
                      'Led successful IPO at \$12B valuation, returning 340% to early investors',
                      'Built and restructured leadership team of 25 C-suite executives globally',
                      'Executed 6 strategic acquisitions totaling \$2.1B in combined value',
                    ]),
                    _wi('President & COO', 'GlobalBridge Corp', 'Chicago', '2012–2018', [
                      'Transformed underperforming division into \$800M annual revenue business',
                      'Expanded operations to 18 new markets across Asia and Europe',
                    ]),
                    _wi('Senior Vice President', 'Fortune 500 Financial Co.', 'Boston', '2006–2012', [
                      'Oversaw \$2.5B portfolio of enterprise technology investments',
                    ]),
                    _st('KEY ACHIEVEMENTS'),
                    _rBullet('Named in Forbes "Top 50 CEOs to Watch" 2022 & 2023', dotColor: _navy),
                    _rBullet('Harvard Business School Alumni Leadership Award 2021', dotColor: _navy),
                    _rBullet('Delivered 18% CAGR to shareholders over 7-year tenure', dotColor: _navy),
                  ]),
            ),
          ),
        ]),
      );

  static Widget _sh(String t) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 7),
      child: Text(t.toUpperCase(),
          style: const TextStyle(
              fontSize: 7.5,
              letterSpacing: 2,
              color: Color(0xFF93B8F5),
              fontWeight: FontWeight.w700)));

  static Widget _ci(String i, String t) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Text(i, style: const TextStyle(fontSize: 9)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(t,
                style: const TextStyle(
                    fontSize: 8, color: Color(0xFFCCCCCC)))),
      ]));

  static Widget _sbar(String label, double v) => Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFBBBBBB))),
        const SizedBox(height: 3),
        ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
                value: v,
                minHeight: 3,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF93B8F5)))),
      ]));

  static Widget _edu(String d, String s, String y) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d,
            style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(s,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFAAAAAA))),
        Text(y,
            style: const TextStyle(
                fontSize: 7, color: Color(0xFF93B8F5))),
      ]));

  static Widget _li(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(right: 6, top: 1),
            decoration: const BoxDecoration(
                color: Color(0xFF93B8F5), shape: BoxShape.circle)),
        Expanded(
            child: Text(t,
                style: const TextStyle(
                    fontSize: 8, color: Color(0xFFCCCCCC)))),
      ]));

  static Widget _st(String t) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(children: [
        Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: _navyDark)),
        const SizedBox(width: 8),
        Expanded(
            child: Container(
                height: 2, color: _navy.withOpacity(0.2))),
      ]));

  static Widget _wi(String title, String co, String loc, String period,
          List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: _navyDark))),
                      Text(period,
                          style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFF999999))),
                    ]),
                Text('$co  ·  $loc',
                    style: const TextStyle(
                        fontSize: 8,
                        color: _navy,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                ...bullets.map((b) => _rBullet(b, dotColor: _navy)),
              ]));
}

// ─────────────────────────────────────────────
// ROSE RESUME (Elegant Feminine) — FULL
// ─────────────────────────────────────────────
class _RoseResume extends StatelessWidget {
  const _RoseResume();
  static const _rose = Color(0xFFE91E8C);
  static const _bg = Color(0xFFFFF8FA);

  @override
  Widget build(BuildContext context) => Container(
        color: _bg,
        child: Column(children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [_rose, const Color(0xFFFF85C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: Row(children: [
              Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      border: Border.all(color: Colors.white, width: 2))),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ISABELLA FONTAINE',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      const Text('Fashion Director',
                          style: TextStyle(
                              fontSize: 11, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 10, runSpacing: 4, children: [
                        _hTag('📞 +1 212 555 6789'),
                        _hTag('✉ isabella@fashion.co'),
                        _hTag('📍 Paris / New York'),
                        _hTag('🌐 isabellafontaine.com'),
                      ]),
                    ]),
              ),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main left
                  Expanded(
                    flex: 6,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sec('ABOUT ME'),
                          const Text(
                              'Visionary fashion director with 12+ years shaping the aesthetic identities of global luxury brands. Renowned for pioneering editorial concepts that blend art, culture and commerce. Collaborating with top-tier photographers, stylists and brands across 4 continents.',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF555555),
                                  height: 1.7)),
                          const SizedBox(height: 16),
                          _sec('EXPERIENCE'),
                          _exp('Fashion Director', 'Vogue Paris', '2021–Present', [
                            'Directed 120+ editorial shoots for global print and digital editions',
                            'Conceptualized brand partnerships generating \$8M in revenue',
                            'Collaborated with designers including Chanel, Dior and Valentino',
                            'Built and led creative team of 18 stylists and art directors',
                          ]),
                          _exp('Senior Fashion Editor', 'Harper\'s Bazaar', '2017–2021', [
                            'Oversaw creative direction for 8 annual cover campaigns',
                            'Styled global celebrities including A-list Hollywood talent',
                          ]),
                          _exp('Fashion Editor', 'Elle Magazine', '2014–2017', [
                            'Produced 60+ monthly fashion spreads across 12 markets',
                          ]),
                          _sec('ACHIEVEMENTS'),
                          _award('CFDA Fashion Award', 'Editorial Excellence', '2023'),
                          _award('British Fashion Award', 'Stylist of the Year', '2022'),
                          _award('Vogue 100 Most Influential', 'Fashion Figures', '2021'),
                        ]),
                  ),
                  const SizedBox(width: 22),
                  // Right
                  Expanded(
                    flex: 4,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sec('SKILLS'),
                          ...[
                            ['Fashion Direction', 0.97],
                            ['Styling', 0.95],
                            ['Brand Strategy', 0.88],
                            ['Photography Direction', 0.90],
                            ['Art Direction', 0.92],
                            ['Trend Forecasting', 0.85],
                          ].map((s) => _sbar(s[0] as String, s[1] as double)),
                          const SizedBox(height: 16),
                          _sec('EDUCATION'),
                          _edu('BA Fashion Design', 'Parsons, New York', '2010–2014'),
                          _edu('Diploma Styling', 'Institut Français de la Mode', '2014'),
                          const SizedBox(height: 16),
                          _sec('LANGUAGES'),
                          _lang('English', 'Native'),
                          _lang('French', 'Fluent'),
                          _lang('Italian', 'Conversational'),
                          const SizedBox(height: 16),
                          _sec('TOOLS'),
                          const Text(
                              'Adobe Creative Suite, Final Cut Pro, Capture One, Notion',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF666666),
                                  height: 1.6)),
                        ]),
                  ),
                ]),
          ),
        ]),
      );

  static Widget _hTag(String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6)),
      child: Text(t,
          style: const TextStyle(fontSize: 7.5, color: Colors.white)));

  static Widget _sec(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: _rose, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 7),
        Text(t,
            style: const TextStyle(
                fontSize: 9.5,
                letterSpacing: 2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF333333))),
        const SizedBox(width: 7),
        Expanded(
            child: Container(height: 1, color: const Color(0xFFE8E8E8))),
      ]));

  static Widget _exp(String role, String co, String dates,
          List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(role,
                              style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF222222)))),
                      Text(dates,
                          style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFFAAAAAA))),
                    ]),
                Text(co,
                    style: const TextStyle(
                        fontSize: 8,
                        color: _rose,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                ...bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('◦ ',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFFF85C2))),
                          Expanded(
                              child: Text(b,
                                  style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Color(0xFF555555),
                                      height: 1.5))),
                        ]))),
              ]));

  static Widget _award(String name, String cat, String year) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        const Text('★ ',
            style: TextStyle(fontSize: 8, color: _rose)),
        Expanded(
            child: Text('$name – $cat',
                style: const TextStyle(
                    fontSize: 8.5, color: Color(0xFF444444)))),
        Text(year,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFAAAAAA))),
      ]));

  static Widget _sbar(String label, double v) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500)),
          Text('${(v * 100).toInt()}%',
              style: const TextStyle(fontSize: 7.5, color: _rose)),
        ]),
        const SizedBox(height: 3),
        ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
                value: v,
                minHeight: 4,
                backgroundColor: const Color(0xFFFFD6EC),
                valueColor: const AlwaysStoppedAnimation<Color>(_rose))),
      ]));

  static Widget _edu(String d, String s, String y) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d,
            style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333))),
        Text(s,
            style: const TextStyle(
                fontSize: 8, color: Color(0xFF888888))),
        Text(y,
            style: const TextStyle(fontSize: 7.5, color: _rose)),
      ]));

  static Widget _lang(String l, String p) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(
            child: Text(l,
                style: const TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF444444),
                    fontWeight: FontWeight.w600))),
        Text(p, style: const TextStyle(fontSize: 8, color: _rose)),
      ]));
}

// ─────────────────────────────────────────────
// ATS CLASSIC RESUME — FULL
// ─────────────────────────────────────────────
class _AtsClassicResume extends StatelessWidget {
  const _AtsClassicResume();

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 36),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centered header
              Center(
                  child: Column(children: [
                const Text('MICHAEL THOMPSON',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111111))),
                const SizedBox(height: 5),
                const Text('Senior Software Engineer',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF444444),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                const Text(
                    '📞 +1 628 555 1234  ·  ✉ michael@engineer.io  ·  📍 Seattle, WA  ·  🌐 linkedin.com/michael',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 8.5, color: Color(0xFF555555))),
              ])),
              const SizedBox(height: 14),
              Container(height: 1.5, color: const Color(0xFF111111)),
              _sec('PROFESSIONAL SUMMARY'),
              const Text(
                  'Senior Software Engineer with 9+ years of experience designing, developing and scaling enterprise-grade applications. Expert in distributed systems architecture, cloud infrastructure and full-stack development. Proven track record of delivering high-performance solutions that serve millions of users globally.',
                  style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF333333),
                      height: 1.7)),
              _sec('WORK EXPERIENCE'),
              _job('Senior Software Engineer', 'Meta Platforms Inc.',
                  'Seattle, WA', 'Jan 2021 – Present', [
                'Architected a real-time data pipeline processing 2.4B events/day with 99.99% uptime',
                'Led migration of 14 legacy services to microservices, reducing system latency by 62%',
                'Mentored team of 8 engineers; 3 promoted to senior roles under guidance',
                'Reduced infrastructure costs by \$1.2M annually through optimization initiatives',
              ]),
              _job('Software Engineer II', 'Amazon Web Services',
                  'Seattle, WA', 'Mar 2018 – Dec 2020', [
                'Developed core features for AWS Lambda used by 500K+ developers worldwide',
                'Improved cold-start performance by 45% through runtime optimization',
                'Contributed 80+ PRs to open-source AWS SDKs with 12K+ GitHub stars',
              ]),
              _job('Software Engineer', 'Microsoft Corporation',
                  'Redmond, WA', 'Jul 2015 – Feb 2018', [
                'Built features for Azure DevOps used by 10M+ developers globally',
                'Designed and implemented CI/CD pipeline reducing deployment time from 4h to 20min',
              ]),
              _sec('SKILLS'),
              const Text(
                  'Python  ·  Go  ·  Java  ·  TypeScript  ·  Kubernetes  ·  Docker  ·  AWS  ·  GCP  ·  Terraform  ·  PostgreSQL  ·  Redis  ·  Kafka  ·  gRPC  ·  React  ·  System Design  ·  Distributed Systems',
                  style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF333333),
                      height: 1.7)),
              _sec('EDUCATION'),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('M.Sc Computer Science – Distributed Systems',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111))),
                          Text('Massachusetts Institute of Technology (MIT)',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF444444))),
                        ]),
                    const Text('2013 – 2015',
                        style: TextStyle(
                            fontSize: 8, color: Color(0xFF666666))),
                  ]),
              const SizedBox(height: 8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('B.Sc Computer Engineering',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111))),
                          Text('University of Washington',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF444444))),
                        ]),
                    const Text('2009 – 2013',
                        style: TextStyle(
                            fontSize: 8, color: Color(0xFF666666))),
                  ]),
              _sec('CERTIFICATIONS'),
              _cert('AWS Certified Solutions Architect – Professional', 'Amazon Web Services', '2023'),
              _cert('Google Professional Cloud Architect', 'Google Cloud', '2022'),
              _cert('Certified Kubernetes Administrator (CKA)', 'CNCF', '2021'),
            ]),
      );

  static Widget _sec(String t) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 7),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111111),
                letterSpacing: 1)),
        Container(
            height: 1,
            color: const Color(0xFF333333),
            margin: const EdgeInsets.only(top: 3)),
      ]));

  static Widget _job(String title, String company, String loc, String dates,
          List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111)))),
                      Text(dates,
                          style: const TextStyle(
                              fontSize: 8, color: Color(0xFF555555))),
                    ]),
                Text('$company  |  $loc',
                    style: const TextStyle(
                        fontSize: 8.5,
                        color: Color(0xFF444444))),
                const SizedBox(height: 5),
                ...bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  ',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF222222))),
                          Expanded(
                              child: Text(b,
                                  style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Color(0xFF333333),
                                      height: 1.55))),
                        ]))),
              ]));

  static Widget _cert(String name, String org, String year) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Text('•  ',
            style: TextStyle(fontSize: 8.5, color: Color(0xFF333333))),
        Expanded(
            child: Text('$name – $org',
                style: const TextStyle(
                    fontSize: 8.5, color: Color(0xFF333333)))),
        Text(year,
            style: const TextStyle(
                fontSize: 8, color: Color(0xFF777777))),
      ]));
}

// ─────────────────────────────────────────────
// ATS MODERN RESUME — FULL
// ─────────────────────────────────────────────
class _AtsModernResume extends StatelessWidget {
  const _AtsModernResume();
  static const _blue = Color(0xFF1A56DB);

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: _blue),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(28, 30, 30, 36),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('PRIYA NAIR',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF111111))),
                                SizedBox(height: 4),
                                Text('Product Manager',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _blue,
                                        fontWeight: FontWeight.w600)),
                              ]),
                          Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: const [
                                Text('+1 628 456 7890',
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        color: Color(0xFF555555))),
                                Text('priya@product.io',
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        color: Color(0xFF555555))),
                                Text('linkedin.com/priya',
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        color: Color(0xFF555555))),
                                Text('San Francisco, CA',
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        color: Color(0xFF555555))),
                              ]),
                        ]),
                    const SizedBox(height: 12),
                    Container(
                        height: 1.5, color: _blue.withOpacity(0.25)),
                    const SizedBox(height: 14),
                    _sec('SUMMARY'),
                    const Text(
                        'Strategic Product Manager with 8+ years of experience shipping B2B SaaS products used by millions. Expert in cross-functional leadership, data-driven product decisions and scaling products from 0 to 1 and 1 to N. Passionate about building products that solve real user problems at scale.',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF333333),
                            height: 1.7)),
                    _sec('EXPERIENCE'),
                    _job('Senior Product Manager', 'Notion Labs',
                        'San Francisco', 'Feb 2021 – Present', [
                      'Owned core editor product used by 30M+ users across 150 countries',
                      'Drove 48% increase in weekly active users through feature improvements',
                      'Led team of 8 engineers, 3 designers and 2 data scientists',
                      'Launched AI writing assistant generating \$12M in new ARR',
                    ]),
                    _job('Product Manager', 'Stripe Inc.',
                        'San Francisco', 'Aug 2018 – Jan 2021', [
                      'Owned Stripe Dashboard used by 2M+ businesses worldwide',
                      'Shipped 40+ features increasing merchant activation rate by 35%',
                      'Reduced payment failure rate by 12% through ML-driven routing',
                    ]),
                    _job('Associate PM', 'Google', 'Mountain View',
                        'Jul 2016 – Jul 2018', [
                      'Contributed to Google Pay launch in 5 new markets',
                    ]),
                    _sec('SKILLS'),
                    const Text(
                        'Product Strategy  ·  Roadmapping  ·  Agile / Scrum  ·  SQL  ·  A/B Testing  ·  User Research  ·  Figma  ·  JIRA  ·  Mixpanel  ·  Looker  ·  Go-to-Market  ·  OKRs',
                        style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF333333),
                            height: 1.7)),
                    _sec('EDUCATION'),
                    _eduSimple('MBA – Technology & Innovation',
                        'Stanford Graduate School of Business', '2014–2016'),
                    _eduSimple('B.Tech Computer Science',
                        'Indian Institute of Technology, Delhi', '2010–2014'),
                    _sec('CERTIFICATIONS'),
                    const Text(
                        '• Certified Scrum Product Owner (CSPO)  ·  2022\n• Google Project Management Certificate  ·  2021',
                        style: TextStyle(
                            fontSize: 8.5, color: Color(0xFF444444))),
                  ]),
            ),
          ),
        ]),
      );

  static Widget _sec(String t) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(children: [
        Text(t,
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111111),
                letterSpacing: 1)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Container(height: 1.5, color: _blue.withOpacity(0.3))),
      ]));

  static Widget _job(String title, String company, String loc,
          String dates, List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111)))),
                      Text(dates,
                          style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF666666))),
                    ]),
                Text('$company  |  $loc',
                    style: const TextStyle(
                        fontSize: 8.5,
                        color: _blue,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                ...bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('–  ',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF888888))),
                          Expanded(
                              child: Text(b,
                                  style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Color(0xFF333333),
                                      height: 1.55))),
                        ]))),
              ]));

  static Widget _eduSimple(
          String degree, String school, String dates) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(degree,
                          style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111))),
                      Text(school,
                          style: const TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFF555555))),
                    ])),
                Text(dates,
                    style: const TextStyle(
                        fontSize: 8, color: Color(0xFF777777))),
              ]));
}

// ─────────────────────────────────────────────
// ATS EXECUTIVE RESUME — FULL
// ─────────────────────────────────────────────
class _AtsExecutiveResume extends StatelessWidget {
  const _AtsExecutiveResume();
  static const _green = Color(0xFF166534);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 36),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DAVID PARK',
                                style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF111111))),
                            const SizedBox(height: 4),
                            const Text('Chief Financial Officer',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _green,
                                    fontWeight: FontWeight.w700)),
                          ]),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('📞 +1 646 555 2200',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF555555))),
                          Text('✉ david.park@finance.com',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF555555))),
                          Text('🌐 linkedin.com/davidpark',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF555555))),
                          Text('📍 New York, NY',
                              style: TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF555555))),
                        ]),
                  ]),
              const SizedBox(height: 10),
              Container(height: 2, color: _green),
              const SizedBox(height: 14),
              _sec('EXECUTIVE PROFILE'),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: _green.withOpacity(0.04),
                    border: Border.all(color: _green.withOpacity(0.15))),
                child: const Text(
                    'CFO with 18+ years of financial leadership across Fortune 100 companies in banking, technology and private equity. Expert in capital markets, M&A transactions, financial restructuring and investor relations. Track record of delivering \$2B+ in value creation through strategic financial initiatives.',
                    style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF333333),
                        height: 1.7)),
              ),
              _sec('EXPERIENCE'),
              _job('Chief Financial Officer', 'Goldman Sachs Group',
                  'New York, NY', '2018 – Present', [
                'Oversee \$420B AUM financial operations and 400-person finance organization',
                'Executed 6 strategic acquisitions totaling \$8.4B in combined enterprise value',
                'Led successful \$5B bond issuance at record-low 2.1% coupon rate',
                'Reduced operating costs by \$280M through restructuring and efficiency programs',
              ]),
              _job('Executive VP & CFO', 'JPMorgan Chase', 'New York, NY',
                  '2012 – 2018', [
                'Managed \$12B capital allocation across 8 business divisions globally',
                'Steered bank through successful stress test with tier 1 ratio of 13.2%',
                'Led \$3.2B divestiture of non-core assets improving ROE by 180 bps',
              ]),
              _job('Managing Director – Finance', 'Citigroup', 'New York, NY',
                  '2007 – 2012', [
                'Led financial planning for \$85B corporate banking portfolio',
                'Managed regulatory reporting for SEC, Fed and OCC requirements',
              ]),
              _sec('EDUCATION'),
              _eduSimple('MBA – Finance & Economics',
                  'Wharton School, University of Pennsylvania', '2007–2009'),
              _eduSimple('B.Sc Finance (Magna Cum Laude)',
                  'New York University, Stern School', '2001–2005'),
              _sec('SKILLS & COMPETENCIES'),
              const Text(
                  'Financial Strategy  ·  M&A and Divestitures  ·  Capital Markets  ·  Risk Management  ·  Investor Relations  ·  GAAP / IFRS  ·  SOX Compliance  ·  Financial Modeling  ·  Corporate Governance  ·  Private Equity',
                  style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF333333),
                      height: 1.7)),
              _sec('CERTIFICATIONS & DESIGNATIONS'),
              _cert('Chartered Financial Analyst (CFA)', 'CFA Institute', '2010'),
              _cert('Certified Public Accountant (CPA)', 'AICPA', '2007'),
              _cert('Financial Risk Manager (FRM)', 'GARP', '2009'),
              _sec('BOARD MEMBERSHIPS'),
              const Text(
                  '• Audit Committee Member, TechVenture Capital  ·  2020–Present\n• Finance Committee, Harvard Business School Alumni Board  ·  2019–Present\n• Advisory Board, FinTech Innovation Lab New York  ·  2021–Present',
                  style: TextStyle(
                      fontSize: 8.5,
                      color: Color(0xFF333333),
                      height: 1.7)),
            ]),
      );

  static Widget _sec(String t) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: _green,
                letterSpacing: 1.5)),
        Container(
            height: 1,
            color: _green.withOpacity(0.4),
            margin: const EdgeInsets.only(top: 3)),
      ]));

  static Widget _job(String title, String company, String loc,
          String dates, List<String> bullets) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111111)))),
                      Text(dates,
                          style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF666666))),
                    ]),
                Text('$company  |  $loc',
                    style: const TextStyle(
                        fontSize: 8.5,
                        color: _green,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                ...bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('◆  ',
                              style: TextStyle(
                                  fontSize: 7, color: _green)),
                          Expanded(
                              child: Text(b,
                                  style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Color(0xFF333333),
                                      height: 1.55))),
                        ]))),
              ]));

  static Widget _eduSimple(
          String degree, String school, String dates) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(degree,
                          style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111))),
                      Text(school,
                          style: const TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFF555555))),
                    ])),
                Text(dates,
                    style: const TextStyle(
                        fontSize: 8, color: Color(0xFF777777))),
              ]));

  static Widget _cert(String name, String org, String year) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Text('•  ',
            style: TextStyle(fontSize: 8.5, color: Color(0xFF444444))),
        Expanded(
            child: Text('$name – $org',
                style: const TextStyle(
                    fontSize: 8.5, color: Color(0xFF333333)))),
        Text(year,
            style: const TextStyle(
                fontSize: 8, color: Color(0xFF777777))),
      ]));
}
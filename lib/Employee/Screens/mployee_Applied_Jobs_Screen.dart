import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/job_apply_application_controller.dart';
import 'package:templink/Employee/Screens/employee_application_detail.dart';
import 'package:templink/Employee/models/job_application_model.dart';
import 'package:templink/Utils/colors.dart';

// ─── Design tokens (matches projects screen) ─────────────────────────────────
const _bg      = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border  = Color(0xFFE5E7EB);
const _text1   = Color(0xFF111827);
const _text2   = Color(0xFF6B7280);
const _text3   = Color(0xFF9CA3AF);
const _red     = Color(0xFFDC2626);
const _green   = Color(0xFF16A34A);
const _amber   = Color(0xFFD97706);
const _r       = 10.0;

class EmployeeAppliedJobsScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;
  final Function(EmployeeApplication)? onApplicationTap;

  final JobApplicationController controller =
      Get.put(JobApplicationController());

  EmployeeAppliedJobsScreen({
    super.key,
    this.onBackPressed,
    this.showSidebar = true,
    this.onApplicationTap,
  });

  static const _tabs = [
    _TabMeta('All',         'all',         Icons.layers_outlined),
    _TabMeta('Pending',     'pending',     Icons.hourglass_top_outlined),
    _TabMeta('Reviewed',    'reviewed',    Icons.visibility_outlined),
    _TabMeta('Shortlisted', 'shortlisted', Icons.star_outline_rounded),
    _TabMeta('Rejected',    'rejected',    Icons.do_not_disturb_alt_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Obx(() {
        // Loading
        if (controller.isLoadingApplications.value &&
            controller.myApplications.isEmpty) {
          return _LoadingList();
        }
        // Error
        if (controller.errorMessage.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refreshApplications,
          );
        }
        // Empty
        if (controller.myApplications.isEmpty) {
          return _EmptyState(onBrowse: () => Get.back());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshApplications,
          color: primary,
          displacement: 20,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Status filter bar ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() => _FilterBar(
                      tabs: _tabs,
                      selected: controller.selectedStatus.value,
                      onTap: controller.filterByStatus,
                      counts: _buildCounts(),
                    )),
              ),

              // ── Summary strip ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() => _SummaryStrip(
                      total: controller.myApplications.length,
                      filtered: controller.filteredApplications.length,
                      selected: controller.selectedStatus.value,
                    )),
              ),

              // ── List / empty-filter ────────────────────────────────────
              Obx(() {
                if (controller.filteredApplications.isEmpty) {
                  return SliverFillRemaining(
                    child: _NoFilterResult(
                      status: controller.selectedStatus.value,
                      onClear: () => controller.filterByStatus('all'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _ApplicationCard(
                        app: controller.filteredApplications[i],
                        controller: controller,
                        onTap: () {
                          if (onApplicationTap != null) {
                            onApplicationTap!(
                                controller.filteredApplications[i]);
                          } else {
                            Get.to(() => EmployeeApplicationDetailScreen(
                                application:
                                    controller.filteredApplications[i]));
                          }
                        },
                      ),
                      childCount: controller.filteredApplications.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      foregroundColor: _text1,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 17, color: _text2),
              onPressed: onBackPressed)
          : null,
      title: const Text(
        'Applied Jobs',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: _text1),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _border),
      ),
      actions: [
        Obx(() => IconButton(
              icon: AnimatedRotation(
                turns: controller.isLoadingApplications.value ? 1 : 0,
                duration: const Duration(milliseconds: 700),
                child: Icon(
                  Icons.refresh_outlined,
                  size: 20,
                  color: controller.isLoadingApplications.value
                      ? _text3
                      : _text2,
                ),
              ),
              onPressed: controller.isLoadingApplications.value
                  ? null
                  : controller.refreshApplications,
            )),
        const SizedBox(width: 4),
      ],
    );
  }

  // Build counts map for each tab badge
  Map<String, int> _buildCounts() {
    final all = controller.myApplications;
    return {
      'all':         all.length,
      'pending':     all.where((a) => a.status == 'pending').length,
      'reviewed':    all.where((a) => a.status == 'reviewed').length,
      'shortlisted': all.where((a) => a.status == 'shortlisted').length,
      'rejected':    all.where((a) => a.status == 'rejected').length,
    };
  }
}

// ─── Tab metadata ──────────────────────────────────────────────────────────────
class _TabMeta {
  final String label;
  final String value;
  final IconData icon;
  const _TabMeta(this.label, this.value, this.icon);
}

// ─── Filter Bar ───────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final List<_TabMeta> tabs;
  final String selected;
  final void Function(String) onTap;
  final Map<String, int> counts;

  const _FilterBar({
    required this.tabs,
    required this.selected,
    required this.onTap,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final tab   = tabs[i];
                final active = selected == tab.value;
                final count  = counts[tab.value] ?? 0;

                return GestureDetector(
                  onTap: () => onTap(tab.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 0),
                    decoration: BoxDecoration(
                      color: active ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab.icon,
                            size: 14,
                            color: active ? Colors.white : _text2),
                        const SizedBox(width: 6),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: active ? Colors.white : _text2,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withOpacity(0.25)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : _text2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: _border),
        ],
      ),
    );
  }
}

// ─── Summary strip ─────────────────────────────────────────────────────────────
class _SummaryStrip extends StatelessWidget {
  final int total;
  final int filtered;
  final String selected;

  const _SummaryStrip({
    required this.total,
    required this.filtered,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final label = selected == 'all'
        ? '$total application${total == 1 ? '' : 's'}'
        : '$filtered of $total';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _text1),
          ),
          const Spacer(),
          if (selected != 'all')
            Text(
              'showing ${selected[0].toUpperCase()}${selected.substring(1)}',
              style:
                  const TextStyle(fontSize: 12, color: _text3),
            ),
        ],
      ),
    );
  }
}

// ─── Application Card ─────────────────────────────────────────────────────────
class _ApplicationCard extends StatelessWidget {
  final EmployeeApplication app;
  final JobApplicationController controller;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.app,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = controller.getStatusColor(app.status);
    final statusIcon  = controller.getStatusIcon(app.status);
    final statusText  = controller.getStatusText(app.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_r + 2),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            // ── Main body ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Logo + Title + Status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CompanyLogo(app: app),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.jobSnapshot.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _text1,
                                  height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.business_outlined,
                                    size: 12, color: _text3),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    app.employerSnapshot.companyName,
                                    style: const TextStyle(
                                        fontSize: 12, color: _text2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: statusColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon,
                                size: 11, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Row 2: Location · Workplace · Type chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MetaChip(
                          icon: Icons.location_on_outlined,
                          label: app.jobSnapshot.location),
                      _MetaChip(
                          icon: Icons.work_outline,
                          label: app.jobSnapshot.workplace),
                      _TypeChip(label: app.jobSnapshot.type),
                    ],
                  ),
                ],
              ),
            ),

            // ── Footer bar ──────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(_r + 2)),
                border: Border(top: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  // Resume pill
                  _ResumePill(
                    ext: controller.getFileExtension(app.resumeFileName),
                  ),

                  const SizedBox(width: 10),

                  // Skills
                  Expanded(child: _SkillsRow(skills: app.employeeSnapshot.skills)),

                  const SizedBox(width: 10),

                  // Applied date
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 12, color: _text3),
                      const SizedBox(width: 4),
                      Text(
                        controller.formatDate(app.appliedAt),
                        style: const TextStyle(
                            fontSize: 11, color: _text2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Cover letter (if present) ───────────────────────────────
            if (app.coverLetter.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: const BoxDecoration(
                  border:
                      Border(top: BorderSide(color: _border)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded,
                        size: 14, color: primary.withOpacity(0.5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        app.coverLetter,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _text2,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Card sub-widgets ─────────────────────────────────────────────────────────
class _CompanyLogo extends StatelessWidget {
  final EmployeeApplication app;
  const _CompanyLogo({required this.app});

  @override
  Widget build(BuildContext context) {
    final initial = app.employerSnapshot.companyName.isNotEmpty
        ? app.employerSnapshot.companyName[0].toUpperCase()
        : 'C';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: app.employerSnapshot.logoUrl.isNotEmpty
          ? Image.network(
              app.employerSnapshot.logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Initials(initial: initial),
            )
          : _Initials(initial: initial),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initial;
  const _Initials({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _text3),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: _text2)),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: primary),
      ),
    );
  }
}

class _ResumePill extends StatelessWidget {
  final String ext;
  const _ResumePill({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 12, color: primary),
          const SizedBox(width: 4),
          Text('Resume',
              style: TextStyle(
                  fontSize: 11,
                  color: primary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              ext.toUpperCase(),
              style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsRow extends StatelessWidget {
  final List<String> skills;
  const _SkillsRow({required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return const Text('No skills listed',
          style: TextStyle(fontSize: 11, color: _text3));
    }
    final shown = skills.take(3).toList();
    final extra = skills.length - shown.length;

    return Row(
      children: [
        ...shown.map((s) => Container(
              margin: const EdgeInsets.only(right: 5),
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(s,
                  style: const TextStyle(
                      fontSize: 10,
                      color: _text2,
                      fontWeight: FontWeight.w500)),
            )),
        if (extra > 0)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('+$extra',
                style: const TextStyle(
                    fontSize: 10,
                    color: _text3,
                    fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}

// ─── Full-screen states ────────────────────────────────────────────────────────
class _LoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      itemCount: 5,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 110,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_r + 2),
          border: Border.all(color: _border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Shimmer(width: 44, height: 44, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Shimmer(width: double.infinity, height: 14, radius: 4),
                    const SizedBox(height: 8),
                    _Shimmer(width: 140, height: 11, radius: 4),
                    const SizedBox(height: 16),
                    Row(children: [
                      _Shimmer(width: 80, height: 22, radius: 5),
                      const SizedBox(width: 8),
                      _Shimmer(width: 80, height: 22, radius: 5),
                    ]),
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

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer(
      {required this.width, required this.height, required this.radius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 0.9).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
              const Color(0xFFE5E7EB), const Color(0xFFF3F4F6), _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wifi_off_outlined,
                  size: 28, color: _red),
            ),
            const SizedBox(height: 20),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _text1)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, color: _text2, height: 1.5),
            ),
            const SizedBox(height: 24),
            _ABtn(
                label: 'Try Again',
                icon: Icons.refresh_outlined,
                onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyState({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.inbox_outlined, size: 34, color: primary),
            ),
            const SizedBox(height: 20),
            const Text('No applications yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _text1)),
            const SizedBox(height: 8),
            const Text(
              "You haven't applied for any jobs yet.\nStart exploring and apply to your dream job!",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color: _text2, height: 1.6),
            ),
            const SizedBox(height: 24),
            _ABtn(
                label: 'Browse Jobs',
                icon: Icons.search_outlined,
                onTap: onBrowse),
          ],
        ),
      ),
    );
  }
}

class _NoFilterResult extends StatelessWidget {
  final String status;
  final VoidCallback onClear;
  const _NoFilterResult({required this.status, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.filter_alt_off_outlined, size: 36, color: _text3),
          const SizedBox(height: 14),
          Text(
            'No ${status[0].toUpperCase()}${status.substring(1)} applications',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: _text1),
          ),
          const SizedBox(height: 6),
          const Text('Try a different filter',
              style: TextStyle(fontSize: 13, color: _text2)),
          const SizedBox(height: 20),
          _ABtn(
              label: 'Clear filter',
              icon: Icons.clear_outlined,
              onTap: onClear,
              variant: _ABtnVariant.outlined),
        ],
      ),
    );
  }
}

// ─── _ABtn — shared action button ─────────────────────────────────────────────
enum _ABtnVariant { filled, outlined }

class _ABtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final _ABtnVariant variant;

  const _ABtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.variant = _ABtnVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == _ABtnVariant.filled;
    final bg  = isFilled ? primary : Colors.transparent;
    final fg  = isFilled ? Colors.white : primary;
    final bd  = isFilled
        ? Border.all(color: Colors.transparent)
        : Border.all(color: primary.withOpacity(0.4));

    return SizedBox(
      height: 40,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: fg.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: bd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 7),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
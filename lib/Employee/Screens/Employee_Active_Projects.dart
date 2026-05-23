// screens/employee/employee_projects_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/Employee_Active_Project_Controller.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects_Detail_Screen.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:intl/intl.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _bg      = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border  = Color(0xFFE5E7EB);
const _text1   = Color(0xFF111827);
const _text2   = Color(0xFF6B7280);
const _text3   = Color(0xFF9CA3AF);
const _accent  = Color(0xFF2563EB);  // professional blue
const _green   = Color(0xFF16A34A);
const _amber   = Color(0xFFD97706);
const _radius  = 10.0;

class EmployeeActiveProjectsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;
  final Function(String, EmployeeActiveProjectModel)? onProjectTap;

  const EmployeeActiveProjectsScreen({
    super.key,
    this.onBackPressed,
    this.showSidebar = true,
    this.onProjectTap,
  });

  @override
  State<EmployeeActiveProjectsScreen> createState() =>
      _EmployeeActiveProjectsScreenState();
}

class _EmployeeActiveProjectsScreenState
    extends State<EmployeeActiveProjectsScreen> {
  final searchController = TextEditingController();
  final controller = Get.put(EmployeeActiveProjectController());

  // view toggle: true = grid, false = table
  bool _gridView = true;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isWeb && !widget.showSidebar) {
      return Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _TopBar(
              controller: controller,
              showBack: widget.onBackPressed != null,
              onBack: widget.onBackPressed,
              gridView: _gridView,
              onToggleView: () => setState(() => _gridView = !_gridView),
              onSearch: () => _showSearchDialog(context),
            ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      );
    }

    if (isWeb) return _buildFullWebLayout(context);
    return _buildMobileLayout(context);
  }

  // ── Full web (with own sidebar) ──────────────────────────────────────────────
  Widget _buildFullWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  controller: controller,
                  showBack: false,
                  onBack: null,
                  gridView: _gridView,
                  onToggleView: () => setState(() => _gridView = !_gridView),
                  onSearch: () => _showSearchDialog(context),
                  showAvatar: true,
                ),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Web content area ─────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.projects.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: _accent));
      }
      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: _accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsRow(controller: controller),
              const SizedBox(height: 24),
              _SectionHeader(
                controller: controller,
                gridView: _gridView,
                onToggle: () => setState(() => _gridView = !_gridView),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.projects.isEmpty) return _EmptyState();
                return _gridView
                    ? _ProjectGrid(
                        projects: controller.projects,
                        onTap: _onProjectTap,
                      )
                    : _ProjectTable(
                        projects: controller.projects,
                        onTap: _onProjectTap,
                      );
              }),
            ],
          ),
        ),
      );
    });
  }

  void _onProjectTap(EmployeeActiveProjectModel project) {
    if (widget.onProjectTap != null) {
      widget.onProjectTap!(project.id, project);
    } else {
      Get.to(() => EmployeeProjectDetailsScreen(project: project));
    }
  }

  // ── Mobile ───────────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('My Projects',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: _surface,
        foregroundColor: _text1,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
        leading: widget.onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: widget.onBackPressed)
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => controller.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined, size: 20),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.projects.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: _accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _MobileStats(controller: controller)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Active Projects',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _text1)),
                      Obx(() => _Pill(
                          label: '${controller.projects.length} total')),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (controller.projects.isEmpty) {
                  return SliverFillRemaining(child: _EmptyState());
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _ProjectCard(
                        project: controller.projects[i],
                        onTap: _onProjectTap,
                        isWeb: false,
                      ),
                      childCount: controller.projects.length,
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

  void _showSearchDialog(BuildContext context) {
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    if (isWeb) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius + 4)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search projects',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _text1)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 14, color: _text1),
                    decoration: _inputDecoration('Search by title or employer…'),
                    onSubmitted: (q) {
                      Navigator.pop(context);
                      controller.searchProjects(q);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                      child: _AppButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        variant: _BtnVariant.outlined,
                        size: _BtnSize.md,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AppButton(
                        label: 'Search',
                        onPressed: () {
                          Navigator.pop(context);
                          controller.searchProjects(searchController.text);
                        },
                        variant: _BtnVariant.filled,
                        size: _BtnSize.md,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Search Projects',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _text1)),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: _text1),
              decoration:
                  _inputDecoration('Search by title or employer…'),
              onSubmitted: (q) {
                Navigator.pop(context);
                controller.searchProjects(q);
              },
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: _AppButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  variant: _BtnVariant.outlined,
                  size: _BtnSize.md,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AppButton(
                  label: 'Search',
                  onPressed: () {
                    Navigator.pop(context);
                    controller.searchProjects(searchController.text);
                  },
                  variant: _BtnVariant.filled,
                  size: _BtnSize.md,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final EmployeeActiveProjectController controller;
  final bool showBack;
  final bool showAvatar;
  final VoidCallback? onBack;
  final bool gridView;
  final VoidCallback onToggleView;
  final VoidCallback onSearch;

  const _TopBar({
    required this.controller,
    required this.showBack,
    required this.onBack,
    required this.gridView,
    required this.onToggleView,
    required this.onSearch,
    this.showAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: _text2),
                onPressed: onBack,
                style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero),
              ),
            ),
          const Text('Projects',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _text1)),
          const Spacer(),
          // view toggle
          _SegmentedToggle(
            gridView: gridView,
            onToggle: onToggleView,
          ),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.search_outlined, onTap: onSearch),
          _IconBtn(
              icon: Icons.refresh_outlined,
              onTap: () => controller.refreshData()),
          if (showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEFF6FF),
              child: const Icon(Icons.person_outline,
                  size: 17, color: _accent),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final bool gridView;
  final VoidCallback onToggle;
  const _SegmentedToggle({required this.gridView, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.grid_view_outlined,
            active: gridView,
            onTap: gridView ? null : onToggle,
          ),
          _ToggleBtn(
            icon: Icons.table_rows_outlined,
            active: !gridView,
            onTap: gridView ? onToggle : null,
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  const _ToggleBtn({required this.icon, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 26,
        decoration: BoxDecoration(
          color: active ? _surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ]
              : [],
        ),
        child: Icon(icon,
            size: 15, color: active ? _text1 : _text3),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 19, color: _text2),
      onPressed: onTap,
      style: IconButton.styleFrom(
          minimumSize: const Size(36, 36), padding: EdgeInsets.zero),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFEFF6FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 17,
                  color: active ? _accent : _text2),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? _accent : _text2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stats Row (compact, Next.js-style inline) ────────────────────────────────
class _StatsRow extends StatelessWidget {
  final EmployeeActiveProjectController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Active',
          valueObs: controller.activeProjects,
          icon: Icons.radio_button_checked_outlined,
          iconColor: _accent,
          bgColor: const Color(0xFFEFF6FF),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Completed',
          valueObs: controller.completedProjects,
          icon: Icons.check_circle_outline,
          iconColor: _green,
          bgColor: const Color(0xFFF0FDF4),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Total',
          valueObs: controller.totalProjects,
          icon: Icons.folder_outlined,
          iconColor: _amber,
          bgColor: const Color(0xFFFFFBEB),
        ),
        const SizedBox(width: 12),
        _EarningsCard(controller: controller),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final RxInt valueObs;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const _StatCard({
    required this.label,
    required this.valueObs,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _text2,
                        fontWeight: FontWeight.w500)),
                Obx(() => Text(
                      valueObs.value.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _text1,
                          height: 1.2),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final EmployeeActiveProjectController controller;
  const _EarningsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up_outlined,
                  size: 17, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Earnings',
                    style: TextStyle(
                        fontSize: 11,
                        color: _text2,
                        fontWeight: FontWeight.w500)),
                Obx(() => Text(
                      '\$${controller.totalEarnings.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _text1,
                          height: 1.2),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileStats extends StatelessWidget {
  final EmployeeActiveProjectController controller;
  const _MobileStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _MiniStat(
              label: 'Active',
              valueObs: controller.activeProjects,
              color: _accent),
          const SizedBox(width: 10),
          _MiniStat(
              label: 'Done',
              valueObs: controller.completedProjects,
              color: _green),
          const SizedBox(width: 10),
          _MiniStat(
              label: 'Total',
              valueObs: controller.totalProjects,
              color: _amber),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final RxInt valueObs;
  final Color color;
  const _MiniStat(
      {required this.label, required this.valueObs, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            Obx(() => Text(
                  valueObs.value.toString(),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: color),
                )),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: _text2)),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final EmployeeActiveProjectController controller;
  final bool gridView;
  final VoidCallback onToggle;
  const _SectionHeader(
      {required this.controller,
      required this.gridView,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Active Projects',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _text1)),
        const SizedBox(width: 10),
        Obx(() => _Pill(label: '${controller.projects.length}')),
        const Spacer(),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _text2)),
    );
  }
}

// ─── Project Grid ──────────────────────────────────────────────────────────────
class _ProjectGrid extends StatelessWidget {
  final List<EmployeeActiveProjectModel> projects;
  final void Function(EmployeeActiveProjectModel) onTap;
  const _ProjectGrid({required this.projects, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < projects.length; i += 2) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: _ProjectCard(
                  project: projects[i],
                  onTap: onTap,
                  isWeb: true)),
          const SizedBox(width: 16),
          i + 1 < projects.length
              ? Expanded(
                  child: _ProjectCard(
                      project: projects[i + 1],
                      onTap: onTap,
                      isWeb: true))
              : const Expanded(child: SizedBox()),
        ],
      ));
      if (i + 2 < projects.length) rows.add(const SizedBox(height: 14));
    }
    return Column(children: rows);
  }
}

// ─── Project Table ─────────────────────────────────────────────────────────────
class _ProjectTable extends StatelessWidget {
  final List<EmployeeActiveProjectModel> projects;
  final void Function(EmployeeActiveProjectModel) onTap;
  const _ProjectTable({required this.projects, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_radius)),
              border: Border(
                  bottom: BorderSide(color: _border, width: 1)),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: _TableHeader('Project')),
                Expanded(
                    flex: 2,
                    child: _TableHeader('Employer')),
                Expanded(
                    flex: 1,
                    child: _TableHeader('Category')),
                Expanded(
                    flex: 1,
                    child: _TableHeader('Budget')),
                Expanded(
                    flex: 2,
                    child: _TableHeader('Progress')),
                Expanded(
                    flex: 1,
                    child: _TableHeader('Status')),
                SizedBox(width: 80),
              ],
            ),
          ),

          // Table rows
          ...projects.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final fmt = NumberFormat.compactCurrency(symbol: '\$');

            return InkWell(
              onTap: () => onTap(p),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: i < projects.length - 1
                      ? const Border(
                          bottom: BorderSide(
                              color: _border, width: 1))
                      : null,
                  borderRadius: i == projects.length - 1
                      ? const BorderRadius.vertical(
                          bottom: Radius.circular(_radius))
                      : null,
                ),
                child: Row(
                  children: [
                    // Project name + logo
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _MiniLogo(project: p),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(p.title,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w500,
                                    color: _text1),
                                overflow:
                                    TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    // Employer
                    Expanded(
                      flex: 2,
                      child: Text(p.employerName,
                          style: const TextStyle(
                              fontSize: 12,
                              color: _text2),
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Category
                    Expanded(
                      flex: 1,
                      child: Text(p.category,
                          style: const TextStyle(
                              fontSize: 12,
                              color: _text2),
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Budget
                    Expanded(
                      flex: 1,
                      child: Text(
                          fmt.format(p.maxBudget),
                          style: const TextStyle(
                              fontSize: 12,
                              color: _text1,
                              fontWeight:
                                  FontWeight.w500)),
                    ),
                    // Progress bar
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${p.completedMilestones}/${p.totalMilestones}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _text2)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value:
                                  p.progressPercentage,
                              backgroundColor:
                                  const Color(0xFFF3F4F6),
                              valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                p.progressPercentage ==
                                        1.0
                                    ? _green
                                    : _accent,
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Expanded(
                      flex: 1,
                      child: _StatusBadge(project: p),
                    ),
                    // Action button
                    SizedBox(
                      width: 72,
                      child: _AppButton(
                        label: 'View →',
                        onPressed: () => onTap(p),
                        variant: _BtnVariant.ghost,
                        size: _BtnSize.sm,
                        labelColor: _accent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _text2,
            letterSpacing: 0.3));
  }
}

// ─── Project Card (grid / mobile) ─────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final EmployeeActiveProjectModel project;
  final void Function(EmployeeActiveProjectModel) onTap;
  final bool isWeb;
  const _ProjectCard(
      {required this.project,
      required this.onTap,
      required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.compactCurrency(symbol: '\$');

    return Container(
      margin: EdgeInsets.only(bottom: isWeb ? 0 : 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius + 2),
        border: Border.all(color: _border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(project),
          borderRadius: BorderRadius.circular(_radius + 2),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MiniLogo(project: project),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(project.title,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _text1),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(project.employerName,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _text2),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(project: project),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 12),

                // Meta row — compact inline tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MetaTag(
                        icon: Icons.category_outlined,
                        label: project.category),
                    _MetaTag(
                        icon: Icons.schedule_outlined,
                        label: project.duration),
                    _MetaTag(
                        icon: Icons.payments_outlined,
                        label: fmt.format(project.maxBudget)),
                  ],
                ),

                const SizedBox(height: 14),

                // Progress
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Progress',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _text2)),
                              Text(
                                '${(project.progressPercentage * 100).round()}%',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        project.progressPercentage ==
                                                1.0
                                            ? _green
                                            : _accent),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: project
                                  .progressPercentage,
                              backgroundColor:
                                  const Color(0xFFF3F4F6),
                              valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                project.progressPercentage ==
                                        1.0
                                    ? _green
                                    : _accent,
                              ),
                              minHeight: 5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${project.completedMilestones} of ${project.totalMilestones} milestones',
                            style: const TextStyle(
                                fontSize: 10, color: _text3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Next milestone (if present)
                if (project.nextMilestone != null) ...[
                  const SizedBox(height: 12),
                  _NextMilestoneBanner(project: project, fmt: fmt),
                ],

                const SizedBox(height: 14),

                // Action buttons — compact
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _AppButton(
                      label: 'Details',
                      onPressed: () => onTap(project),
                      variant: _BtnVariant.outlined,
                      size: _BtnSize.sm,
                    ),
                    if (project.nextMilestone?.isReady == true) ...[
                      const SizedBox(width: 8),
                      _AppButton(
                        label: 'Start Work',
                        onPressed: () => onTap(project),
                        variant: _BtnVariant.filled,
                        size: _BtnSize.sm,
                        fillColor: _green,
                        leadingIcon: Icons.play_arrow_outlined,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared small widgets ──────────────────────────────────────────────────────
class _MiniLogo extends StatelessWidget {
  final EmployeeActiveProjectModel project;
  const _MiniLogo({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        image: project.employerLogo != null
            ? DecorationImage(
                image: NetworkImage(project.employerLogo!),
                fit: BoxFit.cover)
            : null,
      ),
      child: project.employerLogo == null
          ? Center(
              child: Text(
                project.employerName.isNotEmpty
                    ? project.employerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _accent),
              ),
            )
          : null,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final EmployeeActiveProjectModel project;
  const _StatusBadge({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: project.statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: project.statusColor.withOpacity(0.25)),
      ),
      child: Text(
        project.statusText,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: project.statusColor),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: _text3),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: _text2)),
      ],
    );
  }
}

class _NextMilestoneBanner extends StatelessWidget {
  final EmployeeActiveProjectModel project;
  final NumberFormat fmt;
  const _NextMilestoneBanner(
      {required this.project, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final m = project.nextMilestone!;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(
            m.isReady
                ? Icons.play_circle_outline
                : Icons.lock_outline,
            size: 14,
            color: m.isReady ? _green : _text3,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Next: ${m.title}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _text1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(fmt.format(m.amount),
              style: const TextStyle(
                  fontSize: 11, color: _text2)),
          if (m.isReady) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Ready',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.folder_open_outlined,
                  size: 30, color: _text3),
            ),
            const SizedBox(height: 20),
            const Text('No active projects',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _text1)),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have any active projects.\nStart applying for jobs to get hired!',
              style: TextStyle(
                  fontSize: 13, color: _text2, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _AppButton(
              label: 'Browse Jobs',
              onPressed: () => Get.back(),
              variant: _BtnVariant.filled,
              size: _BtnSize.md,
              leadingIcon: Icons.search_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _AppButton — single consistent button widget ─────────────────────────────
//
//  variant:
//    'filled'   → solid background  (primary action)
//    'outlined' → border only       (secondary action)
//    'ghost'    → no border/bg      (table / inline actions)
//
//  size:
//    'md'  → height 36, fontSize 13  (dialogs, empty-state)
//    'sm'  → height 32, fontSize 12  (cards, table rows)

enum _BtnVariant { filled, outlined, ghost }
enum _BtnSize { md, sm }

class _AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final _BtnVariant variant;
  final _BtnSize size;
  final Color? fillColor;
  final Color? labelColor;
  final IconData? leadingIcon;

  const _AppButton({
    required this.label,
    required this.onPressed,
    this.variant = _BtnVariant.outlined,
    this.size = _BtnSize.sm,
    this.fillColor,
    this.labelColor,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final h      = size == _BtnSize.md ? 38.0 : 32.0;
    final hPad   = size == _BtnSize.md ? 18.0 : 14.0;
    final fSize  = size == _BtnSize.md ? 13.0 : 12.0;

    final Color bg = switch (variant) {
      _BtnVariant.filled   => fillColor ?? _accent,
      _BtnVariant.outlined => Colors.transparent,
      _BtnVariant.ghost    => Colors.transparent,
    };

    final Color fg = switch (variant) {
      _BtnVariant.filled   => labelColor ?? Colors.white,
      _BtnVariant.outlined => labelColor ?? _text1,
      _BtnVariant.ghost    => labelColor ?? _accent,
    };

    final Border border = switch (variant) {
      _BtnVariant.filled   => Border.all(color: Colors.transparent),
      _BtnVariant.outlined => Border.all(color: _border, width: 1),
      _BtnVariant.ghost    => Border.all(color: Colors.transparent),
    };

    return SizedBox(
      height: h,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          splashColor: fg.withOpacity(0.08),
          highlightColor: fg.withOpacity(0.04),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: border,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: fSize + 2, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fSize,
                    fontWeight: FontWeight.w500,
                    color: fg,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper builders ──────────────────────────────────────────────────────────
InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _text3),
      prefixIcon: const Icon(Icons.search, size: 16, color: _text3),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
    );
// screens/employer_project_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/Screens/Employer_Project_Milestone_Screen.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/colors.dart' as AppColors;
import 'package:templink/Utils/responsive.dart';
import 'package:intl/intl.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _bg      = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border  = Color(0xFFE5E7EB);
const _text1   = Color(0xFF111827);
const _text2   = Color(0xFF6B7280);
const _text3   = Color(0xFF9CA3AF);
const _accent  = Color(0xFF2563EB);
const _green   = Color(0xFF16A34A);
const _amber   = Color(0xFFD97706);
const _red     = Color(0xFFDC2626);
const _radius  = 12.0;

class EmployerProjectManagementScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;
    final Function(EmployerProject)? onProjectTap;  // ✅ ADD THIS


  const EmployerProjectManagementScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
        this.onProjectTap,  // ✅ ADD THIS

  }) : super(key: key);

  @override
  State<EmployerProjectManagementScreen> createState() => _EmployerProjectManagementScreenState();
}

class _EmployerProjectManagementScreenState extends State<EmployerProjectManagementScreen> {
  final EmployerProjectsController controller = Get.put(EmployerProjectsController());
  final TextEditingController searchController = TextEditingController();

  // view toggle: true = grid, false = table
  bool _gridView = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    controller.updateSearch(searchController.text);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

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
              searchController: searchController,
              showBack: widget.onBackPressed != null,
              onBack: widget.onBackPressed,
              gridView: _gridView,
              onToggleView: () => setState(() => _gridView = !_gridView),
              onSearch: () => _showSearchDialog(context),
              onFilter: () => _showFilterOptions(context),
            ),
            Expanded(child: _buildContent(context)),
          ],
        ),
      );
    }

    if (isWeb) return _buildFullWebLayout(context);
    return _buildMobileLayout(context);
  }

  // ── Full web layout ─────────────────────────────────────────────────────────
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
                  searchController: searchController,
                  showBack: false,
                  onBack: null,
                  gridView: _gridView,
                  onToggleView: () => setState(() => _gridView = !_gridView),
                  onSearch: () => _showSearchDialog(context),
                  onFilter: () => _showFilterOptions(context),
                  showAvatar: false,
                ),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Web content area ────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredProjects.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchMyProjectsWithProposals(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsRow(controller: controller),
              const SizedBox(height: 20),
              _SectionHeader(
                controller: controller,
                gridView: _gridView,
                onToggle: () => setState(() => _gridView = !_gridView),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.filteredProjects.isEmpty) return _EmptyState(hasSearch: controller.searchQuery.value.isNotEmpty);
                return _gridView
                    ? _ProjectGrid(projects: controller.filteredProjects, onTap: _onProjectTap)
                    : _ProjectTable(projects: controller.filteredProjects, onTap: _onProjectTap);
              }),
            ],
          ),
        ),
      );
    });
  }

 void _onProjectTap(EmployerProject project) {
  // Web layout mein sidebar ke liye
  if (Responsive.isDesktop(context) || Responsive.isTablet(context)) {
    // Yahan par aapko parent screen (EmployeerHomeScreen) ka navigation update karna hoga
    // Isliye callback use karna better hai
    widget.onProjectTap?.call(project);
  } else {
    // Mobile ke liye normal navigation
    Get.to(() => EmployerProjectDetailsScreen(project: project));
  }
}

  // ── Show Filter Options ─────────────────────────────────────────────────────
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: _surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 16),
            _buildFilterOption(context, 'All Projects', ''),
            const SizedBox(height: 8),
            _buildFilterOption(context, 'Open', 'OPEN'),
            const SizedBox(height: 8),
            _buildFilterOption(context, 'In Progress', 'IN_PROGRESS'),
            const SizedBox(height: 8),
            _buildFilterOption(context, 'Completed', 'COMPLETED'),
            const SizedBox(height: 8),
            _buildFilterOption(context, 'Cancelled', 'CANCELLED'),
            const SizedBox(height: 16),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _red),
                      foregroundColor: _red,
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, String value) {
    final isSelected = controller.filterStatus.value == value;
    return InkWell(
      onTap: () {
        controller.filterStatus.value = value;
        controller.filterProjects();
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ?      AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected ? AppColors.primary : _text3,
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, color: isSelected ? AppColors.primary : _text1)),
          ],
        ),
      ),
    );
  }

  // ── Show Search Dialog ──────────────────────────────────────────────────────
  void _showSearchDialog(BuildContext context) {
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    if (isWeb) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius + 4)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search projects',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text1)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 14, color: _text1),
                    decoration: _inputDecoration('Search by title or category…'),
                    onSubmitted: (q) {
                      Navigator.pop(context);
                      controller.updateSearch(q);
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
                          controller.updateSearch(searchController.text);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Search Projects',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text1)),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: _text1),
              decoration: _inputDecoration('Search by title or category…'),
              onSubmitted: (q) {
                Navigator.pop(context);
                controller.updateSearch(q);
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
                    controller.updateSearch(searchController.text);
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

  // ── Mobile Layout ───────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Project Management',
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
            onPressed: () => controller.fetchMyProjectsWithProposals(),
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined, size: 20),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined, size: 20),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.filteredProjects.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchMyProjectsWithProposals(),
          color: AppColors.primary,
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
                      const Text('Projects',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _text1)),
                      Obx(() => _Pill(label: '${controller.filteredProjects.length} total')),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (controller.filteredProjects.isEmpty) {
                  return SliverFillRemaining(child: _EmptyState(hasSearch: controller.searchQuery.value.isNotEmpty));
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _ProjectCard(
                        project: controller.filteredProjects[i],
                        onTap: _onProjectTap,
                        isWeb: false,
                      ),
                      childCount: controller.filteredProjects.length,
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
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final EmployerProjectsController controller;
  final TextEditingController searchController;
  final bool showBack;
  final bool showAvatar;
  final VoidCallback? onBack;
  final bool gridView;
  final VoidCallback onToggleView;
  final VoidCallback onSearch;
  final VoidCallback onFilter;

  const _TopBar({
    required this.controller,
    required this.searchController,
    required this.showBack,
    required this.onBack,
    required this.gridView,
    required this.onToggleView,
    required this.onSearch,
    required this.onFilter,
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
                icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: _text2),
                onPressed: onBack,
                style: IconButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero),
              ),
            ),
          const Text('Project Management',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _text1)),
          const Spacer(),
          _SearchField(controller: controller, searchController: searchController),
          const SizedBox(width: 8),
          _SegmentedToggle(gridView: gridView, onToggle: onToggleView),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.filter_list_outlined, onTap: onFilter),
          _IconBtn(icon: Icons.refresh_outlined, onTap: () => controller.fetchMyProjectsWithProposals()),
          if (showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEFF6FF),
              child: const Icon(Icons.business_outlined, size: 17, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final EmployerProjectsController controller;
  final TextEditingController searchController;
  const _SearchField({required this.controller, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.search, size: 16, color: _text3),
          ),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: controller.updateSearch,
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                hintStyle: TextStyle(fontSize: 12, color: _text3),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 14, color: _text3),
                  onPressed: () => controller.clearFilters(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : const SizedBox.shrink()),
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
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(icon: Icons.grid_view_outlined, active: gridView, onTap: gridView ? null : onToggle),
          _ToggleBtn(icon: Icons.table_rows_outlined, active: !gridView, onTap: gridView ? onToggle : null),
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
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))] : [],
        ),
        child: Icon(icon, size: 15, color: active ? _text1 : _text3),
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
      icon: Icon(icon, size: 18, color: _text2),
      onPressed: onTap,
      style: IconButton.styleFrom(minimumSize: const Size(32, 32), padding: EdgeInsets.zero),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final EmployerProjectsController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Total',
          value: controller.totalProjects.toString(),
          icon: Icons.folder_outlined,
          iconColor: AppColors.primary,
          bgColor: const Color(0xFFEFF6FF),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Active',
          value: controller.projects.where((p) => p.Status == 'IN_PROGRESS').length.toString(),
          icon: Icons.play_circle_outline,
          iconColor: _green,
          bgColor: const Color(0xFFF0FDF4),
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Completed',
          value: controller.projects.where((p) => p.Status == 'COMPLETED').length.toString(),
          icon: Icons.check_circle_outline,
          iconColor: _amber,
          bgColor: const Color(0xFFFFFBEB),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const _StatCard({
    required this.label,
    required this.value,
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
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _text2, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _text1, height: 1.2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileStats extends StatelessWidget {
  final EmployerProjectsController controller;
  const _MobileStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _MiniStat(label: 'Total', value: controller.totalProjects.toString(), color: AppColors.primary),
          const SizedBox(width: 10),
          _MiniStat(label: 'Active', value: controller.projects.where((p) => p.Status == 'IN_PROGRESS').length.toString(), color: _green),
          const SizedBox(width: 10),
          _MiniStat(label: 'Done', value: controller.projects.where((p) => p.Status == 'COMPLETED').length.toString(), color: _amber),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

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
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: _text2)),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final EmployerProjectsController controller;
  final bool gridView;
  final VoidCallback onToggle;
  const _SectionHeader({
    required this.controller,
    required this.gridView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('All Projects',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _text1)),
        const SizedBox(width: 10),
        Obx(() => _Pill(label: '${controller.filteredProjects.length}')),
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
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _text2)),
    );
  }
}

// ─── Project Grid ─────────────────────────────────────────────────────────────
class _ProjectGrid extends StatelessWidget {
  final List<EmployerProject> projects;
  final void Function(EmployerProject) onTap;
  const _ProjectGrid({required this.projects, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < projects.length; i += 2) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ProjectCard(project: projects[i], onTap: onTap, isWeb: true)),
          const SizedBox(width: 16),
          i + 1 < projects.length
              ? Expanded(child: _ProjectCard(project: projects[i + 1], onTap: onTap, isWeb: true))
              : const Expanded(child: SizedBox()),
        ],
      ));
      if (i + 2 < projects.length) rows.add(const SizedBox(height: 14));
    }
    return Column(children: rows);
  }
}

// ─── Project Table ────────────────────────────────────────────────────────────
class _ProjectTable extends StatelessWidget {
  final List<EmployerProject> projects;
  final void Function(EmployerProject) onTap;
  const _ProjectTable({required this.projects, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.compactCurrency(symbol: '\$');

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(_radius)),
              border: Border(bottom: BorderSide(color: _border, width: 1)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _TableHeader('Project')),
                Expanded(flex: 2, child: _TableHeader('Category')),
                Expanded(flex: 1, child: _TableHeader('Budget')),
                Expanded(flex: 1, child: _TableHeader('Proposals')),
                Expanded(flex: 1, child: _TableHeader('Status')),
                SizedBox(width: 80),
              ],
            ),
          ),
          ...projects.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final statusColor = _getStatusColor(p.Status);
            final statusText = _getStatusText(p.Status);

            return InkWell(
              onTap: () => onTap(p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: i < projects.length - 1 ? const Border(bottom: BorderSide(color: _border, width: 1)) : null,
                  borderRadius: i == projects.length - 1 ? const BorderRadius.vertical(bottom: Radius.circular(_radius)) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          _MiniLogo(project: p),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(p.title,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _text1),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(p.category,
                          style: const TextStyle(fontSize: 12, color: _text2),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(fmt.format(p.maxBudget),
                          style: const TextStyle(fontSize: 12, color: _text1, fontWeight: FontWeight.w500)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text('${p.proposalsCount}',
                          style: const TextStyle(fontSize: 12, color: _text2)),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.25)),
                        ),
                        child: Text(statusText,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: _AppButton(
                        label: 'View →',
                        onPressed: () => onTap(p),
                        variant: _BtnVariant.ghost,
                        size: _BtnSize.sm,
                        labelColor: AppColors.primary,
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
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _text2, letterSpacing: 0.3));
  }
}

// ─── Project Card ─────────────────────────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final EmployerProject project;
  final void Function(EmployerProject) onTap;
  final bool isWeb;
  const _ProjectCard({required this.project, required this.onTap, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.compactCurrency(symbol: '\$');
    final statusColor = _getStatusColor(project.Status);
    final statusText = _getStatusText(project.Status);

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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MiniLogo(project: project),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _text1),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(project.category,
                              style: const TextStyle(fontSize: 11, color: _text2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.25)),
                      ),
                      child: Text(statusText,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MetaTag(icon: Icons.attach_money, label: fmt.format(project.maxBudget)),
                    _MetaTag(icon: Icons.description_outlined, label: '${project.proposalsCount} proposals'),
                    _MetaTag(icon: Icons.calendar_today_outlined, label: project.displayDate),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: project.skills.take(3).map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(skill,
                        style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
                if (project.skills.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('+${project.skills.length - 3} more',
                        style: TextStyle(fontSize: 9, color: _text3)),
                  ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _AppButton(
                      label: 'Details',
                      onPressed: () => onTap(project),
                      variant: _BtnVariant.outlined,
                      size: _BtnSize.sm,
                    ),
                    if (project.Status == 'OPEN') ...[
                      const SizedBox(width: 8),
                      _AppButton(
                        label: 'View Proposals',
                        onPressed: () => onTap(project),
                        variant: _BtnVariant.filled,
                        size: _BtnSize.sm,
                      ),
                    ],
                    if (project.Status == 'IN_PROGRESS') ...[
                      const SizedBox(width: 8),
                      _AppButton(
                        label: 'Track',
                        onPressed: () => onTap(project),
                        variant: _BtnVariant.filled,
                        size: _BtnSize.sm,
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

class _MiniLogo extends StatelessWidget {
  final EmployerProject project;
  const _MiniLogo({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          project.title.isNotEmpty ? project.title[0].toUpperCase() : 'P',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
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
        Text(label, style: const TextStyle(fontSize: 11, color: _text2)),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

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
              child: Icon(hasSearch ? Icons.search_off_outlined : Icons.folder_open_outlined,
                  size: 30, color: _text3),
            ),
            const SizedBox(height: 20),
            Text(hasSearch ? 'No projects found' : 'No projects yet',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text1)),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try searching with different keywords'
                  : 'Create your first project to start receiving proposals',
              style: const TextStyle(fontSize: 13, color: _text2, height: 1.6),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              _AppButton(
                label: 'Create Project',
                onPressed: () {},
                variant: _BtnVariant.filled,
                size: _BtnSize.md,
                leadingIcon: Icons.add_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── _AppButton ───────────────────────────────────────────────────────────────
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
      _BtnVariant.filled   => fillColor ?? AppColors.primary,
      _BtnVariant.outlined => Colors.transparent,
      _BtnVariant.ghost    => Colors.transparent,
    };

    final Color fg = switch (variant) {
      _BtnVariant.filled   => labelColor ?? Colors.white,
      _BtnVariant.outlined => labelColor ?? _text1,
      _BtnVariant.ghost    => labelColor ?? AppColors.primary,
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

// ─── Helper functions ─────────────────────────────────────────────────────────
Color _getStatusColor(String status) {
  switch (status) {
    case 'OPEN': return Colors.green;
    case 'AWAITING_FUNDING': return Colors.orange;
    case 'IN_PROGRESS': return AppColors.primary;
    case 'COMPLETED': return Colors.purple;
    case 'CANCELLED': return Colors.red;
    default: return _text3;
  }
}

String _getStatusText(String status) {
  switch (status) {
    case 'OPEN': return 'Open';
    case 'AWAITING_FUNDING': return 'Awaiting Funding';
    case 'IN_PROGRESS': return 'In Progress';
    case 'COMPLETED': return 'Completed';
    case 'CANCELLED': return 'Cancelled';
    default: return status;
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _text3),
      prefixIcon: const Icon(Icons.search, size: 16, color: _text3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
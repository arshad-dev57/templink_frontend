import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Controllers/job_apply_application_controller.dart';
import 'package:templink/Employee/models/job_application_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/config/api_config.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────────
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

class EmployeeApplicationDetailScreen extends StatelessWidget {
  final EmployeeApplication application;
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  final JobApplicationController controller = Get.find();
  final String baseUrl = ApiConfig.baseUrl;

  EmployeeApplicationDetailScreen({
    super.key,
    required this.application,
    this.onBackPressed,
    this.showSidebar = true,
  });

  // ── Resume opener ────────────────────────────────────────────────────────────
  Future<void> _openResume() async {
    if (application.resumeFileUrl.isEmpty) return;
    try {
      final uri = Uri.parse(application.resumeFileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack('Error', 'Could not open resume', isError: true);
      }
    } catch (_) {
      _snack('Error', 'Failed to open resume', isError: true);
    }
  }

  // ── Leave job flow ────────────────────────────────────────────────────────────
  Future<void> _markAsLeft() async {
    final reasonCtrl = TextEditingController();

    final confirm = await Get.dialog<bool>(
      Dialog(
        backgroundColor: _surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.exit_to_app_outlined,
                        size: 18, color: _red),
                  ),
                  const SizedBox(width: 12),
                  const Text('Leave this job?',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _text1)),
                ],
              ),
              const SizedBox(height: 16),

              // Warning banner
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: _amber),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This will notify the employer and update your application status.',
                        style: TextStyle(
                            fontSize: 12,
                            color: _amber,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Reason field
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: _text1),
                decoration: InputDecoration(
                  hintText: 'Reason for leaving (optional)',
                  hintStyle:
                      const TextStyle(fontSize: 13, color: _text3),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: _bg,
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
                    borderSide:
                        BorderSide(color: primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _DBtn(
                      label: 'Cancel',
                      onTap: () => Get.back(result: false),
                      variant: _DBtnVariant.ghost,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DBtn(
                      label: 'Confirm Leave',
                      onTap: () => Get.back(result: true),
                      variant: _DBtnVariant.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await _submitLeaveRequest(reasonCtrl.text);
    }
  }

  Future<void> _submitLeaveRequest(String reason) async {
    try {
      Get.dialog(
        const Center(
            child: CircularProgressIndicator(color: primary)),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/api/applications/${application.id}/left'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _snack('Done', data['message'] ?? 'Job marked as left');
        await controller.fetchMyApplications();
        Get.back();
      } else {
        throw Exception('Failed to update');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _snack('Error', e.toString(), isError: true);
    }
  }

  void _snack(String title, String msg, {bool isError = false}) {
    Get.snackbar(
      title,
      msg,
      backgroundColor: isError ? _red : _green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb =
        Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isWeb && !showSidebar) {
      return Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _WebTopBar(
              title: application.jobSnapshot.title,
              onBack: onBackPressed,
              hasResume: application.resumeFileUrl.isNotEmpty,
              onResume: _openResume,
            ),
            Expanded(child: _buildScrollBody(context)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: _buildScrollBody(context),
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
      title: Text(
        application.jobSnapshot.title,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: _text1),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        if (application.resumeFileUrl.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.open_in_new_outlined,
                size: 19, color: _text2),
            onPressed: _openResume,
            tooltip: 'Open Resume',
          ),
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _border),
      ),
    );
  }

  Widget _buildScrollBody(BuildContext context) {
    final isWeb =
        Responsive.isDesktop(context) || Responsive.isTablet(context);
    final hPad = isWeb ? 28.0 : 16.0;

    return SingleChildScrollView(
      padding:
          EdgeInsets.symmetric(horizontal: hPad, vertical: 20),
      child: isWeb
          ? _buildWebLayout()
          : _buildMobileLayout(),
    );
  }

  // ── Web: two-column layout ────────────────────────────────────────────────────
  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column — main content
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _CompanyHeader(application: application),
              const SizedBox(height: 16),
              _JobDetailsCard(
                  application: application, controller: controller),
              const SizedBox(height: 16),
              if (application.coverLetter.isNotEmpty) ...[
                _CoverLetterCard(application: application),
                const SizedBox(height: 16),
              ],
              if (application.employeeSnapshot.skills.isNotEmpty) ...[
                _SkillsCard(application: application),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Right column — status + resume + action
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _StatusCard(
                  application: application, controller: controller),
              const SizedBox(height: 16),
              _ResumeCard(
                  application: application, onOpen: _openResume),
              const SizedBox(height: 16),
              if (application.status == 'hired') ...[
                application.employmentStatus != 'left'
                    ? _LeaveButton(onTap: _markAsLeft)
                    : _LeftBanner(
                        application: application,
                        controller: controller),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile: single column ────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _CompanyHeader(application: application),
        const SizedBox(height: 14),
        _StatusCard(application: application, controller: controller),
        const SizedBox(height: 14),
        _JobDetailsCard(
            application: application, controller: controller),
        const SizedBox(height: 14),
        _ResumeCard(application: application, onOpen: _openResume),
        if (application.coverLetter.isNotEmpty) ...[
          const SizedBox(height: 14),
          _CoverLetterCard(application: application),
        ],
        if (application.employeeSnapshot.skills.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SkillsCard(application: application),
        ],
        if (application.status == 'hired') ...[
          const SizedBox(height: 14),
          application.employmentStatus != 'left'
              ? _LeaveButton(onTap: _markAsLeft)
              : _LeftBanner(
                  application: application, controller: controller),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Web Top Bar ───────────────────────────────────────────────────────────────
class _WebTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final bool hasResume;
  final VoidCallback onResume;

  const _WebTopBar({
    required this.title,
    required this.onBack,
    required this.hasResume,
    required this.onResume,
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
          if (onBack != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: _text2),
              onPressed: onBack,
              style: IconButton.styleFrom(
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _text1),
                overflow: TextOverflow.ellipsis),
          ),
          if (hasResume)
            TextButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.open_in_new_outlined,
                  size: 15),
              label: const Text('Resume'),
              style: TextButton.styleFrom(
                foregroundColor: primary,
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Company Header ───────────────────────────────────────────────────────────
class _CompanyHeader extends StatelessWidget {
  final EmployeeApplication application;
  const _CompanyHeader({required this.application});

  @override
  Widget build(BuildContext context) {
    final emp = application.employerSnapshot;

    return _Card(
      child: Row(
        children: [
          // Logo
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            clipBehavior: Clip.antiAlias,
            child: emp.logoUrl.isNotEmpty
                ? Image.network(emp.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _Initial(name: emp.companyName))
                : _Initial(name: emp.companyName),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp.companyName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _text1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (emp.industry.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(emp.industry,
                      style: const TextStyle(
                          fontSize: 12, color: _text2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: _text3),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${emp.city}, ${emp.country}',
                        style: const TextStyle(
                            fontSize: 11, color: _text2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Card ──────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final EmployeeApplication application;
  final JobApplicationController controller;
  const _StatusCard(
      {required this.application, required this.controller});

  @override
  Widget build(BuildContext context) {
    final color = controller.getStatusColor(application.status);
    final icon  = controller.getStatusIcon(application.status);
    final text  = controller.getStatusText(application.status);
    final isHiredActive = application.status == 'hired' &&
        application.employmentStatus == 'active';

    return _Card(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Application Status',
                    style: TextStyle(
                        fontSize: 11,
                        color: _text2,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(text,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color)),
                if (isHiredActive) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      const Text('Currently working here',
                          style: TextStyle(
                              fontSize: 11, color: _green)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Status pill (right side)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(text,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Job Details Card ─────────────────────────────────────────────────────────
class _JobDetailsCard extends StatelessWidget {
  final EmployeeApplication application;
  final JobApplicationController controller;
  const _JobDetailsCard(
      {required this.application, required this.controller});

  @override
  Widget build(BuildContext context) {
    final j = application.jobSnapshot;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Job Details'),
          const SizedBox(height: 14),

          // Info rows
          _InfoRow(
              icon: Icons.work_outline,
              label: 'Position',
              value: j.title),
          _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: j.location),
          _InfoRow(
              icon: Icons.laptop_outlined,
              label: 'Workplace',
              value: j.workplace),
          _InfoRow(
              icon: Icons.category_outlined,
              label: 'Type',
              value: j.type),
          _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Applied',
              value: controller.formatDate(application.appliedAt),
              isLast: true),

          if (j.about.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 14),
            const _SectionLabel('About the job'),
            const SizedBox(height: 10),
            Text(j.about,
                style: const TextStyle(
                    fontSize: 13,
                    color: _text2,
                    height: 1.65)),
          ],
        ],
      ),
    );
  }
}

// ─── Resume Card ──────────────────────────────────────────────────────────────
class _ResumeCard extends StatelessWidget {
  final EmployeeApplication application;
  final VoidCallback onOpen;
  const _ResumeCard(
      {required this.application, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final sizeKb = application.resumeFileSize != null
        ? '${(application.resumeFileSize! / 1024).toStringAsFixed(1)} KB'
        : '';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Resume'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description_outlined,
                      size: 18, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.resumeFileName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _text1),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (sizeKb.isNotEmpty)
                        Text(sizeKb,
                            style: const TextStyle(
                                fontSize: 11, color: _text2)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (application.resumeFileUrl.isNotEmpty)
                  _IconPill(
                    icon: Icons.open_in_new_outlined,
                    label: 'Open',
                    onTap: onOpen,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cover Letter Card ────────────────────────────────────────────────────────
class _CoverLetterCard extends StatelessWidget {
  final EmployeeApplication application;
  const _CoverLetterCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('Cover Letter'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: Text(
              application.coverLetter,
              style: const TextStyle(
                  fontSize: 13, color: _text2, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skills Card ──────────────────────────────────────────────────────────────
class _SkillsCard extends StatelessWidget {
  final EmployeeApplication application;
  const _SkillsCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionLabel('Skills'),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${application.employeeSnapshot.skills.length}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _text2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: application.employeeSnapshot.skills
                .map((skill) => _SkillPill(skill: skill))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Leave Button ─────────────────────────────────────────────────────────────
class _LeaveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LeaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r + 2),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_r + 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_r + 2),
          splashColor: _red.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.exit_to_app_outlined,
                      size: 16, color: _red),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('I Left This Job',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _red)),
                    Text('Tap to notify the employer',
                        style: TextStyle(
                            fontSize: 11, color: _text3)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_outlined,
                    size: 18, color: _text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Left Banner ──────────────────────────────────────────────────────────────
class _LeftBanner extends StatelessWidget {
  final EmployeeApplication application;
  final JobApplicationController controller;
  const _LeftBanner(
      {required this.application, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(_r + 2),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline_rounded,
                size: 17, color: _amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You have left this job',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _text1)),
                if (application.leftReason != null &&
                    application.leftReason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Reason: ${application.leftReason}',
                      style: const TextStyle(
                          fontSize: 12, color: _text2)),
                ],
                if (application.leftAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Left on ${controller.formatDate(application.leftAt!)}',
                    style: const TextStyle(
                        fontSize: 11, color: _text3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r + 2),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _text1,
            letterSpacing: 0.1));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + label column
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Icon(icon, size: 14, color: _text3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: _text2)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _text1)),
          ),
        ],
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  final String skill;
  const _SkillPill({required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: primary.withOpacity(0.15)),
      ),
      child: Text(skill,
          style: TextStyle(
              fontSize: 12,
              color: primary,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _IconPill(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: primary),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: primary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) {
    final ch = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    return Center(
      child: Text(ch,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: primary)),
    );
  }
}

// ─── Dialog button ─────────────────────────────────────────────────────────────
enum _DBtnVariant { ghost, danger }

class _DBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _DBtnVariant variant;
  const _DBtn(
      {required this.label,
      required this.onTap,
      required this.variant});

  @override
  Widget build(BuildContext context) {
    final isDanger = variant == _DBtnVariant.danger;
    final bg  = isDanger ? _red : Colors.transparent;
    final fg  = isDanger ? Colors.white : _text2;
    final bd  = isDanger
        ? Border.all(color: Colors.transparent)
        : Border.all(color: _border);

    return SizedBox(
      height: 38,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: fg.withOpacity(0.08),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: bd),
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: fg)),
          ),
        ),
      ),
    );
  }
}
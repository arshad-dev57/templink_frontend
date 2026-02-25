  import 'dart:io';
  import 'dart:typed_data';

  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:get/get.dart';
import 'package:image/image.dart' as img;
  import 'package:open_file/open_file.dart';
  import 'package:path_provider/path_provider.dart';
  import 'package:pdf/pdf.dart';
  import 'package:pdf/widgets.dart' as pw;
  import 'package:permission_handler/permission_handler.dart';
  import 'package:screenshot/screenshot.dart';
  import 'package:share_plus/share_plus.dart';
  import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
  import 'package:templink/Resume_Builder/Screens/Resume_Templetes_Screen.dart';

  class AppColors {
    static const primary = Color(0xffB1843D);
    static const bg = Color(0xFFF8F9FA);
    static const cardBg = Color(0xFFFFFFFF);
    static const surface = Color(0xFFF1F3F4);
    static const border = Color(0xFFE0E0E0);
    static const textPrimary = Color(0xFF212121);
    static const textSecondary = Color(0xFF757575); // Medium grey
    static const textMuted = Color(0xFF9E9E9E);    // Light grey
    static const white = Color(0xFFFFFFFF);
    static const black = Color(0xFF000000);
    static const error = Color(0xFFDC2626);        // Red
    static const success = Color(0xFF16A34A);      // Green
    
    // Primary variants
    static const primaryLight = Color(0xFFE6D5B8);
    static const primaryDark = Color(0xFF8B6B3C);
  }

  // ============================================
  // RESUME FORM SCREEN
  // ============================================
  class ResumeFormScreen extends StatelessWidget {
    ResumeFormScreen({super.key});

    final ResumeController controller = Get.put(ResumeController());

    static const List<_StepMeta> _steps = [
      _StepMeta(icon: Icons.person_outline_rounded, label: 'Personal'),
      _StepMeta(icon: Icons.edit_note_rounded, label: 'Summary'),
      _StepMeta(icon: Icons.work_outline_rounded, label: 'Experience'),
      _StepMeta(icon: Icons.school_outlined, label: 'Education'),
      _StepMeta(icon: Icons.build_outlined, label: 'Skills'),
      _StepMeta(icon: Icons.add_circle_outline_rounded, label: 'Extras'),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildStepIndicator(),
            // Expanded + SingleChildScrollView for proper scrolling
            Expanded(
              child: Obx(() {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Current step content
                      _buildCurrentStep(),
                      // Extra padding at bottom
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }),
            ),
            _buildBottomBar(),
          ],
        ),
      );
    }

    Widget _buildCurrentStep() {
      switch (controller.currentStep.value) {
        case 0:
          return _PersonalInfoForm();
        case 1:
          return _ProfessionalSummaryForm();
        case 2:
          return _WorkExperienceForm();
        case 3:
          return _EducationForm();
        case 4:
          return _SkillsForm();
        case 5:
          return _AdditionalInfoForm();
        default:
          return const SizedBox();
      }
    }

    PreferredSizeWidget _buildAppBar() {
      return AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 16),
          ),
        ),
        title: Obx(() {
          final template = kTemplates.firstWhere(
            (t) => t.id == controller.selectedTemplateId.value,
            orElse: () => kTemplates.first,
          );
          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: template.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.description_rounded,
                    color: template.accent, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Build Resume',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      template.title,
                      style: TextStyle(
                          color: template.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: controller.selectedTemplateAccent.value.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: controller.selectedTemplateAccent.value.withOpacity(0.3)),
            ),
            child: Text(
              '${controller.currentStep.value + 1} / 6',
              style: TextStyle(
                color: controller.selectedTemplateAccent.value,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          )),
        ],
      );
    }

    Widget _buildStepIndicator() {
      return Obx(() {
        final step = controller.currentStep.value;
        final accent = controller.selectedTemplateAccent.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_steps.length, (i) {
              final isActive = i == step;
              final isDone = i < step;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (i <= step) controller.goToStep(i);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isActive ? 34 : 28,
                        height: isActive ? 34 : 28,
                        decoration: BoxDecoration(
                          color: isDone
                              ? accent
                              : isActive
                                  ? accent.withOpacity(0.15)
                                  : AppColors.border.withOpacity(0.5),
                          shape: BoxShape.circle,
                          border: isActive
                              ? Border.all(color: accent, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: isDone
                              ? Icon(Icons.check_rounded,
                                  color: isDone ? Colors.white : Colors.black, 
                                  size: 14)
                              : Icon(
                                  _steps[i].icon,
                                  color: isActive
                                      ? accent
                                      : AppColors.textSecondary,
                                  size: isActive ? 16 : 13,
                                ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Text(
                          _steps[i].label,
                          style: TextStyle(
                            color: accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      });
    }

    Widget _buildBottomBar() {
      return Obx(() {
        final step = controller.currentStep.value;
        final accent = controller.selectedTemplateAccent.value;
        final isValid = controller.isCurrentStepValid();
        return Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(Get.context!).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            border: Border(top: BorderSide(color: AppColors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (step > 0) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.previousStep,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isValid
                      ? () {
                          if (step == 5) {
                            Get.to(() => FinalResumeScreen(),
                                transition: Transition.rightToLeft);
                          } else {
                            controller.nextStep();
                          }
                        }
                      : null,
                  icon: Icon(
                    step == 5
                        ? Icons.check_circle_outline_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                    color: isValid
                        ? (accent.computeLuminance() < 0.4
                            ? Colors.white
                            : Colors.white)
                        : AppColors.textSecondary,
                  ),
                  label: Text(
                    step == 5 ? 'Build Resume' : 'Continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isValid ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid ? accent : AppColors.border,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      });
    }
  }

  // ============================================
  // STEP META CLASS
  // ============================================
  class _StepMeta {
    final IconData icon;
    final String label;
    const _StepMeta({required this.icon, required this.label});
  }

  // ============================================
  // SHARED WIDGETS
  // ============================================
  class _SectionHeader extends StatelessWidget {
    final String title;
    final String subtitle;
    const _SectionHeader({required this.title, required this.subtitle});

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }
  }

  class _FormField extends StatelessWidget {
    final String label;
    final String hint;
    final IconData icon;
    final Function(String) onChanged;
    final TextInputType keyboardType;
    final bool required;
    final int maxLines;
    final String? initialValue;

    const _FormField({
      required this.label,
      required this.hint,
      required this.icon,
      required this.onChanged,
      this.keyboardType = TextInputType.text,
      this.required = true,
      this.maxLines = 1,
      this.initialValue,
    });

    @override
    Widget build(BuildContext context) {
      final controller = Get.find<ResumeController>();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label,
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                if (required)
                  Obx(() => Text(' *',
                      style: TextStyle(
                          color: controller.selectedTemplateAccent.value,
                          fontSize: 13,
                          fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 6),
            Obx(() => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: TextStyle(
                    color: AppColors.textPrimary, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w400),
                keyboardType: keyboardType,
                maxLines: maxLines,
                controller: initialValue != null
                    ? TextEditingController(text: initialValue)
                    : null,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: maxLines == 1
                      ? Icon(icon,
                          color: controller.selectedTemplateAccent.value,
                          size: 18)
                      : null,
                  border: InputBorder.none,
                  contentPadding: maxLines > 1
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                onChanged: onChanged,
              ),
            )),
          ],
        ),
      );
    }
  }

  class _InlineField extends StatelessWidget {
    final String label;
    final String hint;
    final String initialValue;
    final Function(String) onChanged;
    final bool enabled;

    const _InlineField({
      required this.label,
      required this.hint,
      required this.initialValue,
      required this.onChanged,
      this.enabled = true,
    });

    @override
    Widget build(BuildContext context) {
      final ctrl = Get.find<ResumeController>();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: enabled ? AppColors.border : AppColors.border.withOpacity(0.4),
                      width: 1),
                ),
              ),
              child: Obx(() => TextField(
                enabled: enabled,
                style: TextStyle(
                    color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 13),
                controller: TextEditingController(text: initialValue),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: ctrl.selectedTemplateAccent.value, width: 1.5)),
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: AppColors.border.withOpacity(0.4))),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: onChanged,
              )),
            ),
          ],
        ),
      );
    }
  }

  class _AddButton extends StatelessWidget {
    final String label;
    final Color accent;
    final VoidCallback onTap;
    const _AddButton(
        {required this.label, required this.accent, required this.onTap});

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: accent, size: 16),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }
  }

  class _EmptyState extends StatelessWidget {
    final IconData icon;
    final String title;
    final String subtitle;
    final Color accent;
    final VoidCallback onAdd;

    const _EmptyState({
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.accent,
      required this.onAdd,
    });

    @override
    Widget build(BuildContext context) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 36),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  class _ValidationBanner extends StatelessWidget {
    final String text;
    const _ValidationBanner({required this.text});

    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 16),
            const SizedBox(width: 10),
            Expanded(
                child: Text(text,
                    style: const TextStyle(color: AppColors.error, fontSize: 12))),
          ],
        ),
      );
    }
  }

  // ============================================
  // STEP 1: PERSONAL INFO
  // ============================================
  class _PersonalInfoForm extends StatelessWidget {
    _PersonalInfoForm();
    final ResumeController controller = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Personal Info',
            subtitle: 'Tell us the basics about yourself',
          ),
          _FormField(
            label: 'Full Name',
            hint: 'e.g., Ahmed Khan',
            icon: Icons.person_outline_rounded,
            onChanged: (v) {
              controller.resumeData.value.fullName = v;
              controller.validatePersonalInfo();
            },
          ),
          _FormField(
            label: 'Professional Title',
            hint: 'e.g., Senior Software Engineer',
            icon: Icons.work_outline_rounded,
            onChanged: (v) {
              controller.resumeData.value.professionalTitle = v;
              controller.validatePersonalInfo();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _FormField(
                    label: 'Phone',
                    hint: '+92 300 1234567',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    onChanged: (v) {
                      controller.resumeData.value.phone = v;
                      controller.validatePersonalInfo();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FormField(
                    label: 'Location',
                    hint: 'Karachi, PK',
                    icon: Icons.location_on_outlined,
                    onChanged: (v) {
                      controller.resumeData.value.location = v;
                      controller.validatePersonalInfo();
                    },
                  ),
                ),
              ],
            ),
          ),
          _FormField(
            label: 'Email Address',
            hint: 'ahmed@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) {
              controller.resumeData.value.email = v;
              controller.validatePersonalInfo();
            },
          ),
          _FormField(
            label: 'LinkedIn Profile',
            hint: 'linkedin.com/in/username',
            icon: Icons.link_rounded,
            required: false,
            onChanged: (v) => controller.resumeData.value.linkedIn = v,
          ),
          Obx(() => controller.showProfileImage.value
              ? Column(
                  children: [
                    _FormField(
                      label: 'GitHub Profile',
                      hint: 'github.com/username',
                      icon: Icons.code_rounded,
                      required: false,
                      onChanged: (v) => controller.resumeData.value.github = v,
                    ),
                    _FormField(
                      label: 'Portfolio Website',
                      hint: 'yourportfolio.com',
                      icon: Icons.public_rounded,
                      required: false,
                      onChanged: (v) =>
                          controller.resumeData.value.portfolio = v,
                    ),
                  ],
                )
              : const SizedBox()),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildInfoTip(),
          ),
        ],
      );
    }

    Widget _buildInfoTip() {
      return Obx(() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: controller.selectedTemplateAccent.value.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: controller.selectedTemplateAccent.value.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: controller.selectedTemplateAccent.value, size: 18),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Fields marked with * are required to proceed to the next step.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      ));
    }
  }

  // ============================================
  // STEP 2: PROFESSIONAL SUMMARY
  // ============================================
  class _ProfessionalSummaryForm extends StatelessWidget {
    _ProfessionalSummaryForm();
    final ResumeController controller = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Professional Summary',
            subtitle: 'A brief overview of your professional background',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: TextStyle(
                    color: AppColors.textPrimary, 
                    fontSize: 14, 
                    height: 1.6),
                maxLines: 9,
                minLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'e.g., Results-driven Software Engineer with 5+ years of experience building scalable web applications...',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, 
                      fontSize: 13, 
                      height: 1.6),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12, top: 16),
                    child: Icon(Icons.edit_note_rounded,
                        color: controller.selectedTemplateAccent.value
                            .withOpacity(0.7),
                        size: 22),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (v) {
                  controller.resumeData.value.summary = v;
                  controller.validateSummary();
                },
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Obx(() {
              final count = controller.resumeData.value.summary.trim().length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$count characters',
                    style: TextStyle(
                      color: count >= 10
                          ? controller.selectedTemplateAccent.value
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: controller.selectedTemplateAccent.value.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color:
                        controller.selectedTemplateAccent.value.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: controller.selectedTemplateAccent.value, size: 16),
                      const SizedBox(width: 8),
                      Text('Writing Tips',
                          style: TextStyle(
                              color: controller.selectedTemplateAccent.value,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Keep it to 3–4 concise sentences\n'
                    '• Mention your years of experience\n'
                    '• Highlight 2–3 key achievements\n'
                    '• Tailor it to the role you\'re applying for',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.7),
                  ),
                ],
              ),
            )),
          ),
        ],
      );
    }
  }

  // ============================================
  // STEP 3: WORK EXPERIENCE
  // ============================================
  class _WorkExperienceForm extends StatelessWidget {
    _WorkExperienceForm();
    final ResumeController controller = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          // Header with Add button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Work Experience',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text('Add your relevant work history',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Obx(() => _AddButton(
                      label: 'Add Experience',
                      accent: controller.selectedTemplateAccent.value,
                      onTap: () {
                        controller.addExperience();
                      },
                    )),
              ],
            ),
          ),
          // List of experiences
          Obx(() {
            final exps = controller.resumeData.value.experiences;
            if (exps.isEmpty) {
              return _EmptyState(
                icon: Icons.work_outline_rounded,
                title: 'No experience added',
                subtitle: 'Tap "Add Experience" to add your work experience',
                accent: controller.selectedTemplateAccent.value,
                onAdd: controller.addExperience,
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: exps.length,
              itemBuilder: (_, i) => _ExperienceCard(
                index: i,
                experience: exps[i],
                onRemove: () => controller.removeExperience(i),
                onUpdate: controller.validateExperience,
              ),
            );
          }),
          // Validation error
          Obx(() {
            if (controller.resumeData.value.experiences.isEmpty) {
              return const _ValidationBanner(
                  text: 'Add at least one work experience to continue');
            }
            return const SizedBox();
          }),
        ],
      );
    }
  }

  // ============================================
  // EXPERIENCE CARD
  // ============================================
  class _ExperienceCard extends StatelessWidget {
    final int index;
    final Experience experience;
    final VoidCallback onRemove;
    final VoidCallback onUpdate;

    const _ExperienceCard({
      required this.index,
      required this.experience,
      required this.onRemove,
      required this.onUpdate,
    });

    @override
    Widget build(BuildContext context) {
      final ctrl = Get.find<ResumeController>();
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card Header
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ctrl.selectedTemplateAccent.value.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          ctrl.selectedTemplateAccent.value.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            color: ctrl.selectedTemplateAccent.value,
                            fontWeight: FontWeight.w800,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      experience.title.isEmpty
                          ? 'Experience ${index + 1}'
                          : experience.title,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                    ),
                  ),
                ],
              ),
            )),
            // Fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _InlineField(
                          label: 'Job Title *',
                          hint: 'Senior Developer',
                          initialValue: experience.title,
                          onChanged: (v) {
                            experience.title = v;
                            onUpdate();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InlineField(
                          label: 'Company *',
                          hint: 'Google Inc.',
                          initialValue: experience.company,
                          onChanged: (v) {
                            experience.company = v;
                            onUpdate();
                          },
                        ),
                      ),
                    ],
                  ),
                  _InlineField(
                    label: 'Location',
                    hint: 'San Francisco, CA',
                    initialValue: experience.location,
                    onChanged: (v) {
                      experience.location = v;
                      onUpdate();
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _InlineField(
                          label: 'Start Date *',
                          hint: 'MM/YYYY',
                          initialValue: experience.startDate,
                          onChanged: (v) {
                            experience.startDate = v;
                            onUpdate();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InlineField(
                          label: 'End Date',
                          hint: experience.isCurrent ? 'Present' : 'MM/YYYY',
                          initialValue: experience.endDate,
                          enabled: !experience.isCurrent,
                          onChanged: (v) {
                            experience.endDate = v;
                            onUpdate();
                          },
                        ),
                      ),
                    ],
                  ),
                  // Current job toggle
                  Obx(() => Row(
                    children: [
                      Checkbox(
                        value: experience.isCurrent,
                        onChanged: (val) {
                          experience.isCurrent = val ?? false;
                          experience.endDate =
                              experience.isCurrent ? 'Present' : '';
                          Get.find<ResumeController>().resumeData.refresh();
                          onUpdate();
                        },
                        activeColor: ctrl.selectedTemplateAccent.value,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Text('Currently working here',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  )),
                  const SizedBox(height: 12),
                  // Responsibilities
                  _ResponsibilitiesSection(
                    experience: experience,
                    onUpdate: onUpdate,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  class _ResponsibilitiesSection extends StatelessWidget {
    final Experience experience;
    final VoidCallback onUpdate;
    const _ResponsibilitiesSection(
        {required this.experience, required this.onUpdate});

    @override
    Widget build(BuildContext context) {
      final ctrl = Get.find<ResumeController>();
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Responsibilities',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () {
                    experience.responsibilities.add('');
                    ctrl.resumeData.refresh();
                    onUpdate();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ctrl.selectedTemplateAccent.value.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded,
                            color: ctrl.selectedTemplateAccent.value, size: 14),
                        const SizedBox(width: 4),
                        Text('Add Bullet',
                            style: TextStyle(
                                color: ctrl.selectedTemplateAccent.value,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(experience.responsibilities.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: ctrl.selectedTemplateAccent.value,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                              text: experience.responsibilities[i]),
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13),
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'e.g., Led team of 5 engineers...',
                            hintStyle: TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (v) {
                            experience.responsibilities[i] = v;
                            onUpdate();
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          experience.responsibilities.removeAt(i);
                          ctrl.resumeData.refresh();
                          onUpdate();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Icon(Icons.close_rounded,
                              color: AppColors.error.withOpacity(0.7), size: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }
  }

  // ============================================
  // STEP 4: EDUCATION
  // ============================================
  class _EducationForm extends StatelessWidget {
    _EducationForm();
    final ResumeController controller = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Education',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text('Your academic background',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Obx(() => _AddButton(
                      label: 'Add Education',
                      accent: controller.selectedTemplateAccent.value,
                      onTap: controller.addEducation,
                    )),
              ],
            ),
          ),
          Obx(() {
            final list = controller.resumeData.value.educationList;
            if (list.isEmpty) {
              return _EmptyState(
                icon: Icons.school_outlined,
                title: 'No education added',
                subtitle: 'Tap "Add Education" to add your education',
                accent: controller.selectedTemplateAccent.value,
                onAdd: controller.addEducation,
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: list.length,
              itemBuilder: (_, i) => _EducationCard(
                index: i,
                education: list[i],
                onRemove: () => controller.removeEducation(i),
                onUpdate: controller.validateEducation,
              ),
            );
          }),
          Obx(() {
            if (controller.resumeData.value.educationList.isEmpty) {
              return const _ValidationBanner(
                  text: 'Add at least one education entry to continue');
            }
            return const SizedBox();
          }),
        ],
      );
    }
  }

  class _EducationCard extends StatelessWidget {
    final int index;
    final Education education;
    final VoidCallback onRemove;
    final VoidCallback onUpdate;

    const _EducationCard({
      required this.index,
      required this.education,
      required this.onRemove,
      required this.onUpdate,
    });

    @override
    Widget build(BuildContext context) {
      final ctrl = Get.find<ResumeController>();
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: ctrl.selectedTemplateAccent.value.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ctrl.selectedTemplateAccent.value.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${index + 1}',
                          style: TextStyle(
                              color: ctrl.selectedTemplateAccent.value,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      education.degree.isEmpty
                          ? 'Education ${index + 1}'
                          : education.degree,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                    ),
                  ),
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InlineField(
                    label: 'Degree *',
                    hint: 'Bachelor of Science in Computer Science',
                    initialValue: education.degree,
                    onChanged: (v) {
                      education.degree = v;
                      onUpdate();
                    },
                  ),
                  _InlineField(
                    label: 'Institution *',
                    hint: 'University of Karachi',
                    initialValue: education.institution,
                    onChanged: (v) {
                      education.institution = v;
                      onUpdate();
                    },
                  ),
                  _InlineField(
                    label: 'Location',
                    hint: 'Karachi, Pakistan',
                    initialValue: education.location,
                    onChanged: (v) {
                      education.location = v;
                      onUpdate();
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _InlineField(
                          label: 'Start Year *',
                          hint: '2018',
                          initialValue: education.startYear,
                          onChanged: (v) {
                            education.startYear = v;
                            onUpdate();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InlineField(
                          label: 'End Year *',
                          hint: '2022',
                          initialValue: education.endYear,
                          onChanged: (v) {
                            education.endYear = v;
                            onUpdate();
                          },
                        ),
                      ),
                    ],
                  ),
                  Obx(() => ctrl.showGPA.value
                      ? _InlineField(
                          label: 'GPA',
                          hint: '3.8 / 4.0',
                          initialValue: education.grade,
                          onChanged: (v) {
                            education.grade = v;
                            onUpdate();
                          },
                        )
                      : const SizedBox()),
                  Obx(() => ctrl.showAwards.value
                      ? _InlineField(
                          label: 'Honors & Awards',
                          hint: "Dean's List, Cum Laude",
                          initialValue: education.honors,
                          onChanged: (v) {
                            education.honors = v;
                            onUpdate();
                          },
                        )
                      : const SizedBox()),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ============================================
  // STEP 5: SKILLS
  // ============================================
  class _SkillsForm extends StatelessWidget {
    _SkillsForm();
    final ResumeController controller = Get.find<ResumeController>();

    void _showAddSkillDialog(BuildContext context) {
      final inputCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Skill',
              style: TextStyle(
                  color: AppColors.textPrimary, 
                  fontWeight: FontWeight.w700)),
          content: Obx(() => TextField(
            controller: inputCtrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g., Flutter, Python, Figma',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: controller.selectedTemplateAccent.value, width: 1.5),
              ),
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                controller.addSkill(v.trim());
                Navigator.pop(context);
              }
            },
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            Obx(() => ElevatedButton(
              onPressed: () {
                if (inputCtrl.text.trim().isNotEmpty) {
                  controller.addSkill(inputCtrl.text.trim());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.selectedTemplateAccent.value,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add'),
            )),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _SectionHeader(
              title: 'Skills & Languages',
              subtitle: 'Add your technical and soft skills',
            ),
          ),
          // Skills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Skills',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Obx(() => _AddButton(
                      label: 'Add Skill',
                      accent: controller.selectedTemplateAccent.value,
                      onTap: () => _showAddSkillDialog(context),
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() {
              final skills = controller.resumeData.value.skills;
              if (skills.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.build_outlined,
                          color: AppColors.textSecondary, size: 36),
                      const SizedBox(height: 10),
                      const Text('No skills added yet',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('Tap "Add Skill" to get started',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 14),
                      Obx(() => ElevatedButton.icon(
                        onPressed: () => _showAddSkillDialog(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add First Skill'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              controller.selectedTemplateAccent.value,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      )),
                    ],
                  ),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.asMap().entries.map((e) {
                  final i = e.key;
                  final skill = e.value;
                  return Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: controller.selectedTemplateAccent.value
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: controller.selectedTemplateAccent.value
                              .withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(skill,
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        if (controller.showSkillLevels.value) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${((controller.resumeData.value.skillLevels[skill] ?? 0.75) * 100).toInt()}%',
                            style: TextStyle(
                                color: controller.selectedTemplateAccent.value,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            controller.removeSkill(i);
                          },
                          child: Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 15),
                        ),
                      ],
                    ),
                  ));
                }).toList(),
              );
            }),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: AppColors.border, height: 1),
          ),
          // Languages
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Languages',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Obx(() => _AddButton(
                      label: 'Add Language',
                      accent: controller.selectedTemplateAccent.value,
                      onTap: controller.addLanguage,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(() {
              final langs = controller.resumeData.value.languages;
              if (langs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.language_rounded,
                          color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 12),
                      Text('No languages added (optional)',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                );
              }
              return Column(
                children: langs.asMap().entries.map((e) {
                  final i = e.key;
                  final lang = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language_rounded,
                            color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller:
                                TextEditingController(text: lang.name),
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Language name',
                              hintStyle: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) => lang.name = v,
                          ),
                        ),
                        Obx(() => DropdownButton<String>(
                          value: lang.proficiency.isEmpty
                              ? null
                              : lang.proficiency,
                          hint: const Text('Level',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                          dropdownColor: AppColors.cardBg,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 12),
                          underline: const SizedBox(),
                          icon: Icon(Icons.arrow_drop_down_rounded,
                              color:
                                  controller.selectedTemplateAccent.value),
                          items: const [
                            DropdownMenuItem(
                                value: 'Native', child: Text('Native')),
                            DropdownMenuItem(
                                value: 'Fluent', child: Text('Fluent')),
                            DropdownMenuItem(
                                value: 'Conversational',
                                child: Text('Conversational')),
                            DropdownMenuItem(
                                value: 'Basic', child: Text('Basic')),
                          ],
                          onChanged: (v) {
                            lang.proficiency = v ?? '';
                            controller.resumeData.refresh();
                          },
                        )),
                        GestureDetector(
                          onTap: () => controller.removeLanguage(i),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.close_rounded,
                                color: AppColors.error.withOpacity(0.7), size: 18),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ),
          // Validation
          Padding(
            padding: const EdgeInsets.all(20),
            child: Obx(() {
              if (controller.resumeData.value.skills.isEmpty) {
                return const _ValidationBanner(
                    text: 'Add at least one skill to continue');
              }
              return const SizedBox();
            }),
          ),
        ],
      );
    }
  }

  // ============================================
  // STEP 6: ADDITIONAL INFO
  // ============================================
  class _AdditionalInfoForm extends StatelessWidget {
    _AdditionalInfoForm();
    final ResumeController controller = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: _SectionHeader(
                title: 'Additional Info',
                subtitle: 'Optional sections to enhance your resume',
              ),
            ),
            Obx(() => controller.showCertifications.value
                ? _CertificationsSection()
                : const SizedBox()),
            Obx(() => controller.showAwards.value
                ? _AwardsSection()
                : const SizedBox()),
            Obx(() => controller.showProjects.value
                ? _ProjectsSection()
                : const SizedBox()),
            Obx(() => controller.showBoardMemberships.value
                ? _BoardSection()
                : const SizedBox()),
            Obx(() => controller.showDesignations.value
                ? _DesignationsSection()
                : const SizedBox()),
            Obx(() => controller.showTools.value
                ? _ToolsSection()
                : const SizedBox()),
            Obx(() => controller.showKeyMetrics.value
                ? _KeyMetricsSection()
                : const SizedBox()),
            // Tip
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Obx(() => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: controller.selectedTemplateAccent.value.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: controller.selectedTemplateAccent.value
                          .withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: controller.selectedTemplateAccent.value, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'All additional fields are optional. Click "Build Resume" when ready!',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      );
    }
  }

  // ============================================
  // EXTRA SECTIONS (Additional Info)
  // ============================================
  class _ExtraSection extends StatelessWidget {
    final String title;
    final IconData icon;
    final VoidCallback onAdd;
    final Widget child;

    const _ExtraSection({
      required this.title,
      required this.icon,
      required this.onAdd,
      required this.child,
    });

    @override
    Widget build(BuildContext context) {
      final ctrl = Get.find<ResumeController>();
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Obx(() => Icon(icon,
                      color: ctrl.selectedTemplateAccent.value, size: 18)),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ]),
                Obx(() => _AddButton(
                      label: 'Add',
                      accent: ctrl.selectedTemplateAccent.value,
                      onTap: onAdd,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
    }
  }

  class _ExtraCard extends StatelessWidget {
    final Widget child;
    final VoidCallback onRemove;
    const _ExtraCard({required this.child, required this.onRemove});

    @override
    Widget build(BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child:
                    Icon(Icons.close_rounded, color: AppColors.error.withOpacity(0.7), size: 18),
              ),
            ),
          ],
        ),
      );
    }
  }

  class _ExtraEmptyHint extends StatelessWidget {
    final String text;
    const _ExtraEmptyHint({required this.text});

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      );
    }
  }

  // Certifications Section
  class _CertificationsSection extends StatelessWidget {
    _CertificationsSection();
    final ctrl = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return _ExtraSection(
        title: 'Certifications',
        icon: Icons.verified_outlined,
        onAdd: ctrl.addCertification,
        child: Obx(() {
          final certs = ctrl.resumeData.value.certifications;
          if (certs.isEmpty) {
            return const _ExtraEmptyHint(
                text: 'Add your professional certifications');
          }
          return Column(
            children: certs.asMap().entries.map((e) {
              final i = e.key;
              final cert = e.value;
              return _ExtraCard(
                onRemove: () => ctrl.removeCertification(i),
                child: Column(children: [
                  _InlineField(
                      label: 'Certification Name',
                      hint: 'AWS Certified Solutions Architect',
                      initialValue: cert.name,
                      onChanged: (v) => cert.name = v),
                  Row(children: [
                    Expanded(
                        child: _InlineField(
                            label: 'Organization',
                            hint: 'Amazon',
                            initialValue: cert.organization,
                            onChanged: (v) => cert.organization = v)),
                    const SizedBox(width: 12),
                    SizedBox(
                        width: 80,
                        child: _InlineField(
                            label: 'Year',
                            hint: '2023',
                            initialValue: cert.year,
                            onChanged: (v) => cert.year = v)),
                  ]),
                ]),
              );
            }).toList(),
          );
        }),
      );
    }
  }

  // Awards Section
  class _AwardsSection extends StatelessWidget {
    _AwardsSection();
    final ctrl = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return _ExtraSection(
        title: 'Awards & Achievements',
        icon: Icons.emoji_events_outlined,
        onAdd: ctrl.addAward,
        child: Obx(() {
          final awards = ctrl.resumeData.value.awards;
          if (awards.isEmpty) {
            return const _ExtraEmptyHint(text: 'Add your awards and achievements');
          }
          return Column(
            children: awards.asMap().entries.map((e) {
              final i = e.key;
              final award = e.value;
              return _ExtraCard(
                onRemove: () => ctrl.removeAward(i),
                child: Column(children: [
                  _InlineField(
                      label: 'Award Name',
                      hint: 'Employee of the Year',
                      initialValue: award.name,
                      onChanged: (v) => award.name = v),
                  Row(children: [
                    Expanded(
                        child: _InlineField(
                            label: 'Organization',
                            hint: 'Company Name',
                            initialValue: award.organization,
                            onChanged: (v) => award.organization = v)),
                    const SizedBox(width: 12),
                    SizedBox(
                        width: 80,
                        child: _InlineField(
                            label: 'Year',
                            hint: '2023',
                            initialValue: award.year,
                            onChanged: (v) => award.year = v)),
                  ]),
                ]),
              );
            }).toList(),
          );
        }),
      );
    }
  }

  // Projects Section
  class _ProjectsSection extends StatelessWidget {
    _ProjectsSection();
    final ctrl = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return _ExtraSection(
        title: 'Projects',
        icon: Icons.folder_outlined,
        onAdd: ctrl.addProject,
        child: Obx(() {
          final projects = ctrl.resumeData.value.projects;
          if (projects.isEmpty) {
            return const _ExtraEmptyHint(text: 'Add your key projects');
          }
          return Column(
            children: projects.asMap().entries.map((e) {
              final i = e.key;
              final p = e.value;
              return _ExtraCard(
                onRemove: () => ctrl.removeProject(i),
                child: Column(children: [
                  _InlineField(
                      label: 'Project Name',
                      hint: 'E-Commerce App',
                      initialValue: p.name,
                      onChanged: (v) => p.name = v),
                  _InlineField(
                      label: 'Description',
                      hint: 'Brief description of the project',
                      initialValue: p.description,
                      onChanged: (v) => p.description = v),
                  _InlineField(
                      label: 'Technologies (comma separated)',
                      hint: 'Flutter, Firebase, Node.js',
                      initialValue: p.technologies.join(', '),
                      onChanged: (v) {
                        p.technologies =
                            v.split(',').map((s) => s.trim()).toList();
                      }),
                ]),
              );
            }).toList(),
          );
        }),
      );
    }
  }

  // Board Memberships Section
  class _BoardSection extends StatelessWidget {
    _BoardSection();
    final ctrl = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return _ExtraSection(
        title: 'Board Memberships',
        icon: Icons.groups_outlined,
        onAdd: ctrl.addBoardMembership,
        child: Obx(() {
          final items = ctrl.resumeData.value.boardMemberships;
          if (items.isEmpty) {
            return const _ExtraEmptyHint(text: 'Add board memberships or affiliations');
          }
          return Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              return _ExtraCard(
                onRemove: () => ctrl.removeBoardMembership(i),
                child: _InlineField(
                    label: 'Board / Organization',
                    hint: 'Harvard Business School Advisory Board',
                    initialValue: items[i],
                    onChanged: (v) {
                      ctrl.resumeData.value.boardMemberships[i] = v;
                      ctrl.resumeData.refresh();
                    }),
              );
            }).toList(),
          );
        }),
      );
    }
  }

  // Professional Designations Section
  class _DesignationsSection extends StatelessWidget {
    _DesignationsSection();
    final ctrl = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return _ExtraSection(
        title: 'Professional Designations',
        icon: Icons.workspace_premium_outlined,
        onAdd: ctrl.addDesignation,
        child: Obx(() {
          final items = ctrl.resumeData.value.designations;
          if (items.isEmpty) {
            return const _ExtraEmptyHint(
                text: 'Add designations like CPA, CFA, PMP');
          }
          return Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              return _ExtraCard(
                onRemove: () => ctrl.removeDesignation(i),
                child: _InlineField(
                    label: 'Designation',
                    hint: 'e.g., CPA, CFA, PMP',
                    initialValue: items[i],
                    onChanged: (v) {
                      ctrl.resumeData.value.designations[i] = v;
                      ctrl.resumeData.refresh();
                    }),
              );
            }).toList(),
          );
        }),
      );
    }
  }

  // Tools Section
  class _ToolsSection extends StatelessWidget {
    _ToolsSection();
    final ctrl = Get.find<ResumeController>();
    final _toolCtrl = TextEditingController();

    void _showAddToolDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Tool',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          content: Obx(() => TextField(
            controller: _toolCtrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g., Figma, Jira, VS Code',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: ctrl.selectedTemplateAccent.value, width: 1.5),
              ),
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                ctrl.addTool(v.trim());
                _toolCtrl.clear();
                Navigator.pop(context);
              }
            },
          )),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.textSecondary))),
            Obx(() => ElevatedButton(
              onPressed: () {
                if (_toolCtrl.text.trim().isNotEmpty) {
                  ctrl.addTool(_toolCtrl.text.trim());
                  _toolCtrl.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ctrl.selectedTemplateAccent.value,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add'),
            )),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return _ExtraSection(
        title: 'Tools & Technologies',
        icon: Icons.construction_outlined,
        onAdd: () => _showAddToolDialog(context),
        child: Obx(() {
          final tools = ctrl.resumeData.value.tools;
          if (tools.isEmpty) {
            return const _ExtraEmptyHint(text: 'Add tools you use professionally');
          }
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tools.asMap().entries.map((e) {
              final i = e.key;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ctrl.selectedTemplateAccent.value.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: ctrl.selectedTemplateAccent.value.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(e.value,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => ctrl.removeTool(i),
                    child: Icon(Icons.close_rounded,
                        color: AppColors.textSecondary, size: 14),
                  ),
                ]),
              );
            }).toList(),
          );
        }),
      );
    }
  }

  // Key Metrics Section
  class _KeyMetricsSection extends StatelessWidget {
    _KeyMetricsSection();
    final ctrl = Get.find<ResumeController>();

    @override
    Widget build(BuildContext context) {
      return _ExtraSection(
        title: 'Key Metrics & Achievements',
        icon: Icons.trending_up_rounded,
        onAdd: ctrl.addKeyMetric,
        child: Obx(() {
          final items = ctrl.resumeData.value.keyMetrics;
          if (items.isEmpty) {
            return const _ExtraEmptyHint(
                text: 'e.g., Grew revenue by 45% in 2023');
          }
          return Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              return _ExtraCard(
                onRemove: () => ctrl.removeKeyMetric(i),
                child: _InlineField(
                    label: 'Metric',
                    hint: 'e.g., Increased sales by 30%',
                    initialValue: items[i],
                    onChanged: (v) {
                      ctrl.resumeData.value.keyMetrics[i] = v;
                      ctrl.resumeData.refresh();
                    }),
              );
            }).toList(),
          );
        }),
      );
    }
  }
// ============================================
// FINAL RESUME SCREEN - FIXED WITH AUTO-SAVE
// ============================================
class FinalResumeScreen extends StatefulWidget {
  FinalResumeScreen({super.key});
  
  @override
  State<FinalResumeScreen> createState() => _FinalResumeScreenState();
}

class _FinalResumeScreenState extends State<FinalResumeScreen> {
  final ResumeController controller = Get.find<ResumeController>();
  final ScreenshotController screenshotController = ScreenshotController();
  static const platform = MethodChannel('com.templink/media_store');
  
  // Loading states
  var isGeneratingPDF = false.obs;
  var isSavingToBackend = false.obs;
  var isDownloading = false.obs;

  @override
  void initState() {
    super.initState();
    // Automatically generate and save PDF when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoGenerateAndSave();
    });
  }

  // ============================================
  // AUTO GENERATE AND SAVE TO BACKEND
  // ============================================
  Future<void> _autoGenerateAndSave() async {
    try {
      isGeneratingPDF.value = true;
      
      // Generate PDF
      final pdfBytes = await _generatePDF();
      
      isGeneratingPDF.value = false;
      isSavingToBackend.value = true;
      
      // Generate filename
      final fileName = 'Resume_${controller.resumeData.value.fullName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      // Save to backend
      await controller.uploadResume(
        fileName: fileName,
        pdfBytes: pdfBytes,
        resumeData: controller.resumeData.value.toJson(),
      );
      
      isSavingToBackend.value = false;
      
      // Show success message (optional)
      Get.snackbar(
        '✅ Success',
        'Resume saved to your account',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      isGeneratingPDF.value = false;
      isSavingToBackend.value = false;
      print('Auto-save error: $e');
    }
  }

  // ============================================
  // PDF GENERATION METHODS
  // ============================================
  Future<Uint8List> _generatePDF() async {
    try {
      final Uint8List? imageFile = await screenshotController.capture(
        delay: const Duration(milliseconds: 200),
        pixelRatio: 3.0,
      );
      
      if (imageFile == null) {
        throw Exception('Failed to capture screenshot');
      }

      final pdf = pw.Document();
      final image = pw.MemoryImage(imageFile);
      
      final imgLib = img.decodeImage(imageFile);
      double imageWidth = imgLib?.width.toDouble() ?? 800;
      double imageHeight = imgLib?.height.toDouble() ?? 1100;
      
      double pageWidth = PdfPageFormat.a4.width;
      double pageHeight = PdfPageFormat.a4.height;
      
      double scale = (pageWidth / imageWidth).clamp(0.0, pageHeight / imageHeight);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                image,
                width: imageWidth * scale,
                height: imageHeight * scale,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
      
      return await pdf.save();
      
    } catch (e) {
      print('PDF generation error: $e');
      rethrow;
    }
  }

  // ============================================
  // DOWNLOAD PDF (LOCAL ONLY - NO API CALL)
  // ============================================
  Future<void> _downloadPDF() async {
    try {
      isDownloading.value = true;

      // Check permissions for Android
      if (Platform.isAndroid) {
        final hasPermission = await _checkPermissions();
        if (!hasPermission) {
          isDownloading.value = false;
          Get.snackbar(
            '❌ Permission Required',
            'Storage permission is needed to save PDF',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      // Generate PDF if not already generated
      final pdfBytes = await _generatePDF();

      // Save PDF locally
      String? savedPath;
      
      if (Platform.isAndroid) {
        savedPath = await _saveWithMediaStore(pdfBytes);
        if (savedPath == null) {
          savedPath = await _saveToDownloadsLegacy(pdfBytes);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'Resume_${controller.resumeData.value.fullName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        savedPath = '${directory.path}/$fileName';
        final file = File(savedPath);
        await file.writeAsBytes(pdfBytes);
      }

      isDownloading.value = false;

      if (savedPath != null) {
        Get.snackbar(
          '✅ Downloaded!',
          Platform.isAndroid 
              ? 'PDF saved to Downloads folder' 
              : 'PDF saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => OpenFile.open(savedPath!),
            child: const Text('OPEN', style: TextStyle(color: Colors.white)),
          ),
        );
        
        await OpenFile.open(savedPath);
      } else {
        throw Exception('Failed to save PDF');
      }
      
    } catch (e) {
      isDownloading.value = false;
      Get.snackbar(
        '❌ Error',
        'Failed to download: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Save using MediaStore (Android 10+)
  Future<String?> _saveWithMediaStore(Uint8List pdfBytes) async {
    try {
      final fileName = 'Resume_${controller.resumeData.value.fullName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final String? savedPath = await platform.invokeMethod(
        'saveToDownloads',
        {
          'fileName': fileName,
          'mimeType': 'application/pdf',
          'bytes': pdfBytes,
        },
      );
      
      return savedPath;
      
    } catch (e) {
      print('Failed to save with MediaStore: $e');
      return null;
    }
  }

  // Legacy save method (Android 9 and below)
  Future<String?> _saveToDownloadsLegacy(Uint8List pdfBytes) async {
    try {
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final fileName = 'Resume_${controller.resumeData.value.fullName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      await file.writeAsBytes(pdfBytes);
      
      try {
        await platform.invokeMethod('mediaScan', {'filePath': filePath});
      } catch (e) {
        print('Media scan error: $e');
      }
      
      return filePath;
      
    } catch (e) {
      print('Error saving to Downloads legacy: $e');
      return null;
    }
  }

  // Check permissions
  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      final int sdkVersion = await platform.invokeMethod('getSdkVersion');
      
      if (sdkVersion >= 30) {
        if (await Permission.manageExternalStorage.isGranted) {
          return true;
        }
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
        
      } else if (sdkVersion >= 29) {
        if (await Permission.storage.isGranted) {
          return true;
        }
        final status = await Permission.storage.request();
        return status.isGranted;
        
      } else {
        if (await Permission.storage.isGranted) {
          return true;
        }
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  // ============================================
  // SHARE PDF
  // ============================================
  Future<void> _sharePDF() async {
    try {
      final pdfBytes = await _generatePDF();
      
      final directory = await getTemporaryDirectory();
      final fileName = 'Resume_${controller.resumeData.value.fullName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'My Resume - ${controller.resumeData.value.fullName}',
      );
      
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to share: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 16),
          ),
        ),
        title: Obx(() => Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: controller.selectedTemplateAccent.value.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description_rounded,
                  color: controller.selectedTemplateAccent.value, size: 16),
            ),
            const SizedBox(width: 10),
            Text('Your Resume',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ],
        )),
        actions: [
          // Status indicators
          Obx(() {
            if (isGeneratingPDF.value) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.selectedTemplateAccent.value.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          controller.selectedTemplateAccent.value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Generating...', style: TextStyle(fontSize: 10)),
                  ],
                ),
              );
            } else if (isSavingToBackend.value) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: controller.selectedTemplateAccent.value.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          controller.selectedTemplateAccent.value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Saving...', style: TextStyle(fontSize: 10)),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          }),
          
          // PDF Download Button (NO API CALL)
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: isDownloading.value ? null : _downloadPDF,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.selectedTemplateAccent.value.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: controller.selectedTemplateAccent.value.withOpacity(0.3)),
                ),
                child: isDownloading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            controller.selectedTemplateAccent.value,
                          ),
                        ),
                      )
                    : Icon(Icons.picture_as_pdf_rounded,
                        color: controller.selectedTemplateAccent.value, size: 20),
              ),
            ),
          )),
          
          // Share PDF Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _sharePDF,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.selectedTemplateAccent.value.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: controller.selectedTemplateAccent.value.withOpacity(0.3)),
                ),
                child: Icon(Icons.share_rounded,
                    color: controller.selectedTemplateAccent.value, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.zoom_in_rounded,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Preview your resume',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
                Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('PDF Ready',
                    style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Resume preview with screenshot capability
          Expanded(
            child: InteractiveViewer(
              minScale: 0.3,
              maxScale: 3.0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Screenshot(
                    controller: screenshotController,
                    child: Obx(() => _buildResumeWidget()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BUILD RESUME WIDGET (Template selector)
  // ============================================
  Widget _buildResumeWidget() {
    switch (controller.selectedTemplateId.value) {
      case 'olivia':
        return _OliviaResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value);
      case 'austin':
        return _AustinResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value);
      case 'nova':
        return _NovaResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value);
      case 'ember':
        return _EmberResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value);
      case 'slate':
        return _SlateResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value);
      case 'rose':
        return _RoseResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value);
      case 'ats_classic':
      case 'ats_modern':
      case 'ats_executive':
        return _AtsResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value,
            templateId: controller.selectedTemplateId.value);
      default:
        return _AtsResumeRendered(
            data: controller.resumeData.value,
            accent: controller.selectedTemplateAccent.value,
            templateId: 'ats_classic');
    }
  }
}

// Note: Aapke saare rendered template classes (_OliviaResumeRendered, etc.)
// neeche hain. Main unhe dobara nahi likh raha kyunki aapke code mein pehle se hain.

Widget _rBar(double w, double h, Color c) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
        color: c, borderRadius: BorderRadius.circular(2)));

Widget _rBullet(String text, {Color? dotColor, double fontSize = 8}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            margin: const EdgeInsets.only(top: 4, right: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
                color: dotColor ?? const Color(0xFF666666),
                shape: BoxShape.circle)),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: fontSize,
                    color: const Color(0xFF555555),
                    height: 1.5))),
      ]),
    );

// ============================================
// NOTE: Yahan se neeche aapke saare rendered classes hain
// (_OliviaResumeRendered, _AustinResumeRendered, _NovaResumeRendered,
//  _EmberResumeRendered, _SlateResumeRendered, _RoseResumeRendered,
//  _AtsResumeRendered)
// 
// Ye classes pehle se aapke code mein hain, unhe yahan dobara likhne ki zaroorat nahi
// ============================================  // ============================================
  // YAHAN PE APKE EXISTING RENDERED CLASSES RAHENGE
  // (_OliviaResumeRendered, _AustinResumeRendered, _NovaResumeRendered,
  //  _EmberResumeRendered, _SlateResumeRendered, _RoseResumeRendered,
  //  _AtsResumeRendered) - Jo pehle se code mein hain
  // ============================================
  // Shared helpers

  // OLIVIA rendered
  class _OliviaResumeRendered extends StatelessWidget {
    final ResumeData data;
    final Color accent;
    const _OliviaResumeRendered({required this.data, required this.accent});

    static const _dark = Color(0xFF2C2C2C);

    @override
    Widget build(BuildContext context) {
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Sidebar
          Container(
            width: 200,
            color: _dark,
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data.fullName.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: 1)),
              const SizedBox(height: 5),
              Text(data.professionalTitle.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 7.5, letterSpacing: 2, color: Color(0xFFAAAAAA))),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFF3E3E3E)),
              _sh('Contact'),
              if (data.phone.isNotEmpty) _ci('📞', data.phone),
              if (data.email.isNotEmpty) _ci('✉', data.email),
              if (data.linkedIn.isNotEmpty) _ci('🌐', data.linkedIn),
              if (data.location.isNotEmpty) _ci('📍', data.location),
              if (data.educationList.isNotEmpty) ...[
                _sh('Education'),
                ...data.educationList.map((e) =>
                    _edu(e.institution, e.degree, '${e.startYear}–${e.endYear}')),
              ],
              if (data.skills.isNotEmpty) ...[
                _sh('Skills'),
                ...data.skills.map((s) =>
                    _sb(s, data.skillLevels[s] ?? 0.75)),
              ],
              if (data.languages.isNotEmpty) ...[
                _sh('Languages'),
                ...data.languages.map((l) => _li('${l.name} – ${l.proficiency}')),
              ],
            ]),
          ),
          // Main
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (data.summary.isNotEmpty) ...[
                  _st('Profile Summary'),
                  Text(data.summary,
                      style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF555555),
                          height: 1.65)),
                ],
                if (data.experiences.isNotEmpty) ...[
                  _st('Work Experience'),
                  ...data.experiences.map((e) => _wi(
                      e.title,
                      '${e.company}${e.location.isNotEmpty ? ' – ${e.location}' : ''}',
                      '${e.startDate}–${e.endDate}',
                      e.responsibilities
                          .where((r) => r.trim().isNotEmpty)
                          .toList())),
                ],
                if (data.awards.isNotEmpty) ...[
                  _st('Achievements'),
                  ...data.awards.map((a) => _rBullet(
                      '${a.name}${a.organization.isNotEmpty ? ' – ${a.organization}' : ''}${a.year.isNotEmpty ? ' (${a.year})' : ''}',
                      dotColor: accent)),
                ],
              ]),
            ),
          ),
        ]),
      );
    }

    Widget _sh(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(t.toUpperCase(),
            style: TextStyle(
                fontSize: 8,
                letterSpacing: 2,
                color: accent,
                fontWeight: FontWeight.w700)));
    Widget _ci(String icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 9)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 8, color: Color(0xFFBBBBBB)))),
        ]));
    Widget _edu(String s, String d, String y) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s,
              style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(d,
              style: const TextStyle(fontSize: 7.5, color: Color(0xFFAAAAAA))),
          Text(y,
              style: const TextStyle(fontSize: 7, color: Color(0xFF888888))),
        ]));
    Widget _sb(String label, double v) => Padding(
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
                  valueColor: AlwaysStoppedAnimation<Color>(accent))),
        ]));
    Widget _li(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(t,
            style: const TextStyle(fontSize: 8, color: Color(0xFFCCCCCC))));
    Widget _st(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.toUpperCase(),
              style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: _dark)),
          Container(height: 2, color: accent, margin: const EdgeInsets.only(top: 3)),
        ]));
    Widget _wi(String title, String co, String period, List<String> bullets) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                  style: TextStyle(
                      fontSize: 8, color: accent, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ...bullets.map((b) => _rBullet(b)),
            ]));
  }

  // AUSTIN rendered
  class _AustinResumeRendered extends StatelessWidget {
    final ResumeData data;
    final Color accent;
    const _AustinResumeRendered({required this.data, required this.accent});

    @override
    Widget build(BuildContext context) {
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: Container(
              color: const Color(0xFF1C1C1E),
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.fullName.toUpperCase(),
                        style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 2,
                            color: Colors.white,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text(data.professionalTitle,
                        style: TextStyle(
                            fontSize: 9, color: accent, letterSpacing: 1)),
                    const Divider(color: Color(0xFF333333), height: 24),
                    if (data.summary.isNotEmpty)
                      Text(data.summary,
                          style: const TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFFAAAAAA),
                              height: 1.65)),
                    if (data.experiences.isNotEmpty) ...[
                      _st('Experience'),
                      ...data.experiences.map((e) => _exp(
                          e.title,
                          '${e.company}${e.location.isNotEmpty ? ' – ${e.location}' : ''}',
                          '${e.startDate}–${e.endDate}',
                          e.responsibilities
                              .where((r) => r.trim().isNotEmpty)
                              .toList())),
                    ],
                    if (data.skills.isNotEmpty) ...[
                      _st('Skills'),
                      Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: data.skills
                              .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF333333)),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(s,
                                      style: const TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFFCCCCCC)))))
                              .toList()),
                    ],
                  ]),
            ),
          ),
          Container(
            width: 155,
            color: const Color(0xFF111111),
            child: Column(children: [
              Container(
                width: double.infinity,
                color: accent,
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
                child: Column(children: [
                  const SizedBox(height: 8),
                  Text(data.fullName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 1.5,
                          color: accent.computeLuminance() < 0.4
                              ? const Color(0xFF1C1C1E)
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1.1)),
                  const SizedBox(height: 3),
                  Text(data.professionalTitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 6.5,
                          color: (accent.computeLuminance() < 0.4
                                  ? const Color(0xFF1C1C1E)
                                  : Colors.white)
                              .withOpacity(0.7),
                          letterSpacing: 1)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ss('Contact'),
                      if (data.phone.isNotEmpty) _sc('📞', data.phone),
                      if (data.email.isNotEmpty) _sc('✉', data.email),
                      if (data.linkedIn.isNotEmpty) _sc('🌐', data.linkedIn),
                      if (data.location.isNotEmpty) _sc('📍', data.location),
                      if (data.educationList.isNotEmpty) ...[
                        _ss('Education'),
                        ...data.educationList.map((e) =>
                            _se(e.degree, e.institution,
                                '${e.startYear}–${e.endYear}')),
                      ],
                      if (data.languages.isNotEmpty) ...[
                        _ss('Languages'),
                        ...data.languages
                            .map((l) => _si('${l.name} – ${l.proficiency}')),
                      ],
                      if (data.certifications.isNotEmpty) ...[
                        _ss('Certifications'),
                        ...data.certifications.map((c) => _si(c.name)),
                      ],
                    ]),
              ),
            ]),
          ),
        ]),
      );
    }

    Widget _st(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 10),
        child: Row(children: [
          Text(t.toUpperCase(),
              style: TextStyle(
                  fontSize: 8.5,
                  letterSpacing: 3,
                  color: accent,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
              child: Container(height: 1, color: const Color(0xFF333333))),
        ]));
    Widget _exp(String role, String co, String dates, List<String> b) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(dates,
                  style: const TextStyle(
                      fontSize: 7.5, color: Color(0xFF666666))),
              Text(role,
                  style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text(co,
                  style: TextStyle(fontSize: 8, color: accent)),
              const SizedBox(height: 4),
              ...b.map((x) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('▸ ',
                            style: TextStyle(fontSize: 8, color: accent)),
                        Expanded(
                            child: Text(x,
                                style: const TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF888888),
                                    height: 1.5))),
                      ]))),
            ]));
    Widget _ss(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.toUpperCase(),
              style: TextStyle(
                  fontSize: 7.5,
                  letterSpacing: 2,
                  color: accent,
                  fontWeight: FontWeight.w700)),
          Container(
              height: 1,
              color: const Color(0xFF222222),
              margin: const EdgeInsets.only(top: 3)),
        ]));
    Widget _sc(String i, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          Text(i, style: TextStyle(fontSize: 9, color: accent)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(t,
                  style: const TextStyle(
                      fontSize: 7.5, color: Color(0xFFAAAAAA)))),
        ]));
    Widget _se(String d, String s, String y) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d,
              style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(s,
              style: const TextStyle(fontSize: 7.5, color: Color(0xFFAAAAAA))),
          Text(y, style: const TextStyle(fontSize: 7, color: Color(0xFF666666))),
        ]));
    Widget _si(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(t,
            style: const TextStyle(
                fontSize: 7.5, color: Color(0xFFAAAAAA), height: 1.6)));
  }

  // NOVA rendered
  class _NovaResumeRendered extends StatelessWidget {
    final ResumeData data;
    final Color accent;
    const _NovaResumeRendered({required this.data, required this.accent});

    @override
    Widget build(BuildContext context) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.fullName,
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111111))),
                    const SizedBox(height: 4),
                    Text(data.professionalTitle,
                        style: TextStyle(
                            fontSize: 10,
                            color: accent,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 4, children: [
                      if (data.phone.isNotEmpty) _tag('📞 ${data.phone}'),
                      if (data.email.isNotEmpty) _tag('✉ ${data.email}'),
                      if (data.location.isNotEmpty) _tag('📍 ${data.location}'),
                      if (data.portfolio.isNotEmpty) _tag('🌐 ${data.portfolio}'),
                    ]),
                  ]),
            ),
          ]),
          const SizedBox(height: 16),
          Container(height: 1.5, color: accent.withOpacity(0.25)),
          const SizedBox(height: 16),
          if (data.summary.isNotEmpty) ...[
            _section('PROFILE'),
            Text(data.summary,
                style: const TextStyle(
                    fontSize: 9, color: Color(0xFF555555), height: 1.7)),
            const SizedBox(height: 14),
          ],
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 6,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.experiences.isNotEmpty) ...[
                      _section('EXPERIENCE'),
                      ...data.experiences.map((e) => _novaExp(
                          e.title,
                          e.company,
                          '${e.startDate}–${e.endDate}',
                          e.responsibilities
                              .where((r) => r.trim().isNotEmpty)
                              .toList())),
                    ],
                  ]),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.skills.isNotEmpty) ...[
                      _section('SKILLS'),
                      Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: data.skills
                              .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: accent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: accent.withOpacity(0.25))),
                                  child: Text(s,
                                      style: const TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFF333333),
                                          fontWeight: FontWeight.w500))))
                              .toList()),
                      const SizedBox(height: 14),
                    ],
                    if (data.educationList.isNotEmpty) ...[
                      _section('EDUCATION'),
                      ...data.educationList.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.degree,
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF222222))),
                                Text(e.institution,
                                    style: const TextStyle(
                                        fontSize: 8, color: Color(0xFF888888))),
                                Text('${e.startYear}–${e.endYear}',
                                    style: TextStyle(
                                        fontSize: 7.5, color: accent)),
                              ]))),
                    ],
                    if (data.languages.isNotEmpty) ...[
                      _section('LANGUAGES'),
                      ...data.languages.map((l) => Text('${l.name} – ${l.proficiency}',
                          style: const TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFF555555),
                              height: 1.7))),
                    ],
                  ]),
            ),
          ]),
        ]),
      );
    }

    Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Text(t,
              style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w800,
                  color: accent)),
          const SizedBox(width: 8),
          Expanded(
              child: Container(height: 1, color: accent.withOpacity(0.2))),
        ]));
    Widget _tag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6)),
        child: Text(t,
            style: const TextStyle(fontSize: 7.5, color: Color(0xFF444444))));
    Widget _novaExp(
            String role, String co, String dates, List<String> bullets) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: accent, shape: BoxShape.circle)),
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
                            style: TextStyle(
                                fontSize: 8,
                                color: accent,
                                fontWeight: FontWeight.w600)),
                        Text(dates,
                            style: const TextStyle(
                                fontSize: 7.5, color: Color(0xFFAAAAAA))),
                      ]),
                      const SizedBox(height: 4),
                      ...bullets.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                    ]),
              ),
            ]));
  }

  // EMBER rendered
  class _EmberResumeRendered extends StatelessWidget {
    final ResumeData data;
    final Color accent;
    const _EmberResumeRendered({required this.data, required this.accent});

    @override
    Widget build(BuildContext context) {
      return Container(
        color: Colors.white,
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data.fullName,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 5),
              Text(data.professionalTitle,
                  style: const TextStyle(fontSize: 10, color: Colors.white70)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                if (data.phone.isNotEmpty) _tag(data.phone),
                if (data.email.isNotEmpty) _tag(data.email),
                if (data.location.isNotEmpty) _tag(data.location),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 6,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.summary.isNotEmpty) ...[
                        Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: accent.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: accent.withOpacity(0.15))),
                            child: Text(data.summary,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF444444),
                                    height: 1.7))),
                        const SizedBox(height: 16),
                      ],
                      if (data.experiences.isNotEmpty) ...[
                        _sec('EXPERIENCE'),
                        ...data.experiences.map((e) => _exp(
                            e.title,
                            '${e.company}  ·  ${e.startDate}–${e.endDate}',
                            e.responsibilities
                                .where((r) => r.trim().isNotEmpty)
                                .toList())),
                      ],
                    ]),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.skills.isNotEmpty) ...[
                        _sec('SKILLS'),
                        ...data.skills.map((s) => _skillRow(
                            s, data.skillLevels[s] ?? 0.75)),
                        const SizedBox(height: 14),
                      ],
                      if (data.educationList.isNotEmpty) ...[
                        _sec('EDUCATION'),
                        ...data.educationList.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.degree,
                                      style: const TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF222222))),
                                  Text(e.institution,
                                      style: const TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFF888888))),
                                  Text('${e.startYear}–${e.endYear}',
                                      style: TextStyle(
                                          fontSize: 7.5, color: accent)),
                                ]))),
                      ],
                      if (data.awards.isNotEmpty) ...[
                        _sec('AWARDS'),
                        ...data.awards.map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                                '• ${a.name}${a.year.isNotEmpty ? ' (${a.year})' : ''}',
                                style: const TextStyle(
                                    fontSize: 8, color: Color(0xFF555555))))),
                      ],
                    ]),
              ),
            ]),
          ),
        ]),
      );
    }

    Widget _tag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6)),
        child: Text(t,
            style: const TextStyle(fontSize: 7.5, color: Colors.white)));
    Widget _sec(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 7),
          Text(t,
              style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222))),
          const SizedBox(width: 7),
          Expanded(
              child:
                  Container(height: 1, color: const Color(0xFFEEEEEE))),
        ]));
    Widget _exp(String role, String co, List<String> b) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(role,
              style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222))),
          Text(co,
              style: TextStyle(
                  fontSize: 8,
                  color: accent,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...b.map((x) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('› ',
                        style: TextStyle(
                            fontSize: 9,
                            color: accent.withOpacity(0.7))),
                    Expanded(
                        child: Text(x,
                            style: const TextStyle(
                                fontSize: 8,
                                color: Color(0xFF555555),
                                height: 1.5))),
                  ]))),
        ]));
    Widget _skillRow(String label, double v) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor: AlwaysStoppedAnimation<Color>(accent))),
        ]));
  }

  // SLATE rendered
  class _SlateResumeRendered extends StatelessWidget {
    final ResumeData data;
    final Color accent;
    const _SlateResumeRendered({required this.data, required this.accent});

    static const _navyDark = Color(0xFF1E3A5F);

    @override
    Widget build(BuildContext context) {
      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            width: 195,
            color: _navyDark,
            padding: const EdgeInsets.all(22),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.fullName,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2)),
                  const SizedBox(height: 6),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(data.professionalTitle.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 6.5,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600))),
                  const SizedBox(height: 14),
                  _sh('Contact'),
                  if (data.phone.isNotEmpty) _ci('📞', data.phone),
                  if (data.email.isNotEmpty) _ci('✉', data.email),
                  if (data.linkedIn.isNotEmpty) _ci('🌐', data.linkedIn),
                  if (data.location.isNotEmpty) _ci('📍', data.location),
                  if (data.skills.isNotEmpty) ...[
                    _sh('Core Expertise'),
                    ...data.skills.take(5).map((s) =>
                        _sb(s, data.skillLevels[s] ?? 0.8)),
                  ],
                  if (data.boardMemberships.isNotEmpty) ...[
                    _sh('Board Memberships'),
                    ...data.boardMemberships
                        .where((b) => b.isNotEmpty)
                        .map((b) => _li(b)),
                  ],
                  if (data.educationList.isNotEmpty) ...[
                    _sh('Education'),
                    ...data.educationList.map((e) => _edu(
                        e.degree, e.institution, '${e.startYear}–${e.endYear}')),
                  ],
                ]),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.summary.isNotEmpty) ...[
                      Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: accent.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: accent.withOpacity(0.1))),
                          child: Text(data.summary,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF444444),
                                  height: 1.7))),
                      const SizedBox(height: 14),
                    ],
                    if (data.experiences.isNotEmpty) ...[
                      _st('Experience'),
                      ...data.experiences.map((e) => _wi(
                          e.title,
                          '${e.company}${e.location.isNotEmpty ? ' – ${e.location}' : ''}',
                          '${e.startDate}–${e.endDate}',
                          e.responsibilities
                              .where((r) => r.trim().isNotEmpty)
                              .toList())),
                    ],
                  ]),
            ),
          ),
        ]),
      );
    }

    Widget _sh(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 7),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 7.5,
                letterSpacing: 2,
                color: Color(0xFF93B8F5),
                fontWeight: FontWeight.w700)));
    Widget _ci(String i, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          Text(i, style: const TextStyle(fontSize: 9)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(t,
                  style: const TextStyle(
                      fontSize: 8, color: Color(0xFFCCCCCC)))),
        ]));
    Widget _sb(String label, double v) => Padding(
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
    Widget _li(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
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
    Widget _edu(String d, String s, String y) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d,
              style: const TextStyle(
                  fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(s,
              style: const TextStyle(
                  fontSize: 7.5, color: Color(0xFFAAAAAA))),
          Text(y,
              style: const TextStyle(
                  fontSize: 7, color: Color(0xFF93B8F5))),
        ]));
    Widget _st(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 10),
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
                  height: 2, color: const Color(0xFF2563EB).withOpacity(0.2))),
        ]));
    Widget _wi(String title, String co, String period, List<String> bullets) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            fontSize: 7.5, color: Color(0xFF999999))),
                  ]),
              Text(co,
                  style: TextStyle(
                      fontSize: 8,
                      color: accent,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              ...bullets.map((b) => _rBullet(b, dotColor: accent)),
            ]));
  }

  // ROSE rendered
  class _RoseResumeRendered extends StatelessWidget {
    final ResumeData data;
    final Color accent;
    const _RoseResumeRendered({required this.data, required this.accent});

    @override
    Widget build(BuildContext context) {
      return Container(
        color: const Color(0xFFFFF8FA),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [accent, const Color(0xFFFF85C2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: Column(children: [
              Text(data.fullName,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1)),
              const SizedBox(height: 5),
              Text(data.professionalTitle,
                  style: const TextStyle(fontSize: 10, color: Colors.white70)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (data.phone.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(data.phone,
                          style: const TextStyle(
                              fontSize: 7.5, color: Colors.white70))),
                if (data.email.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(data.email,
                          style: const TextStyle(
                              fontSize: 7.5, color: Colors.white70))),
                if (data.location.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(data.location,
                          style: const TextStyle(
                              fontSize: 7.5, color: Colors.white70))),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 6,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.summary.isNotEmpty) ...[
                        _section('ABOUT ME'),
                        Text(data.summary,
                            style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF555555),
                                height: 1.7)),
                        const SizedBox(height: 14),
                      ],
                      if (data.experiences.isNotEmpty) ...[
                        _section('EXPERIENCE'),
                        ...data.experiences.map((e) => _exp(
                            e.title,
                            e.company,
                            '${e.startDate}–${e.endDate}',
                            e.responsibilities
                                .where((r) => r.trim().isNotEmpty)
                                .toList())),
                      ],
                    ]),
              ),
              const SizedBox(width: 22),
              Expanded(
                flex: 4,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.skills.isNotEmpty) ...[
                        _section('SKILLS'),
                        ...data.skills.map((s) =>
                            _sb(s, data.skillLevels[s] ?? 0.8)),
                        const SizedBox(height: 14),
                      ],
                      if (data.educationList.isNotEmpty) ...[
                        _section('EDUCATION'),
                        ...data.educationList.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.degree,
                                      style: const TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF333333))),
                                  Text(e.institution,
                                      style: const TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFF888888))),
                                  Text('${e.startYear}–${e.endYear}',
                                      style: TextStyle(
                                          fontSize: 7.5, color: accent)),
                                ]))),
                      ],
                      if (data.languages.isNotEmpty) ...[
                        _section('LANGUAGES'),
                        ...data.languages.map((l) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(l.name,
                                      style: const TextStyle(
                                          fontSize: 8,
                                          color: Color(0xFF444444),
                                          fontWeight: FontWeight.w600)),
                                  Text(l.proficiency,
                                      style: const TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFFAAAAAA))),
                                ]))),
                      ],
                    ]),
              ),
            ]),
          ),
        ]),
      );
    }

    Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                  color: accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 7),
          Text(t,
              style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333))),
          const SizedBox(width: 7),
          Expanded(
              child: Container(height: 1, color: const Color(0xFFE8E8E8))),
        ]));
    Widget _exp(String role, String co, String dates, List<String> b) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(role,
                  style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222))),
              Row(children: [
                Text(co,
                    style: TextStyle(
                        fontSize: 8,
                        color: accent,
                        fontWeight: FontWeight.w600)),
                const Text('  ·  ',
                    style: TextStyle(fontSize: 8, color: Color(0xFFBBBBBB))),
                Text(dates,
                    style: const TextStyle(
                        fontSize: 8, color: Color(0xFFAAAAAA))),
              ]),
              const SizedBox(height: 4),
              ...b.map((x) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('◦ ',
                            style: TextStyle(
                                fontSize: 9,
                                color: accent.withOpacity(0.7))),
                        Expanded(
                            child: Text(x,
                                style: const TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF555555),
                                    height: 1.5))),
                      ]))),
            ]));
    Widget _sb(String label, double v) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFFFD6EC),
                  valueColor: AlwaysStoppedAnimation<Color>(accent))),
        ]));
  }

  // ATS rendered (covers classic, modern, executive)
  class _AtsResumeRendered extends StatelessWidget {
    final ResumeData data;
    final Color accent;
    final String templateId;

    const _AtsResumeRendered({
      required this.data,
      required this.accent,
      required this.templateId,
    });

    @override
    Widget build(BuildContext context) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 36),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Center(
            child: Column(children: [
              Text(data.fullName,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: templateId == 'ats_executive'
                          ? accent
                          : const Color(0xFF111111),
                      letterSpacing: 1.5)),
              const SizedBox(height: 5),
              Text(data.professionalTitle,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF444444),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 7),
              Wrap(alignment: WrapAlignment.center, spacing: 12, children: [
                if (data.phone.isNotEmpty)
                  Text(data.phone,
                      style: const TextStyle(
                          fontSize: 8.5, color: Color(0xFF555555))),
                if (data.email.isNotEmpty)
                  Text(data.email,
                      style: const TextStyle(
                          fontSize: 8.5, color: Color(0xFF555555))),
                if (data.linkedIn.isNotEmpty)
                  Text(data.linkedIn,
                      style: const TextStyle(
                          fontSize: 8.5, color: Color(0xFF555555))),
                if (data.location.isNotEmpty)
                  Text(data.location,
                      style: const TextStyle(
                          fontSize: 8.5, color: Color(0xFF555555))),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          Container(height: templateId == 'ats_executive' ? 2 : 1.5,
              color: accent),
          if (data.summary.isNotEmpty) ...[
            _sec('PROFESSIONAL SUMMARY'),
            Text(data.summary,
                style: const TextStyle(
                    fontSize: 9, color: Color(0xFF333333), height: 1.7)),
          ],
          if (data.experiences.isNotEmpty) ...[
            _sec('WORK EXPERIENCE'),
            ...data.experiences.map((e) => _job(
                e.title,
                '${e.company}${e.location.isNotEmpty ? '  |  ${e.location}' : ''}',
                '${e.startDate} – ${e.endDate}',
                e.responsibilities
                    .where((r) => r.trim().isNotEmpty)
                    .toList())),
          ],
          if (data.skills.isNotEmpty) ...[
            _sec('SKILLS'),
            Text(data.skills.join('  ·  '),
                style: const TextStyle(
                    fontSize: 9, color: Color(0xFF333333), height: 1.7)),
          ],
          if (data.educationList.isNotEmpty) ...[
            _sec('EDUCATION'),
            ...data.educationList.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.degree,
                                  style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111111))),
                              Text(e.institution,
                                  style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Color(0xFF444444))),
                              if (e.grade.isNotEmpty)
                                Text('GPA: ${e.grade}',
                                    style: const TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF777777),
                                        fontStyle: FontStyle.italic)),
                              if (e.honors.isNotEmpty)
                                Text(e.honors,
                                    style: const TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF777777),
                                        fontStyle: FontStyle.italic)),
                            ]),
                      ),
                      Text('${e.startYear} – ${e.endYear}',
                          style: const TextStyle(
                              fontSize: 8, color: Color(0xFF777777))),
                    ]))),
          ],
          if (data.certifications.isNotEmpty) ...[
            _sec('CERTIFICATIONS'),
            ...data.certifications.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Text('•  ',
                      style: TextStyle(
                          fontSize: 8.5, color: Color(0xFF333333))),
                  Expanded(
                      child: Text(
                          '${c.name}${c.organization.isNotEmpty ? ' – ${c.organization}' : ''}',
                          style: const TextStyle(
                              fontSize: 8.5, color: Color(0xFF333333)))),
                  if (c.year.isNotEmpty)
                    Text(c.year,
                        style: const TextStyle(
                            fontSize: 8, color: Color(0xFF888888))),
                ]))),
          ],
          if (data.awards.isNotEmpty) ...[
            _sec('AWARDS & RECOGNITION'),
            ...data.awards.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Text('•  ',
                      style: TextStyle(
                          fontSize: 8.5, color: Color(0xFF333333))),
                  Expanded(
                      child: Text(a.name,
                          style: const TextStyle(
                              fontSize: 8.5, color: Color(0xFF333333)))),
                  if (a.year.isNotEmpty)
                    Text(a.year,
                        style: const TextStyle(
                            fontSize: 8, color: Color(0xFF888888))),
                ]))),
          ],
          if (data.boardMemberships.isNotEmpty &&
              data.boardMemberships.any((b) => b.isNotEmpty)) ...[
            _sec('BOARD & ADVISORY ROLES'),
            ...data.boardMemberships
                .where((b) => b.isNotEmpty)
                .map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Text('•  ',
                          style: TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFF444444))),
                      Expanded(
                          child: Text(b,
                              style: const TextStyle(
                                  fontSize: 8.5,
                                  color: Color(0xFF333333)))),
                    ]))),
          ],
          if (data.keyMetrics.isNotEmpty &&
              data.keyMetrics.any((k) => k.isNotEmpty)) ...[
            _sec('KEY ACHIEVEMENTS'),
            ...data.keyMetrics
                .where((k) => k.isNotEmpty)
                .map((k) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('▸  ',
                              style: TextStyle(
                                  fontSize: 8.5, color: accent)),
                          Expanded(
                              child: Text(k,
                                  style: const TextStyle(
                                      fontSize: 8.5,
                                      color: Color(0xFF333333),
                                      height: 1.55))),
                        ]))),
          ],
        ]),
      );
    }

    Widget _sec(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t,
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: templateId == 'ats_executive'
                      ? accent
                      : const Color(0xFF111111),
                  letterSpacing: 1.5)),
          Container(
              height: 1,
              color: accent.withOpacity(0.5),
              margin: const EdgeInsets.only(top: 3)),
        ]));

    Widget _job(String title, String co, String dates, List<String> bullets) =>
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            fontSize: 8, color: Color(0xFF666666))),
                  ]),
              Text(co,
                  style: TextStyle(
                      fontSize: 8.5,
                      color: accent,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ',
                            style: TextStyle(
                                fontSize: 8.5, color: Color(0xFF222222))),
                        Expanded(
                            child: Text(b,
                                style: const TextStyle(
                                    fontSize: 8.5,
                                    color: Color(0xFF333333),
                                    height: 1.55))),
                      ]))),
            ]));
  }
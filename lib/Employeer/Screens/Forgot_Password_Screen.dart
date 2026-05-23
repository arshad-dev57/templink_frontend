import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:templink/Controllers/forgot_password_controller.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordController c = Get.put(ForgotPasswordController());

  // Focus nodes (UI only)
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    
    final maxWidth = isDesktop
        ? 480.0
        : (isTablet ? 500.w : double.infinity);

    return Scaffold(
      backgroundColor: Colors.white,
   
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // For desktop: Split screen layout
            if (isDesktop) {
              return Row(
                children: [
                  // Left Side - Form (50% width)
                  Expanded(
                    flex: 1,
                    child: _buildFormContent(
                      isDesktop: true,
                      maxWidth: maxWidth,
                    ),
                  ),
                  // Right Side - Image (50% width)
                  Expanded(
                    flex: 1,
                    child: _buildImageSection(),
                  ),
                ],
              );
            } 
            // For tablet: Split screen with smaller image
            else if (isTablet) {
              return Row(
                children: [
                  // Left Side - Form (60% width)
                  Expanded(
                    flex: 6,
                    child: _buildFormContent(
                      isDesktop: false,
                      maxWidth: maxWidth,
                    ),
                  ),
                  // Right Side - Image (40% width)
                  Expanded(
                    flex: 4,
                    child: _buildImageSection(),
                  ),
                ],
              );
            }
            // For mobile: Full screen form
            else {
              return _buildFormContent(
                isDesktop: false,
                maxWidth: maxWidth,
              );
            }
          },
        ),
      ),
    );
  }

  // ✅ Image Section
  Widget _buildImageSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=800&h=1200&fit=crop',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF4CAF50),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_reset_outlined,
                        size: 80.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Templink',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.responsive(
                    context: context,
                    mobile: 20.w,
                    tablet: 30.w,
                    desktop: 40.w,
                  ),
                  vertical: Responsive.responsive(
                    context: context,
                    mobile: 20.h,
                    tablet: 30.h,
                    desktop: 40.h,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_reset_outlined,
                      size: Responsive.responsive(
                        context: context,
                        mobile: 60.sp,
                        tablet: 70.sp,
                        desktop: 80.sp,
                      ),
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: Responsive.responsive(
                        context: context,
                        mobile: 16.h,
                        tablet: 20.h,
                        desktop: 24.h,
                      ),
                    ),
                    Text(
                      'Reset Your Password',
                      style: TextStyle(
                        fontSize: Responsive.responsive(
                          context: context,
                          mobile: 24.sp,
                          tablet: 30.sp,
                          desktop: 36.sp,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      softWrap: true,
                    ),
                    SizedBox(
                      height: Responsive.responsive(
                        context: context,
                        mobile: 12.h,
                        tablet: 14.h,
                        desktop: 16.h,
                      ),
                    ),
                    Text(
                      'Enter your email to receive a verification code',
                      style: TextStyle(
                        fontSize: Responsive.responsive(
                          context: context,
                          mobile: 14.sp,
                          tablet: 16.sp,
                          desktop: 18.sp,
                        ),
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      softWrap: true,
                    ),
                    SizedBox(
                      height: Responsive.responsive(
                        context: context,
                        mobile: 24.h,
                        tablet: 28.h,
                        desktop: 32.h,
                      ),
                    ),
                    _buildFeatureItem(Icons.verified_outlined, 'Secure Process'),
                    SizedBox(
                      height: Responsive.responsive(
                        context: context,
                        mobile: 12.h,
                        tablet: 14.h,
                        desktop: 16.h,
                      ),
                    ),
                    _buildFeatureItem(Icons.security_outlined, 'Protected Account'),
                    SizedBox(
                      height: Responsive.responsive(
                        context: context,
                        mobile: 12.h,
                        tablet: 14.h,
                        desktop: 16.h,
                      ),
                    ),
                    _buildFeatureItem(Icons.support_agent_outlined, '24/7 Support'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: Responsive.responsive(
            context: context,
            mobile: 20.sp,
            tablet: 22.sp,
            desktop: 24.sp,
          ),
        ),
        SizedBox(
          width: Responsive.responsive(
            context: context,
            mobile: 10.w,
            tablet: 11.w,
            desktop: 12.w,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Responsive.responsive(
                context: context,
                mobile: 13.sp,
                tablet: 14.sp,
                desktop: 16.sp,
              ),
              color: Colors.white.withOpacity(0.95),
              height: 1.3,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  // ✅ Form Content
  Widget _buildFormContent({
    required bool isDesktop,
    required double maxWidth,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop
              ? 40.0
              : (Responsive.isTablet(context) ? 32.w : 24.w),
          vertical: isDesktop ? 40.0 : 24.h,
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Obx(() {
            final step = c.currentStep.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isDesktop ? 16.0 : 24.h),

                // Step title
                Text(
                  c.stepTitles[step],
                  style: TextStyle(
                    fontSize: isDesktop ? 22.0 : 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: isDesktop ? 6.0 : 8.h),

                // Step description
                _buildStepDescription(step, isDesktop),

                SizedBox(height: isDesktop ? 24.0 : 32.h),

                // Step content
                if (step == 0) _buildEmailStep(isDesktop),
                if (step == 1) _buildOtpStep(isDesktop),
                if (step == 2) _buildPasswordStep(isDesktop),

                SizedBox(height: isDesktop ? 24.0 : 32.h),

                // Action button
                _buildActionButton(step, isDesktop),

                SizedBox(height: isDesktop ? 16.0 : 20.h),

                // Extra options
                _buildExtraOptions(step, isDesktop),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepDescription(int step, bool isDesktop) {
    switch (step) {
      case 0:
        return Text(
          "Enter your email address and we'll send you a verification code",
          style: TextStyle(
            fontSize: isDesktop ? 13.0 : 14.sp,
            color: Colors.grey.shade600,
          ),
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter the 6-digit code sent to",
              style: TextStyle(
                fontSize: isDesktop ? 13.0 : 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: isDesktop ? 3.0 : 4.h),
            Text(
              c.emailController.text.isNotEmpty ? c.emailController.text : "your email",
              style: TextStyle(
                fontSize: isDesktop ? 13.0 : 14.sp,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ],
        );
      case 2:
        return Text(
          "Create a new password for your account",
          style: TextStyle(
            fontSize: isDesktop ? 13.0 : 14.sp,
            color: Colors.grey.shade600,
          ),
        );
      default:
        return const SizedBox();
    }
  }

  // ✅ Email Step - Responsive
  Widget _buildEmailStep(bool isDesktop) {
    return Column(
      children: [
        Container(
          height: isDesktop ? 44.0 : 56.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
            borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
          ),
          child: TextField(
            controller: c.emailController,
            focusNode: _emailFocusNode,
            style: TextStyle(
              fontSize: isDesktop ? 14.0 : 16.sp,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 12.0 : 16.w,
                vertical: isDesktop ? 12.0 : 16.h,
              ),
              border: InputBorder.none,
              hintText: "Enter your email",
              hintStyle: TextStyle(
                fontSize: isDesktop ? 14.0 : 16.sp,
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey, size: isDesktop ? 20.0 : 22.sp),
              prefixIconConstraints: BoxConstraints(
                minHeight: isDesktop ? 40.0 : 48.w,
                minWidth: isDesktop ? 40.0 : 48.w,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => c.sendCode(),
          ),
        ),
      ],
    );
  }

  // ✅ OTP Step - Responsive
  Widget _buildOtpStep(bool isDesktop) {
    return Column(
      children: [
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: c.otpController,
          backgroundColor: Colors.transparent,
          autoDisposeControllers: false,
          textStyle: TextStyle(
            fontSize: isDesktop ? 18.0 : 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
            fieldHeight: isDesktop ? 44.0 : 56.h,
            fieldWidth: isDesktop ? 40.0 : 48.w,
            activeFillColor: Colors.white,
            activeColor: primary,
            selectedColor: primary,
            selectedFillColor: Colors.white,
            inactiveColor: Colors.grey.shade400,
            inactiveFillColor: Colors.white,
            errorBorderColor: Colors.red,
          ),
          cursorColor: Colors.black,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          keyboardType: TextInputType.number,
          onCompleted: (_) => c.verifyCode(),
          onChanged: (_) {
            if (c.otpError.value.isNotEmpty) c.otpError.value = "";
          },
          beforeTextPaste: (text) {
            return text != null && RegExp(r'^[0-9]+$').hasMatch(text);
          },
        ),

        // Error message
        Obx(() {
          if (c.otpError.value.isEmpty) return const SizedBox();
          return Padding(
            padding: EdgeInsets.only(top: isDesktop ? 8.0 : 12.h),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: isDesktop ? 14.0 : 16.sp),
                SizedBox(width: isDesktop ? 6.0 : 8.w),
                Text(
                  c.otpError.value,
                  style: TextStyle(
                    fontSize: isDesktop ? 11.0 : 13.sp,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          );
        }),

        SizedBox(height: isDesktop ? 12.0 : 16.h),

        // resend row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: TextStyle(
                fontSize: isDesktop ? 12.0 : 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            Obx(() {
              final t = c.resendTimer.value;
              if (t > 0) {
                return Text(
                  "Resend in $t seconds",
                  style: TextStyle(
                    fontSize: isDesktop ? 12.0 : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                );
              }
              return GestureDetector(
                onTap: c.isResending.value ? null : c.resendCode,
                child: Text(
                  c.isResending.value ? "Resending..." : "Resend code",
                  style: TextStyle(
                    fontSize: isDesktop ? 12.0 : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: c.isResending.value ? Colors.grey : primary,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  // ✅ Password Step - Responsive
  Widget _buildPasswordStep(bool isDesktop) {
    return Column(
      children: [
        // New password
        Container(
          height: isDesktop ? 44.0 : 56.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
            borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
          ),
          child: Obx(() => TextField(
                controller: c.newPasswordController,
                focusNode: _newPasswordFocusNode,
                obscureText: !c.showPassword.value,
                style: TextStyle(
                  fontSize: isDesktop ? 14.0 : 16.sp,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 12.0 : 16.w,
                    vertical: isDesktop ? 12.0 : 16.h,
                  ),
                  border: InputBorder.none,
                  hintText: "New password",
                  hintStyle: TextStyle(
                    fontSize: isDesktop ? 14.0 : 16.sp,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey, size: isDesktop ? 20.0 : 22.sp),
                  prefixIconConstraints: BoxConstraints(
                    minHeight: isDesktop ? 40.0 : 48.w,
                    minWidth: isDesktop ? 40.0 : 48.w,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.showPassword.value ? Icons.visibility_off : Icons.visibility,
                      size: isDesktop ? 18.0 : 20.sp,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => c.showPassword.value = !c.showPassword.value,
                  ),
                ),
                textInputAction: TextInputAction.next,
              )),
        ),

        SizedBox(height: isDesktop ? 12.0 : 16.h),

        // Confirm password
        Container(
          height: isDesktop ? 44.0 : 56.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
            borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
          ),
          child: Obx(() => TextField(
                controller: c.confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                obscureText: !c.showConfirmPassword.value,
                style: TextStyle(
                  fontSize: isDesktop ? 14.0 : 16.sp,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 12.0 : 16.w,
                    vertical: isDesktop ? 12.0 : 16.h,
                  ),
                  border: InputBorder.none,
                  hintText: "Confirm password",
                  hintStyle: TextStyle(
                    fontSize: isDesktop ? 14.0 : 16.sp,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey, size: isDesktop ? 20.0 : 22.sp),
                  prefixIconConstraints: BoxConstraints(
                    minHeight: isDesktop ? 40.0 : 48.w,
                    minWidth: isDesktop ? 40.0 : 48.w,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.showConfirmPassword.value ? Icons.visibility_off : Icons.visibility,
                      size: isDesktop ? 18.0 : 20.sp,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => c.showConfirmPassword.value = !c.showConfirmPassword.value,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => c.resetPassword(),
              )),
        ),

        SizedBox(height: isDesktop ? 12.0 : 16.h),

        _buildPasswordRequirements(isDesktop),
      ],
    );
  }

  Widget _buildPasswordRequirements(bool isDesktop) {
    final requirements = [
      "At least 8 characters",
      "At least 1 uppercase letter",
      "At least 1 number",
      "At least 1 special character",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password requirements:",
          style: TextStyle(
            fontSize: isDesktop ? 12.0 : 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 6.0 : 8.h),
        ...requirements.map(
          (req) => Padding(
            padding: EdgeInsets.only(bottom: isDesktop ? 3.0 : 4.h),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: isDesktop ? 14.0 : 16.sp, color: Colors.green.shade500),
                SizedBox(width: isDesktop ? 6.0 : 8.w),
                Text(
                  req,
                  style: TextStyle(
                    fontSize: isDesktop ? 11.0 : 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Action Button - Responsive
  Widget _buildActionButton(int step, bool isDesktop) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: isDesktop ? 44.0 : 48.h,
          child: ElevatedButton(
            onPressed: c.isLoading.value
                ? null
                : () {
                    if (step == 0) c.sendCode();
                    if (step == 1) c.verifyCode();
                    if (step == 2) c.resetPassword();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
              ),
              elevation: 0,
            ),
            child: c.isLoading.value
                ? SizedBox(
                    height: isDesktop ? 20.0 : 20.h,
                    width: isDesktop ? 20.0 : 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    step == 2 ? "Reset Password" : "Continue",
                    style: TextStyle(
                      fontSize: isDesktop ? 14.0 : 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ));
  }

  // ✅ Extra Options - Responsive
  Widget _buildExtraOptions(int step, bool isDesktop) {
    if (step == 0) {
      return Center(
        child: GestureDetector(
          onTap: () => Get.offAll(() => const LoginScreen()),
          child: Text(
            "Back to Login",
            style: TextStyle(
              fontSize: isDesktop ? 12.0 : 14.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
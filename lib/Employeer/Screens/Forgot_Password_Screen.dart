import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:templink/Controllers/forgot_password_controller.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';


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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => c.goBack(),
        ),
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            final step = c.currentStep.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Step title
                Text(
                  c.stepTitles[step],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Step description
                _buildStepDescription(step),

                const SizedBox(height: 32),

                // Step content
                if (step == 0) _buildEmailStep(),
                if (step == 1) _buildOtpStep(),
                if (step == 2) _buildPasswordStep(),

                const SizedBox(height: 32),

                // Action button
                _buildActionButton(step),

                const SizedBox(height: 20),

                // Extra options
                _buildExtraOptions(step),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepDescription(int step) {
    switch (step) {
      case 0:
        return Text(
          "Enter your email address and we'll send you a verification code",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter the 6-digit code sent to",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              c.emailController.text.isNotEmpty ? c.emailController.text : "your email",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ],
        );
      case 2:
        return Text(
          "Create a new password for your account",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildEmailStep() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: c.emailController,
        focusNode: _emailFocusNode,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.2,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          hintText: "Enter your email",
          hintStyle: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
            height: 1.2,
          ),
          prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey, size: 22),
          prefixIconConstraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => c.sendCode(),
      ),
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: c.otpController,
          backgroundColor: Colors.transparent,
          autoDisposeControllers: false,
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 56,
            fieldWidth: 48,
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
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  c.otpError.value,
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        // resend row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            Obx(() {
              final t = c.resendTimer.value;
              if (t > 0) {
                return Text(
                  "Resend in $t seconds",
                  style: TextStyle(
                    fontSize: 14,
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
                    fontSize: 14,
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

  Widget _buildPasswordStep() {
    return Column(
      children: [
        // New password
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() => TextField(
                controller: c.newPasswordController,
                focusNode: _newPasswordFocusNode,
                obscureText: !c.showPassword.value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                  hintText: "New password",
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.2),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 22),
                  prefixIconConstraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.showPassword.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => c.showPassword.value = !c.showPassword.value,
                  ),
                ),
                textInputAction: TextInputAction.next,
              )),
        ),

        const SizedBox(height: 16),

        // Confirm password
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() => TextField(
                controller: c.confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                obscureText: !c.showConfirmPassword.value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: InputBorder.none,
                  hintText: "Confirm password",
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.2),
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 22),
                  prefixIconConstraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                  suffixIcon: IconButton(
                    icon: Icon(
                      c.showConfirmPassword.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () =>
                        c.showConfirmPassword.value = !c.showConfirmPassword.value,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => c.resetPassword(),
              )),
        ),

        const SizedBox(height: 16),

        _buildPasswordRequirements(),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...requirements.map(
          (req) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade500),
                const SizedBox(width: 8),
                Text(req, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(int step) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: c.isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    step == 2 ? "Reset Password" : "Continue",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildExtraOptions(int step) {
    if (step == 0) {
      return Center(
        child: GestureDetector(
          onTap: () => Get.offAll(() => const LoginScreen()),
          child: Text(
            "Back to Login",
            style: TextStyle(
              fontSize: 14,
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

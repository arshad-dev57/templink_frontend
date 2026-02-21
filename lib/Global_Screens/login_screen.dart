import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Screens/Forgot_Password_Screen.dart';
import 'package:templink/Global_Screens/usertype_screen.dart';
import 'package:templink/Utils/colors.dart';

import '../Controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Step 1: Email
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _showEmailError = false;
  bool _isEmailSubmitted = false;

  // Step 2: Password
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _showPassword = false;

  bool _showGoogleError = false;
  bool _showAppleError = false;

  final LoginController loginController = Get.put(LoginController());

  void _handleEmailSubmit() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() => _showEmailError = true);
      return;
    }

    setState(() {
      _showEmailError = false;
      _isEmailSubmitted = true;
    });

    FocusScope.of(context).unfocus();
  }

  void _handleLogin() {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    loginController.loginuser(
      email: _emailController.text.trim(),
      pass: _passwordController.text,
     
    );
  }

  void _handleGoogleLogin() {
    setState(() {
      _showGoogleError = true;
      _showAppleError = false;
    });
  }

  void _handleAppleLogin() {
    setState(() {
      _showAppleError = true;
      _showGoogleError = false;
    });
  }

  void _goBackToEmail() {
    setState(() {
      _isEmailSubmitted = false;
      _passwordController.clear();
      _showGoogleError = false;
      _showAppleError = false;
    });
  }

  void _handleForgotPassword() {
    Get.to(const ForgotPasswordScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        centerTitle: true,
        title: const Text(
          "Templink",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEmailSubmitted) ...[
                _buildEmailScreen(),
                const SizedBox(height: 40),
                _buildSocialLoginSection(),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () => Get.offAll(() => RegisterChoiceScreen()),
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have a Templink account? ",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF14A800),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildPrivacyNotice(),
              ] else ...[
                _buildPasswordScreen(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          "Username or email",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: _showEmailError ? Colors.red : Colors.grey.shade400,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
              hintText: "Username or Email",
              hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleEmailSubmit(),
          ),
        ),
        if (_showEmailError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(
                "Oops! Email is incorrect",
                style: TextStyle(fontSize: 13, color: Colors.red.shade700),
              ),
            ],
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleEmailSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text(
              "Continue",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              _emailController.text,
              style: const TextStyle(fontSize: 16, color: primary),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          "Password",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_showPassword,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primary, width: 1.8),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _goBackToEmail,
              child: Text(
                "Not you?",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
            ),
            GestureDetector(
              onTap: _handleForgotPassword,
              child: const Text(
                "Forgot password?",
                style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ✅ Login Button with GetX loading
        Obx(() => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loginController.isLoading.value ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: loginController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Log In",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            )),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("or", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _handleGoogleLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(
                color: _showGoogleError ? Colors.red : Colors.grey.shade400,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: Image.asset('assets/google.png', height: 24, width: 24),
            label: const Text("Continue with Google", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ),
        if (_showGoogleError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text("Some internal error, please retry (code: 302)",
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700)),
            ],
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _handleAppleLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(
                color: _showAppleError ? Colors.red : Colors.grey.shade400,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: Image.asset('assets/apple.png', height: 24, width: 24, color: Colors.black),
            label: const Text("Continue with Apple", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ),
        if (_showAppleError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text("Some internal error, please retry (code: 302)",
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyNotice() {
    return Column(
      children: [
        const Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 16),
        Text(
          "Templink uses cookies for analytics, personalized content, and ads. "
          "By using Templink's services, you agree to the use of cookies.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text("Privacy Policy",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
            ),
            Text("•", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            GestureDetector(
              onTap: () {},
              child: Text("Terms of Service",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
            ),
            Text("•", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            GestureDetector(
              onTap: () {},
              child: Text("Cookie Policy",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}

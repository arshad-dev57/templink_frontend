import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Screens/Forgot_Password_Screen.dart';
import 'package:templink/Global_Screens/usertype_screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
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
    Responsive.init(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // For desktop: Split screen layout
            if (isDesktop) {
              return Row(
                children: [
                  // Left Side - Login Form (50% width)
                  Expanded(
                    flex: 1,
                    child: _buildFormContent(
                      isDesktop: true,
                      isTablet: false,
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
                      isTablet: true,
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
                isTablet: false,
              );
            }
          },
        ),
      ),
    );
  }

  // ✅ Image Section (Same as Forgot Password)
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
                        Icons.work_outline,
                        size: 80,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Templink',
                        style: TextStyle(
                          fontSize: 32,
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
                  horizontal: Responsive.isDesktop(context) ? 40 : 30,
                  vertical: Responsive.isDesktop(context) ? 40 : 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: Responsive.isDesktop(context) ? 80 : 70,
                      color: Colors.white,
                    ),
                    SizedBox(height: Responsive.isDesktop(context) ? 24 : 20),
                    Text(
                      'Find Your Dream Job',
                      style: TextStyle(
                        fontSize: Responsive.isDesktop(context) ? 36 : 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      softWrap: true,
                    ),
                    SizedBox(height: Responsive.isDesktop(context) ? 16 : 14),
                    Text(
                      'Connect with top employers and take your career to the next level',
                      style: TextStyle(
                        fontSize: Responsive.isDesktop(context) ? 18 : 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      softWrap: true,
                    ),
                    SizedBox(height: Responsive.isDesktop(context) ? 32 : 24),
                    _buildFeatureItem(Icons.verified_outlined, 'Thousands of Jobs'),
                    SizedBox(height: Responsive.isDesktop(context) ? 16 : 12),
                    _buildFeatureItem(Icons.people_outline, 'Top Companies Hiring'),
                    SizedBox(height: Responsive.isDesktop(context) ? 16 : 12),
                    _buildFeatureItem(Icons.support_agent_outlined, '24/7 Career Support'),
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
          size: Responsive.isDesktop(context) ? 24 : 22,
        ),
        SizedBox(width: Responsive.isDesktop(context) ? 12 : 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Responsive.isDesktop(context) ? 16 : 14,
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
    required bool isTablet,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop
              ? 40.0
              : (isTablet ? 32.0 : 24.0),
          vertical: isDesktop ? 40.0 : 24.0,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 480.0 : (isTablet ? 500.0 : double.infinity),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isDesktop ? 16 : 24),
              
              // Logo or Title
              if (!isDesktop)
                Center(
                  child: Text(
                    'Templink',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
              
              SizedBox(height: isDesktop ? 32 : 40),
              
              if (!_isEmailSubmitted) ...[
                _buildEmailScreen(isDesktop),
                const SizedBox(height: 40),
                _buildSocialLoginSection(isDesktop),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () => Get.offAll(() => const RegisterChoiceScreen()),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have a Templink account? ",
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 14,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 14,
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildPrivacyNotice(isDesktop),
              ] else ...[
                _buildPasswordScreen(isDesktop),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailScreen(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sign in to continue to your account",
          style: TextStyle(
            fontSize: isDesktop ? 14 : 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "Username or email",
          style: TextStyle(
            fontSize: isDesktop ? 14 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: isDesktop ? 48 : 48,
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
            style: TextStyle(fontSize: isDesktop ? 16 : 16, color: Colors.black87),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: InputBorder.none,
              hintText: "Email address",
              hintStyle: TextStyle(fontSize: isDesktop ? 16 : 16, color: Colors.grey.shade500),
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
                "Please enter a valid email address",
                style: TextStyle(fontSize: 13, color: Colors.red.shade700),
              ),
            ],
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 48 : 48,
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

  Widget _buildPasswordScreen(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 16,
            color: primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "Password",
          style: TextStyle(
            fontSize: isDesktop ? 14 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: isDesktop ? 48 : 48,
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_showPassword,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: isDesktop ? 16 : 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(fontSize: isDesktop ? 16 : 16, color: Colors.grey.shade500),
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
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: _handleForgotPassword,
              child: Text(
                "Forgot password?",
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 14,
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Login Button with GetX loading
        Obx(() => SizedBox(
          width: double.infinity,
          height: isDesktop ? 48 : 48,
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

  Widget _buildSocialLoginSection(bool isDesktop) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("or", style: TextStyle(fontSize: isDesktop ? 14 : 14, color: Colors.grey.shade600)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: isDesktop ? 48 : 48,
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
          height: isDesktop ? 48 : 48,
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

  Widget _buildPrivacyNotice(bool isDesktop) {
    return Column(
      children: [
        const Divider(color: Colors.grey, thickness: 1),
        const SizedBox(height: 16),
        Text(
          "Templink uses cookies for analytics, personalized content, and ads. "
          "By using Templink's services, you agree to the use of cookies.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isDesktop ? 12 : 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text("Privacy Policy",
                  style: TextStyle(fontSize: isDesktop ? 12 : 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
            ),
            Text("•", style: TextStyle(fontSize: isDesktop ? 12 : 12, color: Colors.grey.shade600)),
            GestureDetector(
              onTap: () {},
              child: Text("Terms of Service",
                  style: TextStyle(fontSize: isDesktop ? 12 : 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
            ),
            Text("•", style: TextStyle(fontSize: isDesktop ? 12 : 12, color: Colors.grey.shade600)),
            GestureDetector(
              onTap: () {},
              child: Text("Cookie Policy",
                  style: TextStyle(fontSize: isDesktop ? 12 : 12, color: Colors.grey.shade600, decoration: TextDecoration.underline)),
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
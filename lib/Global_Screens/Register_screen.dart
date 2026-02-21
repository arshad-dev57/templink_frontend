import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/register_controller.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Complete_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_profile_complete_screen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';

class RegisterScreen extends StatefulWidget {
  final bool isCompany;
  const RegisterScreen({super.key, required this.isCompany});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {   
  final RegisterController controller =
      Get.put(RegisterController(), permanent: true);

  final _formKey = GlobalKey<FormState>();
  bool _agreed = false;
  bool _sendEmails = false;
  bool _showPassword = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedCountry = 'Pakistan';
  final List<String> _countries = const [
    'Pakistan',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'India',
    'Germany',
    'France',
    'UAE',
    'Saudi Arabia',
  ];
  static const Color kGreen = primary;

  InputDecoration _decoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 2,
      helperText: ' ',
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kGreen, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.isCompany ? 'employer' : 'employee';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Templink',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to find work you love',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Obx(() {
                  final loading = controller.isLoading.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () async {
                              if (!_agreed) {
                                Get.snackbar(
                                  "Error",
                                  "Please accept terms and conditions",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              final ok = await controller.googleAuth(
                                role: role,
                                country: _selectedCountry,
                                sendEmails: _sendEmails,
                                termsAccepted: _agreed,
                              );
                              if (ok) {
                                if (widget.isCompany) {
                                  Get.to(() => EmployerProfileCompleteScreen(
                                      country: _selectedCountry));
                                } else {
                                  Get.to(() => EmployeeProfileCompleteScreen(
                                    firstName: _firstNameController.text.trim(),
                                    lastName: _lastNameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                    country: _selectedCountry,
                                    sendEmails: _sendEmails,
                                    termsAccepted: _agreed,
                                  ));
                                }
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.grey, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset('assets/google.png',
                              height: 24, width: 24),
                      label: Text(
                        loading ? "Please wait..." : "Continue with Google",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: Colors.grey.shade400, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "or",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: Colors.grey.shade400, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'First name',
                        controller: _firstNameController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'First name is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Last name',
                        controller: _lastNameController,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Last name is required'
                            : null,
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                    return null;
                  },
                ),
                _buildPasswordField(),
                _buildCountryDropdown(),
                Row(
                  children: [
                    Checkbox(
                      value: _sendEmails,
                      onChanged: (value) =>
                          setState(() => _sendEmails = value ?? false),
                      activeColor: kGreen,
                    ),
                    Expanded(
                      child: Text(
                        'Send me helpful emails to find rewarding work and job leads.',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: (value) =>
                          setState(() => _agreed = value ?? false),
                      activeColor: kGreen,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            text: 'Yes, I understand and agree to the ',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700),
                            children: const [
                              TextSpan(
                                text: 'Templink Terms of Service',
                                style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ', including the '),
                              TextSpan(
                                text: 'User Agreement',
                                style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(() {
                  final loading = controller.isLoading.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              if (!_agreed) {
                                Get.snackbar(
                                  "Error",
                                  "Please accept terms and conditions",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              // ✅ FIXED: Set basic info for BOTH roles
                              controller.setBasicInfo(
                                role: widget.isCompany ? 'employer' : 'employee',
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                country: _selectedCountry,
                                sendEmails: _sendEmails,
                                termsAccepted: _agreed,
                              );
                              
                              if (widget.isCompany) {
                                Get.offAll(() => EmployerProfileCompleteScreen(
                                    country: _selectedCountry));
                              } else {
                                Get.offAll(() => EmployeeProfileCompleteScreen(
                                  firstName: _firstNameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  country: _selectedCountry,
                                  sendEmails: _sendEmails,
                                  termsAccepted: _agreed,
                                ));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create my account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const LoginScreen()),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: _decoration(hint: label),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          textAlignVertical: TextAlignVertical.center,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 8) return 'Password must be at least 8 characters';
            return null;
          },
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          decoration: _decoration(
            hint: "password (min 8 characters)",
            prefixIcon: const Icon(Icons.lock_outline, size: 22, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: _decoration(hint: 'Select country'),
          icon: const Icon(Icons.arrow_drop_down),
          items: _countries
              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() => _selectedCountry = val);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
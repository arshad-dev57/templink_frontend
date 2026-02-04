import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/register_controller.dart';
import 'package:templink/Employeer/Screens/homescreen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';

class RegisterScreen extends StatelessWidget {
  final bool isCompany; // Parameter to decide fields
  const RegisterScreen({super.key, required this.isCompany});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    // Form key
    final _formKey = GlobalKey<FormState>();

    // Controllers
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController jobPositionController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final TextEditingController companyNameController = TextEditingController();
    final TextEditingController officialEmailController = TextEditingController();

    RxBool agreed = false.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -80,
              child: Container(
             width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                      Color(0xffB1843D),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
              ),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration:  BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
               colors: [
                      Color(0xffB1843D),
                    Colors.white.withOpacity(0.1),
                  ],
                  ),
                ),
              ),
            ),

            // Form
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Obx(() => Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
   Text(
                  'Templink',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),              const SizedBox(height: 30),

                      // Conditional fields
                      if (isCompany) ...[
                        _buildTextFormField(
                          "Company Name",
                          controller: companyNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Company name is required";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Official Email",
                          controller: officialEmailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Email is required";
                            if (!GetUtils.isEmail(value)) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Phone Number",
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Phone number is required";
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Enter a valid phone number";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Password",
                          controller: passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Password is required";
                            if (value.length < 6) return "Password must be at least 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Confirm Password",
                          controller: confirmPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Confirm your password";
                            if (value != passwordController.text) return "Passwords do not match";
                            return null;
                          },
                        ),
                      ] else ...[
                        _buildTextFormField(
                          "Full Name",
                          controller: fullNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Full name is required";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Email Address",
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Email is required";
                            if (!GetUtils.isEmail(value)) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Phone Number",
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Phone number is required";
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Enter a valid phone number";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Job Position",
                          controller: jobPositionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Job position is required";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Password",
                          controller: passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Password is required";
                            if (value.length < 6) return "Password must be at least 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          "Confirm Password",
                          controller: confirmPasswordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Confirm your password";
                            if (value != passwordController.text) return "Passwords do not match";
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Checkbox
                      Obx(() => Row(
                        children: [
                          Checkbox(
                            value: agreed.value,
                            onChanged: (value) => agreed.value = value!,
                            activeColor: primary,
                          ),
                          Expanded(
                            child: Text(
                              'By signing up you agree to the following terms and conditions',
                              style: TextStyle(
                                fontSize: 10,
                                color: primary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      )),

                      const SizedBox(height: 16),

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : () async {
                            if (!_formKey.currentState!.validate()) return;

                            if (!agreed.value) {
                              Get.snackbar("Error", "Please accept terms and conditions");
                              return;
                            }
Get.to( () => HomeScreen());
                            // if (isCompany) {
                            //   await controller.registerCompany(
                            //     companyName: companyNameController.text,
                            //     officialEmail: officialEmailController.text,
                            //     phoneNumber: phoneController.text,
                            //     password: passwordController.text,
                            //     confirmPassword: confirmPasswordController.text,
                            //   );
                            // } else {
                            //   await controller.registerEmployee(
                            //     fullName: fullNameController.text,
                            //     email: emailController.text,
                            //     phoneNumber: phoneController.text,
                            //     jobPosition: jobPositionController.text,
                            //     password: passwordController.text,
                            //     confirmPassword: confirmPasswordController.text,
                            //   );
                            // }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Get.to(() => LoginScreen());
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(fontWeight: FontWeight.w600, color: primary),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TextFormField builder
  Widget _buildTextFormField(String hint,
      {bool obscureText = false,
      TextEditingController? controller,
      String? Function(String?)? validator,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: primary),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }
}

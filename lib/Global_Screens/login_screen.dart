import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Global_Screens/Register_screen.dart';
import 'package:templink/Employeer/Screens/homescreen.dart';
import 'package:templink/Utils/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
                      bool _agreed = false;
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


            Center(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10), 
        Text(
          "Welcome Back!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8), 
        Text(
          "Please Log In To Continue Managing Your Company\nAccount And Employee Service",
          textAlign: TextAlign.center, 
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
   Text(
                  'Templink',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),        const SizedBox(height: 16),

        // Fields
        _buildTextField('Phone Number'),
        const SizedBox(height: 16),
        _buildTextField('Password', obscureText: true),
        const SizedBox(height: 16),
        _buildTextField('Confirm Password', obscureText: true),
        const SizedBox(height: 8),

        // ✅ Checkbox Row
        Row(
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return Transform.scale(
                  scale: 1.3, // Makes checkbox slightly bigger
                  child: Checkbox(
                    value: _agreed,
                    onChanged: (value) {
                      setState(() {
                        _agreed = value!;
                      });
                    },
                    activeColor: primary,
                  ),
                );
              },
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
        ),

      
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => const HomeScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text( 
              "Don't have an account?",
              style: TextStyle(
                fontSize: 14,
                color: primary,
              ),
            ),
            TextButton(
              onPressed: () {
Get.to(() => const RegisterScreen(isCompany: false));
              },
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )
      ],
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
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

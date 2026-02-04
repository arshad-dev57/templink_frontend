import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Global_Screens/Register_screen.dart';

class RegisterChoiceScreen extends StatelessWidget {
  const RegisterChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -80,
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

          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 10),
                child: TextButton(
                  onPressed: () {
                    Get.to(() => const LoginScreen());
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF2B3A67),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Text(
                  'Templink',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Employee Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => RegisterScreen(isCompany: false)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text('Register as Employee', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Employer Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: OutlinedButton(
                    onPressed: () => Get.to(() => RegisterScreen(isCompany: true)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primary, width: 1.5),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Register as Employer', style: TextStyle(color: Color(0xFF2B3A67), fontSize: 16)),
                  ),
                ),
                // Taki buttons niche wale circle se na takrayein
                const SizedBox(height: 150), 
              ],
            ),
          ),

          // --- Bottom Fixed Curve (Perfect Solution) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 250, // Height of the bottom area
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // The Curve Shape
                  Positioned(
                    bottom: -350, // Circle ko niche dhakel diya curve banane ke liye
                    child: Container(
                      width: MediaQuery.of(context).size.width * 2, // Double width for soft curve
                      height: 600,
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Text on top of the curve
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30, left: 40, right: 40),
                    child: Text(
                      'By signing up as an employee, you agree to the\nfollowing terms and conditions:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Global_Screens/Register_screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

class RegisterChoiceScreen extends StatefulWidget {
  const RegisterChoiceScreen({super.key});

  @override
  State<RegisterChoiceScreen> createState() => _RegisterChoiceScreenState();
}

class _RegisterChoiceScreenState extends State<RegisterChoiceScreen> {
  late final VideoPlayerController _videoC;

  @override
  void initState() {
    super.initState();
    _videoC = VideoPlayerController.asset("assets/splash.mp4")
      ..setLooping(true)
      ..setVolume(0) // mute
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoC.play();
      });
  }

  @override
  void dispose() {
    _videoC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive
    Responsive.init(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Video Background
          Positioned.fill(
            child: _videoC.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoC.value.size.width,
                      height: _videoC.value.size.height,
                      child: VideoPlayer(_videoC),
                    ),
                  )
                : Container(color: Colors.black),
          ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.80),
                  ],
                ),
              ),
            ),
          ),
          
          // Top Bar with Logo and Login Button
          Positioned(
            top: 55.h,
            left: 22.w,
            right: 22.w,
            child: SafeArea(
              child: Row(
                children: [
                  Text(
                    "Templink",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.responsive(
                        context: context,
                        mobile: 22.sp,
                        tablet: 28.sp,
                        desktop: 32.sp,
                      ),
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.to(() => const LoginScreen()),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: Responsive.padding(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: Responsive.responsive(
                          context: context,
                          mobile: 16.sp,
                          tablet: 18.sp,
                          desktop: 20.sp,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // Bottom Card
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: Responsive.padding(
                  left: 18,
                  right: 18,
                  bottom: Responsive.responsive(
                    context: context,
                    mobile: 18,
                    tablet: 24,
                    desktop: 32,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: Responsive.responsive(
                        context: context,
                        mobile: double.infinity,
                        tablet: 600.w,
                        desktop: 800.w,
                      ),
                      padding: Responsive.padding(
                        left: Responsive.responsive(
                          context: context,
                          mobile: 18,
                          tablet: 24,
                          desktop: 32,
                        ),
                        right: Responsive.responsive(
                          context: context,
                          mobile: 18,
                          tablet: 24,
                          desktop: 32,
                        ),
                        top: Responsive.responsive(
                          context: context,
                          mobile: 18,
                          tablet: 22,
                          desktop: 28,
                        ),
                        bottom: Responsive.responsive(
                          context: context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.w,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Responsive.sizedBox(height: 2),
                          
                          // Main Title
                          Text(
                            "Hire smarter. Work faster.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.responsive(
                                context: context,
                                mobile: 22.sp,
                                tablet: 28.sp,
                                desktop: 32.sp,
                              ),
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          
                          Responsive.sizedBox(height: 8),
                          
                          // Subtitle
                          Text(
                            Responsive.responsive(
                              context: context,
                              mobile: "Choose how you want to continue.\nFind jobs as an employee or hire talent as an employer.",
                              tablet: "Choose how you want to continue. Find jobs as an employee or hire talent as an employer.",
                              desktop: "Choose how you want to continue. Find jobs as an employee or hire talent as an employer.",
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.90),
                              fontSize: Responsive.responsive(
                                context: context,
                                mobile: 13.5.sp,
                                tablet: 16.sp,
                                desktop: 18.sp,
                              ),
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          Responsive.sizedBox(height: 16),
                          
                          // Buttons Row
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Get.to(() => RegisterScreen(isCompany: false)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: Responsive.padding(
                                      vertical: Responsive.responsive(
                                        context: context,
                                        mobile: 14,
                                        tablet: 16,
                                        desktop: 18,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Employee",
                                    style: TextStyle(
                                      fontSize: Responsive.responsive(
                                        context: context,
                                        mobile: 15.sp,
                                        tablet: 17.sp,
                                        desktop: 19.sp,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              
                              Responsive.sizedBox(width: 12),
                              
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.to(() => RegisterScreen(isCompany: true)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.65),
                                      width: 1.2.w,
                                    ),
                                    padding: Responsive.padding(
                                      vertical: Responsive.responsive(
                                        context: context,
                                        mobile: 14,
                                        tablet: 16,
                                        desktop: 18,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                  ),
                                  child: Text(
                                    "Employer",
                                    style: TextStyle(
                                      fontSize: Responsive.responsive(
                                        context: context,
                                        mobile: 15.sp,
                                        tablet: 17.sp,
                                        desktop: 19.sp,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          Responsive.sizedBox(height: 14),
                          
                          // Bottom Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.88),
                                  fontSize: Responsive.responsive(
                                    context: context,
                                    mobile: 13.sp,
                                    tablet: 15.sp,
                                    desktop: 17.sp,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(() => const LoginScreen()),
                                child: Text(
                                  "Log in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.responsive(
                                      context: context,
                                      mobile: 13.sp,
                                      tablet: 15.sp,
                                      desktop: 17.sp,
                                    ),
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.underline,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
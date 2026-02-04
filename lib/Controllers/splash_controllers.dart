import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Global_Screens/usertype_screen.dart';
class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Alignment> alignmentAnimation;
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    alignmentAnimation = Tween<Alignment>(
      begin: Alignment.bottomCenter,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 20.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animation
    animationController.forward();

    // Navigate after animation completes
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 1), () {
          Get.off(() => const RegisterChoiceScreen());
        });
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}

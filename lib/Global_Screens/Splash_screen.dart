import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Controllers/splash_controller.dart';
import 'package:templink/Utils/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashController controller =
        Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // AnimatedBuilder(
          //   animation: controller.animationController,
          //   builder: (context, child) {
          //     return Align(
          //       alignment: controller.alignmentAnimation.value,
          //       child: Transform.scale(
          //         scale: controller.scaleAnimation.value,
          //         child: child,
          //       ),
          //     );
          //   },
          //   child: Container(
          //     width: 200,
          //     height: 200,
          //     decoration: const BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: primary,
          //     ),
          //   ),
          // ),
           Text(
                  'Templink',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
        ]
      ),
    );
  }
}

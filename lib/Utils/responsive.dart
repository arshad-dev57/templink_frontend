import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Responsive {
  // Initialize ScreenUtil
  static void init(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // iPhone 12/13/14 design size (standard mobile)
      minTextAdapt: true,
      splitScreenMode: true,
    );
  }

  // Responsive width - direct ScreenUtil use
  static double width(double width) {
    return width.w;
  }

  // Responsive height
  static double height(double height) {
    return height.h;
  }

  // Responsive font size
  static double fontSize(double size) {
    return size.sp;
  }

  // Responsive radius
  static double radius(double radius) {
    return radius.r;
  }

  // Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Check if screen is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  // Check if screen is desktop/web
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  // Get responsive value based on screen type
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Responsive padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0).w,
      top: (top ?? vertical ?? all ?? 0).h,
      right: (right ?? horizontal ?? all ?? 0).w,
      bottom: (bottom ?? vertical ?? all ?? 0).h,
    );
  }

  // Responsive margin (same as padding)
  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return padding(
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  // Responsive SizedBox
  static SizedBox sizedBox({double? width, double? height}) {
    return SizedBox(
      width: width?.w,
      height: height?.h,
    );
  }

  // Responsive container with constraints
  static BoxConstraints constraints({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth?.w ?? 0,
      maxWidth: maxWidth?.w ?? double.infinity,
      minHeight: minHeight?.h ?? 0,
      maxHeight: maxHeight?.h ?? double.infinity,
    );
  }
  // Add this method to Responsive class for better spacing
static double verticalSpace(double height) {
  return height.h;
}

static double horizontalSpace(double width) {
  return width.w;
}
}


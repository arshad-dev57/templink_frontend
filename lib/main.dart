import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:templink/Global_Screens/Splash_screen.dart';
import 'package:templink/Services/Notificaton_Service.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:templink/paymenttesting_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // // Initialize Stripe
  // Stripe.publishableKey =
  //     "pk_test_51QY8GUFfoWN8tK9rycKFo91v04ba0VTvnmtz2t8QyyG6GCmFgkzNPduXu72mt3TFuoqyliOKgI6U9ve3PMBCXfTE0045P6hGKg";
  // await Stripe.instance.applySettings();
  
  // Initialize app services
  await _initializeApp();
  
  runApp(const MyApp());
  
  // ✅ Web ke liye notification service initialize nahi karenge
  if (!kIsWeb) {
    // Initialize notification service after app is built (only for mobile)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("🟡 Initializing NotificationService from main post frame (Mobile only)");
      await NotificationService.instance.init();
      await NotificationService.instance.debugPrintState(from: "main_postframe");
      
      // Check if user is already logged in
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('auth_user_id');
      
      if (userId != null && userId.isNotEmpty) {
        print("🟡 User already logged in with ID: $userId, setting up OneSignal");
        
        await NotificationService.instance.login(userId);
        await NotificationService.instance.verifyDeviceRegistration();
      }
    });
  } else {
    print("🟢 Running on Web - Notifications disabled");
  }
}

Future<void> _initializeApp() async {
  try {
    print('🟡 Initializing app services...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('auth_user_id') ?? '';
    
    print('🔍 Auth Token exists: ${token.isNotEmpty}');
    print('🔍 User ID exists: ${userId.isNotEmpty}');
    
    if (token.isNotEmpty && userId.isNotEmpty) {
      print('✅ User session found');
    } else {
      print('⚠️ No active user session');
    }
    
  } catch (e) {
    print('❌ Error initializing app services: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Templink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home:  SplashScreen(),
      builder: (context, child) {
        // Initialize responsive utility
        Responsive.init(context);
        return child!;
      },
    );
  }
}
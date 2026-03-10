import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Screens/Employee_HomeScreen.dart';
import 'package:templink/Employeer/Screens/Employeer_homescreen.dart';
import 'package:templink/Global_Screens/Splash_screen.dart';
import 'package:templink/Services/Notificaton_Service.dart';
import 'package:templink/Services/notification_api_service.dart';
import 'package:templink/config/api_config.dart';
import 'package:templink/controllers/chat_socket_controller.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey =
      "pk_test_51QY8GUFfoWN8tK9rycKFo91v04ba0VTvnmtz2t8QyyG6GCmFgkzNPduXu72mt3TFuoqyliOKgI6U9ve3PMBCXfTE0045P6hGKg";
  await Stripe.instance.applySettings();
  
  // Initialize app services
  await _initializeApp();
  
  runApp(const MyApp());
  
  // Initialize notification service after app is built
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    print("🟡 Initializing NotificationService from main post frame");
    await NotificationService.instance.init();
    await NotificationService.instance.debugPrintState(from: "main_postframe");
    
    // Check if user is already logged in
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('auth_user_id');
    
    if (userId != null && userId.isNotEmpty) {
      print("🟡 User already logged in with ID: $userId, setting up OneSignal");
      
      // Small delay before login
      await Future.delayed(const Duration(seconds: 1));
      
      await NotificationService.instance.login(userId);
      await Future.delayed(const Duration(seconds: 3));
      await NotificationService.instance.verifyDeviceRegistration();
      
      // Send a welcome back notification after a delay
      Future.delayed(const Duration(seconds: 8), () {
        NotificationApi.sendLoginSuccessPush(
          userId: userId,
          title: "Welcome Back",
          message: "You're still logged in to Templink",
        );
      });
    }
  });
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
      home: SplashScreen(),
    );
  }
}
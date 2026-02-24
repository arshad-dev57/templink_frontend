import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects.dart';
import 'package:templink/Employee/Screens/Employee_HomeScreen.dart';
import 'package:templink/Employeer/Screens/Employeer_Dashboard_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_homescreen.dart';
import 'package:templink/Employeer/Screens/Employeer_profile_complete_screen.dart';
import 'package:templink/Employeer/Screens/Employer_Active_Projects_Screen.dart';
import 'package:templink/Employeer/Screens/project_management_screen.dart';
import 'package:templink/Global_Screens/Chat_Users_List_Screen.dart';
import 'package:templink/Global_Screens/Splash_screen.dart';
import 'package:templink/Resume_Builder/Screens/Resume_Templetes_Screen.dart';
import 'package:templink/Resume_Builder/Screens/resume_form_screen.dart';
import 'package:templink/Services/Notificaton_Service.dart';
import 'package:templink/config/api_config.dart';
import 'package:templink/controllers/chat_socket_controller.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // // Initialize Stripe
  // Stripe.publishableKey =
  //     "pk_test_51QY8GUFfoWN8tK9rycKFo91v04ba0VTvnmtz2t8QyyG6GCmFgkzNPduXu72mt3TFuoqyliOKgI6U9ve3PMBCXfTE0045P6hGKg";
  // await Stripe.instance.applySettings();
  
  // Initialize app services
  await _initializeApp();
  
  runApp(const MyApp());
  
  // Initialize notifications after app starts
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   await NotificationService.instance.init();
  //   await NotificationService.instance.debugPrintState(from: "main_postframe");
  // });
}
// Initialize all app services
Future<void> _initializeApp() async {
  try {
    print('🟡 Initializing app services...');
        final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final userId = prefs.getString('auth_user_id') ?? '';
    final baseUrl = ApiConfig.baseUrl;
    
    print('🔍 Auth Token exists: ${token.isNotEmpty}');
    print('🔍 User ID exists: ${userId.isNotEmpty}');
    if (token.isNotEmpty && userId.isNotEmpty) {

      
      print('✅ ChatSocketController initialized globally');
    } else {
      print('⚠️ User not logged in - skipping socket initialization');
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
      home:  ResumeTemplate(),
    );
  }
}
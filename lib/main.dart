import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Screens/Employee_Active_Projects.dart';
import 'package:templink/Employee/Screens/Employee_HomeScreen.dart';
import 'package:templink/Employeer/Screens/Employeer_Dashboard_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_homescreen.dart';
import 'package:templink/Employeer/Screens/Employeer_profile_complete_screen.dart';
import 'package:templink/Employeer/Screens/Employer_Active_Projects_Screen.dart';
import 'package:templink/Employeer/Screens/project_management_screen.dart';
import 'package:templink/Global_Screens/Chat_Users_List_Screen.dart';
import 'package:templink/Global_Screens/Splash_screen.dart';
import 'package:templink/Resume_Builder/Screens/Resume_Dashboard_Screen.dart';
import 'package:templink/Services/Notificaton_Service.dart';
Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey =
  //     "pk_test_51QY8GUFfoWN8tK9rycKFo91v04ba0VTvnmtz2t8QyyG6GCmFgkzNPduXu72mt3TFuoqyliOKgI6U9ve3PMBCXfTE0045P6hGKg";
  // await Stripe.instance.applySettings();
  runApp(const MyApp());
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   await NotificationService.instance.init();
  //   await NotificationService.instance.debugPrintState(from: "main_postframe");
  // });
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
    );
  }
}

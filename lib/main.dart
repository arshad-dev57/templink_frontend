import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:templink/Global_Screens/Coins_purchase_screen.dart';

import 'package:templink/Global_Screens/Splash_screen.dart';
import 'package:templink/Global_Screens/payment_cancel_screen.dart';
import 'package:templink/Global_Screens/payment_sucess_screen.dart';
import 'package:templink/Services/Notificaton_Service.dart';
import 'package:templink/Utils/responsive.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();

  runApp(const MyApp());

  if (!kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("🟡 Initializing NotificationService from main post frame (Mobile only)");
      await NotificationService.instance.init();
      await NotificationService.instance.debugPrintState(from: "main_postframe");
      
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
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/payment-success', page: () => const PaymentSuccessScreen()),
        GetPage(name: '/payment-cancel', page: () => const PaymentCancelScreen()),
        GetPage(name: '/buy-coins', page: () => const CoinsPurchaseScreen()),
      ],
      // IMPORTANT: For web hash routing
      defaultTransition: Transition.fade,
      // Handle web redirects
      onGenerateRoute: (settings) {
        print("📍 onGenerateRoute: ${settings.name}");
        
        // Handle hash routes for web
        if (settings.name?.startsWith('/payment-success') == true) {
          return GetPageRoute(
            settings: settings,
            page: () => const PaymentSuccessScreen(),
            transition: Transition.fade,
          );
        }
        if (settings.name?.startsWith('/payment-cancel') == true) {
          return GetPageRoute(
            settings: settings,
            page: () => const PaymentCancelScreen(),
            transition: Transition.fade,
          );
        }
        return null;
      },
      home: const SplashScreen(),
      builder: (context, child) {
        Responsive.init(context);
        return child!;
      },
    );
  }
}
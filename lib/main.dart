import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:templink/Employee/Screens/Employee_Category_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Edit_Profile_Screen.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Screen.dart';
import 'package:templink/Employeer/Screens/PostProjectScreen.dart';
import 'package:templink/Employeer/Screens/Post_Job_screen.dart';
import 'package:templink/Global_Screens/Register_screen.dart';
import 'package:templink/Global_Screens/Spalsh_screen.dart';
import 'package:templink/Employeer/Screens/homescreen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Employeer/Screens/post_selection.dart';
import 'package:templink/Employeer/Screens/select_post_type_screen.dart';
import 'package:templink/Global_Screens/usertype_screen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_downloader
  await FlutterDownloader.initialize(
    debug: true, // Set to false in production
  );
  
  // Request necessary permissions
  await _requestPermissions();
  runApp(const MyApp());
}
Future<void> _requestPermissions() async {
  if (GetPlatform.isAndroid) {
    await Permission.storage.request();
    await Permission.camera.request();
    await Permission.photos.request();
    await Permission.notification.request();
  } else if (GetPlatform.isIOS) {
    await Permission.photos.request();
    await Permission.camera.request();
    await Permission.notification.request();
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

    @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  MyProfileScreen(),
    );
  } 
}

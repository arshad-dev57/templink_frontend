import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';

// Web-specific imports

class RegisterController extends GetxController {
  final isLoading = false.obs;

  final token = ''.obs;
  final user = Rxn<Map<String, dynamic>>();
  final userRole = ''.obs;

  String role = 'employee';
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String country = '';
  bool sendEmails = false;
  bool termsAccepted = false;

  final String baseUrl = ApiConfig.baseUrl;

  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';
  static const _kRole = 'auth_role';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  @override
  void onInit() {
    super.onInit();
    print("🔵 [RegisterController] onInit called");
    loadFromPrefs();
  }

  void setBasicInfo({
    required String role,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String country,
    required bool sendEmails,
    required bool termsAccepted,
  }) {
    print("🔵 [setBasicInfo] Setting basic info...");
    print("  - role: $role");
    print("  - firstName: $firstName");
    print("  - lastName: $lastName");
    print("  - email: $email");
    print("  - country: $country");
    print("  - sendEmails: $sendEmails");
    print("  - termsAccepted: $termsAccepted");

    this.role = role;
    this.firstName = firstName.trim();
    this.lastName = lastName.trim();
    this.email = email.trim().toLowerCase();
    this.password = password;
    this.country = country.trim();
    this.sendEmails = sendEmails;
    this.termsAccepted = termsAccepted;

    print("✅ [setBasicInfo] Basic info set successfully");
  }

  // ✅ Employee register
  Future<bool> registerEmployeeWithPhoto(
    Map<String, dynamic> employeeProfile,
    dynamic photoFile, // Changed to dynamic to accept both File and Uint8List
  ) async {
    print("🔵 [registerEmployeeWithPhoto] Called");
    print("  - employeeProfile keys: ${employeeProfile.keys.toList()}");
    
    if (kIsWeb) {
      print("  - Web mode: photo is bytes");
    } else {
      print("  - photoFile path: ${(photoFile as File).path}");
    }
    
    return _registerMultipart(
      profileKey: 'employeeProfile',
      profileData: employeeProfile,
      photoFile: photoFile,
    );
  }

  // ✅ Employer register
  Future<bool> registerEmployer(Map<String, dynamic> employerProfile) async {
    print("🔵 [registerEmployer] Called");
    print("  - employerProfile keys: ${employerProfile.keys.toList()}");
    employerProfile['country'] = country;
    print("  - country injected: $country");
    return _registerJson(profileKey: 'employerProfile', profileData: employerProfile);
  }

  // ✅ JSON register
  Future<bool> _registerJson({
    required String profileKey,
    required Map<String, dynamic> profileData,
  }) async {
    print("🔵 [_registerJson] Started");
    print("  - profileKey: $profileKey");
    print("  - profileData: $profileData");
    print("  - baseUrl: $baseUrl");

    isLoading.value = true;
    try {
      final uri = Uri.parse('$baseUrl/api/users/register');
      print("🔵 [_registerJson] Sending POST to: $uri");

      final payload = <String, dynamic>{
        "role": role,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "country": country,
        "sendEmails": sendEmails,
        "termsAccepted": termsAccepted,
        profileKey: profileData,
      };

      print("🔵 [_registerJson] Payload (without password):");
      payload.forEach((k, v) {
        if (k != 'password') print("  - $k: ${v.toString().length > 100 ? '${v.toString().substring(0, 100)}...' : v}");
      });

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("🔵 [_registerJson] Response received");
      print("  - Status Code: ${res.statusCode}");
      print("  - Body: ${res.body.length > 500 ? '${res.body.substring(0, 500)}...' : res.body}");

      Map<String, dynamic> data = {};
      try {
        data = (res.body.isNotEmpty)
            ? (jsonDecode(res.body) as Map<String, dynamic>)
            : {};
        print("✅ [_registerJson] JSON decoded successfully");
      } catch (parseErr) {
        print("❌ [_registerJson] JSON decode failed: $parseErr");
        Get.snackbar(
          'Error',
          'Invalid server response',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("✅ [_registerJson] Registration successful");

        token.value = (data['token'] ?? '').toString();
        user.value = (data['user'] is Map<String, dynamic>) ? data['user'] : null;

        final serverRole = (user.value?['role'] ?? role).toString();
        userRole.value = serverRole;

        await saveToPrefs(token: token.value, user: user.value, role: userRole.value);

        Get.snackbar(
          'Success',
          data['message']?.toString() ?? 'Registered successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF388E3C),
          colorText: const Color(0xFFFFFFFF),
        );
        return true;
      } else {
        final msg = data['message']?.toString() ?? 'Registration failed';
        print("❌ [_registerJson] Registration failed: $msg");
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e, stackTrace) {
      print("❌ [_registerJson] Exception caught: $e");
      Get.snackbar(
        'Error',
        'Network error: $e',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ MULTIPART register - FULLY WEB COMPATIBLE
  Future<bool> _registerMultipart({
    required String profileKey,
    required Map<String, dynamic> profileData,
    required dynamic photoFile,
  }) async {
    print("🔵 [_registerMultipart] Started");
    print("  - profileKey: $profileKey");
    print("  - baseUrl: $baseUrl");
    print("  - Platform: ${kIsWeb ? 'Web' : 'Mobile'}");

    isLoading.value = true;

    try {
      final uri = Uri.parse('$baseUrl/api/users/register');
      print("🔵 [_registerMultipart] Sending MultipartRequest to: $uri");

      final request = http.MultipartRequest('POST', uri);

      // text fields
      request.fields['role'] = role;
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['country'] = country;
      request.fields['sendEmails'] = sendEmails.toString();
      request.fields['termsAccepted'] = termsAccepted.toString();
      request.fields[profileKey] = jsonEncode(profileData);

      print("🔵 [_registerMultipart] Fields set");

      // ✅ WEB COMPATIBLE FILE HANDLING
      if (kIsWeb) {
        // Web: photoFile should be Uint8List
        if (photoFile is Uint8List) {
          print("🔵 [_registerMultipart] Web mode - using Uint8List");
          print("  - Bytes length: ${photoFile.length}");
          
          // Get filename from profileData or use default
          String fileName = 'profile_photo.jpg';
          if (profileData['photoUrl'] != null) {
            String url = profileData['photoUrl'].toString();
            if (url.contains('/')) {
              fileName = url.split('/').last;
            }
          }
          
          // Determine file extension
          String ext = 'jpg';
          if (fileName.contains('.')) {
            ext = fileName.split('.').last.toLowerCase();
          }
          if (ext.contains('?')) ext = ext.split('?').first;
          if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) ext = 'jpg';
          
          final contentType = ext == 'png' ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
          
          final multipartFile = http.MultipartFile.fromBytes(
            'photo',
            photoFile,
            filename: 'profile_photo.$contentType',
            contentType: MediaType('image', contentType),
          );
          
          request.files.add(multipartFile);
          print("✅ [_registerMultipart] File added to request (web mode)");
        } else {
          print("❌ [_registerMultipart] Web mode but photoFile is not Uint8List");
          Get.snackbar(
            'Error',
            'Invalid photo data on web',
            backgroundColor: const Color(0xFFD32F2F),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else {
        // Mobile: photoFile should be File
        if (photoFile is File) {
          print("🔵 [_registerMultipart] Mobile mode - using File");
          
          final photoExists = await photoFile.exists();
          final photoSize = photoExists ? await photoFile.length() : 0;
          final ext = photoFile.path.split('.').last.toLowerCase();

          print("  - Path: ${photoFile.path}");
          print("  - Exists: $photoExists");
          print("  - Size: $photoSize bytes");
          print("  - Extension: $ext");

          if (!photoExists) {
            print("❌ Photo file does NOT exist!");
            Get.snackbar('Error', 'Photo file not found', backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF));
            return false;
          }

          if (photoSize == 0) {
            print("❌ Photo file is empty");
            Get.snackbar('Error', 'Photo file is empty', backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF));
            return false;
          }

          final MediaType mediaType = (ext == 'png')
              ? MediaType('image', 'png')
              : (ext == 'webp')
                  ? MediaType('image', 'webp')
                  : MediaType('image', 'jpeg');

          request.files.add(
            await http.MultipartFile.fromPath(
              'photo',
              photoFile.path,
              contentType: mediaType,
            ),
          );
          print("✅ [_registerMultipart] File added to request (mobile mode)");
        } else {
          print("❌ Mobile mode but photoFile is not File");
          Get.snackbar('Error', 'Invalid photo data', backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF));
          return false;
        }
      }

      print("🔵 [_registerMultipart] Sending request...");
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      print("🔵 [_registerMultipart] Response received");
      print("  - Status Code: ${res.statusCode}");
      print("  - Body length: ${res.body.length}");
      if (res.body.length > 0 && res.body.length < 2000) {
        print("  - Body: ${res.body}");
      }

      Map<String, dynamic> data = {};
      try {
        data = (res.body.isNotEmpty) ? (jsonDecode(res.body) as Map<String, dynamic>) : {};
      } catch (e) {
        print("❌ Failed to parse JSON: $e");
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("✅ Registration successful!");

        token.value = (data['token'] ?? '').toString();
        user.value = (data['user'] is Map<String, dynamic>) ? data['user'] : null;

        final serverRole = (user.value?['role'] ?? role).toString();
        userRole.value = serverRole;

        await saveToPrefs(token: token.value, user: user.value, role: userRole.value);

        Get.snackbar(
          'Success',
          data['message']?.toString() ?? 'Registered successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF388E3C),
          colorText: const Color(0xFFFFFFFF),
        );
        return true;
      } else {
        final msg = data['message']?.toString() ?? 'Registration failed';
        print("❌ Registration failed: $msg");
        Get.snackbar('Error', msg, backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF), snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e, stackTrace) {
      print("❌ Exception caught: $e");
      print("  - StackTrace: $stackTrace");
      Get.snackbar('Error', 'Network error: $e', backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ GOOGLE AUTH
  Future<bool> googleAuth({
    required String role,
    required String country,
    required bool sendEmails,
    required bool termsAccepted,
  }) async {
    print("🔵 [googleAuth] Started");

    isLoading.value = true;

    try {
      final account = await _googleSignIn.signIn();

      if (account == null) {
        print("❌ Google Sign-In cancelled");
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        print("❌ idToken is null");
        Get.snackbar('Error', 'Google idToken null', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF));
        return false;
      }

      final uri = Uri.parse('$baseUrl/api/users/google');
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idToken": idToken,
          "role": role,
          "country": country,
          "sendEmails": sendEmails,
          "termsAccepted": termsAccepted,
        }),
      );

      Map<String, dynamic> data = {};
      try {
        data = (res.body.isNotEmpty) ? (jsonDecode(res.body) as Map<String, dynamic>) : {};
      } catch (e) {
        print("Failed to parse JSON: $e");
      }

      if (res.statusCode == 200) {
        token.value = (data['token'] ?? '').toString();
        user.value = (data['user'] is Map<String, dynamic>) ? data['user'] : null;

        final serverRole = (user.value?['role'] ?? role).toString();
        userRole.value = serverRole;

        await saveToPrefs(token: token.value, user: user.value, role: userRole.value);

        Get.snackbar('Success', data['message']?.toString() ?? 'Google auth successful', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF388E3C), colorText: const Color(0xFFFFFFFF));
        return true;
      } else {
        final msg = data['message']?.toString() ?? 'Google auth failed';
        Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF));
        return false;
      }
    } catch (e) {
      print("❌ Exception: $e");
      Get.snackbar('Error', 'Google auth error: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFD32F2F), colorText: const Color(0xFFFFFFFF));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Save to SharedPrefs
  Future<void> saveToPrefs({
    required String token,
    required Map<String, dynamic>? user,
    required String role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kToken, token);
      await prefs.setString(_kRole, role);

      if (user != null) {
        await prefs.setString(_kUser, jsonEncode(user));

        final userId = user["_id"]?.toString() ?? user["id"]?.toString() ?? "";
        final firstName = user["firstName"]?.toString() ?? "";
        final lastName = user["lastName"]?.toString() ?? "";

        String imageUrl = user["imageUrl"]?.toString() ?? "";
        if (imageUrl.isEmpty && role == "employer") {
          imageUrl = user["employerProfile"]?["logoUrl"]?.toString() ?? "";
        }
        if (imageUrl.isEmpty && role == "employee") {
          imageUrl = user["employeeProfile"]?["photoUrl"]?.toString() ?? "";
        }

        await prefs.setString('auth_user_id', userId);
        await prefs.setString('auth_first_name', firstName);
        await prefs.setString('auth_last_name', lastName);
        await prefs.setString('auth_image_url', imageUrl);
      }
    } catch (e) {
      print("❌ Failed to save: $e");
    }
  }

  // ✅ Load from SharedPrefs
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      token.value = prefs.getString(_kToken) ?? '';
      userRole.value = prefs.getString(_kRole) ?? '';

      final savedUserStr = prefs.getString(_kUser);
      if (savedUserStr != null && savedUserStr.isNotEmpty) {
        try {
          user.value = jsonDecode(savedUserStr) as Map<String, dynamic>;
        } catch (e) {
          print("Failed to decode user: $e");
          user.value = null;
        }
      }
    } catch (e) {
      print("❌ Failed to load: $e");
    }
  }

  Future<void> clearPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kUser);
      await prefs.remove(_kRole);
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_first_name');
      await prefs.remove('auth_last_name');
      await prefs.remove('auth_image_url');
    } catch (e) {
      print("❌ Failed to clear: $e");
    }
  }

  void clearAll() {
    token.value = '';
    user.value = null;
    userRole.value = '';

    role = 'employee';
    firstName = '';
    lastName = '';
    email = '';
    password = '';
    country = '';
    sendEmails = false;
    termsAccepted = false;
  }
}
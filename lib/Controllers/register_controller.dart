import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';

class RegisterController extends GetxController {
  final isLoading = false.obs;

  // API response
  final token = ''.obs;
  final user = Rxn<Map<String, dynamic>>();

  // role observable
  final userRole = ''.obs; // "employee" | "employer"

  // register basic fields (Register screen se)
  String role = 'employee';
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String country = '';
  bool sendEmails = false;
  bool termsAccepted = false;

  final String baseUrl = ApiConfig.baseUrl;

  // ✅ SharedPrefs keys
  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';
  static const _kRole = 'auth_role';

  // ✅ Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  @override
  void onInit() {
    super.onInit();
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
    this.role = role;
    this.firstName = firstName.trim();
    this.lastName = lastName.trim();
    this.email = email.trim().toLowerCase();
    this.password = password;
    this.country = country.trim();
    this.sendEmails = sendEmails;
    this.termsAccepted = termsAccepted;
  }

  // ✅ Employee register (photo required)
  Future<bool> registerEmployeeWithPhoto(
    Map<String, dynamic> employeeProfile,
    File photoFile,
  ) async {
    return _registerMultipart(
      profileKey: 'employeeProfile',
      profileData: employeeProfile,
      photoFile: photoFile,
    );
  }

  // ✅ Employer register (photo not used here, but you can add logo similarly later)
  Future<bool> registerEmployer(Map<String, dynamic> employerProfile) async {
    employerProfile['country'] = country;
    return _registerJson(profileKey: 'employerProfile', profileData: employerProfile);
  }

  // ✅ JSON register (kept for employer / google etc)
  Future<bool> _registerJson({
    required String profileKey,
    required Map<String, dynamic> profileData,
  }) async {
    isLoading.value = true;
    try {
      final uri = Uri.parse('$baseUrl/api/users/register');

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

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
print(res.statusCode);
print(res.body);
      final Map<String, dynamic> data =
          (res.body.isNotEmpty) ? (jsonDecode(res.body) as Map<String, dynamic>) : {};
print(data);
      if (res.statusCode == 200 || res.statusCode == 201) {
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
        print("error in register $msg");
        Get.snackbar(
          'Error',
          msg,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print("error in register $e");
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

  // ✅ MULTIPART register (PHOTO + FIELDS) - your edited version
  // ✅ MULTIPART register (PHOTO + FIELDS) - FIXED (force content-type + safe JSON parse)


Future<bool> _registerMultipart({
  required String profileKey,
  required Map<String, dynamic> profileData,
  required File photoFile,
}) async {
  isLoading.value = true;

  try {
    final uri = Uri.parse('$baseUrl/api/users/register');
    final request = http.MultipartRequest('POST', uri);

    // ✅ text fields
    request.fields['role'] = role;
    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['country'] = country;
    request.fields['sendEmails'] = sendEmails.toString();
    request.fields['termsAccepted'] = termsAccepted.toString();

    // ✅ profile object as JSON string
    request.fields[profileKey] = jsonEncode(profileData);

    // ✅ Debug
    print("PHOTO PATH: ${photoFile.path}");
    print("PHOTO EXISTS: ${await photoFile.exists()}");
    final ext = photoFile.path.split('.').last.toLowerCase();
    print("PHOTO EXT: $ext");

    // ✅ Force correct content-type (THIS FIXES your backend "Only image files are allowed")
    final MediaType mediaType = (ext == 'png')
        ? MediaType('image', 'png')
        : (ext == 'webp')
            ? MediaType('image', 'webp')
            : MediaType('image', 'jpeg'); // jpg/jpeg default

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo', // MUST match backend upload.single("photo")
        photoFile.path,
        contentType: mediaType,
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    print("REGISTER status: ${res.statusCode}");
    print("REGISTER content-type: ${res.headers['content-type']}");
    print("REGISTER body (first 200): ${res.body.substring(0, res.body.length > 200 ? 200 : res.body.length)}");

    // ✅ Safe JSON decode (avoid FormatException when backend returns HTML)
    final contentType = (res.headers['content-type'] ?? '').toLowerCase();
    Map<String, dynamic> data = {};

    if (contentType.contains('application/json')) {
      data = (res.body.isNotEmpty) ? (jsonDecode(res.body) as Map<String, dynamic>) : {};
      print("REGISTER JSON: $data");
    } else {
      // backend sent HTML error page
      final snippet = res.body.substring(0, res.body.length > 250 ? 250 : res.body.length);
      print("REGISTER NON-JSON BODY: $snippet");

      // Show readable error
      String msg = "Server error ${res.statusCode}";
      if (snippet.contains("Only image files are allowed")) {
        msg = "Only image files are allowed";
      } else if (snippet.contains("Error:")) {
        // try to extract a short message
        msg = "Server returned HTML error (${res.statusCode})";
      }

      Get.snackbar(
        'Error',
        msg,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // ✅ handle success/fail
    if (res.statusCode == 200 || res.statusCode == 201) {
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
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  } catch (e) {
    print("error in multipart register $e");
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

  // ✅ GOOGLE AUTH (same as your file)
  Future<bool> googleAuth({
    required String role,
    required String country,
    required bool sendEmails,
    required bool termsAccepted,
  }) async {
    isLoading.value = true;

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Google idToken null. SHA / Firebase config check karo.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
        );
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

      final Map<String, dynamic> data =
          (res.body.isNotEmpty) ? (jsonDecode(res.body) as Map<String, dynamic>) : {};

      if (res.statusCode == 200) {
        token.value = (data['token'] ?? '').toString();
        user.value = (data['user'] is Map<String, dynamic>) ? data['user'] : null;

        final serverRole = (user.value?['role'] ?? role).toString();
        userRole.value = serverRole;

        await saveToPrefs(token: token.value, user: user.value, role: userRole.value);

        Get.snackbar(
          'Success',
          data['message']?.toString() ?? 'Google auth successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF388E3C),
          colorText: const Color(0xFFFFFFFF),
        );

        return true;
      } else {
        final msg = data['message']?.toString() ?? 'Google auth failed';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Google auth error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Save token + user + role
  Future<void> saveToPrefs({
    required String token,
    required Map<String, dynamic>? user,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kRole, role);

    if (user != null) {
      await prefs.setString(_kUser, jsonEncode(user));
    }
  }

  // ✅ Load token + user + role
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    token.value = prefs.getString(_kToken) ?? '';
    userRole.value = prefs.getString(_kRole) ?? '';

    final savedUserStr = prefs.getString(_kUser);
    if (savedUserStr != null && savedUserStr.isNotEmpty) {
      try {
        user.value = jsonDecode(savedUserStr) as Map<String, dynamic>;
        final r = (user.value?['role'] ?? '').toString();
        if (userRole.value.isEmpty && r.isNotEmpty) {
          userRole.value = r;
          await prefs.setString(_kRole, r);
        }
      } catch (_) {
        user.value = null;
      }
    }
  }

  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
    await prefs.remove(_kRole);
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
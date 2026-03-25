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
    File photoFile,
  ) async {
    print("🔵 [registerEmployeeWithPhoto] Called");
    print("  - employeeProfile keys: ${employeeProfile.keys.toList()}");
    print("  - photoFile path: ${photoFile.path}");
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
        if (k != 'password') print("  - $k: $v");
      });

      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("🔵 [_registerJson] Response received");
      print("  - Status Code: ${res.statusCode}");
      print("  - Content-Type: ${res.headers['content-type']}");
      print("  - Body: ${res.body}");

      Map<String, dynamic> data = {};
      try {
        data = (res.body.isNotEmpty)
            ? (jsonDecode(res.body) as Map<String, dynamic>)
            : {};
        print("✅ [_registerJson] JSON decoded successfully: $data");
      } catch (parseErr) {
        print("❌ [_registerJson] JSON decode failed: $parseErr");
        print("  - Raw body: ${res.body}");
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

        print("  - token received: ${token.value.isNotEmpty ? 'YES (${token.value.length} chars)' : 'EMPTY ❌'}");
        print("  - user received: ${user.value != null ? 'YES' : 'NULL ❌'}");
        print("  - user data: ${user.value}");

        final serverRole = (user.value?['role'] ?? role).toString();
        userRole.value = serverRole;
        print("  - serverRole: $serverRole");

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
        print("❌ [_registerJson] Registration failed");
        print("  - Status: ${res.statusCode}");
        print("  - Message: $msg");
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
      print("  - StackTrace: $stackTrace");
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
      print("🔵 [_registerJson] isLoading reset to false");
    }
  }

  // ✅ MULTIPART register
  Future<bool> _registerMultipart({
    required String profileKey,
    required Map<String, dynamic> profileData,
    required File photoFile,
  }) async {
    print("🔵 [_registerMultipart] Started");
    print("  - profileKey: $profileKey");
    print("  - profileData: $profileData");
    print("  - baseUrl: $baseUrl");

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

      print("🔵 [_registerMultipart] Fields set (without password):");
      request.fields.forEach((k, v) {
        if (k != 'password') print("  - $k: $v");
      });

      // photo validation
      final photoExists = await photoFile.exists();
      final photoSize = photoExists ? await photoFile.length() : 0;
      final ext = photoFile.path.split('.').last.toLowerCase();

      print("🔵 [_registerMultipart] Photo info:");
      print("  - Path: ${photoFile.path}");
      print("  - Exists: $photoExists");
      print("  - Size: $photoSize bytes");
      print("  - Extension: $ext");

      if (!photoExists) {
        print("❌ [_registerMultipart] Photo file does NOT exist at path!");
        Get.snackbar(
          'Error',
          'Photo file not found',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (photoSize == 0) {
        print("❌ [_registerMultipart]");
        Get.snackbar(
          'Error',
          'Photo file is empty',
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final MediaType mediaType = (ext == 'png')
          ? MediaType('image', 'png')
          : (ext == 'webp')
              ? MediaType('image', 'webp')
              : MediaType('image', 'jpeg');

      print("🔵 [_registerMultipart] MediaType set: ${mediaType.type}/${mediaType.subtype}");

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
          contentType: mediaType,
        ),
      );

      print("🔵 [_registerMultipart] Photo file added to request");
      print("🔵 [_registerMultipart] Sending request...");

      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      print("🔵 [_registerMultipart] Response received");
      print("  - Status Code: ${res.statusCode}");
      print("  - Content-Type: ${res.headers['content-type']}");
      print("  - Body length: ${res.body.length} chars");
      print("  - Body (first 300): ${res.body.substring(0, res.body.length > 300 ? 300 : res.body.length)}");

      final contentType = (res.headers['content-type'] ?? '').toLowerCase();
      Map<String, dynamic> data = {};

      if (contentType.contains('application/json')) {
        try {
          data = (res.body.isNotEmpty)
              ? (jsonDecode(res.body) as Map<String, dynamic>)
              : {};
          print("✅ [_registerMultipart] JSON decoded: $data");
        } catch (parseErr) {
          print("❌ [_registerMultipart] JSON decode failed: $parseErr");
          print("  - Raw body: ${res.body}");
          Get.snackbar(
            'Error',
            'Invalid server response',
            backgroundColor: const Color(0xFFD32F2F),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else {
        final snippet = res.body.substring(0, res.body.length > 300 ? 300 : res.body.length);
        print("❌ [_registerMultipart] Non-JSON response received");
        print("  - Content-Type: $contentType");
        print("  - Body snippet: $snippet");

        String msg = "Server error ${res.statusCode}";
        if (snippet.contains("Only image files are allowed")) {
          msg = "Only image files are allowed";
          print("❌ [_registerMultipart] Backend rejected file type");
        } else if (snippet.contains("File too large")) {
          msg = "File too large";
          print("❌ [_registerMultipart] File too large");
        } else if (snippet.contains("Error:")) {
          msg = "Server returned HTML error (${res.statusCode})";
          print("❌ [_registerMultipart] Generic server error in HTML");
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

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("✅ [_registerMultipart] Registration successful");

        token.value = (data['token'] ?? '').toString();
        user.value = (data['user'] is Map<String, dynamic>) ? data['user'] : null;

        print("  - token received: ${token.value.isNotEmpty ? 'YES (${token.value.length} chars)' : 'EMPTY ❌'}");
        print("  - user received: ${user.value != null ? 'YES' : 'NULL ❌'}");
        print("  - user data: ${user.value}");

        final serverRole = (user.value?['role'] ?? role).toString();
        userRole.value = serverRole;
        print("  - serverRole: $serverRole");

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
        print("❌ [_registerMultipart] Registration failed");
        print("  - Status: ${res.statusCode}");
        print("  - Message: $msg");
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
      print("❌ [_registerMultipart] Exception caught: $e");
      print("  - StackTrace: $stackTrace");
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
      print("🔵 [_registerMultipart] isLoading reset to false");
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
    print("  - role: $role");
    print("  - country: $country");
    print("  - sendEmails: $sendEmails");
    print("  - termsAccepted: $termsAccepted");

    isLoading.value = true;

    try {
      print("🔵 [googleAuth] Attempting Google Sign-In...");
      final account = await _googleSignIn.signIn();

      if (account == null) {
        print("❌ [googleAuth] Google Sign-In cancelled by user (account is null)");
        return false;
      }

      print("✅ [googleAuth] Google account selected: ${account.email}");
      print("  - Display Name: ${account.displayName}");

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      print("🔵 [googleAuth] Auth tokens received:");
      print("  - idToken: ${idToken != null ? 'PRESENT (${idToken.length} chars)' : 'NULL ❌'}");
      print("  - accessToken: ${accessToken != null ? 'PRESENT' : 'NULL'}");

      if (idToken == null || idToken.isEmpty) {
        print("❌ [googleAuth] idToken is null or empty — SHA/Firebase config issue");
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
      print("🔵 [googleAuth] Sending POST to: $uri");

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

      print("🔵 [googleAuth] Response received");
      print("  - Status Code: ${res.statusCode}");
      print("  - Content-Type: ${res.headers['content-type']}");
      print("  - Body: ${res.body}");

      Map<String, dynamic> data = {};
      try {
        data = (res.body.isNotEmpty)
            ? (jsonDecode(res.body) as Map<String, dynamic>)
            : {};
        print("✅ [googleAuth] JSON decoded: $data");
      } catch (parseErr) {
        print("❌ [googleAuth] JSON decode failed: $parseErr");
        print("  - Raw body: ${res.body}");
        Get.snackbar(
          'Error',
          'Invalid server response',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
        );
        return false;
      }

      if (res.statusCode == 200) {
        print("✅ [googleAuth] Google auth successful");

        token.value = (data['token'] ?? '').toString();
        user.value = (data['user'] is Map<String, dynamic>) ? data['user'] : null;

        print("  - token received: ${token.value.isNotEmpty ? 'YES (${token.value.length} chars)' : 'EMPTY ❌'}");
        print("  - user received: ${user.value != null ? 'YES' : 'NULL ❌'}");
        print("  - user data: ${user.value}");

        final serverRole = (user.value?['role'] ?? role).toString();
        userRole.value = serverRole;
        print("  - serverRole: $serverRole");

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
        print("❌ [googleAuth] Google auth failed");
        print("  - Status: ${res.statusCode}");
        print("  - Message: $msg");
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
        );
        return false;
      }
    } catch (e, stackTrace) {
      print("❌ [googleAuth] Exception caught: $e");
      print("  - StackTrace: $stackTrace");
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
      print("🔵 [googleAuth] isLoading reset to false");
    }
  }

  // ✅ Save to SharedPrefs
  Future<void> saveToPrefs({
    required String token,
    required Map<String, dynamic>? user,
    required String role,
  }) async {
    print("🔵 [saveToPrefs] Saving to SharedPreferences...");
    print("  - token: ${token.isNotEmpty ? 'PRESENT (${token.length} chars)' : 'EMPTY ❌'}");
    print("  - role: $role");
    print("  - user: ${user != null ? 'PRESENT' : 'NULL ❌'}");

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
          print("  - imageUrl from employerProfile.logoUrl: $imageUrl");
        }
        if (imageUrl.isEmpty && role == "employee") {
          imageUrl = user["employeeProfile"]?["photoUrl"]?.toString() ?? "";
          print("  - imageUrl from employeeProfile.photoUrl: $imageUrl");
        }

        await prefs.setString('auth_user_id', userId);
        await prefs.setString('auth_first_name', firstName);
        await prefs.setString('auth_last_name', lastName);
        await prefs.setString('auth_image_url', imageUrl);

        print("✅ [saveToPrefs] All keys saved:");
        print("  - auth_token: ${token.isNotEmpty ? 'SAVED' : 'EMPTY ❌'}");
        print("  - auth_role: $role");
        print("  - auth_user_id: ${userId.isNotEmpty ? userId : 'EMPTY ❌'}");
        print("  - auth_first_name: ${firstName.isNotEmpty ? firstName : 'EMPTY ❌'}");
        print("  - auth_last_name: ${lastName.isNotEmpty ? lastName : 'EMPTY ❌'}");
        print("  - auth_image_url: ${imageUrl.isNotEmpty ? imageUrl : 'EMPTY (no photo)'}");
      } else {
        print("⚠️ [saveToPrefs] user is null — skipping name/image/userId save");
      }
    } catch (e, stackTrace) {
      print("❌ [saveToPrefs] Failed to save: $e");
      print("  - StackTrace: $stackTrace");
    }
  }

  // ✅ Load from SharedPrefs
  Future<void> loadFromPrefs() async {
    print("🔵 [loadFromPrefs] Loading from SharedPreferences...");
    try {
      final prefs = await SharedPreferences.getInstance();

      token.value = prefs.getString(_kToken) ?? '';
      userRole.value = prefs.getString(_kRole) ?? '';

      print("  - auth_token: ${token.value.isNotEmpty ? 'FOUND (${token.value.length} chars)' : 'NOT FOUND'}");
      print("  - auth_role: ${userRole.value.isNotEmpty ? userRole.value : 'NOT FOUND'}");

      final savedUserStr = prefs.getString(_kUser);
      print("  - auth_user string: ${savedUserStr != null ? 'FOUND (${savedUserStr.length} chars)' : 'NOT FOUND'}");

      if (savedUserStr != null && savedUserStr.isNotEmpty) {
        try {
          user.value = jsonDecode(savedUserStr) as Map<String, dynamic>;
          print("✅ [loadFromPrefs] User decoded successfully");
          print("  - user keys: ${user.value?.keys.toList()}");

          final r = (user.value?['role'] ?? '').toString();
          if (userRole.value.isEmpty && r.isNotEmpty) {
            userRole.value = r;
            await prefs.setString(_kRole, r);
            print("  - role updated from user object: $r");
          }
        } catch (parseErr) {
          print("❌ [loadFromPrefs] Failed to decode user JSON: $parseErr");
          user.value = null;
        }
      } else {
        print("⚠️ [loadFromPrefs] No saved user found");
      }

      print("✅ [loadFromPrefs] Done — role: ${userRole.value}, hasToken: ${token.value.isNotEmpty}");
    } catch (e, stackTrace) {
      print("❌ [loadFromPrefs] Exception: $e");
      print("  - StackTrace: $stackTrace");
    }
  }

  Future<void> clearPrefs() async {
    print("🔵 [clearPrefs] Clearing all SharedPreferences keys...");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kUser);
      await prefs.remove(_kRole);
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_first_name');
      await prefs.remove('auth_last_name');
      await prefs.remove('auth_image_url');
      print("✅ [clearPrefs] All keys cleared");
    } catch (e) {
      print("❌ [clearPrefs] Failed: $e");
    }
  }

  void clearAll() {
    print("🔵 [clearAll] Clearing all in-memory state...");
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
    print("✅ [clearAll] In-memory state cleared");
  }
}
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';

class PdfDownloadHelper {
  // ✅ Android ke liye MediaStore channel
  static const MethodChannel _channel =
      MethodChannel('com.templink/media_store');

  // ==================== MAIN DOWNLOAD METHOD ====================
  static Future<void> downloadPDF({
    required String contractId,
    required String contractNumber,
  }) async {
    try {
      // Step 1: Downloading snackbar dikhao
      Get.snackbar(
        '⏳ Downloading...',
        'Please wait...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 60),
        showProgressIndicator: true,
        isDismissible: false,
      );

      // Step 2: Token lo
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      // Step 3: API se PDF bytes lo
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/contracts/$contractId/download'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        Get.closeAllSnackbars();
        Get.snackbar(
          '❌ Error',
          'Failed to download PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Uint8List bytes = response.bodyBytes;
      final String fileName =
          'Contract_${contractNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Step 4: Platform ke hisaab se save karo
      String savedPath = '';

      if (Platform.isAndroid) {
        savedPath = await _saveToAndroidDownloads(bytes, fileName);
      } else if (Platform.isIOS) {
        savedPath = await _saveToIosDocuments(bytes, fileName);
      }

      // Step 5: Success
      Get.closeAllSnackbars();

      if (savedPath.isNotEmpty) {
        Get.snackbar(
          '✅ Downloaded!',
          Platform.isAndroid
              ? 'Saved to Downloads: $fileName'
              : 'Saved to Files: $fileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => OpenFile.open(savedPath),
            child: const Text(
              'OPEN',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        '❌ Error',
        'Download failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================== ANDROID: MediaStore ke zariye Downloads ====================
  static Future<String> _saveToAndroidDownloads(
      Uint8List bytes, String fileName) async {
    try {
      // ✅ Method 1: MediaStore use karo (Android 10+) - yeh ACTUAL Downloads folder mein save karta hai
      if (await _isAndroid10OrAbove()) {
        return await _saveViaMediaStore(bytes, fileName);
      } else {
        // Method 2: Android 9 aur neeche ke liye direct path
        return await _saveToDirectDownloads(bytes, fileName);
      }
    } catch (e) {
      // Fallback
      return await _saveToDirectDownloads(bytes, fileName);
    }
  }

  // ✅ MediaStore se save (Android 10+ - bilkul actual Downloads folder)
  static Future<String> _saveViaMediaStore(
      Uint8List bytes, String fileName) async {
    try {
      // Android ka MediaStore use karo
      final result = await _channel.invokeMethod('saveToDownloads', {
        'fileName': fileName,
        'mimeType': 'application/pdf',
        'bytes': bytes,
      });
      return result?.toString() ?? '';
    } catch (e) {
      // Agar MethodChannel kaam na kare to direct save karo
      return await _saveToDirectDownloads(bytes, fileName);
    }
  }

  // Direct Downloads folder mein save
  static Future<String> _saveToDirectDownloads(
      Uint8List bytes, String fileName) async {
    final downloadsDir = Directory('/storage/emulated/0/Download');

    if (await downloadsDir.exists()) {
      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      // ✅ Media scan karo taake file manager mein dikhe
      await _mediaScan(filePath);
      return filePath;
    } else {
      // Fallback: app external storage
      final extDir = await getExternalStorageDirectory();
      final filePath = '${extDir?.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    }
  }

  // Media scan - file manager ko notify karo
  static Future<void> _mediaScan(String filePath) async {
    try {
      await _channel.invokeMethod('mediaScan', {'filePath': filePath});
    } catch (e) {
      // Ignore - optional step
    }
  }

  // ✅ iOS ke liye Documents mein save
  static Future<String> _saveToIosDocuments(
      Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  static Future<bool> _isAndroid10OrAbove() async {
    if (!Platform.isAndroid) return false;
    try {
      final result =
          await _channel.invokeMethod<int>('getSdkVersion') ?? 0;
      return result >= 29; // Android 10 = API 29
    } catch (e) {
      return false;
    }
  }
}
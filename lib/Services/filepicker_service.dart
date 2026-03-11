// lib/services/file_picker_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart' as path;

class FilePickerService extends GetxController {
  static FilePickerService get to => Get.find();

  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // Pick and upload file
  Future<Map<String, dynamic>?> pickAndUploadFile({
    required String baseUrl,
    required String token,
    required String toUserId,
    String? conversationId,
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result == null) return null;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileSize = result.files.single.size;
      final mimeType = mime(fileName) ?? 'application/octet-stream';

      // Show platform-specific file size warning
      if (fileSize > 100 * 1024 * 1024) { // 100MB limit
        Get.snackbar(
          'File Too Large',
          'Maximum file size is 100MB',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      // Upload file
      isUploading.value = true;
      uploadProgress.value = 0.0;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/chat/upload'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.fields['toUserId'] = toUserId;
      if (conversationId != null) {
        request.fields['conversationId'] = conversationId;
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ),
      );

      var streamedResponse = await request.send();
      
      // Track upload progress
      streamedResponse.stream.listen(
        (List<int> chunk) {
          // You can calculate progress here if needed
        },
        onDone: () async {
          uploadProgress.value = 1.0;
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        isUploading.value = false;
        return {
          'success': true,
          'conversationId': data['conversationId'],
          'message': data['message'],
        };
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      print('❌ File pick/upload error: $e');
      Get.snackbar(
        'Upload Failed',
        'Could not upload file. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Get file icon based on type
  static IconData getFileIcon(String fileName, String? fileType) {
    final ext = path.extension(fileName).toLowerCase();
    
    if (fileType == 'image' || ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext)) {
      return Icons.image;
    } else if (fileType == 'video' || ['.mp4', '.mov', '.avi', '.mkv'].contains(ext)) {
      return Icons.video_file;
    } else if (fileType == 'audio' || ['.mp3', '.wav', '.m4a', '.ogg'].contains(ext)) {
      return Icons.audio_file;
    } else if (fileType == 'document' || ['.pdf'].contains(ext)) {
      return Icons.picture_as_pdf;
    } else if (['.doc', '.docx'].contains(ext)) {
      return Icons.description;
    } else if (['.xls', '.xlsx'].contains(ext)) {
      return Icons.table_chart;
    } else if (['.ppt', '.pptx'].contains(ext)) {
      return Icons.slideshow;
    } else if (['.txt'].contains(ext)) {
      return Icons.text_snippet;
    }
    return Icons.insert_drive_file;
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
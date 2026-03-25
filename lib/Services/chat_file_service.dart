import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

enum ChatFileType { image, video, audio, pdf, doc, excel, archive, file }

class FileUploadResult {
  final String mediaUrl;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final ChatFileType fileType;

  FileUploadResult({
    required this.mediaUrl,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.fileType,
  });

  String get typeString {
    switch (fileType) {
      case ChatFileType.image:   return 'image';
      case ChatFileType.video:   return 'video';
      case ChatFileType.audio:   return 'audio';
      case ChatFileType.pdf:     return 'pdf';
      case ChatFileType.doc:     return 'doc';
      case ChatFileType.excel:   return 'excel';
      case ChatFileType.archive: return 'archive';
      case ChatFileType.file:    return 'file';
    }
  }
}

class ChatFileService {
  final String baseUrl;
  final String token;

  ChatFileService({required this.baseUrl, required this.token});

  // ── Pick image — imageQuality se compress hogi directly ──
  Future<File?> pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,   // ✅ 60% quality — size ~5x chhoti ho jati hai
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return null;
      return File(picked.path);
    } catch (e) {
      print('❌ Image pick: $e');
      return null;
    }
  }

  Future<File?> pickVideo() async {
    try {
      final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (picked == null) return null;
      return File(picked.path);
    } catch (e) {
      print('❌ Video pick: $e');
      return null;
    }
  }

  Future<File?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return null;
      final path = result.files.single.path;
      if (path == null) return null;
      return File(path);
    } catch (e) {
      print('❌ File pick: $e');
      return null;
    }
  }

  Future<FileUploadResult?> uploadFile(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    final ext      = p.extension(file.path).toLowerCase().replaceAll('.', '');
    final fileType = _typeFromExt(ext);
    final fileName = p.basename(file.path);
    final fileSize = await file.length();

    print('📤 Uploading: $fileName | ${formatFileSize(fileSize)} | type: ${fileType.name}');

    // ✅ Fresh Dio instance with 5 minute timeout
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      sendTimeout:    const Duration(minutes: 5),   // ← YE FIX HAI
      receiveTimeout: const Duration(minutes: 5),
    ));

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    try {
      final response = await dio.post(
        '$baseUrl/api/chat/upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            print('📊 Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
            onProgress?.call(progress);
          }
        },
      );

      if (response.statusCode == 200 && response.data['ok'] == true) {
        final data = response.data;
        print('✅ Upload done: ${data['mediaUrl']}');
        return FileUploadResult(
          mediaUrl:     (data['mediaUrl']     ?? '').toString(),
          originalName: (data['originalName'] ?? fileName).toString(),
          mimeType:     (data['mimeType']     ?? '').toString(),
          fileSize:     data['fileSize'] is int
                          ? data['fileSize'] as int
                          : int.tryParse(data['fileSize']?.toString() ?? '') ?? fileSize,
          fileType:     _mapFileType((data['fileType'] ?? '').toString()),
        );
      }

      print('❌ Upload server error: ${response.statusCode} | ${response.data}');
      return null;
    } on DioException catch (e) {
      print('❌ Upload DioException [${e.type.name}]: ${e.message}');
      rethrow;
    }
  }

  ChatFileType _typeFromExt(String ext) {
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'].contains(ext)) return ChatFileType.image;
    if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(ext))           return ChatFileType.video;
    if (['mp3', 'aac', 'wav', 'ogg', 'm4a', 'flac'].contains(ext))           return ChatFileType.audio;
    if (ext == 'pdf')                                                          return ChatFileType.pdf;
    if (['doc', 'docx'].contains(ext))                                         return ChatFileType.doc;
    if (['xls', 'xlsx', 'csv'].contains(ext))                                  return ChatFileType.excel;
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext))                      return ChatFileType.archive;
    return ChatFileType.file;
  }

  ChatFileType _mapFileType(String t) {
    switch (t) {
      case 'image':   return ChatFileType.image;
      case 'video':   return ChatFileType.video;
      case 'audio':   return ChatFileType.audio;
      case 'pdf':     return ChatFileType.pdf;
      case 'doc':     return ChatFileType.doc;
      case 'excel':   return ChatFileType.excel;
      case 'archive': return ChatFileType.archive;
      default:        return ChatFileType.file;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024)             return '$bytes B';
    if (bytes < 1024 * 1024)      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static IconData iconForType(String type) {
    switch (type) {
      case 'image':   return Icons.image_rounded;
      case 'video':   return Icons.videocam_rounded;
      case 'audio':   return Icons.audiotrack_rounded;
      case 'pdf':     return Icons.picture_as_pdf_rounded;
      case 'doc':     return Icons.description_rounded;
      case 'excel':   return Icons.table_chart_rounded;
      case 'archive': return Icons.folder_zip_rounded;
      default:        return Icons.insert_drive_file_rounded;
    }
  }

  static Color colorForType(String type) {
    switch (type) {
      case 'image':   return const Color(0xFF10B981);
      case 'video':   return const Color(0xFF8B5CF6);
      case 'audio':   return const Color(0xFFF59E0B);
      case 'pdf':     return const Color(0xFFEF4444);
      case 'doc':     return const Color(0xFF3B82F6);
      case 'excel':   return const Color(0xFF059669);
      case 'archive': return const Color(0xFF6B7280);
      default:        return const Color(0xFF6B7280);
    }
  }
}
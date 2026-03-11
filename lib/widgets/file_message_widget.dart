// lib/widgets/file_message_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Services/filepicker_service.dart';
import 'package:templink/Utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FileMessageWidget extends StatelessWidget {
  final String fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final bool isMe;
  final bool isFirstInGroup;
  final String time;
  final String? status;

  const FileMessageWidget({
    Key? key,
    required this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    required this.isMe,
    required this.isFirstInGroup,
    required this.time,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icon = FilePickerService.getFileIcon(fileName, fileType);
    final sizeText = fileSize != null ? FilePickerService.formatFileSize(fileSize!) : '';

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 60 : 16,
        right: isMe ? 16 : 60,
        top: isFirstInGroup ? 4 : 2,
        bottom: 2,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe && isFirstInGroup)
            _buildAvatar()
          else if (!isMe)
            const SizedBox(width: 40),
          
          if (isMe && isFirstInGroup)
            _statusIcon(status)
          else if (isMe)
            const SizedBox(width: 22),
          
          Flexible(
            child: GestureDetector(
              onTap: () => _openFile(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(12).copyWith(
                    bottomLeft: !isMe && isFirstInGroup
                        ? const Radius.circular(4)
                        : const Radius.circular(12),
                    bottomRight: isMe && isFirstInGroup
                        ? const Radius.circular(4)
                        : const Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isMe ? Colors.white : primary).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: isMe ? Colors.white : primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.grey[900],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (sizeText.isNotEmpty)
                            Text(
                              sizeText,
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withOpacity(0.1),
      ),
      child: Center(
        child: Icon(Icons.person, color: primary, size: 16),
      ),
    );
  }

  Widget _statusIcon(String? status) {
    switch (status) {
      case "sending":
        return Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(right: 8),
          child: const CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.grey,
          ),
        );
      case "failed":
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: const Icon(Icons.error_outline, color: Colors.red, size: 18),
        );
      default:
        return const SizedBox(width: 20);
    }
  }

  void _openFile() async {
    if (fileUrl == null) return;
    
    try {
      final uri = Uri.parse(fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open file',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error opening file: $e');
    }
  }
}
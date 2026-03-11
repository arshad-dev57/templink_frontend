import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:templink/Employee/Controllers/Employee_Active_Project_Controller.dart';
import 'package:templink/Employee/models/Employee_Active_Project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class EmployeeSubmitWorkScreen extends StatelessWidget {
  final EmployeeActiveProjectModel project;
  final Milestone milestone;
  final controller = Get.find<EmployeeActiveProjectController>();
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();

  final selectedFiles = <File>[].obs;

  EmployeeSubmitWorkScreen({
    super.key,
    required this.project,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Submit Work',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildNotesField(),
              const SizedBox(height: 20),
              _buildFileAttachments(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.payment, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ${currencyFormat.format(milestone.amount)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (milestone.dueDate != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: milestone.dueDate!.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  milestone.dueDate!.isBefore(DateTime.now())
                      ? 'Overdue by ${_daysOverdue(milestone.dueDate!)} days'
                      : 'Due in ${_daysUntil(milestone.dueDate!)} days',
                  style: TextStyle(
                    color: milestone.dueDate!.isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Description *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe the work you have completed...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes (Optional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any additional information for the client...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileAttachments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Attachments',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Obx(() => selectedFiles.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedFiles.length} file(s)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 8),

          // ✅ File type chips — user ko pata ho kya accept hoga
          Wrap(
            spacing: 8,
            children: [
              _fileTypeChip(Icons.image, 'Images', Colors.blue),
              _fileTypeChip(Icons.picture_as_pdf, 'PDF', Colors.red),
              _fileTypeChip(Icons.description, 'DOC/DOCX', Colors.indigo),
              _fileTypeChip(Icons.table_chart, 'Excel', Colors.green),
              _fileTypeChip(Icons.insert_drive_file, 'Any File', Colors.grey),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ Upload button — file picker se sab types
          InkWell(
            onTap: _pickFiles,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: primary.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: primary.withOpacity(0.05),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: primary.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload files',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Images • PDF • DOC • Excel • Any file',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Selected files list
          Obx(() => selectedFiles.isNotEmpty
              ? Column(
                  children: selectedFiles.map((file) {
                    final fileName = file.path.split('/').last;
                    final fileSize = file.lengthSync();
                    final fileSizeStr = fileSize > 1024 * 1024
                        ? '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB'
                        : '${(fileSize / 1024).toStringAsFixed(1)} KB';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          // ✅ File icon with color
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getFileColor(file.path).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getFileIcon(file.path),
                              color: _getFileColor(file.path),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fileSizeStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ✅ Remove button
                          IconButton(
                            icon: Icon(Icons.close,
                                size: 18, color: Colors.grey[500]),
                            onPressed: () => selectedFiles.remove(file),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ✅ File type chip widget
  Widget _fileTypeChip(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _submitWork,
        icon: const Icon(Icons.send),
        label: const Text(
          'Submit Work',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  // ✅ File picker — har tarah ki file pick hogi
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any, // ✅ Sab types allow
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          // ✅ Duplicate check — same file dobara na aye
          final alreadyAdded = selectedFiles
              .any((f) => f.path.split('/').last == file.name);
          if (!alreadyAdded) {
            selectedFiles.add(File(file.path!));
          }
        }
      }
    }
  }

  // ✅ File icon by extension
  IconData _getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  // ✅ File color by extension
  Color _getFileColor(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Colors.blue;
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.indigo;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'zip':
      case 'rar':
        return Colors.brown;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Colors.purple;
      case 'mp3':
      case 'wav':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  int _daysUntil(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }

  int _daysOverdue(DateTime dueDate) {
    return DateTime.now().difference(dueDate).inDays;
  }

  Future<void> _submitWork() async {
    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please provide work description',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Submitting work...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final success = await controller.submitWork(
        projectId: project.id,
        milestoneId: milestone.id,
        description: descriptionController.text,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        attachments: selectedFiles.isNotEmpty ? selectedFiles.toList() : null,
      );

      Get.back(); // Close loading dialog

      if (success) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 60),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Work Submitted Successfully!',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your work has been submitted for review.\nThe employer will review it soon.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                  controller.fetchProjectDetails(project.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to submit work. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
// screens/employee/employee_submit_work_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  
  // ✅ RxList sahi tarike se initialize
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount: ${currencyFormat.format(milestone.amount)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe the work you have completed...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any additional information for the client...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          const Text(
            'Attachments',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Upload Button
          InkWell(
            onTap: _pickFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: primary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
                color: primary.withOpacity(0.05),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload files',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Supported: Images, PDF, DOC',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // ✅ Selected Files List with Obx
          Obx(() => selectedFiles.isNotEmpty
              ? Column(
                  children: selectedFiles.map((file) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getFileIcon(file.path),
                            color: primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file.path.split('/').last,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => selectedFiles.remove(file),
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

  Widget _buildSubmitButton() {
      
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed:  _submitWork,
          icon: const Icon(Icons.send),
          label: const Text(
            'Submit Work',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    
  }

  // ==================== HELPER METHODS ====================
  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    for (var image in images) {
      selectedFiles.add(File(image.path));
    }
  }

  IconData _getFileIcon(String path) {
    if (path.endsWith('.jpg') || path.endsWith('.png') || path.endsWith('.jpeg')) {
      return Icons.image;
    } else if (path.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (path.endsWith('.doc') || path.endsWith('.docx')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  int _daysUntil(DateTime dueDate) {
    return dueDate.difference(DateTime.now()).inDays;
  }

  int _daysOverdue(DateTime dueDate) {
    return DateTime.now().difference(dueDate).inDays;
  }
// screens/employee/employee_submit_work_screen.dart

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

  // Show loading dialog
  Get.dialog(
    const Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Submitting work...',
              style: TextStyle(color: Colors.white),
            ),
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
      // Show success dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Work Submitted Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your work has been submitted for review.\nThe employer will review it soon.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to details screen
                controller.fetchProjectDetails(project.id); // Refresh data
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    Get.back(); // Close loading dialog
    Get.snackbar(
      'Error',
      'Failed to submit work. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}}
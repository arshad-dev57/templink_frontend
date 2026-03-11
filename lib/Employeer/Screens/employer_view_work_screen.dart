//aa
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:templink/Employeer/Controller/employer_own_projects_controller.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class EmployerViewWorkScreen extends StatefulWidget {
  final EmployerProject project;
  final Milestone milestone;

  const EmployerViewWorkScreen({
    Key? key,
    required this.project,
    required this.milestone,
  }) : super(key: key);

  @override
  State<EmployerViewWorkScreen> createState() => _EmployerViewWorkScreenState();
}

class _EmployerViewWorkScreenState extends State<EmployerViewWorkScreen> {
  final controller = Get.find<EmployerProjectsController>();
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final feedbackController = TextEditingController();

  var isLoading = true.obs;
  var submission = Rx<Map<String, dynamic>>({});
  var attachments = <Map<String, dynamic>>[].obs;

  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchSubmissionData();
  }

  // ==================== FETCH SUBMISSION DATA ====================
  Future<void> fetchSubmissionData() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/submissions/project/${widget.project.id}/milestone/${widget.milestone.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Submission response: ${response.statusCode}');
      print('📦 Data: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          submission.value = jsonResponse['submission'] ?? {};
          attachments.value = List<Map<String, dynamic>>.from(
              jsonResponse['submission']['attachments'] ?? []);
        }
      }
    } catch (e) {
      print('❌ Error fetching submission: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Review Work',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchSubmissionData,
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (submission.value.isEmpty) {
          return _buildErrorState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildWorkSubmissionCard(),
              const SizedBox(height: 20),
              _buildAttachmentsCard(),
              const SizedBox(height: 20),
              _buildFeedbackCard(),
              const SizedBox(height: 30),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No submission found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This milestone has no work submitted yet.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  // ==================== INFO CARD ====================
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
            widget.project.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Client: ${widget.project.employerSnapshot.companyName}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payment, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.milestone.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: ${currencyFormat.format(widget.milestone.amount)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  submission.value['status'] ?? 'PENDING',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== WORK SUBMISSION CARD ====================
  Widget _buildWorkSubmissionCard() {
    final description =
        submission.value['description'] ?? 'No description provided';
    final notes = submission.value['notes'];
    final submittedAt = submission.value['submittedAt'] != null
        ? DateTime.parse(submission.value['submittedAt'])
        : null;

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
            'Work Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Additional Notes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Text(
                notes,
                style: const TextStyle(fontSize: 13, color: Colors.blue),
              ),
            ),
          ],
          if (submittedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  'Submitted ${_formatTimeAgo(submittedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==================== ATTACHMENTS CARD ====================
  Widget _buildAttachmentsCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attachments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(() => attachments.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${attachments.length} files',
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => attachments.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.attach_file,
                            size: 36, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No attachments submitted',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: attachments
                      .map((file) => _buildAttachmentItem(file))
                      .toList(),
                )),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> file) {
    final fileName = file['fileName'] ?? 'Unknown';
    final fileUrl = file['fileUrl'] ?? '';
    final fileSize = file['fileSize'] ?? 0;
    final fileType = file['fileType'] ?? '';

    IconData icon;
    Color color;

    if (fileType.startsWith('image/')) {
      icon = Icons.image;
      color = Colors.blue;
    } else if (fileType.startsWith('video/')) {
      icon = Icons.video_file;
      color = Colors.purple;
    } else if (fileType == 'application/pdf') {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (fileType.contains('word') ||
        fileName.endsWith('.doc') ||
        fileName.endsWith('.docx')) {
      icon = Icons.description;
      color = Colors.indigo;
    } else if (fileType.contains('excel') ||
        fileName.endsWith('.xls') ||
        fileName.endsWith('.xlsx')) {
      icon = Icons.table_chart;
      color = Colors.green;
    } else if (fileType.contains('zip') || fileType.contains('rar')) {
      icon = Icons.folder_zip;
      color = Colors.orange;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
    }

    // ✅ File size display
    String fileSizeStr = '';
    if (fileSize > 0) {
      fileSizeStr = fileSize > 1024 * 1024
          ? '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB'
          : '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSizeStr.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    fileSizeStr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
          ),
          // ✅ Download button with progress
          _DownloadButton(
            fileUrl: fileUrl,
            fileName: fileName,
            baseUrl: baseUrl,
          ),
        ],
      ),
    );
  }

  // ==================== FEEDBACK CARD ====================
  Widget _buildFeedbackCard() {
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
            'Your Feedback',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add your comments or feedback here...',
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

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showRevisionDialog,
            icon: const Icon(Icons.refresh),
            label: const Text('Request Revision',
                style: TextStyle(fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showApproveDialog,
            icon: const Icon(Icons.check_circle),
            label:
                const Text('Approve', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== API CALLS ====================
  Future<void> _approveWork() async {
    Get.back();

    Get.dialog(
      const Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Processing...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/submissions/approve/${submission.value['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'feedback': feedbackController.text}),
      );

      Get.back();

      if (response.statusCode == 200) {
        _showSuccessDialog(
          'Work Approved!',
          'Payment of ${currencyFormat.format(widget.milestone.amount)} has been released.',
        );
      } else {
        throw Exception('Failed to approve');
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to approve work',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _requestRevision() async {
    Get.back();

    Get.dialog(
      const Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Sending request...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/submissions/revision/${submission.value['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'feedback': feedbackController.text}),
      );

      Get.back();

      if (response.statusCode == 200) {
        _showSuccessDialog(
          'Revision Requested',
          'Freelancer will be notified to make changes.',
        );
      } else {
        throw Exception('Failed to request revision');
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to send request',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showApproveDialog() {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Approve Work'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle,
                  color: Colors.green, size: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to approve this work?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Once approved, payment of ${currencyFormat.format(widget.milestone.amount)} will be released.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _approveWork,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Approve'),
          ),
        ],
      ),
    );
  }

  void _showRevisionDialog() {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Request Revision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh,
                  color: Colors.orange, size: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'Request changes to this work?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _requestRevision,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
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
              controller.fetchMyProjectsWithProposals();
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

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
class _DownloadButton extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String baseUrl;

  const _DownloadButton({
    required this.fileUrl,
    required this.fileName,
    required this.baseUrl,
  });

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  bool isDownloading = false;
  double downloadProgress = 0.0;
  Future<void> _download() async {
    if (widget.fileUrl.isEmpty) {
      Get.snackbar('Error', 'File URL not available',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (Platform.isAndroid) {
      final manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }

    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final filePath = '${dir.path}/${widget.fileName}';
      print('📁 Saving to: $filePath');

      // ✅ Backend proxy se download karo
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ));

      await dio.download(
        '${widget.baseUrl}/api/submissions/download-file',
        filePath,
        data: {'fileUrl': widget.fileUrl},
        options: Options(
          method: 'POST',
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          isDownloading = false;
          downloadProgress = 0.0;
        });
      }

      print('✅ File downloaded successfully');

      Get.snackbar(
        '✅ Downloaded',
        '${widget.fileName} saved to Downloads',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => OpenFile.open(filePath),
          child: const Text('Open',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );

      await OpenFile.open(filePath);

    } catch (e) {
      if (mounted) {
        setState(() {
          isDownloading = false;
          downloadProgress = 0.0;
        });
      }
      print('❌ Download error: $e');
      Get.snackbar(
        '❌ Download Failed',
        'Could not download file. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }  @override
  Widget build(BuildContext context) {
    if (isDownloading) {
      return SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: downloadProgress > 0 && downloadProgress < 1
                  ? downloadProgress
                  : null,
              strokeWidth: 2.5,
              color: primary,
            ),
            if (downloadProgress > 0 && downloadProgress < 1)
              Text(
                '${(downloadProgress * 100).toInt()}%',
                style: const TextStyle(
                    fontSize: 8, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.download_rounded),
      color: primary,
      onPressed: _download,
      tooltip: 'Download ${widget.fileName}',
    );
  }
}
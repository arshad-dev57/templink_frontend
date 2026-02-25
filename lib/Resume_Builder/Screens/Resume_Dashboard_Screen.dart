import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
import 'package:templink/Resume_Builder/Screens/Resume_Templetes_Screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;

// ============================================
// RESUME DASHBOARD SCREEN - COMPLETE FIXED VERSION
// ============================================
class ResumeDashboardScreen extends StatefulWidget {
  const ResumeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ResumeDashboardScreen> createState() => _ResumeDashboardScreenState();
}

class _ResumeDashboardScreenState extends State<ResumeDashboardScreen> {
  final ResumeController controller = Get.put(ResumeController());

  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  Future<void> _loadResumes() async {
    await controller.fetchUserResumes();
  }

  // ============================================
  // VIEW RESUME - WITH CLOUDINARY FIX
  // ============================================
  Future<void> _viewResume(ResumesModel resume) async {
    try {
      // Show loading
      Get.dialog(
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading resume...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      print('📥 Original URL: ${resume.fileUrl}');
      
      // Try multiple URL formats for Cloudinary
      List<String> urlsToTry = [];
      
      // Add different URL variations
      if (resume.fileUrl.contains('image/upload')) {
        urlsToTry.add(resume.fileUrl.replaceFirst('image/upload', 'raw/upload'));
        urlsToTry.add(resume.fileUrl);
        urlsToTry.add('${resume.fileUrl}?fl_attachment=true');
        urlsToTry.add(resume.fileUrl.replaceFirst('image/upload', 'fl_attachment/raw/upload'));
      } else {
        urlsToTry.add(resume.fileUrl);
      }
      
      Uint8List? pdfBytes;
      String? successUrl;
      
      for (String url in urlsToTry) {
        try {
          print('🔄 Trying: $url');
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/pdf',
              'User-Agent': 'Mozilla/5.0', // Some Cloudinary URLs need this
            },
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Timeout'),
          );
          
          print('📥 Status: ${response.statusCode}');
          print('📥 Headers: ${response.headers['content-type']}');
          print('📥 Size: ${response.bodyBytes.length} bytes');
          
          if (response.statusCode == 200) {
            // Check if we actually got PDF content
            if (response.bodyBytes.length > 1000) {
              pdfBytes = response.bodyBytes;
              successUrl = url;
              print('✅ Success with: $url');
              break;
            } else {
              print('⚠️ File too small: ${response.bodyBytes.length} bytes');
            }
          } else if (response.statusCode == 401) {
            print('⚠️ URL requires authentication (401)');
          } else if (response.statusCode == 404) {
            print('⚠️ URL not found (404)');
          }
        } catch (e) {
          print('❌ Failed: $url - $e');
          continue;
        }
      }
      
      Get.back(); // Close loading
      
      if (pdfBytes != null) {
        // Save to temporary directory
        final tempDir = await getTemporaryDirectory();
        
        // Ensure filename has .pdf extension
        String fileName = resume.fileName;
        if (!fileName.toLowerCase().endsWith('.pdf')) {
          fileName = '$fileName.pdf';
        }
        
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(pdfBytes!);
        
        // Verify file was saved
        if (await tempFile.exists()) {
          print('✅ File saved: ${tempFile.path}');
          
          // Navigate to PDF viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                filePath: tempFile.path,
                fileName: fileName,
              ),
            ),
          ).then((_) {
            // Clean up temp file after returning (optional)
            // if (tempFile.existsSync()) {
            //   tempFile.deleteSync();
            // }
          });
        } else {
          throw Exception('Failed to save file');
        }
      } else {
        // If all attempts failed, show error with download option
        _showDownloadOption(resume);
      }
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      print('❌ View error: $e');
      _showDownloadOption(resume);
    }
  }

  // ============================================
  // SHOW DOWNLOAD OPTION WHEN VIEW FAILS
  // ============================================
  void _showDownloadOption(ResumesModel resume) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cannot Open Resume'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This resume could not be opened directly. You can:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.download, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Download it to your device'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.share, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Share it with others'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _downloadResume(resume);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DELETE RESUME
  // ============================================
  void _confirmDelete(ResumesModel resume) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Resume'),
        content: Text('Are you sure you want to delete "${resume.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteResume(resume.id);
              if (success) {
                Get.snackbar(
                  '✅ Deleted',
                  'Resume removed successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                setState(() {});
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SET DEFAULT RESUME
  // ============================================
  Future<void> _setDefaultResume(ResumesModel resume) async {
    if (resume.isDefault) {
      Get.snackbar(
        'ℹ️ Info',
        'This is already your default resume',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final success = await controller.setDefaultResume(resume.id);
    if (success) {
      setState(() {});
      Get.snackbar(
        '✅ Success',
        'Default resume updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // ============================================
  // SHARE RESUME
  // ============================================
  Future<void> _shareResume(ResumesModel resume) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Try to download first
      final response = await http.get(
        Uri.parse(resume.fileUrl.replaceFirst('image/upload', 'raw/upload')),
        headers: {'Accept': 'application/pdf'},
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }
      
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${resume.fileName}');
      await tempFile.writeAsBytes(response.bodyBytes);
      
      Get.back(); // Close loading
      
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'My Resume - ${resume.fileName}',
      );
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // If download fails, share the URL
      await Share.share(
        'Check out my resume: ${resume.fileUrl}',
        subject: 'My Resume',
      );
    }
  }

  // ============================================
  // DOWNLOAD RESUME
  // ============================================
  Future<void> _downloadResume(ResumesModel resume) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Try raw upload URL first
      String downloadUrl = resume.fileUrl.replaceFirst('image/upload', 'raw/upload');
      
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {'Accept': 'application/pdf'},
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        // Try original URL
        final response2 = await http.get(
          Uri.parse(resume.fileUrl),
          headers: {'Accept': 'application/pdf'},
        ).timeout(const Duration(seconds: 30));
        
        if (response2.statusCode != 200) {
          throw Exception('Failed to download PDF');
        }
        
        await _savePdfToDevice(response2.bodyBytes, resume.fileName);
      } else {
        await _savePdfToDevice(response.bodyBytes, resume.fileName);
      }
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // If all fails, open in browser
      Get.dialog(
        AlertDialog(
          title: const Text('Download via Browser'),
          content: const Text('Unable to download directly. Open in browser?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                final url = resume.fileUrl.replaceFirst('image/upload', 'raw/upload');
                await OpenFile.open(url);
              },
              child: const Text('Open in Browser'),
            ),
          ],
        ),
      );
    }
  }

  // ============================================
  // SAVE PDF TO DEVICE
  // ============================================
  Future<void> _savePdfToDevice(Uint8List bytes, String fileName) async {
    try {
      if (Platform.isAndroid) {
        // For Android - save to Downloads
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        
        // Ensure unique filename
        String uniqueFileName = fileName;
        File file = File('${downloadDir.path}/$uniqueFileName');
        int counter = 1;
        
        while (await file.exists()) {
          final name = fileName.split('.pdf')[0];
          uniqueFileName = '${name}_$counter.pdf';
          file = File('${downloadDir.path}/$uniqueFileName');
          counter++;
        }
        
        await file.writeAsBytes(bytes);
        
        Get.back(); // Close loading
        
        Get.snackbar(
          '✅ Downloaded',
          'Saved to Downloads folder as "$uniqueFileName"',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => OpenFile.open(file.path),
            child: const Text('OPEN', style: TextStyle(color: Colors.white)),
          ),
        );
      } else {
        // For iOS
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        Get.back(); // Close loading
        
        Get.snackbar(
          '✅ Downloaded',
          'Resume saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Resumes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadResumes,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Get.to(() => ResumeTemplate());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.savedResumes.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.savedResumes.length,
          itemBuilder: (context, index) {
            final resume = controller.savedResumes[index];
            return _buildResumeCard(resume);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 60,
              color: primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Resumes Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your first resume to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to resume builder
              // Get.to(() => ResumeTemplateScreen());
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(ResumesModel resume) {
    final isDefault = resume.isDefault;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Default badge
          if (isDefault)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Default Resume',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          
          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PDF Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Resume details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded ${DateFormat('MMM dd, yyyy').format(resume.uploadDate)} • ${_formatFileSize(resume.fileSize)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _viewResume(resume);
                        break;
                      case 'share':
                        _shareResume(resume);
                        break;
                      case 'download':
                        _downloadResume(resume);
                        break;
                      case 'set_default':
                        _setDefaultResume(resume);
                        break;
                      case 'delete':
                        _confirmDelete(resume);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('View'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Download'),
                        ],
                      ),
                    ),
                    if (!isDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ============================================
// PDF VIEWER SCREEN
// ============================================
class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PdfViewerScreen({
    Key? key,
    required this.filePath,
    required this.fileName,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final Completer<PDFViewController> _controller = Completer();
  int? pages;
  int? currentPage;
  bool isReady = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _verifyFile();
  }

  void _verifyFile() async {
    final file = File(widget.filePath);
    if (!await file.exists()) {
      setState(() {
        errorMessage = 'File not found';
      });
      return;
    }
    
    final bytes = await file.readAsBytes();
    print('📄 PDF file size: ${bytes.length} bytes');
    print('📄 File path: ${widget.filePath}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.fileName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () async {
              await Share.shareXFiles([XFile(widget.filePath)]);
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () async {
              if (Platform.isAndroid) {
                final downloadDir = Directory('/storage/emulated/0/Download');
                if (!await downloadDir.exists()) {
                  await downloadDir.create(recursive: true);
                }
                final newPath = '${downloadDir.path}/${widget.fileName}';
                await File(widget.filePath).copy(newPath);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved to Downloads folder'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (errorMessage.isEmpty)
            PDFView(
              filePath: widget.filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: currentPage ?? 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (pagesCount) {
                setState(() {
                  pages = pagesCount;
                  isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = 'Page $page: ${error.toString()}';
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  currentPage = page;
                });
              },
            ),
          
          if (!isReady && errorMessage.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading PDF...'),
                ],
              ),
            ),
          
          if (errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading PDF',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => OpenFile.open(widget.filePath),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Open with external app'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isReady && pages != null && pages! > 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'prev',
                    backgroundColor: Colors.white,
                    onPressed: currentPage! > 0
                        ? () async {
                            final ctrl = await _controller.future;
                            ctrl.setPage(currentPage! - 1);
                          }
                        : null,
                    child: const Icon(Icons.chevron_left, color: Colors.black),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Page ${(currentPage ?? 0) + 1} of $pages',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'next',
                    backgroundColor: Colors.white,
                    onPressed: currentPage! < pages! - 1
                        ? () async {
                            final ctrl = await _controller.future;
                            ctrl.setPage(currentPage! + 1);
                          }
                        : null,
                    child: const Icon(Icons.chevron_right, color: Colors.black),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
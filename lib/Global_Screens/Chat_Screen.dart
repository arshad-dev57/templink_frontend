//nn
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:templink/Services/chat_api_service.dart';
import 'package:templink/Services/chat_file_service.dart';
import '../Controllers/chat_socket_controller.dart';
import '../Controllers/chat_list_controller.dart';
import '../Controllers/call_controller.dart';
import '../Controllers/video_call_controller.dart';
import '../Utils/colors.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final bool userOnline;
  final String toUserId;
  final String baseUrl;
  final String myToken;
  final String myUserId;
  final String? initialConversationId;
  final List<Map<String, dynamic>>? initialMessages;

  const ChatScreen({
    Key? key,
    required this.userName,
    required this.userOnline,
    required this.toUserId,
    required this.baseUrl,
    required this.myToken,
    required this.myUserId,
    this.initialConversationId,
    this.initialMessages,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late final ChatSocketController controller;
  late final ChatListController listController;
  late final ChatFileService _fileService;

  String? conversationId;
  bool _isLoading = true;
  bool _initialLoadDone = false;
  bool _isComposing = false;

  // File upload state
  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fileService = ChatFileService(
      baseUrl: widget.baseUrl,
      token: widget.myToken,
    );
    _initializeController();

    if (widget.initialConversationId != null) {
      conversationId = widget.initialConversationId;
      controller.setActiveConversation(widget.initialConversationId!);
      if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
        controller.replaceMessages(widget.initialConversationId!, widget.initialMessages!);
        _isLoading = false;
        _initialLoadDone = true;
      }
      _refreshMessagesInBackground();
    } else {
      _initChat();
    }

    _messageController.addListener(_onTextChanged);

    ever(controller.messages, (_) {
      if (mounted && _initialLoadDone) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  @override
  void didChangeMetrics() {
    if (_focusNode.hasFocus) _scrollToBottom();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.isNotEmpty;
    if (hasText != _isComposing) setState(() => _isComposing = hasText);
  }

  void _initializeController() {
    try {
      if (Get.isRegistered<ChatSocketController>()) {
        controller = Get.find<ChatSocketController>();
      } else {
        controller = Get.put(
          ChatSocketController(
            socketBaseUrl: widget.baseUrl,
            token: widget.myToken,
            myUserId: widget.myUserId,
          ),
          permanent: true,
        );
      }
      if (Get.isRegistered<ChatListController>()) {
        listController = Get.find<ChatListController>();
      } else {
        listController = Get.put(
          ChatListController(baseUrl: widget.baseUrl, token: widget.myToken),
        );
      }
    } catch (e) {
      print('❌ Controller initialization error: $e');
    }
  }

  Future<void> _refreshMessagesInBackground() async {
    try {
      final msgs = await ChatApi.getMessages(
        baseUrl: widget.baseUrl,
        token: widget.myToken,
        conversationId: conversationId!,
        page: 1,
        limit: 50,
      );
      controller.replaceMessages(conversationId!, msgs);
      controller.markRead(conversationId: conversationId!);
      if (mounted) setState(() { _isLoading = false; _initialLoadDone = true; });
    } catch (e) {
      print('❌ Background refresh error: $e');
      if (mounted) setState(() { _isLoading = false; _initialLoadDone = true; });
    }
  }

  Future<void> _initChat() async {
    try {
      String? cid = listController.getCachedConversationId(widget.toUserId);
      if (cid == null) {
        cid = await ChatApi.getOrCreateConversation(
          baseUrl: widget.baseUrl,
          token: widget.myToken,
          otherUserId: widget.toUserId,
        );
      }
      setState(() => conversationId = cid);
      controller.setActiveConversation(cid);

      final cachedMessages = listController.getCachedMessages(cid);
      if (cachedMessages.isNotEmpty) {
        controller.replaceMessages(cid, cachedMessages);
        setState(() { _isLoading = false; _initialLoadDone = true; });
      }

      try {
        final msgs = await ChatApi.getMessages(
          baseUrl: widget.baseUrl,
          token: widget.myToken,
          conversationId: cid,
          page: 1,
          limit: 50,
        );
        controller.replaceMessages(cid, msgs);
        controller.markRead(conversationId: cid);
      } catch (e) { print('❌ Messages fetch error: $e'); }

      if (mounted && _isLoading) setState(() { _isLoading = false; _initialLoadDone = true; });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      print('❌ Chat initialization error: $e');
      if (mounted) setState(() { _isLoading = false; _initialLoadDone = true; });
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) { print('❌ Scroll error: $e'); }
  }

  void _sendMessage() {
    final cid = conversationId;
    if (cid == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    setState(() => _isComposing = false);
    controller.sendMessage(conversationId: cid, toUserId: widget.toUserId, text: text);
    try {
      controller.sendTyping(conversationId: cid, toUserId: widget.toUserId, isTyping: false);
    } catch (e) { print('❌ Error stopping typing: $e'); }
  }

  void _handleTextChanged(String val) {
    final cid = conversationId;
    if (cid == null) return;
    try {
      controller.sendTyping(conversationId: cid, toUserId: widget.toUserId, isTyping: val.isNotEmpty);
    } catch (e) { print('❌ Error sending typing: $e'); }
  }

  // ── File attachment bottom sheet ──────────────────────────
  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Attachment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _attachOption(
                    icon: Icons.image_rounded,
                    label: 'Photo',
                    color: const Color(0xFF10B981),
                    onTap: () { Navigator.pop(context); _pickAndSend('image'); },
                  ),
                  _attachOption(
                    icon: Icons.videocam_rounded,
                    label: 'Video',
                    color: const Color(0xFF8B5CF6),
                    onTap: () { Navigator.pop(context); _pickAndSend('video'); },
                  ),
                  _attachOption(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    color: const Color(0xFF3B82F6),
                    onTap: () { Navigator.pop(context); _pickAndSend('file'); },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Pick file and upload ──────────────────────────────────
  Future<void> _pickAndSend(String pickType) async {
    final cid = conversationId;
    if (cid == null) return;

    File? file;
    if (pickType == 'image') {
      file = await _fileService.pickImage();
    } else if (pickType == 'video') {
      file = await _fileService.pickVideo();
    } else {
      file = await _fileService.pickFile();
    }

    if (file == null) return;

    // Check file size (10MB limit)
    final size = await file.length();
    if (size > 10 * 1024 * 1024) {
      Get.snackbar(
        'File too large',
        'Maximum file size is 10MB',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
      return;
    }

    setState(() { _isUploading = true; _uploadProgress = 0; });

    try {
      final result = await _fileService.uploadFile(
        file,
        onProgress: (p) => setState(() => _uploadProgress = p),
      );

      if (result == null) {
        Get.snackbar(
          'Upload Failed',
          'Could not upload file. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.85),
          colorText: Colors.white,
        );
        return;
      }

      // Send via socket
      controller.sendFileMessage(
        conversationId: cid,
        toUserId: widget.toUserId,
        type: result.typeString,
        mediaUrl: result.mediaUrl,
        originalName: result.originalName,
        fileSize: result.fileSize,
      );

    } catch (e) {
      print('❌ Upload/send error: $e');
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() { _isUploading = false; _uploadProgress = 0; });
    }
  }

  // ── Calls ─────────────────────────────────────────────────
  void _startVoiceCall() {
    try {
      Get.find<CallController>().startCall(
        toUserId: widget.toUserId,
        toUserName: widget.userName,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not start voice call.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    }
  }

  void _startVideoCall() {
    try {
      Get.find<VideoCallController>().startVideoCall(
        toUserId: widget.toUserId,
        toUserName: widget.userName,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not start video call.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    }
  }

  // ── Message UI helpers ────────────────────────────────────
  Widget _statusIcon(String? status) {
    switch (status) {
      case "sending":
        return Container(
          width: 14, height: 14, margin: const EdgeInsets.only(left: 4),
          child: const CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white70),
        );
      case "sent":
        return Icon(Icons.check, size: 14, color: Colors.white.withOpacity(0.7));
      case "delivered":
        return Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.7));
      case "read":
        return const Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent);
      case "failed":
        return const Icon(Icons.error_outline, size: 14, color: Colors.redAccent);
      default:
        return const SizedBox(width: 14);
    }
  }

  String _formatTime(dynamic createdAt) {
    try {
      if (createdAt == null) return "";
      DateTime dt;
      if (createdAt is String) dt = DateTime.parse(createdAt).toLocal();
      else if (createdAt is DateTime) dt = createdAt;
      else return "";
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, "0");
      final ap = dt.hour >= 12 ? "PM" : "AM";
      return "$h:$m $ap";
    } catch (_) { return ""; }
  }

  // ── Build message bubble based on type ───────────────────
  Widget _buildMessageItem(Map<String, dynamic> message, bool isMe, bool isFirstInGroup) {
    final type = (message['type'] ?? 'text').toString();
    final time = _formatTime(message['createdAt']);
    final status = (message['status'] ?? '').toString();

    Widget bubble;
    if (type == 'text') {
      final text = (message['text'] ?? '').toString();
      bubble = isMe
          ? _buildSentTextBubble(text: text, time: time, status: status, isFirstInGroup: isFirstInGroup)
          : _buildReceivedTextBubble(text: text, time: time, isFirstInGroup: isFirstInGroup);
    } else if (type == 'image') {
      bubble = isMe
          ? _buildSentImageBubble(message: message, time: time, status: status, isFirstInGroup: isFirstInGroup)
          : _buildReceivedImageBubble(message: message, time: time, isFirstInGroup: isFirstInGroup);
    } else {
      // All other file types
      bubble = isMe
          ? _buildSentFileBubble(message: message, time: time, status: status, isFirstInGroup: isFirstInGroup)
          : _buildReceivedFileBubble(message: message, time: time, isFirstInGroup: isFirstInGroup);
    }
    return bubble;
  }

  // ── Text bubbles ──────────────────────────────────────────
  Widget _buildSentTextBubble({
    required String text,
    required String time,
    required String status,
    required bool isFirstInGroup,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 60, right: 16, top: isFirstInGroup ? 4 : 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFirstInGroup) _statusIcon(status) else const SizedBox(width: 22),
          const SizedBox(width: 4),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isFirstInGroup ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(time, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedTextBubble({
    required String text,
    required String time,
    required bool isFirstInGroup,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 60, top: isFirstInGroup ? 4 : 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isFirstInGroup)
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withOpacity(0.1)),
              child: Center(child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              )),
            )
          else
            const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isFirstInGroup ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(color: Colors.grey[900], fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image bubbles ─────────────────────────────────────────
  Widget _buildSentImageBubble({
    required Map<String, dynamic> message,
    required String time,
    required String status,
    required bool isFirstInGroup,
  }) {
    final url = message['mediaUrl']?.toString() ?? '';
    return Container(
      margin: EdgeInsets.only(left: 60, right: 16, top: isFirstInGroup ? 4 : 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFirstInGroup) _statusIcon(status) else const SizedBox(width: 22),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _openFile(url, 'image'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14).copyWith(
                bottomRight: isFirstInGroup ? const Radius.circular(4) : const Radius.circular(14),
              ),
              child: Stack(
                children: [
                  Image.network(
                    url,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 200, height: 200,
                      color: primary.withOpacity(0.2),
                      child: Icon(Icons.broken_image_rounded, color: primary, size: 40),
                    ),
                  ),
                  Positioned(
                    bottom: 6, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedImageBubble({
    required Map<String, dynamic> message,
    required String time,
    required bool isFirstInGroup,
  }) {
    final url = message['mediaUrl']?.toString() ?? '';
    return Container(
      margin: EdgeInsets.only(left: 16, right: 60, top: isFirstInGroup ? 4 : 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFirstInGroup)
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withOpacity(0.1)),
              child: Center(child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              )),
            )
          else
            const SizedBox(width: 40),
          GestureDetector(
            onTap: () => _openFile(url, 'image'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14).copyWith(
                bottomLeft: isFirstInGroup ? const Radius.circular(4) : const Radius.circular(14),
              ),
              child: Stack(
                children: [
                  Image.network(
                    url,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 200, height: 200,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image_rounded, color: Colors.grey[400], size: 40),
                    ),
                  ),
                  Positioned(
                    bottom: 6, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── File bubbles (PDF, DOC, VIDEO, etc.) ─────────────────
  Widget _buildSentFileBubble({
    required Map<String, dynamic> message,
    required String time,
    required String status,
    required bool isFirstInGroup,
  }) {
    final type = (message['type'] ?? 'file').toString();
    final name = (message['originalName'] ?? 'File').toString();
    final size = (message['fileSize'] ?? 0) as int;
    final url  = message['mediaUrl']?.toString() ?? '';
    final icon  = ChatFileService.iconForType(type);
    final color = ChatFileService.colorForType(type);

    return Container(
      margin: EdgeInsets.only(left: 60, right: 16, top: isFirstInGroup ? 4 : 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFirstInGroup) _statusIcon(status) else const SizedBox(width: 22),
          const SizedBox(width: 4),
          Flexible(
            child: GestureDetector(
              onTap: () => _openFile(url, type),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isFirstInGroup ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                ChatFileService.formatFileSize(size),
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
                              ),
                              const SizedBox(width: 8),
                              Text(time, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                            ],
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

  Widget _buildReceivedFileBubble({
    required Map<String, dynamic> message,
    required String time,
    required bool isFirstInGroup,
  }) {
    final type = (message['type'] ?? 'file').toString();
    final name = (message['originalName'] ?? 'File').toString();
    final size = (message['fileSize'] ?? 0) as int;
    final url  = message['mediaUrl']?.toString() ?? '';
    final icon  = ChatFileService.iconForType(type);
    final color = ChatFileService.colorForType(type);

    return Container(
      margin: EdgeInsets.only(left: 16, right: 60, top: isFirstInGroup ? 4 : 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFirstInGroup)
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withOpacity(0.1)),
              child: Center(child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              )),
            )
          else
            const SizedBox(width: 40),
          Flexible(
            child: GestureDetector(
              onTap: () => _openFile(url, type),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: isFirstInGroup ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(color: Colors.grey[900], fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                ChatFileService.formatFileSize(size),
                                style: TextStyle(color: Colors.grey[500], fontSize: 10),
                              ),
                              const SizedBox(width: 8),
                              Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.download_rounded, color: color, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Open file in browser/viewer ───────────────────────────
  void _openFile(String url, String type) {
    if (url.isEmpty) return;
    // For images show full screen
    if (type == 'image') {
      Get.to(() => _FullScreenImage(url: url));
      return;
    }
    // For all other files open with system app
    OpenFile.open(url);
  }

  // ── Upload progress bar ───────────────────────────────────
  Widget _buildUploadProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              value: _uploadProgress,
              strokeWidth: 2,
              color: primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[200],
                    color: primary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withOpacity(0.1)),
            child: Center(child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
              style: TextStyle(color: primary, fontWeight: FontWeight.w600),
            )),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_dot(), const SizedBox(width: 4), _dot(), const SizedBox(width: 4), _dot()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: primary.withOpacity(0.5), shape: BoxShape.circle),
  );

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Container(
          margin: EdgeInsets.only(left: isMe ? 60 : 16, right: isMe ? 16 : 60, bottom: 12),
          child: Container(height: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20))),
        );
      },
    );
  }

  Widget _buildInputBar(String cid) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Attachment button ──
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _isUploading ? null : _showAttachmentSheet,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: _isUploading ? Colors.grey : primary,
                  size: 28,
                ),
              ),
            ),
            // ── Text input ──
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  onChanged: _handleTextChanged,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            // ── Send button ──
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: FloatingActionButton(
                onPressed: _isComposing ? _sendMessage : null,
                mini: true,
                elevation: 0,
                backgroundColor: _isComposing ? primary : Colors.grey[300],
                child: Icon(Icons.send_rounded,
                    color: _isComposing ? Colors.white : Colors.grey[600], size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primary.withOpacity(0.1),
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "?",
                  style: TextStyle(color: primary, fontWeight: FontWeight.w700),
                ),
              ),
              if (widget.userOnline)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Obx(() {
                  if (controller.isOtherTyping.value) {
                    return Text("Typing...", style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500));
                  }
                  return Text(
                    widget.userOnline ? "Online" : "Offline",
                    style: TextStyle(fontSize: 12, color: widget.userOnline ? Colors.green : Colors.grey, fontWeight: FontWeight.w500),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(onPressed: _startVoiceCall, icon: Icon(Icons.phone_rounded, color: primary), tooltip: 'Voice Call'),
      //   IconButton(onPressed: _startVideoCall, icon: Icon(Icons.videocam_rounded, color: primary), tooltip: 'Video Call'),
      //   IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: primary)),
      // ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cid = conversationId;
    final bool showLoading = _isLoading &&
        controller.messages.isEmpty &&
        (widget.initialMessages?.isEmpty ?? true);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: showLoading
          ? _buildShimmerLoading()
          : (cid == null)
              ? const Center(child: Text("Chat not available"))
              : Column(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final messages = controller.messages;
                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text("No messages yet",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                const SizedBox(height: 8),
                                Text("Say hello to start the conversation",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = (message["from"] ?? "").toString() == widget.myUserId;
                            final isFirstInGroup = index == 0 ||
                                messages[index - 1]["from"] != message["from"];
                            return _buildMessageItem(message, isMe, isFirstInGroup);
                          },
                        );
                      }),
                    ),
                    // Upload progress bar
                    if (_isUploading) _buildUploadProgress(),
                    Obx(() => controller.isOtherTyping.value ? _typingIndicator() : const SizedBox()),
                    _buildInputBar(cid),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    try {
      if (Get.isRegistered<ChatSocketController>()) controller.clearActiveConversation();
    } catch (e) { print('❌ Error clearing active conversation: $e'); }
    super.dispose();
  }
}

// ── Full screen image viewer ──────────────────────────────
class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () => OpenFile.open(url),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_rounded, color: Colors.white54, size: 60,
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Services/chat_api_service.dart';
import '../controllers/chat_socket_controller.dart';
import '../Utils/colors.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final bool userOnline;
  final String toUserId;
  final String baseUrl;
  final String myToken;
  final String myUserId;

  const ChatScreen({
    Key? key,
    required this.userName,
    required this.userOnline,
    required this.toUserId,
    required this.baseUrl,
    required this.myToken,
    required this.myUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatSocketController controller;
  String? conversationId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatSocketController>();
    _initChat();
    
    // Scroll to bottom when new messages arrive
    ever(controller.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  Future<void> _initChat() async {
    try {
      // Get or create conversation
      final cid = await ChatApi.getOrCreateConversation(
        baseUrl: widget.baseUrl,
        token: widget.myToken,
        otherUserId: widget.toUserId,
      );

      // Join conversation room
      controller.joinConversation(conversationId: cid);
      controller.setActiveConversation(cid);

      // Load messages
      final msgs = await ChatApi.getMessages(
        baseUrl: widget.baseUrl,
        token: widget.myToken,
        conversationId: cid,
        page: 1,
        limit: 50,
      );

      setState(() {
        conversationId = cid;
        loading = false;
      });

      // Update messages and mark as read
      controller.replaceMessages(cid, msgs);
      controller.markRead(conversationId: cid);

    } catch (e) {
      setState(() => loading = false);
      Get.snackbar(
        "Chat Error",
        "Failed to open chat: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    final cid = conversationId;
    if (cid == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    
    // Send message
    controller.sendMessage(
      conversationId: cid,
      toUserId: widget.toUserId,
      text: text,
    );

    // Stop typing indicator
    controller.onTextChanged(
      conversationId: cid,
      toUserId: widget.toUserId,
      text: '',
    );
  }

  Widget _statusIcon(String? status) {
    switch (status) {
      case "sending":
        return const Icon(Icons.access_time, size: 14, color: Colors.white70);
      case "sent":
        return const Icon(Icons.check, size: 14, color: Colors.white70);
      case "delivered":
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
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
      final dt = DateTime.tryParse(createdAt.toString());
      if (dt == null) return "";
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, "0");
      final ap = dt.hour >= 12 ? "PM" : "AM";
      return "$h:$m $ap";
    } catch (_) {
      return "";
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: Colors.black,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: primary.withOpacity(0.15),
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "?",
                  style: TextStyle(color: primary, fontWeight: FontWeight.w700),
                ),
              ),
              if (widget.userOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  if (controller.isOtherTyping.value) {
                    return Text(
                      "Typing...",
                      style: TextStyle(
                        fontSize: 12,
                        color: primary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }
                  return Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: widget.userOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.userOnline ? "Online" : "Offline",
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.userOnline ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement voice call
            Get.snackbar('Coming Soon', 'Voice calls will be available soon');
          },
          tooltip: "Voice call",
          icon: Icon(Icons.call, color: primary),
        ),
        IconButton(
          onPressed: () {
            // TODO: Implement video call
            Get.snackbar('Coming Soon', 'Video calls will be available soon');
          },
          tooltip: "Video call",
          icon: Icon(Icons.videocam, color: primary),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _bubble({
    required bool isMe,
    required String text,
    required String time,
    required String status,
  }) {
    final maxWidth = MediaQuery.of(context).size.width * 0.78;

    final bubbleColor = isMe ? primary : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final subColor = isMe ? Colors.white70 : Colors.black45;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: EdgeInsets.fromLTRB(isMe ? 60 : 12, 6, isMe ? 12 : 60, 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
            border: isMe ? null : Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: TextStyle(color: textColor, fontSize: 15, height: 1.25),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: subColor, fontWeight: FontWeight.w500),
                  ),
                  if (isMe) ...[ 
                    const SizedBox(width: 6),
                    _statusIcon(status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typingPill() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.05),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text("Typing...", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBar(String cid) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, -4),
              color: Colors.black.withOpacity(0.06),
            )
          ],
        ),
        child: Row(
          children: [
            // ✅ Text Field - Uncommented and Fixed
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: TextField(
                  controller: _messageController,
                  onChanged: (val) => controller.onTextChanged(
                    conversationId: cid,
                    toUserId: widget.toUserId,
                    text: val,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Type a message…",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            
            // Send Button
            InkWell(
              onTap: _sendMessage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                      color: primary.withOpacity(0.25),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cid = conversationId;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: _buildAppBar(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (cid == null)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "Chat not available",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Messages List
                    Expanded(
                      child: Obx(() {
                        final list = controller.messages;
                        if (list.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  "No messages yet",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Say hello to start the conversation",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          itemCount: list.length,
                          itemBuilder: (_, i) {
                            final m = list[i];
                            final isMe = (m["from"] ?? "").toString() == widget.myUserId;
                            final text = (m["text"] ?? "").toString();
                            final status = (m["status"] ?? "").toString();
                            final time = _formatTime(m["createdAt"]);

                            return _bubble(
                              isMe: isMe,
                              text: text,
                              time: time,
                              status: status,
                            );
                          },
                        );
                      }),
                    ),

                    // Typing Indicator
                    Obx(() => controller.isOtherTyping.value ? _typingPill() : const SizedBox()),

                    // Input Bar
                    _inputBar(cid),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    
    // Leave conversation
    if (conversationId != null) {
      controller.leaveConversation(conversationId!);
    }
    
    super.dispose();
  }
}
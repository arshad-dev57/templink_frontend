import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Services/chat_api_service.dart';
import '../controllers/chat_socket_controller.dart';
import '../controllers/chat_list_controller.dart';
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

  String? conversationId;
  bool _isLoading = true;
  bool _initialLoadDone = false;
  
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
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
    if (_focusNode.hasFocus) {
      _scrollToBottom();
    }
  }

  void _onTextChanged() {
    final hasText = _messageController.text.isNotEmpty;
    if (hasText != _isComposing) {
      setState(() {
        _isComposing = hasText;
      });
    }
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
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _initialLoadDone = true;
        });
      }
    } catch (e) {
      print('❌ Background refresh error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _initialLoadDone = true;
        });
      }
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

      setState(() {
        conversationId = cid;
      });

      controller.setActiveConversation(cid);

      final cachedMessages = listController.getCachedMessages(cid);
      if (cachedMessages.isNotEmpty) {
        controller.replaceMessages(cid, cachedMessages);
        setState(() {
          _isLoading = false;
          _initialLoadDone = true;
        });
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
      } catch (e) {
        print('❌ Messages fetch error: $e');
      }

      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _initialLoadDone = true;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      print('❌ Chat initialization error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _initialLoadDone = true;
        });
      }
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
    } catch (e) {
      print('❌ Scroll error: $e');
    }
  }

  void _sendMessage() {
    final cid = conversationId;
    
    if (cid == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    controller.sendMessage(
      conversationId: cid,
      toUserId: widget.toUserId,
      text: text,
    );

    try {
      controller.sendTyping(
        conversationId: cid,
        toUserId: widget.toUserId,
        isTyping: false,
      );
    } catch (e) {
      print('❌ Error stopping typing: $e');
    }
  }

  void _handleTextChanged(String val) {
    final cid = conversationId;
    if (cid == null) return;
    
    try {
      controller.sendTyping(
        conversationId: cid,
        toUserId: widget.toUserId,
        isTyping: val.isNotEmpty,
      );
    } catch (e) {
      print('❌ Error sending typing: $e');
    }
  }

  // ==================== PROFESSIONAL MESSAGE BUBBLES ====================

  Widget _statusIcon(String? status) {
    switch (status) {
      case "sending":
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(left: 4),
          child: const CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white70,
          ),
        );
      case "sent":
        return Icon(Icons.check, size: 14, color: Colors.white.withOpacity(0.7));
      case "delivered":
        return Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.7));
      case "read":
        return Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent);
      case "failed":
        return Icon(Icons.error_outline, size: 14, color: Colors.redAccent);
      default:
        return const SizedBox(width: 14);
    }
  }

  String _formatTime(dynamic createdAt) {
    try {
      if (createdAt == null) return "";
      
      DateTime dt;
      if (createdAt is String) {
        dt = DateTime.parse(createdAt).toLocal();
      } else if (createdAt is DateTime) {
        dt = createdAt;
      } else {
        return "";
      }
      
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, "0");
      final ap = dt.hour >= 12 ? "PM" : "AM";
      return "$h:$m $ap";
    } catch (e) {
      return "";
    }
  }

  // ✅ MODERN MESSAGE BUBBLE - SENT (OWN MESSAGE)
  Widget _buildSentBubble({
    required String text,
    required String time,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 60, right: 16, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Status indicators
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: _statusIcon(status),
          ),
          
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Message text
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Time
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
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

  // ✅ MODERN MESSAGE BUBBLE - RECEIVED (OTHER USER)
  Widget _buildReceivedBubble({
    required String text,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 60, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar (small)
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Time
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
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

  // ✅ GROUPED MESSAGES - SENT (WITHOUT AVATAR FOR CONSECUTIVE)
  Widget _buildGroupedSentBubble({
    required String text,
    required String time,
    required String status,
    required bool isFirstInGroup,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: 60,
        right: 16,
        top: isFirstInGroup ? 4 : 2,
        bottom: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isFirstInGroup) const SizedBox(width: 22), // Space for status
          if (isFirstInGroup) _statusIcon(status),
          if (!isFirstInGroup) const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isFirstInGroup 
                      ? const Radius.circular(4) 
                      : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
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

  // ✅ GROUPED MESSAGES - RECEIVED (WITHOUT AVATAR FOR CONSECUTIVE)
  Widget _buildGroupedReceivedBubble({
    required String text,
    required String time,
    required bool isFirstInGroup,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 60,
        top: isFirstInGroup ? 4 : 2,
        bottom: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isFirstInGroup)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                  style: TextStyle(color: primary, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            const SizedBox(width: 40), // Space for avatar
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isFirstInGroup 
                      ? const Radius.circular(4) 
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(color: Colors.grey[900], fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MESSAGE DIVIDER (DATE)
  Widget _buildDateDivider(String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              date,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  // ✅ TYPING INDICATOR
  Widget _typingIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(150),
                const SizedBox(width: 4),
                _buildTypingDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  // ✅ SHIMMER LOADING
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Container(
          margin: EdgeInsets.only(
            left: isMe ? 60 : 16,
            right: isMe ? 16 : 60,
            bottom: 12,
          ),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  // ✅ INPUT BAR
  Widget _buildInputBar(String cid) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  // Handle attachment
                },
                icon: Icon(Icons.add_circle_outline, color: primary, size: 28),
              ),
            ),
            
            // Text field
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            
            // Send button
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: FloatingActionButton(
                onPressed: _isComposing ? _sendMessage : null,
                mini: true,
                elevation: 0,
                backgroundColor: _isComposing ? primary : Colors.grey[300],
                child: Icon(
                  Icons.send_rounded,
                  color: _isComposing ? Colors.white : Colors.grey[600],
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ APPBAR
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
                backgroundImage: const AssetImage('assets/default_avatar.png'),
                child: Text(
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : "?",
                  style: TextStyle(color: primary, fontWeight: FontWeight.w700),
                ),
              ),
              if (widget.userOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
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
                Text(
                  widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
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
                  return Text(
                    widget.userOnline ? "Online" : "Offline",
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.userOnline ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.phone, color: primary),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_vert, color: primary),
        ),
      ],
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
                    // Messages list
                    Expanded(
                      child: Obx(() {
                        final messages = controller.messages;
                        
                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, 
                                    size: 64, color: Colors.grey[400]),
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
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = (message["from"] ?? "").toString() == widget.myUserId;
                            final text = (message["text"] ?? "").toString();
                            final status = (message["status"] ?? "").toString();
                            final time = _formatTime(message["createdAt"]);

                            // Check if message is first in group
                            final bool isFirstInGroup = index == 0 ||
                                messages[index - 1]["from"] != message["from"];

                            // Check if message is last in group
                            final bool isLastInGroup = index == messages.length - 1 ||
                                messages[index + 1]["from"] != message["from"];

                            if (isMe) {
                              return _buildGroupedSentBubble(
                                text: text,
                                time: time,
                                status: status,
                                isFirstInGroup: isFirstInGroup,
                              );
                            } else {
                              return _buildGroupedReceivedBubble(
                                text: text,
                                time: time,
                                isFirstInGroup: isFirstInGroup,
                              );
                            }
                          },
                        );
                      }),
                    ),

                    // Typing indicator
                    Obx(() => controller.isOtherTyping.value
                        ? _typingIndicator()
                        : const SizedBox()),

                    // Input bar
                    if (cid != null) _buildInputBar(cid),
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
      if (Get.isRegistered<ChatSocketController>()) {
        controller.clearActiveConversation();
      }
    } catch (e) {
      print('❌ Error clearing active conversation: $e');
    }
    
    super.dispose();
  }
}
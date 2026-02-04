import 'package:flutter/material.dart';
import 'package:templink/Utils/colors.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final bool userOnline;

  const ChatScreen({
    Key? key,
    required this.userName,
    required this.userOnline,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [
    {
      'text': 'Hey! How are you?',
      'sentByMe': false,
      'time': '12:30 PM',
      'image':
          'https://i.pravatar.cc/150?img=1', // network image for sender
    },
    {
      'text': 'I am good, thanks! You?',
      'sentByMe': true,
      'time': '12:31 PM',
      'image':
          'https://i.pravatar.cc/150?img=2', // network image for me
    },
    {
      'text': 'I need help with a project.',
      'sentByMe': false,
      'time': '12:32 PM',
      'image': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'text': 'Sure, tell me the details.',
      'sentByMe': true,
      'time': '12:33 PM',
      'image': 'https://i.pravatar.cc/150?img=2',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      messages.add({
        'text': _messageController.text.trim(),
        'sentByMe': true,
        'time': 'Now',
        'image': 'https://i.pravatar.cc/150?img=2', // my profile image
      });
      _messageController.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAvatar(String? imageUrl, String fallbackLetter) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(imageUrl),
        child: Text(
          fallbackLetter,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.grey[400],
        child: Text(
          fallbackLetter,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _buildAvatar(null, widget.userName[0]), // user avatar
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                Text(
                  widget.userOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sentByMe'] as bool;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isMe)
                        _buildAvatar(msg['image'], msg['text'][0]),
                      if (!isMe) const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? primary : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg['text'],
                              style: TextStyle(
                                color:
                                    isMe ? Colors.white : Colors.grey[900],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'],
                              style: TextStyle(
                                color:
                                    isMe ? Colors.white70 : Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMe) const SizedBox(width: 8),
                      if (isMe)
                        _buildAvatar(msg['image'], msg['text'][0]),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

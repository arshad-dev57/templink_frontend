import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Utils/colors.dart';
// ... imports same

class ChatUsersListScreen extends StatefulWidget {
  const ChatUsersListScreen({Key? key}) : super(key: key);

  @override
  State<ChatUsersListScreen> createState() => _ChatUsersListScreenState();
}

class _ChatUsersListScreenState extends State<ChatUsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<Map<String, dynamic>> users = [
    {
      'name': 'Arshad Nasir',
      'lastMessage': 'Hey, are you available for a project?',
      'time': '12:45 PM',
      'online': true,
      'unread': 3,
      'image': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Sarah Khan',
      'lastMessage': 'I sent you the documents.',
      'time': '11:30 AM',
      'online': false,
      'unread': 0,
      'image': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'name': 'Ali Raza',
      'lastMessage': 'Let\'s discuss the new project.',
      'time': 'Yesterday',
      'online': true,
      'unread': 1,
      'image': 'https://i.pravatar.cc/150?img=3',
    },
    {
      'name': 'Mariam Ahmed',
      'lastMessage': 'Thanks for the update!',
      'time': 'Yesterday',
      'online': false,
      'unread': 0,
      'image': 'https://i.pravatar.cc/150?img=4',
    },
    {
      'name': 'David Wilson',
      'lastMessage': 'Can you review my proposal?',
      'time': 'Monday',
      'online': false,
      'unread': 0,
      'image': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Lisa Chen',
      'lastMessage': 'Great work on the UI design!',
      'time': '2d ago',
      'online': true,
      'unread': 5,
      'image': 'https://i.pravatar.cc/150?img=6',
    },
    {
      'name': 'Michael Brown',
      'lastMessage': 'Meeting scheduled for tomorrow',
      'time': '3d ago',
      'online': false,
      'unread': 0,
      'image': 'https://i.pravatar.cc/150?img=7',
    },
    {
      'name': 'Emma Watson',
      'lastMessage': 'Payment sent, please confirm',
      'time': '1w ago',
      'online': true,
      'unread': 2,
      'image': 'https://i.pravatar.cc/150?img=8',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAvatar(String? imageUrl, String fallbackLetter, {double size = 56}) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(imageUrl),
        child: Text(
          fallbackLetter,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
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
    List<Map<String, dynamic>> filteredUsers = users
        .where((user) =>
            user['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${users.length} conversations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => searchQuery = val),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        Icons.search_rounded,
                        color: primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            if (searchQuery.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  'Active Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: users.where((user) => user['online']).length,
                  itemBuilder: (context, index) {
                    final onlineUsers =
                        users.where((user) => user['online']).toList();
                    final user = onlineUsers[index];
                    return Container(
                      width: 68,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(() => ChatScreen(
                                        userName: user['name'],
                                        userOnline: user['online'],
                                      ));
                                },
                                child: _buildAvatar(
                                  user['image'],
                                  user['name'].split(' ').map((n) => n[0]).join(),
                                  size: 56,
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user['name'].split(' ')[0],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, searchQuery.isEmpty ? 0 : 16, 20, 12),
              child: Text(
                searchQuery.isEmpty ? 'All Messages' : 'Search Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),

            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredUsers.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey[100],
                        indent: 72,
                      ),
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Get.to(() => ChatScreen(
                                    userName: user['name'],
                                    userOnline: user['online'],
                                  ));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      _buildAvatar(
                                        user['image'],
                                        user['name']
                                            .split(' ')
                                            .map((n) => n[0])
                                            .join(),
                                        size: 56,
                                      ),
                                      if (user['online'])
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                user['name'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[900],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              user['time'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user['lastMessage'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Unread Badge
                                  if (user['unread'] > 0) ...[
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          user['unread'].toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // New Message FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Start new conversation
        },
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.message_rounded, size: 24),
      ),
    );
  }
}

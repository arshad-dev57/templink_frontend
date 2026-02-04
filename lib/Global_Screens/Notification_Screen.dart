import 'package:flutter/material.dart';
import 'package:templink/Utils/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'New Message from Sarah Khan',
      'subtitle': 'Hey, did you check the document?',
      'time': '2 min ago',
      'image': 'https://i.pravatar.cc/150?img=2',
      'read': false,
    },
    {
      'title': 'Project Update',
      'subtitle': 'Ali Raza updated the project status.',
      'time': '1 hr ago',
      'image': 'https://i.pravatar.cc/150?img=3',
      'read': true,
    },
    {
      'title': 'Payment Received',
      'subtitle': 'You received \$250 from Lisa Chen.',
      'time': 'Yesterday',
      'image': 'https://i.pravatar.cc/150?img=6',
      'read': false,
    },
    {
      'title': 'Meeting Reminder',
      'subtitle': 'Meeting scheduled for tomorrow at 11 AM.',
      'time': '2d ago',
      'image': 'https://i.pravatar.cc/150?img=7',
      'read': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = notifications.where((n) {
      final query = searchQuery.toLowerCase();
      return n['title'].toLowerCase().contains(query) ||
          n['subtitle'].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search notifications...',
                  prefixIcon: Icon(Icons.search_rounded, color: primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications found',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notif = filteredNotifications[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(notif['image']),
                          ),
                          title: Text(
                            notif['title'],
                            style: TextStyle(
                              fontWeight: notif['read'] ? FontWeight.normal : FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          subtitle: Text(
                            notif['subtitle'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                notif['time'],
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                              if (!notif['read'])
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            setState(() => notif['read'] = true);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

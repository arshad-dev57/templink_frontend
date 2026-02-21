// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:templink/Global_Screens/Chat_Screen.dart';
// import 'package:templink/Utils/colors.dart';
// import 'package:templink/config/api_config.dart';
// import 'package:templink/controllers/chat_list_controller.dart';
// import 'package:templink/controllers/chat_socket_controller.dart';

// class ChatUsersListScreen extends StatefulWidget {
//   const ChatUsersListScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatUsersListScreen> createState() => _ChatUsersListScreenState();
// }

// class _ChatUsersListScreenState extends State<ChatUsersListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String searchQuery = '';

//   // ✅ Dynamic values from SharedPreferences
//   late String baseUrl;
//   late String myToken;
//   late String myUserId;
//   late String myName;

//   late final ChatListController listC;
//   late final ChatSocketController socketC;

//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeChat();
//   }

//   // ✅ Initialize chat with user data from SharedPreferences
//   Future<void> _initializeChat() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
      
//       // Get values from SharedPreferences
//       baseUrl = ApiConfig.baseUrl;
//       myToken = prefs.getString('auth_token') ?? '';
//       myUserId = prefs.getString('auth_user_id') ?? '';
      
//       // Get user name from auth_user JSON
//       final userJson = prefs.getString('auth_user');
//       if (userJson != null) {
//         try {
//           final userData = jsonDecode(userJson);
//           myName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
//           if (myName.isEmpty) myName = 'User';
//         } catch (e) {
//           myName = 'User';
//         }
//       } else {
//         myName = 'User';
//       }

//       // Validate required data
//       if (myToken.isEmpty) {
//         Get.snackbar(
//           'Error',
//           'Authentication token missing. Please login again.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         setState(() => _isLoading = false);
//         return;
//       }

//       if (myUserId.isEmpty) {
//         Get.snackbar(
//           'Error',
//           'User ID missing. Please login again.',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         setState(() => _isLoading = false);
//         return;
//       }

//       // Initialize Socket Controller
//       socketC = Get.put(
//         ChatSocketController(
//           socketBaseUrl: baseUrl,
//           token: myToken,
//           myUserId: myUserId,
//         ),
//         permanent: true,
//       );

//       // Initialize Chat List Controller
//       listC = Get.put(
//         ChatListController(
//           baseUrl: baseUrl, 
//           token: myToken
//         ),
//       );

//       setState(() => _isLoading = false);
      
//     } catch (e) {
//       print('❌ Error initializing chat: $e');
//       setState(() => _isLoading = false);
//       Get.snackbar(
//         'Error',
//         'Failed to initialize chat',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// // 📁 lib/Global_Screens/ChatUsersListScreen.dart
// // ✅ Update _buildAvatar function

// Widget _buildAvatar(String? imageUrl, String fallbackLetter, {double size = 56}) {
//   // ✅ AGAR IMAGE URL HAI TO USE KARO
//   if (imageUrl != null && imageUrl.isNotEmpty) {
//     return CircleAvatar(
//       radius: size / 2,
//       backgroundColor: Colors.grey[300],
//       backgroundImage: NetworkImage(imageUrl),
//       onBackgroundImageError: (_, __) {
//         // Agar image load fail ho to fallback dikhao
//       },
//     );
//   }
  
//   // ✅ UI AVATARS - Automatic name se image generate karo
//   final initial = fallbackLetter.isNotEmpty 
//       ? fallbackLetter[0].toUpperCase() 
//       : '?';
  
//   // UI Avatars URL - backend change ki zaroorat nahi
//   final uiAvatarUrl = 'https://ui-avatars.com/api/?name=$initial&background=4F46E5&color=fff&size=128';
  
//   return CircleAvatar(
//     radius: size / 2,
//     backgroundColor: Colors.grey[400],
//     backgroundImage: NetworkImage(uiAvatarUrl),
//     child: Container(), // Empty container because we're using backgroundImage
//   );
// }
//   String _formatTime(dynamic t) => t == null ? "" : t.toString();

//   @override
//   Widget build(BuildContext context) {
//     // Show loading while initializing
//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const CircularProgressIndicator(color: primary),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Loading conversations...',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Obx(() {
//           // Check if listC is initialized
//           if (listC == null) {
//             return const Center(child: Text('Chat service unavailable'));
//           }

//           final users = listC.conversations;

//           final filteredUsers = users.where((u) {
//             final name = (u["name"] ?? "").toString().toLowerCase();
//             return name.contains(searchQuery.toLowerCase());
//           }).toList();

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Messages',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.grey[900],
//                             letterSpacing: -0.5,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () => listC.loadConversations(),
//                           icon: Icon(Icons.refresh_rounded, color: Colors.grey[600], size: 24),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${users.length} conversations',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               ),

//               // Search Bar
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: Colors.grey[200]!, width: 1.5),
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (val) => setState(() => searchQuery = val),
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                     decoration: InputDecoration(
//                       hintText: 'Search messages...',
//                       hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                       prefixIcon: Padding(
//                         padding: const EdgeInsets.only(left: 16, right: 12),
//                         child: Icon(Icons.search_rounded, color: primary, size: 24),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // Section Title
//               Padding(
//                 padding: EdgeInsets.fromLTRB(20, searchQuery.isEmpty ? 0 : 16, 20, 12),
//                 child: Text(
//                   searchQuery.isEmpty ? 'All Messages' : 'Search Results',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
//                 ),
//               ),

//               // Conversations List
//               Expanded(
//                 child: filteredUsers.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.chat_bubble_outline,
//                               size: 64,
//                               color: Colors.grey[400],
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               searchQuery.isEmpty 
//                                   ? 'No conversations yet' 
//                                   : 'No conversations found',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             if (searchQuery.isEmpty) ...[
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Start chatting with talents and employers',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       )
//                     : ListView.separated(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         itemCount: filteredUsers.length,
//                         separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[100], indent: 72),
//                         itemBuilder: (context, index) {
//                           final user = filteredUsers[index];
//                           final name = (user["name"] ?? "Unknown User").toString();
//                           final toUserId = (user["userId"] ?? "").toString();
//                           final unread = (user["unread"] ?? 0) as int;
//                           final lastMessage = (user["lastMessage"] ?? "No messages yet").toString();
//                           final time = _formatTime(user["time"]);
//                           final imageUrl = user["image"]?.toString();

//                           return InkWell(
//                             onTap: () {
//                               // ✅ Navigate to Chat Screen with dynamic values
//                               Get.to(() => ChatScreen(
//                                     userName: name,
//                                     userOnline: false,
//                                     toUserId: toUserId,
//                                     baseUrl: baseUrl,
//                                     myToken: myToken,
//                                     myUserId: myUserId,
//                                   ));
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               child: Row(
//                                 children: [
//                                   _buildAvatar(imageUrl, name),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 name,
//                                                 style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
//                                                   color: Colors.grey[900],
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                             if (time.isNotEmpty)
//                                               Text(
//                                                 time,
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: unread > 0 ? primary : Colors.grey[500],
//                                                   fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           lastMessage,
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: unread > 0 ? Colors.grey[800] : Colors.grey[600],
//                                             fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
//                                             height: 1.4,
//                                           ),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   if (unread > 0) ...[
//                                     const SizedBox(width: 12),
//                                     Container(
//                                       width: 24,
//                                       height: 24,
//                                       decoration: BoxDecoration(
//                                         color: primary,
//                                         shape: BoxShape.circle,
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: primary.withOpacity(0.3),
//                                             blurRadius: 4,
//                                             offset: const Offset(0, 2),
//                                           ),
//                                         ],
//                                       ),
//                                       child: Center(
//                                         child: Text(
//                                           unread > 9 ? '9+' : unread.toString(),
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
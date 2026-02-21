// // lib/Employee/Resume/screens/resume_dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
// import 'package:templink/Resume_Builder/Models/resume_model.dart';
// import 'package:templink/Utils/colors.dart';
// import 'package:intl/intl.dart';

// class ResumeDashboardScreen extends StatelessWidget {
//   final controller = Get.put(ResumeController());
//   final dateFormat = DateFormat('MMM dd, yyyy');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'My Resumes',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => controller.fetchResumes(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: _showInfoDialog,
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         return Column(
//           children: [
//             _buildStatsSection(),
//             Expanded(
//               child: controller.resumes.isEmpty
//                   ? _buildEmptyState()
//                   : _buildResumesList(),
//             ),
//           ],
//         );
//       }),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showCreateDialog,
//         icon: const Icon(Icons.add),
//         label: const Text('New Resume'),
//         backgroundColor: primary,
//       ),
//     );
//   }

//   // ==================== STATS SECTION ====================
//   Widget _buildStatsSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           _buildStatCard(
//             icon: Icons.description,
//             label: 'Total',
//             value: controller.totalResumes.value.toString(),
//             color: Colors.blue,
//           ),
//           const SizedBox(width: 12),
//           _buildStatCard(
//             icon: Icons.check_circle,
//             label: 'Complete',
//             value: controller.completedResumes.value.toString(),
//             color: Colors.green,
//           ),
//           const SizedBox(width: 12),
//           _buildStatCard(
//             icon: Icons.edit,
//             label: 'Draft',
//             value: controller.draftResumes.value.toString(),
//             color: Colors.orange,
//           ),
//           const SizedBox(width: 12),
//           _buildStatCard(
//             icon: Icons.auto_awesome,
//             label: 'AI Enhanced',
//             value: controller.aiEnhancedResumes.value.toString(),
//             color: Colors.purple,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== RESUMES LIST ====================
//   Widget _buildResumesList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: controller.resumes.length,
//       itemBuilder: (context, index) {
//         final resume = controller.resumes[index];
//         return _buildResumeCard(resume);
//       },
//     );
//   }

//   Widget _buildResumeCard(ResumeModel resume) {
//     Color statusColor;
//     IconData statusIcon;

//     switch (resume.status) {
//       case 'complete':
//         statusColor = Colors.green;
//         statusIcon = Icons.check_circle;
//         break;
//       case 'draft':
//         statusColor = Colors.orange;
//         statusIcon = Icons.edit;
//         break;
//       case 'ai_enhanced':
//         statusColor = Colors.purple;
//         statusIcon = Icons.auto_awesome;
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusIcon = Icons.description;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _editResume(resume),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         statusIcon,
//                         color: statusColor,
//                         size: 28,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             resume.title,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Last updated: ${dateFormat.format(resume.updatedAt)}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         resume.statusText,
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           color: statusColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 // Progress Bar
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: LinearProgressIndicator(
//                           value: resume.completionPercentage / 100,
//                           backgroundColor: Colors.grey[200],
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             resume.completionPercentage == 100
//                                 ? Colors.green
//                                 : Colors.blue,
//                           ),
//                           minHeight: 6,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${resume.completionPercentage}%',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: resume.completionPercentage == 100
//                             ? Colors.green
//                             : Colors.blue,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 // Action Buttons
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     IconButton(
//                       onPressed: () => _editResume(resume),
//                       icon: const Icon(Icons.edit, size: 20),
//                       color: Colors.blue,
//                     ),
//                     IconButton(
//                       onPressed: () => _duplicateResume(resume),
//                       icon: const Icon(Icons.copy, size: 20),
//                       color: Colors.orange,
//                     ),
//                     IconButton(
//                       onPressed: () => _downloadResume(resume),
//                       icon: const Icon(Icons.download, size: 20),
//                       color: Colors.green,
//                     ),
//                     IconButton(
//                       onPressed: () => _deleteResume(resume),
//                       icon: const Icon(Icons.delete, size: 20),
//                       color: Colors.red,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ==================== EMPTY STATE ====================
//   Widget _buildEmptyState() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.description_outlined,
//                 size: 60,
//                 color: primary.withOpacity(0.5),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'No Resumes Yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Create your first professional resume\nwith AI assistance',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _showCreateDialog,
//               icon: const Icon(Icons.add),
//               label: const Text('Create New Resume'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primary,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 12,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== DIALOGS ====================
//   void _showCreateDialog() {
//     final titleController = TextEditingController();

//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: const Text('Create New Resume'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Give your resume a name',
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: titleController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: 'e.g., Software Engineer Resume',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 prefixIcon: const Icon(Icons.description),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.createResume(titleController.text);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primary,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Create'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showInfoDialog() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: const Text('About Resumes'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.check_circle, color: Colors.green),
//               title: Text('Complete'),
//               subtitle: Text('All sections filled'),
//             ),
//             ListTile(
//               leading: Icon(Icons.edit, color: Colors.orange),
//               title: Text('Draft'),
//               subtitle: Text('In progress, not finished'),
//             ),
//             ListTile(
//               leading: Icon(Icons.auto_awesome, color: Colors.purple),
//               title: Text('AI Enhanced'),
//               subtitle: Text('Optimized with AI suggestions'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Got it'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== ACTIONS ====================
//   void _editResume(ResumeModel resume) {
//     // Navigate to resume editor
//     Get.toNamed('/resume/editor', arguments: resume);
//   }

//   void _duplicateResume(ResumeModel resume) {
//     controller.duplicateResume(resume.id);
//   }

//   void _downloadResume(ResumeModel resume) {
//     controller.downloadResume(resume.id);
//   }

//   void _deleteResume(ResumeModel resume) {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: const Text('Delete Resume'),
//         content: Text('Are you sure you want to delete "${resume.title}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.deleteResume(resume.id);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }
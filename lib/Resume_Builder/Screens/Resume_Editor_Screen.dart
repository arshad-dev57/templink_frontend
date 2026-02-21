// // lib/Employee/Resume/screens/resume_editor_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
// import 'package:templink/Resume_Builder/Models/resume_model.dart';

// import 'package:templink/Utils/colors.dart';
// import 'package:intl/intl.dart';

// class ResumeEditorScreen extends StatelessWidget {
//   final ResumeModel resume = Get.arguments;
//   final controller = Get.find<ResumeController>();
//   final dateFormat = DateFormat('MMM yyyy');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           resume.title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: primary,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: _buildProgressBar(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.preview),
//             onPressed: _previewResume,
//           ),
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveResume,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildSectionHeader(
//               'Personal Information',
//               Icons.person,
//               Colors.blue,
//               onTap: () => _editPersonalInfo(),
//             ),
//             _buildPersonalInfoPreview(),
            
//             const SizedBox(height: 16),
            
//             _buildSectionHeader(
//               'Work Experience',
//               Icons.work,
//               Colors.green,
//               onTap: () => _addExperience(),
//             ),
//             _buildExperienceList(),
            
//             const SizedBox(height: 16),
            
//             _buildSectionHeader(
//               'Education',
//               Icons.school,
//               Colors.orange,
//               onTap: () => _addEducation(),
//             ),
//             _buildEducationList(),
            
//             const SizedBox(height: 16),
            
//             _buildSectionHeader(
//               'Skills',
//               Icons.code,
//               Colors.purple,
//               onTap: () => _editSkills(),
//             ),
//             _buildSkillsPreview(),
            
//             const SizedBox(height: 16),
            
//             _buildSectionHeader(
//               'Projects',
//               Icons.folder,
//               Colors.teal,
//               onTap: () => _addProject(),
//             ),
//             _buildProjectsList(),
            
//             const SizedBox(height: 20),
            
//             // AI Enhancement Button
//             _buildAIEnhanceButton(),
            
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== PROGRESS BAR ====================
//   Widget _buildProgressBar() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: LinearProgressIndicator(
//                 value: resume.completionPercentage / 100,
//                 backgroundColor: Colors.grey[200],
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   resume.completionPercentage == 100 ? Colors.green : Colors.blue,
//                 ),
//                 minHeight: 8,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             '${resume.completionPercentage}%',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: resume.completionPercentage == 100 ? Colors.green : Colors.blue,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== SECTION HEADER ====================
//   Widget _buildSectionHeader(String title, IconData icon, Color color, {required VoidCallback onTap}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Spacer(),
//           IconButton(
//             onPressed: onTap,
//             icon: Icon(Icons.add_circle_outline, color: color),
//             iconSize: 24,
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== PERSONAL INFO PREVIEW ====================
//   Widget _buildPersonalInfoPreview() {
//     final info = resume.personalInfo;
    
//     if (info == null) {
//       return Card(
//         child: InkWell(
//           onTap: _editPersonalInfo,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(Icons.info, color: Colors.grey[400]),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Add personal information',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Card(
//       child: InkWell(
//         onTap: _editPersonalInfo,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor: primary.withOpacity(0.1),
//                     child: Text(
//                       info.fullName.isNotEmpty ? info.fullName[0] : '?',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: primary,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           info.fullName,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         if (info.title.isNotEmpty)
//                           Text(
//                             info.title,
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               if (info.email.isNotEmpty) ...[
//                 const Divider(),
//                 _buildInfoRow(Icons.email, info.email),
//               ],
//               if (info.phone.isNotEmpty)
//                 _buildInfoRow(Icons.phone, info.phone),
//               if (info.summary.isNotEmpty) ...[
//                 const Divider(),
//                 Text(
//                   info.summary,
//                   style: const TextStyle(height: 1.5),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== EXPERIENCE LIST ====================
//   Widget _buildExperienceList() {
//     if (resume.experiences.isEmpty) {
//       return Card(
//         child: InkWell(
//           onTap: _addExperience,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(Icons.work_outline, color: Colors.grey[400]),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Add work experience',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: resume.experiences.map((exp) => _buildExperienceCard(exp)).toList(),
//     );
//   }

//   Widget _buildExperienceCard(WorkExperience exp) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: Colors.green.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.work, color: Colors.green, size: 20),
//         ),
//         title: Text(
//           exp.title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(exp.company),
//             Text(
//               '${dateFormat.format(exp.startDate)} - ${exp.current ? 'Present' : dateFormat.format(exp.endDate!)}',
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         trailing: PopupMenuButton(
//           icon: const Icon(Icons.more_vert),
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//               child: Text('Edit'),
//               value: 'edit',
//             ),
//             const PopupMenuItem(
//               child: Text('Delete'),
//               value: 'delete',
//             ),
//           ],
//           onSelected: (value) {
//             if (value == 'edit') {
//               _editExperience(exp);
//             } else if (value == 'delete') {
//               _deleteExperience(exp.id);
//             }
//           },
//         ),
//         onTap: () => _editExperience(exp),
//       ),
//     );
//   }

//   // ==================== EDUCATION LIST ====================
//   Widget _buildEducationList() {
//     if (resume.education.isEmpty) {
//       return Card(
//         child: InkWell(
//           onTap: _addEducation,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(Icons.school_outlined, color: Colors.grey[400]),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Add education',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: resume.education.map((edu) => _buildEducationCard(edu)).toList(),
//     );
//   }

//   Widget _buildEducationCard(Education edu) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: Colors.orange.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.school, color: Colors.orange, size: 20),
//         ),
//         title: Text(
//           edu.degree,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('${edu.field} - ${edu.institution}'),
//             Text(
//               '${dateFormat.format(edu.startDate)} - ${edu.current ? 'Present' : dateFormat.format(edu.endDate!)}',
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         trailing: PopupMenuButton(
//           icon: const Icon(Icons.more_vert),
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//               child: Text('Edit'),
//               value: 'edit',
//             ),
//             const PopupMenuItem(
//               child: Text('Delete'),
//               value: 'delete',
//             ),
//           ],
//           onSelected: (value) {
//             if (value == 'edit') {
//               _editEducation(edu);
//             } else if (value == 'delete') {
//               _deleteEducation(edu.id);
//             }
//           },
//         ),
//         onTap: () => _editEducation(edu),
//       ),
//     );
//   }

//   // ==================== SKILLS PREVIEW ====================
//   Widget _buildSkillsPreview() {
//     if (resume.skills.isEmpty) {
//       return Card(
//         child: InkWell(
//           onTap: _editSkills,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(Icons.code_rounded, color: Colors.grey[400]),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Add skills',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: resume.skills.map((skill) {
//             Color levelColor;
//             switch (skill.level) {
//               case 'Expert':
//                 levelColor = Colors.green;
//                 break;
//               case 'Advanced':
//                 levelColor = Colors.blue;
//                 break;
//               case 'Intermediate':
//                 levelColor = Colors.orange;
//                 break;
//               default:
//                 levelColor = Colors.grey;
//             }

//             return Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 6,
//               ),
//               decoration: BoxDecoration(
//                 color: levelColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: levelColor.withOpacity(0.3)),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     skill.name,
//                     style: TextStyle(
//                       color: levelColor,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '• ${skill.level}',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: levelColor.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   // ==================== PROJECTS LIST ====================
//   Widget _buildProjectsList() {
//     if (resume.projects.isEmpty) {
//       return Card(
//         child: InkWell(
//           onTap: _addProject,
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Icon(Icons.folder, color: Colors.grey[400]),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Add projects',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       children: resume.projects.map((project) => _buildProjectCard(project)).toList(),
//     );
//   }

//   Widget _buildProjectCard(Project project) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: Colors.teal.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.folder, color: Colors.teal, size: 20),
//         ),
//         title: Text(
//           project.title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           project.description,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         trailing: PopupMenuButton(
//           icon: const Icon(Icons.more_vert),
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//               child: Text('Edit'),
//               value: 'edit',
//             ),
//             const PopupMenuItem(
//               child: Text('Delete'),
//               value: 'delete',
//             ),
//           ],
//           onSelected: (value) {
//             if (value == 'edit') {
//               _editProject(project);
//             } else if (value == 'delete') {
//               _deleteProject(project.id);
//             }
//           },
//         ),
//         onTap: () => _editProject(project),
//       ),
//     );
//   }

//   // ==================== AI ENHANCE BUTTON ====================
//   Widget _buildAIEnhanceButton() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.purple, Colors.purple.withOpacity(0.8)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.auto_awesome, color: Colors.white),
//               SizedBox(width: 8),
//               Text(
//                 'AI Enhancement',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Get AI-powered suggestions to improve your resume',
//             style: TextStyle(color: Colors.white70),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: _optimizeWithAI,
//                   icon: const Icon(Icons.auto_awesome, color: Colors.white),
//                   label: const Text(
//                     'Optimize',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.white),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: _analyzeWithAI,
//                   icon: const Icon(Icons.analytics),
//                   label: const Text('Analyze'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.purple,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== NAVIGATION & ACTIONS ====================
//   void _editPersonalInfo() {
//     Get.toNamed('/resume/personal-info', arguments: resume);
//   }

//   void _addExperience() {
//     Get.toNamed('/resume/experience', arguments: {'resume': resume, 'mode': 'add'});
//   }

//   void _editExperience(WorkExperience exp) {
//     Get.toNamed('/resume/experience', arguments: {'resume': resume, 'experience': exp, 'mode': 'edit'});
//   }

//   void _deleteExperience(String id) {
//     // TODO: Implement delete
//   }

//   void _addEducation() {
//     Get.toNamed('/resume/education', arguments: {'resume': resume, 'mode': 'add'});
//   }

//   void _editEducation(Education edu) {
//     Get.toNamed('/resume/education', arguments: {'resume': resume, 'education': edu, 'mode': 'edit'});
//   }

//   void _deleteEducation(String id) {
//     // TODO: Implement delete
//   }

//   void _editSkills() {
//     Get.toNamed('/resume/skills', arguments: resume);
//   }

//   void _addProject() {
//     Get.toNamed('/resume/project', arguments: {'resume': resume, 'mode': 'add'});
//   }

//   void _editProject(Project project) {
//     Get.toNamed('/resume/project', arguments: {'resume': resume, 'project': project, 'mode': 'edit'});
//   }

//   void _deleteProject(String id) {
//     // TODO: Implement delete
//   }

//   void _previewResume() {
//     Get.toNamed('/resume/preview', arguments: resume);
//   }

//   void _saveResume() {
//     // TODO: Implement save
//     Get.snackbar(
//       'Success',
//       'Resume saved successfully',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void _optimizeWithAI() {
//     // TODO: Implement AI optimization
//     Get.snackbar(
//       'AI Optimization',
//       'Analyzing your resume...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }

//   void _analyzeWithAI() {
//     // TODO: Implement AI analysis
//     Get.snackbar(
//       'AI Analysis',
//       'Generating insights...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }
// }
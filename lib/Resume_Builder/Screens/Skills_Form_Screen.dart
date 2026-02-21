// // lib/Employee/Resume/screens/skills_form_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
// import 'package:templink/Resume_Builder/Models/resume_model.dart';

// import 'package:templink/Utils/colors.dart';

// class SkillsFormScreen extends StatelessWidget {
//   final ResumeModel resume = Get.arguments;
//   final controller = Get.find<ResumeController>();
  
//   final RxList<Skill> skills = <Skill>[].obs;
//   final TextEditingController skillController = TextEditingController();
//   final RxString selectedLevel = 'Intermediate'.obs;

//   final List<String> proficiencyLevels = [
//     'Beginner',
//     'Intermediate',
//     'Advanced',
//     'Expert'
//   ];

//   SkillsFormScreen() {
//     // Load existing skills
//     skills.value = List.from(resume.skills);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Skills',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.purple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveSkills,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildAddSkillCard(),
//           Expanded(
//             child: Obx(() => skills.isEmpty
//                 ? _buildEmptyState()
//                 : _buildSkillsList()),
//           ),
//           _buildAISuggestionsCard(),
//         ],
//       ),
//     );
//   }

//   // ==================== ADD SKILL CARD ====================
//   Widget _buildAddSkillCard() {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Add New Skill',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           // Skill Name
//           TextField(
//             controller: skillController,
//             decoration: InputDecoration(
//               labelText: 'Skill Name',
//               hintText: 'e.g., Flutter, Python, Project Management',
//               prefixIcon: const Icon(Icons.code, color: Colors.purple),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.grey[50],
//             ),
//           ),
          
//           const SizedBox(height: 12),
          
//           // Proficiency Level
//           const Text(
//             'Proficiency Level',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 8),
          
//           Obx(() => Row(
//             children: proficiencyLevels.map((level) {
//               bool isSelected = selectedLevel.value == level;
//               Color color;
//               switch (level) {
//                 case 'Beginner':
//                   color = Colors.grey;
//                   break;
//                 case 'Intermediate':
//                   color = Colors.blue;
//                   break;
//                 case 'Advanced':
//                   color = Colors.orange;
//                   break;
//                 case 'Expert':
//                   color = Colors.green;
//                   break;
//                 default:
//                   color = Colors.purple;
//               }
              
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => selectedLevel.value = level,
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 4),
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                       color: isSelected ? color : color.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: isSelected ? color : color.withOpacity(0.3),
//                       ),
//                     ),
//                     child: Text(
//                       level,
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                         color: isSelected ? Colors.white : color,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           )),
          
//           const SizedBox(height: 12),
          
//           // Add Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: _addSkill,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Skill'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== SKILLS LIST ====================
//   Widget _buildSkillsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: skills.length,
//       itemBuilder: (context, index) {
//         final skill = skills[index];
//         return _buildSkillCard(skill, index);
//       },
//     );
//   }

//   Widget _buildSkillCard(Skill skill, int index) {
//     Color levelColor;
//     switch (skill.level) {
//       case 'Beginner':
//         levelColor = Colors.grey;
//         break;
//       case 'Intermediate':
//         levelColor = Colors.blue;
//         break;
//       case 'Advanced':
//         levelColor = Colors.orange;
//         break;
//       case 'Expert':
//         levelColor = Colors.green;
//         break;
//       default:
//         levelColor = Colors.purple;
//     }

//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: levelColor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             Icons.code,
//             color: levelColor,
//             size: 20,
//           ),
//         ),
//         title: Text(
//           skill.name,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 2,
//               ),
//               decoration: BoxDecoration(
//                 color: levelColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 skill.level,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: levelColor,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               '${skill.yearsOfExperience} yrs',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete, color: Colors.red),
//           onPressed: () => _removeSkill(index),
//         ),
//         onTap: () => _editSkill(skill, index),
//       ),
//     );
//   }

//   // ==================== EMPTY STATE ====================
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               color: Colors.purple.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.code,
//               size: 60,
//               color: Colors.purple.withOpacity(0.5),
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'No Skills Added',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Add your technical and professional skills',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== AI SUGGESTIONS CARD ====================
//   Widget _buildAISuggestionsCard() {
//     return Container(
//       margin: const EdgeInsets.all(16),
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
//                 'AI Skill Suggestions',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Based on your experience, we recommend these skills:',
//             style: TextStyle(color: Colors.white70),
//           ),
//           const SizedBox(height: 16),
          
//           // Suggested Skills
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _buildSuggestionChip('Flutter', 'Expert'),
//               _buildSuggestionChip('Firebase', 'Advanced'),
//               _buildSuggestionChip('REST APIs', 'Advanced'),
//               _buildSuggestionChip('Git', 'Expert'),
//               _buildSuggestionChip('UI/UX', 'Intermediate'),
//             ],
//           ),
          
//           const SizedBox(height: 16),
          
//           // Add All Button
//           OutlinedButton.icon(
//             onPressed: _addAllSuggestions,
//             icon: const Icon(Icons.add, color: Colors.white),
//             label: const Text(
//               'Add All Suggestions',
//               style: TextStyle(color: Colors.white),
//             ),
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: Colors.white),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               minimumSize: const Size(double.infinity, 40),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSuggestionChip(String skill, String level) {
//     Color levelColor;
//     switch (level) {
//       case 'Expert':
//         levelColor = Colors.green;
//         break;
//       case 'Advanced':
//         levelColor = Colors.orange;
//         break;
//       default:
//         levelColor = Colors.blue;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             skill,
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(width: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 6,
//               vertical: 2,
//             ),
//             decoration: BoxDecoration(
//               color: levelColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               level,
//               style: TextStyle(
//                 fontSize: 8,
//                 color: levelColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(width: 4),
//           GestureDetector(
//             onTap: () => _addSuggestedSkill(skill, level),
//             child: const Icon(Icons.add_circle, color: Colors.purple, size: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== HELPER METHODS ====================
//   void _addSkill() {
//     if (skillController.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please enter a skill name',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     final newSkill = Skill(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: skillController.text,
//       level: selectedLevel.value,
//       yearsOfExperience: 0, // Can be enhanced later
//     );

//     skills.add(newSkill);
//     skillController.clear();
//     selectedLevel.value = 'Intermediate';

//     Get.snackbar(
//       'Success',
//       'Skill added',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void _removeSkill(int index) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Remove Skill'),
//         content: Text('Are you sure you want to remove "${skills[index].name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               skills.removeAt(index);
//               Get.back();
//               Get.snackbar(
//                 'Success',
//                 'Skill removed',
//                 backgroundColor: Colors.green,
//                 colorText: Colors.white,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Remove'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _editSkill(Skill skill, int index) {
//     // Simple edit - can be enhanced with a dialog
//     skillController.text = skill.name;
//     selectedLevel.value = skill.level;
//     skills.removeAt(index);
    
//     Get.snackbar(
//       'Info',
//       'Edit the skill and add again',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//     );
//   }

//   void _addSuggestedSkill(String name, String level) {
//     final newSkill = Skill(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: name,
//       level: level,
//       yearsOfExperience: 0,
//     );

//     // Check if already exists
//     if (skills.any((s) => s.name.toLowerCase() == name.toLowerCase())) {
//       Get.snackbar(
//         'Info',
//         'Skill already exists',
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     skills.add(newSkill);
//     Get.snackbar(
//       'Success',
//       'Skill added',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void _addAllSuggestions() {
//     final suggestions = [
//       {'name': 'Flutter', 'level': 'Expert'},
//       {'name': 'Firebase', 'level': 'Advanced'},
//       {'name': 'REST APIs', 'level': 'Advanced'},
//       {'name': 'Git', 'level': 'Expert'},
//       {'name': 'UI/UX', 'level': 'Intermediate'},
//     ];

//     int added = 0;
//     for (var suggestion in suggestions) {
//       if (!skills.any((s) => s.name.toLowerCase() == suggestion['name']!.toLowerCase())) {
//         skills.add(Skill(
//           id: DateTime.now().millisecondsSinceEpoch.toString(),
//           name: suggestion['name']!,
//           level: suggestion['level']!,
//           yearsOfExperience: 0,
//         ));
//         added++;
//       }
//     }

//     Get.snackbar(
//       'Success',
//       'Added $added new skills',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void _saveSkills() {
//     // TODO: Save to backend
//     // controller.updateSkills(resume.id, skills.toList());

//     Get.back();
//     Get.snackbar(
//       'Success',
//       'Skills saved successfully',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }
// }
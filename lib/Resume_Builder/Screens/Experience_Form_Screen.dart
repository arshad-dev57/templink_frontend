// // lib/Employee/Resume/screens/experience_form_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
// import 'package:templink/Resume_Builder/Models/resume_model.dart';
// import 'package:templink/Utils/colors.dart';
// import 'package:intl/intl.dart';

// class ExperienceFormScreen extends StatelessWidget {
//   final Map<String, dynamic> args = Get.arguments;
//   final ResumeModel resume = Get.arguments['resume'];
//   final String mode = Get.arguments['mode']; // 'add' or 'edit'
//   final WorkExperience? existingExperience = Get.arguments['experience'];
  
//   final controller = Get.find<ResumeController>();
//   final dateFormat = DateFormat('yyyy-MM-dd');
  
//   final titleController = TextEditingController();
//   final companyController = TextEditingController();
//   final locationController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final achievementsController = TextEditingController();
  
//   final Rx<DateTime> startDate = DateTime.now().obs;
//   final Rx<DateTime?> endDate = Rx<DateTime?>(null);
//   final RxBool currentlyWorking = false.obs;

//   ExperienceFormScreen() {
//     // Load existing data if in edit mode
//     if (mode == 'edit' && existingExperience != null) {
//       final exp = existingExperience!;
//       titleController.text = exp.title;
//       companyController.text = exp.company;
//       locationController.text = exp.location;
//       descriptionController.text = exp.description;
//       achievementsController.text = exp.achievements.join('\n');
//       startDate.value = exp.startDate;
//       endDate.value = exp.endDate;
//       currentlyWorking.value = exp.current;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           mode == 'add' ? 'Add Experience' : 'Edit Experience',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveExperience,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildBasicInfoCard(),
//             const SizedBox(height: 16),
//             _buildDatesCard(),
//             const SizedBox(height: 16),
//             _buildDescriptionCard(),
//             const SizedBox(height: 16),
//             _buildAchievementsCard(),
//             const SizedBox(height: 16),
//             _buildAIEnhanceCard(),
//             const SizedBox(height: 30),
//             _buildSaveButton(),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== BASIC INFO CARD ====================
//   Widget _buildBasicInfoCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Basic Information',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Job Title
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(
//                 labelText: 'Job Title *',
//                 hintText: 'e.g., Senior Flutter Developer',
//                 prefixIcon: const Icon(Icons.work, color: Colors.green),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//             const SizedBox(height: 12),
            
//             // Company
//             TextField(
//               controller: companyController,
//               decoration: InputDecoration(
//                 labelText: 'Company *',
//                 hintText: 'e.g., Google, Microsoft',
//                 prefixIcon: const Icon(Icons.business, color: Colors.green),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//             const SizedBox(height: 12),
            
//             // Location
//             TextField(
//               controller: locationController,
//               decoration: InputDecoration(
//                 labelText: 'Location',
//                 hintText: 'e.g., San Francisco, CA',
//                 prefixIcon: const Icon(Icons.location_on, color: Colors.green),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== DATES CARD ====================
//   Widget _buildDatesCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Duration',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Start Date
//             Obx(() => ListTile(
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.calendar_today, color: Colors.green, size: 20),
//               ),
//               title: const Text('Start Date *'),
//               subtitle: Text(dateFormat.format(startDate.value)),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               onTap: _selectStartDate,
//             )),
            
//             const Divider(),
            
//             // End Date / Currently Working
//             Obx(() => CheckboxListTile(
//               value: currentlyWorking.value,
//               onChanged: (value) {
//                 currentlyWorking.value = value ?? false;
//                 if (currentlyWorking.value) {
//                   endDate.value = null;
//                 }
//               },
//               title: const Text('I currently work here'),
//               activeColor: Colors.green,
//             )),
            
//             if (!currentlyWorking.value) ...[
//               const Divider(),
//               Obx(() => ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.calendar_today, color: Colors.green, size: 20),
//                 ),
//                 title: const Text('End Date *'),
//                 subtitle: Text(endDate.value != null 
//                     ? dateFormat.format(endDate.value!) 
//                     : 'Select end date'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: _selectEndDate,
//               )),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== DESCRIPTION CARD ====================
//   Widget _buildDescriptionCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Job Description',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _enhanceDescription,
//                   icon: const Icon(Icons.auto_awesome, color: Colors.purple),
//                   tooltip: 'Enhance with AI',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: descriptionController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Describe your responsibilities and achievements...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== ACHIEVEMENTS CARD ====================
//   Widget _buildAchievementsCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Key Achievements',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _enhanceAchievements,
//                   icon: const Icon(Icons.auto_awesome, color: Colors.purple),
//                   tooltip: 'Generate with AI',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 '💡 Tip: Use bullet points and quantify your achievements (e.g., "Increased sales by 30%")',
//                 style: TextStyle(fontSize: 12, color: Colors.green),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: achievementsController,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: 'One achievement per line\n• Example 1\n• Example 2',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== AI ENHANCE CARD ====================
//   Widget _buildAIEnhanceCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.purple, Colors.purple.withOpacity(0.8)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.auto_awesome, color: Colors.white),
//               SizedBox(width: 8),
//               Text(
//                 'AI Assistant',
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
//             'Get AI-powered suggestions to improve your experience',
//             style: TextStyle(color: Colors.white70),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: _improveWording,
//                   icon: const Icon(Icons.edit, color: Colors.white),
//                   label: const Text(
//                     'Improve Wording',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: _addMetrics,
//                   icon: const Icon(Icons.analytics, color: Colors.white),
//                   label: const Text(
//                     'Add Metrics',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== SAVE BUTTON ====================
//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _saveExperience,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         child: const Text(
//           'Save Experience',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ==================== DATE PICKERS ====================
//   Future<void> _selectStartDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: startDate.value,
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       startDate.value = picked;
//     }
//   }

//   Future<void> _selectEndDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: endDate.value ?? DateTime.now(),
//       firstDate: startDate.value,
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       endDate.value = picked;
//     }
//   }

//   // ==================== VALIDATION ====================
//   bool _validateForm() {
//     if (titleController.text.isEmpty) {
//       _showError('Please enter job title');
//       return false;
//     }
//     if (companyController.text.isEmpty) {
//       _showError('Please enter company name');
//       return false;
//     }
//     if (!currentlyWorking.value && endDate.value == null) {
//       _showError('Please select end date or mark as current');
//       return false;
//     }
//     return true;
//   }

//   void _showError(String message) {
//     Get.snackbar(
//       'Error',
//       message,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }

//   // ==================== AI ENHANCEMENTS ====================
//   void _enhanceDescription() {
//     // TODO: Implement AI description enhancement
//     Get.snackbar(
//       'AI Enhancement',
//       'Enhancing your job description...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }

//   void _enhanceAchievements() {
//     // TODO: Implement AI achievement generation
//     Get.snackbar(
//       'AI Generation',
//       'Generating achievement suggestions...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }

//   void _improveWording() {
//     // TODO: Implement AI wording improvement
//     Get.snackbar(
//       'AI Assistant',
//       'Improving wording...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }

//   void _addMetrics() {
//     // TODO: Implement AI metric suggestions
//     Get.snackbar(
//       'AI Assistant',
//       'Adding quantifiable metrics...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }

//   // ==================== SAVE ====================
//   void _saveExperience() {
//     if (!_validateForm()) return;

//     // Parse achievements
//     List<String> achievements = achievementsController.text
//         .split('\n')
//         .where((line) => line.trim().isNotEmpty)
//         .map((line) => line.replaceAll('• ', '').trim())
//         .toList();

//     // Create experience object
//     final experience = WorkExperience(
//       id: existingExperience?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       title: titleController.text,
//       company: companyController.text,
//       location: locationController.text,
//       startDate: startDate.value,
//       endDate: currentlyWorking.value ? null : endDate.value,
//       current: currentlyWorking.value,
//       description: descriptionController.text,
//       achievements: achievements,
//     );

//     // TODO: Save to backend
//     // if (mode == 'add') {
//     //   controller.addExperience(resume.id, experience);
//     // } else {
//     //   controller.updateExperience(resume.id, experience);
//     // }

//     Get.back();
//     Get.snackbar(
//       'Success',
//       mode == 'add' ? 'Experience added' : 'Experience updated',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }
// }
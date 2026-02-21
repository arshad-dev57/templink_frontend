// // lib/Employee/Resume/screens/education_form_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
// import 'package:templink/Resume_Builder/Models/resume_model.dart';

// import 'package:templink/Utils/colors.dart';
// import 'package:intl/intl.dart';

// class EducationFormScreen extends StatelessWidget {
//   final Map<String, dynamic> args = Get.arguments;
//   final ResumeModel resume = Get.arguments['resume'];
//   final String mode = Get.arguments['mode']; // 'add' or 'edit'
//   final Education? existingEducation = Get.arguments['education'];
  
//   final controller = Get.find<ResumeController>();
//   final dateFormat = DateFormat('yyyy');
  
//   final degreeController = TextEditingController();
//   final fieldController = TextEditingController();
//   final institutionController = TextEditingController();
//   final locationController = TextEditingController();
//   final gradeController = TextEditingController();
//   final descriptionController = TextEditingController();
  
//   final Rx<DateTime> startDate = DateTime.now().obs;
//   final Rx<DateTime?> endDate = Rx<DateTime?>(null);
//   final RxBool currentlyStudying = false.obs;

//   EducationFormScreen() {
//     // Load existing data if in edit mode
//     if (mode == 'edit' && existingEducation != null) {
//       final edu = existingEducation!;
//       degreeController.text = edu.degree;
//       fieldController.text = edu.field;
//       institutionController.text = edu.institution;
//       locationController.text = edu.location;
//       gradeController.text = edu.grade;
//       descriptionController.text = edu.description;
//       startDate.value = edu.startDate;
//       endDate.value = edu.endDate;
//       currentlyStudying.value = edu.current;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(
//           mode == 'add' ? 'Add Education' : 'Edit Education',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveEducation,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildBasicInfoCard(),
//             const SizedBox(height: 16),
//             _buildInstitutionCard(),
//             const SizedBox(height: 16),
//             _buildDatesCard(),
//             const SizedBox(height: 16),
//             _buildDetailsCard(),
//             const SizedBox(height: 16),
//             _buildDescriptionCard(),
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
//               'Degree Information',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Degree
//             TextField(
//               controller: degreeController,
//               decoration: InputDecoration(
//                 labelText: 'Degree *',
//                 hintText: 'e.g., Bachelor of Science, Master of Arts',
//                 prefixIcon: const Icon(Icons.school, color: Colors.orange),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//             const SizedBox(height: 12),
            
//             // Field of Study
//             TextField(
//               controller: fieldController,
//               decoration: InputDecoration(
//                 labelText: 'Field of Study *',
//                 hintText: 'e.g., Computer Science, Business Administration',
//                 prefixIcon: const Icon(Icons.science, color: Colors.orange),
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

//   // ==================== INSTITUTION CARD ====================
//   Widget _buildInstitutionCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Institution',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Institution Name
//             TextField(
//               controller: institutionController,
//               decoration: InputDecoration(
//                 labelText: 'Institution Name *',
//                 hintText: 'e.g., Stanford University, MIT',
//                 prefixIcon: const Icon(Icons.account_balance, color: Colors.orange),
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
//                 hintText: 'e.g., Stanford, CA',
//                 prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
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
//                 color: Colors.orange,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Start Year
//             Obx(() => ListTile(
//               leading: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
//               ),
//               title: const Text('Start Year *'),
//               subtitle: Text(dateFormat.format(startDate.value)),
//               trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//               onTap: _selectStartYear,
//             )),
            
//             const Divider(),
            
//             // Currently Studying
//             Obx(() => CheckboxListTile(
//               value: currentlyStudying.value,
//               onChanged: (value) {
//                 currentlyStudying.value = value ?? false;
//                 if (currentlyStudying.value) {
//                   endDate.value = null;
//                 }
//               },
//               title: const Text('I am currently studying here'),
//               activeColor: Colors.orange,
//             )),
            
//             if (!currentlyStudying.value) ...[
//               const Divider(),
//               Obx(() => ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
//                 ),
//                 title: const Text('Graduation Year *'),
//                 subtitle: Text(endDate.value != null 
//                     ? dateFormat.format(endDate.value!) 
//                     : 'Select graduation year'),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: _selectEndYear,
//               )),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== DETAILS CARD ====================
//   Widget _buildDetailsCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Additional Details',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Grade/GPA
//             TextField(
//               controller: gradeController,
//               decoration: InputDecoration(
//                 labelText: 'Grade / GPA (Optional)',
//                 hintText: 'e.g., 3.8 GPA, First Class Honours',
//                 prefixIcon: const Icon(Icons.grade, color: Colors.orange),
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
//                   'Description & Achievements',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _enhanceWithAI,
//                   icon: const Icon(Icons.auto_awesome, color: Colors.purple),
//                   tooltip: 'Enhance with AI',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 '💡 Tip: Mention relevant coursework, projects, awards, or activities',
//                 style: TextStyle(fontSize: 12, color: Colors.orange),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: descriptionController,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: 'Describe your academic achievements, activities, etc...',
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

//   // ==================== SAVE BUTTON ====================
//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _saveEducation,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.orange,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         child: const Text(
//           'Save Education',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ==================== DATE PICKERS ====================
//   Future<void> _selectStartYear() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: startDate.value,
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//       initialDatePickerMode: DatePickerMode.year,
//     );
//     if (picked != null) {
//       startDate.value = picked;
//     }
//   }

//   Future<void> _selectEndYear() async {
//     final DateTime? picked = await showDatePicker(
//       context: Get.context!,
//       initialDate: endDate.value ?? DateTime.now(),
//       firstDate: startDate.value,
//       lastDate: DateTime.now().add(const Duration(days: 3650)),
//       initialDatePickerMode: DatePickerMode.year,
//     );
//     if (picked != null) {
//       endDate.value = picked;
//     }
//   }

//   // ==================== VALIDATION ====================
//   bool _validateForm() {
//     if (degreeController.text.isEmpty) {
//       _showError('Please enter degree name');
//       return false;
//     }
//     if (fieldController.text.isEmpty) {
//       _showError('Please enter field of study');
//       return false;
//     }
//     if (institutionController.text.isEmpty) {
//       _showError('Please enter institution name');
//       return false;
//     }
//     if (!currentlyStudying.value && endDate.value == null) {
//       _showError('Please select graduation year or mark as current');
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

//   // ==================== AI ENHANCEMENT ====================
//   void _enhanceWithAI() {
//     // TODO: Implement AI enhancement for education description
//     Get.snackbar(
//       'AI Enhancement',
//       'Enhancing your academic achievements...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }

//   // ==================== SAVE ====================
//   void _saveEducation() {
//     if (!_validateForm()) return;

//     // Create education object
//     final education = Education(
//       id: existingEducation?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       degree: degreeController.text,
//       field: fieldController.text,
//       institution: institutionController.text,
//       location: locationController.text,
//       startDate: startDate.value,
//       endDate: currentlyStudying.value ? null : endDate.value,
//       current: currentlyStudying.value,
//       grade: gradeController.text,
//       description: descriptionController.text,
//     );

//     // TODO: Save to backend
//     // if (mode == 'add') {
//     //   controller.addEducation(resume.id, education);
//     // } else {
//     //   controller.updateEducation(resume.id, education);
//     // }

//     Get.back();
//     Get.snackbar(
//       'Success',
//       mode == 'add' ? 'Education added' : 'Education updated',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }
// }
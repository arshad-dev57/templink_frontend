// // lib/Employee/Resume/screens/personal_info_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:templink/Resume_Builder/Controller/Resume_Controller.dart';
// import 'package:templink/Resume_Builder/Models/resume_model.dart';
// import 'package:templink/Utils/colors.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class PersonalInfoScreen extends StatelessWidget {
//   final ResumeModel resume = Get.arguments;
//   final controller = Get.find<ResumeController>();
  
//   final firstNameController = TextEditingController();
//   final lastNameController = TextEditingController();
//   final titleController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final addressController = TextEditingController();
//   final cityController = TextEditingController();
//   final countryController = TextEditingController();
//   final linkedinController = TextEditingController();
//   final githubController = TextEditingController();
//   final portfolioController = TextEditingController();
//   final summaryController = TextEditingController();
  
//   final Rx<File?> selectedImage = Rx<File?>(null);

//   PersonalInfoScreen() {
//     // Load existing data if available
//     if (resume.personalInfo != null) {
//       final info = resume.personalInfo!;
//       firstNameController.text = info.firstName;
//       lastNameController.text = info.lastName;
//       titleController.text = info.title;
//       emailController.text = info.email;
//       phoneController.text = info.phone;
//       addressController.text = info.address;
//       cityController.text = info.city;
//       countryController.text = info.country;
//       linkedinController.text = info.linkedin;
//       githubController.text = info.github;
//       portfolioController.text = info.portfolio;
//       summaryController.text = info.summary;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Personal Information',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveInfo,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildProfileImage(),
//             const SizedBox(height: 20),
//             _buildNameSection(),
//             const SizedBox(height: 16),
//             _buildProfessionalSection(),
//             const SizedBox(height: 16),
//             _buildContactSection(),
//             const SizedBox(height: 16),
//             _buildAddressSection(),
//             const SizedBox(height: 16),
//             _buildSocialSection(),
//             const SizedBox(height: 16),
//             _buildSummarySection(),
//             const SizedBox(height: 30),
//             _buildSaveButton(),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== PROFILE IMAGE ====================
//   Widget _buildProfileImage() {
//     return Center(
//       child: Stack(
//         children: [
//           Obx(() => CircleAvatar(
//             radius: 60,
//             backgroundColor: Colors.blue.withOpacity(0.1),
//             backgroundImage: selectedImage.value != null
//                 ? FileImage(selectedImage.value!)
//                 : (resume.personalInfo?.photo != null
//                     ? NetworkImage(resume.personalInfo!.photo!)
//                     : null) as ImageProvider?,
//             child: selectedImage.value == null && resume.personalInfo?.photo == null
//                 ? Text(
//                     _getInitials(),
//                     style: const TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   )
//                 : null,
//           )),
//           Positioned(
//             bottom: 0,
//             right: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white, width: 3),
//               ),
//               child: IconButton(
//                 onPressed: _pickImage,
//                 icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
//                 constraints: const BoxConstraints.tightFor(width: 40, height: 40),
//                 padding: EdgeInsets.zero,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getInitials() {
//     if (firstNameController.text.isNotEmpty && lastNameController.text.isNotEmpty) {
//       return '${firstNameController.text[0]}${lastNameController.text[0]}'.toUpperCase();
//     } else if (firstNameController.text.isNotEmpty) {
//       return firstNameController.text[0].toUpperCase();
//     }
//     return '?';
//   }

//   // ==================== NAME SECTION ====================
//   Widget _buildNameSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Full Name',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: firstNameController,
//                     decoration: InputDecoration(
//                       labelText: 'First Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     controller: lastNameController,
//                     decoration: InputDecoration(
//                       labelText: 'Last Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== PROFESSIONAL SECTION ====================
//   Widget _buildProfessionalSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Professional Title',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(
//                 hintText: 'e.g., Senior Flutter Developer',
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

//   // ==================== CONTACT SECTION ====================
//   Widget _buildContactSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Contact Information',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: InputDecoration(
//                 labelText: 'Email Address',
//                 prefixIcon: const Icon(Icons.email, size: 20),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: phoneController,
//               keyboardType: TextInputType.phone,
//               decoration: InputDecoration(
//                 labelText: 'Phone Number',
//                 prefixIcon: const Icon(Icons.phone, size: 20),
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

//   // ==================== ADDRESS SECTION ====================
//   Widget _buildAddressSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Address',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(
//                 labelText: 'Street Address',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: cityController,
//                     decoration: InputDecoration(
//                       labelText: 'City',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     controller: countryController,
//                     decoration: InputDecoration(
//                       labelText: 'Country',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==================== SOCIAL SECTION ====================
//   Widget _buildSocialSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Social & Portfolio',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: linkedinController,
//               decoration: InputDecoration(
//                 labelText: 'LinkedIn URL',
//                 prefixIcon: const Icon(Icons.link, size: 20),
//                 hintText: 'https://linkedin.com/in/username',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: githubController,
//               decoration: InputDecoration(
//                 labelText: 'GitHub URL',
//                 prefixIcon: const Icon(Icons.code, size: 20),
//                 hintText: 'https://github.com/username',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: portfolioController,
//               decoration: InputDecoration(
//                 labelText: 'Portfolio Website',
//                 prefixIcon: const Icon(Icons.web, size: 20),
//                 hintText: 'https://yourportfolio.com',
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

//   // ==================== SUMMARY SECTION ====================
//   Widget _buildSummarySection() {
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
//                   'Professional Summary',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.blue,
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
//             TextField(
//               controller: summaryController,
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: 'Write a brief summary of your professional background...',
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
//         onPressed: _saveInfo,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         child: const Text(
//           'Save Information',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ==================== HELPER METHODS ====================
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(source: ImageSource.gallery);
    
//     if (image != null) {
//       selectedImage.value = File(image.path);
//     }
//   }

//   void _enhanceWithAI() {
//     // TODO: Implement AI enhancement for summary
//     Get.snackbar(
//       'AI Enhancement',
//       'Enhancing your summary...',
//       backgroundColor: Colors.purple,
//       colorText: Colors.white,
//     );
//   }

//   void _saveInfo() {
//     // Validate required fields
//     if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Please enter your full name',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // Create personal info object
//     final personalInfo = PersonalInfo(
//       firstName: firstNameController.text,
//       lastName: lastNameController.text,
//       title: titleController.text,
//       email: emailController.text,
//       phone: phoneController.text,
//       address: addressController.text,
//       city: cityController.text,
//       country: countryController.text,
//       linkedin: linkedinController.text,
//       github: githubController.text,
//       portfolio: portfolioController.text,
//       summary: summaryController.text,
//       photo: selectedImage.value?.path, // Will be uploaded separately
//     );

//     // TODO: Save to backend
//     // controller.updatePersonalInfo(resume.id, personalInfo);

//     Get.back();
//     Get.snackbar(
//       'Success',
//       'Personal information saved',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }
// }
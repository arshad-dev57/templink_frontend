// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:templink/Controllers/job_post_controller.dart';
// import 'package:templink/Utils/colors.dart';

// class JobPostScreen extends StatelessWidget {
//   JobPostScreen({Key? key}) : super(key: key);

//   final JobPostController controller = Get.put(JobPostController());
  
//   // Text editing controllers
//   final TextEditingController _jobTitleController = TextEditingController();
//   final TextEditingController _companyController = TextEditingController();
//   final TextEditingController _jobLocationController = TextEditingController();
//   final TextEditingController _aboutJobController = TextEditingController();
//   final TextEditingController _keyRequirementsController = TextEditingController();
//   final TextEditingController _qualificationsController = TextEditingController();
  
//   // Salary controllers
//   final TextEditingController _minSalaryController = TextEditingController();
//   final TextEditingController _maxSalaryController = TextEditingController();
//   final TextEditingController _salaryTypeController = TextEditingController();
//   final TextEditingController _currencyController = TextEditingController();
  
//   final List<String> _workplaceOptions = ['Onsite', 'Hybrid', 'Remote'];
//   final List<String> _jobTypeOptions = [
//     'Full Time', 
//     'Part Time', 
//     'Contract', 
//     'Temporary', 
//     'Internship', 
//     'Other'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // Sync UI controllers with controller Rx variables
//     _syncControllersWithRx();
    
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Post a New Job",
//           style: TextStyle(color: Colors.black, fontSize: 16),
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Job Title
//                 _buildLabel("JOB TITLE"),
//                 const SizedBox(height: 8),
//                 _buildTextField(
//                   controller: _jobTitleController,
//                   hintText: "Enter job title",
//                   icon: Icons.work_outline,
//                   onChanged: (value) => controller.jobTitle.value = value,
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // // Company
//                 // _buildLabel("COMPANY"),
//                 // const SizedBox(height: 8),
//                 // _buildTextField(
//                 //   controller: _companyController,
//                 //   hintText: "Enter company name",
//                 //   icon: Icons.business_outlined,
//                 //   onChanged: (value) => controller.company.value = value,
//                 // ),
                
//                 // const SizedBox(height: 20),
                
//                 // Workplace Type
//                 _buildLabel("WORKPLACE TYPE"),
//                 const SizedBox(height: 8),
//                 Obx(
//                   () => _buildDropdown(
//                     value: controller.selectedWorkplace.value,
//                     items: _workplaceOptions,
//                     onChanged: (value) {
//                       controller.selectedWorkplace.value = value ?? 'Remote';
//                     },
//                     icon: Icons.location_city_outlined,
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Job Location
//                 _buildLabel("JOB LOCATION"),
//                 const SizedBox(height: 8),
//                 _buildTextField(
//                   controller: _jobLocationController,
//                   hintText: "Enter job location (e.g., San Francisco, CA)",
//                   icon: Icons.location_on_outlined,
//                   onChanged: (value) => controller.jobLocation.value = value,
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Job Type
//                 _buildLabel("JOB TYPE"),
//                 const SizedBox(height: 8),
//                 Obx(
//                   () => _buildDropdown(
//                     value: controller.selectedJobType.value,
//                     items: _jobTypeOptions,
//                     onChanged: (value) {
//                       controller.selectedJobType.value = value ?? 'Full Time';
//                     },
//                     icon: Icons.schedule_outlined,
//                   ),
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // About the Job
//                 _buildLabel("ABOUT THE JOB"),
//                 const SizedBox(height: 8),
//                 _buildRichTextField(
//                   controller: _aboutJobController,
//                   hintText: "Describe the overall purpose, objectives, and impact of this role...",
//                   icon: Icons.description_outlined,
//                   lines: 6,
//                   onChanged: (value) => controller.aboutJob.value = value,
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Key Requirements
//                 _buildLabel("KEY REQUIREMENTS"),
//                 const SizedBox(height: 8),
//                 _buildRichTextField(
//                   controller: _keyRequirementsController,
//                   hintText: "List the must-have skills, experience, and requirements (one per line)...",
//                   icon: Icons.checklist_outlined,
//                   lines: 5,
//                   onChanged: (value) => controller.keyRequirements.value = value,
//                 ),
                
//                 const SizedBox(height: 20),
                
//                 // Qualifications
//                 _buildLabel("QUALIFICATIONS"),
//                 const SizedBox(height: 8),
//                 _buildRichTextField(
//                   controller: _qualificationsController,
//                   hintText: "List educational qualifications, certifications, and preferred skills...",
//                   icon: Icons.school_outlined,
//                   lines: 5,
//                   onChanged: (value) => controller.qualifications.value = value,
//                 ),
                
//                 const SizedBox(height: 30),
                
//                 // Salary Information
//                 _buildLabel("SALARY INFORMATION (OPTIONAL)"),
//                 const SizedBox(height: 8),
//                 _buildSalarySection(),
                
//                 const SizedBox(height: 30),
                
//                 // Media Gallery
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildLabel("MEDIA GALLERY"),
//                     TextButton(
//                       onPressed: controller.pickImage,
//                       child: const Text("Add More"),
//                     )
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 _mediaGallery(),
                
//                 const SizedBox(height: 100),
//               ],
//             ),
//           ),
          
//           // Bottom sheet button area
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: _buildBottomSheet(),
//           ),
//         ],
//       ),
//     );
//   }

//   void _syncControllersWithRx() {
//     // Initialize controllers with existing Rx values if any
//     _jobTitleController.text = controller.jobTitle.value;
//     _companyController.text = controller.company.value;
//     _jobLocationController.text = controller.jobLocation.value;
//     _aboutJobController.text = controller.aboutJob.value;
//     _keyRequirementsController.text = controller.keyRequirements.value;
//     _qualificationsController.text = controller.qualifications.value;
//   }

//   Widget _buildSalarySection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSalaryField(
//                   controller: _minSalaryController,
//                   hintText: "Min Salary",
//                   icon: Icons.attach_money,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildSalaryField(
//                   controller: _maxSalaryController,
//                   hintText: "Max Salary",
//                   icon: Icons.attach_money,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildSalaryField(
//                   controller: _salaryTypeController,
//                   hintText: "Salary Type (e.g., Monthly, Yearly)",
//                   icon: Icons.monetization_on_outlined,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildSalaryField(
//                   controller: _currencyController,
//                   hintText: "Currency (e.g., USD)",
//                   icon: Icons.currency_exchange_outlined,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.info_outline,
//                   color: Colors.blue.shade600,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     "Salary information increases job attractiveness by 40%",
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.blue.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSalaryField({
//     required TextEditingController controller,
//     required String hintText,
//     required IconData icon,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: TextField(
//         controller: controller,
//         style: const TextStyle(fontSize: 13),
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 16),
//         ),
//       ),
//     );
//   }

//   Widget _buildRichTextField({
//     required TextEditingController controller,
//     required String hintText,
//     required IconData icon,
//     required int lines,
//     required ValueChanged<String> onChanged,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(icon, color: Colors.grey.shade500, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     maxLines: lines,
//                     style: const TextStyle(fontSize: 14, height: 1.5),
//                     onChanged: onChanged,
//                     decoration: InputDecoration(
//                       hintText: hintText,
//                       hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             height: 1,
//             color: Colors.grey.shade200,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 _formatButton(Icons.format_bold, "Bold", () {
//                   controller.text = "**${controller.text}**";
//                 }),
//                 const SizedBox(width: 8),
//                 _formatButton(Icons.format_italic, "Italic", () {
//                   controller.text = "*${controller.text}*";
//                 }),
//                 const SizedBox(width: 8),
//                 _formatButton(Icons.format_list_bulleted, "Bullets", () {
//                   controller.text = "• ${controller.text.replaceAll('\n', '\n• ')}";
//                 }),
//                 const SizedBox(width: 8),
//                 _formatButton(Icons.format_list_numbered, "Numbers", () {
//                   final lines = controller.text.split('\n');
//                   for (int i = 0; i < lines.length; i++) {
//                     lines[i] = "${i + 1}. ${lines[i]}";
//                   }
//                   controller.text = lines.join('\n');
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _formatButton(IconData icon, String tooltip, VoidCallback onTap) {
//     return Tooltip(
//       message: tooltip,
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Icon(icon, size: 18, color: Colors.grey.shade600),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomSheet() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           top: BorderSide(color: Colors.grey.shade300, width: 1),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Obx(() => Row(
//         children: [
//           // Preview button
//           Expanded(
//             child: OutlinedButton(
//               onPressed: controller.isLoading.value ? null : () {
//                 _showPreview();
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: primary,
//                 side: BorderSide(color: primary),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 "Preview",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
          
//           const SizedBox(width: 16),
          
//           // Publish button
//           Expanded(
//             child: ElevatedButton(
//               onPressed: controller.isLoading.value ? null : () {
//                 _showPublishConfirmation();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primary,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: controller.isLoading.value
//                   ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Text(
//                       "Publish Job",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       )),
//     );
//   }

//   void _showPublishConfirmation() {
//     // Update controller values with latest text
//     _updateControllerValues();
    
//     // Validate required fields
//     if (_jobTitleController.text.isEmpty || 
//         _aboutJobController.text.isEmpty) {
//       _showValidationDialog();
//       return;
//     }
    
//     // Show confirmation dialog
//     showModalBottomSheet(
//       context: Get.context!,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return _buildPublishConfirmationSheet();
//       },
//     );
//   }

//   Widget _buildPublishConfirmationSheet() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Icon
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.check_circle_outline,
//               size: 40,
//               color: primary,
//             ),
//           ),
          
//           const SizedBox(height: 20),
          
//           // Title
//           const Text(
//             "Ready to Publish?",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
          
//           const SizedBox(height: 12),
          
//           // Description
//           Text(
//             "Your job post will be visible to all candidates. "
//             "You can edit or unpublish it anytime.",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//               height: 1.5,
//             ),
//           ),
          
//           const SizedBox(height: 30),
          
//           // Job Summary
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.work_outline,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         _jobTitleController.text.isNotEmpty 
//                             ? _jobTitleController.text 
//                             : "Job Title",
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.business_outlined,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       _companyController.text.isNotEmpty 
//                           ? _companyController.text 
//                           : "Company",
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     const Icon(
//                       Icons.location_on_outlined,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       _jobLocationController.text.isNotEmpty 
//                           ? _jobLocationController.text 
//                           : "Location",
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
                
//                 const SizedBox(height: 8),
                
//                 Obx(() => Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _buildSummaryChip(
//                       icon: Icons.location_city_outlined,
//                       text: controller.selectedWorkplace.value,
//                     ),
//                     _buildSummaryChip(
//                       icon: Icons.schedule_outlined,
//                       text: controller.selectedJobType.value,
//                     ),
//                   ],
//                 )),
                
//                 if (_aboutJobController.text.isNotEmpty)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 12),
//                       const Divider(),
//                       const SizedBox(height: 12),
//                       const Text(
//                         "About the Job:",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _aboutJobController.text.length > 100
//                             ? "${_aboutJobController.text.substring(0, 100)}..."
//                             : _aboutJobController.text,
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 30),
          
//           // Action buttons
//           Row(
//             children: [
//               // Cancel button
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.pop(Get.context!);
//                   },
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.grey.shade700,
//                     side: BorderSide(color: Colors.grey.shade300),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text("Edit Details"),
//                 ),
//               ),
              
//               const SizedBox(width: 16),
              
//               // Publish button
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(Get.context!);
//                     _postJob();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primary,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Publish Now",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryChip({required IconData icon, required String text}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 12,
//             color: Colors.grey.shade600,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showValidationDialog() {
//     Get.snackbar(
//       'Missing Information',
//       'Please fill in Job Title, Company, and About the Job fields',
//       backgroundColor: Colors.orange,
//       colorText: Colors.white,
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 3),
//     );
//   }

//   void _showPreview() {
//     _updateControllerValues();
    
//     showModalBottomSheet(
//       context: Get.context!,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return _buildPreviewSheet(context);
//       },
//     );
//   }

//   Widget _buildPreviewSheet(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
//       padding: const EdgeInsets.all(24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Job Preview",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
          
//           const SizedBox(height: 20),
          
//           // Preview content
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Job title
//                   Text(
//                     _jobTitleController.text.isNotEmpty 
//                         ? _jobTitleController.text 
//                         : "[Job Title]",
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
                  
//                   const SizedBox(height: 8),
                  
//                   // Company and location
//                   Row(
//                     children: [
//                       const Icon(Icons.business_outlined, size: 16, color: Colors.grey),
//                       const SizedBox(width: 6),
//                       Text(
//                         _companyController.text.isNotEmpty 
//                             ? _companyController.text 
//                             : "[Company]",
//                         style: const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       const SizedBox(width: 16),
//                       const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
//                       const SizedBox(width: 6),
//                       Text(
//                         _jobLocationController.text.isNotEmpty 
//                             ? _jobLocationController.text 
//                             : "[Location]",
//                         style: const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Job details chips
//                   Obx(() => Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       _buildPreviewChip(Icons.location_city_outlined, controller.selectedWorkplace.value),
//                       _buildPreviewChip(Icons.schedule_outlined, controller.selectedJobType.value),
//                     ],
//                   )),
                  
//                   const SizedBox(height: 30),
                  
//                   // About the Job
//                   const Text(
//                     "About the Job",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
                  
//                   const SizedBox(height: 12),
                  
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       _aboutJobController.text.isNotEmpty 
//                           ? _aboutJobController.text 
//                           : "[About the job will appear here]",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                         height: 1.6,
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Key Requirements
//                   const Text(
//                     "Key Requirements",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
                  
//                   const SizedBox(height: 12),
                  
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       _keyRequirementsController.text.isNotEmpty 
//                           ? _keyRequirementsController.text 
//                           : "[Key requirements will appear here]",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                         height: 1.6,
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 20),
                  
//                   // Qualifications
//                   const Text(
//                     "Qualifications",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
                  
//                   const SizedBox(height: 12),
                  
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       _qualificationsController.text.isNotEmpty 
//                           ? _qualificationsController.text 
//                           : "[Qualifications will appear here]",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade700,
//                         height: 1.6,
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 30),
                  
//                   // Salary Information
//                   if (_minSalaryController.text.isNotEmpty || _maxSalaryController.text.isNotEmpty)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Salary",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade50,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             "${_currencyController.text.isNotEmpty ? _currencyController.text : 'USD'} "
//                             "${_minSalaryController.text} - ${_maxSalaryController.text} "
//                             "${_salaryTypeController.text.isNotEmpty ? '/ ${_salaryTypeController.text}' : ''}",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey.shade700,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPreviewChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: primary),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: primary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _updateControllerValues() {
//     // Update controller Rx values with latest text
//     controller.jobTitle.value = _jobTitleController.text;
//     controller.company.value = _companyController.text;
//     controller.jobLocation.value = _jobLocationController.text;
//     controller.aboutJob.value = _aboutJobController.text;
//     controller.keyRequirements.value = _keyRequirementsController.text;
//     controller.qualifications.value = _qualificationsController.text;
//   }

//   void _postJob() {
//     // Update controller values with latest text
//     _updateControllerValues();
    
//     // Add salary information to controller
//     controller.minSalary.value = _minSalaryController.text;
//     controller.maxSalary.value = _maxSalaryController.text;
//     controller.salaryType.value = _salaryTypeController.text;
//     controller.currency.value = _currencyController.text;
    
//     // Call controller to post job
//     controller.postJob().then((_) {
//       // Success and error handling is done in the controller
//       if (!controller.isLoading.value && controller.errorMessage.value.isEmpty) {
//         _clearForm();
//         Future.delayed(const Duration(seconds: 1), () {
//           Get.back();
//         });
//       }
//     });
//   }

//   void _clearForm() {
//     _jobTitleController.clear();
//     _companyController.clear();
//     _jobLocationController.clear();
//     _aboutJobController.clear();
//     _keyRequirementsController.clear();
//     _qualificationsController.clear();
//     _minSalaryController.clear();
//     _maxSalaryController.clear();
//     _salaryTypeController.clear();
//     _currencyController.clear();
//     controller.images.clear();
//   }

//   // Helper methods
//   Widget _buildLabel(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         color: Colors.black87,
//         letterSpacing: 0.5,
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hintText,
//     required IconData icon,
//     ValueChanged<String>? onChanged,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: TextField(
//         controller: controller,
//         style: const TextStyle(fontSize: 14),
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey.shade500),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown({
//     required String? value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//     required IconData icon,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: value,
//             icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
//             iconSize: 24,
//             isExpanded: true,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//             onChanged: onChanged,
//             items: items.map((String item) {
//               return DropdownMenuItem<String>(
//                 value: item,
//                 child: Row(
//                   children: [
//                     Icon(icon, color: Colors.grey.shade500, size: 20),
//                     const SizedBox(width: 12),
//                     Text(item),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _mediaGallery() {
//     return Obx(
//       () => Wrap(
//         spacing: 12,
//         runSpacing: 12,
//         children: [
//           _uploadBox(),
//           ...List.generate(
//             controller.images.length,
//             (index) => _pickedImage(controller.images[index], index),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _uploadBox() {
//     return GestureDetector(
//       onTap: controller.pickImage,
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           border: Border.all(color: Colors.grey.shade300, width: 1.5),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.camera_alt_outlined, color: Colors.grey.shade500),
//             const SizedBox(height: 6),
//             Text(
//               "Upload",
//               style: TextStyle(
//                 fontSize: 11,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _pickedImage(File file, int index) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.file(
//             file, 
//             width: 80, 
//             height: 80, 
//             fit: BoxFit.cover
//           ),
//         ),
//         Positioned(
//           top: 4,
//           right: 4,
//           child: GestureDetector(
//             onTap: () => controller.removeImage(index),
//             child: CircleAvatar(
//               radius: 12,
//               backgroundColor: Colors.black.withOpacity(0.6),
//               child: const Icon(
//                 Icons.close, 
//                 size: 14, 
//                 color: Colors.white
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
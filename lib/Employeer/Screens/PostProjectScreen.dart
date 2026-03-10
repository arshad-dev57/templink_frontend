import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/project_controller.dart';
import 'package:templink/Employeer/model/project_model.dart';
import 'package:templink/Utils/colors.dart';

class PostProjectScreen extends StatefulWidget {
  const PostProjectScreen({super.key});

  @override
  State<PostProjectScreen> createState() => _PostProjectScreenState();
}

class _PostProjectScreenState extends State<PostProjectScreen> {
  final ProjectController controller = Get.put(ProjectController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post a Project',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'STEP ${controller.currentStep.value + 1} OF 3',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )),
      ),
      body: Obx(() => Column(
        children: [
          LinearProgressIndicator(
            value: (controller.currentStep.value + 1) / 3,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(primary),
            minHeight: 4,
          ),
          Expanded(
            child: IndexedStack(
              index: controller.currentStep.value,
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (controller.currentStep.value > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (controller.currentStep.value > 0) const SizedBox(width: 12),
              Expanded(
                flex: controller.currentStep.value == 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (controller.currentStep.value == 2) {
                            _handlePublish();
                          } else {
                            _handleNext();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getNextButtonColor(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.currentStep.value == 2
                                  ? 'Publish Project'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              controller.currentStep.value == 2
                                  ? Icons.rocket_launch
                                  : Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Color _getNextButtonColor() {
    if (controller.currentStep.value == 1) {
      // Step 2 mein check karo ke milestones total max budget ke barabar hai ya nahi
      final maxBudget = double.tryParse(controller.maxBudgetController.text) ?? 0;
      final totalMilestones = controller.milestonesList.fold<double>(
        0, (sum, m) => sum + (m['amount'] as double)
      );
      
      const double tolerance = 0.5;
      
      // Agar milestones hain aur total max budget ke barabar nahi hai to button grey karo
      if (controller.milestonesList.isNotEmpty && 
          (totalMilestones - maxBudget).abs() > tolerance) {
        return Colors.grey;
      }
    }
    return primary;
  }

  void _handleNext() {
    if (controller.currentStep.value == 0) {
      if (controller.validateStep1()) {
        controller.nextStep();
      }
    } else if (controller.currentStep.value == 1) {
      // Step 2 ke liye extra validation
      if (controller.validateStep2()) {
        controller.nextStep();
      } else {
        // Agar validation fail ho to user ko dikhao
        _showBudgetMismatchDialog();
      }
    }
  }

  void _showBudgetMismatchDialog() {
    final maxBudget = double.tryParse(controller.maxBudgetController.text) ?? 0;
    final totalMilestones = controller.milestonesList.fold<double>(
      0, (sum, m) => sum + (m['amount'] as double)
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '⚠️ Budget Mismatch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Milestones total must equal max budget:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildBudgetRow('Max Budget:', '\$${maxBudget.toStringAsFixed(0)}', Colors.blue),
                  const SizedBox(height: 8),
                  _buildBudgetRow('Milestones Total:', '\$${totalMilestones.toStringAsFixed(0)}', 
                    totalMilestones > maxBudget ? Colors.red : Colors.orange),
                  const Divider(height: 16),
                  _buildBudgetRow(
                    'Difference:', 
                    '\$${(maxBudget - totalMilestones).abs().toStringAsFixed(0)}',
                    totalMilestones > maxBudget ? Colors.red : Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              totalMilestones > maxBudget
                  ? '❌ Reduce milestone amounts by \$${(totalMilestones - maxBudget).toStringAsFixed(0)}'
                  : '⚠️ Add \$${(maxBudget - totalMilestones).toStringAsFixed(0)} more in milestones',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: totalMilestones > maxBudget ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _handlePublish() {
    if (controller.validateStep3()) {
      _showPublishConfirmationDialog();
    }
  }

  Widget _buildStep1() {
    return Obx(() => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Basics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s start with the fundamental details of your project.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Project Title
            const Text(
              'Project Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Enterprise SaaS UI/UX Overhaul',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clear titles attract better candidates.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Project Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                hint: const Text('Select a category'),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  'UI/UX Design',
                  'Web Development',
                  'Mobile Development',
                  'Graphic Design',
                  'Marketing',
                ].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) => controller.selectedCategory.value = value,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Project Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.format_bold),
                          onPressed: () {},
                          iconSize: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_italic),
                          onPressed: () {},
                          iconSize: 20,
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_list_bulleted),
                          onPressed: () {},
                          iconSize: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () {},
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: controller.descriptionController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText:
                          'Briefly describe the goals, key challenges,\nand who you\'re looking for...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min. 100 characters recommended',
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.descriptionController.text.length >= 100
                        ? Colors.green
                        : Colors.grey[500],
                  ),
                ),
                Text(
                  '${controller.descriptionController.text.length}/5000',
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.descriptionController.text.length >= 100
                        ? Colors.green
                        : Colors.grey[500],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }

  Widget _buildStep2() {
    return Obx(() => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Define the scope, timeline, and budget for your project.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DURATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: controller.selectedDuration.value,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: [
                            'Less than 1 month',
                            '1-3 months',
                            '3-6 months',
                            '6+ months',
                          ].map((duration) {
                            return DropdownMenuItem<String>(
                              value: duration,
                              child: Text(
                                duration,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              controller.selectedDuration.value = value!,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPERIENCE LEVEL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: controller.selectedExperience.value,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: const [
                            DropdownMenuItem(
                              value: 'Entry Level',
                              child: Text(
                                'Entry Level',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Intermediate',
                              child: Text(
                                'Intermediate',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Expert',
                              child: Text(
                                'Expert',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              controller.selectedExperience.value = value!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Budget Range
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Budget Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            _buildBudgetTypeButton('FIXED'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.minBudgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            hintText: 'Min',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          onChanged: (value) {
                            // Trigger rebuild to update button color
                            controller.update();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller.maxBudgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            hintText: 'Max',
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          onChanged: (value) {
                            // Trigger rebuild to update button color
                            controller.update();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        'Average market rate for Expert level: \$850 - \$2000',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // MILESTONES SECTION
            _buildMilestonesSection(),
            
            const SizedBox(height: 24),

            // Key Deliverables
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Key Deliverables',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddDeliverableDialog,
                  icon: const Icon(Icons.add_circle, size: 20),
                  label: const Text('Add Item'),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controller.deliverables.asMap().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                      onPressed: () => controller.removeDeliverable(entry.key),
                      iconSize: 20,
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _showAddDeliverableDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                'Add another deliverable...',
                style: TextStyle(color: Colors.grey[600]),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // Milestones Section with Budget Validation
  // Milestones Section with Budget Validation
   // Milestones Section with Budget Validation - WITHOUT Obx
  Widget _buildMilestonesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Project Milestones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Simple condition, no Obx
              !controller.showMilestoneForm.value
                  ? TextButton.icon(
                      onPressed: () {
                        controller.showMilestoneForm.value = true;
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_circle, size: 20),
                      label: const Text('Add Milestone'),
                      style: TextButton.styleFrom(
                        foregroundColor: primary,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Break down your project into milestones (Total must equal max budget)',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Budget Range Display
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Max Budget: \$${controller.maxBudgetController.text}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Milestones List
          if (controller.milestonesList.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No milestones added yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add milestones to break down payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (controller.milestonesList.isNotEmpty)
            ...List.generate(controller.milestonesList.length, (index) {
              final milestone = controller.milestonesList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone['title'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            milestone['description'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.attach_money,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      '\$${(milestone['amount'] as double).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (milestone['dueDate'] != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 12,
                                        color: Colors.blue[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(milestone['dueDate']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        controller.milestonesList.removeAt(index);
                        setState(() {});
                      },
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),

          // Milestone Form
          if (controller.showMilestoneForm.value)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Milestone',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.milestoneTitleController,
                    decoration: InputDecoration(
                      labelText: 'Milestone Title',
                      hintText: 'e.g., Design Phase, Development, Testing',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.milestoneDescController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe what needs to be delivered',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.milestoneAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            prefixText: '\$ ',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              controller.selectedMilestoneDueDate.value = date;
                              setState(() {});
                            }
                          },
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.selectedMilestoneDueDate.value == null
                                        ? 'Due Date (Optional)'
                                        : _formatDate(controller.selectedMilestoneDueDate.value!),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: controller.selectedMilestoneDueDate.value == null
                                          ? Colors.grey[500]
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.milestoneTitleController.clear();
                            controller.milestoneDescController.clear();
                            controller.milestoneAmountController.clear();
                            controller.selectedMilestoneDueDate.value = null;
                            controller.showMilestoneForm.value = false;
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addMilestone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Add Milestone'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Total milestones summary
          if (controller.milestonesList.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Milestones Amount:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${_getTotalMilestones().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Budget validation status
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBudgetStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getBudgetStatusColor().withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getBudgetStatusIcon(),
                      color: _getBudgetStatusColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getBudgetStatusMessage(),
                        style: TextStyle(
                          fontSize: 13,
                          color: _getBudgetStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Warning if not equal
            if (_isBudgetMismatch())
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ You cannot proceed to next step until total equals max budget',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // Helper methods for budget status (no Obx needed)
  double _getTotalMilestones() {
    return controller.milestonesList.fold<double>(
      0, (sum, m) => sum + (m['amount'] as double)
    );
  }

  double _getMaxBudget() {
    return double.tryParse(controller.maxBudgetController.text) ?? 0;
  }

  bool _isBudgetMismatch() {
    final maxBudget = _getMaxBudget();
    if (maxBudget <= 0) return false;
    final total = _getTotalMilestones();
    const double tolerance = 0.5;
    return (total - maxBudget).abs() > tolerance;
  }

  Color _getBudgetStatusColor() {
    final maxBudget = _getMaxBudget();
    final total = _getTotalMilestones();
    const double tolerance = 0.5;
    
    if (maxBudget <= 0) return Colors.grey;
    if ((total - maxBudget).abs() <= tolerance) return Colors.green;
    if (total < maxBudget) return Colors.orange;
    return Colors.red;
  }

  IconData _getBudgetStatusIcon() {
    final maxBudget = _getMaxBudget();
    final total = _getTotalMilestones();
    const double tolerance = 0.5;
    
    if (maxBudget <= 0) return Icons.info;
    if ((total - maxBudget).abs() <= tolerance) return Icons.check_circle;
    if (total < maxBudget) return Icons.warning_amber;
    return Icons.error;
  }

  String _getBudgetStatusMessage() {
    final maxBudget = _getMaxBudget();
    final total = _getTotalMilestones();
    const double tolerance = 0.5;
    
    if (maxBudget <= 0) return 'Total: \$${total.toStringAsFixed(0)}';
    if ((total - maxBudget).abs() <= tolerance) return '✅ Perfect! Total matches max budget';
    if (total < maxBudget) {
      return '⚠️ Total (\$${total.toStringAsFixed(0)}) is \$${(maxBudget - total).toStringAsFixed(0)} less than max budget';
    }
    return '❌ Total (\$${total.toStringAsFixed(0)}) exceeds max budget by \$${(total - maxBudget).toStringAsFixed(0)}';
  }
  Widget _buildBudgetTypeButton(String type) {
    return Obx(() => GestureDetector(
      onTap: () => controller.budgetType.value = type,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: controller.budgetType.value == type ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: controller.budgetType.value == type
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Text(
          type,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: controller.budgetType.value == type ? primary : Colors.grey[600],
          ),
        ),
      ),
    ));
  }

  void _addMilestone() {
    if (controller.milestoneTitleController.text.isEmpty ||
        controller.milestoneDescController.text.isEmpty ||
        controller.milestoneAmountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(controller.milestoneAmountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ STRICT VALIDATION: Total must not exceed max budget
    final maxBudget = double.tryParse(controller.maxBudgetController.text) ?? 0;
    
    if (maxBudget <= 0) {
      Get.snackbar(
        'Error',
        'Please enter valid max budget first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    final currentTotal = controller.milestonesList.fold<double>(
      0, (sum, m) => sum + (m['amount'] as double)
    );
    final newTotal = currentTotal + amount;

    // Check if total would exceed max budget
    if (newTotal > maxBudget + 0.01) {
      Get.snackbar(
        '❌ Budget Exceeded',
        'Total milestones (\$${newTotal.toStringAsFixed(0)}) exceeds max budget (\$${maxBudget.toStringAsFixed(0)})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Add milestone to list
    Map<String, dynamic> newMilestone = {
      'title': controller.milestoneTitleController.text,
      'description': controller.milestoneDescController.text,
      'amount': amount,
    };
    
    if (controller.selectedMilestoneDueDate.value != null) {
      newMilestone['dueDate'] = controller.selectedMilestoneDueDate.value;
    }
    
    controller.milestonesList.add(newMilestone);

    // Clear form
    controller.milestoneTitleController.clear();
    controller.milestoneDescController.clear();
    controller.milestoneAmountController.clear();
    controller.selectedMilestoneDueDate.value = null;
    controller.showMilestoneForm.value = false;
    
    // Show success message
    Get.snackbar(
      '✅ Success',
      'Milestone added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }

  Widget _buildStep3() {
    return Obx(() => SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Final Details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add required skills and any supporting documents.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Required Technical Skills
            const Text(
              'Required Technical Skills',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => controller.removeSkill(skill),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: const TextStyle(color: Colors.black87),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.skillController,
                          decoration: InputDecoration(
                            hintText: 'Add a skill...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              controller.addSkill(value.trim());
                              controller.skillController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.skillController.text.trim().isNotEmpty) {
                            controller.addSkill(controller.skillController.text.trim());
                            controller.skillController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 20, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Media & Documents
            const Text(
              'Media & Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Upload Area
            GestureDetector(
              onTap: () => controller.pickFiles(),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Upload Supporting Files',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag & drop files or click to browse',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.pickFiles(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Browse Files',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Supports: PDF, DOCX, JPEG, PNG\nMax file size: 25MB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // File requirement warning
            Obx(() {
              if (controller.mediaFiles.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ At least one file is required before publishing',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
            // Selected Files List
            if (controller.mediaFiles.isNotEmpty)
              ...controller.mediaFiles.asMap().entries.map((entry) {
                int index = entry.key;
                MediaFile file = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: controller.getFileColor(file.fileName).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          controller.getFileIcon(file.fileName),
                          color: controller.getFileColor(file.fileName),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.fileName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: controller.getFileColor(file.fileName).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    file.fileType.split('/').last.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: controller.getFileColor(file.fileName),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => controller.removeFile(index),
                      ),
                    ],
                  ),
                );
              }),
            
            const SizedBox(height: 24),
            
            // Info Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Make sure all details are accurate before publishing. You can edit the project later.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ));
  }

  void _showAddDeliverableDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Deliverable',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Describe a specific deliverable for this project',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.deliverableController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. Complete wireframes for all screens',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.deliverableController.text.isNotEmpty) {
                            controller.addDeliverable(controller.deliverableController.text);
                            controller.deliverableController.clear();
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Add Deliverable', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPublishConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ready to Publish?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your project will be visible to our community of professionals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Review Again'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await controller.createProject();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Publish Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.rocket_launch, size: 20, color: Colors.white),
                                ],
                              ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
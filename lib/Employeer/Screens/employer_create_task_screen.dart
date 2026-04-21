import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_task_controller.dart';
import '../../Utils/colors.dart';

class EmployerCreateTaskScreen extends StatelessWidget {
  const EmployerCreateTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.find<TaskController>();
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create New Task',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              const Text(
                'Task Title',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                onChanged: (val) => controller.taskTitle.value = val,
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Please enter task title' : null,
              ),

              const SizedBox(height: 20),
              
              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 4,
                onChanged: (val) => controller.taskDescription.value = val,
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),
              
              // Assign To (Employee only - no job selection)
              const Text(
                'Assign To',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.employeesList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Loading employees...',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  value: controller.selectedEmployeeId.value.isEmpty
                      ? null
                      : controller.selectedEmployeeId.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  hint: const Text('Select employee'),
                  items: controller.employeesList
                      .map<DropdownMenuItem<String>>((emp) {
                    return DropdownMenuItem<String>(
                      value: emp['id'],
                      child: Text('${emp['name']} (${emp['department']})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedEmployeeId.value = val ?? '';
                    // Also store employee name if needed
                    final selectedEmp = controller.employeesList.firstWhere(
                      (emp) => emp['id'] == val,
                      orElse: () => {},
                    );
                    controller.selectedEmployeeName.value = selectedEmp['name'] ?? '';
                  },
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please select an employee'
                      : null,
                );
              }),

              const SizedBox(height: 20),
              
              // Priority
              const Text(
                'Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip('Low', 'low', Colors.green, controller),
                  const SizedBox(width: 8),
                  _buildPriorityChip(
                      'Medium', 'medium', Colors.blue, controller),
                  const SizedBox(width: 8),
                  _buildPriorityChip(
                      'High', 'high', Colors.orange, controller),
                  const SizedBox(width: 8),
                  _buildPriorityChip(
                      'Urgent', 'urgent', Colors.red, controller),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Due Date
              const Text(
                'Due Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() => InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDueDate.value,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null)
                        controller.selectedDueDate.value = picked;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${controller.selectedDueDate.value.day}/${controller.selectedDueDate.value.month}/${controller.selectedDueDate.value.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Icon(Icons.calendar_today,
                              color: Colors.grey[400], size: 18),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 20),

              // Estimated Hours
              const Text(
                'Estimated Hours',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    controller.estimatedHours.value =
                        double.tryParse(val) ?? 0,
                decoration: InputDecoration(
                  hintText: 'Enter hours',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  suffixText: 'hours',
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  controller.clearCreateTaskForm();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isCreating.value
                        ? null
                        : () async {
                            print('Creating task with:');
                            print('Title: ${controller.taskTitle.value}');
                            print(
                                'Description: ${controller.taskDescription.value}');
                            print(
                                'EmployeeId: ${controller.selectedEmployeeId.value}');
                            print(
                                'Priority: ${controller.selectedPriority.value}');
                            print(
                                'DueDate: ${controller.selectedDueDate.value}');
                            print(
                                'Hours: ${controller.estimatedHours.value}');

                            if (_formKey.currentState!.validate()) {
                              final success = await controller.createTask();
                              if (success) {
                                controller.clearCreateTaskForm();
                                Navigator.pop(context);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: controller.isCreating.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Create Task',
                            style: TextStyle(color: Colors.white),
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(
      String label, String value, Color color, TaskController controller) {
    return Expanded(
      child: Obx(() => InkWell(
            onTap: () => controller.selectedPriority.value = value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: controller.selectedPriority.value == value
                    ? color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.selectedPriority.value == value
                      ? color
                      : Colors.grey[300]!,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: controller.selectedPriority.value == value
                      ? color
                      : Colors.grey[600],
                  fontWeight: controller.selectedPriority.value == value
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          )),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_task_controller.dart';
import 'package:templink/Employeer/Screens/employer_create_task_screen.dart';
import 'package:templink/Employeer/Screens/employer_task_detail_screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _bg = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border = Color(0xFFE5E7EB);
const _text1 = Color(0xFF111827);
const _text2 = Color(0xFF6B7280);
const _text3 = Color(0xFF9CA3AF);
const _success = Color(0xFF16A34A);
const _warning = Color(0xFFF59E0B);
const _error = Color(0xFFDC2626);
const _info = Color(0xFF3B82F6);
const _radius = 12.0;

class EmployerTasksScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const EmployerTasksScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

  @override
  State<EmployerTasksScreen> createState() => _EmployerTasksScreenState();
}

class _EmployerTasksScreenState extends State<EmployerTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskController controller = Get.put(TaskController());
  final GlobalKey<FormState> _taskFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isWeb && !widget.showSidebar) {
      return Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildWebTopBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      );
    }

    if (isWeb) {
      return _buildFullWebLayout();
    }

    return _buildMobileLayout();
  }

  // ==================== WEB FULL LAYOUT ====================
  Widget _buildFullWebLayout() {
    final isDesktop = Responsive.isDesktop(context);
    final sidebarW = isDesktop ? 280.0 : 240.0;

    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          Container(
            width: sidebarW,
            decoration: BoxDecoration(
              color: _surface,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(2, 0)),
              ],
            ),
            child: _buildWebSidebar(),
          ),
          Expanded(
            child: Column(
              children: [
                _buildWebTopBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSidebar() {
    return Column(
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.task_alt, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Templink', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text1)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: Column(
              children: [
                const Icon(Icons.task_alt, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                const Text('Task Management', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Manage your team tasks efficiently', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: _border))),
          child: Column(
            children: [
              _webNavItem(Icons.home_outlined, 'Dashboard', () {}),
              const SizedBox(height: 8),
              _webNavItem(Icons.arrow_back, 'Back', () {
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!();
                } else {
                  Get.back();
                }
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _webNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _text2),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, color: _text2)),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: _surface, boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ]),
      child: Row(
        children: [
          Text('Task Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20),
            onPressed: () => controller.fetchTasks(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_task_rounded, size: 20),
            onPressed: () => _showCreateTaskDialog(),
            tooltip: 'Create Task',
          ),
          if (!widget.showSidebar) ...[
            const SizedBox(width: 8),
            CircleAvatar(radius: 18, backgroundColor: primary.withOpacity(0.1), child: Icon(Icons.person, size: 18, color: primary)),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value && controller.allTasks.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: primary));
      }

      return Column(
        children: [
          Container(
            color: _surface,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primary,
              indicatorWeight: 2,
              labelColor: primary,
              unselectedLabelColor: _text3,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'All Tasks'),
                Tab(text: 'Reports'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildAllTasksTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ==================== WEB DIALOGS ====================
  void _showCreateTaskDialog() {
    controller.clearCreateTaskForm();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _taskFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Align(alignment: Alignment.centerLeft, child: Text('Task Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  TextFormField(
                    onChanged: (val) => controller.taskTitle.value = val,
                    decoration: _inputDecoration('Enter task title'),
                    validator: (v) => v?.isEmpty ?? true ? 'Please enter task title' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  const Align(alignment: Alignment.centerLeft, child: Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  TextFormField(
                    maxLines: 3,
                    onChanged: (val) => controller.taskDescription.value = val,
                    decoration: _inputDecoration('Enter task description'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Assign To
                  const Align(alignment: Alignment.centerLeft, child: Text('Assign To', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.employeesList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: _boxDecoration(),
                        child: Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: primary)),
                            const SizedBox(width: 12),
                            Text('Loading employees...', style: TextStyle(color: _text3)),
                          ],
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.selectedEmployeeId.value.isEmpty ? null : controller.selectedEmployeeId.value,
                      decoration: _inputDecoration('Select employee'),
                      hint: const Text('Select employee'),
                      items: controller.employeesList.map<DropdownMenuItem<String>>((emp) {
                        return DropdownMenuItem(value: emp['id'], child: Text('${emp['name']} (${emp['department']})'));
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedEmployeeId.value = val ?? '';
                        final selectedEmp = controller.employeesList.firstWhere(
                          (emp) => emp['id'] == val,
                          orElse: () => {},
                        );
                        controller.selectedEmployeeName.value = selectedEmp['name'] ?? '';
                      },
                      validator: (v) => (v == null || v.isEmpty) ? 'Please select an employee' : null,
                    );
                  }),
                  const SizedBox(height: 16),
                  
                  // Priority
                  const Align(alignment: Alignment.centerLeft, child: Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip('Low', 'low', _success),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Medium', 'medium', _info),
                      const SizedBox(width: 8),
                      _buildPriorityChip('High', 'high', _warning),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Urgent', 'urgent', _error),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Due Date
                  const Align(alignment: Alignment.centerLeft, child: Text('Due Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Obx(() => InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDueDate.value,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) controller.selectedDueDate.value = picked;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: _boxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${controller.selectedDueDate.value.day}/${controller.selectedDueDate.value.month}/${controller.selectedDueDate.value.year}'),
                          Icon(Icons.calendar_today, color: _text3, size: 20),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                  
                  // Estimated Hours
                  const Align(alignment: Alignment.centerLeft, child: Text('Estimated Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) => controller.estimatedHours.value = double.tryParse(val) ?? 0,
                    decoration: _inputDecoration('Enter hours', suffix: 'hours'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
            onPressed: controller.isCreating.value ? null : () async {
              if (_taskFormKey.currentState!.validate()) {
                final success = await controller.createTask();
                if (success) {
                  controller.clearCreateTaskForm();
                  Navigator.pop(context);
                }
              }
            },
            style: _filledButtonStyle(),
            child: controller.isCreating.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Create Task'),
          )),
        ],
      ),
    );
  }

  void _showTaskDetailDialog(Map<String, dynamic> task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Task Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Priority
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: controller.getStatusColor(task['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        controller.getStatusText(task['status']),
                        style: TextStyle(color: controller.getStatusColor(task['status']), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: controller.getPriorityColor(task['priority']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(controller.getPriorityIcon(task['priority']), color: controller.getPriorityColor(task['priority']), size: 14),
                          const SizedBox(width: 4),
                          Text(task['priority'].toUpperCase(), style: TextStyle(color: controller.getPriorityColor(task['priority']), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(task['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Task ID: ${task['id']}', style: TextStyle(color: _text3, fontSize: 12)),
                const SizedBox(height: 20),
                
                // Description
                const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(task['description'], style: const TextStyle(fontSize: 14, height: 1.5)),
                const SizedBox(height: 20),
                
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _boxDecoration(),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.person_outline, 'Assigned To', task['assignedTo'], _info),
                      const Divider(),
                      _buildInfoRow(Icons.person, 'Assigned By', task['assignedBy'], _success),
                      const Divider(),
                      _buildInfoRow(Icons.calendar_today, 'Due Date', task['dueDate'], _warning),
                      const Divider(),
                      _buildInfoRow(Icons.access_time, 'Created', task['createdDate'], Colors.purple),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Progress
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _boxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Logged: ${task['loggedHours']} hrs'),
                        Text('Estimated: ${task['estimatedHours']} hrs'),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: task['loggedHours'] / task['estimatedHours'],
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(_success),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${((task['loggedHours'] / task['estimatedHours']) * 100).toStringAsFixed(0)}% Complete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditTaskDialog(task);
            },
            style: _filledButtonStyle(),
            child: const Text('Edit Task'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    // controller.populateFormForEdit(task);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _taskFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Align(alignment: Alignment.centerLeft, child: Text('Task Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: task['title'],
                    onChanged: (val) => controller.taskTitle.value = val,
                    decoration: _inputDecoration('Enter task title'),
                    validator: (v) => v?.isEmpty ?? true ? 'Please enter task title' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  const Align(alignment: Alignment.centerLeft, child: Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: task['description'],
                    maxLines: 3,
                    onChanged: (val) => controller.taskDescription.value = val,
                    decoration: _inputDecoration('Enter task description'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Assign To
                  const Align(alignment: Alignment.centerLeft, child: Text('Assign To', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.employeesList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: _boxDecoration(),
                        child: Row(
                          children: [
                            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: primary)),
                            const SizedBox(width: 12),
                            Text('Loading employees...', style: TextStyle(color: _text3)),
                          ],
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: controller.selectedEmployeeId.value.isEmpty ? null : controller.selectedEmployeeId.value,
                      decoration: _inputDecoration('Select employee'),
                      hint: const Text('Select employee'),
                      items: controller.employeesList.map<DropdownMenuItem<String>>((emp) {
                        return DropdownMenuItem(value: emp['id'], child: Text('${emp['name']} (${emp['department']})'));
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedEmployeeId.value = val ?? '';
                        final selectedEmp = controller.employeesList.firstWhere(
                          (emp) => emp['id'] == val,
                          orElse: () => {},
                        );
                        controller.selectedEmployeeName.value = selectedEmp['name'] ?? '';
                      },
                      validator: (v) => (v == null || v.isEmpty) ? 'Please select an employee' : null,
                    );
                  }),
                  const SizedBox(height: 16),
                  
                  // Priority
                  const Align(alignment: Alignment.centerLeft, child: Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityChip('Low', 'low', _success),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Medium', 'medium', _info),
                      const SizedBox(width: 8),
                      _buildPriorityChip('High', 'high', _warning),
                      const SizedBox(width: 8),
                      _buildPriorityChip('Urgent', 'urgent', _error),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Due Date
                  const Align(alignment: Alignment.centerLeft, child: Text('Due Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  Obx(() => InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDueDate.value,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) controller.selectedDueDate.value = picked;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: _boxDecoration(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${controller.selectedDueDate.value.day}/${controller.selectedDueDate.value.month}/${controller.selectedDueDate.value.year}'),
                          Icon(Icons.calendar_today, color: _text3, size: 20),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                  
                  // Estimated Hours
                  const Align(alignment: Alignment.centerLeft, child: Text('Estimated Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: task['estimatedHours'].toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => controller.estimatedHours.value = double.tryParse(val) ?? 0,
                    decoration: _inputDecoration('Enter hours', suffix: 'hours'),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
            onPressed: controller.isCreating.value ? null : () async {
              if (_taskFormKey.currentState!.validate()) {
                // final success = await controller.updateTask(task['id']);
                  controller.clearCreateTaskForm();
                  Navigator.pop(context);
                
              }
            },
            style: _filledButtonStyle(),
            child: controller.isCreating.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Update Task'),
          )),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Task Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.employees.isNotEmpty)
                  ...controller.employees.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEmployeeReportCard(e),
                  )),
                if (controller.employees.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No employee data available'),
                  )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {},
            style: _filledButtonStyle(),
            child: const Text('Export Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String label, String value, Color color) {
    return Expanded(
      child: Obx(() => InkWell(
        onTap: () => controller.selectedPriority.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: controller.selectedPriority.value == value ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: controller.selectedPriority.value == value ? color : _border),
          ),
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: controller.selectedPriority.value == value ? color : _text2,
              fontWeight: controller.selectedPriority.value == value ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: _text2, fontSize: 13))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmployeeReportCard(Map<String, dynamic> employee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundColor: primary.withOpacity(0.1), child: Text(employee['initials'], style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(employee['department'], style: TextStyle(color: _text2, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildReportStat('Completed', '${employee['completedTasks'] ?? 0}', _success),
              _buildReportStat('Pending', '${employee['pendingTasks'] ?? 0}', _warning),
              _buildReportStat('On Time', '${employee['onTimeRate'] ?? 85}%', _info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: _text3, fontSize: 10)),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _text1),
          onPressed: widget.onBackPressed ?? () => Get.back(),
        ),
        title: const Text('Task Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _text1)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: () => controller.fetchTasks()),
          IconButton(icon: const Icon(Icons.add_task_rounded), onPressed: () => Get.to(() => const EmployerCreateTaskScreen())),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelColor: primary,
          unselectedLabelColor: _text3,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Tasks'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allTasks.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: primary));
        }
        return TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildAllTasksTab(),
            _buildReportsTab(),
          ],
        );
      }),
    );
  }

  // ==================== OVERVIEW TAB ====================
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchTasks(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                _buildStatsCards(),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildTaskStatusChart()),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: _buildDepartmentProgress()),
                  ],
                ),
                const SizedBox(height: 20),
                _buildUpcomingDeadlines(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = controller.taskStats.value;
    final isDesktop = Responsive.isDesktop(context);
    final crossAxisCount = isDesktop ? 4 : 2;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard('Total Tasks', '${stats['total']}', Icons.assignment, _info),
        _buildStatCard('Pending', '${stats['pending']}', Icons.pending, _warning),
        _buildStatCard('In Progress', '${stats['inProgress']}', Icons.autorenew, _info),
        _buildStatCard('Completed', '${stats['completed']}', Icons.check_circle, _success),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _text1)),
          Text(label, style: TextStyle(color: _text2, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTaskStatusChart() {
    final stats = controller.taskStats.value;
    final total = stats['total'] as int;
    final completed = stats['completed'] as int;
    final percentage = total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Task Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator('Pending', stats['pending'], _warning),
              _buildStatusIndicator('In Progress', stats['inProgress'], _info),
              _buildStatusIndicator('Completed', stats['completed'], _success),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(_success),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$percentage% Completed', style: TextStyle(color: _text2, fontSize: 12)),
              Text('${stats['overdue']} Overdue', style: const TextStyle(color: _error, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Column(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(height: 4),
        Text('$count', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: _text3, fontSize: 11)),
      ],
    );
  }

  Widget _buildDepartmentProgress() {
    if (controller.departmentTasks.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Department Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
          const SizedBox(height: 16),
          ...controller.departmentTasks.map((dept) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(dept['dept'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  Text('${dept['completed']}/${dept['total']}', style: TextStyle(color: _text2, fontSize: 11)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: dept['total'] > 0 ? dept['completed'] / dept['total'] : 0,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(dept['completed'] / dept['total'] > 0.7 ? _success : _warning),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines() {
    final upcomingTasks = controller.allTasks.where((t) => t['status'] != 'completed').toList().take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Upcoming Deadlines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
            TextButton(onPressed: () => _tabController.animateTo(1), child: const Text('View All')),
          ]),
          const SizedBox(height: 16),
          if (upcomingTasks.isEmpty)
            const Center(child: Text('No pending tasks', style: TextStyle(color: _text2)))
          else
            ...upcomingTasks.map((task) => _buildDeadlineItem(task)),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(Map<String, dynamic> task) {
    final dueDate = DateTime.parse('${task['dueDate']}');
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: controller.getPriorityColor(task['priority']).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.task_alt, color: controller.getPriorityColor(task['priority']), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Assigned to: ${task['assignedTo']}', style: TextStyle(color: _text2, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: (isOverdue ? _error : _warning).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(isOverdue ? 'Overdue' : '$daysLeft days left', style: TextStyle(color: isOverdue ? _error : _warning, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Text(task['dueDate'], style: TextStyle(color: _text3, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ALL TASKS TAB ====================
  Widget _buildAllTasksTab() {
    final isDesktop = Responsive.isDesktop(context);
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: isDesktop
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: controller.filteredTasks.length,
                  itemBuilder: (context, index) => _buildTaskCard(controller.filteredTasks[index]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredTasks.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTaskCard(controller.filteredTasks[index]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Pending', 'In Progress', 'Completed', 'Overdue'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: filters.map((filter) {
            final isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.applyFilter(filter),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? primary : _border),
                ),
                child: Text(filter,
                  style: TextStyle(color: isSelected ? Colors.white : _text2, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13),
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    
    return Container(
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
      child: InkWell(
        onTap: () {
          if (isWeb) {
            _showTaskDetailDialog(task);
          } else {
            Get.to(() => EmployerTaskDetailScreen(task: task));
          }
        },
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: controller.getPriorityColor(task['priority']).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(controller.getPriorityIcon(task['priority']), color: controller.getPriorityColor(task['priority']), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(task['description'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _text2, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: controller.getStatusColor(task['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(controller.getStatusText(task['status']), style: TextStyle(color: controller.getStatusColor(task['status']), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _buildTaskInfo(Icons.person_outline, task['assignedTo']),
                _buildTaskInfo(Icons.calendar_today, task['dueDate']),
                _buildTaskInfo(Icons.timer, '${task['loggedHours']}/${task['estimatedHours']}h'),
              ]),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTaskMeta(Icons.attach_file, '${task['attachments']}'),
                  const SizedBox(width: 16),
                  _buildTaskMeta(Icons.comment, '${task['comments']}'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: controller.getPriorityColor(task['priority']).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(task['priority'].toUpperCase(), style: TextStyle(color: controller.getPriorityColor(task['priority']), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _text3),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: _text2)),
      ],
    );
  }

  Widget _buildTaskMeta(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _text3),
        const SizedBox(width: 2),
        Text(count, style: TextStyle(fontSize: 11, color: _text2)),
      ],
    );
  }

  // ==================== REPORTS TAB ====================
  Widget _buildReportsTab() {
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);
    
    return RefreshIndicator(
      onRefresh: () => controller.fetchTasks(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildEmployeePerformance(isWeb)),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: _buildTaskCompletionRate()),
                  ],
                ),
                const SizedBox(height: 20),
                _buildRecentReports(isWeb),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeePerformance(bool isWeb) {
    if (controller.employees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
        child: const Center(child: Text('No employees data', style: TextStyle(color: _text2))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Employee Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
            if (isWeb)
              TextButton(
                onPressed: () => _showReportDialog(),
                child: const Text('View Details'),
              ),
          ]),
          const SizedBox(height: 16),
          ...controller.employees.take(4).map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(radius: 22, backgroundColor: primary.withOpacity(0.1), child: Text(e['initials'], style: TextStyle(color: primary, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e['performance'] / 100,
                          minHeight: 4,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(e['performance'] > 80 ? _success : _warning),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text('${e['performance']}%', style: TextStyle(color: e['performance'] > 80 ? _success : _warning, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTaskCompletionRate() {
    final stats = controller.taskStats.value;
    final total = stats['total'] as int;
    final completed = stats['completed'] as int;
    final percentage = total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Completion Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 120, height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(_success),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$percentage%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('Completed', style: TextStyle(fontSize: 12, color: _text2)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildStatSmall('Total', '$total'),
            _buildStatSmall('Pending', '${stats['pending']}'),
            _buildStatSmall('In Progress', '${stats['inProgress']}'),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatSmall(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: _text2)),
      ],
    );
  }

  Widget _buildRecentReports(bool isWeb) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(_radius), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text1)),
            if (isWeb)
              TextButton(
                onPressed: () => _showReportDialog(),
                child: const Text('View All'),
              ),
          ]),
          const SizedBox(height: 16),
          _buildReportTile(Icons.pie_chart, 'Weekly Task Summary', '${DateTime.now().subtract(const Duration(days: 7)).day} - ${DateTime.now().day}, ${DateTime.now().year}', _info),
          const Divider(),
          _buildReportTile(Icons.assessment, 'Employee Performance', '${DateTime.now().month}/${DateTime.now().year}', _success),
          const Divider(),
          _buildReportTile(Icons.timer, 'Time Tracking Report', 'Last 30 days', _warning),
        ],
      ),
    );
  }

  Widget _buildReportTile(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: _text2)),
      trailing: IconButton(icon: const Icon(Icons.download_outlined, size: 18), onPressed: () {}),
      onTap: () {},
    );
  }

  // ==================== HELPER METHODS ====================
  InputDecoration _inputDecoration(String hint, {String? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: _text3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixText: suffix,
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border));
  }

  ButtonStyle _filledButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
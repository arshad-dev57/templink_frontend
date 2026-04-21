import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';

class TaskController extends GetxController {
  var isLoading = false.obs;
  var isCreating = false.obs;
  var isUpdating = false.obs;
    var allTasks = <Map<String, dynamic>>[].obs;
  var filteredTasks = <Map<String, dynamic>>[].obs;
    var employeeTasks = <Map<String, dynamic>>[].obs;
  var filteredEmployeeTasks = <Map<String, dynamic>>[].obs;
    var employees = <Map<String, dynamic>>[].obs;
    var taskStats = <String, dynamic>{
    'total': 0,
    'pending': 0,
    'inProgress': 0,
    'completed': 0,
    'overdue': 0,
  }.obs;
  
  var departmentTasks = <Map<String, dynamic>>[].obs;
    var selectedFilter = 'All'.obs;
    var taskTitle = ''.obs;
  var taskDescription = ''.obs;
  var selectedEmployeeId = ''.obs;
  var selectedEmployeeName = ''.obs;
  var selectedPriority = 'medium'.obs;
  var selectedDueDate = DateTime.now().add(const Duration(days: 7)).obs;
  var estimatedHours = 0.0.obs;
  
    var employeesList = <Map<String, dynamic>>[].obs;

  final String baseUrl = ApiConfig.baseUrl;

  Map<String, dynamic> get summaryStats {
    return {
      'total': taskStats.value['total'] ?? 0,
      'pending': taskStats.value['pending'] ?? 0,
      'inProgress': taskStats.value['inProgress'] ?? 0,
      'completed': taskStats.value['completed'] ?? 0,
      'overdue': taskStats.value['overdue'] ?? 0,
    };
  }

  @override
  void onInit() {
    super.onInit();
    print('TaskController initialized');
    initForEmployer();
  }
  
  void initForEmployer() {
    fetchTasks();
    fetchActiveHiredEmployees();
  }
  
  void initForEmployee() {
    fetchEmployeeTasks();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('Token: ${token != null ? 'Found' : 'Not found'}');
    return token;
  }
 Future<void> fetchActiveHiredEmployees() async {
  print("fetching hiredemployee");
  try {
    final token = await _getToken();
    if (token == null) {
      print('No token found for fetching hired employees');
      return;
    }
    
    final url = '$baseUrl/api/jobapplication/employer/hired?status=active';
    print('Fetching hired employees from: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    print('Hired employees response status: ${response.statusCode}');
    print('Hired employees response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Parsed hired employees data: $jsonData');
      final dataList = jsonData['data'] as List? ?? [];
      final List<Map<String, dynamic>> formattedEmployees = [];
      
      for (var item in dataList) {
        try {
          final employeeData = item as Map<String, dynamic>;
          
          // Get employeeId (just the ID string)
          final employeeId = employeeData['employeeId']?.toString() ?? '';
          
          // Get employee details from employeeDetails object
          final employeeDetails = employeeData['employeeDetails'] as Map<String, dynamic>?;
          String empName = 'Unknown';
          
          if (employeeDetails != null) {
            final firstName = employeeDetails['firstName']?.toString() ?? '';
            final lastName = employeeDetails['lastName']?.toString() ?? '';
            empName = '$firstName $lastName'.trim();
            if (empName.isEmpty) empName = 'Unknown';
          }
          
          formattedEmployees.add({
            'id': employeeId,
            'name': empName,
            'department': employeeData['jobTitle']?.toString() ?? 'No Department',
            'jobId': employeeData['jobId']?.toString() ?? '',
            'jobTitle': employeeData['jobTitle']?.toString() ?? '',
            'hiredAt': employeeData['hiredAt'],
            'status': employeeData['status']?.toString() ?? 'active',
          });
        } catch (e) {
          print('Error parsing employee: $e');
        }
      }
      
      print('Formatted employees: $formattedEmployees');
      employeesList.value = formattedEmployees;
      
      final List<Map<String, dynamic>> formattedForReports = [];
      for (var emp in formattedEmployees) {
        formattedForReports.add({
          'id': emp['id'],
          'name': emp['name'],
          'initials': _getInitials(emp['name']),
          'department': emp['department'],
          'completed': 0,
          'pending': 0,
          'performance': 0,
        });
      }
      employees.value = formattedForReports;
      _calculateEmployeeStats();
    } else {
      print('Failed to fetch hired employees. Status: ${response.statusCode}');
      Get.snackbar(
        'Error',
        'Failed to load hired employees (Status: ${response.statusCode})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print('Error fetching hired employees: $e');
    Get.snackbar(
      'Error',
      'Failed to load hired employees: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
} 
  // ==================== FETCH EMPLOYER TASKS ====================
  Future<void> fetchTasks() async {
    isLoading.value = true;
    
    try {
      final token = await _getToken();
      if (token == null) {
        print('No token found for fetching tasks');
        isLoading.value = false;
        return;
      }
      
      final url = '$baseUrl/api/tasks/employer?page=1&limit=100';
      print('Fetching tasks from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('Tasks response status: ${response.statusCode}');
      print('Tasks response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tasksData = data['data'] as List? ?? [];
        
        print('Found ${tasksData.length} tasks');
        
        // Convert tasks to the format expected by UI
        final List<Map<String, dynamic>> formattedTasks = [];
        
        for (var task in tasksData) {
          try {
            final taskMap = task as Map<String, dynamic>;
            
            // Get employee details
            final employeeIdData = taskMap['employeeId'];
            String assignedTo = 'Unknown';
            String assignedToId = '';
            
            if (employeeIdData is Map<String, dynamic>) {
              assignedToId = employeeIdData['_id']?.toString() ?? '';
              final firstName = employeeIdData['firstName']?.toString() ?? '';
              final lastName = employeeIdData['lastName']?.toString() ?? '';
              assignedTo = '$firstName $lastName'.trim();
              if (assignedTo.isEmpty) assignedTo = 'Unknown';
            } else if (employeeIdData is String) {
              assignedToId = employeeIdData;
            }
            
            // Get employer details
            final employerIdData = taskMap['employerId'];
            String assignedBy = 'Employer';
            if (employerIdData is Map<String, dynamic>) {
              final firstName = employerIdData['firstName']?.toString() ?? '';
              final lastName = employerIdData['lastName']?.toString() ?? '';
              assignedBy = '$firstName $lastName'.trim();
              if (assignedBy.isEmpty) assignedBy = 'Employer';
            }
            
            // Get department
            String department = 'General';
            if (employeeIdData is Map<String, dynamic>) {
              final empProfile = employeeIdData['employeeProfile'];
              if (empProfile is Map<String, dynamic>) {
                department = empProfile['category']?.toString() ?? 'General';
              }
            }
            
            // Format dates
            String dueDateStr = '';
            try {
              final dueDate = DateTime.parse(taskMap['dueDate']);
              dueDateStr = _formatDate(dueDate);
            } catch (e) {
              dueDateStr = taskMap['dueDate']?.toString() ?? '';
            }
            
            String createdDateStr = '';
            try {
              final createdAt = DateTime.parse(taskMap['createdAt']);
              createdDateStr = _formatDate(createdAt);
            } catch (e) {
              createdDateStr = taskMap['createdAt']?.toString() ?? '';
            }
            
            formattedTasks.add({
              'id': taskMap['_id']?.toString() ?? '',
              'title': taskMap['title']?.toString() ?? '',
              'description': taskMap['description']?.toString() ?? '',
              'assignedTo': assignedTo,
              'assignedToId': assignedToId,
              'assignedBy': assignedBy,
              'department': department,
              'priority': taskMap['priority']?.toString() ?? 'medium',
              'status': taskMap['status']?.toString() ?? 'pending',
              'dueDate': dueDateStr,
              'createdDate': createdDateStr,
              'estimatedHours': (taskMap['estimatedHours'] ?? 0).toInt(),
              'loggedHours': (taskMap['actualHours'] ?? 0).toInt(),
              'attachments': (taskMap['attachments'] as List?)?.length ?? 0,
              'comments': (taskMap['comments'] as List?)?.length ?? 0,
            });
          } catch (e) {
            print('Error parsing task: $e');
          }
        }
        
        allTasks.value = formattedTasks;
        filteredTasks.value = formattedTasks;
        
        // Calculate stats
        _calculateStats();
        
        // Calculate department tasks
        _calculateDepartmentTasks();
        
        // Calculate employee stats
        _calculateEmployeeStats();
      } else if (response.statusCode == 404) {
        print('Tasks endpoint not found (404). Make sure the API endpoint exists.');
        Get.snackbar(
          'Info',
          'Tasks API endpoint not configured yet. Please contact developer.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        print('Failed to fetch tasks. Status: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to fetch tasks (Status: ${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // ==================== FETCH EMPLOYEE TASKS ====================
  Future<void> fetchEmployeeTasks() async {
    isLoading.value = true;
    
    try {
      final token = await _getToken();
      if (token == null) {
        print('No token found for fetching employee tasks');
        isLoading.value = false;
        return;
      }
      
      final url = '$baseUrl/api/tasks/employee?page=1&limit=100';
      print('Fetching employee tasks from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('Employee tasks response status: ${response.statusCode}');
      print('Employee tasks response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tasksData = data['data'] as List? ?? [];
        
        print('Found ${tasksData.length} employee tasks');
        
        // Convert tasks to the format expected by UI
        final List<Map<String, dynamic>> formattedTasks = [];
        
        for (var task in tasksData) {
          try {
            final taskMap = task as Map<String, dynamic>;
            
            // Get employer details
            final employerIdData = taskMap['employerId'];
            String assignedBy = 'Employer';
            if (employerIdData is Map<String, dynamic>) {
              final firstName = employerIdData['firstName']?.toString() ?? '';
              final lastName = employerIdData['lastName']?.toString() ?? '';
              assignedBy = '$firstName $lastName'.trim();
              if (assignedBy.isEmpty) assignedBy = 'Employer';
            }
            
            // Get department/job title
            String department = 'General';
            final jobIdData = taskMap['jobId'];
            if (jobIdData is Map<String, dynamic>) {
              department = jobIdData['title']?.toString() ?? 'General';
            }
            
            // Format dates
            String dueDateStr = '';
            try {
              final dueDate = DateTime.parse(taskMap['dueDate']);
              dueDateStr = _formatDate(dueDate);
            } catch (e) {
              dueDateStr = taskMap['dueDate']?.toString() ?? '';
            }
            
            String createdDateStr = '';
            try {
              final createdAt = DateTime.parse(taskMap['createdAt']);
              createdDateStr = _formatDate(createdAt);
            } catch (e) {
              createdDateStr = taskMap['createdAt']?.toString() ?? '';
            }
            
            formattedTasks.add({
              'id': taskMap['_id']?.toString() ?? '',
              'title': taskMap['title']?.toString() ?? '',
              'description': taskMap['description']?.toString() ?? '',
              'assignedBy': assignedBy,
              'department': department,
              'priority': taskMap['priority']?.toString() ?? 'medium',
              'status': taskMap['status']?.toString() ?? 'pending',
              'dueDate': dueDateStr,
              'createdDate': createdDateStr,
              'estimatedHours': (taskMap['estimatedHours'] ?? 0).toInt(),
              'loggedHours': (taskMap['actualHours'] ?? 0).toInt(),
              'attachments': (taskMap['attachments'] as List?)?.length ?? 0,
              'comments': (taskMap['comments'] as List?)?.length ?? 0,
            });
          } catch (e) {
            print('Error parsing employee task: $e');
          }
        }
        
        employeeTasks.value = formattedTasks;
        filteredEmployeeTasks.value = formattedTasks;
        
        // Calculate stats for employee tasks
        _calculateEmployeeTaskStats();
      } else if (response.statusCode == 404) {
        print('Employee tasks endpoint not found (404). Make sure the API endpoint exists.');
      } else {
        print('Failed to fetch employee tasks. Status: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to fetch your tasks (Status: ${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error fetching employee tasks: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch your tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // ==================== CREATE TASK ====================
  Future<bool> createTask() async {
    if (taskTitle.value.isEmpty) {
      Get.snackbar('Error', 'Please enter task title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    if (selectedEmployeeId.value.isEmpty) {
      Get.snackbar('Error', 'Please select an employee',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    isCreating.value = true;
    
    try {
      final token = await _getToken();
      if (token == null) return false;
      
      // Get the jobId from the selected employee
      String jobId = '';
      for (var emp in employeesList.value) {
        if (emp['id'] == selectedEmployeeId.value) {
          jobId = emp['jobId']?.toString() ?? '';
          break;
        }
      }
      
      final body = {
        'title': taskTitle.value,
        'description': taskDescription.value,
        'employeeId': selectedEmployeeId.value,
        'jobId': jobId,
        'priority': selectedPriority.value,
        'dueDate': selectedDueDate.value.toIso8601String(),
        'estimatedHours': estimatedHours.value,
      };
      
      print('Creating task with body: $body');
      
      final url = '$baseUrl/api/tasks';
      print('POST to: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      print('Create task response status: ${response.statusCode}');
      print('Create task response body: ${response.body}');
      
      if (response.statusCode == 201) {
        await fetchTasks(); // Refresh tasks
        Get.snackbar(
          'Success',
          'Task created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'Error',
          'Tasks API endpoint not found. Please check backend.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      } else {
        final error = json.decode(response.body);
        Get.snackbar(
          'Error',
          error['message'] ?? 'Failed to create task (Status: ${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('Error creating task: $e');
      Get.snackbar(
        'Error',
        'Failed to create task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCreating.value = false;
    }
  }
  
  // ==================== UPDATE TASK STATUS ====================
  Future<void> updateTaskStatus(String taskId, String status) async {
    isUpdating.value = true;
    
    try {
      final token = await _getToken();
      if (token == null) return;
      
      final url = '$baseUrl/api/tasks/$taskId/status';
      print('Updating task status at: $url');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );
      
      print('Update status response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Refresh based on which tasks we're viewing
        if (employeeTasks.isNotEmpty) {
          await fetchEmployeeTasks();
        } else {
          await fetchTasks();
        }
        Get.snackbar(
          'Success',
          'Task status updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      print('Error updating task status: $e');
      Get.snackbar(
        'Error',
        'Failed to update status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }
  
  // ==================== HELPER METHODS ====================
  void _calculateStats() {
    final tasks = allTasks.value;
    final now = DateTime.now();
    
    taskStats.value = {
      'total': tasks.length,
      'pending': tasks.where((t) => t['status'] == 'pending').length,
      'inProgress': tasks.where((t) => t['status'] == 'in_progress').length,
      'completed': tasks.where((t) => t['status'] == 'completed').length,
      'overdue': tasks.where((t) {
        if (t['status'] == 'completed') return false;
        try {
          final dueDate = DateTime.parse('${t['dueDate']}');
          return dueDate.isBefore(now);
        } catch (e) {
          return false;
        }
      }).length,
    };
  }
  
  void _calculateEmployeeTaskStats() {
    final tasks = employeeTasks.value;
    final now = DateTime.now();
    
    taskStats.value = {
      'total': tasks.length,
      'pending': tasks.where((t) => t['status'] == 'pending').length,
      'inProgress': tasks.where((t) => t['status'] == 'in_progress').length,
      'completed': tasks.where((t) => t['status'] == 'completed').length,
      'overdue': tasks.where((t) {
        if (t['status'] == 'completed') return false;
        try {
          final dueDate = DateTime.parse('${t['dueDate']}');
          return dueDate.isBefore(now);
        } catch (e) {
          return false;
        }
      }).length,
    };
  }
  
  void _calculateDepartmentTasks() {
    final Map<String, Map<String, int>> deptMap = {};
    
    for (var task in allTasks.value) {
      final dept = task['department']?.toString() ?? 'General';
      if (!deptMap.containsKey(dept)) {
        deptMap[dept] = {'total': 0, 'completed': 0};
      }
      deptMap[dept]!['total'] = deptMap[dept]!['total']! + 1;
      if (task['status'] == 'completed') {
        deptMap[dept]!['completed'] = deptMap[dept]!['completed']! + 1;
      }
    }
    
    departmentTasks.value = deptMap.entries.map((entry) {
      return {
        'dept': entry.key,
        'total': entry.value['total'],
        'completed': entry.value['completed'],
        'pending': entry.value['total']! - entry.value['completed']!,
      };
    }).toList();
  }
  
  void _calculateEmployeeStats() {
    final Map<String, Map<String, dynamic>> employeeStats = {};
    
    for (var emp in employees.value) {
      final empId = emp['id']?.toString() ?? '';
      if (empId.isNotEmpty) {
        employeeStats[empId] = {
          'completed': 0,
          'pending': 0,
          'total': 0,
        };
      }
    }
    
    for (var task in allTasks.value) {
      final empId = task['assignedToId']?.toString() ?? '';
      if (empId.isNotEmpty && employeeStats.containsKey(empId)) {
        if (task['status'] == 'completed') {
          employeeStats[empId]!['completed'] = (employeeStats[empId]!['completed'] ?? 0) + 1;
        } else {
          employeeStats[empId]!['pending'] = (employeeStats[empId]!['pending'] ?? 0) + 1;
        }
        employeeStats[empId]!['total'] = (employeeStats[empId]!['total'] ?? 0) + 1;
      }
    }
    
    final updatedEmployees = employees.value.map((emp) {
      final empId = emp['id']?.toString() ?? '';
      final stats = employeeStats[empId];
      final total = stats?['total'] ?? 0;
      final completed = stats?['completed'] ?? 0;
      final performance = total > 0 ? (completed / total * 100).round() : 0;
      
      return {
        ...emp,
        'completed': completed,
        'pending': stats?['pending'] ?? 0,
        'performance': performance,
      };
    }).toList();
    
    employees.value = updatedEmployees;
  }
  
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    } else if (name.isNotEmpty) {
      return name[0];
    }
    return '?';
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  void applyFilter(String filter) {
    selectedFilter.value = filter;
    
    if (filter == 'All') {
      filteredTasks.value = allTasks.value;
    } else if (filter == 'Overdue') {
      final now = DateTime.now();
      filteredTasks.value = allTasks.value.where((t) {
        if (t['status'] == 'completed') return false;
        try {
          final dueDate = DateTime.parse('${t['dueDate']}');
          return dueDate.isBefore(now);
        } catch (e) {
          return false;
        }
      }).toList();
    } else {
      final status = filter.toLowerCase().replaceAll(' ', '_');
      filteredTasks.value = allTasks.value.where((t) => t['status'] == status).toList();
    }
  }
  
  void applyEmployeeFilter(String filter) {
    selectedFilter.value = filter;
    
    if (filter == 'All') {
      filteredEmployeeTasks.value = employeeTasks.value;
    } else if (filter == 'Overdue') {
      final now = DateTime.now();
      filteredEmployeeTasks.value = employeeTasks.value.where((t) {
        if (t['status'] == 'completed') return false;
        try {
          final dueDate = DateTime.parse('${t['dueDate']}');
          return dueDate.isBefore(now);
        } catch (e) {
          return false;
        }
      }).toList();
    } else {
      final status = filter.toLowerCase().replaceAll(' ', '_');
      filteredEmployeeTasks.value = employeeTasks.value.where((t) => t['status'] == status).toList();
    }
  }
  
  void clearCreateTaskForm() {
    taskTitle.value = '';
    taskDescription.value = '';
    selectedEmployeeId.value = '';
    selectedEmployeeName.value = '';
    selectedPriority.value = 'medium';
    selectedDueDate.value = DateTime.now().add(const Duration(days: 7));
    estimatedHours.value = 0.0;
  }
  
  // Helper methods for UI colors
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.blue;
      default: return Colors.green;
    }
  }
  
  IconData getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent': return Icons.priority_high;
      case 'high': return Icons.trending_up;
      case 'medium': return Icons.remove;
      default: return Icons.trending_down;
    }
  }
  
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'review': return Colors.purple;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }
  
  String getStatusText(String status) {
    switch (status) {
      case 'pending': return 'PENDING';
      case 'in_progress': return 'IN PROGRESS';
      case 'review': return 'REVIEW';
      case 'completed': return 'DONE';
      default: return status.toUpperCase();
    }
  }
}
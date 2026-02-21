import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectManagementController extends GetxController {
  final Map<String, dynamic> project;
  var isLoading = false.obs;
  
  late final List<Map<String, dynamic>> milestones;
  late final Map<String, dynamic>? freelancerInfo;
  
  ProjectManagementController({required this.project}) {
    _initializeData();
  }
  
  void _initializeData() {
    milestones = List<Map<String, dynamic>>.from(project['milestones'] ?? []);
    
    // Find accepted proposal and freelancer info
    final proposals = project['proposals'] as List? ?? [];
    final acceptedProposal = proposals.firstWhere(
      (p) => p['status'] == 'ACCEPTED',
      orElse: () => null,
    );
    
    if (acceptedProposal != null) {
      final employee = acceptedProposal['employee'] ?? {};
      freelancerInfo = {
        'name': '${employee['firstName'] ?? ''} ${employee['lastName'] ?? ''}'.trim(),
        'title': employee['employeeProfile']?['title'] ?? 'Freelancer',
        'initials': _getInitials(employee),
      };
    } else {
      freelancerInfo = null;
    }
  }
  
  String _getInitials(Map<String, dynamic> employee) {
    final firstName = employee['firstName'] ?? '';
    final lastName = employee['lastName'] ?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    }
    return 'F';
  }
  
  int get totalMilestones => milestones.length;
  
  int get completedMilestones {
    return milestones.where((m) => 
      m['status'] == 'APPROVED' || m['status'] == 'RELEASED'
    ).length;
  }
  
  double get milestoneProgress {
    if (totalMilestones == 0) return 0;
    return completedMilestones / totalMilestones;
  }
  
  Map<String, dynamic>? get activeMilestone {
    try {
      return milestones.firstWhere((m) => 
        m['status'] == 'FUNDED' || m['status'] == 'SUBMITTED'
      );
    } catch (e) {
      return null;
    }
  }
  
  String getStatusText() {
    switch (project['status']) {
      case 'OPEN': return 'Open';
      case 'AWAITING_FUNDING': return 'Awaiting Funding';
      case 'IN_PROGRESS': return 'In Progress';
      case 'COMPLETED': return 'Completed';
      default: return project['status'] ?? 'Unknown';
    }
  }
  
  Color getStatusColor() {
    switch (project['status']) {
      case 'OPEN': return Colors.green;
      case 'AWAITING_FUNDING': return Colors.orange;
      case 'IN_PROGRESS': return Colors.blue;
      case 'COMPLETED': return Colors.teal;
      default: return Colors.grey;
    }
  }
  
  String formatBudget() {
    final min = project['minBudget']?.toDouble() ?? 0;
    final max = project['maxBudget']?.toDouble() ?? 0;
    final type = project['budgetType'] ?? 'FIXED';
    
    if (type == 'FIXED') {
      return '\$${min.round()} - \$${max.round()}';
    } else {
      return '\$${min.round()}/hr - \$${max.round()}/hr';
    }
  }
}
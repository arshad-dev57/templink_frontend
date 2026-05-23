// lib/Employeer/model/employer_interest_model.dart
import 'package:flutter/material.dart';

class EmployerInterestModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeePhoto;
  final String employeeTitle;
  final String jobTitle;
  final double salaryAmount;
  final String salaryPeriod;
  final String message;
  final String status;  // pending, interested, declined, hired, cancelled
  final DateTime createdAt;
  final DateTime? respondedAt;
  final double commissionAmount;

  EmployerInterestModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeePhoto,
    required this.employeeTitle,
    required this.jobTitle,
    required this.salaryAmount,
    required this.salaryPeriod,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    required this.commissionAmount,
  });

  factory EmployerInterestModel.fromJson(Map<String, dynamic> json) {
    final employee = json['employeeId'] is Map
        ? json['employeeId'] as Map<String, dynamic>
        : null;
    
    final employeeProfile = employee?['employeeProfile'] as Map<String, dynamic>?;

    return EmployerInterestModel(
      id: json['_id'] ?? '',
      employeeId: employee?['_id'] ?? json['employeeId'] ?? '',
      employeeName: employee != null
          ? '${employee['firstName'] ?? ''} ${employee['lastName'] ?? ''}'.trim()
          : 'Unknown Employee',
      employeePhoto: employeeProfile?['photoUrl'] ?? '',
      employeeTitle: employeeProfile?['title'] ?? 'Professional',
      jobTitle: json['jobTitle'] ?? '',
      salaryAmount: (json['salaryAmount'] ?? 0).toDouble(),
      salaryPeriod: json['salaryPeriod'] ?? 'monthly',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
    );
  }

  String get formattedSalary {
    return '\$${salaryAmount.toStringAsFixed(0)}/${_getPeriodSymbol()}';
  }

  String _getPeriodSymbol() {
    switch (salaryPeriod) {
      case 'hourly':
        return 'hr';
      case 'monthly':
        return 'mo';
      case 'yearly':
        return 'yr';
      default:
        return 'mo';
    }
  }

  // ✅ Helper methods for UI display
  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'interested':
        return 'Interested';
      case 'declined':
        return 'Declined';
      case 'hired':
        return 'Hired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'interested':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'hired':
        return Colors.purple;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'interested':
        return Icons.check_circle_outline;
      case 'declined':
        return Icons.cancel_outlined;
      case 'hired':
        return Icons.work;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }
}
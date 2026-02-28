// lib/Employee/models/interest_request_model.dart
import 'package:flutter/material.dart';

class InterestRequestModel {
  final String id;
  final String employerId;
  final String employerName;
  final String companyName;
  final String logoUrl;
  final String jobTitle;
  final double salaryAmount;
  final String salaryPeriod;
  final String message;
  final String status; // 'pending', 'interested', 'declined', 'hired'
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;

  InterestRequestModel({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.companyName,
    required this.logoUrl,
    required this.jobTitle,
    required this.salaryAmount,
    required this.salaryPeriod,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
  });

  factory InterestRequestModel.fromJson(Map<String, dynamic> json) {
    final employer = json['employerId'] is Map
        ? json['employerId'] as Map<String, dynamic>
        : null;
    
    final employerProfile = employer?['employerProfile'] as Map<String, dynamic>?;

    return InterestRequestModel(
      id: json['_id'] ?? '',
      employerId: employer?['_id'] ?? json['employerId'] ?? '',
      employerName: employer != null
          ? '${employer['firstName'] ?? ''} ${employer['lastName'] ?? ''}'.trim()
          : 'Unknown Employer',
      companyName: employerProfile?['companyName'] ?? 'Company',
      logoUrl: employerProfile?['logoUrl'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      salaryAmount: (json['salaryAmount'] ?? 0).toDouble(),
      salaryPeriod: json['salaryPeriod'] ?? 'monthly',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(days: 7)),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
    );
  }

  // Helper getters for UI
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

  String get daysRemaining {
    final now = DateTime.now();
    final difference = expiresAt.difference(now).inDays;
    if (difference < 0) return 'Expired';
    if (difference == 0) return 'Last day';
    if (difference == 1) return '1 day left';
    return '$difference days left';
  }

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  
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
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.pending_outlined;
      case 'interested':
        return Icons.check_circle_outline;
      case 'declined':
        return Icons.cancel_outlined;
      case 'hired':
        return Icons.work_outline;
      default:
        return Icons.help_outline;
    }
  }
}
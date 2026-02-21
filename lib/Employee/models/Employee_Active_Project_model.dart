// lib/Employee/models/active_project_model.dart
import 'package:flutter/material.dart';

class EmployeeActiveProjectModel {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String experienceLevel;
  final String budgetType;
  final double minBudget;
  final double maxBudget;
  final List<String> skills;
  final List<String> deliverables;

  // Employer Info
  final String employerId;
  final String employerName;
  final String? employerLogo;
  final Map<String, dynamic> employerSnapshot;

  // Employee Info
  final String employeeId;

  // Contract Info
  final String contractId;
  final String contractNumber;
  final String contractStatus;
  final DateTime? signedAt;

  // Milestones
  final List<Milestone> milestones;

  // Payment Summary
  final double totalBudget;
  final double totalPaid;
  final double remainingAmount;
  final DateTime? lastPaymentAt;

  // Progress
  final int totalMilestones;
  final int completedMilestones;
  final double progressPercentage;

  // Next actionable milestone
  final NextMilestone? nextMilestone;

  // Timestamps
  final DateTime hiredAt;
  final DateTime? lastActivityAt;
  final DateTime? expectedEndDate;
  final DateTime? completedAt;

  // Status
  final String status;

  EmployeeActiveProjectModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.experienceLevel,
    required this.budgetType,
    required this.minBudget,
    required this.maxBudget,
    required this.skills,
    required this.deliverables,
    required this.employerId,
    required this.employerName,
    this.employerLogo,
    required this.employerSnapshot,
    required this.employeeId,
    required this.contractId,
    required this.contractNumber,
    required this.contractStatus,
    this.signedAt,
    required this.milestones,
    required this.totalBudget,
    required this.totalPaid,
    required this.remainingAmount,
    this.lastPaymentAt,
    required this.totalMilestones,
    required this.completedMilestones,
    required this.progressPercentage,
    this.nextMilestone,
    required this.hiredAt,
    this.lastActivityAt,
    this.expectedEndDate,
    this.completedAt,
    required this.status,
  });

  // Helper getters
  bool get isActive => status == 'ACTIVE';
  bool get isCompleted => status == 'COMPLETED';
  bool get isTerminated => status == 'TERMINATED';
  
  String get employerDisplayName => employerName.isNotEmpty ? employerName : 'Client';
  
  Color get statusColor {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'TERMINATED':
        return Colors.red;
      case 'ON_HOLD':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'COMPLETED':
        return 'Completed';
      case 'TERMINATED':
        return 'Terminated';
      case 'ON_HOLD':
        return 'On Hold';
      default:
        return status;
    }
  }

  factory EmployeeActiveProjectModel.fromJson(Map<String, dynamic> json) {
    // Parse milestones
    List<Milestone> milestonesList = [];
    if (json['milestones'] != null) {
      milestonesList = (json['milestones'] as List)
          .map((m) => Milestone.fromJson(m))
          .toList();
    }

    // Parse next milestone
    NextMilestone? nextMile;
    if (json['nextMilestone'] != null) {
      nextMile = NextMilestone.fromJson(json['nextMilestone']);
    }

    return EmployeeActiveProjectModel(
      id: json['_id'] ?? '',
      projectId: json['projectId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      budgetType: json['budgetType'] ?? 'FIXED',
      minBudget: (json['minBudget'] ?? 0).toDouble(),
      maxBudget: (json['maxBudget'] ?? 0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      deliverables: List<String>.from(json['deliverables'] ?? []),
      employerId: json['employerId'] ?? '',
      employerName: json['employerName'] ?? 'Client',
      employerLogo: json['employerLogo'],
      employerSnapshot: json['employerSnapshot'] ?? {},
      employeeId: json['employeeId'] ?? '',
      contractId: json['contractId'] ?? '',
      contractNumber: json['contractNumber'] ?? '',
      contractStatus: json['contractStatus'] ?? '',
      signedAt: json['signedAt'] != null ? DateTime.tryParse(json['signedAt']) : null,
      milestones: milestonesList,
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      lastPaymentAt: json['lastPaymentAt'] != null ? DateTime.tryParse(json['lastPaymentAt']) : null,
      totalMilestones: json['totalMilestones'] ?? 0,
      completedMilestones: json['completedMilestones'] ?? 0,
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      nextMilestone: nextMile,
      hiredAt: DateTime.tryParse(json['hiredAt'] ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      lastActivityAt: json['lastActivityAt'] != null ? DateTime.tryParse(json['lastActivityAt']) : null,
      expectedEndDate: json['expectedEndDate'] != null ? DateTime.tryParse(json['expectedEndDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'experienceLevel': experienceLevel,
      'budgetType': budgetType,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'skills': skills,
      'deliverables': deliverables,
      'employerId': employerId,
      'employerName': employerName,
      'employerLogo': employerLogo,
      'employerSnapshot': employerSnapshot,
      'employeeId': employeeId,
      'contractId': contractId,
      'contractNumber': contractNumber,
      'contractStatus': contractStatus,
      'signedAt': signedAt?.toIso8601String(),
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'totalBudget': totalBudget,
      'totalPaid': totalPaid,
      'remainingAmount': remainingAmount,
      'lastPaymentAt': lastPaymentAt?.toIso8601String(),
      'totalMilestones': totalMilestones,
      'completedMilestones': completedMilestones,
      'progressPercentage': progressPercentage,
      'nextMilestone': nextMilestone?.toJson(),
      'hiredAt': hiredAt.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'expectedEndDate': expectedEndDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status,
    };
  }
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime? dueDate;
  final String status;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? fundedAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? releasedAt;
  final String? paymentIntentId;
  final String? walletTransactionId;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    this.dueDate,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.fundedAt,
    this.submittedAt,
    this.approvedAt,
    this.releasedAt,
    this.paymentIntentId,
    this.walletTransactionId,
  });

  // Helper getters
  bool get isPending => status == 'PENDING';
  bool get isFunded => status == 'FUNDED';
  bool get isSubmitted => status == 'SUBMITTED';
  bool get isApproved => status == 'APPROVED';
  bool get isReleased => status == 'RELEASED';
  bool get isCompleted => status == 'APPROVED' || status == 'RELEASED';

  Color get statusColor {
    switch (status) {
      case 'PENDING':
        return Colors.grey;
      case 'FUNDED':
        return Colors.blue;
      case 'SUBMITTED':
        return Colors.orange;
      case 'APPROVED':
        return Colors.purple;
      case 'RELEASED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'FUNDED':
        return 'Ready to Start';
      case 'SUBMITTED':
        return 'Submitted';
      case 'APPROVED':
        return 'Approved';
      case 'RELEASED':
        return 'Payment Released';
      default:
        return status;
    }
  }

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      fundedAt: json['fundedAt'] != null ? DateTime.tryParse(json['fundedAt']) : null,
      submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt']) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.tryParse(json['approvedAt']) : null,
      releasedAt: json['releasedAt'] != null ? DateTime.tryParse(json['releasedAt']) : null,
      paymentIntentId: json['paymentIntentId'],
      walletTransactionId: json['walletTransactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'fundedAt': fundedAt?.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'releasedAt': releasedAt?.toIso8601String(),
      'paymentIntentId': paymentIntentId,
      'walletTransactionId': walletTransactionId,
    };
  }
}

class NextMilestone {
  final String milestoneId;
  final String title;
  final double amount;
  final String status;

  NextMilestone({
    required this.milestoneId,
    required this.title,
    required this.amount,
    required this.status,
  });

  bool get isReady => status == 'FUNDED';

  factory NextMilestone.fromJson(Map<String, dynamic> json) {
    return NextMilestone(
      milestoneId: json['milestoneId'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'milestoneId': milestoneId,
      'title': title,
      'amount': amount,
      'status': status,
    };
  }
}
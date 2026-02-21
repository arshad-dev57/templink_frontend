import 'package:flutter/material.dart';

// ==================== REQUEST MODELS (For Sending Proposals) ====================

class AttachedFile {
  final String fileName;
  final String fileUrl;
  String? id; // Added for response parsing

  AttachedFile({
    required this.fileName,
    required this.fileUrl,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
    };
  }

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      id: json['_id']?.toString(),
    );
  }
}

class PortfolioProject {
  final String portfolioId;
  final String title;
  final String description;
  final String imageUrl;
  final String completionDate;

  PortfolioProject({
    required this.portfolioId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.completionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'portfolioId': portfolioId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'completionDate': completionDate,
    };
  }

  factory PortfolioProject.fromJson(Map<String, dynamic> json) {
    return PortfolioProject(
      portfolioId: json['portfolioId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      completionDate: json['completionDate'] ?? '',
    );
  }
}

class ProposalRequest {
  final String projectId;
  final String coverLetter;
  final String paymentMethod;
  final double fixedPrice;
  final int projectDuration;
  final List<AttachedFile> attachedFiles;
  final List<PortfolioProject> selectedPortfolioProjects;

  ProposalRequest({
    required this.projectId,
    required this.coverLetter,
    required this.paymentMethod,
    required this.fixedPrice,
    required this.projectDuration,
    required this.attachedFiles,
    required this.selectedPortfolioProjects,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'coverLetter': coverLetter,
      'paymentMethod': paymentMethod,
      'fixedPrice': fixedPrice,
      'projectDuration': projectDuration,
      'attachedFiles': attachedFiles.map((file) => file.toJson()).toList(),
      'selectedPortfolioProjects':
          selectedPortfolioProjects.map((project) => project.toJson()).toList(),
    };
  }
}

class   ProposalResponse {
  final bool success;
  final String? message;
  final String? proposalId;
  final Map<String, dynamic>? data;

  ProposalResponse({
    required this.success,
    this.message,
    this.proposalId,
    this.data,
  });

  factory ProposalResponse.fromJson(Map<String, dynamic> json) {
    return ProposalResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      proposalId: json['proposalId']?.toString(),
      data: json['data'],
    );
  }
}

// ==================== RESPONSE MODELS (For Viewing Proposals) ====================

// Project Employer Snapshot Model
class ProjectEmployerSnapshot {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String companyName;
  final String logoUrl;
  final String industry;
  final String city;
  final String employerCountry;
  final String companySize;
  final String workModel;
  final String phone;
  final String companyEmail;
  final String website;
  final String linkedin;
  final String about;
  final String mission;
  final List<String> cultureTags;
  final List<dynamic> teamMembers;
  final bool isVerifiedEmployer;
  final double rating;
  final String sizeLabel;

  ProjectEmployerSnapshot({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.companyName,
    required this.logoUrl,
    required this.industry,
    required this.city,
    required this.employerCountry,
    required this.companySize,
    required this.workModel,
    required this.phone,
    required this.companyEmail,
    required this.website,
    required this.linkedin,
    required this.about,
    required this.mission,
    required this.cultureTags,
    required this.teamMembers,
    required this.isVerifiedEmployer,
    required this.rating,
    required this.sizeLabel,
  });

  factory ProjectEmployerSnapshot.fromJson(Map<String, dynamic> json) {
    return ProjectEmployerSnapshot(
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      employerCountry: json['employerCountry']?.toString() ?? '',
      companySize: json['companySize']?.toString() ?? '',
      workModel: json['workModel']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      companyEmail: json['companyEmail']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      linkedin: json['linkedin']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
      mission: json['mission']?.toString() ?? '',
      cultureTags: (json['cultureTags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      teamMembers: (json['teamMembers'] as List?) ?? [],
      isVerifiedEmployer: json['isVerifiedEmployer'] ?? false,
      rating: _toDouble(json['rating']),
      sizeLabel: json['sizeLabel']?.toString() ?? '',
    );
  }

  // Helper methods
  String get displayName {
    if (companyName.isNotEmpty) return companyName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) return '$firstName $lastName';
    if (firstName.isNotEmpty) return firstName;
    return 'Client';
  }

  String get displayLocation {
    if (city.isNotEmpty && employerCountry.isNotEmpty) {
      return '$city, $employerCountry';
    } else if (city.isNotEmpty) {
      return city;
    } else if (employerCountry.isNotEmpty) {
      return employerCountry;
    } else if (country.isNotEmpty) {
      return country;
    }
    return '';
  }

  String get initials {
    final name = displayName;
    if (name.isEmpty) return 'C';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Safe double conversion helper
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Project Info Model (nested inside proposal)
class ProposalProjectInfo {
  final String id;
  final String title;
  final String duration;
  final double minBudget;
  final double maxBudget;
  final String status;
  final int proposalsCount;
  final ProjectEmployerSnapshot employerSnapshot;

  ProposalProjectInfo({
    required this.id,
    required this.title,
    required this.duration,
    required this.minBudget,
    required this.maxBudget,
    required this.status,
    required this.proposalsCount,
    required this.employerSnapshot,
  });

  factory ProposalProjectInfo.fromJson(Map<String, dynamic> json) {
    return ProposalProjectInfo(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      minBudget: _toDouble(json['minBudget']),
      maxBudget: _toDouble(json['maxBudget']),
      status: json['status']?.toString() ?? 'OPEN',
      proposalsCount: _toInt(json['proposalsCount']),
      employerSnapshot: ProjectEmployerSnapshot.fromJson(json['employerSnapshot'] ?? {}),
    );
  }

  // Safe conversion helpers
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper for UI - convert to int for display
  String get displayBudget {
    final min = minBudget.toInt();
    final max = maxBudget.toInt();
    return '\$$min - \$$max';
  }
}

// Main Proposal Model (for viewing proposals)
class ProposalModel {
  final String id;
  final ProposalProjectInfo project;
  final String employeeId;
  final String coverLetter;
  final String paymentMethod;
  final double fixedPrice;
  final int projectDuration;
  final double serviceFee;
  final double youWillReceive;
  final List<AttachedFile> attachedFiles;
  final List<PortfolioProject> selectedPortfolioProjects;
  final int pointsUsed;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // ✅ Contract status fields
  final String? contractStatus;
  final String? contractId;

  ProposalModel({
    required this.id,
    required this.project,
    required this.employeeId,
    required this.coverLetter,
    required this.paymentMethod,
    required this.fixedPrice,
    required this.projectDuration,
    required this.serviceFee,
    required this.youWillReceive,
    required this.attachedFiles,
    required this.selectedPortfolioProjects,
    required this.pointsUsed,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.contractStatus,
    this.contractId,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    // ✅ Try multiple possible locations for contract data
    String? contractStatus;
    String? contractId;
    
    // Check if contract exists directly in the proposal
    if (json['contract'] != null) {
      contractStatus = json['contract']['status']?.toString();
      contractId = json['contract']['_id']?.toString();
    }
    // Check if contract exists inside projectId
    else if (json['projectId'] != null && json['projectId']['contract'] != null) {
      contractStatus = json['projectId']['contract']['status']?.toString();
      contractId = json['projectId']['contract']['_id']?.toString();
    }
    // Check if there's a separate contract field
    else if (json['contractInfo'] != null) {
      contractStatus = json['contractInfo']['status']?.toString();
      contractId = json['contractInfo']['_id']?.toString();
    }

    return ProposalModel(
      id: json['_id']?.toString() ?? '',
      project: ProposalProjectInfo.fromJson(json['projectId'] ?? {}),
      employeeId: json['employeeId']?.toString() ?? '',
      coverLetter: json['coverLetter']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      fixedPrice: _toDouble(json['fixedPrice']),
      projectDuration: _toInt(json['projectDuration']),
      serviceFee: _toDouble(json['serviceFee']),
      youWillReceive: _toDouble(json['youWillReceive']),
      attachedFiles: (json['attachedFiles'] as List?)
          ?.map((e) => AttachedFile.fromJson(e))
          .toList() ?? [],
      selectedPortfolioProjects: (json['selectedPortfolioProjects'] as List?)
          ?.map((e) => PortfolioProject.fromJson(e))
          .toList() ?? [],
      pointsUsed: _toInt(json['pointsUsed']),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      
      // ✅ Set contract data
      contractStatus: contractStatus,
      contractId: contractId,
    );
  }

  // Safe conversion helpers
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper methods for UI
  String get displayBudget {
    return '\$${fixedPrice.toInt()}';
  }
  
  String get displayDuration => '$projectDuration months';
  
  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks ago';
    return '${difference.inDays ~/ 30} months ago';
  }

  Color get statusColor {
    switch(status) {
      case 'PENDING':
        return Colors.blue;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'WITHDRAWN':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get displayStatus {
    switch(status) {
      case 'PENDING':
        return 'Submitted';
      case 'ACCEPTED':
        return 'Accepted';
      case 'REJECTED':
        return 'Rejected';
      case 'WITHDRAWN':
        return 'Withdrawn';
      default:
        return status;
    }
  }

  String get statusType {
    switch(status) {
      case 'PENDING':
        return 'submitted';
      case 'ACCEPTED':
        return 'accepted';
      case 'REJECTED':
        return 'rejected';
      case 'WITHDRAWN':
        return 'withdrawn';
      default:
        return 'submitted';
    }
  }

  int get matchScore {
    // Calculate match score based on budget range
    if (fixedPrice >= project.minBudget && fixedPrice <= project.maxBudget) {
      return 95;
    } else if (fixedPrice < project.minBudget) {
      return 85;
    } else {
      return 75;
    }
  }

  String get clientName => project.employerSnapshot.displayName;
  String get clientLocation => project.employerSnapshot.displayLocation;
  String get clientInitials => project.employerSnapshot.initials;
  bool get isVerified => project.employerSnapshot.isVerifiedEmployer;

  // ✅ Contract status helpers
  bool get hasContract => contractId != null && contractId!.isNotEmpty;
  
  bool get hasActiveContract {
    return contractStatus == 'ACTIVE';
  }
  
  bool get contractPending {
    return contractStatus == 'PENDING_EMPLOYEE_SIGN' || 
           contractStatus == 'PENDING_EMPLOYER_SIGN' ||
           contractStatus == 'DRAFT';
  }
  
  Color get contractStatusColor {
    switch(contractStatus) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING_EMPLOYEE_SIGN':
      case 'PENDING_EMPLOYER_SIGN':
      case 'DRAFT':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.teal;
      case 'TERMINATED':
        return Colors.red;
      case 'DISPUTED':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String get contractStatusText {
    switch(contractStatus) {
      case 'ACTIVE':
        return 'Active';
      case 'PENDING_EMPLOYEE_SIGN':
        return 'Awaiting Your Signature';
      case 'PENDING_EMPLOYER_SIGN':
        return 'Awaiting Employer';
      case 'DRAFT':
        return 'Ready to Sign';
      case 'COMPLETED':
        return 'Completed';
      case 'TERMINATED':
        return 'Terminated';
      case 'DISPUTED':
        return 'Disputed';
      default:
        return 'No Contract';
    }
  }

  // ✅ Get contract button text
  String get contractButtonText {
    if (!hasContract) return 'Sign Contract';
    if (hasActiveContract) return 'View Contract';
    if (contractPending) return 'Complete Signing';
    return 'View Contract';
  }
}

// API Response Model
class ProposalsResponse {
  final int total;
  final List<ProposalModel> proposals;

  ProposalsResponse({
    required this.total,
    required this.proposals,
  });

  factory ProposalsResponse.fromJson(Map<String, dynamic> json) {
    return ProposalsResponse(
      total: json['total'] ?? 0,
      proposals: (json['proposals'] as List?)
          ?.map((e) => ProposalModel.fromJson(e))
          .toList() ?? [],
    );
  }
}

// ==================== EXTENSION FOR CONVERTING REQUEST TO MODEL ====================

extension ProposalRequestExtension on ProposalRequest {
  ProposalModel toProposalModel({
    required String id,
    required ProposalProjectInfo project,
    required String employeeId,
    required double serviceFee,
    required double youWillReceive,
    required int pointsUsed,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ProposalModel(
      id: id,
      project: project,
      employeeId: employeeId,
      coverLetter: coverLetter,
      paymentMethod: paymentMethod,
      fixedPrice: fixedPrice,
      projectDuration: projectDuration,
      serviceFee: serviceFee,
      youWillReceive: youWillReceive,
      attachedFiles: attachedFiles,
      selectedPortfolioProjects: selectedPortfolioProjects,
      pointsUsed: pointsUsed,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
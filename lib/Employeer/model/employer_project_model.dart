import 'package:flutter/material.dart';

// ==================== ATTACHED FILE MODEL ====================
class AttachedFile {
  final String fileName;
  final String fileUrl;
  final String? id;

  AttachedFile({
    required this.fileName,
    required this.fileUrl,
    this.id,
  });

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
      fileName: json['fileName']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      id: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      '_id': id,
    };
  }
}

// ==================== PORTFOLIO PROJECT MODEL ====================
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

  factory PortfolioProject.fromJson(Map<String, dynamic> json) {
    return PortfolioProject(
      portfolioId: json['portfolioId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      completionDate: json['completionDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolioId': portfolioId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'completionDate': completionDate,
    };
  }
}

// ==================== MILESTONE MODEL ====================
class Milestone {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime? dueDate;
  final String status;
  final DateTime? fundedAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? releasedAt;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    this.dueDate,
    required this.status,
    this.fundedAt,
    this.submittedAt,
    this.approvedAt,
    this.releasedAt,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      status: json['status']?.toString() ?? 'PENDING',
      fundedAt: json['fundedAt'] != null ? DateTime.tryParse(json['fundedAt'].toString()) : null,
      submittedAt: json['submittedAt'] != null ? DateTime.tryParse(json['submittedAt'].toString()) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.tryParse(json['approvedAt'].toString()) : null,
      releasedAt: json['releasedAt'] != null ? DateTime.tryParse(json['releasedAt'].toString()) : null,
    );
  }

  // Helper methods
  Color get statusColor {
    switch(status) {
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

  String get displayStatus {
    switch(status) {
      case 'PENDING':
        return 'Pending';
      case 'FUNDED':
        return 'Funded';
      case 'SUBMITTED':
        return 'Submitted';
      case 'APPROVED':
        return 'Approved';
      case 'RELEASED':
        return 'Released';
      default:
        return status;
    }
  }

  bool get isPending => status == 'PENDING';
  bool get isFunded => status == 'FUNDED';
  bool get isSubmitted => status == 'SUBMITTED';
  bool get isApproved => status == 'APPROVED';
  bool get isReleased => status == 'RELEASED';
  bool get isCompleted => status == 'APPROVED' || status == 'RELEASED';
}

// Employee Profile Model
class EmployeeProfile {
  final String experienceLevel;
  final String goal;
  final String category;
  final String subcategory;
  final List<String> skills;
  final String title;
  final String bio;
  final String hourlyRate;
  final String photoUrl;
  final String dateOfBirth;
  final String streetAddress;
  final String city;
  final String province;
  final String phoneNumber;
  final List<dynamic> workExperiences;
  final List<dynamic> educations;
  final List<PortfolioProject> portfolioProjects;
  final double rating;
  final int totalReviews;

  EmployeeProfile({
    required this.experienceLevel,
    required this.goal,
    required this.category,
    required this.subcategory,
    required this.skills,
    required this.title,
    required this.bio,
    required this.hourlyRate,
    required this.photoUrl,
    required this.dateOfBirth,
    required this.streetAddress,
    required this.city,
    required this.province,
    required this.phoneNumber,
    required this.workExperiences,
    required this.educations,
    required this.portfolioProjects,
    required this.rating,
    required this.totalReviews,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    List<PortfolioProject> portfolioList = [];
    if (json['portfolioProjects'] is List) {
      portfolioList = (json['portfolioProjects'] as List)
          .map((item) => PortfolioProject.fromJson(item))
          .toList();
    }

    return EmployeeProfile(
      experienceLevel: json['experienceLevel']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      subcategory: json['subcategory']?.toString() ?? '',
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      title: json['title']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      hourlyRate: json['hourlyRate']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      streetAddress: json['streetAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      workExperiences: json['workExperiences'] as List? ?? [],
      educations: json['educations'] as List? ?? [],
      portfolioProjects: portfolioList,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}

// Employer Profile Model
class EmployerProfile {
  final String companyName;
  final String logoUrl;
  final String industry;
  final String city;
  final String country;
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

  EmployerProfile({
    required this.companyName,
    required this.logoUrl,
    required this.industry,
    required this.city,
    required this.country,
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

  factory EmployerProfile.fromJson(Map<String, dynamic> json) {
    return EmployerProfile(
      companyName: json['companyName']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      companySize: json['companySize']?.toString() ?? '',
      workModel: json['workModel']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      companyEmail: json['companyEmail']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      linkedin: json['linkedin']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
      mission: json['mission']?.toString() ?? '',
      cultureTags: (json['cultureTags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      teamMembers: json['teamMembers'] as List? ?? [],
      isVerifiedEmployer: json['isVerifiedEmployer'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      sizeLabel: json['sizeLabel']?.toString() ?? '',
    );
  }
}

// Employee User Model
class EmployeeUser {
  final String id;
  final String role;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final bool sendEmails;
  final bool termsAccepted;
  final String status;
  final EmployeeProfile employeeProfile;
  final EmployerProfile employerProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pointsBalance;
  final bool linkedinConnected;

  EmployeeUser({
    required this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.sendEmails,
    required this.termsAccepted,
    required this.status,
    required this.employeeProfile,
    required this.employerProfile,
    required this.createdAt,
    required this.updatedAt,
    required this.pointsBalance,
    required this.linkedinConnected,
  });

  factory EmployeeUser.fromJson(Map<String, dynamic> json) {
    return EmployeeUser(
      id: json['_id']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      sendEmails: json['sendEmails'] ?? false,
      termsAccepted: json['termsAccepted'] ?? false,
      status: json['status']?.toString() ?? '',
      employeeProfile: EmployeeProfile.fromJson(json['employeeProfile'] ?? {}),
      employerProfile: EmployerProfile.fromJson(json['employerProfile'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      pointsBalance: json['pointsBalance'] ?? 0,
      linkedinConnected: json['linkedinConnected'] ?? false,
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : email;
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'E';
  }
}

// ==================== UPDATED PROJECT PROPOSAL MODEL WITH CONTRACT STATUS ====================
class ProjectProposal {
  final String id;
  final String coverLetter;
  final int fixedPrice;
  final int projectDuration;
  final String status;
  final DateTime createdAt;
  final EmployeeUser employee;
  
  // ✅ NEW FIELDS
  final List<AttachedFile> attachedFiles;
  final List<PortfolioProject> selectedPortfolioProjects;
  
  // ✅ CONTRACT STATUS FIELDS
  final String? contractStatus;
  final String? contractId;

  ProjectProposal({
    required this.id,
    required this.coverLetter,
    required this.fixedPrice,
    required this.projectDuration,
    required this.status,
    required this.createdAt,
    required this.employee,
    required this.attachedFiles,
    required this.selectedPortfolioProjects,
    this.contractStatus,
    this.contractId,
  });

  factory ProjectProposal.fromJson(Map<String, dynamic> json) {
    // Parse attached files
    List<AttachedFile> attachedList = [];
    if (json['attachedFiles'] is List) {
      attachedList = (json['attachedFiles'] as List)
          .map((item) => AttachedFile.fromJson(item))
          .toList();
    }

    // Parse selected portfolio projects
    List<PortfolioProject> portfolioList = [];
    if (json['selectedPortfolioProjects'] is List) {
      portfolioList = (json['selectedPortfolioProjects'] as List)
          .map((item) => PortfolioProject.fromJson(item))
          .toList();
    }

    // ✅ Parse contract data
    String? contractStatus;
    String? contractId;
    
    if (json['contract'] != null) {
      contractStatus = json['contract']['status']?.toString();
      contractId = json['contract']['_id']?.toString();
    } else if (json['contractId'] != null) {
      contractId = json['contractId']?.toString();
    }

    return ProjectProposal(
      id: json['_id']?.toString() ?? '',
      coverLetter: json['coverLetter']?.toString() ?? '',
      fixedPrice: json['fixedPrice'] ?? 0,
      projectDuration: json['projectDuration'] ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      employee: EmployeeUser.fromJson(json['employee'] ?? {}),
      attachedFiles: attachedList,
      selectedPortfolioProjects: portfolioList,
      contractStatus: contractStatus,
      contractId: contractId,
    );
  }

  // Helper methods
  Color get statusColor {
    switch(status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'WITHDRAWN':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String get displayStatus {
    switch(status) {
      case 'PENDING':
        return 'Pending Review';
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

  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks ago';
    return '${difference.inDays ~/ 30} months ago';
  }

  // ✅ Helper getters for new fields
  bool get hasAttachedFiles => attachedFiles.isNotEmpty;
  bool get hasPortfolioProjects => selectedPortfolioProjects.isNotEmpty;
  
  // ✅ CONTRACT STATUS HELPERS
  bool get hasContract => contractId != null && contractId!.isNotEmpty;
  
  bool get hasActiveContract => contractStatus == 'ACTIVE';
  
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
        return Colors.orange;
      case 'PENDING_EMPLOYER_SIGN':
        return Colors.orange;
      case 'DRAFT':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.teal;
      case 'TERMINATED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get contractStatusText {
    switch(contractStatus) {
      case 'ACTIVE':
        return 'Active';
      case 'PENDING_EMPLOYEE_SIGN':
        return 'Awaiting Employee Signature';
      case 'PENDING_EMPLOYER_SIGN':
        return 'Awaiting Your Signature';
      case 'DRAFT':
        return 'Ready to Sign';
      case 'COMPLETED':
        return 'Completed';
      case 'TERMINATED':
        return 'Terminated';
      default:
        return 'No Contract';
    }
  }
}

// Employer Snapshot Model
class EmployerSnapshot {
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
  final int proposalsCount;
  final int interviewingCount;
  final int invitesCount;
  final String status;
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

  EmployerSnapshot({
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
    required this.proposalsCount,
    required this.interviewingCount,
    required this.invitesCount,
    required this.status,
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

  factory EmployerSnapshot.fromJson(Map<String, dynamic> json) {
    return EmployerSnapshot(
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
      proposalsCount: json['proposalsCount'] ?? 0,
      interviewingCount: json['interviewingCount'] ?? 0,
      invitesCount: json['invitesCount'] ?? 0,
      status: json['status']?.toString() ?? 'OPEN',
      phone: json['phone']?.toString() ?? '',
      companyEmail: json['companyEmail']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      linkedin: json['linkedin']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
      mission: json['mission']?.toString() ?? '',
      cultureTags: (json['cultureTags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      teamMembers: json['teamMembers'] as List? ?? [],
      isVerifiedEmployer: json['isVerifiedEmployer'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      sizeLabel: json['sizeLabel']?.toString() ?? '',
    );
  }

  String get displayName {
    if (companyName.isNotEmpty) return companyName;
    if (firstName.isNotEmpty && lastName.isNotEmpty) return '$firstName $lastName';
    if (firstName.isNotEmpty) return firstName;
    return 'Client';
  }
}

// Project Media Model
class ProjectMedia {
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String publicId;
  final String id;

  ProjectMedia({
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.publicId,
    required this.id,
  });

  factory ProjectMedia.fromJson(Map<String, dynamic> json) {
    return ProjectMedia(
      fileName: json['fileName']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      fileType: json['fileType']?.toString() ?? '',
      publicId: json['publicId']?.toString() ?? '',
      id: json['_id']?.toString() ?? '',
    );
  }
}

// ==================== MAIN EMPLOYER PROJECT MODEL WITH MILESTONES ====================
class EmployerProject {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String experienceLevel;
  final String budgetType;
  final int minBudget;
  final int maxBudget;
  final List<String> skills;
  final List<String> deliverables;
  final List<ProjectMedia> media;
  final String postedBy;
  final EmployerSnapshot employerSnapshot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int proposalsCount;
  final List<ProjectProposal> proposals;
  final String Status;
  final List<Milestone> milestones;

  EmployerProject({
    required this.Status,
    required this.id,
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
    required this.media,
    required this.postedBy,
    required this.employerSnapshot,
    required this.createdAt,
    required this.updatedAt,
    required this.proposalsCount,
    required this.proposals,
    required this.milestones,
  });

  factory EmployerProject.fromJson(Map<String, dynamic> json) {
    // Parse milestones
    List<Milestone> milestonesList = [];
    if (json['milestones'] is List) {
      milestonesList = (json['milestones'] as List)
          .map((item) => Milestone.fromJson(item))
          .toList();
    }

    // Parse proposals
    List<ProjectProposal> proposalsList = [];
    if (json['proposals'] is List) {
      proposalsList = (json['proposals'] as List)
          .map((item) => ProjectProposal.fromJson(item))
          .toList();
    }

    return EmployerProject(
      id: json['_id']?.toString() ?? '',
      Status: json['status']?.toString() ?? "",
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      experienceLevel: json['experienceLevel']?.toString() ?? '',
      budgetType: json['budgetType']?.toString() ?? '',
      minBudget: json['minBudget'] ?? 0,
      maxBudget: json['maxBudget'] ?? 0,
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      deliverables: (json['deliverables'] as List?)?.map((e) => e.toString()).toList() ?? [],
      media: (json['media'] as List?)?.map((e) => ProjectMedia.fromJson(e)).toList() ?? [],
      postedBy: json['postedBy']?.toString() ?? '',
      employerSnapshot: EmployerSnapshot.fromJson(json['employerSnapshot'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      proposalsCount: json['proposalsCount'] ?? 0,
      proposals: proposalsList,
      milestones: milestonesList,
    );
  }

  // Helper methods
  String get displayBudget => '\$$minBudget - \$$maxBudget';
  
  String get displayDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks ago';
    return '${difference.inDays ~/ 30} months ago';
  }

  int get pendingProposals => proposals.where((p) => p.status == 'PENDING').length;
  int get acceptedProposals => proposals.where((p) => p.status == 'ACCEPTED').length;
  int get rejectedProposals => proposals.where((p) => p.status == 'REJECTED').length;

  // Milestone helper methods
  bool get hasMilestones => milestones.isNotEmpty;
  int get milestoneCount => milestones.length;
  
  double get totalMilestoneAmount => milestones.fold(0, (sum, m) => sum + m.amount);
  
  List<Milestone> get pendingMilestones => milestones.where((m) => m.status == 'PENDING').toList();
  List<Milestone> get fundedMilestones => milestones.where((m) => m.status == 'FUNDED').toList();
  List<Milestone> get submittedMilestones => milestones.where((m) => m.status == 'SUBMITTED').toList();
  List<Milestone> get approvedMilestones => milestones.where((m) => m.status == 'APPROVED').toList();
  List<Milestone> get releasedMilestones => milestones.where((m) => m.status == 'RELEASED').toList();
  List<Milestone> get completedMilestones => milestones.where((m) => m.isCompleted).toList();
  
  Milestone? get nextPendingMilestone {
    try {
      return milestones.firstWhere((m) => m.status == 'PENDING');
    } catch (e) {
      return null;
    }
  }
  
  double get totalPaidAmount {
    return milestones
        .where((m) => m.isCompleted)
        .fold(0, (sum, m) => sum + m.amount);
  }
  
  double get remainingAmount => maxBudget - totalPaidAmount;
  
  double get progressPercentage {
    if (maxBudget == 0) return 0;
    return totalPaidAmount / maxBudget;
  }
}

// API Response Model
class EmployerProjectsResponse {
  final int total;
  final List<EmployerProject> projects;

  EmployerProjectsResponse({
    required this.total,
    required this.projects,
  });

  factory EmployerProjectsResponse.fromJson(Map<String, dynamic> json) {
    List<EmployerProject> projectsList = [];
    if (json['projects'] is List) {
      projectsList = (json['projects'] as List)
          .map((e) => EmployerProject.fromJson(e))
          .toList();
    }

    return EmployerProjectsResponse(
      total: json['total'] ?? 0,
      projects: projectsList,
    );
  }
}
import 'package:flutter/material.dart';

// ✅ Milestone Model
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
}

class EmployerSnapshot {
  final String userId;
  
  // User fields
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  
  // EmployerProfile fields
  final String companyName;
  final String logoUrl;
  final String industry;
  final String city;
  final String employerCountry;
  final String companySize;
  final String workModel;
  
  // New fields from schema
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
      userId: (json['userId'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      companyName: (json['companyName'] ?? '').toString(),
      logoUrl: (json['logoUrl'] ?? '').toString(),
      industry: (json['industry'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      employerCountry: (json['employerCountry'] ?? '').toString(),
      companySize: (json['companySize'] ?? '').toString(),
      workModel: (json['workModel'] ?? '').toString(),
      proposalsCount: json['proposalsCount'] ?? 0,
      interviewingCount: json['interviewingCount'] ?? 0,
      invitesCount: json['invitesCount'] ?? 0,
      status: (json['status'] ?? 'OPEN').toString(),
      phone: (json['phone'] ?? '').toString(),
      companyEmail: (json['companyEmail'] ?? '').toString(),
      website: (json['website'] ?? '').toString(),
      linkedin: (json['linkedin'] ?? '').toString(),
      about: (json['about'] ?? '').toString(),
      mission: (json['mission'] ?? '').toString(),
      cultureTags: (json['cultureTags'] is List)
          ? (json['cultureTags'] as List).map((e) => e.toString()).toList()
          : [],
      teamMembers: (json['teamMembers'] is List)
          ? json['teamMembers'] as List
          : [],
      isVerifiedEmployer: json['isVerifiedEmployer'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      sizeLabel: (json['sizeLabel'] ?? '').toString(),
    );
  }

  String get fullName => '$firstName $lastName'.trim();
  
  String get displayCompany {
    if (companyName.isNotEmpty) return companyName;
    if (fullName.isNotEmpty) return fullName;
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
    final name = displayCompany;
    if (name.isEmpty) return 'C';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  bool get isOpen => status == 'OPEN';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';

  String get displayStatus {
    switch(status) {
      case 'OPEN':
        return 'Open';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Open';
    }
  }

  Color get statusColor {
    switch(status) {
      case 'OPEN':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.purple;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Media Model
class ProjectMedia {
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String? publicId;

  ProjectMedia({
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.publicId,
  });

  factory ProjectMedia.fromJson(Map<String, dynamic> json) {
    return ProjectMedia(
      fileName: (json['fileName'] ?? 'Unknown File').toString(),
      fileUrl: (json['fileUrl'] ?? '').toString(),
      fileType: (json['fileType'] ?? '').toString(),
      publicId: json['publicId']?.toString(),
    );
  }
}
class ProjectFeedModel {
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
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // ✅ New: Milestones list
  final List<Milestone> milestones;
  
  final int? topLevelProposalsCount;
  final bool featured;
  final EmployerSnapshot? employerSnapshot;

  ProjectFeedModel({
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
    this.createdAt,
    this.updatedAt,
    // ✅ New parameter
    required this.milestones,
    this.topLevelProposalsCount,
    this.featured = false,
    this.employerSnapshot,
  });

  factory ProjectFeedModel.fromJson(Map<String, dynamic> json) {
    // Parse media array
    List<ProjectMedia> mediaList = [];
    if (json['media'] is List) {
      mediaList = (json['media'] as List)
          .map((item) => ProjectMedia.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    // ✅ Parse milestones array
    List<Milestone> milestonesList = [];
    if (json['milestones'] is List) {
      milestonesList = (json['milestones'] as List)
          .map((item) => Milestone.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return ProjectFeedModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'Other').toString(),
      duration: (json['duration'] ?? '3-6 months').toString(),
      experienceLevel: (json['experienceLevel'] ?? 'Intermediate').toString(),
      budgetType: (json['budgetType'] ?? 'FIXED').toString(),
      minBudget: json['minBudget'] ?? 0,
      maxBudget: json['maxBudget'] ?? 0,
      skills: (json['skills'] is List)
          ? (json['skills'] as List).map((e) => e.toString()).toList()
          : [],
      deliverables: (json['deliverables'] is List)
          ? (json['deliverables'] as List).map((e) => e.toString()).toList()
          : [],
      media: mediaList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      // ✅ Add milestones
      milestones: milestonesList,
      topLevelProposalsCount: json['proposalsCount'],
      featured: json['featured'] ?? false,
      employerSnapshot: json['employerSnapshot'] != null
          ? EmployerSnapshot.fromJson(json['employerSnapshot'])
          : null,
    );
  }

  // Helper Methods
  String get displayClientName {
    if (employerSnapshot != null && employerSnapshot!.displayCompany.isNotEmpty) {
      return employerSnapshot!.displayCompany;
    }
    return 'Client';
  }

  bool get isVerified => employerSnapshot?.isVerifiedEmployer ?? false;
  
  String? get logoUrl => employerSnapshot?.logoUrl;
  
  String get displayBudget {
    if (budgetType == 'HOURLY') {
      return '\$$minBudget - \$$maxBudget/hr';
    }
    return '\$$minBudget - \$$maxBudget';
  }
  
  String get displayPostedDate {
    if (createdAt == null) return 'Recently';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    return '${diff.inDays ~/ 30} months ago';
  }

  String get clientLocation => employerSnapshot?.displayLocation ?? '';
  double get clientRating => employerSnapshot?.rating ?? 0;
  String get clientSize => employerSnapshot?.sizeLabel ?? '';
  String get clientAbout => employerSnapshot?.about ?? '';
  List<String> get clientCultureTags => employerSnapshot?.cultureTags ?? [];

  // Helper methods for counts
  int get proposalsCount => employerSnapshot?.proposalsCount ?? topLevelProposalsCount ?? 0;
  int get interviewingCount => employerSnapshot?.interviewingCount ?? 0;
  int get invitesCount => employerSnapshot?.invitesCount ?? 0;
  
  // ✅ Milestone helpers
  int get milestoneCount => milestones.length;
  double get totalMilestoneAmount => milestones.fold(0, (sum, m) => sum + m.amount);
  bool get hasMilestones => milestones.isNotEmpty;
  
  List<Milestone> get pendingMilestones => milestones.where((m) => m.status == 'PENDING').toList();
  List<Milestone> get fundedMilestones => milestones.where((m) => m.status == 'FUNDED').toList();
  List<Milestone> get submittedMilestones => milestones.where((m) => m.status == 'SUBMITTED').toList();
  List<Milestone> get approvedMilestones => milestones.where((m) => m.status == 'APPROVED').toList();
  List<Milestone> get releasedMilestones => milestones.where((m) => m.status == 'RELEASED').toList();

  String get displayProposalsCount {
    if (proposalsCount == 0) return 'No proposals yet';
    if (proposalsCount == 1) return '1 proposal';
    return '$proposalsCount proposals';
  }
  
  String get displayInterviewingCount {
    if (interviewingCount == 0) return 'No interviews';
    if (interviewingCount == 1) return '1 interviewing';
    return '$interviewingCount interviewing';
  }
  
  String get displayInvitesCount {
    if (invitesCount == 0) return 'No invites sent';
    if (invitesCount == 1) return '1 invite sent';
    return '$invitesCount invites sent';
  }

  String get projectStatus => employerSnapshot?.displayStatus ?? 'Open';
  Color get projectStatusColor => employerSnapshot?.statusColor ?? Colors.grey;
  bool get isProjectOpen => employerSnapshot?.isOpen ?? true;
  bool get isProjectInProgress => employerSnapshot?.isInProgress ?? false;
  bool get isProjectCompleted => employerSnapshot?.isCompleted ?? false;
  bool get isProjectCancelled => employerSnapshot?.isCancelled ?? false;
}
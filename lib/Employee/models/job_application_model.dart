class EmployeeApplication {
  final String id;
  final String jobId;
  final String employeeId;
  final String employerId;
  final String status;
  final String coverLetter;
  final DateTime appliedAt;
  final DateTime updatedAt;
    final String employmentStatus; // 'active', 'left', 'terminated'
  final DateTime? leftAt;
  final String? leftReason;
  
  // Resume fields
  final String resumeFileName;
  final String resumeFileUrl;
  final String? resumeCloudinaryPublicId;
  final int? resumeFileSize;
  
  // Snapshots
  final JobSnapshot jobSnapshot;
  final EmployerSnapshot employerSnapshot;
  final EmployeeSnapshot employeeSnapshot;
  
  EmployeeApplication({
        this.employmentStatus = 'active',
    this.leftAt,
    this.leftReason,
    required this.id,
    required this.jobId,
    required this.employeeId,
    required this.employerId,
    required this.status,
    required this.coverLetter,
    required this.appliedAt,
    required this.updatedAt,
    required this.resumeFileName,
    required this.resumeFileUrl,
    this.resumeCloudinaryPublicId,
    this.resumeFileSize,
    required this.jobSnapshot,
    required this.employerSnapshot,
    required this.employeeSnapshot,
  });

  factory EmployeeApplication.fromJson(Map<String, dynamic> json) {
    return EmployeeApplication(
      id: json['_id'] ?? '',
         employmentStatus: json['employmentStatus'] ?? 'active',
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      leftReason: json['leftReason'],
      jobId: json['jobId']?['_id'] ?? json['jobId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employerId: json['employerId'] ?? '',
      status: json['status'] ?? 'pending',
      coverLetter: json['coverLetter'] ?? '',
      appliedAt: json['appliedAt'] != null 
          ? DateTime.parse(json['appliedAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      resumeFileName: json['resumeFileName'] ?? '',
      resumeFileUrl: json['resumeFileUrl'] ?? '',
      resumeCloudinaryPublicId: json['resumeCloudinaryPublicId'],
      resumeFileSize: json['resumeFileSize'],
      jobSnapshot: JobSnapshot.fromJson(json['jobSnapshot'] ?? {}),
      employerSnapshot: EmployerSnapshot.fromJson(json['employerSnapshot'] ?? {}),
      employeeSnapshot: EmployeeSnapshot.fromJson(json['employeeSnapshot'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'jobId': jobId,
      'employeeId': employeeId,
      'employerId': employerId,
      'status': status,
      'coverLetter': coverLetter,
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resumeFileName': resumeFileName,
      'resumeFileUrl': resumeFileUrl,
      'resumeCloudinaryPublicId': resumeCloudinaryPublicId,
      'resumeFileSize': resumeFileSize,
      'jobSnapshot': jobSnapshot.toJson(),
      'employerSnapshot': employerSnapshot.toJson(),
      'employeeSnapshot': employeeSnapshot.toJson(),
    };
  }
}

class JobSnapshot {
  final String title;
  final String company;
  final String workplace;
  final String location;
  final String type;
  final String about;
  final String requirements;
  final String qualifications;
  final DateTime? postedDate;

  JobSnapshot({
    required this.title,
    required this.company,
    required this.workplace,
    required this.location,
    required this.type,
    required this.about,
    required this.requirements,
    required this.qualifications,
    this.postedDate,
  });

  factory JobSnapshot.fromJson(Map<String, dynamic> json) {
    return JobSnapshot(
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      workplace: json['workplace'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      about: json['about'] ?? '',
      requirements: json['requirements'] ?? '',
      qualifications: json['qualifications'] ?? '',
      postedDate: json['postedDate'] != null 
          ? DateTime.parse(json['postedDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'company': company,
      'workplace': workplace,
      'location': location,
      'type': type,
      'about': about,
      'requirements': requirements,
      'qualifications': qualifications,
      'postedDate': postedDate?.toIso8601String(),
    };
  }
}

class EmployerSnapshot {
  final String companyName;
  final String logoUrl;
  final String industry;
  final String city;
  final String country;

  EmployerSnapshot({
    required this.companyName,
    required this.logoUrl,
    required this.industry,
    required this.city,
    required this.country,
  });

  factory EmployerSnapshot.fromJson(Map<String, dynamic> json) {
    return EmployerSnapshot(
      companyName: json['companyName'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      industry: json['industry'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'logoUrl': logoUrl,
      'industry': industry,
      'city': city,
      'country': country,
    };
  }
}

class EmployeeSnapshot {
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String title;
  final String experienceLevel;
  final String category;
  final List<String> skills;
  final String hourlyRate;
  final String photoUrl;
  final String bio;
  final double rating;
  final int totalReviews;

  EmployeeSnapshot({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.title,
    required this.experienceLevel,
    required this.category,
    required this.skills,
    required this.hourlyRate,
    required this.photoUrl,
    required this.bio,
    required this.rating,
    required this.totalReviews,
  });

  factory EmployeeSnapshot.fromJson(Map<String, dynamic> json) {
    return EmployeeSnapshot(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      country: json['country'] ?? '',
      title: json['title'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      category: json['category'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      hourlyRate: json['hourlyRate'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      bio: json['bio'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'country': country,
      'title': title,
      'experienceLevel': experienceLevel,
      'category': category,
      'skills': skills,
      'hourlyRate': hourlyRate,
      'photoUrl': photoUrl,
      'bio': bio,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
}

class ApplicationSummary {
  final int total;
  final int pending;
  final int reviewed;
  final int shortlisted;
  final int rejected;
  final int hired;

  ApplicationSummary({
    required this.total,
    required this.pending,
    required this.reviewed,
    required this.shortlisted,
    required this.rejected,
    required this.hired,
  });

  factory ApplicationSummary.fromJson(Map<String, dynamic> json) {
    return ApplicationSummary(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      reviewed: json['reviewed'] ?? 0,
      shortlisted: json['shortlisted'] ?? 0,
      rejected: json['rejected'] ?? 0,
      hired: json['hired'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'pending': pending,
      'reviewed': reviewed,
      'shortlisted': shortlisted,
      'rejected': rejected,
      'hired': hired,
    };
  }
}
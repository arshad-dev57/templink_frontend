class EmployerJobApplication {
  final String id;
  final String jobId;
  final String employeeId;
  final String employerId;
  final String status;
  final String coverLetter;
  final DateTime appliedAt;
  final DateTime updatedAt;
  
  // Employment status fields
  final String employmentStatus; // 'active', 'left', 'terminated'
  final DateTime? leftAt;
  final String? leftReason;
  
  // Hiring Commission fields
  final HiringCommission? hiringCommission;
  final DateTime? hiredAt;
  
  // Resume fields
  final String resumeFileName;
  final String resumeFileUrl;
  final String? resumeCloudinaryPublicId;
  final int? resumeFileSize;
  
  // Snapshots
  final JobSnapshot jobSnapshot;
  final EmployeeSnapshot employeeSnapshot;
  final EmployerSnapshot employerSnapshot;
  
  EmployerJobApplication({
    required this.id,
    required this.jobId,
    required this.employeeId,
    required this.employerId,
    required this.status,
    required this.coverLetter,
    required this.appliedAt,
    required this.updatedAt,
    this.employmentStatus = 'active',
    this.leftAt,
    this.leftReason,
    this.hiringCommission,
    this.hiredAt,
    required this.resumeFileName,
    required this.resumeFileUrl,
    this.resumeCloudinaryPublicId,
    this.resumeFileSize,
    required this.jobSnapshot,
    required this.employeeSnapshot,
    required this.employerSnapshot,
  });

  factory EmployerJobApplication.fromJson(Map<String, dynamic> json) {
    return EmployerJobApplication(
      id: json['_id'] ?? '',
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
      employmentStatus: json['employmentStatus'] ?? 'active',
      leftAt: json['leftAt'] != null 
          ? DateTime.parse(json['leftAt']) 
          : null,
      leftReason: json['leftReason'],
      hiringCommission: json['hiringCommission'] != null
          ? HiringCommission.fromJson(json['hiringCommission'])
          : null,
      hiredAt: json['hiredAt'] != null
          ? DateTime.parse(json['hiredAt'])
          : null,
      resumeFileName: json['resumeFileName'] ?? '',
      resumeFileUrl: json['resumeFileUrl'] ?? '',
      resumeCloudinaryPublicId: json['resumeCloudinaryPublicId'],
      resumeFileSize: json['resumeFileSize'],
      jobSnapshot: JobSnapshot.fromJson(json['jobSnapshot'] ?? {}),
      employeeSnapshot: EmployeeSnapshot.fromJson(json['employeeSnapshot'] ?? {}),
      employerSnapshot: EmployerSnapshot.fromJson(json['employerSnapshot'] ?? {}),
    );
  }
}

// ============== HIRING COMMISSION MODEL ==============
class HiringCommission {
  final int salaryAmount;
  final int commissionAmount;
  final int commissionRate;
  final String paymentStatus; // 'pending', 'paid', 'free_hire_protection'
  final DateTime? paidAt;
  final String? paymentId;
  final bool isFreeHire;

  HiringCommission({
    required this.salaryAmount,
    required this.commissionAmount,
    required this.commissionRate,
    required this.paymentStatus,
    this.paidAt,
    this.paymentId,
    required this.isFreeHire,
  });

  factory HiringCommission.fromJson(Map<String, dynamic> json) {
    return HiringCommission(
      salaryAmount: json['salaryAmount'] ?? 0,
      commissionAmount: json['commissionAmount'] ?? 0,
      commissionRate: json['commissionRate'] ?? 20,
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'])
          : null,
      paymentId: json['paymentId'],
      isFreeHire: json['isFreeHire'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salaryAmount': salaryAmount,
      'commissionAmount': commissionAmount,
      'commissionRate': commissionRate,
      'paymentStatus': paymentStatus,
      'paidAt': paidAt?.toIso8601String(),
      'paymentId': paymentId,
      'isFreeHire': isFreeHire,
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
  
  // 👇 YAHAN SALARY AMOUNT ADD KIYA
  final int salaryAmount;
  final String salaryCurrency;
  final String salaryPeriod; // 'hourly', 'monthly', 'yearly'

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
    // 👇 Salary fields with defaults
    this.salaryAmount = 0,
    this.salaryCurrency = 'USD',
    this.salaryPeriod = 'monthly',
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
      // 👇 Salary fields parse karo
      salaryAmount: json['salaryAmount'] ?? 0,
      salaryCurrency: json['salaryCurrency'] ?? 'USD',
      salaryPeriod: json['salaryPeriod'] ?? 'monthly',
    );
  }

  // Helper method to format salary
  String get formattedSalary {
    if (salaryAmount <= 0) return 'Not specified';
    
    String period = '';
    switch (salaryPeriod) {
      case 'hourly':
        period = '/hr';
        break;
      case 'monthly':
        period = '/mo';
        break;
      case 'yearly':
        period = '/yr';
        break;
    }
    
    return '$salaryCurrency ${_formatNumber(salaryAmount)}$period';
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
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
  final List<RecentExperience> recentExperiences;
  final RecentEducation? recentEducation;

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
    required this.recentExperiences,
    this.recentEducation,
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
      recentExperiences: (json['recentExperiences'] as List? ?? [])
          .map((e) => RecentExperience.fromJson(e))
          .toList(),
      recentEducation: json['recentEducation'] != null
          ? RecentEducation.fromJson(json['recentEducation'])
          : null,
    );
  }
}

class RecentExperience {
  final String title;
  final String company;
  final String startYear;
  final String endYear;

  RecentExperience({
    required this.title,
    required this.company,
    required this.startYear,
    required this.endYear,
  });

  factory RecentExperience.fromJson(Map<String, dynamic> json) {
    return RecentExperience(
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      startYear: json['startYear'] ?? '',
      endYear: json['endYear'] ?? '',
    );
  }
}

class RecentEducation {
  final String degree;
  final String school;
  final String field;

  RecentEducation({
    required this.degree,
    required this.school,
    required this.field,
  });

  factory RecentEducation.fromJson(Map<String, dynamic> json) {
    return RecentEducation(
      degree: json['degree'] ?? '',
      school: json['school'] ?? '',
      field: json['field'] ?? '',
    );
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
}
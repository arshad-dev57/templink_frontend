// models/hired_employee_model.dart
class HiredEmployeeResponse {
  final bool success;
  final Summary summary;
  final Pagination pagination;
  final List<HiredEmployee> data;

  HiredEmployeeResponse({
    required this.success,
    required this.summary,
    required this.pagination,
    required this.data,
  });

  factory HiredEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return HiredEmployeeResponse(
      success: json['success'] ?? false,
      summary: Summary.fromJson(json['summary'] ?? {}),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      data: (json['data'] as List? ?? [])
          .map((e) => HiredEmployee.fromJson(e))
          .toList(),
    );
  }
}

class Summary {
  final int total;
  final int active;
  final int left;
  final int terminated;

  Summary({
    required this.total,
    required this.active,
    required this.left,
    required this.terminated,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      left: json['left'] ?? 0,
      terminated: json['terminated'] ?? 0,
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int? nextPage;
  final int? prevPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPrevPage,
    this.nextPage,
    this.prevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
      nextPage: json['nextPage'],
      prevPage: json['prevPage'],
    );
  }
}

class HiredEmployee {
  final String employeeId;
  final String jobId;
  final String applicationId;
  final String jobTitle;
  final DateTime hiredAt;
  final String status;
  final DateTime? leftAt;
  final String? leftReason;
  final int commissionPaid;
  final bool isFreeHire;
  final EmployeeDetails employeeDetails;

  HiredEmployee({
    required this.employeeId,
    required this.jobId,
    required this.applicationId,
    required this.jobTitle,
    required this.hiredAt,
    required this.status,
    this.leftAt,
    this.leftReason,
    required this.commissionPaid,
    required this.isFreeHire,
    required this.employeeDetails,
  });

  factory HiredEmployee.fromJson(Map<String, dynamic> json) {
    return HiredEmployee(
      employeeId: json['employeeId'] ?? '',
      jobId: json['jobId'] ?? '',
      applicationId: json['applicationId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      hiredAt: DateTime.parse(json['hiredAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'unknown',
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt']) : null,
      leftReason: json['leftReason'],
      commissionPaid: json['commissionPaid'] ?? 0,
      isFreeHire: json['isFreeHire'] ?? false,
      employeeDetails: EmployeeDetails.fromJson(json['employeeDetails'] ?? {}),
    );
  }
}

class EmployeeDetails {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final EmployeeProfile employeeProfile;

  EmployeeDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.employeeProfile,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeDetails(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      employeeProfile: EmployeeProfile.fromJson(json['employeeProfile'] ?? {}),
    );
  }

  String get fullName => '$firstName $lastName';
}

class EmployeeProfile {
  final String experienceLevel;
  final String category;
  final List<String> skills;
  final String title;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final String bio;
  final String hourlyRate;
  final String photoUrl;
  final List<dynamic> portfolioProjects;
  final double rating;
  final int totalReviews;

  EmployeeProfile({
    required this.experienceLevel,
    required this.category,
    required this.skills,
    required this.title,
    required this.workExperiences,
    required this.educations,
    required this.bio,
    required this.hourlyRate,
    required this.photoUrl,
    required this.portfolioProjects,
    required this.rating,
    required this.totalReviews,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      experienceLevel: json['experienceLevel'] ?? '',
      category: json['category'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      title: json['title'] ?? '',
      workExperiences: (json['workExperiences'] as List? ?? [])
          .map((e) => WorkExperience.fromJson(e))
          .toList(),
      educations: (json['educations'] as List? ?? [])
          .map((e) => Education.fromJson(e))
          .toList(),
      bio: json['bio'] ?? '',
      hourlyRate: json['hourlyRate'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      portfolioProjects: json['portfolioProjects'] ?? [],
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}

class WorkExperience {
  final String title;
  final String company;
  final String location;
  final String country;
  final String startYear;
  final String endYear;
  final bool currentlyWorking;
  final String description;

  WorkExperience({
    required this.title,
    required this.company,
    required this.location,
    required this.country,
    required this.startYear,
    required this.endYear,
    required this.currentlyWorking,
    required this.description,
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      country: json['country'] ?? '',
      startYear: json['startYear'] ?? '',
      endYear: json['endYear'] ?? '',
      currentlyWorking: json['currentlyWorking'] ?? false,
      description: json['description'] ?? '',
    );
  }
}

class Education {
  final String school;  
  final String degree;
  final String field;
  final String startYear;
  final String endYear;
  final bool currentlyAttending;
  final String description;

  Education({
    required this.school,
    required this.degree,
    required this.field,
    required this.startYear,
    required this.endYear,
    required this.currentlyAttending,
    required this.description,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      school: json['school'] ?? '',
      degree: json['degree'] ?? '',
      field: json['field'] ?? '',
      startYear: json['startYear'] ?? '',
      endYear: json['endYear'] ?? '',
      currentlyAttending: json['currentlyAttending'] ?? false,
      description: json['description'] ?? '',
    );
  }
}
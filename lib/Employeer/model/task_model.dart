class TaskModel {
  final String id;
  final String title;
  final String description;
  final String employerId;
  final String employeeId;
  final String jobId;
  final String? applicationId;
  final String priority;
  final String status;
  final DateTime dueDate;
  final double estimatedHours;
  final double actualHours;
  final DateTime? completedAt;
  final List<Attachment> attachments;
  final List<Comment> comments;
  final FeedbackData? employerFeedback;
  final FeedbackData? employeeFeedback;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Populated fields
  final EmployeeDetails? employeeDetails;
  final JobDetails? jobDetails;
  final EmployerDetails? employerDetails;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.employerId,
    required this.employeeId,
    required this.jobId,
    this.applicationId,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.estimatedHours,
    required this.actualHours,
    this.completedAt,
    required this.attachments,
    required this.comments,
    this.employerFeedback,
    this.employeeFeedback,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.employeeDetails,
    this.jobDetails,
    this.employerDetails,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      employerId: json['employerId']?['_id'] ?? json['employerId'] ?? '',
      employeeId: json['employeeId']?['_id'] ?? json['employeeId'] ?? '',
      jobId: json['jobId']?['_id'] ?? json['jobId'] ?? '',
      applicationId: json['applicationId'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      dueDate: DateTime.parse(json['dueDate']),
      estimatedHours: (json['estimatedHours'] ?? 0).toDouble(),
      actualHours: (json['actualHours'] ?? 0).toDouble(),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      attachments: (json['attachments'] as List?)?.map((e) => Attachment.fromJson(e)).toList() ?? [],
      comments: (json['comments'] as List?)?.map((e) => Comment.fromJson(e)).toList() ?? [],
      employerFeedback: json['employerFeedback'] != null ? FeedbackData.fromJson(json['employerFeedback']) : null,
      employeeFeedback: json['employeeFeedback'] != null ? FeedbackData.fromJson(json['employeeFeedback']) : null,
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      employeeDetails: json['employeeId'] != null && json['employeeId'] is Map ? EmployeeDetails.fromJson(json['employeeId']) : null,
      jobDetails: json['jobId'] != null && json['jobId'] is Map ? JobDetails.fromJson(json['jobId']) : null,
      employerDetails: json['employerId'] != null && json['employerId'] is Map ? EmployerDetails.fromJson(json['employerId']) : null,
    );
  }

  bool get isOverdue {
    if (status == 'completed' || status == 'cancelled') return false;
    return DateTime.now().isAfter(dueDate);
  }

  int get daysRemaining {
    if (status == 'completed' || status == 'cancelled') return 0;
    return dueDate.difference(DateTime.now()).inDays;
  }
}

class Attachment {
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final DateTime uploadedAt;

  Attachment({
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}

class Comment {
  final String userId;
  final String userRole;
  final String comment;
  final DateTime createdAt;
  final UserInfo? user;

  Comment({
    required this.userId,
    required this.userRole,
    required this.comment,
    required this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId']?['_id'] ?? json['userId'] ?? '',
      userRole: json['userRole'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      user: json['userId'] != null && json['userId'] is Map ? UserInfo.fromJson(json['userId']) : null,
    );
  }
}

class FeedbackData {
  final int rating;
  final String comment;
  final DateTime? givenAt;

  FeedbackData({
    required this.rating,
    required this.comment,
    this.givenAt,
  });

  factory FeedbackData.fromJson(Map<String, dynamic> json) {
    return FeedbackData(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      givenAt: json['givenAt'] != null ? DateTime.parse(json['givenAt']) : null,
    );
  }
}

class EmployeeDetails {
  final String id;
  final String firstName;
  final String lastName;
  final String? title;
  final String? photoUrl;

  EmployeeDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.title,
    this.photoUrl,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeDetails(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      title: json['employeeProfile']?['title'],
      photoUrl: json['employeeProfile']?['photoUrl'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class JobDetails {
  final String id;
  final String title;

  JobDetails({
    required this.id,
    required this.title,
  });

  factory JobDetails.fromJson(Map<String, dynamic> json) {
    return JobDetails(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class EmployerDetails {
  final String id;
  final String firstName;
  final String lastName;
  final String? companyName;

  EmployerDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.companyName,
  });

  factory EmployerDetails.fromJson(Map<String, dynamic> json) {
    return EmployerDetails(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      companyName: json['employerProfile']?['companyName'],
    );
  }

  String get displayName => companyName ?? '$firstName $lastName';
}

class UserInfo {
  final String id;
  final String firstName;
  final String lastName;

  UserInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}
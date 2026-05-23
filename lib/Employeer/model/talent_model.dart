// 📁 lib/Employer/models/talent_model.dart
import 'package:flutter/material.dart';

// ✅ Work Experience Model
class WorkExperience {
  final String id;
  final String title;
  final String company;
  final String location;
  final String country;
  final String startYear;
  final String endYear;
  final bool currentlyWorking;
  final String description;

  WorkExperience({
    this.id = '',
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
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      startYear: json['startYear']?.toString() ?? '',
      endYear: json['endYear']?.toString() ?? '',
      currentlyWorking: json['currentlyWorking'] ?? false,
      description: json['description']?.toString() ?? '',
    );
  }

  String get duration {
    if (currentlyWorking) {
      return '$startYear - Present';
    }
    if (endYear.isNotEmpty && startYear.isNotEmpty) {
      return '$startYear - $endYear';
    }
    return startYear;
  }
}

// ✅ Education Model
class Education {
  final String id;
  final String school;
  final String degree;
  final String field;
  final String startYear;
  final String endYear;
  final bool currentlyAttending;
  final String description;

  Education({
    this.id = '',
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
      id: json['_id']?.toString() ?? '',
      school: json['school']?.toString() ?? '',
      degree: json['degree']?.toString() ?? '',
      field: json['field']?.toString() ?? '',
      startYear: json['startYear']?.toString() ?? '',
      endYear: json['endYear']?.toString() ?? '',
      currentlyAttending: json['currentlyAttending'] ?? false,
      description: json['description']?.toString() ?? '',
    );
  }

  String get degreeDisplay {
    if (degree.isNotEmpty && field.isNotEmpty) {
      return '$degree in $field';
    } else if (degree.isNotEmpty) {
      return degree;
    } else if (field.isNotEmpty) {
      return field;
    }
    return '';
  }

  String get duration {
    if (currentlyAttending) {
      return '$startYear - Present';
    }
    if (endYear.isNotEmpty && startYear.isNotEmpty) {
      return '$startYear - $endYear';
    }
    return startYear;
  }
}

// ✅ Portfolio Project Model - UPDATED to read from images array
class PortfolioProject {
  final String id;
  final String title;
  final String description;
  final String imageUrl;  // Will contain first image from images array
  final List<Map<String, dynamic>> images;
  final String category;
  final String completionDate;
  final String clientName;
  final String projectUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PortfolioProject({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.images,
    required this.category,
    required this.completionDate,
    required this.clientName,
    required this.projectUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioProject.fromJson(Map<String, dynamic> json) {
    // ✅ Parse images array
    List<Map<String, dynamic>> imagesList = [];
    if (json['images'] is List) {
      for (var img in json['images']) {
        if (img is Map) {
          imagesList.add(Map<String, dynamic>.from(img));
        }
      }
    }
    
    // ✅ Get first image URL from images array
    String firstImageUrl = '';
    
    // First check if there's a direct imageUrl
    if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      firstImageUrl = json['imageUrl'].toString();
    }
    // If not, get first image from images array
    else if (imagesList.isNotEmpty) {
      final firstImage = imagesList.first;
      if (firstImage.containsKey('url')) {
        firstImageUrl = firstImage['url']?.toString() ?? '';
      } else if (firstImage.containsKey('imageUrl')) {
        firstImageUrl = firstImage['imageUrl']?.toString() ?? '';
      }
    }
    
    return PortfolioProject(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: firstImageUrl,
      images: imagesList,
      category: json['category']?.toString() ?? '',
      completionDate: json['completionDate']?.toString() ?? '',
      clientName: json['clientName']?.toString() ?? '',
      projectUrl: json['projectUrl']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  bool get hasImage => imageUrl.isNotEmpty;
  bool get hasMultipleImages => images.length > 1;
  bool get hasProjectUrl => projectUrl.isNotEmpty;
  
  // ✅ Get all image URLs
  List<String> get allImageUrls {
    final urls = <String>[];
    if (imageUrl.isNotEmpty) urls.add(imageUrl);
    for (var img in images) {
      final url = img['url']?.toString();
      if (url != null && url.isNotEmpty && !urls.contains(url)) urls.add(url);
    }
    return urls;
  }
}

// ✅ Main Talent Model
class TalentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final DateTime? createdAt;
  
  // Profile Fields
  final String title;
  final String bio;
  final List<String> skills;
  final String experienceLevel;
  final String category;
  final String hourlyRate;
  final String photoUrl;
  final double rating;
  final int totalReviews;
  final String availability;
  
  // Arrays
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final List<PortfolioProject> portfolioProjects;

  TalentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    this.createdAt,
    required this.title,
    required this.bio,
    required this.skills,
    required this.experienceLevel,
    required this.category,
    required this.hourlyRate,
    required this.photoUrl,
    required this.rating,
    required this.totalReviews,
    required this.availability,
    required this.workExperiences,
    required this.educations,
    required this.portfolioProjects,
  });

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['employeeProfile'] as Map<String, dynamic>? ?? {};
    
    // Work experiences
    final List<WorkExperience> workExps = [];
    if (profile['workExperiences'] is List) {
      for (var exp in profile['workExperiences']) {
        workExps.add(WorkExperience.fromJson(exp));
      }
    }
    
    // Educations
    final List<Education> eduList = [];
    if (profile['educations'] is List) {
      for (var edu in profile['educations']) {
        eduList.add(Education.fromJson(edu));
      }
    }
    
    // Portfolio projects - UPDATED to handle images array
    final List<PortfolioProject> projects = [];
    if (profile['portfolioProjects'] is List) {
      final projectsList = profile['portfolioProjects'] as List;
      for (var project in projectsList) {
        projects.add(PortfolioProject.fromJson(project));
      }
    }
    
    // Skills
    List<String> skillsList = [];
    if (profile['skills'] is List) {
      skillsList = List<String>.from(profile['skills']);
    }
    
    return TalentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      title: profile['title']?.toString() ?? '',
      bio: profile['bio']?.toString() ?? '',
      skills: skillsList,
      experienceLevel: profile['experienceLevel']?.toString() ?? '',
      category: profile['category']?.toString() ?? '',
      hourlyRate: profile['hourlyRate']?.toString() ?? '',
      photoUrl: profile['photoUrl']?.toString() ?? '',
      rating: (profile['rating'] ?? 0).toDouble(),
      totalReviews: profile['totalReviews']?.toInt() ?? 0,
      availability: profile['availability']?.toString() ?? '',
      workExperiences: workExps,
      educations: eduList,
      portfolioProjects: projects,
    );
  }

  // ✅ Helper getters
  String get fullName => '$firstName $lastName';
  
  String get hourlyRateDisplay => hourlyRate.isEmpty ? '' : '\$$hourlyRate/hr';
  
  String get ratingDisplay => rating > 0 ? rating.toStringAsFixed(1) : '';
  
  String get location => country;
  
  int get completedProjects => portfolioProjects.length;
  
  bool get hasPortfolio => portfolioProjects.isNotEmpty;
  
  bool get hasWorkExperience => workExperiences.isNotEmpty;
  
  bool get hasEducation => educations.isNotEmpty;
  
  // ✅ Availability badge text
  String get availabilityBadge {
    switch (availability) {
      case 'AVAILABLE_NOW':
        return 'AVAILABLE NOW';
      case 'AVAILABLE_IN_WEEK':
        return 'AVAILABLE IN 1 WEEK';
      case 'AVAILABLE_IN_MONTH':
        return 'AVAILABLE IN 1 MONTH';
      case 'NOT_AVAILABLE':
        return 'NOT AVAILABLE';
      default:
        return '';
    }
  }
  
  // ✅ Availability badge color
  Color get availabilityBadgeColor {
    switch (availability) {
      case 'AVAILABLE_NOW':
        return Colors.green;
      case 'AVAILABLE_IN_WEEK':
        return Colors.orange;
      case 'AVAILABLE_IN_MONTH':
        return Colors.blue;
      case 'NOT_AVAILABLE':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }
  
  // ✅ Check if talent is available
  bool get isAvailableNow => availability == 'AVAILABLE_NOW';
  
  // ✅ First project image - UPDATED to work with images array
  String get firstProjectImage {
    if (portfolioProjects.isNotEmpty) {
      final firstProject = portfolioProjects.first;
      
      // First try to get from imageUrl (now populated from images array)
      if (firstProject.imageUrl.isNotEmpty) {
        return firstProject.imageUrl;
      }
      
      // If still empty, try to get from images array directly
      if (firstProject.images.isNotEmpty) {
        final imgUrl = firstProject.images.first['url']?.toString();
        if (imgUrl != null && imgUrl.isNotEmpty) {
          return imgUrl;
        }
      }
    }
    
    // Fallback to Unsplash placeholder
    return 'https://images.unsplash.com/photo-15812915';
  }
  
  // ✅ Recent 3 projects
  List<PortfolioProject> get recentProjects {
    if (portfolioProjects.length <= 3) return portfolioProjects;
    return portfolioProjects.sublist(0, 3);
  }
  
  // ✅ First 5 skills
  List<String> get displaySkills {
    if (skills.length <= 5) return skills;
    return skills.sublist(0, 5);
  }
  
  // ✅ Recent work experience
  WorkExperience? get recentWorkExperience {
    return workExperiences.isNotEmpty ? workExperiences.first : null;
  }
  
  // ✅ Color generate karo (UI ke liye)
  Color get bgColor {
    final colors = [
      const Color(0xFFFFD6A5),
      const Color(0xFFE5B299),
      const Color(0xFFB4E4E0),
      const Color(0xFFFFB4A2),
      const Color(0xFFE8F0FE),
      const Color(0xFFFFD966),
      const Color(0xFFD5E8D4),
      const Color(0xFFFADADD),
      const Color(0xFFD4E6F1),
      const Color(0xFFEAD7D1),
    ];
    
    int hash = 0;
    for (int i = 0; i < id.length; i++) {
      hash = ((hash << 5) - hash) + id.codeUnitAt(i);
      hash = hash & hash;
    }
    
    final index = hash.abs() % colors.length;
    return colors[index];
  }
}
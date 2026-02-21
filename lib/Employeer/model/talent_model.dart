// 📁 lib/Employer/models/talent_model.dart
import 'package:flutter/material.dart';
class TalentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final Map<String, dynamic> employeeProfile;
  final DateTime? createdAt;

  TalentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.country,
    required this.employeeProfile,
    this.createdAt,
  });

  factory TalentModel.fromJson(Map<String, dynamic> json) {
    return TalentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      employeeProfile: json['employeeProfile'] is Map
          ? Map<String, dynamic>.from(json['employeeProfile'])
          : {},
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  // ✅ Helper methods for UI
  String get fullName => '$firstName $lastName'.trim();
  
  String get title => employeeProfile['title'] ?? 'Professional';
  
  List<String> get skills {
    final skills = employeeProfile['skills'];
    if (skills is List) {
      return skills.map((e) => e.toString()).toList();
    }
    return [];
  }
  
  String get hourlyRate {
    final rate = employeeProfile['hourlyRate'];
    if (rate != null && rate.toString().isNotEmpty) {
      return '\$$rate/hr';
    }
    return 'Not specified';
  }
  
  String get photoUrl => employeeProfile['photoUrl'] ?? '';
  
  String get rating {
    final rate = employeeProfile['rating'];
    if (rate != null) {
      return rate.toStringAsFixed(1);
    }
    return '5.0';
  }
  
  String get availability => employeeProfile['availability'] ?? '';
  
  String get badge {
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
  
  Color get badgeColor {
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
  
  String get projectImage {
    final portfolioImages = employeeProfile['portfolioImages'];
    if (portfolioImages is List && portfolioImages.isNotEmpty) {
      return portfolioImages[0].toString();
    }
    
    final portfolioProjects = employeeProfile['portfolioProjects'];
    if (portfolioProjects is List && portfolioProjects.isNotEmpty) {
      final firstProject = portfolioProjects[0];
      if (firstProject is Map && firstProject['imageUrl'] != null) {
        return firstProject['imageUrl'].toString();
      }
    }
    
    // Default images based on category
    final category = employeeProfile['category'] ?? '';
    return _getDefaultImage(category);
  }
  
  String _getDefaultImage(String category) {
    final defaultImages = {
      'Development': 'https://images.unsplash.com/photo-1498050108023-c5249f4df085',
      'Design': 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d',
      'Marketing': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f',
      'Writing': 'https://images.unsplash.com/photo-1455390582262-044cdead277a',
      'Data Science': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71',
      'Mobile': 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c',
    };
    return defaultImages[category] ?? defaultImages['Development']!;
  }
  
  String get location {
    final city = employeeProfile['city'];
    if (city != null && city.toString().isNotEmpty) {
      return '$city, $country';
    }
    return country;
  }
  
  int get completedProjects => employeeProfile['completedProjects'] ?? 0;
  
  String get experienceLevel => employeeProfile['experienceLevel'] ?? '';
  
  // ✅ Generate consistent color based on ID
  Color get bgColor {
    final colors = [
      const Color(0xFFFFD6A5), // Peach
      const Color(0xFFE5B299), // Tan
      const Color(0xFFB4E4E0), // Mint
      const Color(0xFFFFB4A2), // Coral
      const Color(0xFFE8F0FE), // Light Blue
      const Color(0xFFFFD966), // Yellow
      const Color(0xFFD5E8D4), // Light Green
      const Color(0xFFFADADD), // Light Pink
      const Color(0xFFD4E6F1), // Sky Blue
      const Color(0xFFEAD7D1), // Rose
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
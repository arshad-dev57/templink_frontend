// lib/Employeer/models/rating_model.dart
import 'package:flutter/material.dart';

class Rating {
  final String id;
  final String projectId;
  final String employerId;
  final String employeeId;
  final int rating;
  final String review;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.projectId,
    required this.employerId,
    required this.employeeId,
    required this.rating,
    required this.review,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['_id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      employerId: json['employerId']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      review: json['review'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'projectId': projectId,
      'employerId': employerId,
      'employeeId': employeeId,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
class ProjectModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String experienceLevel;
  final String budgetType;
  final double minBudget;
  final double maxBudget;
  final List<String> skills;
  final List<String> deliverables;
  final List<MediaFile> media;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProjectModel({
    this.id,
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
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      experienceLevel: json['experienceLevel'] ?? '',
      budgetType: json['budgetType'] ?? 'FIXED',
      minBudget: (json['minBudget'] ?? 0).toDouble(),
      maxBudget: (json['maxBudget'] ?? 0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      deliverables: List<String>.from(json['deliverables'] ?? []),
      media: (json['media'] as List? ?? [])
          .map((m) => MediaFile.fromJson(m))
          .toList(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'experienceLevel': experienceLevel,
      'budgetType': budgetType,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'skills': skills,
      'deliverables': deliverables,
      'media': media.map((m) => m.toJson()).toList(),
    };
  }
}

class MediaFile {
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String? publicId;

  MediaFile({
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.publicId,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? json['filePath'] ?? '',
      fileType: json['fileType'] ?? '',
      publicId: json['publicId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'publicId': publicId,
    };
  }
}
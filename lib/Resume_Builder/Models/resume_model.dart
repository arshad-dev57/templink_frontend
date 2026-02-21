class ResumeModel {
  String id;
  String templateId;
  PersonalInfo personalInfo;
  List<Experience> experiences;
  List<Education> educations;
  List<String> skills;
  String summary;
  List<Language> languages;
  List<SocialLink> socialLinks;
  DateTime createdAt;
  DateTime updatedAt;

  ResumeModel({
    required this.id,
    required this.templateId,
    required this.personalInfo,
    required this.experiences,
    required this.educations,
    required this.skills,
    required this.summary,
    required this.languages,
    required this.socialLinks,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'templateId': templateId,
    'personalInfo': personalInfo.toJson(),
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'educations': educations.map((e) => e.toJson()).toList(),
    'skills': skills,
    'summary': summary,
    'languages': languages.map((l) => l.toJson()).toList(),
    'socialLinks': socialLinks.map((l) => l.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class PersonalInfo {
  String firstName;
  String lastName;
  String profession;
  String city;
  String zipCode;
  String province;
  String phone;
  String email;
  String? profileImage;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.profession,
    required this.city,
    required this.zipCode,
    required this.province,
    required this.phone,
    required this.email,
    this.profileImage,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'profession': profession,
    'city': city,
    'zipCode': zipCode,
    'province': province,
    'phone': phone,
    'email': email,
    'profileImage': profileImage,
  };
}

class Experience {
  String title;
  String company;
  String location;
  bool isRemote;
  DateTime startDate;
  DateTime? endDate;
  bool isCurrent;
  String description;
  List<String> achievements;

  Experience({
    required this.title,
    required this.company,
    required this.location,
    required this.isRemote,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.description,
    required this.achievements,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'company': company,
    'location': location,
    'isRemote': isRemote,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isCurrent': isCurrent,
    'description': description,
    'achievements': achievements,
  };
}

class Education {
  String institution;
  String degree;
  String fieldOfStudy;
  DateTime graduationDate;
  double? gpa;

  Education({
    required this.institution,
    required this.degree,
    required this.fieldOfStudy,
    required this.graduationDate,
    this.gpa,
  });

  Map<String, dynamic> toJson() => {
    'institution': institution,
    'degree': degree,
    'fieldOfStudy': fieldOfStudy,
    'graduationDate': graduationDate.toIso8601String(),
    'gpa': gpa,
  };
}

class Language {
  String name;
  String proficiency;

  Language({
    required this.name,
    required this.proficiency,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'proficiency': proficiency,
  };
}

class SocialLink {
  String type;
  String url;

  SocialLink({
    required this.type,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
  };
}
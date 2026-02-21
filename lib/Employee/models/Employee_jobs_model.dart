// Employee/models/Employee_jobs_model.dart

class JobPostModel {
  final String id;
  final String title;
  final String company;
  final String workplace;
  final String location;
  final String type;
  final String about;
  final String requirements;
  final String qualifications;
  final List<String> images;
  final DateTime? postedDate;
  final bool urgency; // ✅ ADDED: urgency field

  final EmployerSnapshot? employerSnapshot;

  JobPostModel({
    required this.id,
    required this.title,
    required this.company,
    required this.workplace,
    required this.location,
    required this.type,
    required this.about,
    required this.requirements,
    required this.qualifications,
    required this.images,
    required this.postedDate,
    this.urgency = false, // ✅ DEFAULT VALUE
    this.employerSnapshot,
  });

  factory JobPostModel.fromJson(Map<String, dynamic> json) {
    return JobPostModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      company: (json['company'] ?? '').toString(),
      workplace: (json['workplace'] ?? 'Remote').toString(),
      location: (json['location'] ?? 'Remote').toString(),
      type: (json['type'] ?? 'Full Time').toString(),
      about: (json['about'] ?? json['description'] ?? '').toString(),
      requirements: (json['requirements'] ?? '').toString(),
      qualifications: (json['qualifications'] ?? '').toString(),
      images: (json['images'] is List)
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : <String>[],
      postedDate: json['postedDate'] != null 
          ? DateTime.tryParse(json['postedDate'].toString()) 
          : DateTime.now(),
      urgency: json['urgency'] ?? false, // ✅ PARSE URGENCY
      employerSnapshot: json['employerSnapshot'] != null
          ? EmployerSnapshot.fromJson(json['employerSnapshot'])
          : null,
    );
  }

  // ============== 🚀 HELPER METHODS FOR UI ==============

  /// ✅ Company name display - pehle snapshot se, nahi to company field se
  String get displayCompanyName {
    if (employerSnapshot != null && employerSnapshot!.displayCompany.isNotEmpty) {
      return employerSnapshot!.displayCompany;
    }
    return company.isNotEmpty ? company : 'Company';
  }
  
  /// ✅ Logo URL - snapshot se
  String? get logoUrl => employerSnapshot?.logoUrl;
  
  /// ✅ Verified employer check
  bool get isVerified => employerSnapshot?.isVerifiedEmployer ?? false;
  
  /// ✅ Location - pehle snapshot se, nahi to job location se
  String get employerLocation {
    if (employerSnapshot?.displayLocation.isNotEmpty == true) {
      return employerSnapshot!.displayLocation;
    }
    return location.isNotEmpty ? location : 'Remote';
  }
  
  /// ✅ Salary (abhi empty, backend se add karna ho to)
  String get displaySalary => ''; // TODO: Add salary field to model if needed
  
  /// ✅ Workplace type
  String get displayWorkplace => workplace.isNotEmpty ? workplace : 'Remote';
  
  /// ✅ Job type
  String get displayJobType => type.isNotEmpty ? type : 'Full Time';
  
  /// ✅ About job
  String get displayAbout => about.isNotEmpty ? about : 'No job description provided.';
  
  /// ✅ Requirements
  String get displayRequirements => requirements.isNotEmpty 
      ? requirements 
      : '• No specific requirements listed.\n• Contact employer for details.';
  
  /// ✅ Qualifications
  String get displayQualifications => qualifications.isNotEmpty 
      ? qualifications 
      : '• No qualifications specified.\n• Apply to discuss your profile.';
  
  /// ✅ Posted date in readable format
  String get displayPostedDate {
    if (postedDate == null) return 'Recently';
    final diff = DateTime.now().difference(postedDate!);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} weeks ago';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30} months ago';
    return '${diff.inDays ~/ 365} years ago';
  }

  /// ✅ Company initials for logo placeholder
  String get companyInitials {
    final name = displayCompanyName;
    if (name.isEmpty || name == 'Company') return 'CO';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// ✅ Tags for UI (workplace + type)
  List<String> get displayTags {
    final tags = <String>[
      displayWorkplace,
      displayJobType,
    ].where((e) => e.trim().isNotEmpty).toList();
    return tags.isEmpty ? ['Hiring'] : tags;
  }

  /// ✅ Employer full name
  String get employerFullName => employerSnapshot?.fullName ?? '';
  
  /// ✅ Employer about/description
  String get employerAbout => employerSnapshot?.about ?? '';
  
  /// ✅ Employer mission
  String get employerMission => employerSnapshot?.mission ?? '';
  
  /// ✅ Employer culture tags
  List<String> get employerCultureTags => employerSnapshot?.cultureTags ?? [];
  
  /// ✅ Employer rating
  double get employerRating => employerSnapshot?.rating ?? 0;
  
  /// ✅ Employer size label
  String get employerSizeLabel => employerSnapshot?.sizeLabel ?? '';
  
  /// ✅ Has employer snapshot?
  bool get hasEmployerSnapshot => employerSnapshot != null;
}

// ✅ EmployerSnapshot Model (complete with all fields)
class EmployerSnapshot {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String companyName;
  final String logoUrl;
  final String industry;
  final String city;
  final String employerCountry;
  final String companySize;
  final String workModel;
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
  
  String get displayCompany => companyName.isNotEmpty ? companyName : '$fullName\'s Company';
  
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
    return 'Remote';
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
}
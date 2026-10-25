// lib/Models/crm_models.dart

class CrmTeamMember {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String title;

  CrmTeamMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.title,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory CrmTeamMember.fromJson(Map<String, dynamic> json) {
    return CrmTeamMember(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'employee',
      title: json['title']?.toString() ?? 'Team Member',
    );
  }
}

class CrmLead {
  final String id;
  final String leadId;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String jobTitle;
  final String leadSource;
  final String status;
  final String priority;
  final String industry;
  final double estimatedDealValue;
  final String currency;
  final DateTime? expectedClosingDate;
  final String description;
  final bool isConverted;
  final DateTime? convertedAt;
  final CrmTeamMember? assignedTo;
  final DateTime createdAt;

  CrmLead({
    required this.id,
    required this.leadId,
    required this.name,
    this.email = '',
    this.phone = '',
    this.company = '',
    this.jobTitle = '',
    this.leadSource = 'website',
    this.status = 'new',
    this.priority = 'medium',
    this.industry = '',
    this.estimatedDealValue = 0,
    this.currency = 'USD',
    this.expectedClosingDate,
    this.description = '',
    this.isConverted = false,
    this.convertedAt,
    this.assignedTo,
    required this.createdAt,
  });

  factory CrmLead.fromJson(Map<String, dynamic> json) {
    return CrmLead(
      id: json['_id']?.toString() ?? '',
      leadId: json['leadId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      jobTitle: json['jobTitle']?.toString() ?? '',
      leadSource: json['leadSource']?.toString() ?? 'website',
      status: json['status']?.toString() ?? 'new',
      priority: json['priority']?.toString() ?? 'medium',
      industry: json['industry']?.toString() ?? '',
      estimatedDealValue: (json['estimatedDealValue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      expectedClosingDate: json['expectedClosingDate'] != null
          ? DateTime.tryParse(json['expectedClosingDate'].toString())
          : null,
      description: json['description']?.toString() ?? '',
      isConverted: json['isConverted'] == true,
      convertedAt: json['convertedAt'] != null
          ? DateTime.tryParse(json['convertedAt'].toString())
          : null,
      assignedTo: json['assignedTo'] is Map<String, dynamic>
          ? CrmTeamMember.fromJson(json['assignedTo'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmContact {
  final String id;
  final String contactId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String mobilePhone;
  final String jobTitle;
  final String department;
  final String lifecycleStage;
  final String status;
  final String companyId;
  final String companyName;
  final CrmTeamMember? assignedTo;
  final String linkedin;
  final String notes;
  final DateTime createdAt;

  CrmContact({
    required this.id,
    required this.contactId,
    required this.firstName,
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.mobilePhone = '',
    this.jobTitle = '',
    this.department = '',
    this.lifecycleStage = 'lead',
    this.status = 'active',
    this.companyId = '',
    this.companyName = '',
    this.assignedTo,
    this.linkedin = '',
    this.notes = '',
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory CrmContact.fromJson(Map<String, dynamic> json) {
    String compId = '';
    String compName = '';
    if (json['companyId'] is Map<String, dynamic>) {
      compId = json['companyId']['_id']?.toString() ?? '';
      compName = json['companyId']['name']?.toString() ?? '';
    } else if (json['companyId'] != null) {
      compId = json['companyId'].toString();
    }

    return CrmContact(
      id: json['_id']?.toString() ?? '',
      contactId: json['contactId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      mobilePhone: json['mobilePhone']?.toString() ?? '',
      jobTitle: json['jobTitle']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      lifecycleStage: json['lifecycleStage']?.toString() ?? 'lead',
      status: json['status']?.toString() ?? 'active',
      companyId: compId,
      companyName: compName,
      assignedTo: json['assignedTo'] is Map<String, dynamic>
          ? CrmTeamMember.fromJson(json['assignedTo'])
          : null,
      linkedin: json['linkedin']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmCompany {
  final String id;
  final String companyId;
  final String name;
  final String website;
  final String industry;
  final String phone;
  final String email;
  final double annualRevenue;
  final String currency;
  final String employeeCount;
  final String type;
  final String status;
  final String description;
  final CrmTeamMember? assignedTo;
  final DateTime createdAt;

  CrmCompany({
    required this.id,
    required this.companyId,
    required this.name,
    this.website = '',
    this.industry = '',
    this.phone = '',
    this.email = '',
    this.annualRevenue = 0,
    this.currency = 'USD',
    this.employeeCount = '1-10',
    this.type = 'prospect',
    this.status = 'active',
    this.description = '',
    this.assignedTo,
    required this.createdAt,
  });

  factory CrmCompany.fromJson(Map<String, dynamic> json) {
    return CrmCompany(
      id: json['_id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      annualRevenue: (json['annualRevenue'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      employeeCount: json['employeeCount']?.toString() ?? '1-10',
      type: json['type']?.toString() ?? 'prospect',
      status: json['status']?.toString() ?? 'active',
      description: json['description']?.toString() ?? '',
      assignedTo: json['assignedTo'] is Map<String, dynamic>
          ? CrmTeamMember.fromJson(json['assignedTo'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmDeal {
  final String id;
  final String dealId;
  final String title;
  final double amount;
  final String currency;
  final String stage;
  final double probability;
  final DateTime? expectedCloseDate;
  final DateTime? actualCloseDate;
  final String leadSource;
  final String priority;
  final String wonReason;
  final String lostReason;
  final String description;
  final String companyId;
  final String companyName;
  final String contactId;
  final String contactName;
  final CrmTeamMember? assignedTo;
  final DateTime createdAt;

  CrmDeal({
    required this.id,
    required this.dealId,
    required this.title,
    this.amount = 0,
    this.currency = 'USD',
    this.stage = 'lead_in',
    this.probability = 20,
    this.expectedCloseDate,
    this.actualCloseDate,
    this.leadSource = '',
    this.priority = 'medium',
    this.wonReason = '',
    this.lostReason = '',
    this.description = '',
    this.companyId = '',
    this.companyName = '',
    this.contactId = '',
    this.contactName = '',
    this.assignedTo,
    required this.createdAt,
  });

  double get weightedValue => (amount * probability) / 100;

  factory CrmDeal.fromJson(Map<String, dynamic> json) {
    String cId = '';
    String cName = '';
    if (json['companyId'] is Map<String, dynamic>) {
      cId = json['companyId']['_id']?.toString() ?? '';
      cName = json['companyId']['name']?.toString() ?? '';
    } else if (json['companyId'] != null) {
      cId = json['companyId'].toString();
    }

    String ctId = '';
    String ctName = '';
    if (json['contactId'] is Map<String, dynamic>) {
      ctId = json['contactId']['_id']?.toString() ?? '';
      final fn = json['contactId']['firstName']?.toString() ?? '';
      final ln = json['contactId']['lastName']?.toString() ?? '';
      ctName = '$fn $ln'.trim();
    } else if (json['contactId'] != null) {
      ctId = json['contactId'].toString();
    }

    return CrmDeal(
      id: json['_id']?.toString() ?? '',
      dealId: json['dealId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      stage: json['stage']?.toString() ?? 'lead_in',
      probability: (json['probability'] as num?)?.toDouble() ?? 20.0,
      expectedCloseDate: json['expectedCloseDate'] != null
          ? DateTime.tryParse(json['expectedCloseDate'].toString())
          : null,
      actualCloseDate: json['actualCloseDate'] != null
          ? DateTime.tryParse(json['actualCloseDate'].toString())
          : null,
      leadSource: json['leadSource']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      wonReason: json['wonReason']?.toString() ?? '',
      lostReason: json['lostReason']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      companyId: cId,
      companyName: cName,
      contactId: ctId,
      contactName: ctName,
      assignedTo: json['assignedTo'] is Map<String, dynamic>
          ? CrmTeamMember.fromJson(json['assignedTo'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmPipelineColumn {
  final String id;
  final String name;
  final String color;
  final double probability;
  final int dealsCount;
  final double totalAmount;
  final double weightedAmount;
  final List<CrmDeal> deals;

  CrmPipelineColumn({
    required this.id,
    required this.name,
    required this.color,
    required this.probability,
    required this.dealsCount,
    required this.totalAmount,
    required this.weightedAmount,
    required this.deals,
  });

  factory CrmPipelineColumn.fromJson(Map<String, dynamic> json) {
    return CrmPipelineColumn(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      color: json['color']?.toString() ?? '#3B82F6',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
      dealsCount: (json['dealsCount'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      weightedAmount: (json['weightedAmount'] as num?)?.toDouble() ?? 0.0,
      deals: (json['deals'] as List<dynamic>?)
              ?.map((d) => CrmDeal.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CrmActivity {
  final String id;
  final String activityType; // task, call, meeting, follow_up, email
  final String title;
  final String description;
  final String status;
  final String priority;
  final DateTime dueDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String relatedToType;
  final String relatedToId;
  final String relatedToName;
  final String callDirection;
  final String callOutcome;
  final String meetingType;
  final String meetingLink;
  final String location;
  final String outcomeNotes;
  final CrmTeamMember? assignedTo;
  final DateTime createdAt;

  CrmActivity({
    required this.id,
    required this.activityType,
    required this.title,
    this.description = '',
    this.status = 'pending',
    this.priority = 'medium',
    required this.dueDate,
    this.startTime,
    this.endTime,
    this.durationMinutes = 30,
    this.relatedToType = 'general',
    this.relatedToId = '',
    this.relatedToName = '',
    this.callDirection = 'none',
    this.callOutcome = 'none',
    this.meetingType = 'none',
    this.meetingLink = '',
    this.location = '',
    this.outcomeNotes = '',
    this.assignedTo,
    required this.createdAt,
  });

  bool get isOverdue =>
      status != 'completed' &&
      status != 'cancelled' &&
      dueDate.isBefore(DateTime.now());

  factory CrmActivity.fromJson(Map<String, dynamic> json) {
    return CrmActivity(
      id: json['_id']?.toString() ?? '',
      activityType: json['activityType']?.toString() ?? 'task',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString() ?? 'medium',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : null,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : null,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      relatedToType: json['relatedToType']?.toString() ?? 'general',
      relatedToId: json['relatedToId']?.toString() ?? '',
      relatedToName: json['relatedToName']?.toString() ?? '',
      callDirection: json['callDirection']?.toString() ?? 'none',
      callOutcome: json['callOutcome']?.toString() ?? 'none',
      meetingType: json['meetingType']?.toString() ?? 'none',
      meetingLink: json['meetingLink']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      outcomeNotes: json['outcomeNotes']?.toString() ?? '',
      assignedTo: json['assignedTo'] is Map<String, dynamic>
          ? CrmTeamMember.fromJson(json['assignedTo'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmNote {
  final String id;
  final String title;
  final String content;
  final String relatedToType;
  final String relatedToId;
  final String relatedToName;
  final bool isPinned;
  final String createdByName;
  final DateTime createdAt;

  CrmNote({
    required this.id,
    this.title = '',
    required this.content,
    this.relatedToType = 'general',
    this.relatedToId = '',
    this.relatedToName = '',
    this.isPinned = false,
    this.createdByName = '',
    required this.createdAt,
  });

  factory CrmNote.fromJson(Map<String, dynamic> json) {
    String author = '';
    if (json['createdBy'] is Map<String, dynamic>) {
      author =
          '${json['createdBy']['firstName'] ?? ''} ${json['createdBy']['lastName'] ?? ''}'
              .trim();
    }

    return CrmNote(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      relatedToType: json['relatedToType']?.toString() ?? 'general',
      relatedToId: json['relatedToId']?.toString() ?? '',
      relatedToName: json['relatedToName']?.toString() ?? '',
      isPinned: json['isPinned'] == true,
      createdByName: author,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmEmailRecord {
  final String id;
  final String fromEmail;
  final String toEmail;
  final String toName;
  final String subject;
  final String bodyText;
  final String status;
  final String errorMessage;
  final DateTime sentAt;

  CrmEmailRecord({
    required this.id,
    required this.fromEmail,
    required this.toEmail,
    this.toName = '',
    required this.subject,
    this.bodyText = '',
    required this.status,
    this.errorMessage = '',
    required this.sentAt,
  });

  factory CrmEmailRecord.fromJson(Map<String, dynamic> json) {
    return CrmEmailRecord(
      id: json['_id']?.toString() ?? '',
      fromEmail: json['fromEmail']?.toString() ?? '',
      toEmail: json['toEmail']?.toString() ?? '',
      toName: json['toName']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      bodyText: json['bodyText']?.toString() ?? json['bodyHtml']?.toString() ?? '',
      status: json['status']?.toString() ?? 'sent',
      errorMessage: json['errorMessage']?.toString() ?? '',
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmCase {
  final String id;
  final String caseId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String type;
  final String contactName;
  final String companyName;
  final String resolution;
  final CrmTeamMember? assignedTo;
  final DateTime createdAt;

  CrmCase({
    required this.id,
    required this.caseId,
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.status = 'open',
    this.type = 'problem',
    this.contactName = '',
    this.companyName = '',
    this.resolution = '',
    this.assignedTo,
    required this.createdAt,
  });

  factory CrmCase.fromJson(Map<String, dynamic> json) {
    String ctName = '';
    if (json['contactId'] is Map<String, dynamic>) {
      ctName =
          '${json['contactId']['firstName'] ?? ''} ${json['contactId']['lastName'] ?? ''}'
              .trim();
    }
    String cmpName = '';
    if (json['companyId'] is Map<String, dynamic>) {
      cmpName = json['companyId']['name']?.toString() ?? '';
    }

    return CrmCase(
      id: json['_id']?.toString() ?? '',
      caseId: json['caseId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'open',
      type: json['type']?.toString() ?? 'problem',
      contactName: ctName,
      companyName: cmpName,
      resolution: json['resolution']?.toString() ?? '',
      assignedTo: json['assignedTo'] is Map<String, dynamic>
          ? CrmTeamMember.fromJson(json['assignedTo'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmProduct {
  final String id;
  final String sku;
  final String name;
  final String description;
  final String category;
  final double unitPrice;
  final String currency;
  final double taxRate;
  final int stockQuantity;
  final String type;
  final bool isActive;

  CrmProduct({
    required this.id,
    required this.sku,
    required this.name,
    this.description = '',
    this.category = 'General',
    required this.unitPrice,
    this.currency = 'USD',
    this.taxRate = 0,
    this.stockQuantity = 0,
    this.type = 'service',
    this.isActive = true,
  });

  factory CrmProduct.fromJson(Map<String, dynamic> json) {
    return CrmProduct(
      id: json['_id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'service',
      isActive: json['isActive'] != false,
    );
  }
}

class CrmQuotationItem {
  final String? productId;
  final String name;
  final String description;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double taxRate;
  final double lineTotal;

  CrmQuotationItem({
    this.productId,
    required this.name,
    this.description = '',
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    this.taxRate = 0,
    required this.lineTotal,
  });

  factory CrmQuotationItem.fromJson(Map<String, dynamic> json) {
    return CrmQuotationItem(
      productId: json['productId']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'discount': discount,
        'taxRate': taxRate,
        'lineTotal': lineTotal,
      };
}

class CrmQuotation {
  final String id;
  final String quoteNumber;
  final String title;
  final String status;
  final DateTime? validUntil;
  final List<CrmQuotationItem> items;
  final double subtotal;
  final double totalDiscount;
  final double totalTax;
  final double grandTotal;
  final String currency;
  final String contactName;
  final String companyName;
  final String dealTitle;
  final DateTime createdAt;

  CrmQuotation({
    required this.id,
    required this.quoteNumber,
    required this.title,
    this.status = 'draft',
    this.validUntil,
    this.items = const [],
    this.subtotal = 0,
    this.totalDiscount = 0,
    this.totalTax = 0,
    this.grandTotal = 0,
    this.currency = 'USD',
    this.contactName = '',
    this.companyName = '',
    this.dealTitle = '',
    required this.createdAt,
  });

  factory CrmQuotation.fromJson(Map<String, dynamic> json) {
    String ctName = '';
    if (json['contactId'] is Map<String, dynamic>) {
      ctName =
          '${json['contactId']['firstName'] ?? ''} ${json['contactId']['lastName'] ?? ''}'
              .trim();
    }
    String cmpName = '';
    if (json['companyId'] is Map<String, dynamic>) {
      cmpName = json['companyId']['name']?.toString() ?? '';
    }
    String dTitle = '';
    if (json['dealId'] is Map<String, dynamic>) {
      dTitle = json['dealId']['title']?.toString() ?? '';
    }

    return CrmQuotation(
      id: json['_id']?.toString() ?? '',
      quoteNumber: json['quoteNumber']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'draft',
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'].toString())
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => CrmQuotationItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      contactName: ctName,
      companyName: cmpName,
      dealTitle: dTitle,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CrmDashboardData {
  final String role;
  final int totalLeads;
  final int newLeads;
  final int qualifiedLeads;
  final int convertedLeads;
  final int totalContacts;
  final int totalCompanies;
  final int totalDeals;
  final int openDealsCount;
  final int wonDealsCount;
  final int lostDealsCount;
  final double pipelineValue;
  final double wonRevenue;
  final double weightedPipelineValue;
  final int winRate;
  final int leadConversionRate;
  final int overdueActivities;
  final int upcomingActivitiesCount;
  final int completedActivitiesCount;
  final List<CrmLead> recentLeads;
  final List<CrmActivity> upcomingActivities;
  final List<Map<String, dynamic>> dealsByStage;
  final List<Map<String, dynamic>> teamPerformance;

  CrmDashboardData({
    required this.role,
    this.totalLeads = 0,
    this.newLeads = 0,
    this.qualifiedLeads = 0,
    this.convertedLeads = 0,
    this.totalContacts = 0,
    this.totalCompanies = 0,
    this.totalDeals = 0,
    this.openDealsCount = 0,
    this.wonDealsCount = 0,
    this.lostDealsCount = 0,
    this.pipelineValue = 0,
    this.wonRevenue = 0,
    this.weightedPipelineValue = 0,
    this.winRate = 0,
    this.leadConversionRate = 0,
    this.overdueActivities = 0,
    this.upcomingActivitiesCount = 0,
    this.completedActivitiesCount = 0,
    this.recentLeads = const [],
    this.upcomingActivities = const [],
    this.dealsByStage = const [],
    this.teamPerformance = const [],
  });

  factory CrmDashboardData.fromJson(Map<String, dynamic> json) {
    return CrmDashboardData(
      role: json['role']?.toString() ?? 'employer',
      totalLeads: (json['totalLeads'] as num?)?.toInt() ?? 0,
      newLeads: (json['newLeads'] as num?)?.toInt() ?? 0,
      qualifiedLeads: (json['qualifiedLeads'] as num?)?.toInt() ?? 0,
      convertedLeads: (json['convertedLeads'] as num?)?.toInt() ?? 0,
      totalContacts: (json['totalContacts'] as num?)?.toInt() ?? 0,
      totalCompanies: (json['totalCompanies'] as num?)?.toInt() ?? 0,
      totalDeals: (json['totalDeals'] as num?)?.toInt() ?? 0,
      openDealsCount: (json['openDealsCount'] as num?)?.toInt() ?? 0,
      wonDealsCount: (json['wonDealsCount'] as num?)?.toInt() ?? 0,
      lostDealsCount: (json['lostDealsCount'] as num?)?.toInt() ?? 0,
      pipelineValue: (json['pipelineValue'] as num?)?.toDouble() ?? 0.0,
      wonRevenue: (json['wonRevenue'] as num?)?.toDouble() ?? 0.0,
      weightedPipelineValue:
          (json['weightedPipelineValue'] as num?)?.toDouble() ?? 0.0,
      winRate: (json['winRate'] as num?)?.toInt() ?? 0,
      leadConversionRate: (json['leadConversionRate'] as num?)?.toInt() ?? 0,
      overdueActivities: (json['overdueActivities'] as num?)?.toInt() ?? 0,
      upcomingActivitiesCount:
          (json['upcomingActivitiesCount'] as num?)?.toInt() ?? 0,
      completedActivitiesCount:
          (json['completedActivitiesCount'] as num?)?.toInt() ?? 0,
      recentLeads: (json['recentLeads'] as List<dynamic>?)
              ?.map((l) => CrmLead.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      upcomingActivities: (json['upcomingActivities'] as List<dynamic>?)
              ?.map((a) => CrmActivity.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      dealsByStage: (json['dealsByStage'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      teamPerformance: (json['teamPerformance'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}

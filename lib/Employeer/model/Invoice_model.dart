// lib/Employeer/models/invoice_model.dart
class Invoice {
  final String id;
  final String invoiceNumber;
  final String type;
  final String projectId;
  final String projectTitle;
  final String employerId;
  final String employerName;
  final String? employerCompany;
  final String employerEmail;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String contractId;
  final String contractNumber;
  final List<InvoiceMilestone> milestones;
  final double subtotal;
  final double platformFee;
  final double total;
  final String status;
  final DateTime issuedAt;
  final DateTime? dueDate;
  final String? paymentMethod;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.projectId,
    required this.projectTitle,
    required this.employerId,
    required this.employerName,
    this.employerCompany,
    required this.employerEmail,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.contractId,
    required this.contractNumber,
    required this.milestones,
    required this.subtotal,
    required this.platformFee,
    required this.total,
    required this.status,
    required this.issuedAt,
    this.dueDate,
    this.paymentMethod,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var milestonesList = <InvoiceMilestone>[];
    if (json['milestones'] != null) {
      milestonesList = (json['milestones'] as List)
          .map((m) => InvoiceMilestone.fromJson(m))
          .toList();
    }

    return Invoice(
      id: json['_id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      type: json['type'] ?? '',
      projectId: json['projectId'] ?? '',
      projectTitle: json['projectTitle'] ?? '',
      employerId: json['employerId'] ?? '',
      employerName: json['employerName'] ?? '',
      employerCompany: json['employerCompany'],
      employerEmail: json['employerEmail'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      employeeEmail: json['employeeEmail'] ?? '',
      contractId: json['contractId'] ?? '',
      contractNumber: json['contractNumber'] ?? '',
      milestones: milestonesList,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      issuedAt: json['issuedAt'] != null 
          ? DateTime.parse(json['issuedAt']) 
          : DateTime.now(),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : null,
      paymentMethod: json['paymentMethod'],
    );
  }
}

class InvoiceMilestone {
  final String milestoneId;
  final String title;
  final double amount;
  final DateTime? releasedAt;

  InvoiceMilestone({
    required this.milestoneId,
    required this.title,
    required this.amount,
    this.releasedAt,
  });

  factory InvoiceMilestone.fromJson(Map<String, dynamic> json) {
    return InvoiceMilestone(
      milestoneId: json['milestoneId'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      releasedAt: json['releasedAt'] != null 
          ? DateTime.parse(json['releasedAt']) 
          : null,
    );
  }
}
// lib/Employer/models/employer_interest_model.dart
class EmployerInterestModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String employeePhoto;
  final String employeeTitle;
  final String jobTitle;
  final double salaryAmount;
  final String salaryPeriod;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime respondedAt;

  EmployerInterestModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeePhoto,
    required this.employeeTitle,
    required this.jobTitle,
    required this.salaryAmount,
    required this.salaryPeriod,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.respondedAt,
  });

  factory EmployerInterestModel.fromJson(Map<String, dynamic> json) {
    final employee = json['employeeId'] is Map
        ? json['employeeId'] as Map<String, dynamic>
        : null;
    
    final employeeProfile = employee?['employeeProfile'] as Map<String, dynamic>?;

    return EmployerInterestModel(
      id: json['_id'] ?? '',
      employeeId: employee?['_id'] ?? json['employeeId'] ?? '',
      employeeName: employee != null
          ? '${employee['firstName'] ?? ''} ${employee['lastName'] ?? ''}'.trim()
          : 'Unknown Employee',
      employeePhoto: employeeProfile?['photoUrl'] ?? '',
      employeeTitle: employeeProfile?['title'] ?? 'Professional',
      jobTitle: json['jobTitle'] ?? '',
      salaryAmount: (json['salaryAmount'] ?? 0).toDouble(),
      salaryPeriod: json['salaryPeriod'] ?? 'monthly',
      message: json['message'] ?? '',
      status: json['status'] ?? 'interested',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : DateTime.now(),
    );
  }

  String get formattedSalary {
    return '\$${salaryAmount.toStringAsFixed(0)}/${_getPeriodSymbol()}';
  }

  String _getPeriodSymbol() {
    switch (salaryPeriod) {
      case 'hourly':
        return 'hr';
      case 'monthly':
        return 'mo';
      case 'yearly':
        return 'yr';
      default:
        return 'mo';
    }
  }
}
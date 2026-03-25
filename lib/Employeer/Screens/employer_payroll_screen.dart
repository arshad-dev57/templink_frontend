// lib/Employer/Screens/payroll_screen.dart
import 'package:flutter/material.dart';
import '../../Utils/colors.dart';

class EmployerPayrollScreen extends StatefulWidget {
  const EmployerPayrollScreen({Key? key}) : super(key: key);

  @override
  State<EmployerPayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<EmployerPayrollScreen> {
  String selectedMonth = 'December 2024';
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> employees = [
    {
      'name': 'John Doe',
      'initials': 'JD',
      'role': 'Senior Developer',
      'salary': 4800,
      'hourlyRate': 40,
      'hours': 160,
      'overtime': 12,
      'bonus': 200,
      'deductions': 150,
      'netPay': 5050,
      'status': 'paid',
      'paymentDate': 'Dec 25, 2024',
    },
    {
      'name': 'Sarah Smith',
      'initials': 'SS',
      'role': 'UI/UX Designer',
      'salary': 4200,
      'hourlyRate': 35,
      'hours': 160,
      'overtime': 0,
      'bonus': 0,
      'deductions': 120,
      'netPay': 4080,
      'status': 'paid',
      'paymentDate': 'Dec 25, 2024',
    },
    {
      'name': 'Mike Johnson',
      'initials': 'MJ',
      'role': 'Project Manager',
      'salary': 6000,
      'hourlyRate': 50,
      'hours': 160,
      'overtime': 8,
      'bonus': 500,
      'deductions': 200,
      'netPay': 6500,
      'status': 'pending',
      'paymentDate': 'Pending',
    },
    {
      'name': 'Emily Davis',
      'initials': 'ED',
      'role': 'Data Analyst',
      'salary': 3600,
      'hourlyRate': 30,
      'hours': 160,
      'overtime': 4,
      'bonus': 100,
      'deductions': 100,
      'netPay': 3700,
      'status': 'processing',
      'paymentDate': 'Dec 27, 2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final totalPayroll = employees.fold<double>(
        0, (sum, e) => sum + (e['netPay'] as int));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payroll Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(totalPayroll),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 16),
            _buildEmployeeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalPayroll) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withBlue(primary.blue + 20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Payroll',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalPayroll.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('Paid', '\$12,030', Colors.green),
              _buildSummaryStat('Pending', '\$10,200', Colors.orange),
              _buildSummaryStat('Processing', '\$3,700', primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedMonth,
                style: const TextStyle(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Run Payroll',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final months = ['November 2024', 'December 2024', 'January 2025'];
    final filters = ['All', 'Paid', 'Pending', 'Processing'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: months.map((month) {
              final isSelected = month == selectedMonth;
              return GestureDetector(
                onTap: () => setState(() => selectedMonth = month),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    month,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: filters.map((filter) {
            final isSelected = filter == selectedFilter;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedFilter = filter),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    filter,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? primary : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmployeeList() {
    return Column(
      children: employees.map((employee) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Text(
                      employee['initials'],
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee['role'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: employee['status'] == 'paid'
                          ? Colors.green.withOpacity(0.1)
                          : employee['status'] == 'pending'
                              ? Colors.orange.withOpacity(0.1)
                              : primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      employee['status'].toUpperCase(),
                      style: TextStyle(
                        color: employee['status'] == 'paid'
                            ? Colors.green
                            : employee['status'] == 'pending'
                                ? Colors.orange
                                : primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPayrollDetail(
                    label: 'Base Salary',
                    value: '\$${employee['salary']}',
                    color: Colors.grey[700]!,
                  ),
                  _buildPayrollDetail(
                    label: 'Overtime',
                    value: '${employee['overtime']} hrs',
                    color: Colors.orange,
                  ),
                  _buildPayrollDetail(
                    label: 'Bonus',
                    value: '\$${employee['bonus']}',
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPayrollDetail(
                    label: 'Deductions',
                    value: '-\$${employee['deductions']}',
                    color: Colors.red,
                  ),
                  _buildPayrollDetail(
                    label: 'Net Pay',
                    value: '\$${employee['netPay']}',
                    color: primary,
                    isBold: true,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPayrollDetail({
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
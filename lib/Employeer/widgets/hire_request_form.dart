// lib/Employer/Widgets/hire_request_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/model/talent_model.dart';
import 'package:templink/Utils/colors.dart';

class HireRequestForm extends StatefulWidget {
  final TalentModel talent;
  final Function(Map<String, dynamic>) onSubmit;

  const HireRequestForm({
    Key? key,
    required this.talent,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<HireRequestForm> createState() => _HireRequestFormState();
}

class _HireRequestFormState extends State<HireRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _salaryController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedPeriod = 'monthly';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _periods = [
    {'value': 'hourly', 'label': 'Per Hour'},
    {'value': 'monthly', 'label': 'Per Month'},
    {'value': 'yearly', 'label': 'Per Year'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primary.withOpacity(0.1),
                  backgroundImage: widget.talent.photoUrl.isNotEmpty
                      ? NetworkImage(widget.talent.photoUrl)
                      : null,
                  child: widget.talent.photoUrl.isEmpty
                      ? Text(
                          widget.talent.fullName[0].toUpperCase(),
                          style: TextStyle(color: primary),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hire ${widget.talent.firstName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.talent.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Job Title
            TextFormField(
              controller: _jobTitleController,
              decoration: InputDecoration(
                labelText: 'Job Title / Role',
                hintText: 'e.g., Flutter Developer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.work_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter job title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Salary Amount
            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Salary Amount',
                hintText: 'e.g., 5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter salary amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Salary Period
        // Salary Period Dropdown - FIXED
DropdownButtonFormField<String>(
  value: _selectedPeriod,
  decoration: InputDecoration(
    labelText: 'Salary Period',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    prefixIcon: const Icon(Icons.calendar_today),
  ),
  items: _periods.map<DropdownMenuItem<String>>((period) {  // 👈 YAHAN TYPE SPECIFY KIYA
    return DropdownMenuItem<String>(
      value: period['value'] as String,  // 👈 CAST AS STRING
      child: Text(period['label'] as String),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedPeriod = value!;
    });
  },
),
            const SizedBox(height: 16),

            // Message (Optional)
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message (Optional)',
                hintText: 'Tell the candidate why you\'re interested...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Commission Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Platform Fee',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '20% commission will be charged upon hiring',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Interest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'employeeId': widget.talent.id,
        'jobTitle': _jobTitleController.text,
        'salaryAmount': double.parse(_salaryController.text),
        'salaryPeriod': _selectedPeriod,
        'message': _messageController.text,
      };
      widget.onSubmit(data);
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _salaryController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
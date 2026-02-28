import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:templink/Employeer/Controller/employer_job_application_controller.dart';
import 'package:templink/Employeer/model/employer_job_application.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/config/api_config.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final EmployerJobApplication application;
  final EmployerApplicationController controller = Get.find();
  final String baseUrl = ApiConfig.baseUrl;

  final protectionStatus = Rx<Map<String, dynamic>>({});
  final isLoadingProtection = false.obs;

  ApplicationDetailScreen({super.key, required this.application}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEmployerProtection();
    });
  }

  // ============== CHECK EMPLOYER LEVEL PROTECTION ==============
  Future<void> _checkEmployerProtection() async {
    try {
      isLoadingProtection.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      print('🔍 Checking employer protection...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/protection/employer/protection'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Protection response: ${response.statusCode}');
      print('📦 Protection body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          protectionStatus.value = data;
          print('🛡️ Employer protection: ${data['message']}');
          print('🛡️ Remaining hires: ${data['remainingHires']}');
        }
      }
    } catch (e) {
      print('❌ Error checking protection: $e');
    } finally {
      isLoadingProtection.value = false;
    }
  }

  // ============== MARK EMPLOYEE LEFT ==============
  Future<void> _markEmployeeLeft() async {
    try {
      final reasonController = TextEditingController();
      
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Employee Left?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Has this employee left the company?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If employee left within 30 days, you will get FREE HIRE protection for ALL your jobs!',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Reason for leaving (optional)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Left'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      print('📝 Marking employee left for application: ${application.id}');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/api/protection/application/${application.id}/left'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reason': reasonController.text.trim(),
        }),
      );

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String message = data['message'] ?? 'Employee marked as left';
        Color bgColor = data['protectionActivated'] == true ? Colors.green : Colors.orange;
        
        Get.snackbar(
          data['protectionActivated'] == true ? '🎉 Protection Activated!' : 'Employee Left',
          message,
          backgroundColor: bgColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        
        controller.fetchEmployerApplications();
        Get.back();
      } else {
        throw Exception('Failed to update: ${response.body}');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============== HIRE & PAY WITH EMPLOYER LEVEL PROTECTION ==============
  Future<void> _hireAndPay() async {
    try {
      if (application.status == 'hired') {
        Get.snackbar(
          'Already Hired',
          'This candidate is already hired',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Not authenticated');

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // ✅ CHECK EMPLOYER LEVEL PROTECTION
      final protectionCheck = await http.get(
        Uri.parse('$baseUrl/api/protection/employer/protection'),
        headers: {'Authorization': 'Bearer $token'},
      );

      bool isProtected = false;
      int remainingHires = 0;
      
      if (protectionCheck.statusCode == 200) {
        final protectionData = jsonDecode(protectionCheck.body);
        isProtected = protectionData['isProtected'] == true;
        remainingHires = protectionData['remainingHires'] ?? 0;
        
        // ✅ AGAR PROTECTION ACTIVE HAI TO FREE HIRE
        if (isProtected) {
          if (Get.isDialogOpen ?? false) Get.back();

          final confirm = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('🎉 Free Hire Available!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.shield, color: Colors.green, size: 50),
                        const SizedBox(height: 12),
                        Text(
                          protectionData['message'] ?? 'Employer protection active!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${protectionData['remainingHires']} free hire(s) remaining • ${protectionData['daysRemaining']} days left',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hire for Free'),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          // ✅ FREE HIRE API CALL
          final freeHireResponse = await http.post(
            Uri.parse('$baseUrl/api/commission/create-payment'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'applicationId': application.id,
            }),
          );

          if (Get.isDialogOpen ?? false) Get.back();

          if (freeHireResponse.statusCode == 200) {
            final responseData = jsonDecode(freeHireResponse.body);
            
            if (responseData['success'] == true) {
              _showSuccessDialog(
                isFree: true,
                remainingHires: responseData['remainingHires'] ?? 0,
              );
              controller.fetchEmployerApplications();
              Future.delayed(const Duration(seconds: 3), () {
                if (Get.isDialogOpen ?? false) Get.back();
                Get.back();
              });
            } else {
              throw Exception(responseData['message'] ?? 'Free hire failed');
            }
          } else {
            throw Exception('Free hire failed');
          }
          return;
        }
      }

      // 👇 NORMAL HIRE (WITH PAYMENT)
      if (Get.isDialogOpen ?? false) Get.back();

      // Get salary from job snapshot
      final salary = application.jobSnapshot.salaryAmount ?? 2000;
      final commissionAmount = (salary * 0.2).round();

      bool confirm = await _showHireConfirmation(
        salary.toDouble(),
        commissionAmount.toDouble(),
      );
      if (!confirm) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final paymentResponse = await http.post(
        Uri.parse('$baseUrl/api/commission/create-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'applicationId': application.id,
        }),
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (paymentResponse.statusCode != 200) {
        final errorData = jsonDecode(paymentResponse.body);
        throw Exception(errorData['message'] ?? 'Payment failed');
      }

      final paymentData = jsonDecode(paymentResponse.body);
      
      if (paymentData['isFreeHire'] == true) {
        _showSuccessDialog(isFree: true);
        controller.fetchEmployerApplications();
        Future.delayed(const Duration(seconds: 2), () {
          if (Get.isDialogOpen ?? false) Get.back();
          Get.back();
        });
        return;
      }

      // Initialize Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Templink',
          paymentIntentClientSecret: paymentData['clientSecret'],
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF0066B3),
            ),
          ),
        ),
      );

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await Stripe.instance.presentPaymentSheet();

      final verifyResponse = await http.post(
        Uri.parse('$baseUrl/api/commission/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentIntentId': paymentData['paymentIntentId'],
          'applicationId': application.id,
        }),
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (verifyResponse.statusCode == 200) {
        _showSuccessDialog(isFree: false);
        controller.fetchEmployerApplications();
        Future.delayed(const Duration(seconds: 2), () {
          if (Get.isDialogOpen ?? false) Get.back();
          Get.back();
        });
      } else {
        throw Exception('Verification failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============== SUCCESS DIALOG ==============
  void _showSuccessDialog({bool isFree = false, int remainingHires = 0}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isFree ? Colors.blue.shade50 : Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFree ? Icons.shield : Icons.check_circle,
                color: isFree ? Colors.blue : Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFree ? 'Free Hire Successful! 🎉' : 'Hired Successfully!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isFree 
                ? 'Candidate hired under employer protection.\nNo commission charged.'
                : 'Commission payment successful.\nCandidate has been hired.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (isFree && remainingHires > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$remainingHires free hire(s) remaining',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============== HIRE CONFIRMATION DIALOG ==============
  Future<bool> _showHireConfirmation(double salary, double commission) async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hire & Pay Commission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Job Salary:'),
                      Text('\$${salary.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Commission (20%):'),
                      Text(
                        '\$${commission.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total to Pay:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '\$${commission.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'By hiring, you agree to pay 20% platform fee',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    ) ?? false;
  }

  // ============== PROTECTION CARD ==============
  Widget _buildProtectionCard() {
    final remainingHires = protectionStatus.value['remainingHires'] ?? 0;
    final daysRemaining = protectionStatus.value['daysRemaining'] ?? 0;
    final progress = daysRemaining / 30;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Employer Protection Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              protectionStatus.value['message'] ?? 'Free hires available for ALL jobs!',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildProtectionStat(
                    '$remainingHires',
                    'Free Hires Left',
                    Icons.people,
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.white30,
                ),
                Expanded(
                  child: _buildProtectionStat(
                    '$daysRemaining',
                    'Days Remaining',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============== EMPLOYEE LEFT BUTTON ==============
  Widget _buildEmployeeLeftButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: _markEmployeeLeft,
        icon: const Icon(Icons.exit_to_app),
        label: const Text('Mark as Left'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============== PENDING STATUS CARD ==============
  Widget _buildPendingStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pending_actions, color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Application Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    controller.getStatusText(application.status),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hire this candidate to pay 20% platform fee',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== HIRED STATUS CARD ==============
  Widget _buildHiredStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HIRED', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${application.employeeSnapshot.firstName} ${application.employeeSnapshot.lastName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    if (application.hiringCommission?.isFreeHire == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Free Hire',
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Commission paid',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.white, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ============== CANDIDATE PROFILE CARD ==============
  Widget _buildCandidateProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Candidate Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: application.employeeSnapshot.photoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(application.employeeSnapshot.photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: application.employeeSnapshot.photoUrl.isEmpty
                      ? Center(
                          child: Text(
                            '${application.employeeSnapshot.firstName[0]}${application.employeeSnapshot.lastName[0]}',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${application.employeeSnapshot.firstName} ${application.employeeSnapshot.lastName}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.employeeSnapshot.title,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            application.employeeSnapshot.country,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${application.employeeSnapshot.rating}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${application.employeeSnapshot.totalReviews} reviews)',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (application.employeeSnapshot.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                application.employeeSnapshot.bio,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============== JOB DETAILS CARD ==============
  Widget _buildJobDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Job Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.work_outline, color: primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    application.jobSnapshot.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
                const SizedBox(width: 12),
                Text(
                  application.jobSnapshot.location,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    application.jobSnapshot.workplace,
                    style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    application.jobSnapshot.type,
                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Applied ${controller.formatDate(application.appliedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              application.jobSnapshot.about,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ============== RESUME CARD ==============
  Widget _buildResumeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf, size: 32, color: Colors.red),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.resumeFileName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(application.resumeFileSize! / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new, color: primary),
                    onPressed: _openResume,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== COVER LETTER CARD ==============
  Widget _buildCoverLetterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cover Letter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                application.coverLetter,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== SKILLS CARD ==============
  Widget _buildSkillsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: application.employeeSnapshot.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(color: primary, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ============== EDUCATION CARD ==============
  Widget _buildEducationCard() {
    final edu = application.employeeSnapshot.recentEducation!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Education', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school, color: primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          edu.degree,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          edu.school,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          edu.field,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== OPEN RESUME ==============
  Future<void> _openResume() async {
    if (application.resumeFileUrl.isEmpty) return;

    try {
      final Uri uri = Uri.parse(application.resumeFileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open resume', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open resume', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _openResume,
            tooltip: 'Open Resume',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Protection Status Card (Employer Level)
                Obx(() {
                  if (isLoadingProtection.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (protectionStatus.value['isProtected'] == true) {
                    return _buildProtectionCard();
                  }
                  return const SizedBox();
                }),
                
                _buildCandidateProfileCard(),
                const SizedBox(height: 16),
                _buildJobDetailsCard(),
                const SizedBox(height: 16),

                // Status Card
                if (application.status == 'hired')
                  _buildHiredStatusCard()
                else
                  _buildPendingStatusCard(),
                
                const SizedBox(height: 16),

                // Employee Left Button
                if (application.status == 'hired') ...[
                  if (application.employmentStatus != 'left')
                    _buildEmployeeLeftButton(),
                ],

                _buildResumeCard(),
                if (application.coverLetter.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildCoverLetterCard(),
                ],
                if (application.employeeSnapshot.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSkillsCard(),
                ],
                if (application.employeeSnapshot.recentEducation != null) ...[
                  const SizedBox(height: 16),
                  _buildEducationCard(),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Bottom Hire Button
          if (application.status != 'hired')
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: Obx(() {
                  final isProtected = protectionStatus.value['isProtected'] == true;
                  final remainingHires = protectionStatus.value['remainingHires'] ?? 0;
                  
                  return ElevatedButton(
                    onPressed: _hireAndPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isProtected ? Colors.green : primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isProtected ? Icons.shield : Icons.work,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isProtected 
                                  ? 'Hire for FREE (Protected)' 
                                  : 'Hire & Pay 20% Commission',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (isProtected && remainingHires > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$remainingHires free hires remaining',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
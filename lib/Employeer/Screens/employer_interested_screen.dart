// lib/Employer/screens/employer_interested_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:templink/Employeer/Controller/employer_interest_controller.dart';
import 'package:templink/Employeer/model/employer_interest_model.dart';

import 'package:templink/Global_Screens/Chat_Screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmployerInterestedScreen extends StatefulWidget {
  const EmployerInterestedScreen({Key? key}) : super(key: key);

  @override
  State<EmployerInterestedScreen> createState() => _EmployerInterestedScreenState();
}

class _EmployerInterestedScreenState extends State<EmployerInterestedScreen> {
  final EmployerInterestController controller = Get.put(EmployerInterestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Interested Candidates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Wallet Balance
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, 
                         color: primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  '\$${controller.walletBalance.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value != null) {
            return _buildErrorWidget();
          }

          if (controller.interestedCandidates.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.interestedCandidates.length,
            itemBuilder: (context, index) {
              final candidate = controller.interestedCandidates[index];
              return _buildCandidateCard(candidate);
            },
          );
        }),
      ),
    );
  }

  // ============== CANDIDATE CARD ==============
  Widget _buildCandidateCard(EmployerInterestModel candidate) {
    final commissionAmount = candidate.salaryAmount * 0.2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with employee info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: candidate.employeePhoto.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(candidate.employeePhoto),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: candidate.employeePhoto.isEmpty
                      ? Center(
                          child: Text(
                            candidate.employeeName.isNotEmpty
                                ? candidate.employeeName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Name and Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.employeeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.employeeTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Accepted Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, 
                           color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Accepted',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey[200]),

          // Job Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Title and Salary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Position',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            candidate.jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        candidate.formattedSalary,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Message from employee (optional)
                if (candidate.message.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message_outlined, 
                             size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            candidate.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Commission Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, 
                           color: Colors.amber.shade800, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Platform Fee (20%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Commission: \$${commissionAmount.toStringAsFixed(0)} will be deducted from wallet',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Chat Button
                    Expanded(
                      child: _buildActionButton(
                        label: 'Chat',
                        icon: Icons.chat_bubble_outline,
                        color: Colors.blue,
                        onTap: () => _openChat(candidate),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Hire Button
                    Expanded(
                      child: Obx(() {
                        final isHiring = controller.isHiring.value;
                        return _buildActionButton(
                          label: 'Hire Now',
                          icon: Icons.work_outline,
                          color: Colors.green,
                          isLoading: isHiring,
                          onTap: isHiring ? null : () => _hireCandidate(candidate),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============== ACTION BUTTON ==============
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ============== HIRE CANDIDATE ==============
  void _hireCandidate(EmployerInterestModel candidate) {
    final commissionAmount = candidate.salaryAmount * 0.2;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Confirm Hire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hire ${candidate.employeeName} as ${candidate.jobTitle}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Salary:'),
                      Text(candidate.formattedSalary,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Commission (20%):'),
                      Text(
                        '\$${commissionAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Wallet Balance:'),
                      Obx(() => Text(
                        '\$${controller.walletBalance.value.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.walletBalance.value >= commissionAmount
                              ? Colors.green
                              : Colors.red,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Obx(() {
            final canHire = controller.walletBalance.value >= commissionAmount;
            return ElevatedButton(
              onPressed: canHire ? () => _processHire(candidate) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canHire ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Hire'),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _processHire(EmployerInterestModel candidate) async {
    Navigator.pop(context); // Close dialog

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final commissionAmount = candidate.salaryAmount * 0.2;
    final success = await controller.hireCandidate(
      candidate.id,
      commissionAmount,
    );

    if (Get.isDialogOpen ?? false) Get.back();

    if (success) {
      Get.snackbar(
        '🎉 Success!',
        '${candidate.employeeName} has been hired successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to hire candidate. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============== OPEN CHAT ==============
  Future<void> _openChat(EmployerInterestModel candidate) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final prefs = await SharedPreferences.getInstance();
      final myUserId = prefs.getString('auth_user_id') ?? '';
      final myToken = prefs.getString('auth_token') ?? '';

      if (Get.isDialogOpen ?? false) Get.back();

      Get.to(() => ChatScreen(
        userName: candidate.employeeName,
        userOnline: false,
        toUserId: candidate.employeeId,
        baseUrl: ApiConfig.baseUrl,
        myToken: myToken,
        myUserId: myUserId,
      ));
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Failed to open chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ============== EMPTY STATE ==============
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 64,
                color: primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Interested Candidates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When employees accept your requests,\nthey will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== ERROR WIDGET ==============
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
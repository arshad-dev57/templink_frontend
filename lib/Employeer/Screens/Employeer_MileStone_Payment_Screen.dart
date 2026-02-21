// screens/Employeer_Milestone_Payment_Screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employeer/model/employer_project_model.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/config/api_config.dart';

class MilestonePaymentScreen extends StatefulWidget {
  final EmployerProject project;
  final Milestone milestone;

  const MilestonePaymentScreen({
    Key? key,
    required this.project,
    required this.milestone,
  }) : super(key: key);

  @override
  State<MilestonePaymentScreen> createState() => _MilestonePaymentScreenState();
}

class _MilestonePaymentScreenState extends State<MilestonePaymentScreen> {
  final String baseUrl = ApiConfig.baseUrl;
  
  var isProcessing = false.obs;
  var selectedPaymentMethod = 'wallet'.obs;
  var currentWalletBalance = 0.0.obs;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'wallet', 
      'name': 'Wallet Balance', 
      'icon': Icons.account_balance_wallet, 
      'color': Colors.blue,
      'description': 'Use your wallet balance'
    },
    {
      'id': 'card', 
      'name': 'Credit / Debit Card', 
      'icon': Icons.credit_card, 
      'color': Colors.green,
      'description': 'Pay with Stripe'
    },
    {
      'id': 'google_pay', 
      'name': 'Google Pay', 
      'icon': Icons.payment, 
      'color': Colors.black,
      'description': 'Fast & secure'
    },
    {
      'id': 'apple_pay', 
      'name': 'Apple Pay', 
      'icon': Icons.apple, 
      'color': Colors.black,
      'description': 'Pay with Apple'
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchWalletBalance();
  }

  Future<void> fetchWalletBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/balance'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          currentWalletBalance.value = (jsonResponse['balance'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      print('Error fetching wallet balance: $e');
    }
  }

  Future<void> processMilestonePayment() async {
    try {
      isProcessing.value = true;

      if (selectedPaymentMethod.value == 'wallet') {
        await processWalletPayment();
      } else {
        await processStripePayment();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      
      String errorMessage = 'Payment failed';
      if (e.toString().contains('UserCanceled')) {
        errorMessage = 'Payment cancelled';
      } else if (e.toString().contains('Insufficient')) {
        errorMessage = 'Insufficient wallet balance';
      }

      Get.snackbar(
        'Payment Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> processWalletPayment() async {
    // Check if wallet has sufficient balance
    if (currentWalletBalance.value < widget.milestone.amount) {
      throw Exception('Insufficient wallet balance');
    }

    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    Get.dialog(
      const Center(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Processing payment...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/milestone-payments/pay-with-wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': widget.project.id,
          'milestoneId': widget.milestone.id,
          'amount': widget.milestone.amount,
        }),
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          currentWalletBalance.value = (jsonResponse['newBalance'] ?? 0).toDouble();
          
          _showSuccessDialog(
            'Payment Successful!',
            'Milestone payment of \$${widget.milestone.amount.toStringAsFixed(2)} completed using wallet.',
          );
        } else {
          throw Exception(jsonResponse['message'] ?? 'Payment failed');
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      rethrow;
    }
  }

  Future<void> processStripePayment() async {
    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    try {
      Get.dialog(
        const Center(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Initializing payment...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // 1. Create payment intent
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final paymentResponse = await http.post(
        Uri.parse('$baseUrl/api/milestone-payments/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': widget.project.id,
          'milestoneId': widget.milestone.id,
          'amount': widget.milestone.amount,
          'paymentMethod': selectedPaymentMethod.value,
        }),
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (paymentResponse.statusCode != 200) {
        throw Exception('Failed to create payment');
      }

      final paymentData = jsonDecode(paymentResponse.body);
      final clientSecret = paymentData['clientSecret'];

      // 2. Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Templink',
          paymentIntentClientSecret: clientSecret,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'USD',
            testEnv: true,
          ),
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: primary,
              background: Colors.white,
              componentBackground: Colors.grey.shade50,
              componentDivider: Colors.grey.shade300,
              componentBorder: Colors.grey.shade400,
              placeholderText: Colors.grey.shade500,
              icon: primary,
            ),
            shapes: PaymentSheetShape(
              borderWidth: 1,
              borderRadius: 12,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: primary,
                  text: Colors.white,
                  border: primary,
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: primary,
                  text: Colors.white,
                  border: primary,
                ),
              ),
              shapes: PaymentSheetPrimaryButtonShape(
                borderWidth: 0,
                blurRadius: 12,
              ),
            ),
          ),
        ),
      );

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      Get.dialog(
        const Center(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Verifying payment...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // 4. Verify payment
      final verifyResponse = await http.post(
        Uri.parse('$baseUrl/api/milestone-payments/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentIntentId': paymentData['paymentIntentId'],
          'projectId': widget.project.id,
          'milestoneId': widget.milestone.id,
        }),
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (verifyResponse.statusCode == 200) {
        final verifyData = jsonDecode(verifyResponse.body);
        if (verifyData['success'] == true) {
          _showSuccessDialog(
            'Payment Successful!',
            'Milestone payment of \$${widget.milestone.amount.toStringAsFixed(2)} completed successfully.',
          );
        } else {
          throw Exception('Payment verification failed');
        }
      } else {
        throw Exception('Payment verification failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      rethrow;
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirm Milestone Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child:  Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.milestone.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${widget.milestone.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Project:', widget.project.title),
            _buildInfoRow('Payment Method:', _getPaymentMethodName()),
            if (selectedPaymentMethod.value == 'wallet')
              _buildInfoRow(
                'Wallet Balance:', 
                '\$${currentWalletBalance.value.toStringAsFixed(2)}',
                color: currentWalletBalance.value >= widget.milestone.amount 
                    ? Colors.green 
                    : Colors.red,
              ),
            const Divider(height: 24),
            _buildInfoRow('Total Amount:', '\$${widget.milestone.amount.toStringAsFixed(2)}', isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName() {
    return paymentMethods.firstWhere(
      (m) => m['id'] == selectedPaymentMethod.value,
      orElse: () => paymentMethods[0],
    )['name'];
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return success to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPayWithWallet = currentWalletBalance.value >= widget.milestone.amount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Pay Milestone',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Info Card
                _buildProjectInfoCard(),
                
                const SizedBox(height: 20),
                
                // Milestone Details Card
                _buildMilestoneDetailsCard(),
                
                const SizedBox(height: 20),
                
                // Payment Methods Card
                _buildPaymentMethodsCard(canPayWithWallet),
                
                const SizedBox(height: 20),
                
                // Payment Summary Card
                _buildPaymentSummaryCard(),
                
                const SizedBox(height: 30),
                
                // Pay Button
                _buildPayButton(canPayWithWallet),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          if (isProcessing.value)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Processing Payment...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.folder,
              color: primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.project.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Milestone',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.milestone.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.milestone.description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount to Pay',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '\$${widget.milestone.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard(bool canPayWithWallet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...paymentMethods.map((method) {
            final isSelected = selectedPaymentMethod.value == method['id'];
            final isWallet = method['id'] == 'wallet';
            
            // Disable wallet if insufficient balance
            if (isWallet && !canPayWithWallet) {
              return _buildDisabledPaymentMethod(method);
            }
            
            return GestureDetector(
              onTap: () {
                if (isWallet && !canPayWithWallet) return;
                selectedPaymentMethod.value = method['id'];
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? primary.withOpacity(0.05) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? primary : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (method['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        method['icon'],
                        color: method['color'],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            method['description'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (isWallet) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Balance: \$${currentWalletBalance.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: canPayWithWallet ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: method['id'],
                      groupValue: selectedPaymentMethod.value,
                      onChanged: (value) {
                        if (isWallet && !canPayWithWallet) return;
                        selectedPaymentMethod.value = value!;
                      },
                      activeColor: primary,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDisabledPaymentMethod(Map<String, dynamic> method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              method['icon'],
              color: Colors.grey.shade500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Insufficient balance - Need \$${widget.milestone.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    final platformFee = widget.milestone.amount * 0.05;
    final total = widget.milestone.amount + platformFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Milestone Amount', '\$${widget.milestone.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Platform Fee (5%)', '\$${platformFee.toStringAsFixed(2)}', color: Colors.grey),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          _buildSummaryRow(
            'Total', 
            '\$${total.toStringAsFixed(2)}',
            isBold: true,
            color: primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(bool canPayWithWallet) {
    final isWalletSelected = selectedPaymentMethod.value == 'wallet';
    final buttonEnabled = !isWalletSelected || (isWalletSelected && canPayWithWallet);

    final platformFee = widget.milestone.amount * 0.05;
    final total = widget.milestone.amount + platformFee;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: buttonEnabled ? processMilestonePayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWalletSelected ? Icons.account_balance_wallet : Icons.lock,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isWalletSelected 
                  ? 'Pay with Wallet' 
                  : 'Pay \$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
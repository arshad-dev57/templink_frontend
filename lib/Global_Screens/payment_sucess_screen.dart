// lib/Employeer/Screens/payment_success_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:templink/config/api_config.dart';
import 'package:templink/Utils/colors.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool isVerifying = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _handlePaymentSuccess();
  }

  Future<void> _handlePaymentSuccess() async {
    try {
      // Get session_id from URL - works for web and mobile
      String? sessionId;
      
      // For Flutter Web - get from URI
      if (Get.context != null) {
        final uri = Uri.base;
        sessionId = uri.queryParameters['session_id'];
        print("📍 Web URI: ${uri.toString()}");
        print("📍 Web Query Parameters: ${uri.queryParameters}");
      }
      
      // Alternative: Get from Get.parameters
      if (sessionId == null || sessionId.isEmpty) {
        sessionId = Get.parameters['session_id'];
        print("📍 Get.parameters: ${Get.parameters}");
      }
      
      // Alternative: Get from current route
      if (sessionId == null || sessionId.isEmpty) {
        final currentRoute = Get.currentRoute;
        print("📍 Current Route: $currentRoute");
        
        // Parse from route string
        if (currentRoute.contains('session_id=')) {
          final match = RegExp(r'session_id=([^&]+)').firstMatch(currentRoute);
          if (match != null) {
            sessionId = match.group(1);
          }
        }
      }
      
      print("📍 Session ID: $sessionId");

      if (sessionId == null || sessionId.isEmpty) {
        setState(() {
          isVerifying = false;
          errorMessage = 'No payment session found';
        });
        return;
      }

      // Store session ID for verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_payment_session', sessionId);

      // Verify payment
      await _verifyPayment(sessionId);

    } catch (e) {
      print("❌ Error in payment success: $e");
      setState(() {
        isVerifying = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _verifyPayment(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final baseUrl = ApiConfig.baseUrl;

      print("🟡 Verifying payment for session: $sessionId");
      print("🟡 Base URL: $baseUrl");
      print("🟡 Token exists: ${token != null && token.isNotEmpty}");

      final response = await http.post(
        Uri.parse('$baseUrl/api/coins/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sessionId': sessionId,
        }),
      );

      print("📡 Verify response status: ${response.statusCode}");
      print("📡 Verify response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Clear pending session
          await prefs.remove('pending_payment_session');
          
          setState(() {
            isVerifying = false;
          });
          
          // Show success and navigate back
          _showSuccessAndNavigateBack(data['coinsAdded'], data['newBalance']);
        } else {
          throw Exception(data['message'] ?? 'Verification failed');
        }
      } else {
        throw Exception('Verification failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Verification error: $e");
      setState(() {
        isVerifying = false;
        errorMessage = e.toString();
      });
    }
  }

  void _showSuccessAndNavigateBack(int coinsAdded, int newBalance) {
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
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '+$coinsAdded Coins',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'New Balance: $newBalance coins',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate back to coin purchase screen
              Get.offAllNamed('/');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isVerifying) ...[
                const CircularProgressIndicator(color: primary),
                const SizedBox(height: 24),
                Text(
                  'Verifying your payment...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we confirm your transaction',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ] else if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verification Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
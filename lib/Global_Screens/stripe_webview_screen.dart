import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../Utils/colors.dart';

class StripeWebViewScreen extends StatefulWidget {
  final String projectId;
  final String milestoneId;
  final double amount;

  const StripeWebViewScreen({
    Key? key,
    required this.projectId,
    required this.milestoneId,
    required this.amount,
  }) : super(key: key);

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late WebViewController webViewController;
  bool isLoading = true;
  String paymentUrl = '';
  String clientSecret = '';
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    // Register web implementation
    WebViewPlatform.instance = WebWebViewPlatform();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userEmail = prefs.getString('user_email') ?? 'customer@example.com';
      final userName = prefs.getString('user_name') ?? 'Customer';

      // Create payment intent
      final response = await http.post(
        Uri.parse('$baseUrl/api/milestone-payments/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': widget.projectId,
          'milestoneId': widget.milestoneId,
          'amount': widget.amount,
          'paymentMethod': 'card',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        clientSecret = data['clientSecret'];
        
        // Build payment URL with all parameters
        paymentUrl = 'http://localhost:3001?amount=${widget.amount}&email=$userEmail&name=$userName&project_id=${widget.projectId}&milestone_id=${widget.milestoneId}&client_secret=$clientSecret&token=$token&embedded=true';
        
        setState(() {});
        _loadWebView();
      } else {
        throw Exception('Failed to initialize payment');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Navigator.pop(context);
    }
  }

  void _loadWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            
            // Check if payment success page
            if (url.contains('/success') && url.contains('redirect_status=succeeded')) {
              _handlePaymentSuccess();
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: $error');
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
  }

  void _handlePaymentSuccess() {
    // Close WebView and show success
    Navigator.pop(context, true);
    Get.snackbar(
      'Success! 🎉',
      'Payment completed successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Secure Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (paymentUrl.isNotEmpty)
            WebViewWidget(
              controller: webViewController,
            ),
          if (isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading secure payment...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
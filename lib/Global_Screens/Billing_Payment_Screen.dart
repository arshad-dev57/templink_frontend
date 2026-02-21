import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/config/api_config.dart';

class CoinPackage {
  final String id;
  final String name;
  final int coins;
  final int price; 

  CoinPackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.price,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      coins: json['coins'] ?? 0,
      price: json['price'] ?? 0,
    );
  }

  String get displayPrice => '\$${(price / 100).toStringAsFixed(2)}';
  double get priceInDollars => price / 100;
  double get coinsPerDollar => priceInDollars > 0 ? (coins / priceInDollars) : 0;
}

class CoinsPurchaseScreen extends StatefulWidget {
  const CoinsPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<CoinsPurchaseScreen> createState() => _CoinsPurchaseScreenState();
}

class _CoinsPurchaseScreenState extends State<CoinsPurchaseScreen> {
  final String baseUrl = ApiConfig.baseUrl;
  
  var isLoading = true.obs;
  var isProcessing = false.obs;
  var packages = <CoinPackage>[].obs;
  var selectedPackage = Rx<CoinPackage?>(null);
  var currentBalance = 0.obs;
  var selectedPaymentMethod = 'card'.obs;

  final List<Map<String, dynamic>> paymentMethods = [
    {'id': 'card', 'name': 'Credit / Debit Card', 'icon': Icons.credit_card, 'color': Colors.blue},
    {'id': 'google_pay', 'name': 'Google Pay', 'icon': Icons.payment, 'color': Colors.black},
    {'id': 'apple_pay', 'name': 'Apple Pay', 'icon': Icons.apple, 'color': Colors.black},
  ];

  @override
  void initState() {
    super.initState();
    fetchPackagesAndBalance();
  }

  Future<void> fetchPackagesAndBalance() async {
    await Future.wait([
      fetchPackages(),
      fetchBalance(),
    ]);
  }

  Future<void> fetchPackages() async {
    try {
      isLoading.value = true;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/coins/packages'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final List packagesList = jsonResponse['packages'] ?? [];
          packages.value = packagesList.map((p) => CoinPackage.fromJson(p)).toList();
        }
      }
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/coins/balance'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          currentBalance.value = jsonResponse['balance'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  Future<void> purchaseCoins(CoinPackage package) async {
    try {
      isProcessing.value = true;
      selectedPackage.value = package;

      // 1. Create payment intent
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final paymentResponse = await http.post(
        Uri.parse('$baseUrl/api/coins/create-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'packageId': package.id,
        }),
      );

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
      bool confirm = await _showConfirmationDialog(package);
      if (!confirm) {
        isProcessing.value = false;
        selectedPackage.value = null;
        return;
      }
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

      final verifyResponse = await http.post(
        Uri.parse('$baseUrl/api/coins/verify-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentIntentId': paymentData['id'] ?? clientSecret.split('_secret')[0],
          'packageId': package.id,
        }),
      );
      if (Get.isDialogOpen ?? false) Get.back();

      if (verifyResponse.statusCode == 200) {
        final verifyData = jsonDecode(verifyResponse.body);
        if (verifyData['success'] == true) {
          currentBalance.value = verifyData['newBalance'] ?? 0;
          
          _showSuccessDialog(
            package.coins,
            verifyData['newBalance'],
          );
        }
      } else {
        throw Exception('Payment verification failed');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      String errorMessage = 'Payment failed';
      if (e.toString().contains('UserCanceled')) {
        errorMessage = 'Payment cancelled';
      } else if (e.toString().contains('Failed')) {
        errorMessage = 'Payment failed. Please try again.';
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
      selectedPackage.value = null;
    }
  }

  Future<bool> _showConfirmationDialog(CoinPackage package) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirm Purchase',
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
                    child: const Center(
                      child: Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${package.coins} Coins',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  package.displayPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Method:',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Icon(
                      paymentMethods.firstWhere((m) => m['id'] == selectedPaymentMethod.value)['icon'],
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      paymentMethods.firstWhere((m) => m['id'] == selectedPaymentMethod.value)['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccessDialog(int coinsAdded, int newBalance) {
    showDialog(
      context: context,
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
            const Text(
              'Purchase Successful!',
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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
              Navigator.pop(context);
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buy Coins",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bolt,
                  color: primary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Obx(() => Text(
                  '${currentBalance.value}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Why buy coins?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Submit proposals (13 coins each)\n• Boost your profile visibility\n• Get more client interviews',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    "Select Package",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ...packages.map((package) => _buildPackageCard(package)).toList(),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildPaymentMethods(),
                  
                  const SizedBox(height: 30),
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
                            'Processing...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildPackageCard(CoinPackage package) {
    final isSelected = selectedPackage.value?.id == package.id;
    String savings = '';
    if (package.id == 'popular') {
      savings = '🔥 Most Popular';
    } else if (package.id == 'pro') {
      savings = '✨ Best Value';
    } else if (package.id == 'enterprise') {
      savings = '🚀 Enterprise';
    }
    
    final coinsPerDollar = package.coinsPerDollar.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (savings.isNotEmpty)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: package.id == 'popular' ? Colors.orange :
                         package.id == 'pro' ? Colors.purple :
                         Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  savings,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '💰',
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${package.coins} Coins',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package.displayPrice,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Value',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$coinsPerDollar coins/\$',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessing.value ? null : () => purchaseCoins(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? primary : Colors.grey.shade100,
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isSelected ? 4 : 0,
                    ),
                    child: isProcessing.value && selectedPackage.value?.id == package.id
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isSelected ? 'Selected' : 'Select Package',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: paymentMethods.map((method) {
          final isSelected = selectedPaymentMethod.value == method['id'];
          return GestureDetector(
            onTap: () => selectedPaymentMethod.value = method['id'],
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: method != paymentMethods.last ? Colors.grey.shade200 : Colors.transparent,
                  ),
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
                    child: Text(
                      method['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Radio<String>(
                    value: method['id'],
                    groupValue: selectedPaymentMethod.value,
                    onChanged: (value) => selectedPaymentMethod.value = value!,
                    activeColor: primary,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
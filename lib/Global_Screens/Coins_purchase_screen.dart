import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/config/api_config.dart';

// ─── Design tokens (matches Applied Jobs screen) ─────────────────────────────────
const _bg      = Color(0xFFF7F8FA);
const _surface = Colors.white;
const _border  = Color(0xFFE5E7EB);
const _text1   = Color(0xFF111827);
const _text2   = Color(0xFF6B7280);
const _text3   = Color(0xFF9CA3AF);
const _green   = Color(0xFF16A34A);
const _r       = 12.0;

class CoinPackage {
  final String id;
  final String name;
  final int coins;
  final int price;
  final String? badge;
  final String? badgeColor;

  CoinPackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.price,
    this.badge,
    this.badgeColor,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    String? badge;
    String? badgeColor;
    
    if (json['id'] == 'popular') {
      badge = '🔥 Most Popular';
      badgeColor = '#F59E0B';
    } else if (json['id'] == 'pro') {
      badge = '✨ Best Value';
      badgeColor = '#8B5CF6';
    } else if (json['id'] == 'enterprise') {
      badge = '🚀 Enterprise';
      badgeColor = '#3B82F6';
    }
    
    return CoinPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      coins: json['coins'] ?? 0,
      price: json['price'] ?? 0,
      badge: badge,
      badgeColor: badgeColor,
    );
  }

  String get displayPrice => '\$${(price / 100).toStringAsFixed(2)}';
  double get priceInDollars => price / 100;
  double get coinsPerDollar => priceInDollars > 0 ? (coins / priceInDollars) : 0;
}

class CoinsPurchaseScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;
  
  const CoinsPurchaseScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

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
    {'id': 'card', 'name': 'Credit / Debit Card', 'icon': Icons.credit_card, 'color': Color(0xFF3B82F6)},
    {'id': 'google_pay', 'name': 'Google Pay', 'icon': Icons.payment, 'color': Color(0xFF1F2937)},
    {'id': 'apple_pay', 'name': 'Apple Pay', 'icon': Icons.apple, 'color': Color(0xFF1F2937)},
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
          'Content-Type': 'application/json',
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
          'Content-Type': 'application/json',
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

      bool confirm = await _showConfirmationDialog(package);
      if (!confirm) {
        isProcessing.value = false;
        selectedPackage.value = null;
        return;
      }

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
          _showSuccessDialog(package.coins, verifyData['newBalance']);
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
                color: _green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: _green,
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
                      color: _text2,
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
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primary));
        }

        return Stack(
          children: [
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Banner
                SliverToBoxAdapter(
                  child: _buildInfoBanner(),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                
                // Section Title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Select Package",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _text1,
                      ),
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                
                // Packages List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPackageCard(packages[i]),
                      ),
                      childCount: packages.length,
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                
                // Payment Method Section
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _text1,
                      ),
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPaymentMethods(),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
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
                          CircularProgressIndicator(color: primary),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surface,
      foregroundColor: _text1,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: widget.onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 17, color: _text2),
              onPressed: widget.onBackPressed)
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 17, color: _text2),
              onPressed: () => Navigator.pop(context)),
      title: const Text(
        'Buy Coins',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _text1,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: _border),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                size: 16,
              ),
              const SizedBox(width: 6),
              Obx(() => Text(
                '${currentBalance.value}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_r),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why buy coins?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Submit proposals (13 coins each)\n• Boost your profile visibility\n• Get more client interviews',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(CoinPackage package) {
    final isSelected = selectedPackage.value?.id == package.id;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (package.badge != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(int.parse(package.badgeColor!.substring(1), radix: 16)).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  package.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(_r),
              border: Border.all(
                color: isSelected ? primary : _border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '💰',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  package.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _text1,
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
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _text3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  package.displayPrice,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _text1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: _border,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Value',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _text3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${package.coinsPerDollar.toStringAsFixed(1)} coins/\$',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withOpacity(0.05) : const Color(0xFFF9FAFB),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(_r),
                    ),
                    border: Border(
                      top: BorderSide(color: _border),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProcessing.value ? null : () => purchaseCoins(package),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? primary : Colors.white,
                        foregroundColor: isSelected ? Colors.white : primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? primary : _border,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: isProcessing.value && selectedPackage.value?.id == package.id
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isSelected ? Colors.white : primary,
                              ),
                            )
                          : Text(
                              isSelected ? 'Selected' : 'Select Package',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
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
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: paymentMethods.asMap().entries.map((entry) {
          final index = entry.key;
          final method = entry.value;
          final isSelected = selectedPaymentMethod.value == method['id'];
          final isLast = index == paymentMethods.length - 1;
          
          return GestureDetector(
            onTap: () => selectedPaymentMethod.value = method['id'],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? primary.withOpacity(0.03) : Colors.transparent,
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(_r))
                    : null,
                border: !isLast
                    ? Border(bottom: BorderSide(color: _border))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (method['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _text1,
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? primary : _border,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary,
                              ),
                            ),
                          )
                        : null,
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
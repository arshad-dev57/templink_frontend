import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';

import 'dart:html'
  if (dart.library.io) '../../Utils/html_stub.dart' as html;

class WalletController extends GetxController {
  final String baseUrl = ApiConfig.baseUrl;

  // ─── Loading states ───────────────────────────────────────────────
  final isLoading = false.obs;
  final isProcessing = false.obs;
  final isRefreshing = false.obs;

  // ─── Wallet data ──────────────────────────────────────────────────
  final walletBalance = 0.0.obs;
  final availableBalance = 0.0.obs;
  final pendingAmount = 0.0.obs;
  final currency = 'USD'.obs;

  // ─── Stripe Connect ───────────────────────────────────────────────
  final isStripeConnected = false.obs;
  final isOnboarded = false.obs;
  final isPayoutsEnabled = false.obs;
  final stripeAccountId = ''.obs;

  // ─── Lists ────────────────────────────────────────────────────────
  final transactions = <Map<String, dynamic>>[].obs;
  final withdrawals = <Map<String, dynamic>>[].obs;

  // ─── UI state ─────────────────────────────────────────────────────
  final selectedTab = 0.obs;

  // ─── Withdrawal form ──────────────────────────────────────────────
  final withdrawAmountController = TextEditingController();

  // ─── Deposit form ─────────────────────────────────────────────────
  final depositAmountController = TextEditingController();

  // ─── Withdrawal limits (from server) ─────────────────────────────
  var withdrawalLimits = <String, dynamic>{
    'minimum': 10,
    'maximum': 5000,
    'fee': '0%',
    'dailyLimit': 10000,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  @override
  void onClose() {
    withdrawAmountController.dispose();
    depositAmountController.dispose();
    super.onClose();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    await Future.wait([
      fetchWalletDetails(),
      fetchTransactions(),
      fetchWithdrawals(),
      checkStripeStatus(),
    ]);
    isLoading.value = false;
  }

  Future<void> refresh() async {
    isRefreshing.value = true;
    await _loadAll();
    isRefreshing.value = false;
  }

  // ─────────────────────────────────────────────────────────────────
  // API CALLS
  // ─────────────────────────────────────────────────────────────────

  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> fetchWalletDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/details'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final d = data['data'];
          walletBalance.value = (d['balance'] ?? 0).toDouble();
          availableBalance.value = (d['availableBalance'] ?? 0).toDouble();
          pendingAmount.value = (d['pendingWithdrawals'] ?? 0).toDouble();
          currency.value = d['currency'] ?? 'USD';
          isPayoutsEnabled.value = d['stripePayoutsEnabled'] ?? false;
          isOnboarded.value = d['stripeConnected'] ?? false;

          if (d['withdrawalLimits'] != null) {
            withdrawalLimits.value = Map<String, dynamic>.from(d['withdrawalLimits']);
          }
        }
      }
    } catch (e) {
      debugPrint('fetchWalletDetails error: $e');
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/transactions?limit=20'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          transactions.value = List<Map<String, dynamic>>.from(
            data['data']['transactions'] ?? [],
          );
        }
      }
    } catch (e) {
      debugPrint('fetchTransactions error: $e');
    }
  }

  Future<void> fetchWithdrawals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/withdrawals'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          withdrawals.value = List<Map<String, dynamic>>.from(
            data['data']['withdrawals'] ?? [],
          );
        }
      }
    } catch (e) {
      debugPrint('fetchWithdrawals error: $e');
    }
  }

  Future<void> checkStripeStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/wallet/connect/status'),
        headers: await _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        isStripeConnected.value = data['connected'] ?? false;
        isOnboarded.value = data['onboarded'] ?? false;
        isPayoutsEnabled.value = data['payoutsEnabled'] ?? false;
        stripeAccountId.value = data['accountId'] ?? '';
      }
    } catch (e) {
      debugPrint('checkStripeStatus error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // STRIPE CONNECT ONBOARDING
  // ─────────────────────────────────────────────────────────────────

  Future<void> connectBankAccount() async {
    try {
      isProcessing.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/api/wallet/connect/create'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['onboardingUrl'] as String?;

        if (url != null && kIsWeb) {
          html.window.open(url, '_blank');
          _showSnack(
            'Bank Account Setup',
            'Complete your bank setup in the new tab. Return here when done.',
            isError: false,
            icon: Icons.open_in_new,
          );
        } else {
          _showSnack('Open URL', url ?? '', isError: false);
        }
      } else {
        final err = jsonDecode(response.body);
        _showSnack('Error', err['message'] ?? 'Failed to start bank setup', isError: true);
      }
    } catch (e) {
      _showSnack('Error', e.toString(), isError: true);
    } finally {
      isProcessing.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // DEPOSIT (ADD FUNDS)
  // ─────────────────────────────────────────────────────────────────

  Future<void> deposit() async {
    final amountText = depositAmountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showSnack('Invalid Amount', 'Enter a valid deposit amount', isError: true);
      return;
    }

    if (amount < 10) {
      _showSnack('Too Low', 'Minimum deposit is \$10', isError: true);
      return;
    }

    if (amount > 5000) {
      _showSnack('Too High', 'Maximum deposit is \$5000', isError: true);
      return;
    }

    try {
      isProcessing.value = true;

      // Create Stripe Checkout Session for deposit
      final response = await http.post(
        Uri.parse('$baseUrl/api/wallet/deposit/create-checkout'),
        headers: await _headers,
        body: jsonEncode({'amount': amount}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final checkoutUrl = data['checkoutUrl'] as String;

        if (kIsWeb) {
          // Web: Open in new tab
          html.window.open(checkoutUrl, '_blank');
          _showSnack(
            'Deposit Initiated',
            'Complete payment in the new tab. Funds will be added automatically.',
            isError: false,
            icon: Icons.open_in_new,
          );
        } else {
          // Mobile: Use URL launcher
          _showSnack('Open URL', checkoutUrl, isError: false);
        }

        // Clear amount field
        depositAmountController.clear();
        
        // Wait a bit then refresh wallet
        await Future.delayed(const Duration(seconds: 5));
        await refresh();
      } else {
        _showSnack('Failed', data['message'] ?? 'Deposit failed', isError: true);
      }
    } catch (e) {
      _showSnack('Error', e.toString(), isError: true);
    } finally {
      isProcessing.value = false;
    }
  }

  // Alternative deposit method using Payment Intent (for mobile apps)
  Future<void> depositWithPaymentIntent() async {
    final amountText = depositAmountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showSnack('Invalid Amount', 'Enter a valid deposit amount', isError: true);
      return;
    }

    if (amount < 10) {
      _showSnack('Too Low', 'Minimum deposit is \$10', isError: true);
      return;
    }

    if (amount > 5000) {
      _showSnack('Too High', 'Maximum deposit is \$5000', isError: true);
      return;
    }

    try {
      isProcessing.value = true;

      // Create Payment Intent
      final response = await http.post(
        Uri.parse('$baseUrl/api/wallet/deposit/create-intent'),
        headers: await _headers,
        body: jsonEncode({'amount': amount}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final clientSecret = data['clientSecret'];
        final paymentIntentId = data['paymentIntentId'];
        
        // For web, open Stripe Payment Element
        if (kIsWeb) {
          // Open Stripe Payment Element page (you need to create this)
          _showSnack(
            'Payment Required',
            'Payment page will open. Complete payment to add funds.',
            isError: false,
          );
        } else {
          // For mobile, use Stripe SDK
          _showSnack('Mobile Payment', 'Use Stripe SDK for payment', isError: false);
        }
      } else {
        _showSnack('Failed', data['message'] ?? 'Deposit failed', isError: true);
      }
    } catch (e) {
      _showSnack('Error', e.toString(), isError: true);
    } finally {
      isProcessing.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // WITHDRAWAL
  // ─────────────────────────────────────────────────────────────────

  Future<void> requestWithdrawal() async {
    final amountText = withdrawAmountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showSnack('Invalid Amount', 'Enter a valid withdrawal amount', isError: true);
      return;
    }

    final minAmount = (withdrawalLimits['minimum'] ?? 10).toDouble();
    final maxAmount = (withdrawalLimits['maximum'] ?? 5000).toDouble();

    if (amount < minAmount) {
      _showSnack('Too Low', 'Minimum withdrawal is \$${minAmount.toStringAsFixed(0)}', isError: true);
      return;
    }
    if (amount > maxAmount) {
      _showSnack('Too High', 'Maximum per withdrawal is \$${maxAmount.toStringAsFixed(0)}', isError: true);
      return;
    }
    if (amount > availableBalance.value) {
      _showSnack('Insufficient Balance',
        'Available: \$${availableBalance.value.toStringAsFixed(2)}', isError: true);
      return;
    }

    try {
      isProcessing.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/api/wallet/withdraw'),
        headers: await _headers,
        body: jsonEncode({'amount': amount}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        withdrawAmountController.clear();
        _showSnack(
          'Withdrawal Initiated',
          'Funds will arrive in 1-2 business days.',
          isError: false,
          icon: Icons.check_circle_outline,
        );
        await refresh();
      } else {
        if (data['requiresOnboarding'] == true) {
          _promptOnboarding();
        } else {
          _showSnack('Failed', data['message'] ?? 'Withdrawal failed', isError: true);
        }
      }
    } catch (e) {
      _showSnack('Error', e.toString(), isError: true);
    } finally {
      isProcessing.value = false;
    }
  }

  void _promptOnboarding() {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Bank Account Required'),
      content: const Text(
        'You need to connect your bank account before withdrawing. '
        'This is a one-time setup via Stripe.',
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            connectBankAccount();
          },
          child: const Text('Connect Now'),
        ),
      ],
    ));
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────

  String formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

  String formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return isoDate.substring(0, 10);
    }
  }

  String _monthName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];

  Color statusColor(String status) {
    switch (status) {
      case 'completed':   return const Color(0xFF22C55E);
      case 'processing':  return const Color(0xFF3B82F6);
      case 'pending':     return const Color(0xFFF59E0B);
      case 'failed':
      case 'cancelled':   return const Color(0xFFEF4444);
      default:            return const Color(0xFF9CA3AF);
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'completed':   return 'Completed';
      case 'processing':  return 'Processing';
      case 'pending':     return 'Pending';
      case 'failed':      return 'Failed';
      case 'cancelled':   return 'Cancelled';
      default:            return status;
    }
  }

  void _showSnack(String title, String message, {
    required bool isError,
    IconData? icon,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError
          ? const Color(0xFFEF4444).withOpacity(0.95)
          : const Color(0xFF22C55E).withOpacity(0.95),
      colorText: Colors.white,
      icon: Icon(
        icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }
}
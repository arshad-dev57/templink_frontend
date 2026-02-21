// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:flutter_braintree/flutter_braintree.dart';
// import 'package:templink/Employeer/Controller/billing_api_controller.dart';

// class BillingPaymentsController extends GetxController {
//   BillingPaymentsController({required this.api});

//   final BillingApi api;

//   final isLoading = false.obs;
//   final isBusy = false.obs;

//   final bannerMessage = RxnString();

//   final billingCycle = ''.obs;
//   final terms = ''.obs;
//   final outstandingBalance = 0.0.obs;
//   final methods = <BillingMethodModel>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     load();
//   }

//   Future<void> load() async {
//     try {
//       isLoading.value = true;
//       final summary = await api.fetchBillingSummary();
//       billingCycle.value = summary.billingCycle;
//       terms.value = summary.terms;
//       outstandingBalance.value = summary.outstandingBalance;
//       methods.assignAll(_sortMethods(summary.methods));
//     } catch (e) {
//       _toastError("Failed to load billing info", e);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   List<BillingMethodModel> _sortMethods(List<BillingMethodModel> list) {
//     final primary = list.where((m) => m.isPrimary).toList();
//     final rest = list.where((m) => !m.isPrimary).toList();
//     return [...primary, ...rest];
//   }

//   void closeBanner() => bannerMessage.value = null;

//   Future<void> addCardWithStripeSheet() async {
//     try {
//       // Null safety check
//       if (isBusy.value == true) {
//         print('⚠️ Already busy, ignoring tap');
//         return;
//       }

//       isBusy.value = true;

//       print('🎯 Starting Stripe payment sheet flow...');

//       // 1) Get secrets from your backend
//       print('Step 1: Fetching Stripe setup sheet from backend...');
//       final sheet = await api.createStripeSetupSheet();

//       // Validate response data
//       if (sheet.customerId.isEmpty ||
//           sheet.ephemeralKeySecret.isEmpty ||
//           sheet.setupIntentClientSecret.isEmpty) {
//         throw Exception('Invalid Stripe setup data received from backend');
//       }

//       print('✓ Received sheet data');
//       print('  - Customer ID: ${sheet.customerId}');
//       print('  - Ephemeral Key: ${sheet.ephemeralKeySecret.substring(0, 30)}...');
//       print('  - Setup Intent: ${sheet.setupIntentClientSecret.substring(0, 30)}...');
//       print('  - Merchant: ${sheet.merchantDisplayName}');

//       // 2) Initialize Stripe PaymentSheet
//       print('Step 2: Initializing Stripe PaymentSheet...');
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           merchantDisplayName: sheet.merchantDisplayName,
//           customerId: sheet.customerId,
//           customerEphemeralKeySecret: sheet.ephemeralKeySecret,
//           setupIntentClientSecret: sheet.setupIntentClientSecret,
//           style: ThemeMode.light,
//           customFlow: false,
//         ),
//       );
//       print('✓ PaymentSheet initialized successfully');

//       // 3) Present the payment sheet to user
//       print('Step 3: Presenting PaymentSheet to user...');
//       await Stripe.instance.presentPaymentSheet();
//       print('✓ PaymentSheet completed successfully');

//       // 4) Sync with backend
//       print('Step 4: Syncing with backend...');
//       await api.syncAfterStripeSetup();

//       bannerMessage.value = "✅ Your card was added successfully.";
//       await load();

//       // Safe navigation check
//       if (Get.isBottomSheetOpen == true) {
//         Get.back();
//       }
//     } on StripeException catch (e) {
//       print('❌ StripeException: ${e.error.code} - ${e.error.message}');
      
//       // User canceled - don't show error
//       if (e.error.code == FailureCode.Canceled) {
//         print('User canceled the payment sheet');
//         return;
//       }
      
//       _toastError("Stripe error", e.error.message ?? e.toString());
//     } catch (e, stackTrace) {
//       print('❌ Error in addCardWithStripeSheet: $e');
//       print('Stack trace: $stackTrace');
//       _toastError("Failed to add card", e.toString());
//     } finally {
//       isBusy.value = false;
//       print('Stripe flow completed');
//     }
//   }

//   Future<void> addPayPalVault() async {
//     try {
//       if (isBusy.value == true) {
//         print('⚠️ Already busy, ignoring tap');
//         return;
//       }

//       isBusy.value = true;

//       print('🎯 Starting PayPal vault flow...');

//       final clientToken = await api.createBraintreeClientToken();

//       final request = BraintreePayPalRequest(
//         billingAgreementDescription: "Templink billing agreement",
//         displayName: "Templink",
//         amount: "0.00",
//       );

//       final result = await Braintree.requestPaypalNonce(clientToken, request);

//       if (result == null) {
//         print('User canceled PayPal flow');
//         return;
//       }

//       await api.vaultPayPalNonce(result.nonce);

//       bannerMessage.value = "✅ PayPal connected successfully.";
//       await load();

//       if (Get.isBottomSheetOpen == true) {
//         Get.back();
//       }
//     } catch (e, stackTrace) {
//       print('❌ Error in addPayPalVault: $e');
//       print('Stack trace: $stackTrace');
//       _toastError("Failed to connect PayPal", e);
//     } finally {
//       isBusy.value = false;
//       print('PayPal flow completed');
//     }
//   }

//   Future<void> setPrimary(String methodId) async {
//     try {
//       if (isBusy.value == true) return;

//       isBusy.value = true;
//       await api.setPrimaryMethod(methodId);
//       bannerMessage.value = "Primary billing method updated.";
//       await load();
//     } catch (e) {
//       _toastError("Failed to set primary method", e);
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   Future<void> removeMethod(String methodId) async {
//     try {
//       if (isBusy.value == true) return;

//       isBusy.value = true;
//       await api.removeMethod(methodId);
//       bannerMessage.value = "Billing method removed.";
//       await load();
//     } catch (e) {
//       _toastError("Failed to remove method", e);
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   Future<void> payNow() async {
//     try {
//       if (isBusy.value == true) return;

//       isBusy.value = true;
//       await api.payOutstandingBalanceWithPrimary();
//       bannerMessage.value = "Payment completed successfully.";
//       await load();
//     } catch (e) {
//       _toastError("Payment failed", e);
//     } finally {
//       isBusy.value = false;
//     }
//   }

//   void _toastError(String title, Object e) {
//     Get.snackbar(
//       title,
//       e.toString(),
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       margin: const EdgeInsets.all(12),
//       duration: const Duration(seconds: 3),
//     );
//   }
// }
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// enum BillingMethodType { card, paypal }

// class BillingMethodModel {
//   final String id;
//   final BillingMethodType type;
//   final String title;      // e.g. "MasterCard ending in 3037"
//   final String? subtitle;  // e.g. "Expires 12/28" or PayPal email
//   final bool isPrimary;

//   BillingMethodModel({
//     required this.id,
//     required this.type,
//     required this.title,
//     this.subtitle,
//     required this.isPrimary,
//   });

//   BillingMethodModel copyWith({bool? isPrimary}) => BillingMethodModel(
//         id: id,
//         type: type,
//         title: title,
//         subtitle: subtitle,
//         isPrimary: isPrimary ?? this.isPrimary,
//       );
// }

// class BillingSummary {
//   final String billingCycle; // "Weekly"
//   final String terms;        // "Standard"
//   final double outstandingBalance;
//   final List<BillingMethodModel> methods;

//   BillingSummary({
//     required this.billingCycle,
//     required this.terms,
//     required this.outstandingBalance,
//     required this.methods,
//   });
// }

// class StripeSetupSheetResponse {
//   final String customerId;
//   final String ephemeralKeySecret;
//   final String setupIntentClientSecret;
//   final String merchantDisplayName;

//   StripeSetupSheetResponse({
//     required this.customerId,
//     required this.ephemeralKeySecret,
//     required this.setupIntentClientSecret,
//     required this.merchantDisplayName,
//   });
// }

// abstract class BillingApi {
//   Future<BillingSummary> fetchBillingSummary();
//   Future<StripeSetupSheetResponse> createStripeSetupSheet();
//   Future<void> syncAfterStripeSetup();
//   Future<String> createBraintreeClientToken();
//   Future<void> vaultPayPalNonce(String nonce);
//   Future<void> setPrimaryMethod(String methodId);
//   Future<void> removeMethod(String methodId);
//   Future<void> payOutstandingBalanceWithPrimary();
// }

// /// ----------------------------------------------
// /// REAL IMPLEMENTATION with Node.js Backend
// /// ----------------------------------------------
// class RealBillingApi implements BillingApi {
//   // ⚠️ IMPORTANT: Update this with your backend URL
//   // For Android Emulator: Use 10.0.2.2 instead of localhost
//   // For iOS Simulator: Use localhost
//   // For Real Device: Use your PC's IP address (e.g., 192.168.1.100)
  
//   final String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
//   // final String baseUrl = 'http://localhost:5000'; // iOS simulator
//   // final String baseUrl = 'http://192.168.100.29:5000'; // Real device - YOUR PC IP
  
//   final String? authToken;
//   String? currentCustomerId;

//   RealBillingApi({this.authToken});

//   BillingSummary _summary = BillingSummary(
//     billingCycle: "Weekly",
//     terms: "Standard",
//     outstandingBalance: 125.50,
//     methods: [
//       BillingMethodModel(
//         id: "pm_1",
//         type: BillingMethodType.card,
//         title: "MasterCard ending in 3037",
//         subtitle: "Expires 12/28",
//         isPrimary: true,
//       ),
//     ],
//   );

//   @override
//   Future<BillingSummary> fetchBillingSummary() async {
//     try {
//       print('📡 Fetching billing summary from backend...');
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/billing/summary'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//       ).timeout(const Duration(seconds: 10));

//       print('Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
        
//         return BillingSummary(
//           billingCycle: data['billingCycle'] ?? "Monthly",
//           terms: data['terms'] ?? "Standard",
//           outstandingBalance: (data['outstandingBalance'] ?? 0.0).toDouble(),
//           methods: _parseMethods(data['methods'] ?? []),
//         );
//       }
//     } catch (e) {
//       print('❌ Failed to fetch billing summary from backend: $e');
//       print('⚠️  Using fallback local data');
//     }
    
//     // Fallback to local data
//     await Future.delayed(const Duration(milliseconds: 350));
//     return _summary;
//   }

//   @override
//   Future<StripeSetupSheetResponse> createStripeSetupSheet() async {
//     try {
//       print('📞 Calling Node.js backend for Stripe setup...');
//       print('URL: $baseUrl/api/stripe/create-setup-intent');
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/stripe/create-setup-intent'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode({
//           'email': 'user@templink.com', // TODO: Replace with actual user email
//           'userId': 'user_${DateTime.now().millisecondsSinceEpoch}',
//         }),
//       ).timeout(const Duration(seconds: 15));

//       print('Response status: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
        
//         if (data['success'] == true) {
//           currentCustomerId = data['customerId'];
          
//           print('✅ Stripe setup created successfully');
//           print('Customer ID: ${data['customerId']}');
//           print('Ephemeral Key: ${data['ephemeralKeySecret'].substring(0, 30)}...');
//           print('Setup Intent: ${data['setupIntentClientSecret'].substring(0, 30)}...');
          
//           return StripeSetupSheetResponse(
//             customerId: data['customerId'],
//             ephemeralKeySecret: data['ephemeralKeySecret'],
//             setupIntentClientSecret: data['setupIntentClientSecret'],
//             merchantDisplayName: data['merchantDisplayName'] ?? 'Templink App',
//           );
//         } else {
//           throw Exception('Backend error: ${data['error']}');
//         }
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception('HTTP ${response.statusCode}: ${error['error'] ?? 'Unknown error'}');
//       }
//     } catch (e) {
//       print('❌ Failed to create Stripe setup: $e');
//       print('⚠️  THIS IS EXPECTED if backend is not running');
      
//       // Re-throw the error so the controller can handle it properly
//       throw Exception('Backend connection failed. Please ensure your Node.js backend is running. Error: $e');
//     }
//   }

//   @override
//   Future<void> syncAfterStripeSetup() async {
//     try {
//       print('🔄 Syncing with backend after Stripe setup...');
      
//       if (currentCustomerId != null) {
//         final response = await http.post(
//           Uri.parse('$baseUrl/api/stripe/save-payment-method'),
//           headers: {
//             'Content-Type': 'application/json',
//             if (authToken != null) 'Authorization': 'Bearer $authToken',
//           },
//           body: jsonEncode({
//             'customerId': currentCustomerId,
//           }),
//         ).timeout(const Duration(seconds: 10));

//         if (response.statusCode == 200) {
//           print('✅ Synced with backend successfully');
//         } else {
//           print('⚠️  Sync response: ${response.statusCode}');
//         }
//       }
//     } catch (e) {
//       print('❌ Sync failed: $e');
//       print('⚠️  Continuing anyway...');
//     }
    
//     await Future.delayed(const Duration(milliseconds: 250));
    
//     // Update local data (optimistic update)
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: [
//         ..._summary.methods,
//         BillingMethodModel(
//           id: "card_${DateTime.now().millisecondsSinceEpoch}",
//           type: BillingMethodType.card,
//           title: "New Card",
//           subtitle: "Added via Stripe",
//           isPrimary: false,
//         ),
//       ],
//     );
//   }

//   @override
//   Future<String> createBraintreeClientToken() async {
//     try {
//       print('📡 Fetching Braintree client token...');
      
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/braintree/client-token'),
//         headers: {
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print('✅ Braintree token received');
//         return data['token'] ?? data['clientToken'];
//       }
//     } catch (e) {
//       print('❌ Failed to get Braintree token: $e');
//       throw Exception('Failed to connect to backend for PayPal setup');
//     }
    
//     throw Exception('Invalid response from Braintree backend');
//   }

//   @override
//   Future<void> vaultPayPalNonce(String nonce) async {
//     try {
//       print('🔐 Vaulting PayPal nonce...');
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/braintree/vault-nonce'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode({'nonce': nonce}),
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         print('✅ PayPal nonce vaulted successfully');
//       }
//     } catch (e) {
//       print('❌ Failed to vault PayPal nonce: $e');
//     }
    
//     await Future.delayed(const Duration(milliseconds: 300));
    
//     // Optimistic update
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: [
//         ..._summary.methods,
//         BillingMethodModel(
//           id: "pp_${DateTime.now().millisecondsSinceEpoch}",
//           type: BillingMethodType.paypal,
//           title: "PayPal",
//           subtitle: "Connected account",
//           isPrimary: false,
//         ),
//       ],
//     );
//   }

//   @override
//   Future<void> setPrimaryMethod(String methodId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/billing/set-primary'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode({'methodId': methodId}),
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         print('✅ Primary method updated on backend');
//       }
//     } catch (e) {
//       print('❌ Failed to set primary method: $e');
//     }
    
//     await Future.delayed(const Duration(milliseconds: 250));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: _summary.methods
//           .map((m) => m.copyWith(isPrimary: m.id == methodId))
//           .toList(),
//     );
//   }

//   @override
//   Future<void> removeMethod(String methodId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/api/billing/methods/$methodId'),
//         headers: {
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         print('✅ Method removed from backend');
//       }
//     } catch (e) {
//       print('❌ Failed to remove method: $e');
//     }
    
//     await Future.delayed(const Duration(milliseconds: 250));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: _summary.methods.where((m) => m.id != methodId).toList(),
//     );
    
//     // Ensure at least one primary method
//     if (_summary.methods.isNotEmpty && !_summary.methods.any((m) => m.isPrimary)) {
//       _summary = BillingSummary(
//         billingCycle: _summary.billingCycle,
//         terms: _summary.terms,
//         outstandingBalance: _summary.outstandingBalance,
//         methods: [
//           _summary.methods.first.copyWith(isPrimary: true),
//           ..._summary.methods.skip(1),
//         ],
//       );
//     }
//   }

//   @override
//   Future<void> payOutstandingBalanceWithPrimary() async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/billing/pay-balance'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (authToken != null) 'Authorization': 'Bearer $authToken',
//         },
//       ).timeout(const Duration(seconds: 15));

//       if (response.statusCode == 200) {
//         print('✅ Payment processed on backend');
//       }
//     } catch (e) {
//       print('❌ Failed to process payment: $e');
//     }
    
//     await Future.delayed(const Duration(milliseconds: 400));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: 0.0,
//       methods: _summary.methods,
//     );
//   }

//   List<BillingMethodModel> _parseMethods(List<dynamic> methods) {
//     return methods.map((m) => BillingMethodModel(
//       id: m['id'] ?? 'unknown',
//       type: m['type'] == 'paypal' ? BillingMethodType.paypal : BillingMethodType.card,
//       title: m['title'] ?? 'Payment Method',
//       subtitle: m['subtitle'],
//       isPrimary: m['isPrimary'] ?? false,
//     )).toList();
//   }
// }

// /// ----------------------------------------------
// /// MOCK IMPLEMENTATION (for testing UI without backend)
// /// ----------------------------------------------
// class MockBillingApi implements BillingApi {
//   BillingSummary _summary = BillingSummary(
//     billingCycle: "Weekly",
//     terms: "Standard",
//     outstandingBalance: 125.50,
//     methods: [
//       BillingMethodModel(
//         id: "pm_1",
//         type: BillingMethodType.card,
//         title: "MasterCard ending in 3037",
//         subtitle: "Expires 12/28",
//         isPrimary: true,
//       ),
//     ],
//   );

//   @override
//   Future<BillingSummary> fetchBillingSummary() async {
//     print('📦 MockAPI: Fetching billing summary...');
//     await Future.delayed(const Duration(milliseconds: 500));
//     return _summary;
//   }

//   @override
//   Future<StripeSetupSheetResponse> createStripeSetupSheet() async {
//     print('📦 MockAPI: Creating Stripe setup (simulated)...');
//     await Future.delayed(const Duration(milliseconds: 800));
    
//     // These are FAKE test values for UI testing only
//     return StripeSetupSheetResponse(
//       customerId: "cus_mock_${DateTime.now().millisecondsSinceEpoch}",
//       ephemeralKeySecret: "ek_test_mock_secret_key_${DateTime.now().millisecondsSinceEpoch}",
//       setupIntentClientSecret: "seti_mock_client_secret_${DateTime.now().millisecondsSinceEpoch}",
//       merchantDisplayName: "Templink App (Mock)",
//     );
//   }

//   @override
//   Future<void> syncAfterStripeSetup() async {
//     print('📦 MockAPI: Syncing after Stripe setup...');
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: [
//         ..._summary.methods,
//         BillingMethodModel(
//           id: "card_${DateTime.now().millisecondsSinceEpoch}",
//           type: BillingMethodType.card,
//           title: "Visa ending in 4242",
//           subtitle: "Expires 12/29",
//           isPrimary: false,
//         ),
//       ],
//     );
    
//     print('✅ MockAPI: Card added successfully');
//   }

//   @override
//   Future<String> createBraintreeClientToken() async {
//     print('📦 MockAPI: Creating Braintree token...');
//     await Future.delayed(const Duration(milliseconds: 500));
//     return "sandbox_mock_token_${DateTime.now().millisecondsSinceEpoch}";
//   }

//   @override
//   Future<void> vaultPayPalNonce(String nonce) async {
//     print('📦 MockAPI: Vaulting PayPal nonce...');
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: [
//         ..._summary.methods,
//         BillingMethodModel(
//           id: "pp_${DateTime.now().millisecondsSinceEpoch}",
//           type: BillingMethodType.paypal,
//           title: "PayPal",
//           subtitle: "user@example.com",
//           isPrimary: false,
//         ),
//       ],
//     );
    
//     print('✅ MockAPI: PayPal connected successfully');
//   }

//   @override
//   Future<void> setPrimaryMethod(String methodId) async {
//     print('📦 MockAPI: Setting primary method...');
//     await Future.delayed(const Duration(milliseconds: 400));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: _summary.methods
//           .map((m) => m.copyWith(isPrimary: m.id == methodId))
//           .toList(),
//     );
    
//     print('✅ MockAPI: Primary method updated');
//   }

//   @override
//   Future<void> removeMethod(String methodId) async {
//     print('📦 MockAPI: Removing method...');
//     await Future.delayed(const Duration(milliseconds: 400));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: _summary.outstandingBalance,
//       methods: _summary.methods.where((m) => m.id != methodId).toList(),
//     );
    
//     // Ensure at least one primary
//     if (_summary.methods.isNotEmpty && !_summary.methods.any((m) => m.isPrimary)) {
//       _summary = BillingSummary(
//         billingCycle: _summary.billingCycle,
//         terms: _summary.terms,
//         outstandingBalance: _summary.outstandingBalance,
//         methods: [
//           _summary.methods.first.copyWith(isPrimary: true),
//           ..._summary.methods.skip(1),
//         ],
//       );
//     }
    
//     print('✅ MockAPI: Method removed');
//   }

//   @override
//   Future<void> payOutstandingBalanceWithPrimary() async {
//     print('📦 MockAPI: Processing payment...');
//     await Future.delayed(const Duration(milliseconds: 1000));
    
//     _summary = BillingSummary(
//       billingCycle: _summary.billingCycle,
//       terms: _summary.terms,
//       outstandingBalance: 0.0,
//       methods: _summary.methods,
//     );
    
//     print('✅ MockAPI: Payment successful');
//   }
// }
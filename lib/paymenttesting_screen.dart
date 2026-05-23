// // lib/controllers/payment_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:templink/Services/stripe_web_service.dart';
// // lib/controllers/payment_controller.dart
// import 'package:get/get.dart';
// // lib/controllers/payment_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class PaymentController extends GetxController {
//   // final StripeWebService stripeService = StripeWebService();
  
//   var isLoading = false.obs;
//   var errorMessage = ''.obs;
  
//   final amountController = TextEditingController();
//   final emailController = TextEditingController();
//   final nameController = TextEditingController();
  
//   @override
//   void onInit() {
//     super.onInit();
//     // Small delay to ensure DOM is ready
//     Future.delayed(Duration(milliseconds: 500), () {
//       stripeService.initializeStripe();
//     });
//   }
  
//   @override
//   void onClose() {
//     amountController.dispose();
//     emailController.dispose();
//     nameController.dispose();
//     super.onClose();
//   }
  
//   void setAmount(double amount) {
//     amountController.text = amount.toString();
//   }
  
//   Future<void> processPayment() async {
//     // Validation
//     if (nameController.text.isEmpty) {
//       Get.snackbar('Error', 'Please enter your name',
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
    
//     if (emailController.text.isEmpty) {
//       Get.snackbar('Error', 'Please enter your email',
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
    
//     if (amountController.text.isEmpty) {
//       Get.snackbar('Error', 'Please enter amount',
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
    
//     final amount = double.tryParse(amountController.text);
//     if (amount == null || amount <= 0) {
//       Get.snackbar('Error', 'Please enter valid amount',
//           backgroundColor: Colors.red, colorText: Colors.white);
//       return;
//     }
    
//     isLoading.value = true;
//     errorMessage.value = '';
    
//     try {
//       // Create payment intent from backend
//       final clientSecret = await stripeService.createPaymentIntent(amount, 'usd');
      
//       if (clientSecret == null) {
//         throw Exception('Failed to create payment intent');
//       }
      
//       // Confirm payment with Stripe
//       final success = await stripeService.confirmPayment(
//         clientSecret: clientSecret,
//         email: emailController.text,
//         name: nameController.text,
//       );
      
//       if (success) {
//         Get.snackbar(
//           'Success! 🎉', 
//           'Payment completed successfully',
//           backgroundColor: Colors.green, 
//           colorText: Colors.white,
//           duration: Duration(seconds: 3),
//         );
//         // Clear form after successful payment
//         amountController.clear();
//         nameController.clear();
//         emailController.clear();
//       } else {
//         throw Exception('Payment failed. Please try again.');
//       }
//     } catch (e) {
//       errorMessage.value = e.toString();
//       Get.snackbar(
//         'Payment Failed ❌', 
//         e.toString(),
//         backgroundColor: Colors.red, 
//         colorText: Colors.white,
//         duration: Duration(seconds: 4),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }


// class PaymentScreen extends StatelessWidget {
//   final PaymentController controller = Get.put(PaymentController());
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: Text('Stripe Payment', 
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         elevation: 0,
//       ),
//       body: Obx(() => SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Center(
//                 child: Container(
//                   padding: EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.shade100,
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       )
//                     ],
//                   ),
//                   child: Icon(Icons.payment, size: 60, color: Colors.blue),
//                 ),
//               ),
//               SizedBox(height: 24),
              
//               Center(
//                 child: Text(
//                   'Secure Payment',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade800,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 8),
              
//               Center(
//                 child: Text(
//                   'Enter your card details',
//                   style: TextStyle(color: Colors.grey.shade600),
//                 ),
//               ),
//               SizedBox(height: 32),
              
//               // Name Field
//               Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
//               SizedBox(height: 8),
//               TextField(
//                 controller: controller.nameController,
//                 decoration: InputDecoration(
//                   hintText: 'John Doe',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: Icon(Icons.person),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 16),
              
//               // Email Field
//               Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
//               SizedBox(height: 8),
//               TextField(
//                 controller: controller.emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   hintText: 'john@example.com',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: Icon(Icons.email),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 16),
              
//               // Amount Field
//               Text('Amount (USD)', style: TextStyle(fontWeight: FontWeight.w600)),
//               SizedBox(height: 8),
//               TextField(
//                 controller: controller.amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   hintText: '0.00',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: Icon(Icons.attach_money),
//                   suffixText: 'USD',
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//               ),
//               SizedBox(height: 16),
              
//               // Quick Amounts
//               Text('Quick Select', style: TextStyle(fontWeight: FontWeight.w600)),
//               SizedBox(height: 8),
//               Row(
//                 children: [
//                   _buildQuickButton(10),
//                   SizedBox(width: 12),
//                   _buildQuickButton(25),
//                   SizedBox(width: 12),
//                   _buildQuickButton(50),
//                   SizedBox(width: 12),
//                   _buildQuickButton(100),
//                 ],
//               ),
//               SizedBox(height: 24),
              
//               // Card Element Container
//               Text('Card Details', style: TextStyle(fontWeight: FontWeight.w600)),
//               SizedBox(height: 8),
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Column(
//                   children: [
//                     // ✅ Fixed: Stripe card element mounting container
//                     Container(
//                       key: ValueKey('card-element'),
//                       height: 60,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: HtmlElementView(
//                         viewType: 'stripe-card-element',
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     // Error messages
//                     if (controller.errorMessage.value.isNotEmpty)
//                       Container(
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.error, color: Colors.red, size: 16),
//                             SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 controller.errorMessage.value,
//                                 style: TextStyle(color: Colors.red, fontSize: 12),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 24),
              
//               // Pay Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: controller.isLoading.value
//                       ? null
//                       : () => controller.processPayment(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: controller.isLoading.value
//                       ? Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             Text('Processing...'),
//                           ],
//                         )
//                       : Text(
//                           'Pay Now',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//               SizedBox(height: 16),
              
//               // Security Info
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.security, color: Colors.green),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Your payment info is secure and encrypted',
//                         style: TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               SizedBox(height: 24),
//             ],
//           ),
//         ),
//       )),
//     );
//   }
  
//   Widget _buildQuickButton(int amount) {
//     return Expanded(
//       child: OutlinedButton(
//         onPressed: () => controller.setAmount(amount.toDouble()),
//         style: OutlinedButton.styleFrom(
//           side: BorderSide(color: Colors.blue),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Text(
//           '\$$amount',
//           style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
import 'dart:html' as html;

class StripePaymentService {
  static void openPaymentPage({
    required double amount,
    required String email,
    required String name,
    required String projectId,
    required String milestoneId,
  }) {
    // Tumhara Next.js payment page URL
    final paymentUrl = 'http://localhost:3001?amount=$amount&email=$email&name=$name&project_id=$projectId&milestone_id=$milestoneId';
    
    // Bus itna kaam - naya tab open karo
    html.window.open(paymentUrl, '_blank');
  }
}
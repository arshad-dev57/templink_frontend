import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HelpSupportScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const HelpSupportScreen({
    super.key,
    this.onBackPressed,
    this.showSidebar = true,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _supportMessageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, String>> _filteredFAQs = [];
  String _selectedCategory = 'All';

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create a profile?',
      'answer': 'To create a profile, click on the Profile tab in the navigation menu. Fill in your personal information, add your skills, work experience, and upload a profile picture. Save your profile to make it visible to employers.',
      'category': 'Getting Started'
    },
    {
      'question': 'How do I find and apply to projects?',
      'answer': 'Browse projects on the Home page. Use filters to find projects matching your skills. Click on a project to view details, then click "Submit Proposal" to apply. Write a compelling proposal to increase your chances of getting hired.',
      'category': 'Projects'
    },
    {
      'question': 'How do payments work?',
      'answer': 'Payments are processed through milestones. When you complete a milestone, the employer releases payment. Funds are held in escrow until the milestone is approved. You can withdraw earnings to your linked payment method.',
      'category': 'Payments'
    },
    {
      'question': 'What are coins and how do I use them?',
      'answer': 'Coins are the platform currency used to purchase premium features like proposal boosts, profile highlighting, and access to exclusive projects. You can purchase coins from the Buy Coins section in the menu.',
      'category': 'Coins'
    },
    {
      'question': 'How do I contact support?',
      'answer': 'You can contact support through the Help & Support section. Use the contact form to send us a message, or email us directly at support@templink.com. Our team typically responds within 24 hours.',
      'category': 'Support'
    },
    {
      'question': 'How do I change my password?',
      'answer': 'Go to Settings > Password & Security. Click on "Change Password" and follow the instructions. You will need to enter your current password and then create a new one.',
      'category': 'Account'
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, you can close your account from Settings > Account Management. Note that this action is permanent and cannot be undone. Make sure to withdraw all earnings before closing your account.',
      'category': 'Account'
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredFAQs = _faqs;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _supportMessageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _faqs;
      } else {
        _filteredFAQs = _faqs.where((faq) {
          return faq['question']!.toLowerCase().contains(query) ||
                 faq['answer']!.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredFAQs = _faqs;
      } else {
        _filteredFAQs = _faqs.where((faq) => faq['category'] == category).toList();
      }
    });
  }

  Future<void> _submitSupportTicket() async {
    if (_subjectController.text.isEmpty || _supportMessageController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final userId = prefs.getString('auth_user_id') ?? '';

      if (token.isEmpty || userId.isEmpty) {
        Get.snackbar('Error', 'Please login first',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/support/ticket'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'subject': _subjectController.text,
          'message': _supportMessageController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Support ticket submitted successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        _subjectController.clear();
        _supportMessageController.clear();
      } else {
        Get.snackbar('Error', 'Failed to submit support ticket',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      // If API doesn't exist, send email directly
      final emailUri = Uri.parse(
        'mailto:support@templink.com?subject=${Uri.encodeComponent(_subjectController.text)}&body=${Uri.encodeComponent(_supportMessageController.text)}',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        Get.snackbar('Info', 'Opening email client',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blue,
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Could not open email client',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.showSidebar && widget.onBackPressed != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: widget.onBackPressed,
            ),
          const Text(
            "Help & Support",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildCategoryFilters(),
          const SizedBox(height: 24),
          _buildFAQSection(),
          const SizedBox(height: 32),
          _buildContactSupportSection(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search for help...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All', 'Getting Started', 'Projects', 'Payments', 'Coins', 'Account', 'Support'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                _filterByCategory(category);
              },
              selectedColor: Colors.blue.withOpacity(0.2),
              checkmarkColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (_filteredFAQs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No FAQs found matching your search',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._filteredFAQs.map((faq) => _buildFAQCard(faq)),
      ],
    );
  }

  Widget _buildFAQCard(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          faq['question']!,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq['answer']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _supportMessageController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitSupportTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickContactOption(
                  icon: Icons.email,
                  label: 'Email',
                  value: 'support@templink.com',
                  color: Colors.green,
                  onTap: () async {
                    final emailUri = Uri.parse('mailto:support@templink.com');
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickContactOption(
                  icon: Icons.chat,
                  label: 'Live Chat',
                  value: 'Available 9AM-5PM',
                  color: Colors.blue,
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Live Chat'),
                        content: const Text('Live chat is available Monday to Friday, 9AM to 5PM. Our team will assist you shortly.'),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactOption({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

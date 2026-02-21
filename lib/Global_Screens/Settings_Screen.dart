import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Screen.dart';
import 'package:templink/Employeer/Screens/Emplyeer_profile_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color kGreen = Color(0xFF14A800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _sectionTitle('Account'),
          _tile(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Manage your profile details',
            onTap: () {
              Get.to(() => const EmployerProfileScreen()); // Placeholder for Profile Screen
            },
          ),
          _tile(
            context,
            icon: Icons.lock_outline,
            title: 'Password & Security',
            subtitle: 'Change password, security settings',
            onTap: () {},
          ),
          _tile(
            context,
            icon: Icons.notifications_none,
            title: 'Notification Settings',
            subtitle: 'Email, push notifications & alerts',
            onTap: () {},
          ),

          const SizedBox(height: 12),
          _sectionTitle('Payments'),
          _tile(
            context,
            icon: Icons.payments_outlined,
            title: 'Billing & Payments',
            subtitle: 'Payment methods, invoices, billing info',
            onTap: () {
              // Get.to(() => paymentview());
            },
          ),

          const SizedBox(height: 12),
          _sectionTitle('Preferences'),
          _tile(
            context,
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'Choose app language',
            onTap: () {},
          ),
          _tile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: 'Light/Dark mode',
            onTap: () {},
          ),

          const SizedBox(height: 12),
          _sectionTitle('Support'),
          _tile(
            context,
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'FAQs and support resources',
            onTap: () {},
          ),
          _tile(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Contact Support',
            subtitle: 'Reach out for help',
            onTap: () {},
          ),
          _tile(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            subtitle: 'Tell us what’s not working',
            onTap: () {},
          ),

          const SizedBox(height: 12),
          _sectionTitle('Legal'),
          _tileExternal(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _tileExternal(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),

          const SizedBox(height: 16),
          _sectionTitle('Account Management'),
          _dangerTile(
            context,
            title: 'Deactivate account',
            subtitle: 'Temporarily disable your account',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _dangerTile(
            context,
            title: 'Close account',
            subtitle: 'This will permanently close your account',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return _baseTile(
      context,
      leading: Icon(icon, color: Colors.black87),
      title: title,
      subtitle: subtitle,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade500),
      onTap: onTap,
    );
  }

  Widget _tileExternal(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return _baseTile(
      context,
      leading: Icon(icon, color: Colors.black87),
      title: title,
      subtitle: null,
      trailing: Icon(Icons.open_in_new, color: Colors.grey.shade600, size: 20),
      onTap: onTap,
    );
  }

  Widget _dangerTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.red.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: onTap,
      ),
    );
  }

  Widget _baseTile(
    BuildContext context, {
    required Widget leading,
    required String title,
    String? subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: leading),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
        trailing: trailing,
      ),
    );
  }
}

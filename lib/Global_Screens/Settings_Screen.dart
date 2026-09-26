import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Screen.dart';
import 'package:templink/Employee/Screens/wallet_screen.dart';
import 'package:templink/Global_Screens/Change_Password_Screen.dart';


class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const SettingsScreen({
    super.key,
    this.onBackPressed,
    this.showSidebar = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  static const Color kGreen = Color(0xFF14A800);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('language', _selectedLanguage);
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
            "Settings",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            "Manage your account settings",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _sectionTitle('Account'),
        _tile(
          icon: Icons.person_outline,
          title: 'Profile',
          subtitle: 'Manage your profile details',
          onTap: () {
            Get.to(() => const EmployeeProfileScreen());
          },
        ),
        _tile(
          icon: Icons.lock_outline,
          title: 'Password & Security',
          subtitle: 'Change password, security settings',
          onTap: () {
            Get.to(() => const ChangePasswordScreen());
          },
        ),
        _tile(
          icon: Icons.notifications_none,
          title: 'Notification Settings',
          subtitle: 'Email, push notifications & alerts',
          onTap: () {
            _showNotificationSettings();
          },
        ),

        const SizedBox(height: 12),
        _sectionTitle('Payments'),
        _tile(
          icon: Icons.payments_outlined,
          title: 'Billing & Payments',
          subtitle: 'Payment methods, invoices, billing info',
          onTap: () {
            Get.to(() => const WalletScreen());
          },
        ),

        const SizedBox(height: 12),
        _sectionTitle('Legal'),
        _tileExternal(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {
            _showComingSoonDialog('Privacy Policy');
          },
        ),
        _tileExternal(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () {
            _showComingSoonDialog('Terms of Service');
          },
        ),

        const SizedBox(height: 16),
        _sectionTitle('Account Management'),
        _dangerTile(
          title: 'Deactivate account',
          subtitle: 'Temporarily disable your account',
          onTap: () {
            _showDeactivateDialog();
          },
        ),
        const SizedBox(height: 8),
        _dangerTile(
          title: 'Close account',
          subtitle: 'This will permanently close your account',
          onTap: () {
            _showCloseAccountDialog();
          },
        ),
      ],
    );
  }



  void _showNotificationSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Notification Settings'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive updates via email'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                    setDialogState(() {
                      _emailNotifications = value;
                    });
                    _saveSettings();
                  },
                ),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                    setDialogState(() {
                      _pushNotifications = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your account? You can reactivate it later by logging in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showComingSoonDialog('Account Deactivation');
            },
            child: const Text('Deactivate', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCloseAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Close Account'),
        content: const Text(
          'Are you sure you want to permanently close your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showComingSoonDialog('Account Closure');
            },
            child: const Text('Close Account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    Get.dialog(
      AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
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

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return _baseTile(
      leading: Icon(icon, color: Colors.black87),
      title: title,
      subtitle: subtitle,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade500),
      onTap: onTap,
    );
  }

  Widget _tileExternal({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return _baseTile(
      leading: Icon(icon, color: Colors.black87),
      title: title,
      subtitle: null,
      trailing: Icon(Icons.open_in_new, color: Colors.grey.shade600, size: 20),
      onTap: onTap,
    );
  }

  Widget _dangerTile({
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

  Widget _baseTile({
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

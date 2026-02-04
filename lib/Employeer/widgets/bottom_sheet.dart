import 'package:flutter/material.dart';
import 'package:templink/Utils/colors.dart';

class CustomBottomSheets {
  // Settings Bottom Sheet
  static void showSettingsBottomSheet({
    required BuildContext context,
    required VoidCallback onEditProfile,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Options
            _buildSettingsOption(
              context: context,
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your company information',
              iconBgColor: primary.withOpacity(0.1),
              iconColor: primary,
              onTap: () {
                Navigator.pop(context);
                onEditProfile();
              },
            ),

            _buildSettingsOption(
              context: context,
              icon: Icons.settings_outlined,
              title: 'Account Settings',
              subtitle: 'Manage your account preferences',
              iconBgColor: Colors.blue.withOpacity(0.1),
              iconColor: Colors.blue.shade700,
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),

            _buildSettingsOption(
              context: context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Configure notification preferences',
              iconBgColor: Colors.orange.withOpacity(0.1),
              iconColor: Colors.orange.shade700,
              onTap: () {
                Navigator.pop(context);
                // Navigate to notifications
              },
            ),

            _buildSettingsOption(
              context: context,
              icon: Icons.analytics_outlined,
              title: 'Analytics',
              subtitle: 'View your profile statistics',
              iconBgColor: Colors.purple.withOpacity(0.1),
              iconColor: Colors.purple.shade700,
              onTap: () {
                Navigator.pop(context);
                // Navigate to analytics
              },
            ),

            _buildSettingsOption(
              context: context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              iconBgColor: Colors.green.withOpacity(0.1),
              iconColor: Colors.green.shade700,
              onTap: () {
                Navigator.pop(context);
                // Navigate to help
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Job Options Bottom Sheet
  static void showJobOptionsBottomSheet({
    required BuildContext context,
    required String jobTitle,
    required String status,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Job Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jobTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage this job posting',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 8),

            // Options
            _buildMenuOption(
              context: context,
              icon: Icons.edit_outlined,
              title: 'Edit Job',
              iconColor: Colors.blue.shade700,
              onTap: () {
                Navigator.pop(context);
                // Edit job
              },
            ),

            _buildMenuOption(
              context: context,
              icon: status == 'Active' ? Icons.pause_circle_outlined : Icons.play_circle_outlined,
              title: status == 'Active' ? 'Pause Job' : 'Activate Job',
              iconColor: status == 'Active' ? Colors.orange.shade700 : Colors.green.shade700,
              onTap: () {
                Navigator.pop(context);
                // Toggle status
              },
            ),

            _buildMenuOption(
              context: context,
              icon: Icons.share_outlined,
              title: 'Share Job',
              iconColor: Colors.purple.shade700,
              onTap: () {
                Navigator.pop(context);
                // Share job
              },
            ),

            _buildMenuOption(
              context: context,
              icon: Icons.analytics_outlined,
              title: 'View Analytics',
              iconColor: Colors.teal.shade700,
              onTap: () {
                Navigator.pop(context);
                // View analytics
              },
            ),

            const Divider(height: 1),

            _buildMenuOption(
              context: context,
              icon: Icons.delete_outline,
              title: 'Delete Job',
              iconColor: Colors.red.shade700,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, 'Job', jobTitle);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Project Options Bottom Sheet
  static void showProjectOptionsBottomSheet({
    required BuildContext context,
    required String projectTitle,
    required String status,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Project Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage this project',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 8),

            // Options
            _buildMenuOption(
              context: context,
              icon: Icons.edit_outlined,
              title: 'Edit Project',
              iconColor: Colors.blue.shade700,
              onTap: () {
                Navigator.pop(context);
                // Edit project
              },
            ),

            if (status == 'Active')
              _buildMenuOption(
                context: context,
                icon: Icons.play_circle_outlined,
                title: 'Mark as In Progress',
                iconColor: Colors.orange.shade700,
                onTap: () {
                  Navigator.pop(context);
                  // Mark in progress
                },
              ),

            if (status == 'In Progress')
              _buildMenuOption(
                context: context,
                icon: Icons.check_circle_outlined,
                title: 'Mark as Completed',
                iconColor: Colors.green.shade700,
                onTap: () {
                  Navigator.pop(context);
                  // Mark completed
                },
              ),

            _buildMenuOption(
              context: context,
              icon: Icons.share_outlined,
              title: 'Share Project',
              iconColor: Colors.purple.shade700,
              onTap: () {
                Navigator.pop(context);
                // Share project
              },
            ),

            const Divider(height: 1),

            _buildMenuOption(
              context: context,
              icon: Icons.delete_outline,
              title: 'Delete Project',
              iconColor: Colors.red.shade700,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, 'Project', projectTitle);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper method for settings options with subtitle
  static Widget _buildSettingsOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  // Helper method for menu options
  static Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          leading: Icon(icon, color: iconColor, size: 24),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: title.contains('Delete') ? Colors.red.shade700 : Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey.shade300,
            size: 20,
          ),
        ),
      ),
    );
  }

  // Delete Confirmation Dialog
  static void _showDeleteConfirmation(
    BuildContext context,
    String type,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Delete $type?'),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
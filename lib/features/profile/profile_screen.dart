import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Consumer<UserProvider>(builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 32),

                // Profile card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2ECC71),
                        Color(0xFF27AE60),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Phone
                      Text(
                        user?.phoneNumber ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Verification badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'VERIFIED USER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'Total Reports',
                        user?.totalReports.toString() ?? '0',
                        Icons.report,
                        AppColors.orange,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Total Bookings',
                        user?.totalBookings.toString() ?? '0',
                        Icons.calendar_today,
                        AppColors.blue,
                      ),
                      const Divider(height: 24),
                      _buildStatRow(
                        'Current Streak',
                        '${user?.streak ?? 0} days',
                        Icons.local_fire_department,
                        AppColors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        'Edit Profile',
                        Icons.edit,
                        () {
                          // TODO: Navigate to edit profile
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingItem(
                        'My Bookings',
                        Icons.history,
                        () {
                          // TODO: Navigate to bookings history
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingItem(
                        'My Reports',
                        Icons.report_problem,
                        () {
                          // TODO: Navigate to reports history
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingItem(
                        'Help & Support',
                        Icons.help_outline,
                        () {
                          // TODO: Navigate to help
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingItem(
                        'About SafaiPay',
                        Icons.info_outline,
                        () {
                          // TODO: Navigate to about
                        },
                      ),
                      const Divider(height: 1),
                      _buildSettingItem(
                        'Logout',
                        Icons.logout,
                        () => _logout(context),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Version
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.red : AppColors.primaryGreen,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDestructive ? AppColors.red : AppColors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.greyText,
      ),
      onTap: onTap,
    );
  }
}

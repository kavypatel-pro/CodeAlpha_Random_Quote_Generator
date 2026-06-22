import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/page_transitions.dart';
import 'plans_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = false;

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _showThemeLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.lock_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Theme Locked'),
          ],
        ),
        content: const Text(
          'Dark Mode is a premium feature. Upgrade to Silver or Gold to unlock custom themes, save favorites, and read unlimited quotes!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                SlideRightToLeftRoute(page: const PlansScreen()),
              );
            },
            child: const Text('Upgrade Plan'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('About App'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QuoteVerse',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              '"Words that move you."',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QuoteVerse provides daily inspiration, wisdom, and success stories '
              'to power your day. Built with a premium aesthetic and smooth micro-interactions.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationToggle(bool value, String plan) {
    if (plan == AppConstants.planGold) {
      setState(() {
        _notificationsEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_notificationsEnabled ? 'Notifications enabled!' : 'Notifications disabled!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Non-gold users cannot toggle
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Gold Feature Required'),
          content: const Text(
            'Daily Quote of the Day notifications are exclusive to Gold plan subscribers. '
            'Upgrade to Gold to get notifications, image export cards, and custom collections!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlideRightToLeftRoute(page: const PlansScreen()),
                );
              },
              child: const Text('Upgrade Plan'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    
    final currentUser = auth.currentUser;
    final name = currentUser?.name ?? 'Guest User';
    final email = currentUser?.email ?? 'guest@quotverse.app';
    final plan = currentUser?.plan ?? AppConstants.planBasic;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose badge color based on plan
    Color badgeColor;
    switch (plan) {
      case AppConstants.planSilver:
        badgeColor = const Color(0xFFBA7517);
        break;
      case AppConstants.planGold:
        badgeColor = const Color(0xFF185FA5);
        break;
      default:
        badgeColor = const Color(0xFF6B7280);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Circular Avatar initials
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
              child: Text(
                _getInitials(name),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            )
                .animate()
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 16),
            
            // Name
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 4),
            
            // Email
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                  ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 12),
            
            // Plan Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$plan Member',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 36),
            
            // Settings section list items
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Dark Mode Switch
                  ListTile(
                    leading: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDark ? const Color(0xFF22D3EE) : const Color(0xFF7C3AED),
                    ),
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Switch(
                      value: isDark,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        if (plan == AppConstants.planBasic) {
                          _showThemeLockedDialog();
                        } else {
                          theme.toggleTheme();
                        }
                      },
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  
                  // Notifications Switch (Only for Gold users)
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: Colors.blue),
                    title: const Text('Quote Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) => _handleNotificationToggle(value, plan),
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  
                  // Upgrade Plan
                  ListTile(
                    leading: const Icon(Icons.star_outline_rounded, color: Colors.amber),
                    title: const Text('Upgrade Plan', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRightToLeftRoute(page: const PlansScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  
                  // About App
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: Colors.teal),
                    title: const Text('About App', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.05, end: 0.0, curve: Curves.easeOutCubic),
            const SizedBox(height: 24),
            
            // Logout Button (Red text)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      FadeScaleRoute(page: const LoginScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

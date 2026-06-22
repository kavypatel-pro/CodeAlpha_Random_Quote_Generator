import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/page_transitions.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isOnboardingCompleted) {
        Navigator.of(context).pushReplacement(
          SlideRightToLeftRoute(page: const LoginScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          SlideRightToLeftRoute(page: const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background uses primary color #4F46E5 for light, or background color #0F172A for dark
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF4F46E5);
    final foregroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered Quote Icon logo with animation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: foregroundColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.format_quote,
                size: 80,
                color: foregroundColor,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, curve: Curves.easeIn)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            
            // App Name "QuoteVerse" in bold
            Text(
              'QuoteVerse',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: foregroundColor,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0.0, curve: Curves.easeOutCubic),
            const SizedBox(height: 8),
            
            // Tagline "Words that move you." in italic
            Text(
              '"Words that move you."',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: foregroundColor.withOpacity(0.8),
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.5,
                  ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0.0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}

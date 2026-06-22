import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Discover Inspiring Quotes',
      description: 'Explore a curated catalog of wisdom, motivation, and humor from history\'s greatest minds.',
      icon: Icons.explore_rounded,
      accentColor: const Color(0xFF4F46E5),
    ),
    OnboardingSlideData(
      title: 'Save Your Favorites',
      description: 'Build your personal library of quotes that speak to you. Keep them close for whenever you need a lift.',
      icon: Icons.favorite_rounded,
      accentColor: const Color(0xFFEC4899),
    ),
    OnboardingSlideData(
      title: 'Choose Your Plan',
      description: 'Unlock premium features, remove ads, export stunning image cards, and receive daily wisdom collections.',
      icon: Icons.stars_rounded,
      accentColor: const Color(0xFFF59E0B),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    // Save onboarding completion state in provider/prefs
    Provider.of<AuthProvider>(context, listen: false).completeOnboarding();
    Navigator.of(context).pushReplacement(
      SlideRightToLeftRoute(page: const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip button
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerRight,
              child: _currentPage < 2
                  ? TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            
            // Onboarding Slides (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Slide Icon with a subtle circular background
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: slide.accentColor.withOpacity(isDark ? 0.15 : 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 80,
                            color: slide.accentColor,
                          )
                              .animate(key: ValueKey(index))
                              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 500.ms, curve: Curves.easeOutBack)
                              .fadeIn(duration: 400.ms),
                        ),
                        const SizedBox(height: 48),
                        
                        // Slide Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                        )
                            .animate(key: ValueKey('t_$index'))
                            .fadeIn(duration: 400.ms, delay: 100.ms)
                            .slideY(begin: 0.1, end: 0.0, duration: 400.ms),
                        const SizedBox(height: 16),
                        
                        // Slide Description
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                height: 1.5,
                              ),
                        )
                            .animate(key: ValueKey('d_$index'))
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideY(begin: 0.1, end: 0.0, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Bar: Dot indicators & Navigation buttons
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _slides[_currentPage].accentColor
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _slides[_currentPage].accentColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _navigateToLogin();
                        }
                      },
                      child: Text(
                        _currentPage == 2 ? 'Get Started' : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingSlideData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

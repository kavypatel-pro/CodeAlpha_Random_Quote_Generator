import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../widgets/plan_card.dart';
import '../utils/constants.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userPlan = auth.currentUser?.plan ?? AppConstants.planBasic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Text(
              'Choose your plan',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0.0),
            const SizedBox(height: 8),
            Text(
              'Unlock exclusive features and words that move you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0.0),
            const SizedBox(height: 24),
            
            // Basic Plan Card
            PlanCard(
              title: 'BASIC PLAN',
              price: AppConstants.priceBasic,
              icon: Icons.shield_outlined,
              accentColor: const Color(0xFF6B7280),
              isCurrent: userPlan == AppConstants.planBasic,
              features: const [
                '10 random quotes per day',
                '3 categories (Motivation, Life, Success)',
                'Light theme only',
                'No favorites',
                'Ads shown',
              ],
              hasFeatures: const [true, true, true, false, false],
              buttonText: 'Current Plan',
              onPressed: () {},
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0.0),
            
            // Silver Plan Card
            PlanCard(
              title: 'SILVER PLAN',
              price: AppConstants.priceSilver,
              icon: Icons.star_outline_rounded,
              accentColor: const Color(0xFFBA7517),
              isCurrent: userPlan == AppConstants.planSilver,
              features: const [
                'Unlimited quotes',
                'All 6 categories',
                'Save unlimited favorites',
                'Light + Dark theme',
                'No ads',
                'No image export',
              ],
              hasFeatures: const [true, true, true, true, true, false],
              buttonText: 'Upgrade to Silver',
              onPressed: () {
                _handleUpgrade(context, auth, AppConstants.planSilver);
              },
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0.0),
            
            // Gold Plan Card
            PlanCard(
              title: 'GOLD PLAN',
              price: AppConstants.priceGold,
              icon: Icons.workspace_premium_rounded,
              accentColor: const Color(0xFF185FA5),
              isCurrent: userPlan == AppConstants.planGold,
              isHighlighted: true,
              features: const [
                'Everything in Silver',
                'Export quote as image card (share as PNG)',
                'Quote of the Day notification',
                'AI-curated personalized quotes',
                'Exclusive motivational collections',
                'Priority support badge on profile',
              ],
              hasFeatures: const [true, true, true, true, true, true],
              buttonText: 'Upgrade to Gold',
              onPressed: () {
                _handleUpgrade(context, auth, AppConstants.planGold);
              },
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0.0),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _handleUpgrade(BuildContext context, AuthProvider auth, String targetPlan) {
    // Perform mock upgrade so user can test the premium features
    auth.upgradePlan(targetPlan);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upgraded to $targetPlan successfully! Payment coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

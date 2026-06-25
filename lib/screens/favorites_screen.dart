import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quote_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quote_provider.dart';
import '../widgets/quote_card.dart';
import '../utils/constants.dart';
import '../utils/page_transitions.dart';
import 'main_navigation_screen.dart';
import 'plans_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final quotes = Provider.of<QuoteProvider>(context);

    final userPlan = auth.currentUser?.plan ?? AppConstants.planBasic;
    final isBasic = userPlan == AppConstants.planBasic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: isBasic
          // Plan lock barrier state
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 70,
                            color: Colors.red,
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Unlock Favorites',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upgrade to Silver or Gold to save your favorite quotes and build your personal collection of inspiration.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideRightToLeftRoute(page: const PlansScreen()),
                        );
                      },
                      icon: const Icon(Icons.star_rounded, color: Colors.white),
                      label: const Text('Upgrade Plan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : quotes.favorites.isEmpty
          // Empty State
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                          Icons.favorite_border_rounded,
                          size: 80,
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the heart icon on any quote to save it here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () {
                        final navState = context
                            .findAncestorStateOfType<
                              MainNavigationScreenState
                            >();
                        navState?.setSelectedIndex(0);
                      },
                      child: const Text('Discover Quotes'),
                    ),
                  ],
                ),
              ),
            )
          // Favorites list
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: quotes.favorites.length,
              itemBuilder: (context, index) {
                final Quote quote = quotes.favorites[index];
                return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      // Swipe-to-delete implementation
                      child: Dismissible(
                        key: ValueKey(quote.text),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        onDismissed: (direction) {
                          quotes.removeFavorite(quote);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from favorites'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            QuoteCard(quote: quote, isCompact: true),
                            // Delete (trash) icon on top-right
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                color: Colors.red.shade400,
                                onPressed: () {
                                  quotes.removeFavorite(quote);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Removed from favorites'),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                    .slideY(begin: 0.05, end: 0.0, curve: Curves.easeOutCubic);
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import '../models/quote_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/quote_card.dart';
import '../utils/constants.dart';
import '../utils/page_transitions.dart';
import 'plans_screen.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _shareBoundaryKey = GlobalKey();
  bool _isHeartBouncing = false;
  Quote? _lastRecordedQuote;

  Future<void> _shareAsText(Quote quote) async {
    final textToShare = '"${quote.text}"\n— ${quote.author}\n\nShared via QuoteVerse: Words that move you.';
    await Share.share(textToShare);
  }

  Future<void> _shareAsImage(Quote quote) async {
    try {
      final boundary = _shareBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      // Build a dialog indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }

      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '"${quote.text}" — ${quote.author}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export image: $e')),
        );
      }
    }
  }

  void _showShareOptions(BuildContext context, Quote quote, String plan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isGold = plan == AppConstants.planGold;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Share Quote',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _shareAsText(quote);
                },
                icon: const Icon(Icons.text_fields),
                label: const Text('Share as Text'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (isGold) {
                    _shareAsImage(quote);
                  } else {
                    _showGoldRequiredDialog('Export Quote as Image');
                  }
                },
                icon: const Icon(Icons.image_outlined),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Export as Image Card'),
                    if (!isGold) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF185FA5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'GOLD',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGoldRequiredDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gold Feature Required'),
        content: Text('$featureName is exclusively available to Gold members. Upgrade now to get priority access, image card exports, and personalized collections!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to Plans tab/screen
              final navState = context.findAncestorStateOfType<State<MainNavigationScreen>>();
              if (navState != null) {
                // If nested inside MainNavigation, update selected tab to Plans (or profile settings)
                // However, we can simply push PlansScreen directly on top.
                Navigator.push(
                  context,
                  SlideRightToLeftRoute(page: const PlansScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  SlideRightToLeftRoute(page: const PlansScreen()),
                );
              }
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Limit Reached'),
          ],
        ),
        content: const Text(
          'You have reached your free limit of 10 quotes for today. '
          'Upgrade to Silver or Gold to unlock unlimited inspiring quotes and premium custom features!',
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final quotes = Provider.of<QuoteProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    final userPlan = auth.currentUser?.plan ?? AppConstants.planBasic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Record quote category interactions dynamically
    if (quotes.currentQuote != null && quotes.currentQuote != _lastRecordedQuote && !quotes.isLoading && !quotes.isAiLoading) {
      _lastRecordedQuote = quotes.currentQuote;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quotes.recordCategoryInteraction(quotes.currentQuote!.category);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Icon(
            Icons.format_quote_rounded,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
        title: const Text('QuoteVerse'),
        actions: [
          IconButton(
            icon: Icon(
              theme.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              if (userPlan == AppConstants.planBasic) {
                _showThemeLockedDialog();
              } else {
                theme.toggleTheme();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: quotes.allQuotes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Quote Card inside AnimatedSwitcher
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // Fade + Slide transition for the card
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ));
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: (quotes.isLoading || quotes.isAiLoading)
                            // Shimmer state (animated pulse)
                            ? Container(
                                key: const ValueKey('shimmer_state'),
                                height: 260,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              )
                                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                .fadeIn(duration: 300.ms)
                                .shimmer(
                                  color: Theme.of(context).primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                                  duration: 800.ms,
                                )
                            // Actual Quote Card
                            : quotes.currentQuote != null
                                ? QuoteCard(
                                    key: ValueKey(quotes.currentQuote!.text),
                                    quote: quotes.currentQuote!,
                                    boundaryKey: _shareBoundaryKey,
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 3 Action buttons row
                  if (quotes.currentQuote != null && !quotes.isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Favorite Heart Icon Button
                        IconButton(
                          iconSize: 28,
                          icon: Icon(
                            quotes.isFavorite(quotes.currentQuote!)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: quotes.isFavorite(quotes.currentQuote!) ? Colors.red : null,
                          ),
                          // Heart bounce animation on press
                          onPressed: () async {
                            final currentQuote = quotes.currentQuote!;
                            
                            // Guest and Basic restrictions
                            final errorMsg = await quotes.toggleFavorite(currentQuote, userPlan);
                            if (errorMsg != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMsg),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'Upgrade',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        SlideRightToLeftRoute(page: const PlansScreen()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            } else {
                              setState(() {
                                _isHeartBouncing = true;
                              });
                              Future.delayed(const Duration(milliseconds: 150), () {
                                if (mounted) {
                                  setState(() {
                                    _isHeartBouncing = false;
                                  });
                                }
                              });
                            }
                          },
                        )
                            .animate(target: _isHeartBouncing ? 1.0 : 0.0)
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.3, 1.3),
                              duration: 75.ms,
                              curve: Curves.easeOutBack,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.3, 1.3),
                              end: const Offset(1.0, 1.0),
                              duration: 75.ms,
                              curve: Curves.easeIn,
                            ),
                        const SizedBox(width: 24),
                        
                        // Share Icon Button
                        IconButton(
                          iconSize: 26,
                          icon: const Icon(Icons.share_rounded),
                          onPressed: () => _showShareOptions(context, quotes.currentQuote!, userPlan),
                        ),
                        const SizedBox(width: 24),
                        
                        // Copy Icon Button
                        IconButton(
                          iconSize: 26,
                          icon: const Icon(Icons.copy_rounded),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: '"${quotes.currentQuote!.text}" — ${quotes.currentQuote!.author}',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied!'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 300.ms),
                        
                  const Spacer(),
                  const SizedBox(height: 24),
                  
                  // "New Quote" button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: quotes.isLoading || quotes.isAiLoading
                          ? null
                          : () async {
                              final success = await quotes.loadNewQuote(userPlan);
                              if (!success) {
                                _showLimitReachedDialog();
                              }
                            },
                      child: const Text('New Quote'),
                    ),
                  ),
                  
                  // "Generate AI Quote" button for Gold users
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: userPlan == AppConstants.planGold
                        ? ElevatedButton.icon(
                            onPressed: quotes.isAiLoading || quotes.isLoading
                                ? null
                                : () async {
                                    final success = await quotes.generateAiQuote(userPlan);
                                    if (success) {
                                      final msg = quotes.aiError != null
                                          ? quotes.aiError!
                                          : 'AI Quote generated successfully!';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(msg),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: quotes.aiError != null ? Colors.orange : Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(quotes.aiError ?? 'Failed to generate AI quote.'),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            icon: quotes.isAiLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.auto_awesome_rounded),
                            label: Text(quotes.isAiLoading ? 'Generating AI Quote...' : 'Generate AI Quote'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF185FA5),
                              foregroundColor: Colors.white,
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () {
                              _showGoldRequiredDialog('AI Personalized Quotes');
                            },
                            icon: const Icon(Icons.lock_rounded, color: Colors.amber, size: 20),
                            label: const Text('Generate AI Quote'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.amber, width: 1.5),
                              foregroundColor: Colors.amber,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

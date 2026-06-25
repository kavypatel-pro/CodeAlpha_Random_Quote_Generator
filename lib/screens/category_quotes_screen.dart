import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import '../models/quote_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quote_provider.dart';
import '../widgets/quote_card.dart';
import '../utils/constants.dart';
import '../utils/page_transitions.dart';
import 'plans_screen.dart';

class CategoryQuotesScreen extends StatefulWidget {
  final CategoryInfo category;

  const CategoryQuotesScreen({super.key, required this.category});

  @override
  State<CategoryQuotesScreen> createState() => _CategoryQuotesScreenState();
}

class _CategoryQuotesScreenState extends State<CategoryQuotesScreen> {
  final GlobalKey _previewBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteProvider>(
        context,
        listen: false,
      ).recordCategoryInteraction(widget.category.id);
    });
  }

  List<Quote> _getCategoryQuotes(List<Quote> allQuotes) {
    return allQuotes
        .where((q) => q.category.toLowerCase() == widget.category.id)
        .toList();
  }

  Future<void> _shareAsText(Quote quote) async {
    final textToShare =
        '"${quote.text}"\n— ${quote.author}\n\nShared via QuoteVerse.';
    await Share.share(textToShare);
  }

  // Export PNG from a dedicated dialog boundary
  Future<void> _shareAsImage(Quote quote) async {
    try {
      final boundary =
          _previewBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/quote_category_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: '"${quote.text}" — ${quote.author}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export image: $e')));
    }
  }

  void _showExportPreviewDialog(Quote quote) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Image Card'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Preview of the PNG image card that will be shared:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                RepaintBoundary(
                  key: _previewBoundaryKey,
                  child: QuoteCard(quote: quote, isCompact: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _shareAsImage(quote);
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share PNG'),
            ),
          ],
        );
      },
    );
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
                'Share Option',
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
                    _showExportPreviewDialog(quote);
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF185FA5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'GOLD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
        content: Text(
          '$featureName is exclusively available to Gold members. Upgrade now to get priority access, image card exports, and personalized collections!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                SlideRightToLeftRoute(page: const PlansScreen()),
              );
            },
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final quotes = Provider.of<QuoteProvider>(context);

    final userPlan = auth.currentUser?.plan ?? AppConstants.planBasic;
    final categoryQuotes = _getCategoryQuotes(quotes.allQuotes);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.category.name} Quotes')),
      body: categoryQuotes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: categoryQuotes.length,
              itemBuilder: (context, index) {
                final Quote quote = categoryQuotes[index];
                final isFav = quotes.isFavorite(quote);

                return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        children: [
                          QuoteCard(quote: quote, isCompact: true),
                          const SizedBox(height: 6),
                          // Actions row below the card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(
                                      0xFF1E293B,
                                    ).withValues(alpha: 0.5)
                                  : Colors.grey.shade50,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Heart Save Icon
                                IconButton(
                                  iconSize: 20,
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFav ? Colors.red : null,
                                  ),
                                  onPressed: () async {
                                    final errorMsg = await quotes
                                        .toggleFavorite(quote, userPlan);
                                    if (!context.mounted) return;
                                    if (errorMsg != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg),
                                          behavior: SnackBarBehavior.floating,
                                          action: SnackBarAction(
                                            label: 'Upgrade',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                SlideRightToLeftRoute(
                                                  page: const PlansScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    } else {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isFav
                                                ? 'Removed from favorites'
                                                : 'Added to favorites',
                                          ),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 12),
                                // Share Icon
                                IconButton(
                                  iconSize: 20,
                                  icon: const Icon(Icons.share_rounded),
                                  onPressed: () => _showShareOptions(
                                    context,
                                    quote,
                                    userPlan,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Copy Icon
                                IconButton(
                                  iconSize: 20,
                                  icon: const Icon(Icons.copy_rounded),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text:
                                            '"${quote.text}" — ${quote.author}',
                                      ),
                                    );
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
                            ),
                          ),
                        ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/quote_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quote_provider.dart';
import '../utils/constants.dart';
import '../utils/page_transitions.dart';
import '../widgets/quote_card.dart';
import 'category_quotes_screen.dart';
import 'plans_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Returns list of quotes matching keyword or author name
  List<Quote> _filterQuotes(List<Quote> allQuotes) {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return allQuotes.where((quote) {
      return quote.text.toLowerCase().contains(query) ||
          quote.author.toLowerCase().contains(query);
    }).toList();
  }

  void _onCategoryTap(BuildContext context, CategoryInfo category, String userPlan) {
    final allowedCategories = ['motivation', 'life', 'success'];
    final isRestricted = !allowedCategories.contains(category.id);
    final isBasic = userPlan == AppConstants.planBasic;

    if (isBasic && isRestricted) {
      _showCategoryLockedDialog(category.name);
    } else {
      Provider.of<QuoteProvider>(context, listen: false).recordCategoryInteraction(category.id);
      Navigator.push(
        context,
        SlideRightToLeftRoute(
          page: CategoryQuotesScreen(category: category),
        ),
      );
    }
  }

  void _showCategoryLockedDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.lock_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Category Locked'),
          ],
        ),
        content: Text(
          'The "$categoryName" category is a premium feature. '
          'Upgrade to Silver or Gold to unlock all 6 categories, unlimited quotes, and remove all ads!',
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
    
    final userPlan = auth.currentUser?.plan ?? AppConstants.planBasic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredQuotes = _filterQuotes(quotes.allQuotes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search quotes by keyword or author...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Search results or Category cards grid
            Expanded(
              child: _searchQuery.isNotEmpty
                  ? filteredQuotes.isEmpty
                      ? Center(
                          child: Text(
                            'No quotes found matching "$_searchQuery"',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredQuotes.length,
                          padding: const EdgeInsets.only(bottom: 24.0),
                          itemBuilder: (context, index) {
                            final quote = filteredQuotes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: QuoteCard(quote: quote, isCompact: true),
                            );
                          },
                        )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Browse Categories',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.15,
                            ),
                            itemCount: AppConstants.categories.length,
                            itemBuilder: (context, index) {
                              final category = AppConstants.categories[index];
                              
                              // Check if category is locked for Basic plan
                              final allowedCategories = ['motivation', 'life', 'success'];
                              final isLocked = (userPlan == AppConstants.planBasic) &&
                                  !allowedCategories.contains(category.id);

                              // Count quotes for this category
                              final count = quotes.allQuotes
                                  .where((q) => q.category.toLowerCase() == category.id)
                                  .length;

                              return Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => _onCategoryTap(context, category, userPlan),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Icon with colored background
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: category.color.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                category.icon,
                                                color: category.color,
                                                size: 24,
                                              ),
                                            ),
                                            
                                            // Category title + Count
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  category.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '$count quotes',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? const Color(0xFF94A3B8)
                                                        : const Color(0xFF6B7280),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Lock indicator overlay for locked categories
                                      if (isLocked)
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.lock_rounded,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 250.ms);
                            },
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

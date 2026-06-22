import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_model.dart';
import '../services/anthropic_service.dart';
import '../utils/constants.dart';

class QuoteProvider extends ChangeNotifier {
  List<Quote> _allQuotes = [];
  List<Quote> _shuffledQuotes = [];
  List<Quote> _favorites = [];
  int _currentIndex = 0;
  Quote? _currentQuote;
  bool _isLoading = false;
  bool _isInitialized = false;
  int _dailyQuoteCount = 0;

  // AI-Curation and personalization variables
  Map<String, int> _categoryInteractions = {};
  bool _isAiLoading = false;
  String? _aiError;

  List<Quote> get allQuotes => _allQuotes;
  List<Quote> get favorites => _favorites;
  Quote? get currentQuote => _currentQuote;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  int get dailyQuoteCount => _dailyQuoteCount;
  
  Map<String, int> get categoryInteractions => _categoryInteractions;
  bool get isAiLoading => _isAiLoading;
  String? get aiError => _aiError;

  QuoteProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadQuotesFromAssets();
    await _loadFavoritesFromPrefs();
    await _loadCategoryInteractions();
    await _checkDailyReset();
    _selectNextQuoteInitial();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadQuotesFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _allQuotes = jsonList.map((item) => Quote.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading quotes from assets: $e');
    }
  }

  Future<void> _loadFavoritesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favJsonList = prefs.getStringList(AppConstants.keyFavorites);
      if (favJsonList != null) {
        _favorites = favJsonList
            .map((item) => Quote.fromJson(json.decode(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _checkDailyReset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resetStr = prefs.getString(AppConstants.keyDailyResetDate);
      final now = DateTime.now();

      if (resetStr == null) {
        // Set reset to next midnight
        final nextMidnight = DateTime(now.year, now.month, now.day + 1);
        await prefs.setString(AppConstants.keyDailyResetDate, nextMidnight.toIso8601String());
        _dailyQuoteCount = 0;
        await prefs.setInt(AppConstants.keyDailyQuoteCount, 0);
      } else {
        final resetDate = DateTime.parse(resetStr);
        if (now.isAfter(resetDate)) {
          _dailyQuoteCount = 0;
          await prefs.setInt(AppConstants.keyDailyQuoteCount, 0);
          final nextMidnight = DateTime(now.year, now.month, now.day + 1);
          await prefs.setString(AppConstants.keyDailyResetDate, nextMidnight.toIso8601String());
        } else {
          _dailyQuoteCount = prefs.getInt(AppConstants.keyDailyQuoteCount) ?? 0;
        }
      }
    } catch (e) {
      debugPrint('Error checking daily reset: $e');
    }
  }

  void _shuffleQuotesList() {
    Quote? previousQuote = _currentQuote;
    _shuffledQuotes = List.from(_allQuotes)..shuffle();
    _currentIndex = 0;

    // Avoid consecutive repetitions when reshuffling
    if (previousQuote != null &&
        _shuffledQuotes.isNotEmpty &&
        _shuffledQuotes[0] == previousQuote) {
      if (_shuffledQuotes.length > 1) {
        final temp = _shuffledQuotes[0];
        _shuffledQuotes[0] = _shuffledQuotes[1];
        _shuffledQuotes[1] = temp;
      }
    }
  }

  void _selectNextQuoteInitial() {
    if (_allQuotes.isEmpty) return;
    _shuffleQuotesList();
    _currentQuote = _shuffledQuotes[_currentIndex];
    _currentIndex++;
  }

  // Returns false if limit is exceeded for Basic plan
  Future<bool> loadNewQuote(String userPlan) async {
    await _checkDailyReset();

    if (userPlan == AppConstants.planBasic) {
      if (_dailyQuoteCount >= AppConstants.basicDailyLimit) {
        return false;
      }
    }

    _isLoading = true;
    notifyListeners();

    // 300ms simulated delay for loading shimmer
    await Future.delayed(const Duration(milliseconds: 300));

    if (_shuffledQuotes.isEmpty || _currentIndex >= _shuffledQuotes.length) {
      _shuffleQuotesList();
    }

    _currentQuote = _shuffledQuotes[_currentIndex];
    _currentIndex++;

    if (userPlan == AppConstants.planBasic) {
      _dailyQuoteCount++;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(AppConstants.keyDailyQuoteCount, _dailyQuoteCount);
      } catch (e) {
        debugPrint('Error saving daily quote count: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  bool isFavorite(Quote quote) {
    return _favorites.contains(quote);
  }

  // Toggle favorite: returns message or null if successful
  Future<String?> toggleFavorite(Quote quote, String userPlan) async {
    if (userPlan == AppConstants.planBasic) {
      return 'Basic plan does not support saving favorites. Please upgrade!';
    }

    if (_favorites.contains(quote)) {
      _favorites.remove(quote);
    } else {
      _favorites.add(quote);
    }
    notifyListeners();
    await _saveFavoritesToPrefs();
    return null;
  }

  Future<void> removeFavorite(Quote quote) async {
    _favorites.remove(quote);
    notifyListeners();
    await _saveFavoritesToPrefs();
  }

  Future<void> _saveFavoritesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favJsonList =
          _favorites.map((item) => json.encode(item.toJson())).toList();
      await prefs.setStringList(AppConstants.keyFavorites, favJsonList);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Helper method to reset limits for manual testing validation
  Future<void> debugResetDailyCount() async {
    _dailyQuoteCount = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyDailyQuoteCount, 0);
    notifyListeners();
  }

  // Load category tallies from SharedPreferences
  Future<void> _loadCategoryInteractions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(AppConstants.keyCategoryInteractions);
      if (rawJson != null) {
        final Map<String, dynamic> decoded = json.decode(rawJson);
        _categoryInteractions = decoded.map((key, val) => MapEntry(key, val as int));
      }
    } catch (e) {
      debugPrint('Error loading category interactions: $e');
    }
  }

  // Record user category preference interaction
  Future<void> recordCategoryInteraction(String categoryId) async {
    final normalizedId = categoryId.trim().toLowerCase();
    if (normalizedId.isEmpty) return;
    _categoryInteractions[normalizedId] = (_categoryInteractions[normalizedId] ?? 0) + 1;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyCategoryInteractions,
        json.encode(_categoryInteractions),
      );
    } catch (e) {
      debugPrint('Error saving category interaction: $e');
    }
  }

  // Sort interactions and return top 3 categories
  List<String> getTop3Categories() {
    final sortedEntries = _categoryInteractions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<String> top3 = sortedEntries.map((e) => e.key).take(3).toList();

    // Fallbacks if user hasn't visited/clicked enough categories yet
    final fallbacks = ['motivation', 'life', 'success'];
    for (final cat in fallbacks) {
      if (top3.length >= 3) break;
      if (!top3.contains(cat)) {
        top3.add(cat);
      }
    }
    // Capitalize first letter for neat prompt format
    return top3.map((c) => '${c[0].toUpperCase()}${c.substring(1)}').toList();
  }

  // Generate personalized AI quote using Anthropic API
  Future<bool> generateAiQuote(String userPlan) async {
    if (userPlan != AppConstants.planGold) {
      _aiError = "Gold plan required for AI personalized quotes.";
      notifyListeners();
      return false;
    }

    _isAiLoading = true;
    _aiError = null;
    notifyListeners();

    try {
      final top3 = getTop3Categories();
      final aiService = AnthropicService();
      final quote = await aiService.generatePersonalizedQuote(top3);

      // Cache the latest AI quote locally in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.keyCachedAiQuote,
        json.encode(quote.toJson()),
      );

      _currentQuote = quote;
      _isAiLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AI Quote generation error: $e');

      // Attempt to load from offline cache as fallback
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawCached = prefs.getString(AppConstants.keyCachedAiQuote);
        if (rawCached != null) {
          final cachedQuote = Quote.fromJson(json.decode(rawCached));
          _currentQuote = cachedQuote;
          _aiError = "Offline mode: Loaded latest cached AI quote.";
          _isAiLoading = false;
          notifyListeners();
          return true; // Return true as we successfully loaded fallback
        }
      } catch (cacheErr) {
        debugPrint('Cache read error: $cacheErr');
      }

      _aiError = e.toString();
      _isAiLoading = false;
      notifyListeners();
      return false;
    }
  }
}

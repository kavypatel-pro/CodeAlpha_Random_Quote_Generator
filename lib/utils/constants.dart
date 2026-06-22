import 'package:flutter/material.dart';

class AppConstants {
  // SharedPreferences Keys
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyRememberMe = 'remember_me';
  static const String keySavedEmail = 'saved_email';
  static const String keyCurrentUser = 'current_user';
  static const String keyFavorites = 'saved_favorites';
  static const String keyDailyQuoteCount = 'daily_quote_count';
  static const String keyDailyResetDate = 'daily_reset_date';
  static const String keyCategoryInteractions = 'category_interactions';
  static const String keyCachedAiQuote = 'cached_ai_quote';

  // Plan Names
  static const String planBasic = 'Basic';
  static const String planSilver = 'Silver';
  static const String planGold = 'Gold';

  // Plan Limits
  static const int basicDailyLimit = 10;

  // Plan Pricing
  static const String priceBasic = 'Free';
  static const String priceSilver = '\$2.99 / month';
  static const String priceGold = '\$5.99 / month';

  // Categories Definition
  static const List<CategoryInfo> categories = [
    CategoryInfo(
      id: 'motivation',
      name: 'Motivation',
      icon: Icons.bolt,
      color: Colors.purple,
    ),
    CategoryInfo(
      id: 'success',
      name: 'Success',
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),
    CategoryInfo(
      id: 'love',
      name: 'Love',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    CategoryInfo(
      id: 'life',
      name: 'Life',
      icon: Icons.eco,
      color: Colors.teal,
    ),
    CategoryInfo(
      id: 'wisdom',
      name: 'Wisdom',
      icon: Icons.menu_book,
      color: Colors.blue,
    ),
    CategoryInfo(
      id: 'humor',
      name: 'Humor',
      icon: Icons.sentiment_satisfied_alt,
      color: Colors.orange,
    ),
  ];
}

class CategoryInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

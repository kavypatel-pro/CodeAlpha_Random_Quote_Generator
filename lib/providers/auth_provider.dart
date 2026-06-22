import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  bool _isOnboardingCompleted = false;
  bool _isLoggedIn = false;
  bool _rememberMe = false;
  UserModel? _currentUser;

  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isLoggedIn => _isLoggedIn;
  bool get rememberMe => _rememberMe;
  UserModel? get currentUser => _currentUser;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
      _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
      _rememberMe = prefs.getBool(AppConstants.keyRememberMe) ?? false;

      if (_isLoggedIn) {
        final userJson = prefs.getString(AppConstants.keyCurrentUser);
        if (userJson != null) {
          _currentUser = UserModel.fromJson(json.decode(userJson));
        } else {
          // Fallback if null
          _currentUser = const UserModel(
            name: 'User',
            email: 'user@quoteverse.app',
            plan: AppConstants.planBasic,
            isGuest: false,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing auth provider: $e');
    }
  }

  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
    } catch (e) {
      debugPrint('Error saving onboarding preference: $e');
    }
  }

  Future<void> login({
    required String email,
    required String name,
    required bool remember,
  }) async {
    _isLoggedIn = true;
    _rememberMe = remember;
    _currentUser = UserModel(
      name: name,
      email: email,
      plan: AppConstants.planBasic, // Default to Basic on new sign in
      isGuest: false,
    );
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setBool(AppConstants.keyRememberMe, remember);
      if (remember) {
        await prefs.setString(AppConstants.keySavedEmail, email);
      } else {
        await prefs.remove(AppConstants.keySavedEmail);
      }
      await prefs.setString(AppConstants.keyCurrentUser, json.encode(_currentUser!.toJson()));
    } catch (e) {
      debugPrint('Error writing login details: $e');
    }
  }

  Future<void> loginAsGuest() async {
    _isLoggedIn = true;
    _rememberMe = false;
    _currentUser = UserModel.guest();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyCurrentUser, json.encode(_currentUser!.toJson()));
    } catch (e) {
      debugPrint('Error writing guest details: $e');
    }
  }

  Future<void> upgradePlan(String newPlan) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(plan: newPlan);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyCurrentUser, json.encode(_currentUser!.toJson()));
    } catch (e) {
      debugPrint('Error upgrading user plan: $e');
    }
  }

  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.keySavedEmail);
    } catch (e) {
      debugPrint('Error reading saved email: $e');
      return null;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      await prefs.remove(AppConstants.keyCurrentUser);
      await prefs.remove(AppConstants.keyDailyQuoteCount);
      await prefs.remove(AppConstants.keyDailyResetDate);
      // Keep keySavedEmail, keyOnboardingCompleted, and keyRememberMe as per login state requirements
    } catch (e) {
      debugPrint('Error clearing session on logout: $e');
    }
  }
}

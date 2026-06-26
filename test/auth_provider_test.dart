import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quoteverse/providers/auth_provider.dart';
import 'package:quoteverse/utils/constants.dart';

void main() {
  // Required to allow SharedPreferences mocking to register properly
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default values', () async {
      final authProvider = AuthProvider();
      
      // Wait for async constructor initialization to finish
      await Future.delayed(Duration.zero);

      expect(authProvider.isOnboardingCompleted, isFalse);
      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.rememberMe, isFalse);
      expect(authProvider.currentUser, isNull);
    });

    test('completeOnboarding sets state and persists to preferences', () async {
      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);

      await authProvider.completeOnboarding();

      expect(authProvider.isOnboardingCompleted, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConstants.keyOnboardingCompleted), isTrue);
    });

    test('login updates state and stores current user with Basic plan', () async {
      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);

      await authProvider.login(
        email: 'examiner@test.com',
        name: 'Examiner Test',
        remember: true,
      );

      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.rememberMe, isTrue);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.name, 'Examiner Test');
      expect(authProvider.currentUser!.email, 'examiner@test.com');
      expect(authProvider.currentUser!.plan, AppConstants.planBasic);
      expect(authProvider.currentUser!.isGuest, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConstants.keyIsLoggedIn), isTrue);
      expect(prefs.getBool(AppConstants.keyRememberMe), isTrue);
      expect(prefs.getString(AppConstants.keySavedEmail), 'examiner@test.com');
      
      final userJson = prefs.getString(AppConstants.keyCurrentUser);
      expect(userJson, isNotNull);
      final decodedUser = json.decode(userJson!);
      expect(decodedUser['email'], 'examiner@test.com');
      expect(decodedUser['plan'], AppConstants.planBasic);
    });

    test('loginAsGuest initializes Guest user session correctly', () async {
      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);

      await authProvider.loginAsGuest();

      expect(authProvider.isLoggedIn, isTrue);
      expect(authProvider.rememberMe, isFalse);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.isGuest, isTrue);
      expect(authProvider.currentUser!.plan, AppConstants.planBasic);
      expect(authProvider.currentUser!.name, 'Guest User');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConstants.keyIsLoggedIn), isTrue);
      final userJson = prefs.getString(AppConstants.keyCurrentUser);
      expect(userJson, isNotNull);
      expect(json.decode(userJson!)['isGuest'], isTrue);
    });

    test('upgradePlan switches user plan and persists changes', () async {
      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);

      await authProvider.login(
        email: 'premium@test.com',
        name: 'Premium Tester',
        remember: false,
      );

      await authProvider.upgradePlan(AppConstants.planGold);

      expect(authProvider.currentUser!.plan, AppConstants.planGold);

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.keyCurrentUser);
      expect(userJson, isNotNull);
      expect(json.decode(userJson!)['plan'], AppConstants.planGold);
    });

    test('logout clears logged-in state and current user info', () async {
      final authProvider = AuthProvider();
      await Future.delayed(Duration.zero);

      await authProvider.login(
        email: 'logout@test.com',
        name: 'Logout Test',
        remember: true,
      );

      await authProvider.logout();

      expect(authProvider.isLoggedIn, isFalse);
      expect(authProvider.currentUser, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConstants.keyIsLoggedIn), isFalse);
      expect(prefs.getString(AppConstants.keyCurrentUser), isNull);
    });
  });
}

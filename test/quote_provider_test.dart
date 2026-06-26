import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quoteverse/providers/quote_provider.dart';
import 'package:quoteverse/models/quote_model.dart';
import 'package:quoteverse/utils/constants.dart';

class MockAssetBundle extends CachingAssetBundle {
  final List<Map<String, String>> mockQuotes = [
    {"text": "Quote A", "author": "Author A", "category": "motivation"},
    {"text": "Quote B", "author": "Author B", "category": "success"},
    {"text": "Quote C", "author": "Author C", "category": "love"},
    {"text": "Quote D", "author": "Author D", "category": "life"},
    {"text": "Quote E", "author": "Author E", "category": "wisdom"},
    {"text": "Quote F", "author": "Author F", "category": "humor"},
  ];

  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/quotes.json') {
      final jsonStr = json.encode(mockQuotes);
      return ByteData.view(Uint8List.fromList(utf8.encode(jsonStr)).buffer);
    }
    throw Exception('Unknown asset: $key');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAssetBundle mockBundle;

  setUp(() {
    mockBundle = MockAssetBundle();
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(fileInput: 'ANTHROPIC_API_KEY=mock_anthropic_api_key_for_testing');
  });

  group('QuoteProvider Tests', () {
    test('Initializes quotes from assets and selects first quote', () async {
      final quoteProvider = QuoteProvider(assetBundle: mockBundle);
      await Future.delayed(Duration.zero);

      expect(quoteProvider.isInitialized, isTrue);
      expect(quoteProvider.allQuotes.length, mockBundle.mockQuotes.length);
      expect(quoteProvider.currentQuote, isNotNull);
      expect(quoteProvider.allQuotes.contains(quoteProvider.currentQuote), isTrue);
    });

    test('loadNewQuote respects daily limit under Basic plan', () async {
      final quoteProvider = QuoteProvider(assetBundle: mockBundle);
      await Future.delayed(Duration.zero);

      // On Basic plan, limit is AppConstants.basicDailyLimit (10)
      // The initial quote generation doesn't increment the limit (since it occurs on startup).
      // Let's generate quotes up to the limit:
      for (int i = 0; i < AppConstants.basicDailyLimit; i++) {
        final success = await quoteProvider.loadNewQuote(AppConstants.planBasic);
        expect(success, isTrue);
      }

      // Next load should fail because daily limit is reached
      final finalSuccess = await quoteProvider.loadNewQuote(AppConstants.planBasic);
      expect(finalSuccess, isFalse);
    });

    test('loadNewQuote has unlimited loads under Silver or Gold plans', () async {
      final quoteProvider = QuoteProvider(assetBundle: mockBundle);
      await Future.delayed(Duration.zero);

      // Upgrade plan to Silver, should easily bypass the basic daily limit (10)
      for (int i = 0; i < AppConstants.basicDailyLimit + 5; i++) {
        final success = await quoteProvider.loadNewQuote(AppConstants.planSilver);
        expect(success, isTrue);
      }
    });

    test('Favorites toggling stores quotes correctly for non-basic users', () async {
      final quoteProvider = QuoteProvider(assetBundle: mockBundle);
      await Future.delayed(Duration.zero);

      final quote = quoteProvider.currentQuote!;

      // Basic users cannot toggle favorites
      final basicError = await quoteProvider.toggleFavorite(quote, AppConstants.planBasic);
      expect(basicError, contains('Basic plan does not support saving favorites'));
      expect(quoteProvider.isFavorite(quote), isFalse);

      // Gold users can save favorites
      final goldError = await quoteProvider.toggleFavorite(quote, AppConstants.planGold);
      expect(goldError, isNull);
      expect(quoteProvider.isFavorite(quote), isTrue);

      // Remove favorite
      await quoteProvider.removeFavorite(quote);
      expect(quoteProvider.isFavorite(quote), isFalse);
    });

    test('recordCategoryInteraction and getTop3Categories track user preferences', () async {
      final quoteProvider = QuoteProvider(assetBundle: mockBundle);
      await Future.delayed(Duration.zero);

      await quoteProvider.recordCategoryInteraction('motivation');
      await quoteProvider.recordCategoryInteraction('motivation');
      await quoteProvider.recordCategoryInteraction('love');
      await quoteProvider.recordCategoryInteraction('success');

      final topCategories = quoteProvider.getTop3Categories();
      expect(topCategories.first, 'Motivation');
      expect(topCategories.contains('Love'), isTrue);
      expect(topCategories.contains('Success'), isTrue);
    });

    test('generateAiQuote falls back to cached quote when API throws error', () async {
      const quote = Quote(text: "Cached AI Quote", author: "Cached Author", category: "AI Personalization");
      
      // Seed cached AI quote in mock shared preferences
      SharedPreferences.setMockInitialValues({
        AppConstants.keyCachedAiQuote: json.encode(quote.toJson()),
      });

      final quoteProvider = QuoteProvider(assetBundle: mockBundle);
      await Future.delayed(Duration.zero);

      // Since the API Key is a mock key, generateAiQuote would throw an error and fallback to cache
      final success = await quoteProvider.generateAiQuote(AppConstants.planGold);
      expect(success, isTrue);
      expect(quoteProvider.currentQuote!.text, "Cached AI Quote");
      expect(quoteProvider.aiError, contains("Offline mode"));
    });

    test('generateAiQuote returns false for non-Gold users', () async {
      final quoteProvider = QuoteProvider(assetBundle: mockBundle);
      await Future.delayed(Duration.zero);

      final success = await quoteProvider.generateAiQuote(AppConstants.planSilver);
      expect(success, isFalse);
      expect(quoteProvider.aiError, contains("Gold plan required"));
    });
  });
}

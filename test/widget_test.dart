import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:quoteverse/providers/theme_provider.dart';
import 'package:quoteverse/providers/auth_provider.dart';
import 'package:quoteverse/providers/quote_provider.dart';
import 'package:quoteverse/main.dart';

class MockAssetBundle extends CachingAssetBundle {
  final List<Map<String, String>> mockQuotes = [
    {"text": "Mock Wisdom Quote", "author": "Mock Author", "category": "wisdom"}
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

  setUp(() {
    // Setup Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Setup Dotenv Mock
    dotenv.testLoad(fileInput: 'ANTHROPIC_API_KEY=mock_anthropic_api_key_for_testing');
  });

  testWidgets('App launches with SplashScreen and transitions to OnboardingScreen', (WidgetTester tester) async {
    final mockBundle = MockAssetBundle();

    // Build our app and trigger a frame, wrapping it with the required state Providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => QuoteProvider(assetBundle: mockBundle)),
        ],
        child: const MyApp(),
      ),
    );

    // Verify the Splash Screen has loaded and is displaying the branding
    expect(find.text('QuoteVerse'), findsOneWidget);
    expect(find.text('"Words that move you."'), findsOneWidget);

    // Pump and trigger the splash timer duration (2500ms)
    await tester.pump(const Duration(milliseconds: 2500));
    // Trigger transition and page transitions
    await tester.pumpAndSettle();

    // Verify it navigated to the OnboardingScreen
    expect(find.text('Discover Inspiring Quotes'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}

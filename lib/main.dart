import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/quote_provider.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Ensure Basic plan users are strictly locked to Light Theme
    final userPlan = authProvider.currentUser?.plan ?? AppConstants.planBasic;
    final isPremium = userPlan != AppConstants.planBasic;
    final activeThemeMode = (themeProvider.isDarkMode && isPremium)
        ? ThemeMode.dark
        : ThemeMode.light;

    return MaterialApp(
      title: 'QuoteVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: activeThemeMode,
      home: const SplashScreen(),
    );
  }
}

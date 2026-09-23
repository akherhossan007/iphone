import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notification_service.dart';
import 'logic/auth_provider.dart';
import 'logic/cart_provider.dart';
import 'logic/catalog_provider.dart';
import 'logic/home_provider.dart';
import 'logic/order_provider.dart';
import 'logic/wishlist_provider.dart';
import 'presentation/screens/main_nav_screen.dart';
import 'firebase_options.dart';

import 'logic/language_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Modern System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase & Push Notification Engine
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await NotificationService().initialize(navKey: navigatorKey);
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  }

  // Global Flutter Framework Error Handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('GlowBay FlutterError: ${details.exceptionAsString()}');
  };

  // Global Uncaught Asynchronous Error Handler
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('GlowBay Async Error: $error');
    return true;
  };

  // Graceful Fallback Widget for Release Mode
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 48),
              const SizedBox(height: 12),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please refresh or restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(const GlowBayApp());
}

class GlowBayApp extends StatelessWidget {
  const GlowBayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()..fetchProducts()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            key: ValueKey(langProvider.currentLanguage),
            navigatorKey: navigatorKey,
            title: 'GlowBayBD',
            debugShowCheckedModeBanner: false,
            locale: Locale(langProvider.currentLanguage),
            theme: AppTheme.lightTheme,
            home: const MainNavScreen(),
          );
        },
      ),
    );
  }
}

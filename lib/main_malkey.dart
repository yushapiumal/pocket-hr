import 'package:cn_pocket_hr/config/firebase_options_malkey.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/helpers/http_override.dart';
import 'package:cn_pocket_hr/main.dart'; // Ensure this points to your app widget
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // Required for splash control
import 'package:flutter/foundation.dart';

Future<void> main() async {
  // 1. Initialize binding and immediately preserve the native splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Run initialization tasks
  setupHttpOverride();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
    DeviceOrientation.portraitDown,
  ]);

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: MalkeyFirebaseOptions.currentPlatform);
  }

  // 3. Define branding/config (maintaining the exact full app color theme without alterations)
  const Color primary = Color(0xFF6A1311); // Dark crimson red
  const Color secondary = Color(0xffffcc09); // Gold
  const Color iconFg = secondary; 
  const Color iconBg = Color(0xFF6A1311);

  FlavorConfig.init(
    flavor: Flavor.malkey,
    appName: 'Malkey HR',
    apiBaseUrl: 'https://api.human.go.digitable.io/human/v2/api',
    packageName: defaultTargetPlatform == TargetPlatform.iOS
        ? 'io.digitable.go.malkey.human'
        : 'io.digitable.go.malkey.human',
    splashLogoAsset: 'assets/images/bg_remove_domex_app_logo.png',
    primaryColor: primary,
    secondaryColor: secondary,
    morningBg: 'assets/images/domex_home-banner3.jpg',
    afternoonBg: 'assets/images/domex_home-banner3.jpg',
    eveningBg: 'assets/images/domex_home-banner3.jpg',
    nightBg: 'assets/images/domex_home-banner3.jpg',
    iconColor: iconFg,
    iconBackgroundColor: iconBg,
    tenant: 'malkey',
    tabColor: const Color(0xFF791b27),
    tabLabelColor: secondary,
    bottomNavIconColor: secondary,
    bottomNavIconBgColor: const Color(0xFF791b27),
    buttonColor: primary,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
      ),
      primaryColor: primary,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
      fontFamily: 'Poppins',
    ),
  );

  // 4. Remove the splash screen now that app is ready
  FlutterNativeSplash.remove();

  // 5. Launch the application
  runApp(PocketHR());
}

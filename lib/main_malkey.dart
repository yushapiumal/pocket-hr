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

  // 3. Define Malkey branding & colors
  const Color primary = Color(0xFF1D64E2); // Malkey vibrant royal blue
  const Color secondary = Color(0xFF399BF6); // Malkey sky blue accent
  const Color cardColor = Colors.white;
  const Color backgroundColor = Color(0xFFF4F6F9);

  FlavorConfig.init(
    flavor: Flavor.malkey,
    appName: 'Malkey HR',
    apiBaseUrl: 'https://api.human.go.digitable.io/human/v2/api',
    packageName: defaultTargetPlatform == TargetPlatform.iOS
        ? 'io.digitable.go.malkey.human'
        : 'io.digitable.go.malkey.human',
    splashLogoAsset: 'assets/images/malkey_app_logo.png',
    primaryColor: primary,
    secondaryColor: secondary,
    morningBg: 'assets/images/domex_home-banner3.jpg',
    afternoonBg: 'assets/images/domex_home-banner3.jpg',
    eveningBg: 'assets/images/domex_home-banner3.jpg',
    nightBg: 'assets/images/domex_home-banner3.jpg',
    backgroundColor: backgroundColor,
    containerShadowColor: const Color(0xFFE2E8F0),
    lightWhiteColor: const Color(0xFFEBF2FC),
    splashBackgroundColor: primary,
    cardColor: cardColor,
    iconColor: Colors.white,
    iconBackgroundColor: primary,
    tenant: 'malkey',
    tabColor: primary,
    tabLabelColor: Colors.white,
    bottomNavIconColor: primary,
    bottomNavIconBgColor: const Color(0xFFEBF2FC),
    buttonColor: primary,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: cardColor,
      ),
      primaryColor: primary,
      cardColor: cardColor,
      scaffoldBackgroundColor: backgroundColor,
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
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 1,
      ),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: primary),
      fontFamily: 'Poppins',
    ),
  );

  // 4. Remove the splash screen now that app is ready
  FlutterNativeSplash.remove();

  // 5. Launch the application
  runApp(PocketHR());
}

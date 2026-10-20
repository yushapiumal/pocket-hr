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
  const Color primary = Color(0xFF334C5F); // rgb(51, 76, 95) Deep Slate Blue
  const Color secondary = Color(0xFF4F708B); // Slate accent
  const Color cardColor = Colors.white;
  const Color backgroundColor = Color(0xFFEAEEF1); // rgb(234, 238, 241) Clean Ice Slate

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
    morningBg: 'assets/images/malkey-banner.jpg',
    afternoonBg: 'assets/images/malkey-banner.jpg',
    eveningBg: 'assets/images/malkey-banner.jpg',
    nightBg: 'assets/images/malkey-banner.jpg',
    backgroundColor: backgroundColor,
    containerShadowColor: const Color(0xFFD2DCE2),
    lightWhiteColor: const Color(0xFFEAEEF1), // rgb(234, 238, 241)
    splashBackgroundColor: primary, // rgb(51, 76, 95) exactly matching native splash
    cardColor: cardColor,
    iconColor: primary,
    iconBackgroundColor: const Color(0xFFEAEEF1), // rgb(234, 238, 241) soft icon backing
    tenant: 'malkey',
    tabColor: primary,
    tabLabelColor: Colors.white,
    bottomNavIconColor: Colors.white,
    bottomNavIconBgColor: primary,
    bottomNavBarBgColor: Colors.grey.withOpacity(0.6),
    buttonColor: primary,
    brandPrimary: primary,
    brandLight: const Color(0xFFEAEEF1), // rgb(234, 238, 241)
    brandDarkText: const Color(0xFF1F2D38),
    brandGreyText: const Color(0xFF64748B),
    brandBorder: const Color(0xFFD5DFE6),
    brandAccent: const Color(0xFF4F708B),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
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

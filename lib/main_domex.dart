import 'package:cn_pocket_hr/config/firebase_options_domex.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/helpers/http_override.dart';
import 'package:cn_pocket_hr/main.dart'; // Ensure this points to your app widget
import 'package:cn_pocket_hr/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // Required for splash control

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
    await Firebase.initializeApp(options: DomexFirebaseOptions.currentPlatform);
  }

  // 3. Define branding/config
  const Color primary = Color(0xFF8B1818); // Domex dark crimson red
  const Color secondary = Color(0xFFE8B84B); // Domex gold
  const Color iconFg = Color(0xFF000000); 
  const Color iconBg = Color(0xFFEED06E);

  FlavorConfig.init(
    flavor: Flavor.domex,
    appName: 'DomEx Go',
    apiBaseUrl: 'https://api.human.go.digitable.io/human/v2/api',
    packageName: 'io.digitable.go.domex.human',
    splashLogoAsset: 'assets/images/domex_app_logo.png',
    primaryColor: primary,
    secondaryColor: secondary,
    iconColor: iconFg,
    iconBackgroundColor: iconBg,
    tenant: 'domex',
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

  // 4. Initialize services
  await FCMService.initialize();

  // 5. Remove the splash screen now that app is ready
  FlutterNativeSplash.remove();

  // 6. Launch the application
  runApp( PocketHR());
}
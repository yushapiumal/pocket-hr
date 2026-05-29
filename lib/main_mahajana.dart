import 'package:cn_pocket_hr/config/firebase_options_mahajana.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/helpers/http_override.dart';
import 'package:cn_pocket_hr/main.dart';
import 'package:cn_pocket_hr/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupHttpOverride();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(
      options: MahajanaFirebaseOptions.currentPlatform);

  const Color primary = Color(0xFF6A1B9A); // Mahajana purple
  const Color secondary = Color(0xFFE53935); // Mahajana red

  FlavorConfig.init(
    flavor: Flavor.mahajana,
    appName: 'Mahajana HR',
    apiBaseUrl: 'https://api.human.go.digitable.io/human/v2/api',
    packageName: 'com.mahajana.human.pocket',
    splashLogoAsset: 'assets/images/mahajana-logo.png',
    primaryColor: primary,
    secondaryColor: secondary,
    tenant: 'mahajana',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
      ),
      primaryColor: primary,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primary),
      ),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: Colors.white),
      fontFamily: 'Poppins',
    ),
  );

  await FCMService.initialize();
  runApp(PocketHR());
}

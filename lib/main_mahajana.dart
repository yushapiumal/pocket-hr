import 'package:cn_pocket_hr/config/firebase_options_mahajana.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/helpers/http_override.dart';
import 'package:cn_pocket_hr/main.dart';
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

  const Color primary = Color(0xFFC91032); // Mahajana red
  const Color secondary = Color.fromARGB(190, 9, 71, 133); // Mahajana blue

  FlavorConfig.init(
    flavor: Flavor.mahajana,
    appName: 'Mahajana Hr',
    apiBaseUrl: 'https://api.human.go.digitable.io/human/v2/api',
    packageName: 'io.digitable.go.mahajana.human',
    splashLogoAsset: 'assets/images/mahajana plash_logo.png',
    primaryColor: primary,
    secondaryColor: secondary,
    morningBg: 'assets/images/mahajana_home.png',
    afternoonBg: 'assets/images/mahajana_home.png',
    eveningBg: 'assets/images/mahajana_home.png',
    nightBg: 'assets/images/mahajana_home.png',
    backgroundColor: const Color(0xFFF4F7FC),
    containerShadowColor: const Color(0xFFE2E8F0),
    lightWhiteColor: const Color(0xFFEBF2FC),
    splashBackgroundColor: primary,
    iconColor: primary,
    iconBackgroundColor: const Color(0xFFFFEBEE),
    tenant: 'mahajana',
    tabColor: primary,
    tabLabelColor: Colors.white,
    bottomNavIconColor: Colors.white,
    bottomNavIconBgColor: primary,
    buttonColor: primary,
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

  runApp(PocketHR());
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cn_pocket_hr/config/firebase_options_digitable.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/helpers/http_override.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:cn_pocket_hr/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cn_pocket_hr/screens/splash_screen/splashscreen.dart';
import 'package:cn_pocket_hr/l10n/l10n.dart';
import 'package:cn_pocket_hr/providers/locale_provider.dart';
import 'package:cn_pocket_hr/routes.dart';
import 'package:provider/provider.dart';
import 'package:cn_pocket_hr/providers/connection_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupHttpOverride();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(
      options: DigitableFirebaseOptions.currentPlatform);

  // Default flavor (digitable) — used when running `flutter run` without -t flag
  if (!_flavorInitialized()) {
    const Color primary = Color(0xFF2D67CC);
    const Color secondary = Color(0xFFFF6F00);
    FlavorConfig.init(
      flavor: Flavor.digitable,
      appName: 'Pocket HR',
      apiBaseUrl: 'https://api.human.go.digitable.io/human/v2/api',
      packageName: 'asia.ceynet.human.pocket',
      splashLogoAsset: 'assets/images/app_logo.png',
      primaryColor: primary,
      secondaryColor: secondary,
      backgroundColor: const Color(0xFFF4F7FC),
      containerShadowColor: const Color(0xFFE2E8F0),
      lightWhiteColor: const Color(0xFFEBF2FC),
      splashBackgroundColor: const Color(0xFF2D67CC),
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
  }

  runApp(PocketHR());
}

bool _flavorInitialized() {
  try {
    FlavorConfig.instance;
    return true;
  } catch (_) {
    return false;
  }
}

//
class PocketHR extends StatelessWidget {
//
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ],
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);
          final conn = Provider.of<ConnectionProvider>(context);
          return MaterialApp(
            title: FlavorConfig.instance.appName,
            theme: FlavorConfig.instance.theme,
            navigatorKey: FCMService.navigatorKey,
            supportedLocales: L10n.all,
            locale: provider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            initialRoute: SplashScreen.routeName,
            routes: routes,
            builder: (context, widget) {
              return Stack(
                children: [
                  if (widget != null) widget,
                  if (conn.showBanner)
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      child: Material(
                        color: conn.isOnline ? Colors.green : Colors.red,
                        elevation: 6,
                        child: Container(
                          width: 12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                conn.isOnline
                                    ? (conn.isWifi
                                        ? 'Connected Wi-Fi'
                                        : (conn.isMobile
                                            ? 'Connected  Mobile Data'
                                            : 'Connected'))
                                    : AppLocalizations.of(context)!
                                        .noInternetConnection,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
}

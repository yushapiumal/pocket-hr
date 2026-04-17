import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cn_pocket_hr/screens/splash_screen/splashscreen.dart';
import 'package:cn_pocket_hr/l10n/l10n.dart';
import 'package:cn_pocket_hr/providers/locale_provider.dart';
import 'package:cn_pocket_hr/routes.dart'; 
import 'package:provider/provider.dart';
import 'package:cn_pocket_hr/providers/connection_provider.dart';

void main() {
  // add these lines
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
// 
  // run app
  runApp(PocketHR());
}
// 
class PocketHR extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
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
            title: 'Pocket-HR',
            theme: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.white,
              ),
            ),
            navigatorKey: navigatorKey,
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
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                conn.isOnline
                                    ? (conn.isWifi
                                        ? 'Connected Wi-Fi'
                                        : (conn.isMobile ? 'Connected  Mobile Data' : 'Connected'))
                                    : AppLocalizations.of(context)!.noInternetConnection,
                                style: const TextStyle(color: Colors.white ,fontSize: 16),
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

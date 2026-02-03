import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cn_pocket_hr/Screens/splashScreen/Splashscreen.dart';
import 'package:cn_pocket_hr/l10n/l10n.dart';
import 'package:cn_pocket_hr/provider/locale_provider.dart';
import 'package:cn_pocket_hr/routes.dart'; 

import 'package:provider/provider.dart';
// void main() => runApp(PocketHR());
// 
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
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);
// 
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
          );
        },
      );
}



// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Demo Home Page'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Welcome to Flutter!',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Add your onPressed functionality here
//               },
//               child: Text('Press Me'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

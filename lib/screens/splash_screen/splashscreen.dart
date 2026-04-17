import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cn_pocket_hr/screens/splash_screen/devices/mobile_splash.dart';
import 'package:cn_pocket_hr/screens/splash_screen/devices/tablet_splash.dart';
import 'package:cn_pocket_hr/ui/responsive_layout.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = "/splash";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return ResponsiveLayout(
      mobileBody: MobileSplash(),
      tabletBody: TabletSplash(),
    );
  }
}

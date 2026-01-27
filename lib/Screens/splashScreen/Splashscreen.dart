import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cn_pocket_hr/Screens/splashScreen/devices/mobileSplash.dart';
import 'package:cn_pocket_hr/Screens/splashScreen/devices/tabletSplash.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

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

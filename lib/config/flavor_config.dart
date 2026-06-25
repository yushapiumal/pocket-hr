import 'package:flutter/material.dart';

enum Flavor { digitable, domex, mahajana }

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final String packageName;

  /// Asset path for the splash screen logo, e.g. 'assets/images/app_logo.png'
  final String splashLogoAsset;

  /// Primary brand color — used for Check-In button and app primary
  final Color primaryColor;

  /// Secondary brand color — used for Check-Out button
  final Color secondaryColor;

  /// Icon foreground color (e.g. for dashboard/menu icons)
  final Color iconColor;

  /// Icon background/badge color (e.g. the circle behind dashboard icons).
  /// Null means use the default glass/blur style.
  final Color? iconBackgroundColor;

  /// Full MaterialApp theme built from the brand colors
  final ThemeData theme;

  /// Optional hardcoded tenant name — when set, the app skips tenant input
  /// on the login screen and uses this value everywhere (API headers, SSO, etc.).
  final String? tenant;

  /// Styling overrides for different tenants
  final Color backgroundColor;
  final Color containerShadowColor;
  final Color lightWhiteColor;
  final Color splashBackgroundColor;

  /// Tab indicator/background color for selected tabs
  final Color tabColor;

  /// Tab label text color for selected tabs
  final Color tabLabelColor;

  /// Selected icon color in the bottom navigation bar
  final Color bottomNavIconColor;

  /// Background circle color for selected bottom navigation icon
  final Color bottomNavIconBgColor;

  /// Button background color
  final Color buttonColor;

  /// Home page background images
  final String morningBg;
  final String afternoonBg;
  final String eveningBg;
  final String nightBg;

  static FlavorConfig? _instance;

  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.packageName,
    required this.splashLogoAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.iconColor,
    this.iconBackgroundColor,
    required this.theme,
    required this.morningBg,
    required this.afternoonBg,
    required this.eveningBg,
    required this.nightBg,
    this.tenant,
    this.backgroundColor = const Color(0xfffff9ef),
    this.containerShadowColor = const Color(0xffffe8b7),
    this.lightWhiteColor = const Color(0xfffee8c6),
    this.splashBackgroundColor = const Color(0xff7a1b28),
    Color? tabColor,
    Color? tabLabelColor,
    Color? bottomNavIconColor,
    Color? bottomNavIconBgColor,
    Color? buttonColor,
  }) : this.tabColor = tabColor ?? primaryColor,
       this.tabLabelColor = tabLabelColor ?? secondaryColor,
       this.bottomNavIconColor = bottomNavIconColor ?? secondaryColor,
       this.bottomNavIconBgColor = bottomNavIconBgColor ?? const Color(0xFF791b27),
       this.buttonColor = buttonColor ?? primaryColor;

  static void init({
    required Flavor flavor,
    required String appName,
    required String apiBaseUrl,
    required String packageName,
    required String splashLogoAsset,
    required Color primaryColor,
    required Color secondaryColor,
    required String morningBg,
    required String afternoonBg,
    required String eveningBg,
    required String nightBg,
    Color iconColor = Colors.white,
    Color? iconBackgroundColor,
    required ThemeData theme,
    String? tenant,
    Color backgroundColor = const Color(0xfffff9ef),
    Color containerShadowColor = const Color(0xffffe8b7),
    Color lightWhiteColor = const Color(0xfffee8c6),
    Color splashBackgroundColor = const Color(0xff7a1b28),
    Color? tabColor,
    Color? tabLabelColor,
    Color? bottomNavIconColor,
    Color? bottomNavIconBgColor,
    Color? buttonColor,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      apiBaseUrl: apiBaseUrl,
      packageName: packageName,
      splashLogoAsset: splashLogoAsset,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      theme: theme,
      tenant: tenant,
      backgroundColor: backgroundColor,
      containerShadowColor: containerShadowColor,
      lightWhiteColor: lightWhiteColor,
      splashBackgroundColor: splashBackgroundColor,
      tabColor: tabColor,
      tabLabelColor: tabLabelColor,
      bottomNavIconColor: bottomNavIconColor,
      bottomNavIconBgColor: bottomNavIconBgColor,
      buttonColor: buttonColor,
      morningBg: morningBg,
      afternoonBg: afternoonBg,
      eveningBg: eveningBg,
      nightBg: nightBg,
    );
  }

  static FlavorConfig get instance {
    assert(_instance != null,
        'FlavorConfig not initialized. Call FlavorConfig.init() in main.');
    return _instance!;
  }

  static bool get isDigitable => instance.flavor == Flavor.digitable;
  static bool get isDomex => instance.flavor == Flavor.domex;
  static bool get isMahajana => instance.flavor == Flavor.mahajana;
}

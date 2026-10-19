import 'package:flutter/material.dart';

enum Flavor { digitable, domex, mahajana, malkey }

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
  final Color cardColor;

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

  /// Accent / primary brand color for screens (e.g., Domex burgundy, Malkey royal blue)
  final Color brandPrimary;

  /// Soft light tint for card headers, balance summaries, tabs
  final Color brandLight;

  /// Dark text color matching the tenant
  final Color brandDarkText;

  /// Subtle grey text color
  final Color brandGreyText;

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
    this.cardColor = Colors.white,
    Color? tabColor,
    Color? tabLabelColor,
    Color? bottomNavIconColor,
    Color? bottomNavIconBgColor,
    Color? buttonColor,
    Color? brandPrimary,
    Color? brandLight,
    Color? brandDarkText,
    Color? brandGreyText,
  }) : this.tabColor = tabColor ?? primaryColor,
       this.tabLabelColor = tabLabelColor ?? secondaryColor,
       this.bottomNavIconColor = bottomNavIconColor ?? secondaryColor,
       this.bottomNavIconBgColor = bottomNavIconBgColor ?? (flavor == Flavor.domex ? const Color(0xFF791b27) : primaryColor.withOpacity(0.12)),
       this.buttonColor = buttonColor ?? primaryColor,
       this.brandPrimary = brandPrimary ?? (flavor == Flavor.domex ? const Color(0xFF701A27) : primaryColor),
       this.brandLight = brandLight ?? (flavor == Flavor.domex ? const Color(0xFFFAF2EB) : (flavor == Flavor.malkey ? const Color(0xFFEBF2FC) : lightWhiteColor)),
       this.brandDarkText = brandDarkText ?? (flavor == Flavor.domex ? const Color(0xFF4A1521) : (flavor == Flavor.malkey ? const Color(0xFF0F2C6B) : const Color(0xFF1F2A36))),
       this.brandGreyText = brandGreyText ?? (flavor == Flavor.domex ? const Color(0xFF7D6C6F) : const Color(0xFF6B7280));

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
    Color cardColor = Colors.white,
    Color? tabColor,
    Color? tabLabelColor,
    Color? bottomNavIconColor,
    Color? bottomNavIconBgColor,
    Color? buttonColor,
    Color? brandPrimary,
    Color? brandLight,
    Color? brandDarkText,
    Color? brandGreyText,
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
      cardColor: cardColor,
      tabColor: tabColor,
      tabLabelColor: tabLabelColor,
      bottomNavIconColor: bottomNavIconColor,
      bottomNavIconBgColor: bottomNavIconBgColor,
      buttonColor: buttonColor,
      brandPrimary: brandPrimary,
      brandLight: brandLight,
      brandDarkText: brandDarkText,
      brandGreyText: brandGreyText,
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
  static bool get isMalkey => instance.flavor == Flavor.malkey;
}

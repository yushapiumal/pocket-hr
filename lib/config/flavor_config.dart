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
    this.tenant,
  });

  static void init({
    required Flavor flavor,
    required String appName,
    required String apiBaseUrl,
    required String packageName,
    required String splashLogoAsset,
    required Color primaryColor,
    required Color secondaryColor,
    Color iconColor = Colors.white,
    Color? iconBackgroundColor,
    required ThemeData theme,
    String? tenant,
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

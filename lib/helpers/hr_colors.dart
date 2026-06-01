import 'dart:ui' show Color;
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:flutter/material.dart';

class HRColors {
  static const Color shift = Color.fromRGBO(67, 160, 71, 1);
  static const Color dutyOff = Color.fromRGBO(249, 168, 37, 1);

  static const Color red = Color(0xFFD32F2F);
  static const Color iconColor = Color(0xFF88959d);
  static const Color bottomColor = Color(0xFFFED130);
  static const Color lableColor = Color(0xFF29D2C8);
  static const Color blueColor = Color(0xFF2D67CC);
  static const Color yellow = Color(0xffffcc09);

  static const Color white = Color(0xFFffffff);
  static const Color black = Color(0xFF000000);
  static const Color green = Color(0xff00d285);
  static const Color darkFontColor = Color(0xff565759);
  static const Color lightFontColor = Color(0xff939495);

  // These three return the active flavor's primary color so every screen
  // automatically matches the current tenant's brand.
  static Color get darkOrangeColor => FlavorConfig.instance.primaryColor;
  static Color get lightOrangeColor =>
      FlavorConfig.instance.primaryColor.withOpacity(0.18);
  static Color get orangeColor => FlavorConfig.instance.primaryColor;

  /// Active flavor's secondary color (usually yellow/gold for Domex)
  static Color get secondaryColor => FlavorConfig.instance.secondaryColor;

  /// Active flavor's icon background color
  static Color get iconBackgroundColor =>
      FlavorConfig.instance.iconBackgroundColor ?? const Color(0xffffcc09);

  /// Tenant-specific icon foreground color.
  static Color get flavorIconColor => FlavorConfig.instance.iconColor;

  /// Tenant-specific icon background color (null = use default glass style).
  static Color? get flavorIconBackgroundColor =>
      FlavorConfig.instance.iconBackgroundColor;

  static const Color intro1Sed1Color = Color(0xfffedd8c);
  static const Color intro1Sed2Color = Color(0xfff7c361);
  static const Color intro1Sed3Color = Color(0xfff7b53e);
  static const Color intro2Sed1Color = Color(0xffef89a0);
  static const Color intro2Sed2Color = Color(0xfff892a9);
  static const Color intro2Sed3Color = Color(0xffe27996);
  static const Color intro3Sed1Color = Color(0xff3dc6b5);
  static const Color intro3Sed2Color = Color(0xff44cfc0);
  static const Color intro3Sed3Color = Color(0xff38a7a6);

  static const Color intro1ShadowColor = Color(0xffc8973c);
  static const Color intro2ShadowColor = Color(0xffdc6472);
  static const Color intro3ShadowColor = Color(0xbf35939f);

  static const Color intro1buttonColor = Color(0x52f7b53e);
  static const Color intro1buttonTextColor = Color(0xfff7bc4f);
  static const Color intro2buttonColor = Color(0x52e27996);
  static const Color intro2buttonTextColor = Color(0xffec849f);
  static const Color intro3buttonColor = Color(0x5238a7a6);
  static const Color intro3buttonTextColor = Color(0xff3db9b2);
  static const Color backgroundColor = Color(0xfffff9ef);
  static const Color grayColor = Color(0xff939495);
  // orangeColor is defined as a getter above; this duplicate is removed.
  static const Color continueShoppingGradient1Color = Color(0xfffec230);
  static const Color continueShoppingGradient2Color = Color(0xfff9a825);
  static const Color backButtonBoxColor = Color(0x80000000);
  static const Color containerShadowColor = Color(0xffffe8b7);
  static const Color lightWhiteColor = Color(0xfffee8c6);
  static const Color grayTabColor = Color(0xffa1a1a1);
  static const Color splashYellow = Color(0xffffcc09);
  static const Color splashbackgroundColor = splashYellow;
  static const Color blackTransparentColor = Color(0x80000000);

  static const MaterialColor appcolor_material = const MaterialColor(
    0xFFFE724C,
    const <int, Color>{
      50: const Color(0xFFFE724C),
      100: const Color(0xFFFE724C),
      200: const Color(0xFFFE724C),
      300: const Color(0xFFFE724C),
      400: const Color(0xFFFE724C),
      500: const Color(0xFFFE724C),
      600: const Color(0xFFFE724C),
      700: const Color(0xFFFE724C),
      800: const Color(0xFFFE724C),
      900: const Color(0xFFFE724C),
    },
  );
}


// #791b27

// . 
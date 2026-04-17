import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('en'),
    const Locale('si'),
    const Locale('ta'),
  ];

  static String getCode(String code) {
    switch (code) {
      case 'en':
        return 'EN';
      case 'si':
        return 'SI';
      case 'ta':
        return 'TA';
      default:
        return 'EN';
    }
  }
}

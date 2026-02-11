import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Backgrounds / surfaces
  static const Color pageBg = Colors.white;
  static const Color surface = Color.fromARGB(255, 248, 250, 252);
  static const Color card = Colors.white;

  // Borders / shadows
  static Color borderColor = Colors.black.withOpacity(0.05);
  static Color shadowColor = Colors.black.withOpacity(0.06);

  // Typography
  static const TextStyle headerTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Colors.black87,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.black87,
  );

  // Common UI helpers
  static BoxDecoration cardDecoration({double radius = 16}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(color: shadowColor.withOpacity(0.7), blurRadius: 12, offset: const Offset(0, 6)),
      ],
    );
  }

  static BoxDecoration whiteIconButtonDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(40),
      border: Border.all(color: Colors.black.withOpacity(0.06)),
    );
  }
}

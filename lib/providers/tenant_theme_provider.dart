// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cn_pocket_hr/helpers/hr_colors.dart';
// import 'package:cn_pocket_hr/helpers/tenant_helper.dart';

// /// Drives the full app colour theme based on the logged-in tenant.
// ///
// /// Update after login:
// ///   context.read<TenantThemeProvider>().updateTenant('domex');
// ///
// /// Read accent in a widget:
// ///   context.watch<TenantThemeProvider>().accent
// ///
// /// Read accent outside widgets (toasts, services):
// ///   TenantThemeProvider.staticAccent
// class TenantThemeProvider extends ChangeNotifier {
//   // ── state ───────────────────────────────────────────────────────────────────
//   Color _accent = TenantHelper.defaultAccent; // teal  #00D4BC (Digitable)
//   Color _primary = TenantHelper.defaultPrimary; // navy  #050B2E
//   Color _checkIn = TenantHelper.defaultAccent; // check-in button color

//   // ── static accessor for non-widget contexts ─────────────────────────────────
//   static Color _staticAccent = TenantHelper.defaultAccent;
//   static Color _staticPrimary = TenantHelper.defaultPrimary;
//   static Color get staticAccent => _staticAccent;
//   static Color get staticPrimary => _staticPrimary;

//   // ── public getters ──────────────────────────────────────────────────────────
//   Color get accent => _accent;
//   Color get primary => _primary;
//   Color get checkInColor => _checkIn;

//   /// Light wash of accent – used for selected nav pill backgrounds.
//   Color get lightAccent =>
//       Color.alphaBlend(_accent.withOpacity(0.18), Colors.white);

//   // ── constructor: auto-loads stored tenant on startup ────────────────────────
//   TenantThemeProvider() {
//     _loadFromStorage();
//   }

//   // ── public methods ──────────────────────────────────────────────────────────

//   /// Call after successful login / logout to switch the app palette.
//   void updateTenant(String? tenant) => _apply(tenant);

//   /// Shortcut: read provider from context.
//   static TenantThemeProvider of(BuildContext context, {bool listen = false}) =>
//       Provider.of<TenantThemeProvider>(context, listen: listen);

//   // ── private ─────────────────────────────────────────────────────────────────
//   Future<void> _loadFromStorage() async {
//     final tenant = await TenantHelper.getCurrentTenant();
//     _apply(tenant);
//   }

//   void _apply(String? tenant) {
//     _accent = TenantHelper.getAccentColor(tenant);
//     _primary = TenantHelper.getPrimaryColor(tenant);
//     _checkIn = TenantHelper.getCheckInColor(tenant);
//     _staticAccent = _accent;
//     _staticPrimary = _primary;

//     // Derive tonal variants
//     final dark = Color.lerp(_accent, Colors.black, 0.20) ?? _accent;
//     final light = Color.alphaBlend(_accent.withOpacity(0.15), Colors.white);

//     // ── Sync HRColors mutable statics so ALL existing widgets update ────────
//     HRColors.orangeColor = _accent;
//     HRColors.darkOrangeColor = dark;
//     HRColors.lightOrangeColor = light;
//     HRColors.lightWhiteColor = light;
//     HRColors.bottomColor = _accent;
//     HRColors.lableColor = _accent;
//     HRColors.yellow = _accent;
//     HRColors.gradientOneColor = _accent;
//     HRColors.gradientTwoColor = dark;
//     HRColors.containerShadowColor =
//         Color.alphaBlend(_accent.withOpacity(0.30), Colors.white);
//     HRColors.continueShoppingGradient1Color = _accent;
//     HRColors.continueShoppingGradient2Color = dark;
//     // blueColor kept as-is (functional secondary, not brand identity)

//     notifyListeners();
//   }

//   // ── dynamic ThemeData for MaterialApp ──────────────────────────────────────
//   ThemeData get themeData => ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: _accent,
//           primary: _accent,
//           secondary: HRColors.blueColor,
//           surface: Colors.white,
//           onPrimary: Colors.white,
//           onSecondary: Colors.white,
//           primaryContainer: lightAccent,
//           onPrimaryContainer: _accent,
//         ),
//         primaryColor: _accent,
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: AppBarTheme(
//           backgroundColor: _primary,
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: _accent,
//             foregroundColor: Colors.white,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(14)),
//             ),
//           ),
//         ),
//         floatingActionButtonTheme: FloatingActionButtonThemeData(
//           backgroundColor: _accent,
//           foregroundColor: Colors.white,
//         ),
//         progressIndicatorTheme: ProgressIndicatorThemeData(
//           color: _accent,
//         ),
//         textSelectionTheme: TextSelectionThemeData(
//           cursorColor: _accent,
//           selectionHandleColor: _accent,
//         ),
//       );
// }

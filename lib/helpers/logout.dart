import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cn_pocket_hr/screens/login/login_screen.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/services/fcm_service.dart';

class LogoutHelper {
  static Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppLocalizations.of(dialogContext)!.logoutText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(dialogContext)!.logoutConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              // 🔥 CLEAR ALL USER DATA FROM LOCAL STORAGE
              // Save device-level preferences first so they survive the wipe
              try {
                final ls = LocalStorage('pocketHR');
                await ls.ready;
                final savedLang = ls.getItem('lang')?.toString();
                // Wipe everything — this removes stale profile, leave data,
                // attendance state, tokens, etc. so the next user sees fresh data
                await ls.clear();
                // Restore device preference
                if (savedLang != null && savedLang.isNotEmpty) {
                  await ls.setItem('lang', savedLang);
                }
              } catch (_) {}

              // 🔥 CLEAR SECURE STORAGE
              try {
                const secure = FlutterSecureStorage();
                await secure.deleteAll();
              } catch (_) {}

              // 🔥 CLEAR FCM PENDING BUFFER & BADGE
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('fcm_pending_notifications');
              } catch (_) {}
              await FCMService.reset();

              if (!context.mounted) return;

              // 🔥 NAVIGATE LOGIN
              Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(HRLogin.routeName, (route) => false);
            },
            child: Text(
              AppLocalizations.of(dialogContext)!.logoutText,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

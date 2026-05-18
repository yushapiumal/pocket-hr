import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cn_pocket_hr/screens/login/login_screen.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';

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

              // 🔥 CLEAR LOCAL STORAGE
              try {
                final ls = LocalStorage('pocketHR');
                await ls.ready;
                await ls.setItem('access_token', '');
                await ls.setItem('token', '');
                await ls.setItem('refresh_token', '');
                await ls.setItem('uid', '');
                await ls.setItem('human_user_id', '');
                await ls.setItem('login', false);

                try {
                  await ls.deleteItem('tenant');
                } catch (_) {
                  await ls.setItem('tenant', '');
                }
              } catch (_) {}

              // 🔥 CLEAR SECURE STORAGE
              try {
                const secure = FlutterSecureStorage();
                await secure.delete(key: 'access_token');
                await secure.delete(key: 'refresh_token');
                await secure.delete(key: 'token');
              } catch (_) {}

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

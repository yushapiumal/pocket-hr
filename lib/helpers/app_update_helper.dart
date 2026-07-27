import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/services/fcm_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateHelper {
  static bool _isShowing = false;

  /// Checks response status code or body for 426 / APP_UPDATE_REQUIRED.
  /// If detected, shows the mandatory app update bottom sheet.
  static bool handlePotentialUpdateRequired(int statusCode, [dynamic responseBody]) {
    bool isUpdateRequired = statusCode == 426;

    if (!isUpdateRequired && responseBody != null) {
      final str = responseBody.toString();
      if (str.contains('APP_UPDATE_REQUIRED') || str.contains('Please update your app')) {
        isUpdateRequired = true;
      }
    }

    if (isUpdateRequired) {
      showUpdateBottomSheet();
      return true;
    }
    return false;
  }

  static Map<String, String> _getLocalizedTexts(BuildContext context) {
    try {
      final loc = AppLocalizations.of(context);
      if (loc != null) {
        return {
          'title': loc.appUpdateRequiredTitle,
          'message': loc.appUpdateRequiredMessage,
          'button': loc.appUpdateRequiredButton,
        };
      }
    } catch (_) {}

    String lang = 'en';
    try {
      final locale = Localizations.localeOf(context);
      lang = locale.languageCode.toLowerCase();
    } catch (_) {}

    if (lang == 'si') {
      return {
        'title': 'නව යාවත්කාලීන කිරීමක් අවශ්‍යයි',
        'message': 'ඉදිරියට යාම සඳහා කරුණාකර ඔබගේ යෙදුම නවතම අනුවාදයට යාවත්කාලීන කරන්න.',
        'button': 'දැන් යාවත්කාලීන කරන්න',
      };
    } else if (lang == 'ta') {
      return {
        'title': 'பயன்பாட்டை புதுப்பிக்க வேண்டும்',
        'message': 'தொடர, தயவுசெய்து உங்கள் பயன்பாட்டை புதிய பதிப்பிற்கு புதுப்பிக்கவும்.',
        'button': 'இப்போதே புதுப்பிக்கவும்',
      };
    } else {
      return {
        'title': 'App Update Required',
        'message': 'Please update your app to the latest version to continue.',
        'button': 'Update Now',
      };
    }
  }

  static void showUpdateBottomSheet() {
    if (_isShowing) return;
    final context = FCMService.navigatorKey.currentContext;
    if (context == null) return;

    _isShowing = true;

    Color primaryColor;
    try {
      primaryColor = FlavorConfig.instance.primaryColor;
    } catch (_) {
      primaryColor = HRColors.buttonColor;
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final texts = _getLocalizedTexts(ctx);
        return PopScope(
          canPop: false,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    size: 36,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  texts['title']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  texts['message']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      await openStore();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      texts['button']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _isShowing = false;
    });
  }

  static Future<void> openStore() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final packageName = info.packageName;
      Uri url;

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        url = Uri.parse('https://apps.apple.com/app/id6739943444');
      } else {
        url = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('AppUpdateHelper: openStore failed: $e');
    }
  }
}

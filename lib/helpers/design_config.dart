import 'package:auto_size_text/auto_size_text.dart';
import 'dart:ui';
import 'package:cn_pocket_hr/contact_us.dart/contact_us.dart';
import 'package:cn_pocket_hr/helpers/logout.dart';
import 'package:cn_pocket_hr/screens/allowances_deductions/allowance.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart'; 
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/screens/salary_slips/salary_slips.dart'; 
import 'package:cn_pocket_hr/helpers/flutter_rating_bar.dart';
import 'package:cn_pocket_hr/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:cn_pocket_hr/screens/debts_and_loans/debts_and_loans_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DesignConfig {
  static String getPngImagePath(String imageName) {
    return "assets/images/img/$imageName";
  }

  static String getSvgImagePath(String imageName) {
    return "assets/svg/$imageName";
  }

  static BoxDecoration boxDecorationIntroductionColor(
      Color color1, Color color2, double sizes) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [color1, color2],
          begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(sizes),
        topRight: Radius.circular(sizes),
      ),
    );
  }

  static RoundedRectangleBorder setRoundedBorder(
      Color bordercolor, double bradius, bool issetside) {
    return RoundedRectangleBorder(
        side: BorderSide(color: bordercolor, width: 0),
        borderRadius: BorderRadius.circular(bradius));
  }

  static BoxDecoration boxDecorationButton(Color color1, Color color2) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [color1, color2],
          begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static BoxDecoration boxDecorationContainer(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationBorderButtonColor(
      Color color, double sizes) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(sizes),
        border: Border.all(color: color, width: 1));
  }

  static BoxDecoration boxDecorationButtonColor(
      Color color1, Color color2, double sizes) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [color1, color2],
          begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.circular(sizes),
    );
  }

  static BoxDecoration boxDecorationLeafButtonColor(
      Color color1, Color color2, double sizes) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [color1, color2],
          begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(sizes),
        bottomRight: Radius.circular(sizes),
      ),
    );
  }

  // ==================== DRAWER WITH YOUR BG COLOR ====================
  static Widget drawerContent(GlobalKey<ScaffoldState> scaffoldKey, BuildContext context) {
    Widget langPicker() {
      final provider = Provider.of<LocaleProvider>(context);
      final LocalStorage storage = LocalStorage('pocketHR');

      return Container(
        margin: const EdgeInsets.only(top: 80.0, left: 8.0, right: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLangButton(provider, storage, 'EN', 'en'),
            _buildLangButton(provider, storage, 'සිං', 'si'),
            _buildLangButton(provider, storage, 'தமிழ்', 'ta'),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        height: double.infinity,
        decoration: BoxDecoration(
          color: HRColors.white, // Your requested background color
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12.0,
              offset: Offset(3, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 70,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: DesignConfig.boxDecorationButtonColor(
                          HRColors.white.withOpacity(0.9),
                          HRColors.white.withOpacity(0.9),
                          50),
                      child: const Icon(Icons.close, color: HRColors.black),
                    ),
                  ),
                  const SizedBox(width: 20),
                  AutoSizeText(
                    AppLocalizations.of(context)!.menuText,
                    style: const TextStyle(
                        fontSize: 20,
                        color: HRColors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(horizontal: 1, vertical: -2),
                    onTap: () => Navigator.pushNamed(context, '/team'),
                    leading: const Icon(Icons.people_alt, color: HRColors.black),
                    title: AutoSizeText(
                      AppLocalizations.of(context)!.myTeam,
                      style: const TextStyle(fontSize: 17, color: HRColors.black),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(horizontal: 1, vertical: -2),
                    onTap: () => Navigator.pushNamed(context, HRSalarySlips.routeName),
                    leading: const Icon(Icons.receipt_long, color: HRColors.black),
                    title: AutoSizeText(
                      AppLocalizations.of(context)!.salarySlips,
                      style: const TextStyle(fontSize: 17, color: HRColors.black),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(horizontal: 1, vertical: -2),
                    onTap: () => Navigator.pushNamed(context, HRAllowancesDeductions.routeName),
                    leading: const Icon(Icons.account_balance_wallet_outlined, color: HRColors.black),
                    title: AutoSizeText(
                      AppLocalizations.of(context)!.allowanceDeductions,
                      style: const TextStyle(fontSize: 17, color: HRColors.black),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(horizontal: 1, vertical: -2),
                    onTap: () => Navigator.pushNamed(context, HRDebtsAndLoans.routeName),
                    leading: const Icon(Icons.payments_outlined, color: HRColors.black),
                    title: AutoSizeText(
                      AppLocalizations.of(context)!.debtLoans,
                      style: const TextStyle(fontSize: 17, color: HRColors.black),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(horizontal: 1, vertical: -4),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) =>  HRContactUs()),
                      );
                    },
                    leading: const Icon(Icons.contact_support_outlined, color: HRColors.black),
                    title: AutoSizeText(
                      AppLocalizations.of(context)!.contactUsText,
                      style: const TextStyle(fontSize: 17, color: HRColors.black),
                    ),
                  ),

                  // Refresh Button as ListTile
                  const _RefreshListTile(),

                  const SizedBox(height: 20),
                  langPicker(),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Bottom Section: Logout + Version
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: HRColors.white,
              ),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  String version = "1.0.0";
                  if (snapshot.hasData) {
                    version = snapshot.data!.version;
                    if (snapshot.data!.buildNumber != null && snapshot.data!.buildNumber!.isNotEmpty) {
                      version = "${snapshot.data!.version}+${snapshot.data!.buildNumber}";
                    }
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => LogoutHelper.logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout_rounded, size: 20),
                              const SizedBox(width: 8),
                              AutoSizeText(
                                AppLocalizations.of(context)!.logoutText,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AutoSizeText(
                        'App Version $version',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLangButton(LocaleProvider provider, LocalStorage storage, String text, String langCode) {
    return GestureDetector(
      child: ElevatedButton(
        onPressed: () {
          provider.setLocale(Locale(langCode));
          storage.setItem('lang', langCode);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: AutoSizeText(text, style: const TextStyle(color: Colors.black)),
      ),
    );
  }

  // ==================== FIXED showTopToast (No more TickerProvider error) ====================
  static void showTopToast(BuildContext context, String message, {Color? background}) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: background ?? const Color(0xFF323232),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  // ==================== OTHER METHODS (unchanged) ====================
  static Widget displayCourseImage(String image, double height, double width) {
    return Image.asset(image, width: width, height: height, fit: BoxFit.fill);
  }

  static Widget displayRating(String rating, bool isfullratingbar) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
      child: Row(
        children: <Widget>[
          isfullratingbar
              ? RatingBarIndicator(
                  rating: double.parse(rating),
                  itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 14,
                  direction: Axis.horizontal,
                )
              : const Icon(Icons.star, size: 14, color: Colors.amber),
          AutoSizeText("\t\t$rating", style: const TextStyle(color: HRColors.white, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  static Widget displayRatingFull(String? rating, bool isfullratingbar) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
      child: Row(
        children: <Widget>[
          isfullratingbar
              ? RatingBarIndicator(
                  rating: double.parse(rating!),
                  itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 14,
                  direction: Axis.horizontal,
                )
              : const Icon(Icons.star, size: 14, color: Colors.amber),
        ],
      ),
    );
  }
}

// ==================== REFRESH AS LISTTILE (Fixed) ====================
class _RefreshListTile extends StatefulWidget {
  const _RefreshListTile({Key? key}) : super(key: key);

  @override
  __RefreshListTileState createState() => __RefreshListTileState();
}

class __RefreshListTileState extends State<_RefreshListTile> with TickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _spinController.repeat();

    try {
      final APIService apiService = APIService();
      await apiService.fetchMeProfileWithBearer(forceRefresh: true);

      if (mounted) {
        DesignConfig.showTopToast(
          context,
          AppLocalizations.of(context)!.refreshSuccess,
          background: Colors.green,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
        _spinController.stop();
        _spinController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: 1, vertical: -2),
      onTap: _isRefreshing ? null : _onTap,
      leading: RotationTransition(
        turns: _spinController,
        child: const Icon(Icons.refresh, color: HRColors.black, size: 24),
      ),
      title: AutoSizeText(
        _isRefreshing ? AppLocalizations.of(context)!.refreshing : AppLocalizations.of(context)!.refresh,
        style: const TextStyle(fontSize: 17, color: HRColors.black, fontWeight: FontWeight.normal),
      ),
    );
  }
}
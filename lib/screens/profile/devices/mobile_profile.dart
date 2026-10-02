import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/helpers/custom_blur_hash.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/services/fcm_service.dart';

class MobileProfile extends StatefulWidget {
  @override
  _MobileProfileState createState() => _MobileProfileState();
}

class _MobileProfileState extends State<MobileProfile> {
  final APIService _apiService = APIService();
  final LocalStorage storage = LocalStorage('pocketHR');

  bool _loadingMe = false;
  String? _error;
  bool _photoLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Profile data
  String _headerFullName = '';
  String _headerEpf = '';
  String _profilePhotoUrl = '';
  String _email = '';
  String _designation = '';
  String _department = '';
  String _phone = '';
  String _address = '';
  String _nic = '';
  String _dob = '';

  // Colors
  static Color get _primaryColor => HRColors.darkOrangeColor;
  static const Color _secondaryColor = Color(0xFF6366F1);
  static const Color _backgroundColor = Colors.white;
  static const Color _cardColor = Color(0xFFFAF2EB);
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _textTertiary = Color(0xFF94A3B8);
  static const Color _dividerColor = Color(0xFFE2E8F0);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadProfileData();
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadProfileData() async {
    if (_loadingMe) return;
    setState(() {
      _loadingMe = true;
      _error = null;
    });

    try {
      final meProfile = await _apiService.fetchMeProfileWithBearer();
      if (meProfile == null) {
        setState(() {
          _error = AppLocalizations.of(context)!.failedToConnectToServer;
        });
        return;
      }

      final dataAny =
          meProfile['data'] ?? meProfile['result'] ?? meProfile['user'];
      if (dataAny is! Map) return;
      final data = Map<String, dynamic>.from(dataAny);

      // Helper: read custom field value
      String cf(String key) {
        final cfs = data['customfields'];
        if (cfs is List) {
          for (final item in cfs) {
            if (item is Map && item['input_name']?.toString() == key) {
              return item['input_value']?.toString() ?? '';
            }
          }
        }
        return '';
      }

      // Get user ID and profile photo filename from documents array
      final uid = (data['_id'] ?? data['id'] ?? '').toString();
      String? profileFileName;

      // Extract profile photo filename from documents array
      final documents = data['documents'];
      if (documents is List) {
        for (final doc in documents) {
          if (doc is Map && doc['input_name']?.toString() == 'cf_avatar') {
            profileFileName = doc['input_value']?.toString();
            break;
          }
        }
      }

      debugPrint('[PROFILE] User ID: $uid');
      debugPrint('[PROFILE] Profile filename: $profileFileName');

      // Save to storage
      await storage.ready;
      if (uid.isNotEmpty) await storage.setItem('uid', uid);
      if (profileFileName != null && profileFileName.isNotEmpty) {
        await storage.setItem('profile_photo_filename', profileFileName);
      }

      setState(() {
        _email = (data['email'] ?? '').toString();
        _headerFullName = '${cf('cf_first_name')} ${cf('cf_last_name')}'.trim();
        _headerEpf = cf('cf_epf_no');
        _designation = cf('cf_designation');
        _department = cf('cf_department');
        _phone = cf('cf_phone');
        _address = cf('cf_address');
        _nic = cf('cf_nic');
        _dob = cf('cf_dob');
      });

      // Build photo URL (use APIService resolver to try multiple patterns)
      await _buildProfilePhotoUrl(uid: uid, fileName: profileFileName);
    } catch (e) {
      debugPrint('[PROFILE] Error loading profile: $e');
      setState(() {
        _error = DesignConfig.getFriendlyErrorMessage(context, e);
      });
    } finally {
      if (mounted) setState(() => _loadingMe = false);
    }
  }

  /// Resolve profile photo URL via APIService (tries multiple patterns)
  Future<void> _buildProfilePhotoUrl(
      {required String uid, String? fileName}) async {
    if (uid.isEmpty || fileName == null || fileName.isEmpty) {
      debugPrint('[PROFILE] ⚠️ Missing UID or filename for photo');
      setState(() {
        _profilePhotoUrl = '';
        _photoLoading = false;
      });
      return;
    }

    if (mounted) setState(() => _photoLoading = true);

    try {
      final resolved =
          await _apiService.getResolvedProfilePhotoUrl(size: '150-150');
      debugPrint('[PROFILE] Resolved photo URL: $resolved');
      if (resolved != null && resolved.isNotEmpty) {
        setState(() => _profilePhotoUrl = resolved);
      } else {
        setState(() => _profilePhotoUrl = '');
      }
    } catch (e) {
      debugPrint('[PROFILE] Error resolving photo URL: $e');
      setState(() => _profilePhotoUrl = '');
    } finally {
      if (mounted) setState(() => _photoLoading = false);
    }
  }

  /// Auth headers for CachedNetworkImageProvider

  /// Auth headers for CachedNetworkImageProvider
  Map<String, String> _authHeaders() {
    final oauthToken = storage.getItem('token')?.toString() ?? '';
    final accessToken = storage.getItem('access_token')?.toString() ?? '';
    final tenant = storage.getItem('tenant')?.toString() ?? '';

    debugPrint(
        '[PROFILE] Auth - Oauth: ${oauthToken.isNotEmpty ? "present" : "missing"}, Bearer: ${accessToken.isNotEmpty ? "present" : "missing"}');

    return {
      'Accept': 'image/*',
      if (oauthToken.isNotEmpty) 'Oauth-Token': oauthToken,
      if (accessToken.isNotEmpty) 'Authorization': 'Bearer $accessToken',
      if (tenant.isNotEmpty) 'Tenant': tenant,
    };
  }

  // ── UI Widgets ─────────────────────────────────────────────────────────────

  Widget _topCircleButton(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: HRColors.flavorIconBackgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _topHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _topCircleButton(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: SvgPicture.asset(
                'assets/svg/drawer_icon.svg',
                colorFilter: ColorFilter.mode(
                  HRColors.flavorIconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            AutoSizeText(
              AppLocalizations.of(context)!.myProfileTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF791B27),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, HRNotifications.routeName);
                await FCMService.loadUnreadCount();
              },
              child: ValueListenableBuilder<int>(
                valueListenable: FCMService.unreadCount,
                builder: (context, count, _) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: HRColors.flavorIconBackgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/notifications_icon.svg',
                          colorFilter: ColorFilter.mode(
                            HRColors.flavorIconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar widget - displays profile photo from backend
  Widget _buildAvatar() {
    const double size = 80;

    // Show loading indicator
    if (_photoLoading) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: const ClipOval(
          child: Center(
            child: CupertinoActivityIndicator(
              color: Color(0xFF791B27),
              radius: 12,
            ),
          ),
        ),
      );
    }

    // Show image if URL is available
    if (_profilePhotoUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: OctoImage(
            image: CachedNetworkImageProvider(
              _profilePhotoUrl,
              headers: _authHeaders(),
            ),
            placeholderBuilder: OctoBlurHashFix.placeHolder(
              'LRHe%pIA.m_2KjxawKNGIWkWD*M{',
            ),
            errorBuilder: (context, error, stacktrace) {
              debugPrint('[PROFILE] ❌ Failed to load image: $error');
              return _avatarFallback();
            },
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Show fallback if no photo
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: _avatarFallback()),
    );
  }

  Widget _avatarFallback() {
    final firstLetter = _headerFullName.isNotEmpty ? _headerFullName[0].toUpperCase() : 'H';
    return Container(
      color: const Color(0xFF791B27),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF59E0B),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(DesignConfig.defaultBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_headerFullName.isNotEmpty)
                  AutoSizeText(
                    _headerFullName,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF791B27),
                    ),
                  ),
                const SizedBox(height: 4),
                AutoSizeText(
                  '${AppLocalizations.of(context)!.epfLabel}${_headerEpf.isNotEmpty ? _headerEpf : "N/A"}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D7F77),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_designation.isNotEmpty) ...[
                      _buildBadge(_designation, null),
                      const SizedBox(width: 8),
                    ],
                    if (_department.isNotEmpty)
                      _buildBadge(_department, const Icon(Icons.check_rounded, size: 12, color: Color(0xFFF59E0B))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Widget? prefixIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBE1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon,
            const SizedBox(width: 4),
          ],
          AutoSizeText(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF503020),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    Color iconColor = _textPrimary,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 2.0 : 0.0),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          AutoSizeText(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8D7F77),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AutoSizeText(
              value.isNotEmpty
                  ? value
                  : AppLocalizations.of(context)!.notAdded,
              maxLines: maxLines,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF503020),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(DesignConfig.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, size: 18, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              AutoSizeText(
                AppLocalizations.of(context)!.personalInformation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF791B27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.email_rounded,
            title: AppLocalizations.of(context)!.emailAddressText,
            value: _email,
            iconColor: _primaryColor,
          ),
          _buildInfoItem(
            icon: Icons.phone_rounded,
            title: AppLocalizations.of(context)!.phoneLabel,
            value: _phone,
            iconColor: Colors.green,
          ),
          _buildInfoItem(
            icon: Icons.location_on_rounded,
            title: AppLocalizations.of(context)!.addressLabel,
            value: _address,
            iconColor: Colors.blue,
            maxLines: 2,
          ),
          _buildInfoItem(
            icon: Icons.badge_rounded,
            title: AppLocalizations.of(context)!.nicLabel,
            value: _nic,
            iconColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(DesignConfig.defaultBorderRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.cake_rounded, size: 18, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          AutoSizeText(
            AppLocalizations.of(context)!.dateOfBirth,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF791B27),
            ),
          ),
          const Spacer(),
          AutoSizeText(
            _dob.isNotEmpty ? _dob : AppLocalizations.of(context)!.notAdded,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF503020),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawerScrimColor: Colors.black.withOpacity(0.3),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DesignConfig.drawerContent(_scaffoldKey, context),
      ),
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          _topHeader(),
          Expanded(
            child: _loadingMe
                ? Center(
                    child: CupertinoActivityIndicator(
                      color: HRColors.darkOrangeColor,
                      radius: 16.0,
                    ),
                  )
                : _error != null
                    ? DesignConfig.buildErrorState(
                        context,
                        message: _error!,
                        onRetry: _loadProfileData,
                      )
                    : RefreshIndicator(
                        color: _primaryColor,
                        onRefresh: _loadProfileData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              _buildProfileCard(),
                              _buildPersonalInfo(),
                              _buildDateOfBirthCard(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
